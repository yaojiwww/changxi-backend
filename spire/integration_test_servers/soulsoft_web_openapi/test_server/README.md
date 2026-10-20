# Test Server - Spire OpenAPI 测试项目

## 项目结构

```
soulsoft_web_openapi/test_server/
├── src/                           # 源代码
│   └── main.cj                   # 主程序入口
├── wwwroot/                       # 静态资源
│   └── openapi/                  # Swagger UI 资源
├── tests/                         # 测试代码
│   ├── unit/                     # 单元测试（建议）
│   └── integration/              # 集成测试（建议）
├── docs/                          # 文档
│   ├── 测试对比指南.md
│   └── ...
├── examples/                      # 示例文件
│   └── 手动编写的v1.json
├── cjpm.toml                      # 项目配置
└── README.md                      # 本文件
```

## Quick Start

### 1. Start Server

```bash
cd integration_test_servers/soulsoft_web_openapi/test_server
export SPIRE_PATH=/workspace/spire/
cjpm run
```

### 2. Access Swagger UI

```
http://127.0.0.1:15120/openapi
```

### 3. View OpenAPI Specification

```
http://127.0.0.1:15120/openapi/v1.json
```

### 4. Run Validation Tests

```bash
cd test
node validate.js
```

## Test Endpoints

### User Management

- **GET /api/users** - Get user list
- **GET /api/users/{id}** - Get user by ID
- **POST /api/users** - Create new user

### Authentication

- **GET /connect/token** - Create token

## Automated Testing

The `test/` directory contains automated validation tools:

```bash
cd test
node validate.js
```

This will:
- Download the auto-generated OpenAPI spec
- Validate both auto-generated and manual specs
- Compare differences
- Report errors and warnings

See [test/README.md](test/README.md) for details.

## Documentation

- [测试对比指南](docs/测试对比指南.md) - Comparison guide
- [OpenAPI中间件测试指南](docs/OpenAPI中间件测试指南.md) - Testing guide
- [test/README.md](test/README.md) - Validation tool documentation
