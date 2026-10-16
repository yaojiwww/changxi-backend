# cangjie 命令
1. 构建
```cjpm
cjpm build
```
2. 运行
```cjpm
cjpm run
```
# 编译 + 启动服务（前台）
docker compose up

# 只编译
docker compose run --rm dev cjpm build

# 进容器随便玩
docker compose run --rm dev bash

# 停掉
docker compose down

# 检查docker-compose.yml里语法
```
docker compose config
```