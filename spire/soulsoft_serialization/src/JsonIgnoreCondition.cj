/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization

/**
 * @brief 指定序列化时忽略字段的条件。
 */
public enum JsonIgnoreCondition {
    /**
     * @brief 从不忽略字段。
     */
    Never
    /**
     * @brief 在字段值为 null 时忽略写出。
     */
    | WhenWritingNull
}
