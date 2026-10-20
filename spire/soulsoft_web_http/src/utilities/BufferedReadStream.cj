// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http.utilities

import std.io.*
import std.sync.*

/**
 * @brief 表示支持缓冲读取的输入流。
 * @description 提供行读取和缓冲区预读能力，对应 ASP.NET Core 的 BufferedReadStream。
 */
public class BufferedReadStream <: InputStream & Seekable {
    static const CR: Byte = b'\r'
    static const LF: Byte = b'\n'

    private let _stream: InputStream
    private let _bufferData: Array<Byte>
    private var _bufferOffset: Int64 = 0
    private var _bufferCount: Int64 = 0
    private let _length: Int64

    /**
     * @brief 使用默认缓冲区大小创建实例。
     * @param stream 要包装的输入流。
     */
    public init(stream: InputStream) {
        this(stream, 1024 * 4)
    }

    /**
     * @brief 使用指定缓冲区大小创建实例。
     * @param stream 要包装的输入流。
     * @param bufferSize 缓冲区大小。
     * @throws UnsupportedException 当输入流不支持定位时抛出。
     */
    public init(stream: InputStream, bufferSize: Int64) {
        _stream = stream
        _bufferData = Array<Byte>(bufferSize, repeat: 0)
        if (let seekable: Seekable <- _stream) {
            _length = seekable.length
        } else {
            throw UnsupportedException()
        }
    }

    /**
     * @brief 返回底层流长度。
     * @return 底层流总长度。
     */
    public prop length: Int64 {
        get() {
            _length
        }
    }

    /**
     * @brief 返回当前读取位置。
     * @return 当前读取位置。
     */
    public prop position: Int64 {
        get() {
            // 底层流位置减去缓冲中未消费的字节数
            if (let seekable: Seekable <- _stream) {
                seekable.position - _bufferCount
            } else {
                0
            }
        }
    }

    /**
     * @brief 返回剩余可读长度。
     * @return 剩余可读长度。
     */
    public prop remainLength: Int64 {
        get() {
            _length - position
        }
    }

    /**
     * @brief 返回当前缓冲区视图。
     * @return 缓冲区数据、偏移量和剩余字节数。
     */
    public prop bufferedData: (Array<Byte>, Int64, Int64) {
        get() {
            (_bufferData, _bufferOffset, _bufferCount)
        }
    }

    /**
     * @brief 调整当前流位置。
     * @param pos 目标位置描述。
     * @return 调整后的绝对位置。
     * @throws IOException 当目标位置超出流范围时抛出。
     */
    public func seek(pos: SeekPosition): Int64 {
        let offset = match (pos) {
            case SeekPosition.Begin(v) => v
            case SeekPosition.Current(v) => position + v
            case SeekPosition.End(v) => _length + v
        }
        if (offset < 0) {
            throw IOException("Can't move the position before the beginning of the stream.")
        }
        if (offset > _length) {
            throw IOException("Can't move the position after the end of the stream.")
        }
        // 尝试在缓冲区内调整，避免底层 seek
        let innerPos = if (let seekable: Seekable <- _stream) {
            seekable.position
        } else {
            0
        }
        let bufStart = innerPos - _bufferCount
        if (offset >= bufStart && offset <= innerPos) {
            // 目标在缓冲区范围内，直接调整偏移
            let delta = offset - bufStart
            _bufferOffset = delta
            _bufferCount = innerPos - offset
        } else {
            // 超出缓冲区，丢弃缓冲并 seek 底层流
            _bufferOffset = 0
            _bufferCount = 0
            if (let seekable: Seekable <- _stream) {
                seekable.seek(SeekPosition.Begin(offset))
            }
        }
        return offset
    }

    /**
     * @brief 读取数据到指定缓冲区。
     * @param buffer 用于接收数据的缓冲区。
     * @return 实际读取的字节数。
     */
    public func read(buffer: Array<Byte>): Int64 {
        if (_bufferCount > 0) {
            let len = min(buffer.size, _bufferCount)
            _bufferData.copyTo(buffer, _bufferOffset, 0, len)
            _bufferOffset += len
            _bufferCount -= len
            return len
        }
        return _stream.read(buffer)
    }

    /**
     * @brief 确保缓冲区中至少有指定数量的字节可用。
     * @param minCount 最少需要保留的字节数。
     * @return 如果成功缓冲到足够数据则返回 true；流已结束时返回 false。
     * @throws IllegalArgumentException 当请求的字节数超过缓冲区大小时抛出。
     */
    public func ensureBuffered(minCount: Int64): Bool {
        if (minCount > _bufferData.size) {
            throw IllegalArgumentException("minCount(${minCount}) must be <= bufferSize(${_bufferData.size})")
        }
        while (_bufferCount < minCount) {
            // 下移已有数据到缓冲区头部，腾出尾部空间
            if (_bufferOffset > 0 && _bufferCount > 0) {
                _bufferData.copyTo(_bufferData, _bufferOffset, 0, _bufferCount)
            }
            _bufferOffset = 0
            let readBuf = _bufferData.slice(_bufferCount, _bufferData.size - _bufferCount)
            let read = _stream.read(readBuf)
            _bufferCount += read
            if (read == 0) {
                return false
            }
        }
        return true
    }

    /**
     * @brief 确保缓冲区非空。
     * @return 如果缓冲区中存在可读数据则返回 true；流已结束时返回 false。
     */
    public func ensureBuffered(): Bool {
        if (_bufferCount > 0) {
            return true
        }
        _bufferOffset = 0
        _bufferCount = _stream.read(_bufferData)
        return _bufferCount > 0
    }

    /**
     * @brief 读取一行文本。
     * @param lengthLimit 行长度上限。
     * @return 不包含结尾 CRLF 的行字符串。
     * @throws IOException 当行长度超过限制时抛出。
     */
    public func readLine(lengthLimit: Int64): String {
        let builder = ByteBuffer(200)
        var foundCR = false
        var foundCRLF = false

        while (!foundCRLF && ensureBuffered()) {
            var writeCount: Int64 = 0
            while (_bufferCount > 0) {
                let b = _bufferData[_bufferOffset]
                _bufferOffset++
                _bufferCount--
                writeCount++
                if (b == LF && foundCR) {
                    builder.write(_bufferData.slice(_bufferOffset - writeCount, writeCount))
                    foundCRLF = true
                    break
                }
                foundCR = (b == CR)
                if (writeCount > lengthLimit) {
                    throw IOException("Line length limit ${lengthLimit} exceeded.")
                }
            }
            if (!foundCRLF) {
                builder.write(_bufferData.slice(_bufferOffset - writeCount, writeCount))
            }
        }

        let bytes = builder.bytes()
        return unsafe {
            String.fromUtf8Unchecked(if (foundCRLF) {
                bytes.slice(0, bytes.size - 2)
            } else {
                bytes
            })
        }
    }
}
