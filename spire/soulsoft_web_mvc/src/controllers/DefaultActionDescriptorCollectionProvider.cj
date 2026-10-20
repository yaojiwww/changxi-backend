// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.controllers

import std.sync.*
import std.reflect.*
import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_mvc.utilities.*
import soulsoft_web_mvc.applicationModels.*

/**
 * @brief 提供默认的控制器动作描述符集合。
 */
public class DefaultActionDescriptorCollectionProvider <: IActionDescriptorCollectionProvider {
    private let _lock = Mutex()
    private let _partManager: ApplicationPartManager
    private var _collection: ?ActionDescriptorCollection = None

    /**
     * @brief 创建默认动作描述符集合提供器实例。
     * @param partManager 应用程序部件管理器。
     */
    public init(partManager: ApplicationPartManager) {
        _partManager = partManager
    }

    /**
     * @brief 返回当前动作描述符集合。
     * @return 当前可用的动作描述符集合。
     */
    public prop actionDescriptors: ActionDescriptorCollection {
        get() {
            initialize()
        }
    }

    private func initialize() {
        if (let Some(collection) <- _collection) {
            return collection
        }
        synchronized(_lock) {
            if (let Some(collection) <- _collection) {
                return collection
            }
            return updateCollection()
        }
    }

    private func updateCollection() {
        let feature = ControllerFeature()
        _partManager.populateFeature(feature)
        let items = ArrayList<ControllerActionDescriptor>()
        for (controllerType in feature.controllers) {
            for (actionFunction in controllerType.instanceFunctions) {
                let descriptor = createActionDescriptor(controllerType, actionFunction)
                items.add(descriptor)
            }
        }
        _collection = ActionDescriptorCollection(items)
        return _collection.getOrThrow()
    }

    /**
     * @brief 为指定控制器动作创建描述符。
     * @param controllerType 控制器类型信息。
     * @param actionFunction 控制器动作函数信息。
     * @return 创建得到的控制器动作描述符。
     */
    public func createActionDescriptor(controllerType: TypeInfo, actionFunction: InstanceFunctionInfo): ControllerActionDescriptor {
        let actionName = actionFunction.name
        // 保持cangjie首字母小写的风格
        let controllerName = StringUtilities.lowerFirst(controllerType.name.removeSuffix("Controller"))
        var routeValues = RouteValueDictionary()
        routeValues.add("action", actionName)
        routeValues.add("controller", controllerName)
        let descriptor = ControllerActionDescriptor(actionName, controllerName, controllerType, actionFunction,
            routeValues)
        addEndpointMetadata(descriptor, controllerType.annotations)
        addEndpointMetadata(descriptor, actionFunction.annotations)
        return descriptor
    }

    private func addEndpointMetadata(descriptor: ControllerActionDescriptor, annotations: Collection<Object>) {
        for (annotation in annotations) {
            descriptor.endpointMetadata.add(annotation)
        }
    }
}
