package changxi_backend

import std.database.sql.*
import mysql_driver.*

// 会话表和消息表的读写，表结构见 sql/conversation.sql、sql/message.sql
//
// 事务写法要点（mysql_driver 的标准门面）：
//   - Transaction 自身没有 prepareStatement，语句必须用同一个 conn 准备，
//     才会自动并入这个事务；
//   - lastInsertId 只在 INSERT 之后立刻读才有效，驱动在别的语句后会把它清零；
//   - 已经 commit 之后再 rollback 会抛异常，所以回滚要吞掉自己的异常。

// 取消息前若干"字符"做会话标题。必须按 rune 截断 ——
// 按字节切会把中文切成乱码
func shortTitle(message: String, maxRunes: Int64): String {
    let runes = message.toRuneArray()
    if (runes.size <= maxRunes) {
        return message
    }
    var out = ""
    var i = 0
    while (i < maxRunes) {
        out += runes[i].toString()
        i++
    }
    return out
}

// 会话是否属于这个用户。
// SQL 里同时带 id 和 user_id，别人的会话直接查不到 —— 这是防越权的关键
func conversationBelongsTo(conn: Connection, conversationId: Int64, userId: Int64): Bool {
    let stmt = conn.prepareStatement(
        "SELECT id FROM conversation WHERE id = ? AND user_id = ?")
    try {
        stmt.set<Int64>(0, conversationId)
        stmt.set<Int64>(1, userId)
        let rs = stmt.query()
        try {
            return rs.next()
        } finally {
            rs.close()
        }
    } finally {
        stmt.close()
    }
}

// 往会话里追加一条消息
func insertMessage(conn: Connection, conversationId: Int64, role: String, content: String): Unit {
    let stmt = conn.prepareStatement(
        "INSERT INTO message (conversation_id, role, content) VALUES (?, ?, ?)")
    try {
        stmt.set<Int64>(0, conversationId)
        stmt.set<String>(1, role)
        stmt.set<String>(2, content)
        stmt.update()
    } finally {
        stmt.close()
    }
}

// 刷新会话的"最近活跃时间"。
// message 的写入不会碰 conversation 行，不显式 UPDATE 的话 updated_at 不会变
func touchConversation(conn: Connection, conversationId: Int64, userId: Int64): Unit {
    let stmt = conn.prepareStatement(
        "UPDATE conversation SET updated_at = CURRENT_TIMESTAMP WHERE id = ? AND user_id = ?")
    try {
        stmt.set<Int64>(0, conversationId)
        stmt.set<Int64>(1, userId)
        stmt.update()
    } finally {
        stmt.close()
    }
}

// 首轮对话：建会话 + 写入"用户问的"和"AI 答的"两条消息，整体一个事务。
// 放同一个事务是为了避免消息写失败时留下一个空会话
public func createConversationWithMessages(
        userId: Int64, userMessage: String, assistantMessage: String): Int64 {
    let conn = db().connect()
    try {
        let tx = conn.createTransaction()
        tx.begin()
        try {
            var convId: Int64 = 0
            let stmt = conn.prepareStatement(
                "INSERT INTO conversation (user_id, dify_conversation_id, title) VALUES (?, '', ?)")
            try {
                stmt.set<Int64>(0, userId)
                stmt.set<String>(1, shortTitle(userMessage, 30))
                convId = stmt.update().lastInsertId   // 必须紧跟 INSERT 读
            } finally {
                stmt.close()
            }

            insertMessage(conn, convId, "user", userMessage)
            insertMessage(conn, convId, "assistant", assistantMessage)

            tx.commit()
            return convId
        } catch (e: Exception) {
            try {
                tx.rollback()
            } catch (_: Exception) {
                // 回滚失败时保留原始异常，它才是真正的原因
            }
            throw e
        }
    } finally {
        conn.close()
    }
}

// 续聊：校验会话归属，追加两条消息并刷新活跃时间，整体一个事务。
// 会话不存在或不属于该用户统一返回 false，由调用方回 404 ——
// 不区分"不存在"和"不是你的"，避免被拿来枚举别人的会话 id
public func appendChatMessages(
        conversationId: Int64, userId: Int64,
        userMessage: String, assistantMessage: String): Bool {
    let conn = db().connect()
    try {
        let tx = conn.createTransaction()
        tx.begin()
        try {
            if (!conversationBelongsTo(conn, conversationId, userId)) {
                tx.rollback()
                return false
            }

            insertMessage(conn, conversationId, "user", userMessage)
            insertMessage(conn, conversationId, "assistant", assistantMessage)
            touchConversation(conn, conversationId, userId)

            tx.commit()
            return true
        } catch (e: Exception) {
            try {
                tx.rollback()
            } catch (_: Exception) {
                // 同上：回滚失败不掩盖原始异常
            }
            throw e
        }
    } finally {
        conn.close()
    }
}
