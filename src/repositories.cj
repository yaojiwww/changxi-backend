package changxi_backend

import std.collection.*
import std.database.sql.*

// =============================================================================
// 仓储层：所有 SQL 都只在这一个文件里出现
//
// 为什么把 SQL 圈在这一层？
//   接口逻辑（校验参数、发令牌、回信封）和"数据怎么存"是两件会各自变化的事。
//   混在一起的话，将来加一张表或改个字段名，得把每个接口都读一遍。
//
// 表名 `user` 在 MariaDB 里是保留字（USER() 是函数），所以**必须**加反引号，
// 不加就是语法错误。
//
// 字段名对照：接口里叫 number（前端契约），库里叫 phone（见 sql/schema.sql 的说明），
// 转换只发生在这里。
// =============================================================================

// 查用户时的固定列清单。列顺序和下面 toRecord 里的序号一一对应，改这里必须同步改那里。
let USER_SELECT_COLUMNS: String =
    "select id, phone, password_hash, nickname, status, token_version from `user` "

// 一行用户数据。字段与 sql/schema.sql 的 user 表一一对应。
public class UserRecord {
    public var id: Int64 = 0
    public var phone: String = ""
    public var passwordHash: String = ""
    public var nickname: String = ""
    public var status: Int64 = 0        // 0 正常 / 1 禁用 / 2 已注销
    public var tokenVersion: Int64 = 0
}

public class UserRepository {
    private let database: Database

    public init(database: Database) {
        this.database = database
    }

    // 把当前行映射成 UserRecord。
    // 整数列统一按 Int64 读：驱动内部是把原始值按目标类型解析（unsigned 也吃得下），
    // 我们这些 id / tinyint 都远小于 Int64 上限，没必要为省几个字节引入 UInt32。
    private func toRecord(result: QueryResult): UserRecord {
        let record = UserRecord()
        record.id = result.get<Int64>(1)
        record.phone = result.getOrNull<String>(2) ?? ""
        record.passwordHash = result.getOrNull<String>(3) ?? ""
        record.nickname = result.getOrNull<String>(4) ?? ""
        record.status = result.get<Int64>(5)
        record.tokenVersion = result.get<Int64>(6)
        return record
    }

    public func findByPhone(phone: String): ?UserRecord {
        let connection = database.connection()
        try {
            let statement = connection.prepareStatement(USER_SELECT_COLUMNS + "where phone = ? limit 1")
            statement.set(1, phone)
            let result = statement.query()
            if (result.next()) {
                let record = toRecord(result)
                result.close()
                statement.close()
                return record
            }
            result.close()
            statement.close()
            return None
        } finally {
            connection.close()
        }
    }

    public func findById(id: Int64): ?UserRecord {
        let connection = database.connection()
        try {
            let statement = connection.prepareStatement(USER_SELECT_COLUMNS + "where id = ? limit 1")
            statement.set(1, id)
            let result = statement.query()
            if (result.next()) {
                let record = toRecord(result)
                result.close()
                statement.close()
                return record
            }
            result.close()
            statement.close()
            return None
        } finally {
            connection.close()
        }
    }

    // 插入新用户，返回自增 id
    public func insert(phone: String, passwordHash: String, nickname: String): Int64 {
        let connection = database.connection()
        try {
            let statement = connection.prepareStatement(
                "insert into `user` (phone, password_hash, nickname, last_login_at) values (?, ?, ?, now())")
            statement.set(1, phone)
            statement.set(2, passwordHash)
            statement.set(3, nickname)
            let result = statement.update()
            statement.close()
            return result.lastInsertId
        } finally {
            connection.close()
        }
    }

    public func touchLastLogin(id: Int64): Unit {
        let connection = database.connection()
        try {
            let statement = connection.prepareStatement("update `user` set last_login_at = now() where id = ?")
            statement.set(1, id)
            statement.update()
            statement.close()
        } finally {
            connection.close()
        }
    }

    // 登出：token_version + 1。已签发的令牌里带着旧版本号，全部立刻失效。
    // 这就是"无状态令牌怎么做到能撤销"的答案——令牌本身不可撤销，
    // 但校验时会拿令牌里的版本号和库里的比对。
    public func bumpTokenVersion(id: Int64): Int64 {
        let connection = database.connection()
        try {
            let statement = connection.prepareStatement(
                "update `user` set token_version = token_version + 1 where id = ?")
            statement.set(1, id)
            statement.update()
            statement.close()
            // 顺手在同一条连接上读回新版本号（前端后续如果要用到就省一次查询）
            let read = connection.prepareStatement("select token_version from `user` where id = ?")
            read.set(1, id)
            let result = read.query()
            let version = if (result.next()) { result.get<Int64>(1) } else { -1 }
            result.close()
            read.close()
            return version
        } finally {
            connection.close()
        }
    }

    // 注销账号（软删除）：status 置 2，并把 phone 改写成 del_{id}_{原号}。
    // 为什么必须改写 phone？因为 phone 上有 UNIQUE 约束，如果原样留着，
    // 这个号就永远注册不了了（新记录插不进去）。用户其实期望的是
    // "注销后还能用同一个手机号重新注册"。改写成"墓碑值"既释放了唯一键，
    // 又保留了"这个号曾经注销过"的痕迹。同时 token_version + 1，让已发的令牌立刻作废。
    public func softDelete(id: Int64, phone: String): Unit {
        let connection = database.connection()
        try {
            let statement = connection.prepareStatement(
                "update `user` set phone = ?, status = 2, token_version = token_version + 1 where id = ?")
            statement.set(1, "del_${id}_${phone}")
            statement.set(2, id)
            statement.update()
            statement.close()
        } finally {
            connection.close()
        }
    }
}

// 一条验证码记录（只取校验需要的两列）
public class SmsCodeRecord {
    public var id: Int64 = 0
    public var code: String = ""
}

public class SmsCodeRepository {
    private let database: Database

    public init(database: Database) {
        this.database = database
    }

    // 有效期的计算交给数据库的 now()：应用和数据库的时钟可能有偏差，
    // 而"有没有过期"必须和写入时的时间基准一致。
    // 秒数来自配置而非用户输入，直接拼进 SQL 没有注入风险。
    public func insert(phone: String, code: String, scene: String, expireSeconds: Int64): Unit {
        let connection = database.connection()
        try {
            let statement = connection.prepareStatement(
                "insert into sms_code (phone, code, scene, expires_at) values (?, ?, ?, date_add(now(), interval ${expireSeconds} second))")
            statement.set(1, phone)
            statement.set(2, code)
            statement.set(3, scene)
            statement.update()
            statement.close()
        } finally {
            connection.close()
        }
    }

    // 取这个号码最近一条"还没用过、还没过期"的验证码
    public func findLatestUsable(phone: String, scene: String): ?SmsCodeRecord {
        let connection = database.connection()
        try {
            let statement = connection.prepareStatement(
                "select id, code from sms_code where phone = ? and scene = ? and used_at is null and expires_at > now() order by id desc limit 1")
            statement.set(1, phone)
            statement.set(2, scene)
            let result = statement.query()
            if (result.next()) {
                let record = SmsCodeRecord()
                record.id = result.get<Int64>(1)
                record.code = result.getOrNull<String>(2) ?? ""
                result.close()
                statement.close()
                return record
            }
            result.close()
            statement.close()
            return None
        } finally {
            connection.close()
        }
    }

    // 用掉验证码：used_at 打上时间戳，防止同一条码被重复使用（重放）
    public func markUsed(id: Int64): Unit {
        let connection = database.connection()
        try {
            let statement = connection.prepareStatement("update sms_code set used_at = now() where id = ?")
            statement.set(1, id)
            statement.update()
            statement.close()
        } finally {
            connection.close()
        }
    }
}

// =============================================================================
// 题库：知识点
// =============================================================================

// 查知识点的固定列清单。列顺序和 KnowledgePointRepository.toRecord 里的序号一一对应。
let KNOWLEDGE_POINT_SELECT_COLUMNS: String =
    "select kp_id, name, label, level_index, tab, parent_kp_id, sort_no, total from knowledge_point "

// 不分级别的 level_index 值，见 sql/schema.sql 建表处的说明。
// 放在这里当常量，是因为接口层要区分"没传 level"（不过滤）和"传了 level"（要带上它）。
let LEVEL_INDEX_ANY: Int64 = -1

public class KnowledgePointRecord {
    public var kpId: String = ""
    public var name: String = ""
    public var label: String = ""
    public var levelIndex: Int64 = 0
    public var tab: String = ""
    public var parentKpId: ?String = None   // 一级章节是 NULL → None
    public var sortNo: Int64 = 0
    public var total: Int64 = 0
}

public class KnowledgePointRepository {
    private let database: Database

    public init(database: Database) {
        this.database = database
    }

    private func toRecord(result: QueryResult): KnowledgePointRecord {
        let record = KnowledgePointRecord()
        record.kpId = result.getOrNull<String>(1) ?? ""
        record.name = result.getOrNull<String>(2) ?? ""
        record.label = result.getOrNull<String>(3) ?? ""
        record.levelIndex = result.get<Int64>(4)
        record.tab = result.getOrNull<String>(5) ?? ""
        record.parentKpId = result.getOrNull<String>(6)
        record.sortNo = result.get<Int64>(7)
        record.total = result.get<Int64>(8)
        return record
    }

    // 按业务码取一个知识点。抽题前要先拿它，一是为了判断存在性（不存在回 1004），
    // 二是为了让 total（考纲题量）和 name/label 有个权威出处——
    // 这些值不允许由前端传进来，否则进度条上的分母可以随便编。
    public func findById(kpId: String): ?KnowledgePointRecord {
        let connection = database.connection()
        try {
            let statement = connection.prepareStatement(KNOWLEDGE_POINT_SELECT_COLUMNS + "where kp_id = ? limit 1")
            statement.set(1, kpId)
            let result = statement.query()
            if (result.next()) {
                let record = toRecord(result)
                result.close()
                statement.close()
                return record
            }
            result.close()
            statement.close()
            return None
        } finally {
            connection.close()
        }
    }

    // 章节列表。tab 为空串 = 不过滤页签；level 为 None = 不过滤级别。
    //
    // level 的过滤条件是 `level_index = ? or level_index = -1`，这个 or 是关键：
    // 法律法规是"不分级别"的（-1），选初级/中级/高级的人都得看到它。
    // 写成 `level_index = ?` 的话，前端的级别筛选会把基础章节整个筛掉。
    //
    // 排序按 tab → 级别 → sort_no：同一级别内 sort_no 才是出题人想要的顺序，
    // 跨级别时用级别号排（-1 的基础章自然排在最前）。最后补一个 kp_id 兜底，
    // 保证 sort_no 撞车时顺序也是稳定的（随机顺序对分页和缓存都是灾难）。
    public func list(tab: String, level: ?Int64): Array<KnowledgePointRecord> {
        var sql = KNOWLEDGE_POINT_SELECT_COLUMNS + "where 1 = 1"
        if (!tab.isEmpty()) {
            sql = sql + " and tab = ?"
        }
        if (level.isSome()) {
            sql = sql + " and (level_index = ? or level_index = ${LEVEL_INDEX_ANY})"
        }
        sql = sql + " order by tab, level_index, sort_no, kp_id"

        let connection = database.connection()
        try {
            let statement = connection.prepareStatement(sql)
            // 占位符的编号必须和上面拼 SQL 的顺序**逐步对上**：先 tab 再 level。
            // 这是动态拼 SQL 最容易出错的地方，加条件时务必同步改这里。
            var index: Int64 = 1
            if (!tab.isEmpty()) {
                statement.set(index, tab)
                index = index + 1
            }
            if (level.isSome()) {
                statement.set(index, level.getOrThrow())
            }
            let result = statement.query()
            let records = ArrayList<KnowledgePointRecord>()
            while (result.next()) {
                records.add(toRecord(result))
            }
            result.close()
            statement.close()
            return records.toArray()
        } finally {
            connection.close()
        }
    }
}

// =============================================================================
// 每日一练：跨知识点抽题
//
// 和 QUESTION_SELECT_COLUMNS 的区别：
//   ① 多 join 了 knowledge_point，为了拿到 label（"初级 · 组织饮水"）。
//      每日题来自不同章节，每道题的展示名都不一样，不能像 /practice/questions
//      那样在接口层统一用同一个知识点的 label；
//   ② ★ 故意不查 answer / explanation。每日一练的响应里绝不能出现答案，
//      这里连查都不查，比"查出来但接口层记得别放进去"可靠。
//
// 常量放在 QuestionRepository 之前是硬要求：仓颉的顶层 let 按源码顺序生效，
// 写在后面会报 "used before being defined"。
// =============================================================================

let DAILY_QUESTION_SELECT_COLUMNS: String =
    "select q.code, q.kp_id, k.label, q.stem, q.option_a, q.option_b, q.option_c, q.option_d, q.q_type " +
    "from question q join knowledge_point k on k.kp_id = q.kp_id " +
    "where q.status = 1 "

// 每日一练里的一道题。字段是前端 DailyQuestionItem 契约的子集，没有 answer 和 explanation。
public class DailyQuestionRecord {
    public var code: String = ""
    public var kpId: String = ""
    public var kpLabel: String = ""
    public var stem: String = ""
    public var optionA: String = ""
    public var optionB: String = ""
    public var optionC: String = ""
    public var optionD: String = ""
    public var qType: String = "single"
}

// 一天的一练：日期 + 当天的题。
// date 由数据库算出并原样下发，保证"哪一天"只有一个出处，不会出现
// 应用层和数据库各算一遍、跨天时差一天的情况。
public class DailyPracticeRecord {
    public var date: String = ""
    public var questions: Array<DailyQuestionRecord> = []
}

// =============================================================================
// 题库：题目
// =============================================================================

let QUESTION_SELECT_COLUMNS: String =
    "select code, kp_id, stem, option_a, option_b, option_c, option_d, answer, explanation, q_type from question "

public class QuestionRecord {
    public var code: String = ""
    public var kpId: String = ""
    public var stem: String = ""
    public var optionA: String = ""
    public var optionB: String = ""
    public var optionC: String = ""
    public var optionD: String = ""
    public var answer: String = ""        // 字母 A/B/C/D
    public var explanation: String = ""
    public var qType: String = "single"
}

public class QuestionRepository {
    private let database: Database

    public init(database: Database) {
        this.database = database
    }

    private func toRecord(result: QueryResult): QuestionRecord {
        let record = QuestionRecord()
        record.code = result.getOrNull<String>(1) ?? ""
        record.kpId = result.getOrNull<String>(2) ?? ""
        record.stem = result.getOrNull<String>(3) ?? ""
        record.optionA = result.getOrNull<String>(4) ?? ""
        record.optionB = result.getOrNull<String>(5) ?? ""
        record.optionC = result.getOrNull<String>(6) ?? ""
        record.optionD = result.getOrNull<String>(7) ?? ""
        record.answer = result.getOrNull<String>(8) ?? ""
        record.explanation = result.getOrNull<String>(9) ?? ""
        record.qType = result.getOrNull<String>(10) ?? "single"
        return record
    }

    // 按知识点随机抽题。
    //
    // 随机在 SQL 里做（order by rand()）而不是取回来在内存里洗牌：
    // 题库迟早会长到几万行，把整个知识点的题全查出来再随机，内存和网络都白费。
    // 现在数据量小，rand() 的全表排序代价可以忽略；等题量真上来了，
    // 换成"先 count 再按随机 offset 取"或者按 id 区间采样。
    //
    // status = 1 是必须的：下架的题不能再抽给用户，但它在错题本/流水里还引用着
    // （见 sql/schema.sql 里 status 列的说明）。
    //
    // limit 是拼进 SQL 的而不是占位符：count 已经在接口层校验成 1..20 的整数，
    // 不可能是注入内容（和 SmsCodeRepository 里拼 expireSeconds 同一个理由）。
    public func pickRandom(kpId: String, count: Int64): Array<QuestionRecord> {
        let connection = database.connection()
        try {
            let statement = connection.prepareStatement(
                QUESTION_SELECT_COLUMNS + "where kp_id = ? and status = 1 order by rand() limit ${count}")
            statement.set(1, kpId)
            let result = statement.query()
            let records = ArrayList<QuestionRecord>()
            while (result.next()) {
                records.add(toRecord(result))
            }
            result.close()
            statement.close()
            return records.toArray()
        } finally {
            connection.close()
        }
    }

    // -------------------------------------------------------------------------
    // 每日一练
    // -------------------------------------------------------------------------

    // 数据库里的"今天"（北京时间）。
    // 为什么让数据库算：服务器 TZ 虽然是 Asia/Shanghai，但代码里拿时间一律走
    // nowUTC()，如果在应用层手写 +8 再拼日期，跨月、跨年各要处理一次，写错了
    // 就是"每天凌晨 0 点到 8 点抽到前一天的题"。这里用 utc_timestamp() 显式 +8，
    // 规则只有一句，而且接口下发的 date 和抽题用的种子是**同一个值**。
    private func currentDateText(connection: Connection): String {
        let statement = connection.prepareStatement(
            "select date_format(date_add(utc_timestamp(), interval 8 hour), '%Y-%m-%d')")
        let result = statement.query()
        let text = if (result.next()) { result.getOrNull<String>(1) ?? "" } else { "" }
        result.close()
        statement.close()
        return text
    }

    // 抽当天的一套题：同一天、同一用户，题目和顺序都固定。
    //
    // 为什么不用 order by rand()：
    //   用户可能中途退出再进来。每次重抽的话"每日一练"就成了"每次一套新题"，
    //   用户刚做过的题会对不上，体验很怪。这里用 md5(题目code + 日期 + 用户ID)
    //   当排序键——输入不变，结果就不变，等价于"带种子的随机"。
    //   混进用户 ID 是为了让不同用户拿到的题不完全一样，避免同一时刻所有人
    //   都在读同一批热点行；如果产品希望所有人今天做同一套，把第二个参数去掉即可。
    //
    // limit 拼进 SQL 的理由同 pickRandom：count 由接口层保证是正整数。
    public func pickDaily(userId: Int64, count: Int64): DailyPracticeRecord {
        let connection = database.connection()
        try {
            let date = currentDateText(connection)
            let statement = connection.prepareStatement(
                DAILY_QUESTION_SELECT_COLUMNS + "order by md5(concat(q.code, ?, '-', ?)) limit ${count}")
            statement.set(1, date)
            statement.set(2, userId)
            let result = statement.query()
            let questions = ArrayList<DailyQuestionRecord>()
            while (result.next()) {
                let item = DailyQuestionRecord()
                item.code = result.getOrNull<String>(1) ?? ""
                item.kpId = result.getOrNull<String>(2) ?? ""
                item.kpLabel = result.getOrNull<String>(3) ?? ""
                item.stem = result.getOrNull<String>(4) ?? ""
                item.optionA = result.getOrNull<String>(5) ?? ""
                item.optionB = result.getOrNull<String>(6) ?? ""
                item.optionC = result.getOrNull<String>(7) ?? ""
                item.optionD = result.getOrNull<String>(8) ?? ""
                item.qType = result.getOrNull<String>(9) ?? "single"
                questions.add(item)
            }
            result.close()
            statement.close()

            let record = DailyPracticeRecord()
            record.date = date
            record.questions = questions.toArray()
            return record
        } finally {
            connection.close()
        }
    }
}
