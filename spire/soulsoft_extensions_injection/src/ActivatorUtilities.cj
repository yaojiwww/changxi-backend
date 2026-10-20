// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_injection

import std.sort.*
import std.reflect.*
import std.collection.*

/**
 * @brief 提供为未注册类型创建实例的辅助方法。
 */
public class ActivatorUtilities {
    private init() {
    }

    /**
     * @brief 使用服务提供者和显式参数创建指定泛型类型的实例。
     * @param provider 用于解析剩余依赖的服务提供者。
     * @param parameters 用于优先匹配构造函数参数的显式参数列表。
     * @return 创建得到的实例。
     * @throws UnsupportedException 当目标类型不可实例化或找不到合适构造函数时抛出。
     */
    public static func createInstance<T>(provider: IServiceProvider, parameters: Array<Any>): T {
        let instance = createInstance(provider, TypeInfo.of<T>(), parameters) as T
        return instance.getOrThrow()
    }

    /**
     * @brief 使用服务提供者和显式参数创建指定运行时类型的实例。
     * @param provider 用于解析剩余依赖的服务提供者。
     * @param serviceType 要创建的具体服务类型。
     * @param parameters 用于优先匹配构造函数参数的显式参数列表。
     * @return 创建得到的对象实例。
     * @throws UnsupportedException 当目标类型是抽象类型或找不到合适构造函数时抛出。
     */
    public static func createInstance(provider: IServiceProvider, serviceType: TypeInfo, parameters: Array<Any>): Object {
        if (!(serviceType is ClassTypeInfo) || (serviceType as ClassTypeInfo).flatMap {f => f.isAbstract()} == true) {
            throw UnsupportedException("Instances of abstract classes cannot be created.")
        }

        let callSiteFactory = provider.getOrThrow<IServiceProviderIsService>()
        let matcher = ConstructorMatcher(serviceType, callSiteFactory, parameters)

        if (let Some(constructor) <- matcher.find()) {
            return matcher.createInstance(provider, constructor)
        }

        throw UnsupportedException(
            "A suitable constructor for type '${serviceType}' could not be located. Ensure the type is concrete and all parameters of a public constructor are either registered as services or passed as arguments. Also ensure no extraneous arguments are provided.")
    }
}

private struct ConstructorMatcher {
    private let parameterValueTypes: Array<TypeInfo>
    ConstructorMatcher(let typeInfo: TypeInfo, let callSiteFactory: IServiceProviderIsService,
        let parameterValues: Array<Any>) {
        parameterValueTypes = parameterValues |> map {f => TypeInfo.of(f)} |> collectArray
    }

    public func createInstance(provider: IServiceProvider, constructor: ConstructorInfo): Object {
        let parameters = constructor.parameters
        let args = Array<Any>(parameters.size, repeat: 0)
        var parameterValueIndex = 0
        for ((index, parameterInfo) in parameters |> enumerate) {
            // 用户传入参数优先
            if (parameterValueIndex < parameterValues.size && parameterValueTypes[parameterValueIndex].isSubtypeOf(
                parameterInfo.typeInfo)) {
                args[index] = parameterValues[parameterValueIndex]
                parameterValueIndex++
            } else {
                args[index] = provider.getOrThrow(parameterInfo.typeInfo)
            }
        }

        return (constructor.apply(args) as Object).getOrThrow()
    }

    public func find(): ?ConstructorInfo {
        var bestConstructor: ?ConstructorInfo = None
        if (let classTypeInfo: ClassTypeInfo <- typeInfo) {
            let constructors = classTypeInfo.constructors.toArray()
            sort(constructors, key: {a => a.parameters.size}, descending: true)
            for (constructor in constructors) {
                if (isMatch(constructor, parameterValueTypes)) {
                    if (let Some(best) <- bestConstructor) {
                        // 参数数量相同才是真正的歧义，参数更少的直接跳过
                        if (constructor.parameters.size == best.parameters.size) {
                            throw UnsupportedException(
                                "Multiple constructors accepting all given argument types have been found in type '${typeInfo}'. There should only be one applicable constructor.")
                        }
                    } else {
                        bestConstructor = constructor
                    }
                }
            }
        }

        return bestConstructor
    }

    /*
    判断构造器是否匹配
    1. 参数必须是服务类型，或者和用户输入的类型匹配
    2. 必须和用户输入的参数数量匹配
     */
    private func isMatch(constructor: ConstructorInfo, parameterTypes: Array<TypeInfo>) {
        var parameterTypeMatchCount = 0
        for (parameter in constructor.parameters) {
            let isService = callSiteFactory.isService(parameter.typeInfo)
            let isSubtype = parameterTypes |> any {f => f.isSubtypeOf(parameter.typeInfo)}
            if (!(isService || isSubtype)) {
                return false
            }
            if (!isService || isSubtype) {
                parameterTypeMatchCount++
            }
        }
        return parameterTypeMatchCount == parameterTypes.size
    }
}
