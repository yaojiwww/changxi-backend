# soulsoft_web_hosting — 集成测试

本目录是 `soulsoft_web_hosting` 模块的**可执行集成测试项目**，使用 `println` 驱动的自定义断言引擎，通过真实启动 `WebHost` 来验证配置加载优先级和环境检测行为。

---

## 目录结构

```
test/
├── appsettings.json                # 基础配置（Production 环境）
├── appsettings.Development.json    # Development 环境覆盖配置
├── cjpm.toml                       # 项目配置，output-type = executable
├── README.md                       # 本文件
└── src/
    └── main.cj                     # 集成测试入口
```

---

## 配置文件说明

### `appsettings.json`（基础配置，所有环境均加载）

| 键 | 值 | 说明 |
|----|----|------|
| `x_source` | `"json_base"` | 标记当前值来源，用于优先级验证 |
| `x_version` | `"1.0"` | 仅在 base 文件存在，验证未被覆盖时仍可读 |
| `x_shared` | `"from_base"` | Development 文件未覆盖此键，验证继承行为 |
| `app:name` | `"integration-test"` | 嵌套配置，`:` 为层级分隔符 |
| `app:mode` | `"base"` | Development 文件会覆盖此键 |
| `logging:logLevel:default` | `"Info"` | 全局日志级别（Production） |
| `logging:logLevel:soulsoft` | `"Warn"` | soulsoft 前缀日志级别（Production） |
| `logging:logLevel:Microsoft` | `"Error"` | Microsoft 前缀日志级别（Production） |
| `logging:console:logLevel:default` | `"Info"` | console 提供者独立规则 |

### `appsettings.Development.json`（Development 环境追加，同名键覆盖 base）

| 键 | 值 | 说明 |
|----|----|------|
| `x_source` | `"json_dev"` | 覆盖 base 的 `x_source` |
| `x_dev_only` | `"dev_value"` | 仅 Development 环境存在 |
| `app:mode` | `"development"` | 覆盖 base 的 `app:mode` |
| `logging:logLevel:default` | `"Debug"` | 开发环境输出更详细的日志 |
| `logging:logLevel:soulsoft` | `"Debug"` | 开发环境 soulsoft 前缀降至 Debug |
| `logging:logLevel:Microsoft` | `"Warn"` | 开发环境 Microsoft 前缀放宽至 Warn |
| `logging:console:logLevel:default` | `"Debug"` | console 提供者也降至 Debug |

---

## 配置加载优先级

`WebHost.createBuilder` 按以下顺序叠加配置源，**后加载的优先级更高**：

```
appsettings.json                     （最低）
     ↓ 被覆盖
appsettings.{Environment}.json
     ↓ 被覆盖
环境变量（cangjie_ 前缀，如 CANGJIE_X_SOURCE）
     ↓ 被覆盖
命令行参数（如 --x_source value）     （最高）
```

> 环境名本身（`environmentName`）也遵循此优先级：
> 默认 `Production` → `CANGJIE_ENVIRONMENT` → `--environment`

---

## 运行测试

### 基础运行（不设置环境变量）

```bash
cd test
cjpm run
```

预期输出：**35 PASSED / 0 FAILED**

### 第 6 节环境变量验证

```bash
cjpm run
```

程序会在运行第 6 节时自行设置并恢复测试环境变量：
- `CANGJIE_X_SOURCE` 覆盖 `appsettings.json` 中的同名键
- `CANGJIE_ENVIRONMENT` 覆盖默认环境名
- 命令行参数优先级仍高于环境变量

---

## 测试节说明

| 节 | 验证内容 | 用例数 |
|----|---------|--------|
| 1 | 默认环境为 Production | 4 |
| 2 | 命令行参数覆盖环境名（Development / Staging / Custom） | 5 |
| 3 | `appsettings.json` 基础配置加载，包含嵌套键 `app:*` | 6 |
| 4 | `appsettings.Development.json` 覆盖同名键，未覆盖键继承 base | 6 |
| 5 | 命令行参数优先级高于配置文件（含部分覆盖场景） | 4 |
| 6 | 环境变量优先级（`cangjie_` 前缀），由测试程序自行设置 env var | 4 |
| 7 | `logging` 配置从 `appsettings.json` 正确读取 | 4 |
| 8 | Development 环境 `logging` 配置被 `appsettings.Development.json` 覆盖 | 4 |
| 9 | 命令行可精确覆盖单条 `logging` 规则 | 2 |
| 10 | 优先级顺序总结（纯输出） | — |

---

## 与单元测试的区别

| 维度 | 单元测试（`src/unittests/`）| 集成测试（本目录）|
|------|-------------------------|--------------------|
| 框架 | `std.unittest` `@Test` / `@TestCase` | `IStartupCheck` + 自定义 runner |
| 运行方式 | `cjpm test` | `cjpm run` |
| 依赖 | Mock 类（`NoopHostLifetime` 等）| 真实 `WebHost` + 真实配置文件 |
| 覆盖重点 | 单个类 / 方法的正确性 | 配置加载链路的端到端行为 |
| HTTP 服务 | 不涉及 | 不涉及（使用 `NoopHostLifetime` 跳过端口监听）|

---

## 依赖说明

`cjpm.toml` 中依赖项与父模块 `soulsoft_web_hosting` 完全一致，额外声明：

```toml
soulsoft_web_hosting = { path = ".." }
```

平台链接选项（OpenSSL FFI、`crypt32` 等）已在 `[target]` 节中配置，与父模块保持同步。
