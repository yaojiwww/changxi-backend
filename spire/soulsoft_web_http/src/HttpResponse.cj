// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http

import std.io.*
import stdx.encoding.json.*
import stdx.encoding.json.ToJson
import soulsoft_serialization.*
import stdx.encoding.json.stream.*
import stdx.serialization.serialization.DataModel
import stdx.serialization.serialization.Serializable

/**
 * @brief 表示 HTTP 响应。
 */
public abstract class HttpResponse {
    /**
     * @brief 获取或修改响应状态码。
     * @return 当前响应状态码。
     */
    public mut prop statusCode: UInt16
    /**
     * @brief 获取或修改响应内容类型。
     * @return 当前响应内容类型；未设置时返回空。
     */
    public mut prop contentType: ?String
    /**
     * @brief 获取或修改响应内容长度。
     * @return 当前响应内容长度；未设置时返回空。
     */
    public mut prop contentLength: ?Int64
    /**
     * @brief 返回响应正文流。
     * @return 当前响应的正文流。
     */
    public prop body: IOStream
    /**
     * @brief 返回响应 Cookie 集合。
     * @return 当前响应的 Cookie 集合。
     */
    public prop cookies: IResponseCookies
    /**
     * @brief 返回响应头集合。
     * @return 当前响应的响应头集合。
     */
    public prop headers: IHeaderDictionary
    /**
     * @brief 返回所属的 HTTP 上下文。
     * @return 当前响应关联的 HTTP 上下文。
     */
    public prop httpContext: HttpContext
    /**
     * @brief 检查响应是否已开始发送。
     * @return 如果响应已开始发送则返回 true，否则返回 false。
     */
    public prop hasStarted: Bool

    /**
     * @brief 向响应正文写入字节数组。
     * @param bytes 要写入的字节数据。
     */
    public func write(bytes: Array<Byte>): Unit
    /**
     * @brief 注册响应开始前执行的回调。
     * @param callback 响应开始前执行的回调函数。
     */
    public func onStarting(callback: () -> Unit): Unit
    /**
     * @brief 注册响应完成后执行的回调。
     * @param callback 响应完成后执行的回调函数。
     */
    public func onCompleted(callback: () -> Unit): Unit
}

extend HttpResponse {
    /**
     * @brief 注册在响应完成后释放的资源。
     * @param resource 响应完成后需要关闭的资源。
     */
    public func registerForDispose(resource: Resource): Unit {
        onCompleted {resource.close()}
    }
}

extend HttpResponse {
    /**
     * @brief 向响应正文写入字符串内容。
     * @param text 要写入的字符串内容。
     */
    public func write(text: String): Unit {
        write(text.toArray())
    }
    /**
     * @brief 将响应重定向到指定位置。
     * @param location 重定向目标地址。
     */
    public func redirect(location: String): Unit {
        headers.add(HeaderNames.Location, location)
        statusCode = StatusCodes.Found
    }

    /**
     * @brief 将数据作为 JSON 写入响应。
     * @param data 要序列化并写入的数据。
     * @throws UnsupportedException 当数据类型不支持 JSON 写入时抛出。
     */
    public func writeAsJson<T>(data: T): Unit {
        this.writeAsJson<T>(data, JsonSerializerOptions.default)
    }

    /**
     * @brief 使用指定选项将数据作为 JSON 写入响应。
     * @param data 要序列化并写入的数据。
     * @param options JSON 序列化选项。
     * @throws UnsupportedException 当数据类型不支持 JSON 写入时抛出。
     */
    public func writeAsJson<T>(data: T, options: JsonSerializerOptions): Unit {
        this.contentType = "application/json; charset=utf-8"
        if (let data: ISerializable <- data) {
            JsonSerializer.serialize(this.body, data, options)
        } else if (let data: Serializable<T> <- data) {
            write(data.serialize().toJson().toJsonString())
        } else if (let data: JsonValue <- data) {
            write(data.toJsonString())
        } else if (let data: JsonSerializable <- data) {
            let writer = JsonWriter(this.body)
            data.toJson(writer)
            writer.flush()
        } else {
            throw UnsupportedException("writeAsJson only supports Serializable or JsonSerializable types")
        }
    }
}
