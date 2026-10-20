/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization.annotations

/**
 * @brief 标记用于承载未知 JSON 字段的扩展数据字段。
 */
@Annotation[target: [MemberVariable, MemberProperty]]
public class JsonExtensionData {
    public const init() {}
}
