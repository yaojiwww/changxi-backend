/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import std.reflect.*
import std.collection.*

/**
 * 反射辅助工具。
 */
protected class ReflectUtilities {
    private init() {}

    /**
     * 获取类型的所有 public 实例字段，包含继承链上的字段。
     */
    public static func getAllInstanceVariables(typeInfo: TypeInfo): Array<InstanceVariableInfo> {
        if (let classTypeInfo: ClassTypeInfo <- typeInfo) {
            let result = ArrayList<InstanceVariableInfo>(classTypeInfo.instanceVariables.size)
            collectInstanceVariables(classTypeInfo, result)
            return result.toArray()
        }
        return []
    }

    private static func collectInstanceVariables(
        classTypeInfo: ClassTypeInfo,
        result: ArrayList<InstanceVariableInfo>
    ): Unit {
        if (let Some(superClass) <- classTypeInfo.superClass) {
            collectInstanceVariables(superClass, result)
        }

        for (variable in classTypeInfo.instanceVariables) {
            replaceOrAdd(result, variable)
        }
    }

    private static func replaceOrAdd(result: ArrayList<InstanceVariableInfo>, variable: InstanceVariableInfo): Unit {
        for ((index, existing) in result |> enumerate) {
            if (existing.name == variable.name) {
                result[index] = variable
                return
            }
        }
        result.add(variable)
    }
}
