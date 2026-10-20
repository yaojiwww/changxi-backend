/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_mediator

import std.reflect.*
import soulsoft_extensions_injection.*

/**
 * @brief 提供中介者相关服务的注册构建器。
 */
public class MediatorBuilder {
    private let _services: ServiceCollection

    init(services: ServiceCollection) {
        _services = services
    }

    /**
     * @brief 注册一个请求处理管道行为。
     * @return 当前构建器实例。
     */
    public func addPipelineHandler<T>(): MediatorBuilder where T <: IPipelineHandler & Object {
        _services.addScoped<IPipelineHandler, T>()
        return this
    }

    /**
     * @brief 按包反射注册请求处理器和通知处理器。
     * @param packageInfo 要扫描的包信息。
     * @return 当前构建器实例。
     */
    public func registerServices(packageInfo: PackageInfo): MediatorBuilder {
        for (pattern in packageInfo.typeInfos) {
            if (!(pattern is ClassTypeInfo)) {
                continue
            }
            if (let Some(typeInfo) <- getRequestHandlerServiceType(pattern)) {
                _services.addTransient(typeInfo, pattern)
            } else if (let Some(typeInfo) <- getNotificationHandlerServiceType(pattern)) {
                _services.addTransient(typeInfo, pattern)
            }
        }
        return this
    }

    private func findSuperInterface(typeInfo: TypeInfo, qualifiedPrefix: String): ?TypeInfo {
        for (pattern in typeInfo.superInterfaces) {
            if (pattern.qualifiedName.startsWith(qualifiedPrefix)) {
                return pattern
            }
        }
        return None
    }

    private func getRequestHandlerServiceType(typeInfo: TypeInfo): ?TypeInfo {
        findSuperInterface(typeInfo, "soulsoft_mediator.IRequestHandler")
    }

    private func getNotificationHandlerServiceType(typeInfo: TypeInfo): ?TypeInfo {
        findSuperInterface(typeInfo, "soulsoft_mediator.INotificationHandler")
    }
}
