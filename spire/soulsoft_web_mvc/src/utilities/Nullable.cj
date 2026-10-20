/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_mvc.utilities

import std.reflect.*

/*
Option类型操作
 */
protected class Nullable {
    /*
    如果一个类型是Option<T>那么返回T的类型信息，否则返回None
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
