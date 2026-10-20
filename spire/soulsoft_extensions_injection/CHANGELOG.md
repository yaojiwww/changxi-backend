# CHANGELOG — soulsoft.extensions.injection

## v1.1.0 - 2026-03-11

### Breaking Changes

- **`ServiceDescriptor.init(serviceKey:serviceType:instance:)`** 由 `public` 改为 `internal`，不再对外暴露；
  迁移方式：改用 `ServiceDescriptor.singleton<TService>(instance:)` 等静态工厂方法

- **`ServiceDescriptor.init(serviceKey:serviceType:lifetime:factory:)`** 由 `public` 改为 `internal`，不再对外暴露；
  迁移方式：改用 `ServiceDescriptor.scoped/transient/singleton<TService>(factory:)` 等静态工厂方法

- **`ServiceDescriptor.init(serviceKey:serviceType:implementationType:lifetime:)`** 由 `public` 改为 `internal`，不再对外暴露；
  迁移方式：改用 `ServiceDescriptor.scoped/transient/singleton<TService, TImplementation>()` 等静态工厂方法

- **`ServiceCollectionExtensions` 工厂重载**（`addSingleton/addScoped/addTransient/tryAddSingleton/tryAddScoped/tryAddTransient/addKeyedSingleton/addKeyedScoped/addKeyedTransient/tryAddKeyedSingleton/tryAddKeyedScoped/tryAddKeyedTransient<TService>(factory:)`）
  工厂参数类型由 `(IServiceProvider) -> Any` 改为 `(IServiceProvider) -> TService`；
  迁移方式：工厂闭包返回值类型需与 `TService` 一致，移除 `as Any` 强转

### Fixed

- **`ServiceDescriptor.requireSubtype()`** — 提取三处重复的子类型校验逻辑为私有静态方法，消除代码重复

---

## v1.0.0

初始发布。
