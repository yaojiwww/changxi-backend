
/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.utilities

import std.reflect.*
import std.collection.*

protected class ReflectUtilities {
    /**
     * 收集给定类型在最终可见视角下的 public 实例属性。
     *
     * 对 class 类型会沿继承链向上收集，并在子类 override 父类同名属性时，
     * 仅保留子类的最终实现；非 class 类型返回空数组。
     */
    public static func collectInstanceProperties(typeInfo: TypeInfo): Array<InstancePropertyInfo> {
        if (let classTypeInfo: ClassTypeInfo <- typeInfo) {
            let result = ArrayList<InstancePropertyInfo>(classTypeInfo.instanceProperties.size)
            collectInstanceProperties(classTypeInfo, result)
            return result.toArray()
        }
        return []
    }

    /**
     * 递归收集继承链上的 public 实例属性。
     *
     * 先处理父类，再处理当前类；如果当前类 override 了父类同名属性，
     * 则用当前类属性覆盖父类项，只保留最终可见的那一个。
     */
    private static func collectInstanceProperties(classTypeInfo: ClassTypeInfo, result: ArrayList<InstancePropertyInfo>): Unit {
        if (let Some(superClass) <- classTypeInfo.superClass && superClass != TypeInfo.of<Object>()) {
            if (let superClassTypeInfo: ClassTypeInfo <- superClass) {
                collectInstanceProperties(superClassTypeInfo, result)
            }
        }

        for (pattern in classTypeInfo.instanceProperties) {
            if (pattern.isAbstract()) {
                continue
            }
            addOrReplaceProperty(result, pattern)
        }
    }

    /**
     * 子类同名属性覆盖父类属性，避免 open/override 场景下重复收集。
     */
    private static func addOrReplaceProperty(result: ArrayList<InstancePropertyInfo>, propertyInfo: InstancePropertyInfo): Unit {
        for ((index, existingProperty) in result |> enumerate) {
            if (existingProperty.name == propertyInfo.name) {
                result[index] = propertyInfo
                return
            }
        }
        result.add(propertyInfo)
    }
}
