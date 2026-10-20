# soulsoft_web_routing/test_server — 路由集成测试服务器

> 仓颉语言实现的 HTTP 测试服务器，覆盖 `TEST_PLAN.md` 中 **全部 264 条**路由测试用例（P0/P1/P2），
> 供 Python 客户端（`tests/`）发送 HTTP 请求进行断言验证。

---

## 目录结构

```
soulsoft_web_routing/test_server/
├── src/
│   ├── main.cj                # 入口：注册所有路由，监听 :5000
│   ├── JsonHelper.cj          # 公共工具：rv() / buildJson() / writeJson()
│   ├── MetaRoutes.cj          # 元数据内省：/meta/parse、/meta/tokenize、/meta/dict
│   ├── Ch01PatternRoutes.cj   # 第一章 路由模式解析          [P1] TC1-47
│   ├── Ch04DfaRoutes.cj       # 第四章 DFA 匹配器核心        [P0] TC76-127
│   ├── Ch05ComplexSegRoutes.cj# 第五章 复合段匹配            [P1] TC128-145
│   ├── Ch06MethodRoutes.cj    # 第六章 HTTP 方法匹配         [P0] TC146-173
│   ├── Ch07SelectorRoutes.cj  # 第七章 端点选择与歧义处理    [P0] TC174-187
│   ├── Ch08DfaBuilderRoutes.cj# 第八章 DFA 构建行为          [P2] TC188-195
│   ├── Ch10ConstraintRoutes.cj# 第十章 约束类边界            [P1] TC205-233
│   ├── Ch11Ch12Routes.cj      # 第十一/十二章 集成+对齐      [P1/P0] TC234-260
│   └── Ch13Ch14Routes.cj      # 第十三/十四章 优化+Outbound  [P2] TC261-264
├── tests/
│   ├── conftest.py            # pytest 公共配置（服务器就绪检查、请求封装）
│   ├── pytest.ini             # pytest 配置
│   ├── requirements.txt       # Python 依赖
│   ├── test_ch01_patterns.py  # TC1-47    路由模式解析
│   ├── test_ch02_precedence.py# TC48-63   路由优先级
│   ├── test_ch03_tokenizer.py # TC64-75   路径分词
│   ├── test_ch04_dfa.py       # TC76-127  DFA 匹配器
│   ├── test_ch05_complex_seg.py # TC128-145 复合段
│   ├── test_ch06_methods.py   # TC146-173 HTTP 方法
│   ├── test_ch07_selector.py  # TC174-187 端点选择
│   ├── test_ch08_dfa_builder.py # TC188-195 DFA 构建行为
│   ├── test_ch09_dict.py      # TC196-204 RouteValueDictionary
│   ├── test_ch10_constraints.py # TC205-233 约束边界
│   ├── test_ch11_integration.py # TC234-249 端到端集成
│   ├── test_ch12_alignment.py # TC250-260 ASP.NET Core 对齐
│   └── test_ch13_ch14.py      # TC261-264 约束优化+OutboundPrecedence
├── TEST_PLAN.md               # 完整测试用例分支地图（264 条）
└── cjpm.toml                  # 仓颉项目配置
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

确保环境变量已配置：

```bash
# 仓颉扩展标准库路径
export CANGJIE_STDX_PATH=/path/to/cangjie/stdx
# Spire 依赖根目录
export SPIRE_PATH=/path/to/spire/
```

### 第一步：构建并启动测试服务器

```bash
cd integration_test_servers/soulsoft_web_routing/test_server
cjpm run          # 默认监听 http://0.0.0.0:5000
```

成功启动后，控制台输出类似：

```
Application started. Press Ctrl+C to shut down.
Listening on http://0.0.0.0:5000
```

验证服务器就绪：

```bash
curl http://127.0.0.1:5000/health
# 输出: ok
```

### 第二步：运行 Python 测试

```bash
cd integration_test_servers/soulsoft_web_routing/test_server/tests
pip install -r requirements.txt

# 运行全部测试
pytest -v

# 只运行 P0 核心测试
pytest -v test_ch04_dfa.py test_ch06_methods.py test_ch07_selector.py test_ch12_alignment.py

# 运行单个测试类
pytest -v test_ch04_dfa.py::TestLiteralMatching
```

如果服务器不在 `127.0.0.1:5000`，通过环境变量覆盖：

```bash
TEST_SERVER_URL=http://192.168.1.10:5000 pytest -v
```

---

## 路由前缀约定

所有测试路由按章节前缀隔离，互不干扰：

| 前缀 | 章节 | 优先级 | 说明 |
|------|------|--------|------|
| `/meta/...` | 内省端点 | - | 供 Ch1/Ch2/Ch3/Ch9 测试使用 |
| `/ch01/...` | 第一章 | P1 | 路由模式解析：前缀/字面量/参数/约束/复合段/转义 |
| `/ch04/...` | 第四章 | **P0** | DFA 匹配器：字面量/参数/默认值/可选/catch-all/约束 |
| `/ch05/...` | 第五章 | P1 | 复合段：前缀+参数、参数+后缀、分隔符参数 |
| `/ch06/...` | 第六章 | **P0** | HTTP 方法：GET/POST/PUT/PATCH/DELETE/通配/自定义/CORS |
| `/ch07/...` | 第七章 | **P0** | 端点选择：优先级排序、歧义异常、无匹配 |
| `/ch08/...` | 第八章 | P2 | DFA 构建：前缀共享、字面量+参数共存、catch-all 自循环 |
| `/ch10/...` | 第十章 | P1 | 约束边界：int/bool/float/regex 边界值 |
| `/ch11/...` | 第十一章 | P1 | 端到端管道集成 |
| `/ch12/...` | 第十二章 | **P0** | ASP.NET Core 路由语义对齐验证 |
| `/ch13/...` | 第十三章 | P2 | IParameterLiteralNodeMatchingPolicy 约束优化 |
| `/ch14/...` | 第十四章 | P2 | OutboundPrecedence 占位路由 |

---

## 响应格式

所有路由返回 `Content-Type: application/json`，统一格式：

```json
{
  "matched": true,
  "id": "42",
  "ctrl": "Home",
  "action": "Index"
}
```

- 字段仅包含该路由关心的路由参数
- 可选参数不提供时值为 `null`
- `matched` 字段恒为 `true`（无匹配由 HTTP 状态码 404/405/5xx 反映）

---

## 测试优先级

```
P0（核心，必须全部通过）
├── test_ch04_dfa.py        DFA 字面量/参数/约束/catch-all
├── test_ch06_methods.py    HTTP 方法精确匹配与通配
├── test_ch07_selector.py   端点选择优先级与歧义异常
└── test_ch12_alignment.py  ASP.NET Core 语义对齐

P1（主流程，应全部通过）
├── test_ch01_patterns.py   路由模式解析（含异常路径）
├── test_ch02_precedence.py 路由优先级计算
├── test_ch03_tokenizer.py  路径分词边界
├── test_ch05_complex_seg.py 复合段匹配算法
├── test_ch10_constraints.py 约束类边界值
└── test_ch11_integration.py 端到端管道

P2（后续补充）
├── test_ch08_dfa_builder.py DFA 构建行为（行为验证）
├── test_ch09_dict.py       RouteValueDictionary 操作
└── test_ch13_ch14.py       约束优化 + OutboundPrecedence
```

---

## 已知行为说明

| 场景 | 期望状态码 | 说明 |
|------|-----------|------|
| 路径无匹配 | 404 | 无任何候选路由 |
| 方法不匹配 | 405 | 路径存在但方法未注册 |
| 约束失败 | 404 | 所有候选约束均失败 |
| 歧义匹配 | 5xx | `AmbiguousMatchException`，见 TC179-181 |
| 尾随斜杠 | 404 | `/users/` 不匹配 `/users`（TC82/TC260 验证） |
| 大小写路径 | 200 | 字面量不区分大小写（TC77/TC250） |
| 参数值大小写 | 保留原值 | 参数从原始路径提取（TC83/TC251） |
