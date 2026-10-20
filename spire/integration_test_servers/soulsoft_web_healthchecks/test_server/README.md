# HealthChecks Test Server

`soulsoft_web_healthchecks` 的集成测试服务端，配套 Python pytest 测试套件。

## 启动服务器

```bash
cd integration_test_servers/soulsoft_web_healthchecks/test_server
cjpm run
# 监听 http://0.0.0.0:5000
```

## 运行测试

```bash
cd integration_test_servers/soulsoft_web_healthchecks/test_server/tests
pytest -v
```

> 需先启动服务器，测试会自动轮询 `/healthz/only-healthy` 等待就绪。

## 注册的健康检查

| 名称 | Tags | 状态 |
|------|------|------|
| `healthy` | `[]` | Healthy |
| `unhealthy` | `["critical"]` | Unhealthy |
| `degraded` | `["slow"]` | Degraded |

## 端点说明

### useHealthChecks（中间件）

| 路径 | predicate | 预期状态码 |
|------|-----------|-----------|
| `/healthz` | 全部检查 | 503 |
| `/healthz/only-healthy` | name == "healthy" | 200 |
| `/healthz/only-unhealthy` | name == "unhealthy" | 503 |
| `/healthz/only-degraded` | name == "degraded" | 200 |
| `/healthz/cache` | name == "healthy"，allowCachingResponses=true | 200 |
| `/healthz/tag/critical` | tag == "critical" | 503 |
| `/healthz/tag/slow` | tag == "slow" | 200 |

### mapHealthChecks（端点路由）

| 路径 | predicate | 预期状态码 |
|------|-----------|-----------|
| `/map/healthz` | 全部检查 | 503 |
| `/map/healthz/only-healthy` | name == "healthy" | 200 |

## 测试覆盖

| 场景 | 用例数 |
|------|--------|
| 状态码映射（200 / 503） | 4 |
| 默认响应体（状态名文本） | 3 |
| Content-Type: text/plain | 2 |
| 防缓存响应头（默认） | 4 |
| allowCachingResponses=true | 3 |
| predicate 名称过滤 | 3 |
| predicate tag 过滤 | 2 |
| 路径精确匹配（不互相干扰） | 2 |
| 尾部斜杠容忍 | 3 |
| mapHealthChecks 端点路由 | 4 |
| **合计** | **30** |
