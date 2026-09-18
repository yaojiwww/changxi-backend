package changxi_backend

import std.collection.*

// 内存存储模块（开发阶段用，后续可替换为数据库）
// 用数组存数据，程序重启后数据清空

// 用户数据（平行数组，每个数组的同一索引对应同一个用户）
var userIds: ArrayList<Int64> = ArrayList()
var userPhones: ArrayList<String> = ArrayList()
var userPasswords: ArrayList<String> = ArrayList()
var userVerifyCodes: ArrayList<String> = ArrayList()
var userCodeExpires: ArrayList<Int64> = ArrayList()
var nextUserId: Int64 = 1

// 根据手机号查找用户，返回用户索引；找不到返回 -1
public func findUserByNumber(number: String): Int64 {
    var i = 0
    while (i < userPhones.size) {
        if (userPhones[i] == number) {
            return i
        }
        i++
    }
    return -1
}

// 创建新用户，返回用户 ID
public func createUser(number: String, password: String): Int64 {
    let id = nextUserId
    nextUserId++
    userIds.add(id)
    userPhones.add(number)
    userPasswords.add(password)
    userVerifyCodes.add("")
    userCodeExpires.add(0)
    println("【内存】创建用户 id=${id}, phone=${number}")
    return id
}

// 更新验证码和过期时间
public func updateVerifyCode(number: String, code: String, expireTime: Int64): Unit {
    let idx = findUserByNumber(number)
    if (idx >= 0) {
        userVerifyCodes[idx] = code
        userCodeExpires[idx] = expireTime
        println("【内存】更新验证码 phone=${number}, code=${code}")
    }
}

// 更新密码
public func updatePassword(idx: Int64, hashedPwd: String): Unit {
    if (idx >= 0 && idx < userPasswords.size) {
        userPasswords[idx] = hashedPwd
    }
}

// 清除验证码
public func clearVerifyCode(idx: Int64): Unit {
    if (idx >= 0 && idx < userVerifyCodes.size) {
        userVerifyCodes[idx] = ""
        userCodeExpires[idx] = 0
    }
}
