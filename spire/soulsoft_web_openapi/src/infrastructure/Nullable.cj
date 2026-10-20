/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_openapi.infrastructure

import std.reflect.*

/*
Option类型操作
 */
protected class Nullable {
    /**
     * @brief 返回 Option 类型的底层类型。
     * @param typeInfo 要解析的类型信息。
     * @return 如果是 Option 类型则返回其底层类型，否则返回 `None`。
     */
    public static func getUnderlyingType(typeInfo: TypeInfo): ?TypeInfo {
        let qualifiedName = typeInfo.qualifiedName
        if (!(qualifiedName.startsWith("Option<") && qualifiedName.endsWith('>'))) {
            return None
        }
        let underlyingTypeName = qualifiedName[7..qualifiedName.size - 1]
        return TypeInfo.get(underlyingTypeName)
    }
}
