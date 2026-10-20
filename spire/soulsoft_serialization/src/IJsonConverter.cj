/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization

/**
 * @brief 表示 JSON 转换器的标记接口。
 */
public interface IJsonConverter {}

internal func findLastConverter<T>(converters: Collection<IJsonConverter>): ?JsonConverter<T> {
    var result: ?JsonConverter<T> = None
    for (converter in converters) {
        if (let typedConverter: JsonConverter<T> <- converter) {
            result = typedConverter
        }
    }
    return result
}
