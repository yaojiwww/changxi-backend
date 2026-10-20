# soulsoft_web_mvc/test_server — 模型绑定集成测试服务器

本目录包含两部分：

- **仓颉 MVC 测试服务器**（`src/`）：监听 `5010` 端口，为 Python 集成测试提供 HTTP 接口
- **Python 集成测试套件**（`tests/`）：使用 pytest 对模型绑定功能进行端到端验证

---

## 快速开始

### 第一步：启动测试服务器

需要先配置 `SPIRE_PATH` 环境变量（指向 spire monorepo 根目录），以及仓颉工具链环境。

```bash
# 在统一测试服务目录下构建并启动
cd integration_test_servers/soulsoft_web_mvc/test_server
cjpm run
```

服务器启动后将监听 `http://0.0.0.0:5010`，可通过健康检查接口验证：

```bash
curl http://localhost:5010/health
```

返回 `200` 即表示服务器就绪。

### 第二步：安装 Python 依赖

```bash
pip install pytest requests
```

### 第三步：运行集成测试

```bash
cd integration_test_servers/soulsoft_web_mvc/test_server/tests
pytest -v
```

---

## 环境变量

| 变量名 | 说明 | 默认值 |
|---|---|---|
| `SPIRE_PATH` | spire 依赖包根路径，供 `cjpm.toml` 解析依赖 | 无（必须设置） |
| `CANGJIE_STDX_PATH` | 仓颉扩展标准库路径 | 无（必须设置） |
| `TEST_SERVER_HOST` | 测试服务器主机地址 | `http://localhost` |

---

## 测试文件说明

| 文件 | 测试内容 |
|---|---|
| `test_primitive_binding.py` | 14 种基础类型绑定（Bool / Int8~Int64 / UInt8~UInt64 / Float16~Float64 / BigInt / Decimal） |
| `test_string_binding.py` | String 类型绑定 |
| `test_array_binding.py` | Array\<T\> 数组类型绑定 |
| `test_complex_binding.py` | 复杂对象绑定（`@FromQuery` 与默认 `FromBody` / JSON） |
| `test_route_binding.py` | `@FromRoute` 路由段绑定，覆盖 16 种叶子类型及 `?T` |
| `test_header_binding.py` | `@FromHeader` 请求头绑定 |
| `test_form_primitive_binding.py` | 表单基础类型绑定 |
| `test_formfile_binding.py` | 表单文件上传绑定 |
| `test_nullable_binding.py` | 可空类型 `?T` 绑定 |
| `test_datetime_binding.py` | DateTime 类型绑定 |
| `conftest.py` | pytest 公共配置：Session 复用、服务器就绪检测、`get`/`post` 快捷函数 |

---

## 测试行为说明

- 服务器未启动时，`conftest.py` 会在 15 秒内轮询 `/health`，超时后**跳过整套测试**（不报错）
- 服务器返回 5xx 时，测试会将响应体作为 `AssertionError` 抛出，便于定位服务端异常
- 可通过 `TEST_SERVER_HOST` 环境变量将测试指向远程服务器：
  ```bash
  TEST_SERVER_HOST=http://192.168.1.100 pytest -v
  ```

---

## 目录结构

```
soulsoft_web_mvc/test_server/
├── src/
│   ├── main.cj                         # 服务器入口，端口 5010
│   └── controllers/
│       ├── HealthController.cj
│       ├── PrimitiveController.cj
│       ├── StringController.cj
│       ├── ArrayController.cj
│       ├── ComplexController.cj
│       ├── RouteController.cj
│       ├── HeaderController.cj
│       ├── FormPrimitiveController.cj
│       ├── FormFileController.cj
│       ├── NullableController.cj
│       └── DateTimeController.cj
├── tests/
│   ├── conftest.py
│   ├── test_primitive_binding.py
│   ├── test_string_binding.py
│   ├── test_array_binding.py
│   ├── test_complex_binding.py
│   ├── test_route_binding.py
│   ├── test_header_binding.py
│   ├── test_form_primitive_binding.py
│   ├── test_formfile_binding.py
│   ├── test_nullable_binding.py
│   └── test_datetime_binding.py
└── cjpm.toml
```
