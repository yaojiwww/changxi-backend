// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_staticfiles

import std.io.*
import std.time.*
import std.convert.*
import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_http.headers.*
import soulsoft_web_staticfiles.fileProviders.*

struct PreconditionState <: Equatable<PreconditionState> {
    private let _value: Int64

    private init(value: Int64) {
        _value = value
    }

    public static let Unspecified = PreconditionState(0)
    public static let NotModified = PreconditionState(1)
    public static let ShouldProcess = PreconditionState(2)
    public static let PreconditionFailed = PreconditionState(3)

    public prop ordinal: Int64 {
        get() {
            _value
        }
    }

    public operator func ==(other: PreconditionState): Bool {
        _value == other._value
    }

    public operator func !=(other: PreconditionState): Bool {
        _value != other._value
    }
}

struct RequestType <: Equatable<RequestType> {
    private let _value: UInt8

    private init(value: UInt8) {
        _value = value
    }

    public static let Unspecified = RequestType(0)
    public static let IsHead = RequestType(1)
    public static let IsGet = RequestType(2)
    public static let IsRange = RequestType(4)

    public operator func |(other: RequestType): RequestType {
        RequestType(_value | other._value)
    }

    public operator func &(other: RequestType): RequestType {
        RequestType(_value & other._value)
    }

    public operator func ==(other: RequestType): Bool {
        _value == other._value
    }

    public operator func !=(other: RequestType): Bool {
        _value != other._value
    }

    public func hasFlag(flag: RequestType): Bool {
        (_value & flag._value) != 0
    }
}

struct StaticFileContent {
    private let _fileInfo: IFileInfo
    private let _contentType: String
    private let _onPrepareResponse: ?(StaticFileResponseContext) -> Unit
    private var _etag: ?EntityTagHeaderValue = None
    private var _lastModifiedSeconds: Int64 = 0
    private var _length: Int64 = 0

    private var _ifMatchState = PreconditionState.Unspecified
    private var _ifNoneMatchState = PreconditionState.Unspecified
    private var _ifModifiedSinceState = PreconditionState.Unspecified
    private var _ifUnmodifiedSinceState = PreconditionState.Unspecified

    private var _requestType = RequestType.Unspecified
    private var _isRangeRequest = false
    private var _rangeStart: Int64 = 0
    private var _rangeLength: Int64 = 0

    public prop isHeadMethod: Bool {
        get() {
            _requestType.hasFlag(RequestType.IsHead)
        }
    }

    public prop isGetMethod: Bool {
        get() {
            _requestType.hasFlag(RequestType.IsGet)
        }
    }

    StaticFileContent(fileInfo: IFileInfo, contentType: String, method: String,
        onPrepareResponse: ?(StaticFileResponseContext) -> Unit) {
        _fileInfo = fileInfo
        _contentType = contentType
        _onPrepareResponse = onPrepareResponse
        if (HttpMethods.isGet(method)) {
            _requestType = RequestType.IsGet
        } else if (HttpMethods.isHead(method)) {
            _requestType = RequestType.IsHead
        }
    }

    /// 查找并缓存文件元数据，返回文件是否存在。
    public mut func lookupFileInfo(): Bool {
        if (_fileInfo.exists) {
            _length = _fileInfo.size
            // Truncate to the second — aligns with RFC1123 Last-Modified header precision
            let seconds = _fileInfo.lastModified.inUTC().toUnixTimeStamp().toSeconds()
            _lastModifiedSeconds = seconds
            _etag = EntityTagHeaderValue(computeEtag(seconds, _length))
        }
        return _fileInfo.exists
    }

    public mut func serveStaticFile(context: HttpContext, next: RequestDelegate) {
        comprehendRequestHeaders(context)
        let state = getPreconditionState()
        if (state == PreconditionState.Unspecified || state == PreconditionState.ShouldProcess) {
            if (isHeadMethod) {
                sendStatus(context, StatusCodes.Ok)
                return
            }
            try {
                if (_isRangeRequest) {
                    sendRange(context)
                } else {
                    send(context)
                }
                return
            } catch (_: Exception) {
                // File may have been deleted between lookup and read — fall through to next
            }
            next(context)
        } else if (state == PreconditionState.NotModified) {
            sendStatus(context, StatusCodes.NotModified)
        } else {
            sendStatus(context, StatusCodes.PreconditionFailed)
        }
    }

    private mut func comprehendRequestHeaders(context: HttpContext) {
        computeIfMatch(context)
        computeIfModifiedSince(context)
        computeRange(context)
        computeIfRange(context)
    }

    private mut func computeIfMatch(context: HttpContext) {
        // 14.24 If-Match — strong ETag comparison (RFC 7232 §3.1)
        let ifMatchHeaders = context.request.headers.ifMatch
        if (ifMatchHeaders.size > 0) {
            _ifMatchState = PreconditionState.PreconditionFailed
            let list = ArrayList<String>()
            for (v in ifMatchHeaders) {
                list.add(v)
            }
            for (etag in EntityTagHeaderValue.parseList(list)) {
                if (etag == EntityTagHeaderValue.any) {
                    _ifMatchState = PreconditionState.ShouldProcess
                    break
                }
                if (let Some(fileEtag) <- _etag) {
                    if (etag.compare(fileEtag, true)) {
                        _ifMatchState = PreconditionState.ShouldProcess
                        break
                    }
                }
            }
        }
        // 14.26 If-None-Match — strong ETag comparison (RFC 7232 §3.2)
        let ifNoneMatchHeaders = context.request.headers.ifNoneMatch
        if (ifNoneMatchHeaders.size > 0) {
            _ifNoneMatchState = PreconditionState.ShouldProcess
            let list = ArrayList<String>()
            for (v in ifNoneMatchHeaders) {
                list.add(v)
            }
            for (etag in EntityTagHeaderValue.parseList(list)) {
                if (etag == EntityTagHeaderValue.any) {
                    _ifNoneMatchState = PreconditionState.NotModified
                    break
                }
                if (let Some(fileEtag) <- _etag) {
                    if (etag.compare(fileEtag, true)) {
                        _ifNoneMatchState = PreconditionState.NotModified
                        break
                    }
                }
            }
        }
    }

    private mut func computeIfModifiedSince(context: HttpContext) {
        let now = DateTime.now().inUTC().toUnixTimeStamp().toSeconds()
        // 14.25 If-Modified-Since
        // Guard against clock skew: ignore future-dated headers (aligns with ASP.NET Core)
        if (let Some(header) <- context.request.headers.ifModifiedSince.first) {
            if (let Some((_, dateSecs)) <- HeaderUtilities.tryStringToDate(header.trimAscii(), 0)) {
                if (dateSecs <= now) {
                    _ifModifiedSinceState = if (dateSecs < _lastModifiedSeconds) {
                        PreconditionState.ShouldProcess
                    } else {
                        PreconditionState.NotModified
                    }
                }
            }
        }
        // 14.28 If-Unmodified-Since
        if (let Some(header) <- context.request.headers.ifUnmodifiedSince.first) {
            if (let Some((_, dateSecs)) <- HeaderUtilities.tryStringToDate(header.trimAscii(), 0)) {
                if (dateSecs <= now) {
                    _ifUnmodifiedSinceState = if (dateSecs >= _lastModifiedSeconds) {
                        PreconditionState.ShouldProcess
                    } else {
                        PreconditionState.PreconditionFailed
                    }
                }
            }
        }
    }

    private mut func computeRange(context: HttpContext) {
        // Range header only applies to GET, not HEAD (RFC 7233 §3.1)
        if (!isGetMethod) {
            return
        }
        if (let Some(rangeStr) <- context.request.headers.range.first) {
            if (let Some(rangeHeader) <- RangeHeaderValue.tryParse(rangeStr)) {
                let ranges = rangeHeader.ranges
                if (ranges.size == 1) {
                    // Single range: normalize and validate against file length
                    let (start, end) = normalizeRangeItem(ranges[0], _length)
                    _isRangeRequest = true
                    _rangeStart = start
                    _rangeLength = if (start >= 0) {
                        end - start + 1
                    } else {
                        0
                    }
                }
                // 0 or multiple ranges → serve full file (no range request)
            }
        }
    }

    private mut func computeIfRange(context: HttpContext) {
        if (!_isRangeRequest) {
            return
        }
        // 14.27 If-Range — ETag (strong) or date comparison (RFC 7233 §3.2)
        if (let Some(ifRangeRaw) <- context.request.headers.ifRange.first) {
            if (let Some(ifRange) <- RangeConditionHeaderValue.tryParse(ifRangeRaw.trimAscii())) {
                if (let Some(secs) <- ifRange.lastModified) {
                    // Date comparison: if resource was modified after the given date, serve full file
                    if (_lastModifiedSeconds > secs) {
                        _isRangeRequest = false
                    }
                } else if (let Some(et) <- ifRange.entityTag) {
                    // ETag strong comparison: validator mismatch → serve full file
                    let matches = match (_etag) {
                        case Some(fileEtag) => et.compare(fileEtag, true)
                        case None => false
                    }
                    if (!matches) {
                        _isRangeRequest = false
                    }
                }
            }
        }
    }

    private func getPreconditionState(): PreconditionState {
        return maxState(
            maxState(_ifMatchState, _ifNoneMatchState),
            maxState(_ifModifiedSinceState, _ifUnmodifiedSinceState)
        )
    }

    private func applyResponseHeaders(context: HttpContext, statusCode: UInt16) {
        // Only update status if not already changed (e.g., status code pages retry)
        if (context.response.statusCode == StatusCodes.Ok) {
            context.response.statusCode = statusCode
        }
        if (statusCode < 400) {
            // Returned for 200, 206, and 304; not for 412, 416
            context.response.headers.contentType = [_contentType]
            context.response.headers.lastModified = [HeaderUtilities.formatDate(_lastModifiedSeconds)]
            if (let Some(etag) <- _etag) {
                context.response.headers.eTag = [etag.toString()]
            }
            context.response.headers.acceptRanges = ["bytes"]
        }
        if (statusCode == StatusCodes.Ok) {
            // Set Content-Length for all 200 responses (both GET and HEAD)
            // Range (206) sets its own length; 304/412/416 must not include body length
            context.response.contentLength = _length
        }

        if (let Some(apply) <- _onPrepareResponse) {
            apply(StaticFileResponseContext(context, _fileInfo))
        }
    }

    private func sendStatus(context: HttpContext, statusCode: UInt16) {
        applyResponseHeaders(context, statusCode)
    }

    private func send(context: HttpContext) {
        applyResponseHeaders(context, StatusCodes.Ok)
        let stream = _fileInfo.createReadStream()
        try {
            copyRange(context, stream, _length)
        } finally {
            if (let Some(resource) <- (stream as Resource)) {
                resource.close()
            }
        }
    }

    private func sendRange(context: HttpContext) {
        if (_rangeStart < 0) {
            // RFC 7233 §4.4: 416 response SHOULD include Content-Range: bytes */<length>
            context.response.headers.contentRange = [ContentRangeHeaderValue(_length).toString()]
            applyResponseHeaders(context, StatusCodes.RequestedRangeNotSatisfiable)
            return
        }
        let start = _rangeStart
        let end = start + _rangeLength - 1
        context.response.headers.contentRange = [ContentRangeHeaderValue(start, end, _length).toString()]
        context.response.contentLength = _rangeLength
        applyResponseHeaders(context, StatusCodes.PartialContent)
        writeRangeContent(context, start, _rangeLength)
    }

    private func writeRangeContent(context: HttpContext, start: Int64, length: Int64) {
        let stream = _fileInfo.createReadStream()
        try {
            if (let Some(seekable) <- (stream as Seekable)) {
                seekable.seek(SeekPosition.Begin(start))
            }
            copyRange(context, stream, length)
        } finally {
            if (let Some(resource) <- (stream as Resource)) {
                resource.close()
            }
        }
    }

    private func copyRange(context: HttpContext, stream: InputStream, length: Int64) {
        var remaining = length
        let buf = Array<Byte>(65536, repeat: 0)
        while (remaining > 0) {
            let n = stream.read(buf[0..min(65536, remaining)])
            if (n <= 0) {
                break
            }
            context.response.write(buf[0..n])
            remaining -= n
        }
    }

    // --- Helpers ---

    @OverflowWrapping
    private static func computeEtag(lastModified: Int64, fileSize: Int64): String {
        let etagHash = lastModified ^ fileSize
        return "\"${etagHash.format('x')}\""
    }

    /// 将 RangeItemHeaderValue 中的相对或绝对范围规格规范化为文件内的绝对字节偏移。
    /// 返回 (start, end)；start < 0 表示范围不满足（超出文件范围）。
    private static func normalizeRangeItem(item: RangeItemHeaderValue, fileLength: Int64): (Int64, Int64) {
        var start: Int64
        var end: Int64
        match ((item.from, item.to)) {
            case (None, Some(t)) =>
                // Suffix range: bytes=-N → last N bytes; clamp to 0 if N >= fileLength
                start = if (t >= fileLength) {
                    0
                } else {
                    fileLength - t
                }
                end = fileLength - 1
            case (Some(f), None) =>
                // Open-ended: bytes=N-
                start = f
                end = fileLength - 1
            case (Some(f), Some(t)) =>
                start = f
                // Clamp end to last byte (RFC 7233 §2.1)
                end = min(t, fileLength - 1)
            case _ => return (-1, 0)
        }
        if (start < 0 || start >= fileLength || end < start) {
            return (-1, 0)
        }
        return (start, end)
    }

    private static func maxState(a: PreconditionState, b: PreconditionState): PreconditionState {
        return if (a.ordinal >= b.ordinal) {
            a
        } else {
            b
        }
    }
}
