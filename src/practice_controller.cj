package changxi_backend

import std.convert.*
import stdx.encoding.json.*
import soulsoft_web_http.*

// =============================================================================
// 练习接口：章节树 + 抽题 + 判题 + 交卷
//
// 本文件只负责"把请求翻译成对仓储的调用，再把结果拼成契约要求的 JSON"，
// 一条 SQL 都不写（SQL 全在 repositories.cj）。
//
// 三个贯穿全部接口的约定：
//   ① 每个接口第一件事都是 authenticate()，拿不到 user 就直接 return
//      ——它自己已经回过 401 信封了，这里再写一遍会变成两个响应体。
//   ② 所有查询参数已经**被框架解码过一次**：Spire 的 request.query 底层是
//      stdx.encoding.url.Form，实测 "%E5%88%9D%E7%BA%A7" 进来就是"初级"，
//      而且只解一次（"%2520" → "%20"）。所以这里**绝对不能**再调 urlDecode，
//      二次解码会把用户真实输入里字面的 %20 弄坏。
//   ③ 参数不合法的判定标准是"前端契约对不上"（缺字段、拼错名字、非法取值），
//      一律回 1002 并把原因说清楚——这类错误是开发期 bug，藏着只会让联调变慢。
//      而"资源不存在"（kpId 查不到）是 1004，两者不能混。
// =============================================================================

// 抽题默认返回多少道、最多多少道。任务书定的上限是 20。
let QUESTIONS_DEFAULT_COUNT: Int64 = 20
let QUESTIONS_MAX_COUNT: Int64 = 20

// 每日一练固定 5 道。和前端 DailyPracticePage 的演示题数量一致：
// 接上真接口之后，题目来源变了，但"每天 5 道"这个节奏不能变。
let DAILY_QUESTION_COUNT: Int64 = 5

// -----------------------------------------------------------------------------
// GET /api/v1/practice/knowledge-points?tab=&level=
//
// 章节树 + 真实题量。前端目前用的是本地内置的 kpId 列表，这个接口属于预留，
// 但语义必须是真的：total 来自 knowledge_point 表，不是数出来的题目行数。
// -----------------------------------------------------------------------------
public func handleKnowledgePoints(context: HttpContext, services: AppServices): Unit {
    let userOpt = authenticate(context, services)
    if (userOpt.isNone()) {
        return
    }

    // tab 只认 basic / professional / 空。不认别的值（比如大写 BASIC）：
    // 静默按"全部"处理的话，前端参数拼错了会看到一份"看起来对、其实没过滤"的数据，
    // 比直接报错难查得多。
    let tab = context.request.query.get("tab") ?? ""
    if (!tab.isEmpty() && tab != "basic" && tab != "professional") {
        writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST,
            "tab 只能是 basic 或 professional")
        return
    }

    // level 空 = 不过滤级别。传了就必须是整数，否则同样是为了让参数拼错当场暴露。
    var level: ?Int64 = None
    let levelText = context.request.query.get("level") ?? ""
    if (!levelText.isEmpty()) {
        match (Int64.tryParse(levelText)) {
            case Some(value) => level = value
            case None =>
                writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST,
                    "level 必须是整数")
                return
        }
    }

    let records = services.knowledgePoints.list(tab, level)
    let items = JsonArray()
    for (record in records) {
        let item = JsonObject()
        item.put("kpId", JsonString(record.kpId))
        item.put("name", JsonString(record.name))
        item.put("label", JsonString(record.label))
        item.put("levelIndex", JsonInt(record.levelIndex))
        item.put("total", JsonInt(record.total))
        item.put("tab", JsonString(record.tab))
        // 一级章节是 null（不是 ""），前端靠这个判断要不要缩进
        item.put("parentKpId", jsonStringOrNull(record.parentKpId))
        items.add(item)
    }

    let data = JsonObject()
    data.put("knowledgePoints", items)
    writeApiOk(context.response, data)
}

// -----------------------------------------------------------------------------
// GET /api/v1/practice/questions?kpId=<kpId>&count=20
//
// 按知识点随机抽题。★ 这个接口**绝对不能下发 answer 和 explanation**：
// 前端拿不到答案，判题就必须走服务端（4.3），这条路一断，题库就抄不走了。
// QuestionRecord 里确实带着这两个字段，但不往 JSON 里放 —— 靠"这里没写"来保证，
// 所以改这个方法时，新增字段前先想清楚它该不该给前端看。
// -----------------------------------------------------------------------------
public func handlePracticeQuestions(context: HttpContext, services: AppServices): Unit {
    let userOpt = authenticate(context, services)
    if (userOpt.isNone()) {
        return
    }

    let kpId = context.request.query.get("kpId") ?? ""
    if (kpId.isEmpty()) {
        writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST, "缺少 kpId 参数")
        return
    }
    // 先查知识点再抽题（而不是直接抽、空了再报 1004）：
    // "知识点不存在"和"知识点存在但一道题都没录"是两件事，前者 1004、后者是正常返回空数组。
    // 直接抽题的话这两种情况长得一模一样，没法区分。
    let knowledgePoint = match (services.knowledgePoints.findById(kpId)) {
        case Some(record) => record
        case None =>
            writeApiError(context.response, StatusCodes.NotFound, ApiCode.NOT_FOUND, "知识点不存在")
            return
    }

    var count = QUESTIONS_DEFAULT_COUNT
    let countText = context.request.query.get("count") ?? ""
    if (!countText.isEmpty()) {
        match (Int64.tryParse(countText)) {
            case Some(value) =>
                if (value <= 0) {
                    writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST,
                        "count 必须是正整数")
                    return
                }
                // 超过上限就按上限截断，不报错：这是"少给点"而不是"参数错了"，
                // 前端传 count=50 的意图很明确，回 1002 属于没事找事。
                count = if (value > QUESTIONS_MAX_COUNT) { QUESTIONS_MAX_COUNT } else { value }
            case None =>
                writeApiError(context.response, StatusCodes.BadRequest, ApiCode.BAD_REQUEST,
                    "count 必须是整数")
                return
        }
    }

    let questions = services.questions.pickRandom(knowledgePoint.kpId, count)
    let items = JsonArray()
    for (question in questions) {
        let item = JsonObject()
        item.put("questionId", JsonString(question.code))
        item.put("stem", JsonString(question.stem))
        // options 是 4 元素数组，**顺序即 A/B/C/D，文案里不带 "A." 前缀**。
        // 前端按下标渲染并回传字母（下标 0 → "A"），所以顺序错了就是全盘错。
        let options = JsonArray()
        options.add(JsonString(question.optionA))
        options.add(JsonString(question.optionB))
        options.add(JsonString(question.optionC))
        options.add(JsonString(question.optionD))
        item.put("options", options)
        // 展示名用 label（带级别前缀），错题本/收藏就是按这个字符串分组的；
        // 下面顶层的 kpName 用 name（不带前缀），两者用途不同，别合并。
        item.put("knowledgePoint", JsonString(knowledgePoint.label))
        item.put("kpId", JsonString(question.kpId))
        item.put("type", JsonString(question.qType))
        items.add(item)
    }

    let data = JsonObject()
    data.put("kpId", JsonString(knowledgePoint.kpId))
    // kpName 用 name：这是"这个知识点叫什么"，给页面标题用；
    // 每道题里的 knowledgePoint 才是分组用的 label。
    data.put("kpName", JsonString(knowledgePoint.name))
    // total 是知识点题库总题量（考纲题量），不是下面 questions 的长度。
    // 前端进度条和 x/N 显示的是它，所以这里必须取 knowledge_point.total。
    data.put("total", JsonInt(knowledgePoint.total))
    data.put("questions", items)
    writeApiOk(context.response, data)
}

// -----------------------------------------------------------------------------
// GET /api/v1/practice/daily
//
// 每日一练。不带任何参数——"今天的题"由服务端决定（日期在仓储层按北京时间算），
// 前端只负责展示，不能自己传 date/kpId 来挑题。
//
// 抽题规则见 QuestionRepository.pickDaily：同一天、同一用户拿到的题和顺序
// 都是固定的，中途退出再进来不会换题。
//
// ★ 返回里**没有 answer**：每日一练和普通练习一样，答案不下发，
//   判题只能走服务端（判题接口还没做，见待办）。
// -----------------------------------------------------------------------------
public func handleDailyPractice(context: HttpContext, services: AppServices): Unit {
    let userOpt = authenticate(context, services)
    if (userOpt.isNone()) {
        return
    }
    let user = userOpt.getOrThrow()

    let daily = services.questions.pickDaily(user.id, DAILY_QUESTION_COUNT)
    let items = JsonArray()
    for (question in daily.questions) {
        let item = JsonObject()
        item.put("questionId", JsonString(question.code))
        item.put("stem", JsonString(question.stem))
        // 和 /practice/questions 一样：顺序即 A/B/C/D，文案不带前缀
        let options = JsonArray()
        options.add(JsonString(question.optionA))
        options.add(JsonString(question.optionB))
        options.add(JsonString(question.optionC))
        options.add(JsonString(question.optionD))
        item.put("options", options)
        item.put("knowledgePoint", JsonString(question.kpLabel))
        items.add(item)
    }

    let data = JsonObject()
    data.put("date", JsonString(daily.date))
    // practiceId 暂时用「日期 + 用户」拼，同一天同一用户固定。
    // 现在前端不调交卷接口，这个值只用来让前端区分"是不是同一次练习"；
    // 等 batch-submit 落库之后，这里换成 practice_record.id。
    data.put("practiceId", JsonString("daily-${daily.date}-${user.id}"))
    // 题库为空时返回空数组而不是 1004：这是"今天确实没题"，不是请求错了。
    // 前端拿到空数组会按自己的兜底逻辑处理（见 DailyPracticePage 的 demoMode）。
    data.put("questions", items)
    writeApiOk(context.response, data)
}
