# CHANGELOG — soulsoft.extensions.http

## v1.1.0 - 2026-03-12

### Breaking Changes

- **`ActiveHandlerTrackingEntry.startCleanupTimer()`** 已删除；该方法为内部实现细节，
  应由工厂生命周期管理替代，调用者无需手动控制清理定时器。
- **`ActiveHandlerTrackingEntry.stopCleanupTimer()`** 已删除；同上。
- **`HttpClientBuilder` 系列配置方法** 返回类型从 `Unit` 改为 `HttpClientBuilder`，
  支持链式调用；现有代码若将返回值赋给 `Unit` 类型变量则需移除赋值语句。
  受影响方法：`setHandlerLifetime`、`configureHttpClient`（×2）、
  `addHttpMessageHandler`（×3）、`configureHttpMessageHandlerBuilder`、
  `configurePrimaryHttpMessageHandler`（×3）、`addTypedClient`（×3）。

### Removed

- **`ActiveHandlerTrackingEntry.startCleanupTimer(): Unit`** — 内部定时器管理已内化，
  不再作为公开 API 暴露，调用者不应依赖此方法。
- **`ActiveHandlerTrackingEntry.stopCleanupTimer()`** — 同上。

### Changed

- **`HttpClientBuilder.setHandlerLifetime(handlerLifetime: Duration): Unit`**
  → **`setHandlerLifetime(handlerLifetime: Duration): HttpClientBuilder`**
  — 改为返回 `this` 以支持流式配置。
- **`HttpClientBuilder.configureHttpClient(configureClient: (HttpClient) -> Unit): Unit`**
  → **`configureHttpClient(configureClient: (HttpClient) -> Unit): HttpClientBuilder`**
  — 同上。
- **`HttpClientBuilder.configureHttpClient(configureClient: (HttpClient, IServiceProvider) -> Unit): Unit`**
  → **`configureHttpClient(configureClient: (HttpClient, IServiceProvider) -> Unit): HttpClientBuilder`**
  — 同上。
- **`HttpClientBuilder.addHttpMessageHandler(configureHandler: () -> DelegatingHandler): Unit`**
  → **`addHttpMessageHandler(configureHandler: () -> DelegatingHandler): HttpClientBuilder`**
  — 同上。
- **`HttpClientBuilder.addHttpMessageHandler(configureHandler: (IServiceProvider) -> DelegatingHandler): Unit`**
  → **`addHttpMessageHandler(configureHandler: (IServiceProvider) -> DelegatingHandler): HttpClientBuilder`**
  — 同上。
- **`HttpClientBuilder.addHttpMessageHandler<THandler>(): Unit`**
  → **`addHttpMessageHandler<THandler>(): HttpClientBuilder`**
  — 同上。
- **`HttpClientBuilder.configureHttpMessageHandlerBuilder(configureBuilder: (HttpMessageHandlerBuilder) -> Unit): Unit`**
  → **`configureHttpMessageHandlerBuilder(configureBuilder: (HttpMessageHandlerBuilder) -> Unit): HttpClientBuilder`**
  — 同上。
- **`HttpClientBuilder.configurePrimaryHttpMessageHandler(configureHandler: () -> HttpMessageHandler): Unit`**
  → **`configurePrimaryHttpMessageHandler(configureHandler: () -> HttpMessageHandler): HttpClientBuilder`**
  — 同上。
- **`HttpClientBuilder.configurePrimaryHttpMessageHandler(configureHandler: (IServiceProvider) -> HttpMessageHandler): Unit`**
  → **`configurePrimaryHttpMessageHandler(configureHandler: (IServiceProvider) -> HttpMessageHandler): HttpClientBuilder`**
  — 同上。
- **`HttpClientBuilder.configurePrimaryHttpMessageHandler<THandler>(): Unit`**
  → **`configurePrimaryHttpMessageHandler<THandler>(): HttpClientBuilder`**
  — 同上。
- **`HttpClientBuilder.addTypedClient<TClient, TImplementation>(): Unit`**
  → **`addTypedClient<TClient, TImplementation>(): HttpClientBuilder`**
  — 同上。
- **`HttpClientBuilder.addTypedClient<TClient, TImplementation>(factory: (HttpClient) -> TImplementation): Unit`**
  → **`addTypedClient<TClient, TImplementation>(factory: (HttpClient) -> TImplementation): HttpClientBuilder`**
  — 同上。
- **`HttpClientBuilder.addTypedClient<TClient, TImplementation>(factory: (HttpClient, IServiceProvider) -> TImplementation): Unit`**
  → **`addTypedClient<TClient, TImplementation>(factory: (HttpClient, IServiceProvider) -> TImplementation): HttpClientBuilder`**
  — 同上。

### Migration Guide

```cangjie
// 旧写法（v1.0.0）— 逐行调用，无返回值
builder.setHandlerLifetime(Duration.minute * 5)
builder.configureHttpClient({ client => client.timeout = Duration.second * 30 })
builder.addHttpMessageHandler({ LoggingHandler() })

// 新写法（v1.1.0）— 链式调用
builder
    .setHandlerLifetime(Duration.minute * 5)
    .configureHttpClient({ client => client.timeout = Duration.second * 30 })
    .addHttpMessageHandler({ LoggingHandler() })
```

---

## v1.0.0

初始发布。
