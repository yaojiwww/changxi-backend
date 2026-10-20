// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http.utilities

import std.io.*
import std.collection.*

/**
 * @brief 读取 multipart 内容并按分段返回结果。
 */
public class MultipartReader {
    private let _boundary: MultipartBoundary
    private let _stream: BufferedReadStream
    private static const DEFAULT_BUFFER_SIZE = 1024 * 4
    private var _currentStream: ?MultipartReaderStream = None
   
    /**
     * @brief 表示默认的头总长度限制。
     */
    public static const DEFAULT_HEADERS_LENGTH_LIMIT = 1024 * 16
    /**
     * @brief 表示默认的头数量限制。
     */
    public static const DEFAULT_HEADERS_COUNT_LIMIT = 16
    /**
     * @brief 获取或修改头总长度限制。
     */
    public var headersLengthLimit = DEFAULT_HEADERS_LENGTH_LIMIT
    /**
     * @brief 获取或修改头数量限制。
     */
    public var headersCountLimit = DEFAULT_HEADERS_COUNT_LIMIT
    /**
     * @brief 获取或修改分段正文长度限制。
     */
    public var bodyLengthLimit: ?Int64 = None

    /**
     * @brief 使用默认缓冲区大小创建 multipart 读取器。
     * @param boundary multipart 边界字符串。
     * @param stream 要读取的输入流。
     */
    public init(boundary: String, stream: InputStream) {
        this(boundary, stream, DEFAULT_BUFFER_SIZE)
    }

    /**
     * @brief 使用指定缓冲区大小创建 multipart 读取器。
     * @param boundary multipart 边界字符串。
     * @param stream 要读取的输入流。
     * @param bufferSize 读取缓冲区大小。
     * @throws IllegalArgumentException 当缓冲区长度不足以容纳边界时抛出。
     * @throws UnsupportedException 当输入流不支持定位时抛出。
     */
    public init(boundary: String, stream: InputStream, bufferSize: Int64) {
        // 去除边界两端的引号（兼容 Content-Type: multipart/form-data; boundary="foo"）
        let cleanBoundary = removeQuotes(boundary)
        if (bufferSize < cleanBoundary.size + 8) {
            // buffer 需要能容纳 boundary + 前后 CRLF + "--" 标记
            throw IllegalArgumentException(
                "Insufficient buffer space, the buffer must be larger than the boundary: " + cleanBoundary)
        }
        if (stream is Seekable) {
            _stream = BufferedReadStream(stream, bufferSize)
        } else {
            throw UnsupportedException()
        }
        _boundary = MultipartBoundary(cleanBoundary)
    }

    /**
     * @brief 读取下一个 multipart 分段。
     * @return 下一个分段；如果已经读取到最终边界则返回空。
     */
    public func readNextSection(): ?MultipartSection {
        // 首次调用时 _currentStream 为 None，创建消费 preamble 的 stream
        if (_currentStream.isNone()) {
            var s = MultipartReaderStream(_stream, _boundary)
            s.lengthLimit = Some(headersLengthLimit)
            _currentStream = s
        }

        // 排空上一个 stream 的剩余数据
        if (let Some(prev) <- _currentStream) {
            drainStream(prev)
            if (prev.finalBoundaryFound) {
                // 找到最终边界后，排空 stream 中可能的 trailer 数据
                drainBuffered(headersLengthLimit)
                return None
            }
        }

        // 后续 section 的边界前有 CRLF
        _boundary.expectLeadingCrlf()

        let headers = readHeaders()
        let baseStreamOffset: ?Int64 = Some(_stream.position)
        var section = MultipartReaderStream(_stream, _boundary)
        section.lengthLimit = bodyLengthLimit
        _currentStream = section
        return MultipartSection(section, headers, baseStreamOffset)
    }

    // 排空 MultipartReaderStream 中剩余未读数据
    private func drainStream(stream: MultipartReaderStream): Unit {
        let tmp = Array<Byte>(1024, repeat: 0)
        while (stream.read(tmp) > 0) {}
    }

    // 排空底层 BufferedReadStream 中最多 limit 字节（消费 trailer）
    private func drainBuffered(limit: Int64): Unit {
        let tmp = Array<Byte>(1024, repeat: 0)
        var remaining = limit
        while (remaining > 0) {
            let toRead = min(tmp.size, remaining)
            let read = _stream.read(tmp.slice(0, toRead))
            if (read == 0) {
                break
            }
            remaining -= read
        }
    }

    private func readHeaders(): HashMap<String, Array<String>> {
        let headers = HashMap<String, Array<String>>()
        var totalSize: Int64 = 0
        var keyCount: Int64 = 0

        var line = _stream.readLine(headersLengthLimit)
        while (!line.isEmpty()) {
            if (headersLengthLimit - totalSize < line.size) {
                throw IOException("Multipart headers length limit ${headersLengthLimit} exceeded.")
            }
            totalSize += line.size

            if (let Some(idx) <- line.indexOf(':')) {
                if (idx == 0) {
                    throw IOException("Invalid header line: ${line}")
                }
                let key = line[0..idx]
                let value = line[idx + 1..].trimAscii()
                if (!headers.contains(key)) {
                    keyCount++
                    if (keyCount > headersCountLimit) {
                        throw IOException("Multipart headers count limit ${headersCountLimit} exceeded.")
                    }
                    headers[key] = [value]
                } else if (let Some(existing) <- headers.get(key)) {
                    let list = ArrayList<String>(existing)
                    list.add(value)
                    headers[key] = list.toArray()
                }
            } else {
                throw IOException("Invalid header line: ${line}")
            }

            line = _stream.readLine(headersLengthLimit - totalSize)
        }
        return headers
    }

    // 去除首尾引号（兼容 boundary="xxx"）
    private static func removeQuotes(value: String): String {
        if (value.size >= 2 && value[0] == b'"' && value[value.size - 1] == b'"') {
            return value[1..value.size - 1]
        }
        return value
    }
}
