# changxi-backend

保育员考试刷题 App 的后端。仓颉 + Spire + MariaDB。

## 本机开发（macOS / arm64）

```bash
cjpm build      # 编译
cjpm run        # 编译并运行
```

需要先在环境里导出 `SPIRE_PATH`（指向本仓库的 `spire/` 目录）和 `CANGJIE_STDX_PATH`。

## 服务器部署（Ubuntu / x86_64）

不依赖 Docker，原生运行：

```
/opt/cangjie          仓颉 SDK（x86_64）
/opt/stdx             仓颉扩展库
mariadb               apt 安装，10.6
```

编译前需要这三个环境变量：

```bash
export SPIRE_PATH=<仓库目录>/spire/
export CANGJIE_STDX_PATH=/opt/stdx/linux_x86_64_cjnative/dynamic/stdx
export LD_LIBRARY_PATH=/opt/cangjie/runtime/lib/linux_x86_64_cjnative:/opt/cangjie/tools/lib:/opt/stdx/linux_x86_64_cjnative/dynamic/stdx:$LD_LIBRARY_PATH
source /opt/cangjie/envsetup.sh
```

数据库配置见 `appsettings.json`，可用环境变量 `cangjie_Database__*` 覆盖。
表结构见 `sql/schema.sql`。
