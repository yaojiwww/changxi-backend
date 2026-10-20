// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http.utilities

import std.io.*
import std.unicode.*

/**
 * @brief 表示边界感知的 multipart 分段流。
 * @description 读取到分段边界时会自动停止，对应 ASP.NET Core 的 MultipartReaderStream。
 */
public class MultipartReaderStream <: InputStream & Seekable {
    // 边界行尾（"--" 或空行）的最大读取字节数，RFC 2046 中行尾仅含可选空白和 "--"，100 字节绰绰有余
    private static const BOUNDARY_SUFFIX_MAX_LENGTH: Int64 = 100

    private let _innerStream: BufferedReadStream
    private let _boundary: MultipartBoundary
    private let _innerOffset: Int64 // section 在底层流中的起始偏移
    private var _position: Int64 = 0 // 在本 section 内的读取位置
    private var _observedLength: Int64 = 0 // 已观测到的 section 长度
    private var _finished: Bool = false // 是否已到达边界
    private var _finalBoundaryFound: Bool = false // 是否找到了最终边界（"--"结尾）

    /**
     * @brief 获取或修改分段长度限制。
     */
    public var lengthLimit: ?Int64 = None

    /**
     * @brief 创建 multipart 分段流实例。
     * @param stream 底层缓冲读取流。
     * @param boundary 分段边界信息。
     */
    public init(stream: BufferedReadStream, boundary: MultipartBoundary) {
        _innerStream = stream
        _boundary = boundary
        _innerOffset = stream.position
    }

    /**
     * @brief 检查是否检测到最终边界。
     * @return 如果检测到最终边界则返回 true，否则返回 false。
     */
    public prop finalBoundaryFound: Bool {
        get() {
            _finalBoundaryFound
        }
    }

    /**
     * @brief 返回当前已观测到的分段长度。
     * @return 当前已观测到的分段长度。
     */
    public prop length: Int64 {
        get() {
            _observedLength
        }
    }

    /**
     * @brief 返回当前读取位置。
     * @return 当前读取位置。
     */
    public prop position: Int64 {
        get() {
            _position
        }
    }

    /**
     * @brief 返回当前剩余可读长度。
     * @return 当前剩余可读长度。
     */
    public prop remainLength: Int64 {
        get() {
            _observedLength - _position
        }
    }

    /**
     * @brief 调整当前分段流位置。
     * @param pos 目标位置描述。
     * @return 调整后的分段内位置。
     * @throws IOException 当目标位置非法时抛出。
     */
    public func seek(pos: SeekPosition): Int64 {
        let offset = match (pos) {
            case SeekPosition.Begin(v) => v
            case SeekPosition.Current(v) => _position + v
            case SeekPosition.End(v) => _observedLength + v
        }
        if (offset < 0) {
            throw IOException("The Position must be positive.")
        }
        if (offset > _observedLength) {
            throw IOException("The Position must be less than length.")
        }
        _position = offset
        if (_position < _observedLength) {
            _finished = false
        }
        return _position
    }

    /**
     * @brief 从当前分段读取数据。
     * @param buffer 用于接收数据的缓冲区。
     * @return 实际读取的字节数。
     * @throws IOException 当流意外结束或超出长度限制时抛出。
     */
    public func read(buffer: Array<Byte>): Int64 {
        if (_finished) {
            return 0
        }

        // 将底层流定位到本 section 当前读取位置
        positionInnerStream()

        let boundaryBytes = _boundary.boundaryBytes
        // 确保缓冲区中至少有 finalBoundaryLength 字节（用于边界检测）
        if (!_innerStream.ensureBuffered(_boundary.finalBoundaryLength)) {
            throw IOException("Unexpected end of Stream, the content may have already been read by another component.")
        }

        let (bufData, bufOffset, bufCount) = _innerStream.bufferedData

        // 在缓冲区中搜索完整边界
        if (let Some(index) <- bufData.indexOf(boundaryBytes, bufOffset)) {
            let relIndex = index - bufOffset
            if (relIndex > 0) {
                // 边界前还有数据，先返回这部分
                let toRead = min(buffer.size, relIndex)
                let read = _innerStream.read(buffer.slice(0, toRead))
                return updatePosition(read)
            } else {
                // 缓冲区起始就是边界，消费边界并结束
                return consumeBoundary(boundaryBytes.size)
            }
        }

        // 搜索部分边界匹配（边界跨越缓冲区末尾）
        let (matchOffset, matchCount) = subMatch(bufData, bufOffset, bufCount, boundaryBytes)
        if (matchCount > 0) {
            let dataBeforeMatch = matchOffset - bufOffset
            if (dataBeforeMatch > 0) {
                // 返回匹配前的数据
                let toRead = min(buffer.size, dataBeforeMatch)
                let read = _innerStream.read(buffer.slice(0, toRead))
                return updatePosition(read)
            } else {
                return consumeBoundary(boundaryBytes.size)
            }
        }

        // 缓冲区内无边界，直接返回缓冲数据
        let toRead = min(buffer.size, bufCount)
        let read = _innerStream.read(buffer.slice(0, toRead))
        return updatePosition(read)
    }

    // 将底层流定位到本 section 的当前读取位置
    private func positionInnerStream(): Unit {
        let expected = _innerOffset + _position
        if (_innerStream.position != expected) {
            _innerStream.seek(SeekPosition.Begin(expected))
        }
    }

    // 更新已观测长度并返回读取字节数；检查 LengthLimit
    private func updatePosition(read: Int64): Int64 {
        _position += read
        if (_observedLength < _position) {
            _observedLength = _position
            if (let Some(limit) <- lengthLimit) {
                if (_observedLength > limit) {
                    if (_boundary.beforeFirstBoundary()) {
                        throw IOException(
                            "Multipart header length limit ${limit} exceeded. Too much data before the first boundary.")
                    } else {
                        throw IOException("Multipart body length limit ${limit} exceeded.")
                    }
                }
            }
        }
        return read
    }

    // 消费边界字节，读取边界后的行尾（"--" 或空），标记 finished
    private func consumeBoundary(boundaryLen: Int64): Int64 {
        let tmp = Array<Byte>(boundaryLen, repeat: 0)
        _innerStream.read(tmp) // 消费边界本身

        // 读取边界行尾（可能是 "--" 表示最终边界，或空行）
        let remainder = _innerStream.readLine(BOUNDARY_SUFFIX_MAX_LENGTH).trim()
        if (remainder == "--") {
            _finalBoundaryFound = true
        }
        _finished = true
        return 0
    }

    /**
     * 检测缓冲区末尾是否存在 matchBytes 的前缀（跨缓冲区部分匹配）。
     * 对应 ASP.NET Core SubMatch 算法。
     *
     * 返回 (matchOffset, matchCount)：
     *   matchOffset - 匹配起始位置（在 bufData 中的绝对索引）
     *   matchCount  - 匹配的字节数（> 0 表示找到部分匹配）
     */
    private static func subMatch(
        bufData: Array<Byte>,
        bufOffset: Int64,
        bufCount: Int64,
        matchBytes: Array<Byte>
    ): (Int64, Int64) {
        // 只需检查末尾 matchBytes.size 个字节
        var matchOffset = max(bufOffset, bufOffset + bufCount - matchBytes.size)
        let segEnd = bufOffset + bufCount
        var matchCount: Int64 = 0

        while (matchOffset < segEnd) {
            let countLimit = segEnd - matchOffset
            matchCount = 0
            var i: Int64 = 0
            while (i < matchBytes.size && i < countLimit) {
                if (matchBytes[i] != bufData[matchOffset + i]) {
                    matchCount = 0
                    break
                }
                i++
                matchCount = i
            }
            if (matchCount > 0) {
                break
            }
            matchOffset++
        }

        return (matchOffset, matchCount)
    }
}
