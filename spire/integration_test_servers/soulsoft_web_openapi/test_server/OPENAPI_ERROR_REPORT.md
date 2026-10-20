# OpenAPI 集成测试结果

更新时间：2026-05-18

## 当前状态

- 全量 `tests/` 目录测试：`91 passed, 0 failed`
- 当前未发现仍未修复的 OpenAPI 契约问题

## 本轮已完成的关键整改

- 可选 Query 参数 `?T` 正确生成 `required: false` 和 `nullable: true`
- `BigInt`、`Float16`、`UInt*`、`Decimal` 的 `type/format` 映射收敛到更保守的 OpenAPI 3.0 输出
- GET + Query DTO 正确展开为 `parameters`
- Header 参数正确映射为真实 HTTP Header 名
- `json-dict` 响应 schema 正确保留对象结构

## 代码结构调整

- `OpenApiDocumentService` 仅负责文档编排
- 新增 `OpenApiParameterService`，专门负责参数展开、参数名推导、`required` 规则
- `OpenApiSchemaService` 收敛为单一 schema 生成管线，同时保留 `createSchema(...)` 与 `createInlineSchema(...)` 两个清晰入口
- 类型限定名中的泛型解析统一收口到 `TypeNameParser`

## 回归命令

```powershell
$env:TEST_SERVER_URL='http://127.0.0.1:15120'
python -m pytest -q
```

服务启动方式：

```powershell
cd integration_test_servers/soulsoft_web_openapi/test_server
target\release\bin\main.exe --HTTP_PORTS 15120
```
