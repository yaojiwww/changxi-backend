/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores.default

import stdx.encoding.json.*
import soulsoft_extensions_caching.*
import stdx.serialization.serialization.*

/**
 * @brief 提供基于分布式缓存的序列化对象存储基类。
 */
public abstract class MemoryCacheBase<T> where T <: Serializable<T> {
    private let cache: IDistributedCache

    /**
     * @brief 创建缓存存储基类实例。
     * @param cache 底层使用的分布式缓存。
     */
    public init(cache: IDistributedCache) {
        this.cache = cache
    }

    /**
     * @brief 将指定对象写入缓存。
     * @param key 缓存键。
     * @param data 要写入缓存的数据。
     * @param expiration 缓存项的滑动过期时间。
     */
    public func storeItem(key: String, data: T, expiration: ?Duration): Unit {
        let json = data.serialize().toJson().toJsonString()
        let options = DistributedCacheEntryOptions(slidingExpiration: expiration)
        cache.setString(key, json, options)
    }

    /**
     * @brief 从缓存中读取指定键对应的对象。
     * @param key 缓存键。
     * @return 返回反序列化后的对象；如果缓存中不存在则返回 None。
     */
    public func getItem(key: String): ?T {
        if (let Some(json) <- cache.getString(key)) {
            let dm = DataModel.fromJson(JsonValue.fromStr(json))
            return T.deserialize(dm)
        }
        return None
    }

    /**
     * @brief 删除指定键对应的缓存项。
     * @param key 缓存键。
     */
    public func removeItem(key: String): Unit {
        cache.remove(key)
    }
}
