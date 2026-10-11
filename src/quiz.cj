package changxi_backend

import std.collection.*
import stdx.encoding.json.*
import soulsoft_web_http.*

// 刷题域接口：章节列表 / 章节取题 / 提交答案
// 三个接口都要求登录，没带有效 token 一律 401 + CODE_TOKEN_INVALID

const ANSWER_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

// 取当前登录用户。没登录就顺手写好 401 响应，调用方拿 None 直接 return 即可
func requireUser(ctx: HttpContext): Option<Int64> {
    match (currentUser(ctx)) {
        case Some(id) => return Some(id)
        case None =>
            writeError(ctx.response, 401, CODE_TOKEN_INVALID, "登录已失效，请重新登录")
            return None
    }
}

// GET /api/v1/chapters
// 返回全部章节，每章带我的练习进度，客户端首屏直接用这一份数据画列表
public func handleChapters(ctx: HttpContext): Unit {
    let userId = match (requireUser(ctx)) {
        case Some(id) => id
        case None => return
    }

    let items = JsonArray()
    for (c in listChapters(userId)) {
        let item = JsonObject()
        item.put("id", JsonInt(c.id))
        item.put("name", JsonString(c.name))
        item.put("total", JsonInt(c.total))
        item.put("answered", JsonInt(c.answered))
        item.put("correct", JsonInt(c.correct))
        items.add(item)
    }
    writeOk(ctx.response, items)
}

// GET /api/v1/chapters/{id}/questions?page=1&pageSize=20
// 取某一章的题目。响应里【绝不能】出现正确答案和解析 —— 那是提交答案时才给的
public func handleChapterQuestions(ctx: HttpContext): Unit {
    let userId = match (requireUser(ctx)) {
        case Some(id) => id
        case None => return
    }

    let chapterId = routeInt(ctx.request, "id")
    if (chapterId <= 0 || !chapterExists(chapterId)) {
        writeError(ctx.response, 404, CODE_CHAPTER_NOT_FOUND, "章节不存在")
        return
    }

    // pageSize 上限 100：一次取太多会让内存里的组装和响应体都没必要地膨胀
    let page = queryInt(ctx.request, "page", 1, 1, 100000)
    let pageSize = queryInt(ctx.request, "pageSize", 20, 1, 100)
    let offset = (page - 1) * pageSize

    let items = JsonArray()
    for (q in listQuestions(chapterId, userId, pageSize, offset)) {
        let item = JsonObject()
        item.put("id", JsonInt(q.id))
        item.put("type", JsonInt(q.questionType))
        item.put("stem", JsonString(q.stem))
        // answered / myAnswer / lastCorrect 是给"接着上次做"用的：
        // 客户端靠它找到第一道没答过的题
        item.put("answered", JsonBool(q.answered))
        item.put("myAnswer", JsonString(q.myAnswer))
        item.put("lastCorrect", JsonBool(q.lastCorrect))

        let options = JsonArray()
        for (o in q.options) {
            let option = JsonObject()
            option.put("label", JsonString(o.label))
            option.put("content", JsonString(o.content))
            options.add(option)
        }
        item.put("options", options)
        items.add(item)
    }

    let data = JsonObject()
    data.put("page", JsonInt(page))
    data.put("pageSize", JsonInt(pageSize))
    data.put("items", items)
    writeOk(ctx.response, data)
}

// POST /api/v1/questions/{id}/answer   body: {"answer":"ABD"}
// 答完立刻判分并回答案与解析，同时把这次作答记进 user_answers
public func handleAnswer(ctx: HttpContext): Unit {
    let userId = match (requireUser(ctx)) {
        case Some(id) => id
        case None => return
    }

    let questionId = routeInt(ctx.request, "id")
    if (questionId <= 0) {
        writeError(ctx.response, 404, CODE_QUESTION_NOT_FOUND, "题目不存在")
        return
    }

    let myAnswer = normalizeAnswer(jsonField(readRequestBody(ctx.request), "answer"))
    if (myAnswer.isEmpty()) {
        writeError(ctx.response, 400, CODE_PARAM_INVALID, "答案不能为空")
        return
    }

    let question = match (findQuestion(questionId)) {
        case Some(q) => q
        case None =>
            writeError(ctx.response, 404, CODE_QUESTION_NOT_FOUND, "题目不存在")
            return
    }

    // 提交了题目里没有的选项标号（比如题目只有 A~D，却提交了 "E"），按参数错误处理。
    // 挡在这里而不是直接判错，是因为这几乎总是客户端 bug，不该污染错题本
    if (!isValidAnswer(myAnswer, question.options)) {
        writeError(ctx.response, 400, CODE_ANSWER_INVALID, "答案包含该题不存在的选项")
        return
    }

    let rightAnswer = rightAnswerOf(question.options)
    // 多选题全对才算对。两边都是归一化排序过的标号串，直接比字符串即可
    let correct = myAnswer == rightAnswer
    saveAnswer(userId, questionId, question.chapterId, myAnswer, correct)

    let data = JsonObject()
    data.put("correct", JsonBool(correct))
    data.put("myAnswer", JsonString(myAnswer))
    data.put("rightAnswer", JsonString(rightAnswer))
    data.put("analysis", JsonString(question.analysis))
    writeOk(ctx.response, data)
}

// 归一化作答：把 "dab" / "A B D" / "ABBD" 一律压成 "ABD"。
// 只认 ASCII 的 A-Z —— 中文是多字节，每个字节都落在 A-Z 之外，天然被过滤掉。
// 用 26 个布尔位收集、再按字母表顺序输出，顺带完成了去重和排序
func normalizeAnswer(raw: String): String {
    var hit = Array<Bool>(26, repeat: false)
    for (b in raw.toAsciiUpper().toArray()) {
        let index = Int64(b) - 0x41
        if (index >= 0 && index < 26) {
            hit[index] = true
        }
    }
    var out = ""
    var i = 0
    while (i < 26) {
        if (hit[i]) {
            out += String.fromUtf8([UInt8(0x41 + i)])
        }
        i++
    }
    return out
}

// 归一化后的作答里，每个字母都必须是该题真实存在的选项标号
func isValidAnswer(answer: String, options: ArrayList<DbOption>): Bool {
    for (b in answer.toArray()) {
        var found = false
        for (o in options) {
            let label = o.label.toArray()
            if (label.size == 1 && label[0] == b) {
                found = true
            }
        }
        if (!found) {
            return false
        }
    }
    return true
}

// 正确答案 = 所有 is_correct 选项的标号，按 A-Z 顺序拼起来。
// 顺序和 normalizeAnswer 的产物一致，两者才能直接比较
func rightAnswerOf(options: ArrayList<DbOption>): String {
    var out = ""
    for (b in ANSWER_ALPHABET.toArray()) {
        for (o in options) {
            let label = o.label.toArray()
            if (label.size == 1 && label[0] == b && o.isCorrect) {
                out += String.fromUtf8([b])
            }
        }
    }
    return out
}
