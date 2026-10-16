package changxi_backend

import std.fs.*
import std.collection.*
import std.env.*
import std.random.*
import std.convert.*
import std.time.*

// =============================================================================
// 用户存储（文件持久化）+ 公共小工具
//
// 用户数据持久化到 users.txt（程序运行目录下），每行一个用户，字段用 | 分隔：
//   手机号|密码哈希|昵称|真实姓名|报考等级
//
// 密码不存明文，存 SHA256 十六进制哈希；验证码是内存态（进程内有效，重启失效）。
// =============================================================================

public const USERS_FILE: String = "users.txt"

// 一个用户
public class User {
    public var number: String = ""
    public var passwordHash: String = ""
    public var nickname: String = ""
    public var realName: String = ""
    public var examLevel: Int64 = 0   // 0 未选，1/2/3 对应初/中/高级

    // 已设置密码 = 注册完成
    public func isRegistered(): Bool {
        return !passwordHash.isEmpty()
    }
}

// 一条待验证的验证码（内存态）
public class PendingCode {
    public var code: String = ""       // 6 位验证码
    public var expireAt: Int64 = 0     // 过期时间，毫秒时间戳
}

// 验证码有效期：5 分钟（毫秒）
public const CODE_EXPIRE_MS: Int64 = 5 * 60 * 1000

// 当前时间，毫秒时间戳（UnixEpoch 起算）
public func nowMillis(): Int64 {
    return DateTime.nowUTC().toUnixTimeStamp().toMilliseconds()
}

// 从终端读一行，去掉末尾换行符；读失败（EOF）返回空串
public func readInput(): String {
    match (getStdIn().readln()) {
        case Some(s) => s
        case None => ""
    }
}

// 从终端读一行，保留「读不到」这个信息：EOF 时返回 None。
// readInput() 把 EOF 也当成空串，菜单循环里用它判断不出「用户按了回车」还是
// 「输入已经结束」，会一直空转。菜单这类 while 循环必须用这个版本。
public func readLineOrEof(): ?String {
    return getStdIn().readln()
}

// 打印提示语（不换行），并立即刷新，保证在终端里立刻显示
public func prompt(msg: String): Unit {
    print(msg, flush: true)
}

// 生成 6 位数字验证码：[100000, 999999]
public func generateCode(): String {
    let r = Random()
    return (100000 + r.nextInt64(900000)).toString()
}

// 密码 -> 简易哈希（仅演示用，非加密安全！）
// 用多项式散列（同 Java String.hashCode 的思路）把密码折叠成一个整数，
// 目的只是「不把明文密码写进文件」。
// 生产环境必须换成 SHA256 / bcrypt 等加密安全哈希（依赖 OpenSSL，另配环境）。
public func hashPassword(password: String): String {
    var hash: Int64 = 0
    for (b in password.toArray()) {
        hash = hash * 31 + Int64(b)
    }
    return hash.toString()
}

// 读取全部用户
public func loadUsers(): ArrayList<User> {
    let users = ArrayList<User>()
    if (!exists(USERS_FILE)) {
        return users
    }
    let content = String.fromUtf8(File.readFrom(USERS_FILE))
    for (line in content.split("\n", removeEmpty: true)) {
        let parts = line.split("|")
        if (parts.size >= 5) {
            let u = User()
            u.number = parts[0]
            u.passwordHash = parts[1]
            u.nickname = parts[2]
            u.realName = parts[3]
            match (Int64.tryParse(parts[4])) {
                case Some(v) => u.examLevel = v
                case None => u.examLevel = 0
            }
            users.add(u)
        }
    }
    return users
}

// 保存全部用户（覆盖写）
public func saveUsers(users: ArrayList<User>): Unit {
    var content = ""
    for (u in users) {
        content += "${u.number}|${u.passwordHash}|${u.nickname}|${u.realName}|${u.examLevel}\n"
    }
    File.writeTo(USERS_FILE, content.toArray())
}

// 按手机号查用户，查不到返回 None
public func findUser(users: ArrayList<User>, number: String): ?User {
    for (u in users) {
        if (u.number == number) {
            return Some(u)
        }
    }
    return None
}
