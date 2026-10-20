# soulsoft_web_cors/test_server — CORS 集成测试服务器

> 仓颉语言实现的 HTTP 测试服务器，验证 `soulsoft.web.cors` 库的核心行为，
> 供 Python 客户端（`tests/`）发送真实 HTTP 请求进行断言验证。

---

## 目录结构

```
soulsoft_web_cors/test_server/
├── src/
│   ├── main.cj          # 入口：注册 CORS 策略、挂载中间件、监听 :5000
│   └── CorsRoutes.cj    # 所有测试路由注册
├── tests/
│   ├── conftest.py                  # pytest 公共配置（服务器就绪检查、请求封装）
│   ├── test_require_cors.py         # requireCors() 三种重载行为
│   ├── test_cors_policy_builder.py  # CorsPolicyBuilder 各配置方法
│   ├── test_disable_cors.py         # DisableCors / IDisableCors 元数据行为
│   └── test_edge_cases.py           # 边界场景：非法策略异常 + Vary 系统性覆盖
└── cjpm.toml            # 仓颉项目配置
```

---

## 快速开始

### 前置条件

| 工具 | 版本要求 |
|------|---------|
| 仓颉编译器 (`cjc`) | ≥ 1.1.0 |
| `cjpm` | 随编译器附带 |
| Python | ≥ 3.8 |
| pip | 任意版本 |

### 第一步：构建并启动测试服务器

```bash
cd integration_test_servers/soulsoft_web_cors/test_server
cjpm run          # 默认监听 http://0.0.0.0:5000
```

验证服务器就绪：

```bash
curl http://localhost:5000/health
# 输出: ok
```

### 第二步：运行 Python 测试

```bash
cd integration_test_servers/soulsoft_web_cors/test_server/tests
pip install -r requirements.txt   # 安装 requests、pytest

# 运行全部测试
pytest -v

# 只运行某一个文件
pytest -v test_require_cors.py
pytest -v test_cors_policy_builder.py

# 只运行某一个测试类
pytest -v test_cors_policy_builder.py::TestAllowCredentials
```

如果服务器不在 `localhost:5000`：

```bash
TEST_SERVER_URL=http://192.168.1.10:5000 pytest -v
```

---

## 已注册策略一览

`main.cj` 通过 `addCors` 注册了以下命名策略，供各路由 `requireCors` 引用：

| 策略名 | 允许来源 | 方法 | 请求头 | 特殊设置 |
|--------|---------|------|--------|---------|
| 默认策略 | `https://allowed.com` | 任意 | 任意 | — |
| `creds` | `https://creds.com` | 任意 | 任意 | `allowCredentials()` |
| `specific-hdrs` | `https://allowed.com` | GET, POST | X-Custom-Header, Content-Type | — |
| `expose` | `https://allowed.com` | 任意 | 任意 | `withExposedHeaders([X-Total-Count, X-Page])` |
| `maxage` | `https://allowed.com` | 任意 | 任意 | `setPreflightMaxAge(600s)` |
| `any-origin` | `*` | 任意 | 任意 | — |
| `get-only` | `https://allowed.com` | GET | 任意 | — |
| `wildcard-sub` | `https://*.example.com` | 任意 | 任意 | `setIsOriginAllowedToAllowWildcardSubdomains()` |
| `multi-origin` | origin1.com, origin2.com | 任意 | 任意 | — |
| `normalized` | http://example.com:80, https://secure.com:443 | 任意 | 任意 | 端口规范化验证 |
| `custom-fn` | `*.trusted.io`（自定义函数） | 任意 | 任意 | `setIsOriginAllowed` |

---

## 路由一览

| 路径 | 策略 | 说明 |
|------|------|------|
| `/cors/require/default` | 默认策略 | `requireCors()` 无参重载 |
| `/cors/require/named` | `creds` | `requireCors(policyName)` 命名重载 |
| `/cors/require/inline` | 内联（inline.com） | `requireCors { builder => ... }` 内联重载 |
| `/cors/origins/single` | 默认策略 | 单一来源 |
| `/cors/origins/multi` | `multi-origin` | 多来源 |
| `/cors/origins/normalized` | `normalized` | 默认端口规范化 |
| `/cors/origins/any` | `any-origin` | 任意来源（`*`） |
| `/cors/origins/custom-fn` | `custom-fn` | 自定义来源判断函数 |
| `/cors/origins/wildcard-sub` | `wildcard-sub` | 通配子域名 |
| `/cors/headers/specific` | `specific-hdrs` | 特定请求头白名单 |
| `/cors/headers/any` | 默认策略 | 任意请求头反射 |
| `/cors/methods/specific` | `get-only` | 特定方法白名单 |
| `/cors/methods/any` | 默认策略 | 任意方法反射 |
| `/cors/creds/enabled` | `creds` | `allowCredentials()` |
| `/cors/creds/disabled` | 默认策略 | 无凭证（默认行为） |
| `/cors/maxage/set` | `maxage` | `setPreflightMaxAge(600s)` |
| `/cors/expose/set` | `expose` | `withExposedHeaders` |
| `/cors/disable/no-policy` | 无 | 无 `requireCors`，走中间件默认策略 |

---

## 测试覆盖说明

### `test_require_cors.py` — requireCors 三种重载

| 测试类 | 验证点 |
|--------|--------|
| `TestRequireCorsNoArg` | 无参重载行为：允许/拒绝来源、OPTIONS 无 Origin → 405、allowAnyMethod/Header 反射 |
| `TestRequireCorsNamed` | 命名策略独立于默认策略，creds.com 与 allowed.com 互不干扰，ACAC 头 |
| `TestRequireCorsInline` | 内联策略与命名策略完全隔离，allowAnyMethod 反射 DELETE |

### `test_cors_policy_builder.py` — CorsPolicyBuilder 方法

| 测试类 | 覆盖方法 |
|--------|---------|
| `TestWithOriginsSingle` | `withOrigins`（单）、`Vary: Origin` |
| `TestWithOriginsMulti` | `withOrigins`（多）、`Vary: Origin` |
| `TestNormalizedOrigin` | `getNormalizedOrigin`（http:80 / https:443 去端口） |
| `TestAllowAnyOrigin` | `allowAnyOrigin`，ACAO = `*` |
| `TestSetIsOriginAllowed` | `setIsOriginAllowed`，自定义函数 + 边界（apex 域名不匹配） |
| `TestWildcardSubdomains` | `setIsOriginAllowedToAllowWildcardSubdomains`，方案/端口不匹配边界 |
| `TestWithHeaders` | `withHeaders`，ACAH 固定为策略列表；不反射非白名单头 |
| `TestAllowAnyHeader` | `allowAnyHeader`，ACAH 反射请求头；无 ACR-Headers 时 ACAH 为空 |
| `TestWithMethods` | `withMethods`，ACAM 固定为策略方法；不反射请求方法 |
| `TestAllowAnyMethod` | `allowAnyMethod`，ACAM 反射 GET/DELETE/PATCH；实际请求无 ACAM |
| `TestAllowCredentials` | `allowCredentials` + `disallowCredentials`（默认），ACAC 有/无 |
| `TestSetPreflightMaxAge` | `setPreflightMaxAge`，ACMA = 600；仅预检有此头 |
| `TestWithExposedHeaders` | `withExposedHeaders`，ACEH 仅存在于实际响应，预检无此头 |
| `TestNoRequireCors` | 无 `requireCors` 端点走全局默认策略 |

---

## 已知行为说明

| 场景 | 期望 | 说明 |
|------|------|------|
| OPTIONS + Origin + ACR-Method | 204 | CORS 中间件拦截预检，永远返回 204 |
| OPTIONS + Origin（无 ACR-Method） | 405 | 非预检，路由层决定 |
| OPTIONS 无 Origin | 405 | CORS 中间件不处理，路由层决定 |
| 普通请求 + 允许来源 | 200 + ACAO | CORS 中间件追加响应头 |
| 普通请求 + 拒绝来源 | 200（无 ACAO） | 路由命中，但无 CORS 头（浏览器侧被拒） |
| `allowAnyOrigin` 响应 | ACAO = `*` | 不随请求来源变化 |
| `allowCredentials` + 匹配来源 | ACAC: true | 预检和实际响应均含此头 |
| 默认不含 ACAC | 无 ACAC | `disallowCredentials` 是默认状态 |
| `Vary: Origin` | 单一/多来源策略中存在 | 保证不同来源的缓存区分正确性 |

---

## 覆盖缺口

以下场景在当前测试中**未覆盖**，记录于此供后续补充：

| 缺口 | 说明 |
|------|------|
| `DisableCors` / `IDisableCors` | 无显式通过 `DisableCors` 元数据禁用 CORS 的端点及对应测试 |
| `allowAnyOrigin + allowCredentials` 异常 | `build()` 应抛 `UnsupportedException`，但无通过 HTTP 触发并验证 5xx 的测试 |
| `useCors(policyName)` 中间件重载 | 仅使用无参 `useCors()`，未测试在中间件层指定命名策略 |
| `disallowCredentials()` 显式调用 | 当前通过默认策略（不含凭证）间接验证，未测试显式调用 `disallowCredentials()` |
| `Vary: Origin` 系统覆盖 | 仅在 `TestWithOriginsSingle` / `TestWithOriginsMulti` 中验证，多来源策略等场景未完整断言 |
