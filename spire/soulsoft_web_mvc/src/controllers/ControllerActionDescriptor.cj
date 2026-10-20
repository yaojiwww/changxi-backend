// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.controllers

import std.reflect.*
import std.collection.*
import soulsoft_web_http.*

/**
 * @brief 表示一个控制器动作的描述信息。
 */
public class ControllerActionDescriptor {
    private let _actionName: String
    private let _controllerName: String
    private let _controllerType: TypeInfo
    private let _actionFunction: InstanceFunctionInfo
    private let _routeValues: RouteValueDictionary
    private let _endpointMetadata = ArrayList<Any>()

    /**
     * @brief 创建控制器动作描述符实例。
     * @param actionName 动作名称。
     * @param controllerName 控制器名称。
     * @param controllerType 控制器类型信息。
     * @param actionFunction 动作函数信息。
     * @param routeValues 与动作关联的路由值集合。
     */
    public init(actionName: String, controllerName: String, controllerType: TypeInfo, actionFunction: InstanceFunctionInfo, routeValues: RouteValueDictionary) {
        _actionName = actionName
        _controllerName = controllerName
        _controllerType = controllerType
        _actionFunction = actionFunction
        _routeValues = routeValues
    }

    /**
     * @brief 返回动作关联的路由值集合。
     * @return 当前动作的路由值集合。
     */
    public prop routeValues: RouteValueDictionary {
        get() {
            _routeValues
        }
    }

    /**
     * @brief 返回动作名称。
     * @return 当前动作的名称。
     */
    public prop actionName: String {
        get() {
            _actionName
        }
    }

    /**
     * @brief 返回控制器名称。
     * @return 当前动作所属控制器的名称。
     */
    public prop controllerName: String {
        get() {
            _controllerName
        }
    }

    /**
     * @brief 返回控制器类型信息。
     * @return 当前动作所属控制器的类型信息。
     */
    public prop controllerType: TypeInfo {
        get() {
            _controllerType
        }
    }

    /**
     * @brief 返回动作函数信息。
     * @return 当前动作对应的实例函数信息。
     */
    public prop actionFunction: InstanceFunctionInfo {
        get() {
            _actionFunction
        }
    }

    /**
     * @brief 返回端点元数据集合。
     * @return 当前动作关联的端点元数据集合。
     */
    public prop endpointMetadata: List<Any> {
        get() {
            _endpointMetadata
        }
    }
}
