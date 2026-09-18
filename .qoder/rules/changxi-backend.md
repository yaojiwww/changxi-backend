---
trigger: always_on
---

# 畅溪后端（changxi-backend）项目规则

## 项目概览
- 鸿蒙 APP 的后端服务，使用仓颉（Cangjie）语言 + 天擎（Spire）Web 框架开发。
- 接口契约以 `docx/api-spec.md` 为准，实现任何接口前先查阅该文档。

## 构建与运行
- 首次编译：`cjpm build`；启动服务：`cjpm run`；无热重载，改动后需重新运行。
- 依赖通过 `cjpm.toml` 本地路径引入天擎模块，必须配置 `SPIRE_PATH` 环境变量（末尾保留分隔符）。

## 代码约定
- 统一响应格式：`{"code":0,"message":"ok","data":{...}}`，一律通过 `web_util.cj` 的 `writeOk` / `writeError` 输出。
- 密钥与连接信息只从环境变量读取（`config.cj` 的 `mustGetEnv`），绝不硬编码、绝不给默认值。
- 请求字段解析使用 `jsonField` / `queryInt` / `queryText` / `routeInt`，取不到给安全兜底值，不抛异常。
