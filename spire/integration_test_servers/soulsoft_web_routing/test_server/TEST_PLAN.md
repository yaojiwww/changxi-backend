# 路由集成测试用例分支地图（完整版）

> 生成日期：2026-03-17
> 基于：源码逐行分析 + ASP.NET Core 路由对齐行为
> 覆盖范围：`RoutePatternParser` / `FastPathTokenizer` / `DfaMatcher` /
> `DfaMatcherBuilder` / `DefaultEndpointSelector` / `HttpMethodMatcherPolicy` /
> `RoutePatternMatcher` / `RoutePrecedence` / 各约束类

---

## 优先级说明

| 级别 | 含义 |
|------|------|
| P0 | 核心匹配行为，必须全覆盖 |
| P1 | 主流程与边界条件，应覆盖 |
| P2 | 补充场景与组合行为，建议覆盖 |

---

## 一、路由模式解析 `RoutePatternParser` [P1]

### 1.1 前缀修剪

| # | 输入 | 期望 |
|---|-----|------|
| 1 | `/users` | 保留 `users` |
| 2 | `users`（无斜杠） | 保留 `users`，等价于 `/users` |
| 3 | `~/users` | 移除 `~/`，保留 `users` |
| 4 | `~users`（`~` 后无 `/`） | RoutePatternException |
| 5 | `~/` | 空模式，根路径 |

### 1.2 字面量路由

| # | 输入 | 期望 pathSegments |
|---|-----|-----------------|
| 6 | `/` | 0 段（根路径） |
| 7 | `/users` | 1 个字面量段 `users` |
| 8 | `/api/v1/users` | 3 个字面量段 |
| 9 | `/a/b/c/d/e` | 5 个字面量段 |

### 1.3 参数路由

| # | 输入 | 期望参数特征 |
|---|-----|------------|
| 10 | `/{id}` | name=`id`，非 optional，非 catchAll，无默认值 |
| 11 | `/{ctrl}/{action}` | 2 参数，顺序正确 |
| 12 | `/{id=42}` | name=`id`，default=`"42"` |
| 13 | `/{id?}` | name=`id`，isOptional=true |
| 14 | `/{**path}` | isCatchAll=true，encodeSlashes=false（双星不编码斜杠） |
| 15 | `/{*path}` | isCatchAll=true，encodeSlashes=true（单星编码斜杠） |
| 16 | `/{id=0?}` | RoutePatternException（optional 参数不能有默认值） |
| 17 | `/{**path?}` | RoutePatternException（catch-all 不能标记为 optional） |

### 1.4 内联约束

| # | 输入 | 期望约束类型 |
|---|-----|------------|
| 18 | `/{id:int}` | `IntRouteConstraint` |
| 19 | `/{flag:bool}` | `BoolRouteConstraint` |
| 20 | `/{v:float}` | `FloatRouteConstraint` |
| 21 | `/{s:regex([a-z]+)}` | `RegexRouteConstraint`，pattern=`[a-z]+` |
| 22 | `/{id:int:min(1)}` | 2 个策略引用：`int`，`min(1)` |
| 23 | `/{id:int=5}` | IntRouteConstraint + default=`"5"` |
| 24 | `/{id:regex([a-z]+):int}` | 2 个策略，regex 在前 |
| 25 | `/{id:unknown}` | 无异常（约束名不验证，留工厂处理） |

### 1.5 复合段

| # | 输入 | 期望 isSimple | 说明 |
|---|-----|-------------|------|
| 26 | `/v{version}` | false | 字面量前缀 + 参数 |
| 27 | `/{name}.html` | false | 参数 + 字面量后缀 |
| 28 | `/{a}-{b}` | false | 两参数含分隔符 |
| 29 | `/{file}.{ext}` | false | 两参数含点分隔符 |
| 30 | `/prefix-{id}-suffix` | false | 参数被字面量包围 |

### 1.6 可选参数位置约束

| # | 输入 | 期望 |
|---|-----|------|
| 31 | `/{controller}/{action?}` | 合法，action 可选 |
| 32 | `/{action?}/{controller}` | RoutePatternException（optional 后不能有其他部分） |
| 33 | `/path.{ext?}` | 合法，`.` 被自动转换为 separator part |
| 34 | `/path-{ext?}` | RoutePatternException（可选参数前只能是点 `.`） |
| 35 | `/{a?}{b}` | RoutePatternException（optional 不在末尾） |

### 1.7 catch-all 位置约束

| # | 输入 | 期望 |
|---|-----|------|
| 36 | `/files/{**rest}` | 合法，catch-all 在最后 |
| 37 | `/{**rest}/after` | RoutePatternException（catch-all 不是最后一段） |
| 38 | `/{**rest}/{id}` | RoutePatternException（catch-all 后还有段） |
| 39 | `/{**rest}` | 合法，根级 catch-all |

### 1.8 段内规则约束

| # | 输入 | 期望 |
|---|-----|------|
| 40 | `/{a}{b}` | RoutePatternException（不能连续两个参数，无分隔符） |
| 41 | `/{**path}/x` | RoutePatternException（catch-all 不能在多子段内） |
| 42 | `/{id}/{id}` | RoutePatternException（重复参数名） |

### 1.9 花括号转义

| # | 输入 | 期望字面量内容 |
|---|-----|--------------|
| 43 | `/{{literal}}` | 字面量 `{literal}` |
| 44 | `/{{id}}` | 字面量 `{id}`（非参数） |
| 45 | `/{id` | RoutePatternException（未闭合花括号） |
| 46 | `/{{}` | RoutePatternException（转义后为 `{`，参数名为空） |
| 47 | `/{}` | RoutePatternException（空参数名） |

---

## 二、路由优先级 `RoutePrecedence` [P1]

### 2.1 Inbound 优先级数字（单段）

| # | 段类型 | 期望数字 |
|---|--------|---------|
| 48 | 字面量段（如 `users`） | 1 |
| 49 | 复合段（如 `v{ver}`） | 2 |
| 50 | 有约束的参数（如 `{id:int}`） | 2 |
| 51 | 有非空 required value 的参数 | 1（等同字面量） |
| 52 | 无约束普通参数（如 `{id}`） | 3 |
| 53 | 有约束的 catch-all（如 `{**path:regex(...)}`） | 4 |
| 54 | 无约束 catch-all（如 `{**path}`） | 5 |

### 2.2 多段合并公式验证

| # | 路由模式 | 期望 inboundPrecedence |
|---|---------|----------------------|
| 55 | `/a/b/c`（全字面量3段） | `1.11` |
| 56 | `/a/{id}`（1字面+1参数） | `1.3` |
| 57 | `/a/{id:int}`（1字面+1约束参数） | `1.2` |
| 58 | `/{id}/{name}`（2普通参数） | `3.3` |
| 59 | `/a/{**rest}`（1字面+catch-all） | `1.5` |

### 2.3 排序方向验证（优先级高 = 值小）

| # | 路由 A | 路由 B | 期望 |
|---|-------|-------|------|
| 60 | `/users/list` | `/users/{id}` | A.inbound < B.inbound（A 优先） |
| 61 | `/users/{id:int}` | `/users/{id}` | A.inbound < B.inbound（A 优先） |
| 62 | `/users/{id}` | `/files/{**rest}` | A.inbound < B.inbound（A 优先） |
| 63 | `/a/{id:int}` | `/a/{**path:regex(...)}` | A < B（有约束参数优于有约束 catch-all） |

---

## 三、路径分词 `FastPathTokenizer` [P1]

### 3.1 正常分词

| # | 输入路径 | 期望分段数 | 期望内容 |
|---|---------|----------|---------|
| 64 | `/` | 0 | 空数组 |
| 65 | `` （空字符串） | 0 | 空数组 |
| 66 | `/users` | 1 | `["users"]` |
| 67 | `/api/v1/users` | 3 | `["api","v1","users"]` |
| 68 | `/api/v1/users/42` | 4 | `["api","v1","users","42"]` |

### 3.2 尾随斜杠处理（重要）

| # | 输入路径 | 期望分段数 | 说明 |
|---|---------|----------|------|
| 69 | `/users/` | 1 | 尾随空段被过滤，仅含 `users` |
| 70 | `/api/v1/` | 2 | 尾随空段被过滤 |

### 3.3 连续斜杠处理（重要）

| # | 输入路径 | 期望分段数 | 说明 |
|---|---------|----------|------|
| 71 | `//users` | 1 | 头部连续斜杠产生的空段被过滤 |
| 72 | `/a//b` | 2 | 中间连续斜杠的空段被过滤 |
| 73 | `/a//b//c` | 3 | 多处空段全部过滤 |

### 3.4 PathSegment 区间正确性

| # | 说明 | 验证 |
|---|-----|------|
| 74 | 每段 `[start, end)` 区间在原始路径中还原字符串正确 | `/api/users` → segment[1].start=5, end=10 → `users` |
| 75 | 参数值通过区间提取，大小写与原始路径一致（不受 toAsciiLower 影响） | `/Users/42` → segment[0]=`Users` |

---

## 四、DFA 匹配器核心 `DfaMatcher` [P0]

### 4.1 字面量精确匹配

| # | 注册路由 | 请求路径 | 期望 |
|---|---------|---------|------|
| 76 | `GET /users` | `GET /users` | 命中 |
| 77 | `GET /users` | `GET /USERS` | 命中（DFA 小写化路径后匹配，字面量不区分大小写） |
| 78 | `GET /users` | `GET /Users` | 命中（同上） |
| 79 | `GET /users` | `GET /posts` | 无匹配 |
| 80 | `GET /api/v1/users` | `GET /api/v1/users` | 命中 |
| 81 | `GET /api/v1/users` | `GET /api/v2/users` | 无匹配 |
| 82 | `GET /users` | `GET /users/` | 无匹配（尾随斜杠变成0段，段数不符） |

### 4.2 路由参数值大小写保留（重要）

| # | 注册路由 | 请求路径 | 期望参数值 |
|---|---------|---------|----------|
| 83 | `/{id}` | `/Hello` | `id="Hello"`（原始大小写保留） |
| 84 | `/{id}` | `/WORLD` | `id="WORLD"` |
| 85 | `/{ctrl}/{action}` | `/Home/Index` | `ctrl="Home", action="Index"` |

### 4.3 普通参数捕获

| # | 注册路由 | 请求路径 | 期望 |
|---|---------|---------|------|
| 86 | `/users/{id}` | `/users/42` | `id="42"` |
| 87 | `/users/{id}` | `/users/abc-def` | `id="abc-def"` |
| 88 | `/{a}/{b}/{c}` | `/x/y/z` | `a="x",b="y",c="z"` |
| 89 | `/v{version}/api` | `/v2/api` | `version="2"` |
| 90 | `/{file}.html` | `/readme.html` | `file="readme"` |
| 91 | `/{a}-{b}` | `/foo-bar` | `a="foo",b="bar"` |
| 92 | `/prefix-{id}-suffix` | `/prefix-hello-suffix` | `id="hello"` |
| 93 | `/{file}.{ext}` | `/readme.md` | `file="readme",ext="md"` |

### 4.4 默认值行为

| # | 注册路由 | 请求路径 | 期望路由值 |
|---|---------|---------|----------|
| 94 | `/{id=1}` | `/99` | `id="99"`（提供值覆盖默认） |
| 95 | `/{id=1}` | `/` | `id="1"`（省略时用默认值，路径与路由段数不同需路由匹配成功） |
| 96 | `/{ctrl=Home}/{action=Index}` | `/About` | `ctrl="About",action="Index"` |
| 97 | `/{ctrl=Home}/{action=Index}` | `/` | `ctrl="Home",action="Index"` |

### 4.5 可选参数行为

| # | 注册路由 | 请求路径 | 期望 |
|---|---------|---------|------|
| 98 | `/users/{id?}` | `/users/42` | `id="42"` |
| 99 | `/users/{id?}` | `/users` | `id=None`（键存在但值为 None） |
| 100 | `/{ctrl}/{action?}` | `/home` | `ctrl="home",action=None` |
| 101 | `/{ctrl}/{action?}` | `/home/index` | `ctrl="home",action="index"` |
| 102 | `/doc/{name}.{ext?}` | `/doc/readme` | `name="readme",ext=None` |
| 103 | `/doc/{name}.{ext?}` | `/doc/readme.md` | `name="readme",ext="md"` |

### 4.6 Catch-all 参数

| # | 注册路由 | 请求路径 | 期望 `path` 值 |
|---|---------|---------|--------------|
| 104 | `/files/{**path}` | `/files/a` | `"a"` |
| 105 | `/files/{**path}` | `/files/a/b/c` | `"a/b/c"`（保留斜杠） |
| 106 | `/files/{**path}` | `/files` | `""`（空字符串，catch-all 为空） |
| 107 | `/{**path}` | `/any/deep/path` | `"any/deep/path"` |
| 108 | `/{**path}` | `/` | `""` |
| 109 | `/files/{*path}` | `/files/a/b` | `"a/b"`（单星与双星行为相同，但 encodeSlashes 不同） |
| 110 | `/base/{**rest}` | `/base/x/y?q=1` | `"x/y"` （query string 不含于路径） |

### 4.7 约束验证与候选排除

| # | 注册路由 | 请求路径 | 期望 |
|---|---------|---------|------|
| 111 | `/users/{id:int}` | `/users/42` | 命中，`id="42"` |
| 112 | `/users/{id:int}` | `/users/abc` | 约束失败，无匹配 |
| 113 | `/users/{id:int}` | `/users/-1` | 命中，`id="-1"`（负整数合法） |
| 114 | `/users/{id:int}` | `/users/9999999999999999999` | 约束失败（Int64 溢出） |
| 115 | `/{flag:bool}` | `/true` | 命中 |
| 116 | `/{flag:bool}` | `/false` | 命中 |
| 117 | `/{flag:bool}` | `/True` | 命中（大小写不敏感） |
| 118 | `/{flag:bool}` | `/yes` | 约束失败 |
| 119 | `/rate/{v:float}` | `/rate/3.14` | 命中 |
| 120 | `/rate/{v:float}` | `/rate/-0.5` | 命中（负数） |
| 121 | `/rate/{v:float}` | `/rate/abc` | 约束失败 |
| 122 | `/slug/{s:regex([a-z]+)}` | `/slug/hello` | 命中 |
| 123 | `/slug/{s:regex([a-z]+)}` | `/slug/Hello` | 命中（RegexRouteConstraint 默认 IgnoreCase） |
| 124 | `/slug/{s:regex(^\d+$)}` | `/slug/123` | 命中 |
| 125 | `/slug/{s:regex(^\d+$)}` | `/slug/abc` | 约束失败 |
| 126 | `/u/{id:int}` + `/u/{name}` | `/u/42` | 命中 `{id:int}`（约束参数优先） |
| 127 | `/u/{id:int}` + `/u/{name}` | `/u/abc` | 命中 `{name}`（约束失败回退） |

---

## 五、复合段匹配 `RoutePatternMatcher.matchComplexSegment` [P1]

> 算法：从右向左扫描，先固定字面量位置，再提取参数值

### 5.1 前缀字面量 + 参数

| # | 模式 | 请求段 | 期望 |
|---|-----|-------|------|
| 128 | `v{version}` | `v2` | `version="2"` |
| 129 | `v{version}` | `v` | 失败（参数值为空） |
| 130 | `v{version}` | `2` | 失败（前缀 `v` 不存在） |
| 131 | `v{version}` | `V2` | 命中（字面量大小写不敏感，`version="2"`） |
| 132 | `api-{name}` | `api-hello` | `name="hello"` |

### 5.2 参数 + 后缀字面量

| # | 模式 | 请求段 | 期望 |
|---|-----|-------|------|
| 133 | `{name}.html` | `readme.html` | `name="readme"` |
| 134 | `{name}.html` | `readme.txt` | 失败（后缀不匹配） |
| 135 | `{name}.html` | `.html` | 失败（参数值为空） |
| 136 | `{name}.html` | `readme.html.bak` | 失败（后缀不在末尾，需要末尾对齐） |

### 5.3 参数-分隔符-参数

| # | 模式 | 请求段 | 期望 |
|---|-----|-------|------|
| 137 | `{a}-{b}` | `foo-bar` | `a="foo",b="bar"` |
| 138 | `{a}-{b}` | `foo-bar-baz` | `a="foo-bar",b="baz"`（贪婪从左匹配） |
| 139 | `{a}-{b}` | `foo` | 失败（无分隔符） |
| 140 | `{a}-{b}` | `-bar` | 失败（a 为空） |
| 141 | `{a}-{b}` | `foo-` | 失败（b 为空） |
| 142 | `{a}.{b}` | `readme.md` | `a="readme",b="md"` |

### 5.4 末尾 optional 参数

| # | 模式 | 请求段 | 期望 |
|---|-----|-------|------|
| 143 | `{name}.{ext?}` | `readme.md` | `name="readme",ext="md"` |
| 144 | `{name}.{ext?}` | `readme` | `name="readme",ext=None`（`.` 是 separator，无 ext 时跳过） |
| 145 | `{name}.{ext?}` | `readme.` | 失败（`.` 结尾但 ext 为空） |

---

## 六、HTTP 方法匹配 `HttpMethodMatcherPolicy` [P0]

### 6.1 精确方法匹配

| # | 注册方式 | 请求方法 | 期望 |
|---|---------|---------|------|
| 146 | `mapGet` | GET | 命中 |
| 147 | `mapPost` | POST | 命中 |
| 148 | `mapPut` | PUT | 命中 |
| 149 | `mapPatch` | PATCH | 命中 |
| 150 | `mapDelete` | DELETE | 命中 |
| 151 | `mapGet` | POST | 无匹配（405 端点） |
| 152 | `mapPost` | GET | 无匹配 |

### 6.2 方法大小写不敏感

| # | 注册方式 | 请求方法 | 期望 |
|---|---------|---------|------|
| 153 | `mapGet` | `get`（小写） | 命中（首字节位运算 `\|0x20` 转小写比较） |
| 154 | `mapPost` | `Post` | 命中 |
| 155 | `mapGet` | `GET` | 命中 |

### 6.3 通配方法 `map`

| # | 注册方式 | 请求方法 | 期望 |
|---|---------|---------|------|
| 156 | `map`（无方法限制） | GET | 命中 |
| 157 | `map` | POST | 命中 |
| 158 | `map` | DELETE | 命中 |
| 159 | `map` | OPTIONS | 命中 |
| 160 | `map` | 任意自定义方法 | 命中 |

### 6.4 同路径多方法

| # | 注册路由 | 请求方法 | 期望选中端点 |
|---|---------|---------|-----------|
| 161 | `GET /items` + `POST /items` | GET | GET 端点 |
| 162 | `GET /items` + `POST /items` | POST | POST 端点 |
| 163 | `GET /items` + `POST /items` | DELETE | 无匹配（405） |
| 164 | `GET /items` + `map /items` | GET | 需确认：GET 优先还是歧义 |
| 165 | `GET /items` + `POST /items` + `map /items` | PUT | map 端点命中 |

### 6.5 CORS 预检（OPTIONS）

| # | 注册路由 | 请求条件 | 期望 |
|---|---------|---------|------|
| 166 | `mapGet`（acceptCorsPreflight=true） | OPTIONS + Origin + Access-Control-Request-Method: GET | 命中（CORS 路径） |
| 167 | `mapGet`（acceptCorsPreflight=false） | OPTIONS + Origin + Access-Control-Request-Method: GET | 无匹配 |
| 168 | `mapGet`（CORS 已启用） | OPTIONS（无 Origin 头） | 无匹配（非 CORS 预检） |
| 169 | `mapGet`（CORS 已启用） | OPTIONS + Origin（无 Access-Control-Request-Method） | 无匹配 |
| 170 | `mapGet`（CORS 已启用） | OPTIONS + Origin + Access-Control-Request-Method: `""` | 无匹配（方法值为空） |
| 171 | `mapGet`（CORS 已启用） | OPTIONS + Origin + Access-Control-Request-Method: POST | 命中还是不命中（Access-Control-Request-Method 与注册方法不一致） |

### 6.6 自定义 HTTP 方法

| # | 注册路由 | 请求方法 | 期望 |
|---|---------|---------|------|
| 172 | 注册方法 `REPORT` | REPORT | 命中（走 extraDestinations HashMap） |
| 173 | 注册方法 `REPORT` | report | 命中（小写转换后比较） |

---

## 七、端点选择与歧义处理 `DefaultEndpointSelector` [P0]

### 7.1 优先级选择（score 低者优先）

| # | 注册路由 | 请求 | 期望选中 |
|---|---------|------|---------|
| 174 | `/users/me` + `/users/{id}` | `GET /users/me` | `/users/me`（字面量 score 更低） |
| 175 | `/users/{id:int}` + `/users/{name}` | `GET /users/42` | `{id:int}` |
| 176 | `/api/users` + `/{**rest}` | `GET /api/users` | `/api/users` |
| 177 | `/a/b/c` + `/a/{x}/c` + `/{**rest}` | `GET /a/b/c` | `/a/b/c` |
| 178 | `/a/{id:int}/b` + `/a/{name}/b` | `GET /a/42/b` | `{id:int}` |

### 7.2 歧义匹配异常

| # | 注册路由 | 请求 | 期望 |
|---|---------|------|------|
| 179 | `/users/{id}` + `/users/{name}` | `GET /users/42` | AmbiguousMatchException |
| 180 | `/a/{x}` + `/a/{y}` | `GET /a/hello` | AmbiguousMatchException |
| 181 | `/a/{x}` + `/a/{y}` + `/a/{z}` | `GET /a/v` | AmbiguousMatchException（列出全部 3 个端点） |

### 7.3 无匹配

| # | 注册路由 | 请求 | 期望 |
|---|---------|------|------|
| 182 | `/users` | `GET /posts` | endpoint=None |
| 183 | `/users/{id:int}` | `GET /users/abc` | endpoint=None（约束全部失败） |
| 184 | `GET /users` | `DELETE /users` | endpoint=None（方法不匹配） |
| 185 | `/users/{id}` | `GET /users` | endpoint=None（参数必需但缺少段） |

### 7.4 单候选优化路径

| # | 说明 | 期望 |
|---|-----|------|
| 186 | 整个系统只注册 1 条路由，且请求匹配 | 走单候选快速路径（无需选举），命中 |
| 187 | 单候选但约束失败 | endpoint=None（isValid=false，不设置端点） |

---

## 八、DFA 构建行为 `DfaMatcherBuilder` [P2]

### 8.1 字面量前缀共享

| # | 注册路由 | 期望 DFA 结构 |
|---|---------|------------|
| 188 | `/api/users` + `/api/posts` | 共享 `/api` 节点，然后分叉为 `users` / `posts` |
| 189 | `/api/v1` + `/api/v2` | 共享 `/api`，分叉 `v1` / `v2` |
| 190 | `/users` + `/posts` | 根节点直接分两路 |

### 8.2 字面量与参数节点共存

| # | 注册路由 | 期望 DFA |
|---|---------|--------|
| 191 | `/users/me` + `/users/{id}` | `me` 走字面量节点，其他走参数节点 |
| 192 | `/users/me` + `/users/{id:int}` + `/users/{name}` | `me` 字面量，`42` 走约束参数，`abc` 走普通参数 |

### 8.3 Catch-all 自循环节点

| # | 注册路由 | 期望 |
|---|---------|------|
| 193 | `/{**path}` | catch-all 节点的 catchAll 和 parameters 字段均指向自身（自循环） |
| 194 | `/{**path}` | 任意深度路径均命中（1段、5段、10段） |

### 8.4 必需值参数转为字面量

| # | 注册路由（含 requiredValues） | 期望 DFA |
|---|---------------------------|--------|
| 195 | `{controller=Home}/{action=Index}`（框架路由） | controller 和 action 被转换为字面量节点 |

---

## 九、`RouteValueDictionary` [P2]

### 9.1 基本操作

| # | 操作 | 期望返回值 |
|---|-----|----------|
| 196 | `add("id","1"); get("id")` | `Some(Some("1"))` |
| 197 | `get("missing")` | `None` |
| 198 | `add("id", None); get("id")` | `Some(None)` |
| 199 | `add("id","1"); add("id","2"); get("id")` | `Some(Some("2"))`（覆盖） |
| 200 | `fromArray([("id","1"),("name","tom")]); get("name")` | `Some(Some("tom"))` |
| 201 | `contains("id")` 在 add 后 | true |
| 202 | `contains("x")` 在未 add 时 | false |
| 203 | `addIfAbsent("id","new")` 在已有 id 时 | 不覆盖，原值保留 |
| 204 | `addIfAbsent("x","v")` 在无 x 时 | 写入 `x="v"` |

---

## 十、约束类详细边界 [P1]

### 10.1 `IntRouteConstraint`

| # | 路由值 | isMatch 期望 |
|---|-------|------------|
| 205 | `"0"` | true |
| 206 | `"-1"` | true（负整数） |
| 207 | `"9223372036854775807"` | true（Int64 最大值） |
| 208 | `"9223372036854775808"` | false（溢出） |
| 209 | `"3.14"` | false |
| 210 | `""` | false（空字符串） |
| 211 | 值为 None（key 存在） | false（Some(None) 模式不匹配） |
| 212 | key 不存在 | false |

### 10.2 `BoolRouteConstraint`

| # | 路由值 | isMatch 期望 |
|---|-------|------------|
| 213 | `"true"` | true |
| 214 | `"false"` | true |
| 215 | `"True"` | true（大小写不敏感） |
| 216 | `"FALSE"` | true |
| 217 | `"1"` | false（`1` 不是 bool） |
| 218 | `"yes"` | false |
| 219 | `""` | false |

### 10.3 `FloatRouteConstraint`

| # | 路由值 | isMatch 期望 |
|---|-------|------------|
| 220 | `"3.14"` | true |
| 221 | `"-0.5"` | true |
| 222 | `"0"` | true（整数可解析为 float） |
| 223 | `"1e10"` | true（科学计数法） |
| 224 | `"abc"` | false |
| 225 | `""` | false |

### 10.4 `RegexRouteConstraint`

| # | 约束 pattern | 路由值 | isMatch 期望 |
|---|------------|-------|------------|
| 226 | `[a-z]+` | `hello` | true |
| 227 | `[a-z]+` | `Hello` | true（IgnoreCase 标志） |
| 228 | `[a-z]+` | `HELLO` | true（IgnoreCase） |
| 229 | `^\d+$` | `123` | true |
| 230 | `^\d+$` | `abc` | false |
| 231 | `[a-z]+` | `hello world` | true（部分匹配，非全匹配） |
| 232 | `^\d+$` | `123abc` | false（全匹配语义，不匹配） |
| 233 | `[a-z]+` | `""` | false（空字符串无字母） |

---

## 十一、端到端路由管道集成 [P1]

### 11.1 完整请求路由（addRouting → useRouting → useEndpoints → 请求）

| # | 注册路由 | 请求 | 验证点 |
|---|---------|------|-------|
| 234 | `mapGet("/users", h)` | `GET /users` | handler 执行，`getEndpoint()` 非 None |
| 235 | `mapGet("/users/{id:int}", h)` | `GET /users/42` | handler 执行，路由值 `id="42"` 可通过 context 获取 |
| 236 | `mapGet("/users/{id:int}", h)` | `GET /users/abc` | handler 不执行，响应为 404 |
| 237 | `mapGet("/a", h1)` + `mapPost("/a", h2)` | `POST /a` | h2 执行，h1 不执行 |
| 238 | `mapGet("/a", h1)` + `mapPost("/a", h2)` | `DELETE /a` | 两者均不执行，404 |
| 239 | `mapGet("/me", h1)` + `mapGet("/{id}", h2)` | `GET /me` | h1 执行（字面量优先） |
| 240 | `mapGet("/me", h1)` + `mapGet("/{id}", h2)` | `GET /alice` | h2 执行 |
| 241 | `map("/{**path}", h)` | `GET /any/deep/path` | h 执行，`path="any/deep/path"` |
| 242 | `mapGet("/{ctrl}/{action}", h)` | `GET /home/index` | `ctrl="home", action="index"` 注意：小写还是原始？ |
| 243 | 2 个 RouteEndpointDataSource 分别注册路由 | 跨数据源的路径 | CompositeEndpointDataSource 正确聚合，均可命中 |

### 11.2 中间件顺序与状态

| # | 场景 | 期望 |
|---|-----|------|
| 244 | EndpointRoutingMiddleware 第一次请求 | DFA 初始化（Mutex 保护） |
| 245 | EndpointRoutingMiddleware 并发第一次请求 | 只初始化一次（双重检查锁） |
| 246 | 后续多次请求 | 复用同一 `_matcher` 实例 |
| 247 | context 已有 endpoint 时进入 EndpointRoutingMiddleware | 跳过匹配（不覆盖已设置的 endpoint） |
| 248 | 无匹配时 EndpointMiddleware | 传递给下游 next，不执行任何 delegate |
| 249 | 缺少 `addRouting` 服务注册时 `useRouting` | 启动时抛出异常，提示 RoutingMarkerService 缺失 |

---

## 十二、已知 ASP.NET Core 对齐行为 [P0]

> 这些是 ASP.NET Core 已确立的路由语义，需要验证仓颉实现与其一致

| # | 行为 | 输入 | 期望 |
|---|-----|-----|------|
| 250 | 字面量段大小写不敏感 | `/Users` 请求 `/users` 路由 | 命中 |
| 251 | 参数值大小写原样保留 | `/Hello` 路径 `/{id}` 路由 | `id="Hello"` |
| 252 | 优先级：字面量 > 约束参数 > 无约束参数 > catch-all | 综合 | 按顺序命中 |
| 253 | catch-all 可为空 | `/files/{**path}` + `GET /files` | 命中，`path=""` |
| 254 | 同分路由触发歧义异常 | `/u/{id}` + `/u/{name}` | AmbiguousMatchException |
| 255 | 约束失败时可回退到低优先级路由 | `{id:int}` + `{name}` | 数字命中前者，字母命中后者 |
| 256 | Regex 约束不区分大小写 | `{s:regex([a-z]+)}` + `Hello` | 命中（IgnoreCase） |
| 257 | `**` catch-all 不编码斜杠（encodeSlashes=false） | `/a/{**path}` + `GET /a/x/y` | `path="x/y"` |
| 258 | `*` catch-all 编码斜杠（encodeSlashes=true） | `/a/{*path}` + `GET /a/x/y` | `path="x/y"`（值相同，差异在 URL 生成） |
| 259 | 连续斜杠不计入分段 | `GET /a//b` | 视为 `/a/b`（2段），可命中 `/a/{id}` |
| 260 | 尾随斜杠不计入分段 | `GET /users/` | 分1段 `users`，命中 `/users` 路由 |

---

## 十三、`IParameterLiteralNodeMatchingPolicy` 约束优化 [P2]

> 有约束的参数在 DFA 构建时可筛选字面量分支（`IntRouteConstraint` 实现了此接口）

| # | 场景 | 期望 |
|---|-----|------|
| 261 | `/{id:int}` + `/123` 字面量节点 | DFA 构建时，int 约束可以筛选是否将 `123` 字面量分支加入 |
| 262 | `/{id:int}` + `/abc` 字面量节点 | int 约束排除 `abc` 字面量分支（优化 DFA 节点数） |

---

## 十四、OutboundPrecedence（URL 生成优先级）[P2]

| # | 说明 | 期望 |
|---|-----|------|
| 263 | outbound 优先级数字方向与 inbound 相反（5最高） | 字面量 outbound > 普通参数 |
| 264 | 无约束 catch-all outbound = 1（最低），字面量 = 5（最高） | 排序方向与 inbound 相反 |

---

## 测试文件目录结构（建议）

```
test/src/
├── main.cj
├── patterns/
│   ├── RoutePatternParserTest.cj        # 第一章（1.1-1.9）
│   ├── RoutePrecedenceTest.cj           # 第二章（2.1-2.3）
│   └── RoutePatternMatcherTest.cj       # 第五章复合段（5.1-5.4）
├── tokenizer/
│   └── FastPathTokenizerTest.cj         # 第三章（3.1-3.4）
├── matching/
│   ├── DfaMatcherTest.cj                # 第四章（4.1-4.7）[P0 核心]
│   ├── EndpointSelectorTest.cj          # 第七章（7.1-7.4）[P0 核心]
│   ├── HttpMethodPolicyTest.cj          # 第六章（6.1-6.6）[P0 核心]
│   └── DfaMatcherBuilderTest.cj         # 第八章（8.1-8.4）
├── constraints/
│   ├── IntConstraintTest.cj             # 第十章 10.1
│   ├── BoolConstraintTest.cj            # 第十章 10.2
│   ├── FloatConstraintTest.cj           # 第十章 10.3
│   └── RegexConstraintTest.cj           # 第十章 10.4
├── core/
│   └── RouteValueDictionaryTest.cj      # 第九章
└── integration/
    ├── EndToEndRoutingTest.cj           # 第十一章（11.1-11.2）
    └── AspNetCoreAlignmentTest.cj       # 第十二章（12，对齐验证）
```

---

## 测试覆盖优先级

```
P0（先行实现，核心行为）
  ├── 第四章  4.1-4.7  DfaMatcher 字面量/参数/默认值/可选/CatchAll/约束
  ├── 第六章  6.1-6.6  HTTP 方法匹配含 CORS
  ├── 第七章  7.1-7.4  端点选择、歧义检测
  └── 第十二章         ASP.NET Core 对齐行为

P1（其次实现，主流程）
  ├── 第一章  1.1-1.9  路由模式解析（含异常路径）
  ├── 第二章  2.1-2.3  优先级计算
  ├── 第三章  3.1-3.4  路径分词边界
  ├── 第五章  5.1-5.4  复合段匹配
  ├── 第十章  10.1-10.4 约束类边界
  └── 第十一章 11.1-11.2 端到端管道

P2（后续补充）
  ├── 第八章  8.1-8.4  DFA 构建结构
  ├── 第九章  9.1     RouteValueDictionary
  ├── 第十三章        IParameterLiteralNodeMatchingPolicy
  └── 第十四章        OutboundPrecedence
```

---

**用例总计：264 条**
