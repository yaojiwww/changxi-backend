package changxi_backend

import std.env.*
import std.database.sql.*
import stdx.encoding.hex.*
import mysql_driver.*

// 读环境变量，读不到返回空串（不抛）
func optionalEnv(key: String): String {
    match (getVariable(key)) {
        case Some(s) => s
        case None => ""
    }
}

// 所有密钥只从环境变量来；读不到就立刻失败，绝不给默认值
public func mustGetEnv(key: String): String {
    let value = optionalEnv(key)
    if (value.isEmpty()) {
        throw Exception("缺少环境变量 ${key}，请设置后重开终端")
    }
    return value
}

// 开发模式开关：只有显式设成 1/true/yes/on 才为真。
// 联调期用它把验证码放进响应；漏配时必须落到"关"，绝不能反过来。
public func devMode(): Bool {
    let value = optionalEnv("CHANGXI_DEV_MODE")
    return value == "1" || value == "true" || value == "yes" || value == "on"
}

// 数据库数据源：全进程共用一个，第一次用到时才真正去连
var sharedDataSource: Option<Datasource> = None

// 拼 DSN 时对用户名/密码做百分号编码：
// 密码里出现 @ : / ? # 这类字符会直接把 DSN 解析搞坏，必须先编码
func percentEncode(raw: String): String {
    var out = ""
    for (b in raw.toArray()) {
        let unreserved = (b >= 0x41 && b <= 0x5A) || (b >= 0x61 && b <= 0x7A) ||  // A-Z a-z
                         (b >= 0x30 && b <= 0x39) ||                              // 0-9
                         b == 0x2D || b == 0x5F || b == 0x2E || b == 0x7E         // - _ . ~
        if (unreserved) {
            out += String.fromUtf8([b])
        } else {
            out += "%" + toHexString([b])
        }
    }
    return out
}

// 连接串优先用完整的 CHANGXI_DB_DSN，形如：
//   mysql://用户名:密码@127.0.0.1:3306/changxi?tls=false
// 没配就用 .bashrc 里已有的 DB_* 分量拼一个 —— 本机只给了分量，不兜底就完全起不来
func dbDsn(): String {
    let full = optionalEnv("CHANGXI_DB_DSN")
    if (!full.isEmpty()) {
        return full
    }
    let host = mustGetEnv("DB_HOST")
    let port = mustGetEnv("DB_PORT")
    let user = mustGetEnv("DB_USER")
    let pass = mustGetEnv("DB_PASS")
    let name = mustGetEnv("DB_NAME")
    return "mysql://${percentEncode(user)}:${percentEncode(pass)}@${host}:${port}/${name}?tls=false"
}

// 绝不硬编码账号密码到代码里
public func db(): Datasource {
    match (sharedDataSource) {
        case Some(ds) => return ds
        case None => ()
    }
    let dsn = dbDsn()
    // 驱动在 import 时自动注册，这里直接按名字取
    let ds = DriverManager.getDriver("mysql").getOrThrow().open(dsn, [])
    sharedDataSource = Some(ds)
    return ds
}
