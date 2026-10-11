package changxi_backend

import std.collection.*
import std.database.sql.*
import mysql_driver.*

// 刷题域的数据读写，落在 MariaDB 的 changxi 库里
// 表结构见 sql/quiz.sql

// 章节 + 当前用户在该章的练习进度
public class DbChapter {
    public var id: Int64 = 0
    public var name: String = ""
    public var total: Int64 = 0      // 该章题目总数
    public var answered: Int64 = 0   // 我已作答的题目数
    public var correct: Int64 = 0    // 我答对的题目数
}

// 一个选项。isCorrect 在"取题下发"和"判分"两条路径上都要用到，
// 所以统一从库里读出来，由序列化那一层决定要不要给客户端 —— 不在读的时候丢信息
public class DbOption {
    public var label: String = ""
    public var content: String = ""
    public var isCorrect: Bool = false
}

// 一道题
public class DbQuestion {
    public var id: Int64 = 0
    public var chapterId: Int64 = 0
    public var questionType: Int64 = 1  // 1单选 2多选（type 是仓颉关键字，换个名）
    public var stem: String = ""
    public var analysis: String = ""
    public var sortOrder: Int64 = 0
    public var options: ArrayList<DbOption> = ArrayList<DbOption>()
    public var myAnswer: String = ""  // 空串 = 从未作答
    public var answered: Bool = false
    public var lastCorrect: Bool = false
}

// 把一批 id 拼成 SQL 的 IN 列表：1,2,3。
// 参数全是库里的 BIGINT，拼接不引入注入面；用占位符反而没法表达"数量不定"的 IN
func idList(ids: ArrayList<Int64>): String {
    var out = ""
    var first = true
    for (id in ids) {
        if (!first) {
            out += ","
        }
        out += id.toString()
        first = false
    }
    return out
}

// 章节列表（每章带我的练习进度），一条聚合查询出结果。
// 两个 LEFT JOIN 会让行数按 题目 × 作答 膨胀，所以计数一律 COUNT(DISTINCT ...)
public func listChapters(userId: Int64): ArrayList<DbChapter> {
    let result = ArrayList<DbChapter>()
    let conn = db().connect()
    try {
        let stmt = conn.prepareStatement(
            "SELECT c.id, c.name, " +
            "  COUNT(DISTINCT q.id) AS total, " +
            "  COUNT(DISTINCT a.question_id) AS answered, " +
            "  COUNT(DISTINCT CASE WHEN a.is_correct = 1 THEN a.question_id END) AS correct " +
            "FROM chapters c " +
            "LEFT JOIN questions q ON q.chapter_id = c.id " +
            "LEFT JOIN user_answers a ON a.question_id = q.id AND a.user_id = ? " +
            "GROUP BY c.id, c.name " +
            "ORDER BY c.sort_order, c.id")
        try {
            stmt.set<Int64>(0, userId)
            let rs = stmt.query()
            try {
                while (rs.next()) {
                    let c = DbChapter()
                    c.id = rs.get<Int64>(0)
                    c.name = rs.get<String>(1)
                    c.total = rs.get<Int64>(2)
                    c.answered = rs.get<Int64>(3)
                    c.correct = rs.get<Int64>(4)
                    result.add(c)
                }
            } finally {
                rs.close()
            }
        } finally {
            stmt.close()
        }
    } finally {
        conn.close()
    }
    return result
}

// 章节是否存在：用于把"章节不存在"和"章节里还没题"这两种情况分开
public func chapterExists(chapterId: Int64): Bool {
    var found = false
    let conn = db().connect()
    try {
        let stmt = conn.prepareStatement("SELECT 1 FROM chapters WHERE id = ?")
        try {
            stmt.set<Int64>(0, chapterId)
            let rs = stmt.query()
            try {
                found = rs.next()
            } finally {
                rs.close()
            }
        } finally {
            stmt.close()
        }
    } finally {
        conn.close()
    }
    return found
}

// 取某一章的一页题目，附带我的作答状态。
// limit/offset 由调用方夹好范围后用字符串拼进来：驱动对 LIMIT ? 的支持没有保证，
// 而这两个值天然是整数，拼接没有注入风险
public func listQuestions(chapterId: Int64, userId: Int64,
                          limit: Int64, offset: Int64): ArrayList<DbQuestion> {
    let result = ArrayList<DbQuestion>()
    let conn = db().connect()
    try {
        let stmt = conn.prepareStatement(
            "SELECT id, chapter_id, type, stem, sort_order FROM questions " +
            "WHERE chapter_id = ? ORDER BY sort_order, id " +
            "LIMIT ${limit} OFFSET ${offset}")
        try {
            stmt.set<Int64>(0, chapterId)
            let rs = stmt.query()
            try {
                while (rs.next()) {
                    let q = DbQuestion()
                    q.id = rs.get<Int64>(0)
                    q.chapterId = rs.get<Int64>(1)
                    q.questionType = rs.get<Int64>(2)
                    q.stem = rs.get<String>(3)
                    q.sortOrder = rs.get<Int64>(4)
                    result.add(q)
                }
            } finally {
                rs.close()
            }
        } finally {
            stmt.close()
        }

        if (result.isEmpty()) {
            return result
        }

        // 一次查询捞出整页的选项和作答状态，避免"每题一次"的 N+1
        var ids = ArrayList<Int64>()
        for (q in result) {
            ids.add(q.id)
        }
        loadOptions(conn, result, ids)
        loadMyAnswers(conn, result, ids, userId)
    } finally {
        conn.close()
    }
    return result
}

// 把整页题的选项一次性查回来，按 question_id 分配回各自的题
func loadOptions(conn: Connection, questions: ArrayList<DbQuestion>,
                 ids: ArrayList<Int64>): Unit {
    let byId = HashMap<Int64, DbQuestion>()
    for (q in questions) {
        byId.add(q.id, q)
    }
    let stmt = conn.prepareStatement(
        "SELECT question_id, label, content, is_correct FROM question_options " +
        "WHERE question_id IN (${idList(ids)}) ORDER BY question_id, sort_order")
    try {
        let rs = stmt.query()
        try {
            while (rs.next()) {
                let questionId = rs.get<Int64>(0)
                match (byId.get(questionId)) {
                    case Some(q) =>
                        let o = DbOption()
                        o.label = rs.get<String>(1)
                        o.content = rs.get<String>(2)
                        o.isCorrect = rs.get<Int64>(3) != 0
                        q.options.add(o)
                    case None => ()
                }
            }
        } finally {
            rs.close()
        }
    } finally {
        stmt.close()
    }
}

// 把整页题"我答过没有 / 上次答对没有"一次性查回来
func loadMyAnswers(conn: Connection, questions: ArrayList<DbQuestion>,
                   ids: ArrayList<Int64>, userId: Int64): Unit {
    let byId = HashMap<Int64, DbQuestion>()
    for (q in questions) {
        byId.add(q.id, q)
    }
    let stmt = conn.prepareStatement(
        "SELECT question_id, my_answer, is_correct FROM user_answers " +
        "WHERE user_id = ? AND question_id IN (${idList(ids)})")
    try {
        stmt.set<Int64>(0, userId)
        let rs = stmt.query()
        try {
            while (rs.next()) {
                let questionId = rs.get<Int64>(0)
                match (byId.get(questionId)) {
                    case Some(q) =>
                        q.answered = true
                        q.myAnswer = rs.get<String>(1)
                        q.lastCorrect = rs.get<Int64>(2) != 0
                    case None => ()
                }
            }
        } finally {
            rs.close()
        }
    } finally {
        stmt.close()
    }
}

// 按 id 取一道题（含正确答案和解析），用于判分。查不到返回 None
public func findQuestion(questionId: Int64): Option<DbQuestion> {
    var question: Option<DbQuestion> = None
    let conn = db().connect()
    try {
        let stmt = conn.prepareStatement(
            "SELECT id, chapter_id, type, stem, analysis, sort_order FROM questions WHERE id = ?")
        try {
            stmt.set<Int64>(0, questionId)
            let rs = stmt.query()
            try {
                if (rs.next()) {
                    let q = DbQuestion()
                    q.id = rs.get<Int64>(0)
                    q.chapterId = rs.get<Int64>(1)
                    q.questionType = rs.get<Int64>(2)
                    q.stem = rs.get<String>(3)
                    q.analysis = rs.get<String>(4)
                    q.sortOrder = rs.get<Int64>(5)
                    question = Some(q)
                }
            } finally {
                rs.close()
            }
        } finally {
            stmt.close()
        }

        match (question) {
            case Some(q) =>
                var ids = ArrayList<Int64>()
                ids.add(q.id)
                var one = ArrayList<DbQuestion>()
                one.add(q)
                loadOptions(conn, one, ids)
            case None => ()
        }
    } finally {
        conn.close()
    }
    return question
}

// 记一次作答。一人一题只留最后一条，重做直接覆盖
public func saveAnswer(userId: Int64, questionId: Int64, chapterId: Int64,
                       myAnswer: String, isCorrect: Bool): Unit {
    let conn = db().connect()
    try {
        let stmt = conn.prepareStatement(
            "INSERT INTO user_answers (user_id, question_id, chapter_id, my_answer, is_correct) " +
            "VALUES (?, ?, ?, ?, ?) " +
            "ON DUPLICATE KEY UPDATE my_answer = VALUES(my_answer), " +
            "  is_correct = VALUES(is_correct), answered_at = CURRENT_TIMESTAMP")
        try {
            stmt.set<Int64>(0, userId)
            stmt.set<Int64>(1, questionId)
            stmt.set<Int64>(2, chapterId)
            stmt.set<String>(3, myAnswer)
            stmt.set<Int64>(4, if (isCorrect) { 1 } else { 0 })
            stmt.update()
        } finally {
            stmt.close()
        }
    } finally {
        conn.close()
    }
}
