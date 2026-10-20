/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import std.io.*
import soulsoft_serialization.*
import soulsoft_serialization.macros.*
import soulsoft_web_mvc.*

// Action 返回类型集成测试 Controller
//
// 覆盖所有派发路径（ControllerRequestDelegateFactory.dispatchResult）：
//   IActionResult 子类：ContentResult / StatusCodeResult / ObjectResult / JsonResult /
//                       RedirectResult / FileContentResult / FileStreamResult
//   非 IActionResult：String → 自动包装 ContentResult
//                     ISerializable → 自动包装 ObjectResult
//                     Unit → 204 NoContent

@Serialization
public class ReturnTypeDto {
    private var _id: Int64 = 0
    private var _name: String = ""
}

@Route["api/return-type"]
public class ActionReturnTypeController <: Controller {

    // ── ContentResult ─────────────────────────────────────────────────────────

    // content(str) → text/plain; charset=utf-8, 200
    @HttpGet["content-text"]
    public func contentText(): IActionResult {
        return content("hello")
    }

    // content(str, contentType) → application/json, 200
    @HttpGet["content-typed"]
    public func contentTyped(): IActionResult {
        return content("{\"ok\":true}", "application/json")
    }

    // content("") → ContentResult.invoke 检测空串后写 204
    @HttpGet["content-empty"]
    public func contentEmpty(): IActionResult {
        return content("")
    }

    // ── StatusCodeResult ──────────────────────────────────────────────────────

    // ok() → 200
    @HttpGet["status-ok"]
    public func statusOk(): IActionResult {
        return ok()
    }

    // noContent() → 204
    @HttpGet["status-no-content"]
    public func statusNoContent(): IActionResult {
        return noContent()
    }

    // notFound() → 404
    @HttpGet["status-not-found"]
    public func statusNotFound(): IActionResult {
        return notFound()
    }

    // unauthorized() → 401
    @HttpGet["status-unauthorized"]
    public func statusUnauthorized(): IActionResult {
        return unauthorized()
    }

    // badRequest() → 400
    @HttpGet["status-bad-request"]
    public func statusBadRequest(): IActionResult {
        return badRequest()
    }

    // status(UInt16) → 任意自定义状态码（418 I'm a teapot）
    @HttpGet["status-custom"]
    public func statusCustom(): IActionResult {
        return status(418)
    }

    // ── ObjectResult<T> ───────────────────────────────────────────────────────

    // ok<T>(value) → JsonOutputFormatter 序列化，200
    @HttpGet["ok-value"]
    public func okValue(): IActionResult {
        let dto = ReturnTypeDto()
        dto.id = 1
        dto.name = "ok-dto"
        return ok<ReturnTypeDto>(dto)
    }

    // ── JsonResult<T> ─────────────────────────────────────────────────────────

    // json<T>(data) → response.writeAsJson，200
    @HttpGet["json-value"]
    public func jsonValue(): IActionResult {
        let dto = ReturnTypeDto()
        dto.id = 2
        dto.name = "json-dto"
        return json<ReturnTypeDto>(dto)
    }

    // ── RedirectResult ────────────────────────────────────────────────────────

    // redirect(url) → 302 + Location 头
    @HttpGet["redirect-to"]
    public func redirectTo(): IActionResult {
        return redirect("/api/return-type/status-ok")
    }

    // ── FileContentResult ─────────────────────────────────────────────────────

    // file(bytes, contentType) → 200，无 Content-Disposition
    @HttpGet["file-bytes"]
    public func fileBytes(): IActionResult {
        // "Hello" 的 ASCII 字节
        let bytes: Array<Byte> = [0x48, 0x65, 0x6C, 0x6C, 0x6F]
        return file(bytes, "application/octet-stream")
    }

    // file(bytes, contentType, downloadName) → 200 + Content-Disposition: attachment
    @HttpGet["file-bytes-named"]
    public func fileBytesNamed(): IActionResult {
        let bytes: Array<Byte> = [0x48, 0x65, 0x6C, 0x6C, 0x6F]
        return file(bytes, "application/octet-stream", "hello.bin")
    }

    // ── FileStreamResult ──────────────────────────────────────────────────────

    // file(stream, contentType) → 200，无 Content-Disposition
    @HttpGet["file-stream"]
    public func fileStream(): IActionResult {
        let data = "stream-data".toArray()
        let buf = ByteBuffer(data.size)
        buf.write(data)
        return file(buf, "text/plain")
    }

    // file(stream, contentType, downloadName) → 200 + Content-Disposition: attachment
    @HttpGet["file-stream-named"]
    public func fileStreamNamed(): IActionResult {
        let data = "stream-named".toArray()
        let buf = ByteBuffer(data.size)
        buf.write(data)
        return file(buf, "text/plain", "data.txt")
    }

    // ── 非 IActionResult 自动派发 ─────────────────────────────────────────────

    // 返回 String → dispatchResult 包装为 ContentResult(str)，200 text/plain
    @HttpGet["return-string"]
    public func returnString(): String {
        return "plain-string"
    }

    // 返回 ISerializable → dispatchResult 包装为 ObjectResult<Any>(obj)，200 JSON
    @HttpGet["return-serializable"]
    public func returnSerializable(): ReturnTypeDto {
        let dto = ReturnTypeDto()
        dto.id = 3
        dto.name = "serializable-dto"
        return dto
    }

    // 返回 Unit → dispatchResult 写 204
    @HttpGet["return-unit"]
    public func returnUnit(): Unit {
        // 无返回值，框架自动发送 204
    }
}
