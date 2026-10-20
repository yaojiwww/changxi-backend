# JWT Bearer 集成测试

## 测试结构

```
tests/
├── conftest.py                 # pytest 公共配置和辅助函数
├── test_basic_jwt.py          # 基础JWT认证测试（端口5001）
├── test_role_authorization.py # 角色授权测试（端口5002）
└── test_error_handling.py     # 错误处理测试（端口5003）
```

## 测试服务器

| 端口 | 服务器 | 功能 |
|------|--------|------|
| 5001 | 基础JWT | 令牌生成、受保护端点、用户信息 |
| 5002 | 角色授权 | AdminOnly/UserOnly 策略 |
| 5003 | 错误处理 | 过期令牌、无效签名、详细验证 |

## 运行测试

### 1. 安装依赖

```bash
pip install pytest requests
```

### 2. 启动测试服务器

```bash
cd integration_test_servers/soulsoft_web_authentication_jwtbearer/test_server
cjpm run
```

### 3. 运行测试

在另一个终端窗口：

```bash
cd integration_test_servers/soulsoft_web_authentication_jwtbearer/test_server/tests

# 运行所有测试
pytest -v

# 运行特定测试文件
pytest -v test_basic_jwt.py
pytest -v test_role_authorization.py
pytest -v test_error_handling.py

# 运行特定测试类
pytest -v test_basic_jwt.py::TestTokenGeneration

# 运行特定测试方法
pytest -v test_basic_jwt.py::TestTokenGeneration::test_token_has_three_parts
```

### 4. 环境变量

```bash
# 自定义服务器地址（默认 http://localhost）
export TEST_SERVER_HOST=http://192.168.1.100
pytest -v
```

## 测试覆盖

### test_basic_jwt.py
- 健康检查端点
- 令牌生成（默认参数、自定义用户名/角色）
- 受保护端点认证（有效/无效令牌）
- 用户信息获取
- 令牌验证诊断

### test_role_authorization.py
- AdminOnly 策略验证
- UserOnly 策略验证
- 跨角色访问控制
- 授权头格式验证

### test_error_handling.py
- 过期令牌生成和验证
- 无效签名令牌测试
- 详细令牌验证端点
- 错误消息格式验证
- 边界情况处理
