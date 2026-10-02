package changxi_backend

import std.database.sql.*
import mysql_driver.*

// 用户表的读写，全部落到 MariaDB 的 changxi.users 表
// 表结构见 sql/user.sql

// 一行用户记录，对应 users 表的一行
public class DbUser {
    public var id: Int64 = 0            // 主键，对应 userIds
    public var number: String = ""      // 手机号，对应 userPhones
    public var password: String = ""    // 密码哈希，对应 userPasswords
    public var verifyCode: String = ""  // 验证码，对应 userVerifyCodes
    public var codeExpire: Int64 = 0    // 验证码过期时间(毫秒)，对应 userCodeExpires
}

// 按手机号查用户；查不到返回 None
public func findUserByNumber(number: String): Option<DbUser> {
    let conn = db().connect()
    try {
        let stmt = conn.prepareStatement(
            "SELECT id, number, password, verify_code, code_expire FROM users WHERE number = ?")
        try {
            stmt.set<String>(0, number)
            let rs = stmt.query()
            try {
                if (rs.next()) {
                    let u = DbUser()
                    u.id = rs.get<Int64>(0)
                    u.number = rs.get<String>(1)
                    u.password = rs.get<String>(2)
                    u.verifyCode = rs.get<String>(3)
                    u.codeExpire = rs.get<Int64>(4)
                    return Some(u)
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
    return None
}

// 插入一条新用户，返回自增主键 id
public func createUser(number: String, password: String): Int64 {
    var newId: Int64 = 0
    let conn = db().connect()
    try {
        let stmt = conn.prepareStatement("INSERT INTO users (number, password) VALUES (?, ?)")
        try {
            stmt.set<String>(0, number)
            stmt.set<String>(1, password)
            newId = stmt.update().lastInsertId
        } finally {
            stmt.close()
        }
    } finally {
        conn.close()
    }
    println("【数据库】创建用户 id=${newId}, phone=${number}")
    return newId
}

// 更新验证码和过期时间
public func updateVerifyCode(number: String, code: String, expireTime: Int64): Unit {
    let conn = db().connect()
    try {
        let stmt = conn.prepareStatement(
            "UPDATE users SET verify_code = ?, code_expire = ? WHERE number = ?")
        try {
            stmt.set<String>(0, code)
            stmt.set<Int64>(1, expireTime)
            stmt.set<String>(2, number)
            stmt.update()
        } finally {
            stmt.close()
        }
    } finally {
        conn.close()
    }
}

// 写入密码哈希，并清掉验证码（注册成功时调用）
public func setPasswordAndClearCode(number: String, hashedPwd: String): Unit {
    let conn = db().connect()
    try {
        let stmt = conn.prepareStatement(
            "UPDATE users SET password = ?, verify_code = '', code_expire = 0 WHERE number = ?")
        try {
            stmt.set<String>(0, hashedPwd)
            stmt.set<String>(1, number)
            stmt.update()
        } finally {
            stmt.close()
        }
    } finally {
        conn.close()
    }
}
