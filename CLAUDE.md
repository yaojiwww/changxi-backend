<!-- 一个可以复用的 Claude.md 准则，指导 Claude Code 工作。 -->
# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此代码库中工作时提供指导。

<!-- 这个在 Work 模式下不需要，Learn 模式添加辅助学习。 -->
## CLAUDE 任务

claude助手全程指导我边学边做，不得一下把全部代码写出来，每次只说一点，一点一点来。

## 项目概述

保育员考试刷题app，内置AI解析和AI助手。
后端使用仓颉（Cangjie）+ Spire 框架，数据库使用 mariadb。

## 项目结构

```text
changxi-backend/                # 后端：仓颉 + Spire
├── src/
│   ├── main.cj                 # 入口：WebHost 配置、中间件管道
│   ├── controllers/            # 控制器：路由入口，参数绑定
│   ├── application/
│   │   ├── commands/           # 命令（CQRS 写）：Command + Handler
│   │   ├── queries/            # 查询（CQRS 读）：Query 对象
│   │   ├── services/           # 业务服务：跨模块复用的逻辑
│   │   ├── models/             # 应用层模型：SearchModel 等
│   │   └── behaviors/          # 管道行为：事务、日志等
│   ├── domain/
│   │   ├── entities/           # 实体：数据库表映射（代码生成）
│   │   ├── models/             # DTO：序列化模型（代码生成）
│   │   └── views/              # 视图实体（代码生成）
│   ├── infrastructure/
│   │   ├── AdminDbContext.cj   # 数据库上下文
│   │   ├── repositories/       # 仓储层
│   │   ├── MapperUtilities.cj  # 对象映射
│   │   ├── UserAccessor.cj     # 当前用户访问器
│   │   └── middlewares/        # 中间件
│   └── abstractions/           # 抽象基类：Entity、QueryModel、PageResult
└── sql/                        # 数据库初始化脚本
```

## 开发与部署

先用docker进行环境部署，开发时用arm的cangjie包，编译快，适合经常编译。发布时再将源码用x86_64cangjie包重新打包编译，在服务器运行。

## 当前进度
2026.10.12
- 跑通 Spire框架的最小 Host 系统
2026.10.14
- 命令行版 AI 助手：接入 Dify 智能体（streaming/SSE 流式对话，多轮记忆 conversation_id）
- 密钥读环境变量 DIFY_API_KEY；接口地址默认 Dify 云端，可用 DIFY_API_BASE 覆盖
- 菜单循环接入 EOF 处理，管道输入结束不再死循环刷屏
- macOS 本机运行用 `cjpm run`（stdx/runtime 的动态库路径 cjpm 自己会补，openssl 那条在 ~/.zshrc 里）
- 真机联调通过：TLS 客户端必须显式设 `tls.serverName`（仓颉默认不发 SNI，会被网关拒握手）；已实测多轮记忆生效
- DIFY_API_KEY 已在 ~/.zshrc 里全局导出，本机不需要每次手动 export
2026.10.15
- main.cj 清空重写，只留最小 Spire Host（造 builder → 注册服务 → build → 登记路由 → app.run）
- 实测通过：`docker compose up -d dev` 后 `curl http://localhost:8080/hello` 返回 200「changxi 后端已就绪」
- 踩坑①`app.useRouting()` 不能手写：WebHost 启动时自己会挂（dataSources 非空时自动 useRouting+useEndpoints）
- 踩坑②docker-compose 是「宿主机 8080 → 容器 5000」，app.run 必须绑容器内的 5000
2026.10.16
- 重写 docker-compose.yml && dockerfile
- 修改数据库配置，库里目前没有表
- docker 跑通最小 Host
- 认证模块完成（5 个接口），全部实测通过：
  - 响应信封：`src/api_response.cj`，中间件兜住所有 404/异常，任何路径都是 `{code,message,data}`
  - 数据访问：`src/database.cj` + `src/repositories.cj`（SQL 全在这一个文件里）
  - 密码哈希：`src/password.cj`（sha256 + 每用户随机盐 + 12000 轮，约 7ms/次）
  - JWT：`src/jwt.cj`（自己实现 HS256，未用 Spire 的 JwtSecurityTokenHandler）
  - 接口：`src/auth_controller.cj`（send-code / register / login / logout / account-delete）
  - 配置：`appsettings.json` + 环境变量 `cangjie_Database__*`；密钥不硬编码
- 实测：注册→登录→登出→旧令牌失效→注销→换手机号重新注册，全链路通过
- 踩坑①`phone` 列宽必须是 64 而不是 11：注销要把手机号改写成 `del_{id}_{原号}` 释放唯一键，11 位放不下会报 `Data too long`，注销接口直接 500
- 踩坑②`src/` 下原有的命令行版文件（ai/quiz/storage/auth.cj）里有 `User` 类和 `hashPassword`，与新的 HTTP 代码撞名，已移到仓库根目录 `cli/`（git mv 保留历史，不影响编译）
- 踩坑③容器里 `println` 是块缓冲的，要实时看的日志必须用 `src/logging.cj` 的 `serverLog()`（带 flush）——验证码打印就是靠它
- 待办：上线前删掉 `/api/v1/dev/boom` 这个故意抛异常的测试接口