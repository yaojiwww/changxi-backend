// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.infrastructure

import std.reflect.*
import std.collection.*
import soulsoft_web_mvc.core.*
import std.collection.concurrent.*
import soulsoft_extensions_options.*
import soulsoft_web_mvc.utilities.*
import soulsoft_web_mvc.modelBindings.*

/**
 * @brief 按类型信息创建模型绑定器。
 * @description 支持组合处理可空类型、数组类型和类类型，并缓存已解析结果。
 */
public class ModelBinderFactory <: IModelBinderFactory {
    private let _collection: ModelBinderCollection
    private let _cache: ConcurrentHashMap<String, IModelBinder> = ConcurrentHashMap<String, IModelBinder>()
    /// 哨兵值：表示"已解析但不支持该类型"，使 None 结果也能被缓存，避免重复解析
    private let _noOpBinder: IModelBinder = NoOpModelBinder()

    /**
     * @brief 创建模型绑定器工厂实例。
     * @param options MVC 选项访问器。
     */
    public init(options: IOptions<MvcOptions>) {
        _collection = options.value.modelBinders
    }

    /**
     * @brief 根据类型信息创建模型绑定器。
     * @param typeInfo 要解析的目标类型。
     * @return 匹配的模型绑定器；如果当前类型不支持绑定则返回 `None`。
     */
    public func createBinder(typeInfo: TypeInfo): ?IModelBinder {
        let result = _cache.entryView(typeInfo.qualifiedName) {
            view => if (view.value.isNone()) {
                view.value = Some(createBinderCore(typeInfo) ?? _noOpBinder)
            }
        }
        if (let Some(binder) <- result) {
            if (binder is NoOpModelBinder) {
                return None
            }
            return binder
        }
        return None
    }

    private func createBinderCore(typeInfo: TypeInfo): ?IModelBinder {
        // 注册表优先：允许注册特殊类型（如 ?IFormFile、Array<IFormFile>）覆盖默认结构化解析
        if (let Some(binder) <- _collection.find(typeInfo)) {
            return binder
        }

        // Option<T> → NullableModelBinder( createBinder(T) )
        if (let Some(innerTypeInfo) <- Nullable.getUnderlyingType(typeInfo)) {
            if (let Some(innerBinder) <- createBinder(innerTypeInfo)) {
                return NullableModelBinder(typeInfo, innerTypeInfo, innerBinder)
            }
            return None
        }

        // Array<T> → ArrayModelBinder<T>( createBinder(T) )
        if (let Some(elementTypeName) <- getArrayElementTypeName(typeInfo)) {
            try {
                let elementTypeInfo = TypeInfo.get(elementTypeName)
                if (let Some(elementBinder) <- createBinder(elementTypeInfo)) {
                    return ArrayModelBinderUtilities.buildArrayBinder(typeInfo, elementTypeInfo, elementBinder)
                }
            } catch (_: InfoNotFoundException) {}
            return None
        }

        // class 类型 → ComplexObjectModelBinder
        if (let classTypeInfo: ClassTypeInfo <- typeInfo) {
            return ComplexObjectModelBinder(classTypeInfo, this)
        }

        return None
    }

    // ── 私有辅助 ──────────────────────────────────────────────────────────────

    private func getArrayElementTypeName(typeInfo: TypeInfo): ?String {
        let name = typeInfo.qualifiedName
        if (name.startsWith("Array<") && name.endsWith(">")) {
            return name[6..name.size - 1]
        }
        return None
    }
}

/// 哨兵绑定器：仅用于在 _cache 中占位，表示该类型不可绑定，对外不可见
private class NoOpModelBinder <: IModelBinder {
    public func canBind(_: TypeInfo): Bool {
        false
    }
    public func bind(_: ModelBindingContext): Any {
        ()
    }
}
