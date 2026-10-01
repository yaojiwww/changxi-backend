# cangjie 命令
1. 构建
```cjpm
cjpm build
```
2. 运行
```cjpm
cjpm run
```

# 项目结构
开新项目时推荐采用的目录结构。这个结构已经在博客项目中验证过：
```text
your-project/
├── web-api/                        # 后端：仓颉 + Spire
│   ├── src/
│   │   ├── main.cj                 # 入口：WebHost 配置、中间件管道
│   │   ├── controllers/            # 控制器：路由入口，参数绑定
│   │   ├── application/
│   │   │   ├── commands/           # 命令（CQRS 写）：Command + Handler
│   │   │   ├── queries/            # 查询（CQRS 读）：Query 对象
│   │   │   ├── services/           # 业务服务：跨模块复用的逻辑
│   │   │   ├── models/             # 应用层模型：SearchModel 等
│   │   │   └── behaviors/          # 管道行为：事务、日志等
│   │   ├── domain/
│   │   │   ├── entities/           # 实体：数据库表映射（代码生成）
│   │   │   ├── models/             # DTO：序列化模型（代码生成）
│   │   │   └── views/              # 视图实体（代码生成）
│   │   ├── infrastructure/
│   │   │   ├── AdminDbContext.cj          # 数据库上下文
│   │   │   ├── repositories/             # 仓储层
│   │   │   │   ├── BlogRepository.cj
│   │   │   │   ├── UserRepository.cj
│   │   │   │   └── CommentRepository.cj
│   │   │   ├── MapperUtilities.cj        # 对象映射
│   │   │   ├── UserAccessor.cj           # 当前用户访问器
│   │   │   └── middlewares/              # 中间件
│   │   └── abstractions/          # 抽象基类：Entity、QueryModel、PageResult
│   ├── template/                  # 代码生成模板
│   ├── library/                   # 本地依赖
│   └── wwwroot/                   # 静态文件托管目录
└── blog.sql                       # 数据库初始化脚本
```