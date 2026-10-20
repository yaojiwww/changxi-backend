<div align="center">

# Soulsoft 天擎

**为仓颉语言而生的现代化 Web 框架**

天擎由 Soulsoft 与仓颉官方团队联合打造，汲取 ASP.NET Core 的成熟设计理念，\
专为仓颉生态提供生产级的 Web 开发底座——轻量、高性能，且随业务自由伸缩。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-green.svg)](https://gitcode.com/soulsoft)
[![Platform](https://img.shields.io/badge/Platform-HarmonyOS-red.svg)](https://gitcode.com/soulsoft)

</div>

---

## 核心特性

### 为什么选择天擎？

天擎采用**经过大规模生产验证的 ASP.NET Core 设计理念**，**API 与其高度对齐**——你无需担心接口的频繁变更或不成熟的设计给业务带来改造成本。我们提供**完善的文档、全面的单元测试与分支覆盖**，以**完全开放的源码**为稳定性背书。天擎**持续关注 ASP.NET Core 与仓颉语言的演进**，不断融合两者的创新成果。我们高度重视**开发者体验**与开发者的真实反馈，致力于以**优雅的设计**、**开箱即用的体验**和**灵活的配置方式**，让每一位开发者都能愉快地构建可靠的生产级应用。

### 特性一览

| 特性 | 描述 |
|------|------|
| 🏛️ **成熟的设计** | 采用经过大规模生产验证的ASP.NET Core 的设计理念 |
| 🪶 **轻量化架构** | 零侵入式设计，核心极简，行为完全可配置 |
| 🧩 **模块化扩展** | 所有能力均以独立模块提供，按需引入，无多余依赖 |
| 🔐 **身份认证** | 开箱即用的认证授权体系，支持 JWT、Cookie 与 OIDC |
| ⚡ **快速接入** | 基于 GitCode 包管理，几行配置即可引入任意模块 |
| ☁️ **微服务** | 持续演进的微服务组件生态，面向云原生场景设计 |
| 🤖 **AI 友好** | 积极探索框架与智能化工具链的深度融合 |

---

## 快速开始

- 📖 [项目文档](https://docs.cangjie-spire.com) — 完整 API 参考与使用指南
- 📝 [开源博客](https://gitcode.com/soulsoft/blog) — 实践案例与版本动态
- 🤝 [社区案例](https://gitcode.com/soulsoft/examples) — 共享使用案例，助力 AI 学习与知识传播

---

## 模块列表

天擎遵循**按需引入**的设计理念——每个模块职责单一、边界清晰，可自由组合以适配从轻量服务到企业级应用的各类场景。

### 🌐 Web 核心

> 框架运行的最小必要集合，所有应用均需引入。

| 模块名称 | 必要性 | 功能描述 |
|----------|:------:|----------|
| `soulsoft_web_http` | **必需** | HTTP 抽象层，定义请求与响应的核心契约 |
| `soulsoft_web_routing` | **必需** | 高性能路由引擎，支持灵活的终结点映射 |
| `soulsoft_web_hosting` | **必需** | Web 主机生命周期管理，驱动应用启停 |

### 🔧 Web 中间件

> 以管道方式挂载，可自由组合以扩展请求处理链路。

| 模块名称 | 必要性 | 功能描述 |
|----------|:------:|----------|
| `soulsoft_web_mvc` | 可选 | MVC 模式支持，提供控制器与视图抽象 |
| `soulsoft_web_cors` | 可选 | 跨域资源共享策略配置 |
| `soulsoft_web_openapi` | 可选 | OpenAPI / Swagger 文档生成，自动导出接口规范 |
| `soulsoft_web_staticfiles` | 可选 | 静态资源托管与缓存控制 |
| `soulsoft_web_healthchecks` | 可选 | 应用健康探针，对接 K8s 等编排平台 |

### 🔒 身份认证

> 覆盖从基础认证到企业级单点登录的完整方案。

| 模块名称 | 必要性 | 功能描述 |
|----------|:------:|----------|
| `soulsoft_web_authorization` | 可选 | 基于策略的细粒度授权中间件 |
| `soulsoft_web_authentication` | 可选 | 认证框架基础抽象层 |
| `soulsoft_web_authentication_cookies` | 可选 | Cookie 会话认证方案 |
| `soulsoft_web_authentication_jwtbearer` | 可选 | JWT Bearer 令牌认证方案 |

### 🏗️ 基础设施

> 为应用提供配置、注入、缓存等横切关注点的统一支撑。

| 模块名称 | 必要性 | 功能描述 |
|----------|:------:|----------|
| `soulsoft_extensions_options` | **必需** | 强类型配置绑定与选项模式 |
| `soulsoft_extensions_logging` | 可选 | 结构化日志抽象，可对接多种日志后端 |
| `soulsoft_extensions_hosting` | 可选 | 通用主机，承载后台服务与定时任务 |
| `soulsoft_extensions_caching` | 可选 | 分布式内存缓存抽象 |
| `soulsoft_extensions_injection` | **必需** | 依赖注入容器，支持生命周期管理 |
| `soulsoft_extensions_protection` | 可选 | 企业级数据保护与密钥管理 |
| `soulsoft_extensions_healthchecks` | 可选 | 健康检查注册与聚合服务 |
| `soulsoft_extensions_configuration` | 可选 | 多源配置聚合，统一读取环境变量与文件配置 |

### 🛡️ 认证设施

> 身份体系的核心基础件，支撑从声明到协议的完整认证链路。

| 模块名称 | 必要性 | 功能描述 |
|----------|:------:|----------|
| `soulsoft_identity_claims` | 可选 | 基于声明的身份模型 |
| `soulsoft_identity_server` | 可选 | 自托管身份认证中心，支持 OIDC 与 OAuth 2.0 |
| `soulsoft_identity_tokens_jwt` | 可选 | JWT 令牌的签发与验证 |
| `soulsoft_identity_protocols_oidc` | 可选 | OpenID Connect 协议完整实现 |

### 🚀 扩展能力

> 覆盖序列化、ORM、消息调度等常见工程诉求，开箱可用。

| 模块名称 | 必要性 | 功能描述 |
|----------|:------:|----------|
| `sqlsharp` | 可选 | 轻量级 ORM，兼顾灵活性与类型安全 |
| `sqlsharp_util` | 可选 | 数据库实体模板生成工具 |
| `soulsoft_mediator` | 可选 | 中介者模式实现，集成命令、事件、AOP 与 IoC |
| `soulsoft_strategy` | 可选 | 弹性策略库，内置超时、重试、熔断等机制 |
| `soulsoft_scheduler` | 可选 | 基于 Cron 表达式的分布式作业调度 |
| `soulsoft_serialization` | 可选 | 字段驱动的高性能对象序列化工具 |

---

## 发布历史

| 版本 | 状态 | 发布日期 |
|------|:----:|----------|
| `0.9.0` | ✅ 预览版 | — |
| `1.0.0` | ✅ 正式版 | 2025 年 08 月 04 日 |
| `1.1.0` | ✅ 公测版本 | 2026 年 04 月 01 日 |

---

## 共享使用案例，让 AI 更懂天擎

我们正在建设一个**社区驱动的案例知识库** — [soulsoft/examples](https://gitcode.com/soulsoft/examples)。

每一份真实案例都将成为 AI 工具的学习素材——无论是代码补全、文档问答，还是智能脚手架，\
**你提交的案例，将直接提升整个仓颉生态的 AI 辅助质量**。

### 可以贡献什么？

- 基于天擎模块的完整示例项目
- 某个功能点的最小复现代码（如 JWT 认证、Swagger 集成）
- 真实业务场景的解决方案片段
- 踩坑记录与最佳实践总结

### 如何提交？

1. Fork [soulsoft/examples](https://gitcode.com/soulsoft/examples) 仓库
2. 在对应模块目录下新建你的案例文件夹
3. 附上简短的 `README.md` 描述使用场景
4. 发起 Pull Request，我们会尽快审阅合并

> 每一行分享的代码，都在帮助下一位开发者少走弯路。  
> **欢迎你成为知识共享的一份子。**

---

## 参与贡献

仓颉生态正处于蓬勃发展的早期阶段。天擎致力于联合更多开发者，共同完善标准化组件库、\
构建统一的技术生态，让每一个仓颉应用都能站在坚实的底座之上。

无论是贡献代码、参与设计讨论，还是分享真实的使用场景，我们都非常欢迎你的加入。

| 渠道 | 联系方式 |
|------|----------|
| 💬 技术交流 | QQ 群：`307564339` |
| 📞 商务合作 | 微信（同号）：`18058729927` |

---

## 许可证

本项目以 [MIT License](LICENSE) 开源，你可以自由使用、修改与分发。
