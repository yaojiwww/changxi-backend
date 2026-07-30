# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此仓库中工作时提供指导。

## 项目概述

NestJS 后端项目 (Backend_b)。数据库设计位于上级目录 `./MySQL.md`。

## 常用命令

```bash
npm run start:dev      # 开发模式，热重载
npm run start:debug    # 调试模式
npm run start:prod     # 生产环境（需先 npm run build）
npm run build          # 编译 TypeScript 到 dist/
npm run lint           # ESLint 检查
npm run format         # Prettier 格式化
npm run test           # 单元测试
npm run test:e2e       # 端到端测试
```

## 架构

NestJS 使用模块作为基本构建单元。每个功能模块包含：
- `*.controller.ts` - 处理 HTTP 请求/响应
- `*.service.ts` - 业务逻辑
- `*.entity.ts` - 数据库实体（使用 TypeORM 时）
- `*.module.ts` - 模块注册

常用装饰器：
- `@Controller()`, `@Get()`, `@Post()` 等用于路由
- `@Injectable()` 用于服务
- `@Entity()` 用于 TypeORM 实体
- `@Module()` 用于组织导入/控制器/提供者

入口模块：`src/app.module.ts`
入口文件：`src/main.ts`

## 注意事项

- 计划连接 MySQL 数据库（设计在 `../MySQL.md`）
- 配置应使用环境变量或配置模块
