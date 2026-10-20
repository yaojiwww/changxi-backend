# Integration Test Servers

统一存放各模块的集成测试服务。

目录约定：

```text
integration_test_servers/
  <module>/
    <service>/
```

当前已整理的服务：

```text
integration_test_servers/
  soulsoft_net_http/
    test_server/
  soulsoft_web_authentication_jwtbearer/
    test_server/
  soulsoft_web_authorization/
    test_server/
  soulsoft_web_cors/
    test_server/
  soulsoft_web_healthchecks/
    test_server/
  soulsoft_web_hosting/
    test_server/
  soulsoft_web_mvc/
    test_server/
  soulsoft_web_openapi/
    test_server/
  soulsoft_web_routing/
    test_server/
  soulsoft_web_staticfiles/
    test_server/
```

使用方式：

```bash
# 一键启动全部集成服务
cd integration_test_servers
python start_all_integration_servers.py

# 停止全部集成服务
python stop_all_integration_servers.py

# 只启动某个模块
python start_all_integration_servers.py --module soulsoft_web_cors

# 只停止某个模块
python stop_all_integration_servers.py --module soulsoft_web_cors

# 后台拉起后退出
python start_all_integration_servers.py --detach

# 进入某个模块的某个集成服务目录，单独启动
cd soulsoft_web_mvc/test_server
cjpm run

# 运行 Python 测试
cd tests
pytest -v
```

端口规划：

```text
soulsoft_net_http                      15050-15059
soulsoft_web_authentication_jwtbearer  15060-15069
soulsoft_web_authorization             15070-15079
soulsoft_web_cors                      15080-15089
soulsoft_web_healthchecks              15090-15099
soulsoft_web_hosting                   15100-15109
soulsoft_web_mvc                       15110-15119
soulsoft_web_openapi                   15120-15129
soulsoft_web_routing                   15130-15139
soulsoft_web_staticfiles               15140-15149
```

启动约定：

```bash
# 先设置仓库根目录环境变量，注意末尾保留 /
export SPIRE_PATH=/workspace/spire/

# 单服务模块：默认使用各自端口段的第一个端口
cjpm run

# 单服务模块：覆盖单个监听端口
cjpm run -- --HTTP_PORTS 18080

# 多服务模块：统一使用 portBase + offset
cjpm run -- --portBase 16060
```

说明：

- 先按模块分组，再按服务分组，便于后续一个模块下扩展多个集成服务。
- 每个模块预留 10 个端口，后续新增集成服务时直接在本模块端口段内继续分配。
- `cjpm.toml` 依赖路径通过 `SPIRE_PATH` 解析，值应指向仓库根目录，并保留结尾的 `/`。
- `start_all_integration_servers.py` 会显式传入端口参数，并在 `.runtime/logs/` 下记录每个服务的启动日志。
- `start_all_integration_servers.py` 会在 `.runtime/services.json` 记录运行状态，`stop_all_integration_servers.py` 会据此停止服务。
- 服务内部原有目录结构尽量保持不变，降低迁移成本。
- 模块源码目录下不再保留这些集成服务目录，统一从这里管理。
