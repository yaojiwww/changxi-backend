// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.reflect.*
import std.collection.*

/**
 * @brief 表示端点元数据的只读集合。
 */
public class EndpointMetadataCollection <: ReadOnlyList<Any> {
    private let _metadata = ArrayList<Any>()
    private static let _empty = EndpointMetadataCollection()

    /**
     * @brief 创建一个空的端点元数据集合。
     */
    public init() {
    }

    /**
     * @brief 使用指定元数据集合创建端点元数据集合。
     * @param metadata 初始元数据集合。
     */
    public init(metadata: Collection<Any>) {
        _metadata.add(all: metadata)
    }

    /**
     * @brief 返回元数据数量。
     * @return 当前元数据数量。
     */
    public prop size: Int64 {
        get() {
            _metadata.size
        }
    }

    /**
     * @brief 返回第一个元数据项。
     * @return 第一个元数据项；如果集合为空则返回空。
     */
    public prop first: ?Any {
        get() {
            _metadata.first
        }
    }

    /**
     * @brief 返回最后一个元数据项。
     * @return 最后一个元数据项；如果集合为空则返回空。
     */
    public prop last: ?Any {
        get() {
            _metadata.last
        }
    }

    /**
     * @brief 返回空的端点元数据集合实例。
     * @return 空的端点元数据集合实例。
     */
    public static prop empty: EndpointMetadataCollection {
        get() {
            _empty
        }
    }

    /**
     * @brief 获取指定索引处的元数据项。
     * @param index 元数据索引。
     * @return 指定索引处的元数据项；如果越界则返回空。
     */
    public func get(index: Int64): ?Any {
        return _metadata.get(index)
    }

    /**
     * @brief 获取指定索引处的元数据项。
     * @param index 元数据索引。
     * @return 指定索引处的元数据项。
     */
    public operator func [](index: Int64): Any {
        _metadata[index]
    }

    /**
     * @brief 返回元数据集合的迭代器。
     * @return 当前元数据集合的迭代器。
     */
    public func iterator(): Iterator<Any> {
        _metadata.iterator()
    }

    /**
     * @brief 检查元数据集合是否为空。
     * @return 如果元数据集合为空则返回 true，否则返回 false。
     */
    public func isEmpty(): Bool {
        _metadata.isEmpty()
    }

    /**
     * @brief 获取指定类型的最后一个元数据项。
     * @return 匹配类型的最后一个元数据项；如果不存在则返回空。
     */
    public func getMetadata<T>(): ?T {
        return getOrderedMetadata<T>().last
    }

    /**
     * @brief 获取指定类型的所有元数据项。
     * @return 匹配类型的所有元数据项列表。
     */
    public func getOrderedMetadata<T>(): ReadOnlyList<T> {
        _metadata |> filterMap {f => f as T} |> collectArrayList
    }

    /**
     * @brief 获取指定类型的必需元数据项。
     * @return 匹配类型的元数据项。
     * @throws NoneValueException 当不存在指定类型的元数据项时抛出。
     */
    public func getRequiredMetadata<T>(): T {
        if (let Some(metadata) <- getMetadata<T>()) {
            return metadata
        }
        throw NoneValueException("No metadata of type ${TypeInfo.of<T>()} found in the collection.")
    }
}
