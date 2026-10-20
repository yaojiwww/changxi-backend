/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server.controllers

import std.io.*
import std.fs.*
import stdx.encoding.json.*
import soulsoft_web_http.*
import soulsoft_web_mvc.*
import soulsoft_web_mvc.annotations.*

// IFormFile 文件上传绑定测试
// 覆盖：FormFileModelBinder（从 request.form.files 获取上传文件）
// 注意：IFormFile 仅支持 @FromForm 来源，Query/Route 中无意义

@Route["api/file"]
public class FormFileController <: Controller {

    // POST /api/file/single
    // Content-Type: multipart/form-data
    // Body: file=<二进制文件内容>
    // → {"name":"test.txt","filename":"test.txt","contentType":"text/plain","length":123}
    @HttpPost["single"]
    public func uploadSingle(@FromForm file: IFormFile): IActionResult {
        let obj = JsonObject()
        let length = fillFileInfo(obj, file)
        obj.put("length", JsonInt(length))
        return content(obj.toString(), "application/json")
    }

    // POST /api/file/multiple
    // Content-Type: multipart/form-data
    // Body: files=<文件1>&files=<文件2>
    // → {"count":2,"totalLength":246,"files":[{"name":"a.txt","filename":"a.txt","length":123},...]}
    @HttpPost["multiple"]
    public func uploadMultiple(@FromForm files: Array<IFormFile>): IActionResult {
        let filesArr = JsonArray()
        var totalLength: Int64 = 0

        for (f in files) {
            let fileObj = JsonObject()
            let length = fillFileInfo(fileObj, f)
            fileObj.put("length", JsonInt(length))
            filesArr.add(fileObj)
            totalLength += length
        }

        let obj = JsonObject()
        obj.put("count", JsonInt(Int64(files.size)))
        obj.put("totalLength", JsonInt(totalLength))
        obj.put("files", filesArr)
        return content(obj.toString(), "application/json")
    }

    // POST /api/file/mixed
    // Content-Type: multipart/form-data
    // Body: name=Test&age=25&file=<二进制文件>
    // → {"name":"Test","age":25,"file":{"name":"x.txt","filename":"x.txt","length":123}}
    @HttpPost["mixed"]
    public func uploadMixed(
        @FromForm name: String,
        @FromForm age: Int64,
        @FromForm file: IFormFile
    ): IActionResult {
        let obj = JsonObject()
        obj.put("name", JsonString(name))
        obj.put("age", JsonInt(age))

        let fileObj = JsonObject()
        let length = fillFileInfo(fileObj, file)
        fileObj.put("length", JsonInt(length))
        obj.put("file", fileObj)
        return content(obj.toString(), "application/json")
    }

    // POST /api/file/optional
    // Content-Type: multipart/form-data
    // Body: (无file字段) 或 file=<文件>
    // → {"hasFile":true/false,"name":"..."}
    @HttpPost["optional"]
    public func uploadOptional(@FromForm file: ?IFormFile): IActionResult {
        throw UnsupportedException("这是cangjie的bug")
        let obj = JsonObject()
        println(11)
        if (let Some(f) <- file) {
            obj.put("hasFile", JsonBool(true))
            obj.put("name", JsonString(f.name))
            let fname = match (f.filename) {
                case Some(n) => JsonString(n)
                case None => JsonNull()
            }
            obj.put("filename", fname)
            obj.put("length", JsonInt(f.length))
        } else {
            obj.put("hasFile", JsonBool(false))
            obj.put("name", JsonNull())
            obj.put("filename", JsonNull())
            obj.put("length", JsonNull())
        }
        println(22)
        return content(obj.toString(), "application/json")
    }

    // 辅助函数：填充文件信息到 JsonObject，返回文件长度（通过读取流计算）
    private func fillFileInfo(obj: JsonObject, f: IFormFile): Int64 {
        obj.put("name", JsonString(f.name))
        let fname = match (f.filename) {
            case Some(n) => JsonString(n)
            case None => JsonNull()
        }
        obj.put("filename", fname)
        obj.put("contentType", JsonString(f.contentType))

        // 读取文件流到 ByteBuffer 获取长度
        let buffer = ByteBuffer()
        let stream = f.openReadStream()
        copy(stream, to: buffer)
        return buffer.length
    }

    // 辅助函数：填充可选文件信息
    private func fillOptionalFileInfo(obj: JsonObject, f: ?IFormFile, hasFile: Bool): Unit {
        obj.put("hasFile", JsonBool(hasFile))
        if (hasFile) {
            if (let Some(f2) <- f) {
                obj.put("name", JsonString(f2.name))
                let fname = match (f2.filename) {
                    case Some(n) => JsonString(n)
                    case None => JsonNull()
                }
                obj.put("filename", fname)
                // 可选：如果需要 length，可以在这里读取
            }
        } else {
            obj.put("name", JsonNull())
            obj.put("filename", JsonNull())
        }
    }
}
