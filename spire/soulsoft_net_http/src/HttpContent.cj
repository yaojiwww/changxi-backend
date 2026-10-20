// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_net_http

import std.io.*
import std.sync.*
import std.reflect.*
import soulsoft_serialization.*

/**
 * @brief 表示 HTTP 内容体的抽象基类。
 */
public abstract class HttpContent <: Resource {
    private let _isClosed = AtomicBool(false)
    private let _headers = HttpContentHeaders()
    private var _bufferedContent: ?ByteBuffer = None
    private var _contentReadStream: ?InputStream = None

    /**
     * @brief 获取内容头集合。
     * @return 当前内容关联的头集合。
     */
    public prop headers: HttpContentHeaders {
        get() {
            _headers
        }
    }

    protected func serializeToStream(os: OutputStream): Unit

    /**
     * @brief 以流形式读取内容体。
     * @return 可读取当前内容体的输入流。
     * @throws ObjectDisposedException 当当前内容已被释放时抛出。
     */
    public func readAsStream(): InputStream {
        checkClosed()
        if (isBuffered()) {
            return createStreamFromBuffer()
        }
        if (let Some(s) <- _contentReadStream) {
            return s
        }
        let s = createContentReadStream()
        _contentReadStream = s
        return s
    }

    /**
     * @brief 以字符串形式读取内容体。
     * @return 当前内容体的字符串表示。
     * @throws ObjectDisposedException 当当前内容已被释放时抛出。
     */
    public func readAsString(): String {
        checkClosed()
        loadIntoBuffer()
        return createMemoryStreamFromBufferedContent() |> readString
    }

    /**
     * @brief 以字节数组形式读取内容体。
     * @return 当前内容体的字节数组表示。
     * @throws ObjectDisposedException 当当前内容已被释放时抛出。
     */
    public func readAsByteArray(): Array<Byte> {
        checkClosed()
        loadIntoBuffer()
        return createMemoryStreamFromBufferedContent().bytes()
    }

    /**
     * @brief 创建用于读取内容体的输入流。
     * @return 可读取当前内容体的输入流。
     * @throws ObjectDisposedException 当当前内容已被释放时抛出。
     */
    public open func createContentReadStream(): InputStream {
        loadIntoBuffer()
        return createStreamFromBuffer()
    }

    /**
     * @brief 将当前内容加载到内存缓冲区。
     * @return 无返回值。
     * @throws ObjectDisposedException 当当前内容已被释放时抛出。
     */
    public func loadIntoBuffer(): Unit {
        checkClosed()
        if (isBuffered()) {
            return
        }
        let buffer = ByteBuffer()
        serializeToStream(buffer)
        _bufferedContent = buffer
    }

    private func createStreamFromBuffer(): InputStream {
        let buf = _bufferedContent.getOrThrow()
        buf.seek(SeekPosition.Begin(0))
        return ByteBuffer(buf.bytes())
    }

    private func createMemoryStreamFromBufferedContent(): ByteBuffer {
        let buf = _bufferedContent.getOrThrow()
        buf.seek(SeekPosition.Begin(0))
        return buf
    }

    private func isBuffered() {
        _bufferedContent.isSome()
    }

    /**
     * @brief 将 JSON 内容反序列化为指定类型。
     * @return 反序列化后的对象。
     * @throws ObjectDisposedException 当当前内容已被释放时抛出。
     */
    public func readFromJson<T>(): T where T <: IDeserializable<T> {
        return JsonSerializer.deserialize<T>(readAsStream(), JsonSerializerOptions())
    }

    /**
     * @brief 使用指定选项将 JSON 内容反序列化为目标类型。
     * @param options JSON 反序列化选项。
     * @return 反序列化后的对象。
     * @throws ObjectDisposedException 当当前内容已被释放时抛出。
     */
    public func readFromJson<T>(options: JsonSerializerOptions): T where T <: IDeserializable<T> {
        return JsonSerializer.deserialize<T>(readAsStream(), options)
    }

    /**
     * @brief 释放当前内容对象。
     * @return 无返回值。
     */
    public func close(): Unit {
        if (_isClosed.compareAndSwap(false, true)) {
            close(true)
        }
    }

    /**
     * @brief 检查当前内容是否已释放。
     * @return 已释放时返回 `true`。
     */
    public open func isClosed(): Bool {
        return _isClosed.load()
    }

    protected func checkClosed(): Unit {
        if (_isClosed.load()) {
            throw ObjectDisposedException(ClassTypeInfo.of(this).toString())
        }
    }

    /**
     * @brief 执行内容关闭时的扩展逻辑。
     * @param _ 是否执行关闭动作。
     */
    protected open func close(_: Bool): Unit {
    }
}
