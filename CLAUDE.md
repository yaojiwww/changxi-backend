# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此代码库中工作时提供指导。
claude助手全程指导我边学边做，不得一下把全部代码写出来，每次只说一点，一点一点来。

## 项目概述

保育员考试刷题app，内置AI解析和AI助手。
客户端：采用 HarmonyOS NEXT (API 24) 开发，采用 MVVM 架构模式和 V2 状态管理。
服务端：后端使用仓颉（Cangjie）+ Spire 框架，数据库使用 mariadb。

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