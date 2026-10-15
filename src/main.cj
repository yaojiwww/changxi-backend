package changxi_backend

import std.collection.*
import std.convert.*

// =============================================================================
// 保育员考试刷题 —— 命令行交互版入口
//
// 流程：
//   主菜单 → 注册（手机号→验证码→填信息）→ 注册完直接进系统
//          → 登录（手机号+密码）→ 进系统
//   系统内 → 选等级考试（基础题 + 该级题）→ 逐题作答 → 出正确率
// =============================================================================

main(args: Array<String>): Int64 {
    println("===== 保育员考试刷题系统 =====")

    let users = loadUsers()
    // 手机号 -> 验证码（含过期时间），内存态（进程内有效）
    let pendingCodes = HashMap<String, PendingCode>()

    while (true) {
        println("")
        println("[1] 注册")
        println("[2] 登录")
        println("[3] 退出")
        prompt("请选择：")
        let choice = match (readLineOrEof()) {
            case Some(line) => line.trimAscii()
            case None =>
                // 输入已结束（管道读完 / Ctrl+D），再循环下去就是空转刷屏
                println("")
                println("再见！")
                return 0
        }

        if (choice == "1") {
            register(users, pendingCodes)
        } else if (choice == "2") {
            login(users)
        } else if (choice == "3") {
            println("再见！")
            break
        } else {
            println("输入无效，请重新选择")
        }
    }
    return 0
}

// —— 注册：手机号 → 验证码 → 填信息 ——
func register(users: ArrayList<User>, pendingCodes: HashMap<String, PendingCode>): Unit {
    println("")
    println("---- 注册 ----")
    prompt("请输入手机号：")
    let number = readInput().trimAscii()

    if (number.size != 11) {
        println("手机号应为 11 位数字")
        return
    }
    match (findUser(users, number)) {
        case Some(u) =>
            if (u.isRegistered()) {
                println("该手机号已注册，请直接登录")
                return
            }
        case None => ()
    }

    let code = generateCode()
    let pc = PendingCode()
    pc.code = code
    pc.expireAt = nowMillis() + CODE_EXPIRE_MS
    pendingCodes.add(number, pc)
    println("验证码已发送：${code}（5 分钟内有效，本地演示直接显示）")

    prompt("请输入验证码：")
    let inputCode = readInput().trimAscii()
    match (pendingCodes.get(number)) {
        case Some(p) =>
            if (nowMillis() > p.expireAt) {
                println("验证码已过期，请重新获取")
                return
            }
            if (p.code != inputCode) {
                println("验证码错误")
                return
            }
        case None =>
            println("请先获取验证码")
            return
    }

    prompt("请输入昵称：")
    let nickname = readInput().trimAscii()
    prompt("请输入真实姓名：")
    let realName = readInput().trimAscii()
    prompt("请设置密码：")
    let password = readInput()

    if (nickname.isEmpty() || password.isEmpty()) {
        println("昵称和密码不能为空")
        return
    }

    match (findUser(users, number)) {
        case Some(u) =>
            u.nickname = nickname
            u.realName = realName
            u.passwordHash = hashPassword(password)
        case None =>
            let u = User()
            u.number = number
            u.nickname = nickname
            u.realName = realName
            u.passwordHash = hashPassword(password)
            users.add(u)
    }
    saveUsers(users)
    println("注册成功！欢迎，${nickname}")
    enterSystem()
}

// —— 登录：手机号 + 密码 ——
func login(users: ArrayList<User>): Unit {
    println("")
    println("---- 登录 ----")
    prompt("请输入手机号：")
    let number = readInput().trimAscii()
    prompt("请输入密码：")
    let password = readInput()

    if (number.isEmpty() || password.isEmpty()) {
        println("手机号和密码不能为空")
        return
    }

    match (findUser(users, number)) {
        case None =>
            println("该手机号未注册")
        case Some(u) =>
            if (!u.isRegistered()) {
                println("该账号尚未完成注册")
                return
            }
            if (u.passwordHash != hashPassword(password)) {
                println("密码错误")
                return
            }
            println("登录成功！欢迎，${u.nickname}")
            enterSystem()
    }
}

// —— 进入系统后的菜单 ——
func enterSystem(): Unit {
    while (true) {
        println("")
        println("[1] 开始考试")
        println("[2] AI助手")
        println("[3] 退出登录")
        prompt("请选择：")
        let choice = match (readLineOrEof()) {
            case Some(line) => line.trimAscii()
            case None =>
                println("")
                println("输入已结束，返回主菜单")
                return
        }

        if (choice == "1") {
            takeExam()
        } else if (choice == "2") {
            aiAssistant()
        } else if (choice == "3") {
            println("已退出登录")
            return
        } else {
            println("输入无效，请重新选择")
        }
    }
}

// —— 考试 ——
func takeExam(): Unit {
    println("")
    println("---- 选择报考等级 ----")
    println("[1] 初级保育员（基础题 + 初级题）")
    println("[2] 中级保育员（基础题 + 中级题）")
    println("[3] 高级保育员（基础题 + 高级题）")
    prompt("请选择：")
    let level = match (Int64.tryParse(readInput().trimAscii())) {
        case Some(v) => v
        case None => 0
    }
    if (level < 1 || level > 3) {
        println("等级无效")
        return
    }

    let questions = questionsForLevel(level)
    var correct = 0
    for (i in 0..questions.size) {
        let q = questions[i]
        println("")
        println("第 ${i + 1} 题（${q.category}）：${q.text}")
        println("A. ${q.optionA}")
        println("B. ${q.optionB}")
        println("C. ${q.optionC}")
        println("D. ${q.optionD}")
        prompt("请输入答案（A/B/C/D）：")
        let ans = readInput().trimAscii().toAsciiUpper()

        if (ans == q.answer) {
            println("回答正确！")
            correct += 1
        } else {
            println("回答错误，正确答案是 ${q.answer}")
        }
        println("解析：${q.explanation}")
    }

    let total = questions.size
    let rate = correct * 100 / total
    println("")
    println("===== 考试结束 =====")
    println("答对 ${correct}/${total} 题，正确率 ${rate}%")
}
