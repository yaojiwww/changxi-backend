package changxi_backend

// =============================================================================
// 应用服务集合
//
// 启动时构造一次，之后只读。处理器通过闭包拿到它（见 main.cj），
// 不用全局变量也不用容器查找——依赖关系一眼可见，测试时也可以造一份假的传进去。
// =============================================================================

public class AppServices {
    public let config: AppConfig
    public let database: Database
    public let users: UserRepository
    public let smsCodes: SmsCodeRepository
    public let knowledgePoints: KnowledgePointRepository
    public let questions: QuestionRepository

    // 一个"假"的密码哈希，用于登录时给不存在的账号也走一遍校验。
    // 目的：让"账号不存在"和"密码错误"两种失败耗时接近，防止攻击者靠响应时间
    // 判断某个手机号是否注册过（账号枚举）。启动时算一次，之后复用。
    public let dummyPasswordHash: String

    public init(config: AppConfig) {
        this.config = config
        let database = Database(config.database)
        this.database = database
        this.users = UserRepository(database)
        this.smsCodes = SmsCodeRepository(database)
        this.knowledgePoints = KnowledgePointRepository(database)
        this.questions = QuestionRepository(database)
        this.dummyPasswordHash = hashPassword("changxi-dummy-password")
    }
}
