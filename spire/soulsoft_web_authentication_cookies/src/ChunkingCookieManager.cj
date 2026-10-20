// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_cookies

import std.time.*
import std.math.*
import std.convert.*
import std.collection.*
import soulsoft_web_http.*

/**
 * @brief 提供支持分块写入的 Cookie 管理器。
 */
public class ChunkingCookieManager <: ICookieManager {
    private static const DefaultChunkSize = 4050
    private static const ChunkKeySuffix = "C"
    private static const ChunkCountPrefix = "chunks-"

    /**
     * @brief 创建一个分块 Cookie 管理器。
     */
    public init() {
    }

    /**
     * @brief 指定单个 Cookie 分块的最大长度。
     */
    public var chunkSize: ?Int64 = DefaultChunkSize
    /**
     * @brief 指定遇到缺失分块时是否抛出异常。
     */
    public var throwForPartialCookies: Bool = false

    /**
     * @brief 从请求中读取指定 Cookie 值。
     * @param context 当前 HTTP 上下文。
     * @param key Cookie 名称。
     * @return Cookie 值；不存在时返回 None。
     * @throws IllegalFormatException 当分块 Cookie 不完整且启用严格检查时抛出。
     */
    public func getRequestCookie(context: HttpContext, key: String): ?String {
        let requestCookies = context.request.cookies
        let value = requestCookies.get(key)
        let chunksCount = parseChunksCount(requestCookies.get(key))
        if (chunksCount > 0) {
            let chunks = ArrayList<String>(10)
            for (chunkId in 1..chunksCount + 1) {
                let chunk = requestCookies.get('${key}${ChunkKeySuffix}${chunkId}') ?? String.empty
                if (chunk.isEmpty()) {
                    if (throwForPartialCookies) {
                        var totalSize = 0
                        for (i in 0..chunkId - 1) {
                            totalSize += chunks[i].size
                        }
                        throw IllegalFormatException(
                            "The chunked cookie is incomplete. Only ${chunkId - 1} of the expected ${chunksCount} chunks were found, totaling ${totalSize} characters. A client size limit may have been exceeded.")
                    }
                    return value
                }
                chunks.add(chunk)
            }

            return String.join(chunks.toArray(), delimiter: String.empty)
        }

        return value
    }

    /**
     * @brief 向响应写入指定 Cookie 值。
     * @param context 当前 HTTP 上下文。
     * @param key Cookie 名称。
     * @param value Cookie 值。
     * @param options Cookie 选项。
     * @throws UnsupportedException 当分块大小不足以容纳数据时抛出。
     */
    public func appendResponseCookie(context: HttpContext, key: String, value: ?String, options: CookieOptions): Unit {
        let responseCookies = context.response.cookies
        let cookieValue = value ?? String.empty
        if (cookieValue.isEmpty()) {
            responseCookies.append(key, String.empty, options)
            return
        }

        let templateLength = options.createCookieHeaderValue(key, String.empty).size
        let requestCookies = context.request.cookies
        let requestCookie = requestCookies.get(key)
        let requestChunks = parseChunksCount(requestCookie)

        // Normal cookie
        if (chunkSize.isNone() || chunkSize.flatMap {f => f > templateLength + cookieValue.size} == true) {
            if (requestChunks > 0) {
                deleteChunks(context, requestCookies, options, key, 1, requestChunks)
            }

            responseCookies.append(key, cookieValue, options)
        } else if (let Some(chunkSize) <- chunkSize && chunkSize < templateLength + 10) {
            throw UnsupportedException(
                "The cookie key and options are larger than ChunksSize, leaving no room for data.");
        } else if (let Some(chunkSize) <- chunkSize) {
            let dataSizePerCookie = chunkSize - templateLength - 3
            var cookieChunkCount = Int64(ceil(Float64(cookieValue.size) * 1.0 / Float64(dataSizePerCookie)))

            if (requestChunks > cookieChunkCount) {
                // If the cookie was previously chunked but is now smaller, delete the chunks.
                deleteChunks(context, requestCookies, options, key, cookieChunkCount + 1, requestChunks);
            }
            let keyValuePairs = Array<(String, String)>(cookieChunkCount + 1, repeat: (String.empty, String.empty))
            keyValuePairs[0] = (key, '${ChunkCountPrefix}${cookieChunkCount}')

            var offset = 0
            for (chunkId in 1..cookieChunkCount + 1) {
                let remainingLength = cookieValue.size - offset
                let length = min(dataSizePerCookie, remainingLength)
                let segment = cookieValue[offset..offset + length]
                offset += length
                keyValuePairs[chunkId] = ("${key}${ChunkKeySuffix}${chunkId}", segment)
            }

            responseCookies.append(keyValuePairs, options)
        }
    }

    /**
     * @brief 从响应中删除指定 Cookie。
     * @param context 当前 HTTP 上下文。
     * @param key Cookie 名称。
     * @param options Cookie 选项。
     */
    public func deleteCookie(context: HttpContext, key: String, options: CookieOptions): Unit {
        let keys = ArrayList<String>([key + '='])

        let requestCookies = context.request.cookies
        let requestCookie = requestCookies.get(key)
        var chunks = parseChunksCount(requestCookie)

        if (chunks > 0) {
            for (i in 1..chunks + 2) {
                let subkey = key + ChunkKeySuffix + i.toString()
                let subValue = requestCookies.get(subkey) ?? String.empty
                if (subValue.isEmpty()) {
                    chunks = i - 1
                    break
                }
                keys.add(subkey + '=')
            }
        }
        let predicate: (String) -> Bool = {
            value => keys |> any {k => value.toAsciiLower().startsWith(k.toAsciiLower())}
        }
        let rejectPredicate: (String) -> Bool = if (let Some(domain) <- options.domain && !domain.isEmpty()) {
            {
                value => predicate(value) && value.toAsciiLower().contains("domain=${options.domain}".toAsciiLower())
            }
        } else if (let Some(path) <- options.path && !path.isEmpty()) {
            {
                value => predicate(value) && value.toAsciiLower().contains("path=${options.path}".toAsciiLower())
            }
        } else {
            {value => predicate(value)}
        }
        let responseHeaders = context.response.headers
        var existingValues = responseHeaders.setCookie
        if (existingValues.size > 0 && !existingValues[0].isEmpty()) {
            let values = existingValues
            var newValues = ArrayList<String>()
            for (i in 0..values.size) {
                let value = values[i]
                if (!rejectPredicate(value)) {
                    newValues.add(value)
                }
            }
            responseHeaders.setCookie = newValues.toArray()
        }

        let responseCookies = context.response.cookies
        let keyValuePairs = Array<(String, String)>(chunks + 1, repeat: (String.empty, String.empty))
        keyValuePairs[0] = (key, String.empty)

        for (i in 1..chunks + 1) {
            keyValuePairs[i] = ('${key}C${i}', String.empty)
        }

        let newOptions = CookieOptions(options)
        newOptions.expires = DateTime.ofUTC(year: 1970, month: 1, dayOfMonth: 1)
        newOptions.maxAge = None
        responseCookies.append(keyValuePairs, newOptions)
    }

    private func deleteChunks(context: HttpContext, requestCookies: IRequestCookieCollection, options: CookieOptions,
        key: String, startChunk: Int64, endChunk: Int64) {
        let keyValuePairs = ArrayList<(String, String)>()
        for (i in startChunk..endChunk + 1) {
            let subkey = key + ChunkKeySuffix + i.toString()
            let subValue = requestCookies.get("subkey") ?? String.empty
            if (subValue.isEmpty()) {
                break
            }
            keyValuePairs.add((subkey, String.empty))
        }

        if (keyValuePairs.size > 0) {
            let newOptions = CookieOptions(options)
            newOptions.expires = DateTime.ofUTC(year: 1970, month: 1, dayOfMonth: 1)
            newOptions.maxAge = None
            context.response.cookies.append(keyValuePairs.toArray(), CookieOptions(options))
        }
    }

    private func parseChunksCount(value: ?String) {
        if (let Some(data) <- value && data.startsWith(ChunkCountPrefix) && let Some(chunksCount) <- Int64.tryParse(
            data[ChunkCountPrefix.size..])) {
            return chunksCount
        }
        return 0
    }
}
