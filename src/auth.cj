package changxi_backend

// 注册/登录可能失败的原因。
// 逻辑层只回答"因为什么失败"，具体给用户看什么中文（或者将来 HTTP 接口返回什么码），
// 由界面层决定 —— 这样终端和 HTTP 接口能共用同一套判断。
public enum AuthError {
    | PhoneInvalid             // 1. 手机号应为 11 位数字
    | PhoneTaken               // 2. 该手机号已注册
    | CodeExpired              // 3. 验证码已过期
    | CodeMismatch             // 4. 验证码错误
    | CodeNotSent              // 5. 请先获取验证码
    | NameEmpty                // 6. 昵称为空        
    | PasswordEmpty            // 7. 密码为空           
    | PhoneNotFound            // 8. 该手机号未注册
    | RegistrationIncomplete   // 9. 该账号尚未完成注册
    | PasswordMismatch         // 10. 密码错误
}
// 注册这一步要问用户的全部输入，打包成一个对象。
//
// 为什么不让 registerUser 直接收 5 个 String 参数？
//   1. 调用点是 registerUser(users, codes, n, c, nick, real, pwd) ——
//      nickname 和 realName 都是 String，写反了编译器不报错，注册出来的名字就是错的。
//      包成对象后写的是 cmd.nickname = nick，一眼看得出对错。
//   2. 以后要加字段（比如邀请码），只改这个类，函数签名不用动。
//
// 这就是 CQRS 里的「Command（命令）」：一个 Command 装一次写操作需要的全部输入。
// 等目录铺开了，按 CLAUDE.md 的结构搬到 application/commands/ 去。
public class RegisterCommand {
    public var number: String = ""    // 手机号
    public var code: String = ""      // 用户填的验证码（不是服务端生成的那个）
    public var nickname: String = ""
    public var realName: String = ""
    public var password: String = ""
}
