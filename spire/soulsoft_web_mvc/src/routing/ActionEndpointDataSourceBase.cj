// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.routing

import std.sync.*
import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_routing.http.*
import soulsoft_web_mvc.controllers.*

/**
 * @brief 提供控制器动作端点数据源基类。
 */
public abstract class ActionEndpointDataSourceBase <: EndpointDataSource {
    private let _lock = Mutex()
    private var _endpoints: ?ReadOnlyList<Endpoint> = None
    private let _conventions = ArrayList<(EndpointBuilder) -> Unit>()
    private let _defaultBuilder: ControllerActionEndpointConventionBuilder
    private let _actionDescriptorCollectionProvider: IActionDescriptorCollectionProvider

    /**
     * @brief 创建一个控制器动作端点数据源基类实例。
     * @param actionDescriptorCollectionProvider 动作描述符集合提供器。
     */
    protected init(actionDescriptorCollectionProvider: IActionDescriptorCollectionProvider) {
        _defaultBuilder = ControllerActionEndpointConventionBuilder(_lock, _conventions)
        _actionDescriptorCollectionProvider = actionDescriptorCollectionProvider
    }

    /**
     * @brief 返回当前生成的端点集合。
     * @return 当前数据源中的端点列表。
     */
    public prop endpoints: ReadOnlyList<Endpoint> {
        get() {
            initialize()
            _endpoints.getOrThrow()
        }
    }

    /**
     * @brief 返回用于保护端点更新的互斥锁。
     * @return 当前数据源内部使用的互斥锁。
     */
    protected prop lock: Mutex {
        get() {
            _lock
        }
    }

    /**
     * @brief 返回默认的控制器动作端点约定构建器。
     * @return 当前数据源的默认端点约定构建器。
     */
    protected prop defaultBuilder: ControllerActionEndpointConventionBuilder {
        get() {
            _defaultBuilder
        }
    }

    private func initialize() {
        if (let Some(endpoints) <- _endpoints) {
            return endpoints
        }
        synchronized(_lock) {
            if (let Some(endpoints) <- _endpoints) {
                return endpoints
            }
            let actionDescriptors = _actionDescriptorCollectionProvider.actionDescriptors.items
            _endpoints = createEndpoints(actionDescriptors, _conventions)
            return _endpoints.getOrThrow()
        }
    }

    /**
     * @brief 根据动作描述符和约定生成端点集合。
     * @param actions 要转换的控制器动作描述符集合。
     * @param conventions 要应用的端点约定集合。
     * @return 生成得到的端点列表。
     */
    protected func createEndpoints(
        actions: ReadOnlyList<ControllerActionDescriptor>,
        conventions: ArrayList<(EndpointBuilder) -> Unit>
    ): ReadOnlyList<Endpoint>
}
