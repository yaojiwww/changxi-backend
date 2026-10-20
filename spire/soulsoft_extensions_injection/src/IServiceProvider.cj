// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

import std.reflect.*

/**
 * @brief 定义解析服务实例的能力。
 */
public interface IServiceProvider <: IServiceScopeFactory {
    /**
     * @brief 按运行时类型解析服务。
     * @param serviceType 要解析的服务类型。
     * @return 解析得到的服务实例；未注册时返回 `None`。
     */
    func get(serviceType: TypeInfo): ?Any

    /**
     * @brief 按服务键和运行时类型解析服务。
     * @param serviceKey 要解析的服务键。
     * @param serviceType 要解析的服务类型。
     * @return 解析得到的服务实例；未注册时返回 `None`。
     */
    func get(serviceKey: String, serviceType: TypeInfo): ?Any

    /**
     * @brief 按运行时类型解析服务，未注册时抛出异常。
     * @param serviceType 要解析的服务类型。
     * @return 解析得到的服务实例。
     * @throws UnsupportedException 当指定类型未注册时抛出。
     */
    func getOrThrow(serviceType: TypeInfo): Any {
        get(serviceType).getOrThrow {
            UnsupportedException("No service for type '${serviceType}' has been registered.")
        }
    }

    /**
     * @brief 按泛型类型解析服务。
     * @return 解析得到的服务实例；未注册时返回 `None`。
     */
    func get<T>(): ?T {
        return get(TypeInfo.of<T>()).flatMap {f => f as T}
    }

    /**
     * @brief 按服务键和泛型类型解析服务。
     * @param serviceKey 要解析的服务键。
     * @return 解析得到的服务实例；未注册时返回 `None`。
     */
    func get<T>(serviceKey: String): ?T {
        return get(serviceKey, TypeInfo.of<T>()).flatMap {f => f as T}
    }

    /**
     * @brief 按泛型类型解析服务，未注册时抛出异常。
     * @return 解析得到的服务实例。
     * @throws UnsupportedException 当指定类型未注册时抛出。
     */
    func getOrThrow<T>(): T {
        return get<T>().getOrThrow {
            UnsupportedException("No service for type '${TypeInfo.of<T>()}' has been registered.")
        }
    }

    /**
     * @brief 按服务键和泛型类型解析服务，未注册时抛出异常。
     * @param serviceKey 要解析的服务键。
     * @return 解析得到的服务实例。
     * @throws UnsupportedException 当指定键下的类型未注册时抛出。
     */
    func getOrThrow<T>(serviceKey: String): T {
        return get<T>(serviceKey).getOrThrow {
            UnsupportedException("No service for type '${TypeInfo.of<T>()}' has been registered.")
        }
    }

    /**
     * @brief 返回指定泛型类型的全部服务实现。
     * @return 指定类型对应的全部服务集合；未注册时返回空集合。
     */
    func getAll<T>(): Collection<T> {
        return get<Collection<T>>() ?? []
    }

    /**
     * @brief 返回指定服务键下的全部服务实现。
     * @param serviceKey 要解析的服务键。
     * @return 指定键下对应的全部服务集合；未注册时返回空集合。
     */
    func getAll<T>(serviceKey: String): Collection<T> {
        return get<Collection<T>>(serviceKey) ?? []
    }
}
