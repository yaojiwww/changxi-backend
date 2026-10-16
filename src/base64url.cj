package changxi_backend

import std.collection.*

let B64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
let B64_LOOKUP: Array<Int64> = buildLookup()

func buildLookup(): Array<Int64> {
    let table = Array<Int64>(128, repeat: -1)
    for (i in 0..B64_ALPHABET.size) {
        table[Int64(B64_ALPHABET[i])] = i
    }
    return table
}

public func base64UrlEncode(data: Array<Byte>): String {
    let out = ArrayList<Byte>()
    var i = 0
    while (i < data.size) {
        let remain = data.size - i
        let b0 = UInt32(data[i])
        let b1 = if (remain > 1) { UInt32(data[i + 1]) } else { UInt32(0) }
        let b2 = if (remain > 2) { UInt32(data[i + 2]) } else { UInt32(0) }
        let n = (b0 << 16) | (b1 << 8) | b2
        out.add(B64_ALPHABET[Int64((n >> 18) & 0x3F)])
        out.add(B64_ALPHABET[Int64((n >> 12) & 0x3F)])
        if (remain > 1) { out.add(B64_ALPHABET[Int64((n >> 6) & 0x3F)]) }
        if (remain > 2) { out.add(B64_ALPHABET[Int64(n & 0x3F)]) }
        i += 3
    }
    return String.fromUtf8(out.toArray())
}

public func base64UrlDecode(text: String): ?Array<Byte> {
    if (text.size % 4 == 1) { return None }
    let out = ArrayList<Byte>()
    var buffer: UInt32 = 0
    var bits: UInt32 = 0
    for (i in 0..text.size) {
        let ch = text[i]
        if (ch == b'=') { continue }
        if (ch > 127) { return None }
        let v = B64_LOOKUP[Int64(ch)]
        if (v < 0) { return None }
        buffer = (buffer << 6) | UInt32(v)
        bits += 6
        if (bits >= 8) {
            bits -= 8
            out.add(UInt8((buffer >> bits) & 0xFF))
        }
    }
    return out.toArray()
}
