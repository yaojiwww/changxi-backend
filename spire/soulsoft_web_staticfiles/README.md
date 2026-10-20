# soulsoft.web.staticfiles

**为仓颉 Web 应用提供静态文件服务的中间件库，支持文件提供、默认文件、条件请求与 Range 下载。**
---

## 关于

`soulsoft_web_staticfiles` 为 Soulsoft Web 框架提供完整的静态文件服务能力，参考 ASP.NET Core 的 `Microsoft.AspNetCore.StaticFiles` 实现。核心由三个中间件组成：`StaticFileMiddleware` 负责文件响应，`DefaultFilesMiddleware` 处理目录默认文件，`FileServerExtensions` 将二者组合为一键调用接口。

内置对 ETag、`Last-Modified`、`If-Match`、`If-None-Match`、`If-Modified-Since`、`If-Unmodified-Since`、`Range`、`If-Range` 等 HTTP 条件请求头的完整支持，文件变更检测与分片下载开箱即用。

### 特性

| 特性 | 描述 |
|------|------|
| 📁 **静态文件服务** | `useStaticFiles()` 将物理目录映射为 URL 路径，支持 GET / HEAD 请求 |
| 🏠 **默认文件** | `useDefaultFiles()` 在目录路径下自动查找 `index.html` 等默认文件并重写路径 |
| 🔀 **路由前缀** | `requestPath` 支持将静态资源挂载到任意 URL 前缀（如 `/static`） |
| ⚡ **条件请求** | 完整实现 ETag、Last-Modified 条件头，未修改时返回 304，减少带宽消耗 |
| 📦 **Range 下载** | 支持 RFC 7233 单区间 Range 请求，返回 206 / 416，兼容断点续传场景 |
| 🗂️ **复合提供器** | `CompositeFileProvider` 聚合多个 `IFileProvider`，按优先级依次查找文件 |
| 🔒 **路径安全** | `PhysicalFileProvider` 内置路径穿越防护，自动过滤隐藏/系统文件 |
| 🎛️ **响应回调** | `onPrepareResponse` 在响应写入前注入自定义头（如 Cache-Control） |
| 🧩 **共享选项** | `FileServerOptions` 使用 `SharedOptions` 共享引用，`requestPath`/`fileProvider` 一处修改全局生效 |

---

## 如何使用

### 静态文件服务

最简用法：将 `wwwroot` 目录挂载到根路径。

```cj
import soulsoft_web_staticfiles.*
import soulsoft_web_staticfiles.fileProviders.*

// 无前缀：GET /hello.txt → wwwroot/hello.txt
app.useStaticFiles {
    options =>
        options.fileProvider = PhysicalFileProvider("wwwroot")
}

// 带前缀：GET /static/hello.txt → wwwroot/hello.txt
app.useStaticFiles {
    options =>
        options.requestPath = PathString("/static")
        options.fileProvider = PhysicalFileProvider("wwwroot")
}
```

提供未知类型文件（如 `.xyz`），或在写入响应前添加自定义头：

```cj
app.useStaticFiles {
    options =>
        options.fileProvider = PhysicalFileProvider("wwwroot")
        options.serveUnknownFileTypes = true
        options.defaultContentType = "application/octet-stream"
        options.onPrepareResponse = { ctx =>
            ctx.context.response.headers["Cache-Control"] = ["public,max-age=3600"]
        }
}
```

### 默认文件 + 静态文件

`useDefaultFiles` 必须在 `useStaticFiles` 之前注册，它负责路径重写，由 `useStaticFiles` 完成实际响应。

```cj
// GET /        → wwwroot/index.html（若存在）→ 200
// GET /sub     → 301 重定向到 /sub/
// GET /sub/    → wwwroot/sub/index.html → 200
app.useDefaultFiles {
    options =>
        options.fileProvider = PhysicalFileProvider("wwwroot")
}
app.useStaticFiles {
    options =>
        options.fileProvider = PhysicalFileProvider("wwwroot")
}
```

自定义默认文件名优先级：

```cj
import std.collection.*

app.useDefaultFiles {
    options =>
        options.fileProvider = PhysicalFileProvider("wwwroot")
        options.defaultFileNames = ArrayList<String>(["app.html", "index.html"])
}
```

### 使用 FileServer 一键组合

`useFileServer` 将 `useDefaultFiles` 与 `useStaticFiles` 合并为单次调用，`requestPath` 和 `fileProvider` 通过共享引用自动同步到两个子中间件：

```cj
app.useFileServer {
    options =>
        options.requestPath = PathString("/assets")
        options.fileProvider = PhysicalFileProvider("wwwroot")
        // 以下修改自动反映到 staticFileOptions 和 defaultFilesOptions
        options.staticFileOptions.serveUnknownFileTypes = true
}
```

### 使用 CompositeFileProvider

从多个目录中按顺序查找文件，第一个命中的提供器返回结果：

```cj
import std.collection.*

let provider = CompositeFileProvider([
    PhysicalFileProvider("wwwroot"),
    PhysicalFileProvider("assets")
] as Collection<IFileProvider>)

app.useStaticFiles {
    options => options.fileProvider = provider
}
```

---

## API 参考

### useStaticFiles / useDefaultFiles / useFileServer

扩展到 `ApplicationBuilder` 的中间件注册方法，均提供三种重载：

| 方法 | 说明 |
|------|------|
| `useStaticFiles(): Unit` | 使用默认选项注册静态文件中间件 |
| `useStaticFiles(options: StaticFileOptions): Unit` | 使用预构建选项注册 |
| `useStaticFiles(configureOptions: (StaticFileOptions) -> Unit): Unit` | 使用配置回调注册 |
| `useDefaultFiles(): Unit` | 使用默认选项注册默认文件中间件 |
| `useDefaultFiles(options: DefaultFilesOptions): Unit` | 使用预构建选项注册 |
| `useDefaultFiles(configureOptions: (DefaultFilesOptions) -> Unit): Unit` | 使用配置回调注册 |
| `useFileServer(): Unit` | 使用默认选项注册组合文件服务器 |
| `useFileServer(options: FileServerOptions): Unit` | 使用预构建选项注册 |
| `useFileServer(configureOptions: (FileServerOptions) -> Unit): Unit` | 使用配置回调注册 |

### StaticFileOptions

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `requestPath` | `PathString` | `""` | 请求路径前缀，空字符串匹配所有路径 |
| `fileProvider` | `?IFileProvider` | `None` | 文件提供器，`None` 时使用 wwwroot |
| `serveUnknownFileTypes` | `Bool` | `false` | 是否提供无法识别 Content-Type 的文件 |
| `defaultContentType` | `?String` | `None` | 未知类型的备用 Content-Type |
| `onPrepareResponse` | `?(StaticFileResponseContext) -> Unit` | `None` | 响应写入前的回调 |
| `redirectToAppendTrailingSlash` | `Bool` | `true` | 目录路径缺少末尾斜杠时是否 301 重定向 |

### DefaultFilesOptions

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `requestPath` | `PathString` | `""` | 请求路径前缀 |
| `fileProvider` | `?IFileProvider` | `None` | 文件提供器 |
| `defaultFileNames` | `ArrayList<String>` | `["default.htm", "default.html", "index.htm", "index.html"]` | 按优先级排序的默认文件名列表 |

### FileServerOptions

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `requestPath` | `PathString` | `""` | 共享路径前缀，自动同步到子选项 |
| `fileProvider` | `?IFileProvider` | `None` | 共享文件提供器，自动同步到子选项 |
| `enableDefaultFiles` | `Bool` | `true` | 是否启用默认文件中间件 |
| `enableDirectoryBrowsing` | `Bool` | `false` | 是否启用目录浏览（保留字段） |
| `staticFileOptions` | `StaticFileOptions` | — | 静态文件子配置，与顶层共享引用 |
| `defaultFilesOptions` | `DefaultFilesOptions` | — | 默认文件子配置，与顶层共享引用 |

### IFileProvider

| 方法 | 说明 |
|------|------|
| `getFileInfo(path: String): IFileInfo` | 获取文件元信息；文件不存在时返回 `exists == false` 的对象 |
| `getDirectoryContents(subPath: String): IDirectoryContents` | 获取目录内容；目录不存在时返回 `exists == false` 的对象 |

### IFileInfo

| 属性/方法 | 类型 | 说明 |
|-----------|------|------|
| `name` | `String` | 文件名（不含目录） |
| `size` | `Int64` | 文件字节数 |
| `exists` | `Bool` | 文件是否存在 |
| `isDirectory` | `Bool` | 是否为目录 |
| `physicalPath` | `?String` | 物理路径，虚拟文件返回 `None` |
| `lastModified` | `DateTime` | 最后修改时间 |
| `createReadStream(): InputStream` | — | 打开文件读取流 |

### PhysicalFileProvider

| 构造函数 | 说明 |
|----------|------|
| `init(path: String)` | 使用默认 `Sensitive` 过滤规则（排除 `.` 开头、隐藏、系统文件） |
| `init(path: String, filters: ExclusionFilters)` | 使用自定义过滤规则 |

### ExclusionFilters

| 值 | 说明 |
|----|------|
| `None` | 不排除任何文件 |
| `DotPrefixed` | 排除以 `.` 开头的文件和目录 |
| `Hidden` | 排除隐藏属性文件（平台相关） |
| `System` | 排除系统属性文件（平台相关） |
| `Sensitive` | `DotPrefixed \| Hidden \| System`，默认值 |

---

## 相关包

- `soulsoft_web_http` — HTTP 类型系统（`PathString`、`QueryString`、请求/响应头值对象）
- `soulsoft_web_hosting` — Web 宿主与中间件管道（`WebHost`、`ApplicationBuilder`、`HttpContext`）
- `soulsoft_web_routing` — 路由与端点匹配
- `soulsoft_extensions_options` — 选项模式（`IOptions<T>`）
- `soulsoft_extensions_injection` — 依赖注入容器

---

## 反馈与贡献

本项目由杭州颉创科技有限公司开发，以 MIT 许可证开源发布。欢迎在 [GitCode](https://gitcode.com/soulsoft) 提交错误报告和贡献代码。

---

## 开源声明

本库的核心实现参考了 [aspnetcore](https://github.com/dotnet/aspnetcore) 中的 `Microsoft.AspNetCore.StaticFiles` 模块，原始代码版权归 .NET Foundation 所有，遵循 MIT 许可证。详见 [README.OpenSource](https://gitcode.com/soulsoft/spire/blob/main/README.OpenSource)。
