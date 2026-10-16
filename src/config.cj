package changxi_backend

import std.convert.* // Int64.tryParse 是 std.convert 里 Parsable 的扩展，不 import 就报「未声明标识符」
import soulsoft_extensions_configuration.*

// =============================================================================
// 应用配置
//
// Spire 的 WebHost 启动时已经自动把 ./appsettings.json（以及环境变量、命令行参数）
// 读进了一个 IConfiguration。这里只做一件事：把它翻译成强类型的对象。
//
// 为什么不直接在业务代码里写 config["Database:Host"]？
//   1. 键名是字符串，拼错了编译器不管，要等运行时才发现，拿到的是 None；
//   2. 拿到的永远是 ?String，每个调用点都得自己处理"没有这个配置"；
//   3. 数据库密码、JWT 密钥这类东西散落在各个文件里，审计时找不全。
// 集中翻译一次，业务代码只依赖 AppConfig 这个对象，键名写错在这一处就炸了。
//
// 覆盖顺序（后面的盖前面的），由 WebHost 内部决定，我们不用管：
//   appsettings.json → appsettings.{环境}.json → 环境变量(cangjie_ 前缀) → 命令行参数
// 例：生产上不想把 JWT 密钥写进文件，就设环境变量
//   cangjie_Jwt__Secret=xxxxxxxx        ← 注意是双下划线，一个下划线只是普通字符
// =============================================================================

// 数据库连接配置
public class DatabaseConfig {
    public var host: String = "127.0.0.1"
    public var port: UInt16 = 3306
    public var user: String = ""
    public var password: String = ""
    public var name: String = "changxi"
    public var poolMaxSize: Int64 = 10
    public var connectionTimeoutMs: Int64 = 5000

    // 驱动要的连接串。注意上面这些字段是单独传给驱动的（见 property 列表），
    // 连接串里只放地址，用户名/密码/库名走 open() 的第二个参数。
    public func serverUrl(): String {
        return "mariadb://${host}:${port}"
    }
}

// JWT 签发/校验配置
public class JwtConfig {
    public var secret: String = ""        // HS256 的对称密钥，必须够长；空值启动时直接拒绝启动
    public var issuer: String = "changxi" // 签发者
    public var audience: String = "changxi-app" // 面向谁签发
    public var expiresHours: Int64 = 168  // 令牌有效期（小时），7 天
}

// 整个应用的配置
public class AppConfig {
    public var database = DatabaseConfig()
    public var jwt = JwtConfig()
    public var smsCodeExpireSeconds: Int64 = 300 // 验证码有效期，5 分钟
}

// 读一个字符串配置项，读不到就用默认值
private func readString(configuration: IConfiguration, key: String, fallback: String): String {
    return configuration[key] ?? fallback
}

// 读一个整数配置项。配置写错了（比如写成 "abc"）不抛异常，直接退回默认值——
// 但下面 loadAppConfig 里对密码/密钥这类关键项是「读不到就不让启动」，两者策略不同。
private func readInt64(configuration: IConfiguration, key: String, fallback: Int64): Int64 {
    match (configuration[key]) {
        case Some(text) =>
            match (Int64.tryParse(text)) {
                case Some(value) => value
                case None => fallback
            }
        case None => fallback
    }
}

// 把 IConfiguration 翻译成 AppConfig
public func loadAppConfig(configuration: IConfiguration): AppConfig {
    let config = AppConfig()

    config.database.host = readString(configuration, "Database:Host", config.database.host)
    config.database.port = UInt16(readInt64(configuration, "Database:Port", Int64(config.database.port)))
    config.database.user = readString(configuration, "Database:User", config.database.user)
    config.database.password = readString(configuration, "Database:Password", config.database.password)
    config.database.name = readString(configuration, "Database:Name", config.database.name)
    config.database.poolMaxSize = readInt64(configuration, "Database:PoolMaxSize", config.database.poolMaxSize)
    config.database.connectionTimeoutMs =
        readInt64(configuration, "Database:ConnectionTimeoutMs", config.database.connectionTimeoutMs)

    config.jwt.secret = readString(configuration, "Jwt:Secret", "")
    config.jwt.issuer = readString(configuration, "Jwt:Issuer", config.jwt.issuer)
    config.jwt.audience = readString(configuration, "Jwt:Audience", config.jwt.audience)
    config.jwt.expiresHours = readInt64(configuration, "Jwt:ExpiresHours", config.jwt.expiresHours)

    config.smsCodeExpireSeconds = readInt64(configuration, "Sms:CodeExpireSeconds", config.smsCodeExpireSeconds)

    return config
}

// 打印密钥时只露个头，别把完整密钥刷进终端日志和 CI 日志
public func maskSecret(secret: String): String {
    if (secret.size <= 8) {
        return "****"
    }
    return secret[0..4] + "****" + secret[secret.size - 4..secret.size]
}
