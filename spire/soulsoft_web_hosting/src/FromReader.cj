/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

import std.io.*
import soulsoft_web_http.headers.*
import soulsoft_web_http.utilities.*

protected class FromReader {
    /**
     * @brief 从请求中读取并返回表单集合。
     * @param request 要读取表单内容的 HTTP 请求。
     * @return 读取后的表单集合。
     */
    public static func readForm(request: HttpRequest): IFormCollection {
        let form = FormCollection()
        if (let Some(contentType) <- request.contentType && contentType
            .toAsciiLower()
            .startsWith("multipart/form-data")) {
            if (let Some(mediaType) <- MediaTypeHeaderValue.parse(contentType)) {
                let stream = createBufferStream(request)
                let reader = MultipartReader(mediaType.boundary, stream)
                while (let Some(section) <- reader.readNextSection()) {
                    readSection(section, form)
                }
            }
        }
        return form
    }

    private static func createBufferStream(request: HttpRequest) {
        let buffer = ByteBuffer(request.contentLength ?? 1024 * 4)
        copy(request.body, to: buffer)
        return buffer
    }

    private static func readSection(section: MultipartSection, form: FormCollection) {
        if (let Some(contentDisposition) <- section.contentDisposition) {
            if (let Some(name) <- getDispositionParam(contentDisposition, "name")) {
                if (let Some(contentType) <- section.contentType) {
                    let filename = getDispositionParam(contentDisposition, "filename")
                    // 立即读取文件内容到 ByteBuffer，避免 MultipartReader 后续 drainStream 影响
                    let buffer = ByteBuffer()
                    copy(section.body, to: buffer)
                    buffer.seek(SeekPosition.Begin(0))
                    let file = FormFile(name, filename, contentType, contentDisposition, buffer)
                    form.addFile(name, file)
                } else {
                    // 使用 readToEnd 而不是 readString，因为 section body 长度未知
                    // readString 依赖 remainLength 预分配 buffer，而初始时 remainLength=0
                    let bytes = readToEnd(section.body)
                    let value = unsafe {
                        String.fromUtf8Unchecked(bytes)
                    }
                    form.add(name, value)
                }
            }
        }
    }
}

private func getDispositionParam(disposition: String, paramName: String): ?String {
    let prefix = "${paramName}="
    for (part in disposition.split(";")) {
        let trimmed = part.trimAscii()
        if (trimmed.toAsciiLower().startsWith(prefix.toAsciiLower())) {
            return HeaderUtilities.removeQuotes(trimmed[prefix.size..])
        }
    }
    return None
}
