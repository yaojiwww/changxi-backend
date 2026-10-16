package changxi_backend

import stdx.crypto.digest.*
import std.convert.*
import std.collection.*
import std.fs.*

const PASSWORD_ITERATIONS: Int64 = 12000
const SALT_BYTES: Int64 = 16

func concatBytes(a: Array<Byte>, b: Array<Byte>): Array<Byte> {
    let out = ArrayList<Byte>(a.size + b.size)
    out.add(all: a)
    out.add(all: b)
    return out.toArray()
}

func sha256(data: Array<Byte>): Array<Byte> {
    let md = SHA256()
    md.write(data)
    return md.finish()
}

public func randomBytes(size: Int64): Array<Byte> {
    let file = File("/dev/urandom", OpenMode.Read)
    try {
        let buf = Array<Byte>(size, repeat: 0)
        let n = file.read(buf)
        if (n != size) {
            throw Exception("随机数读取不完整 ${n}/${size}")
        }
        return buf
    } finally {
        file.close()
    }
}

func deriveKey(password: String, salt: Array<Byte>, iterations: Int64): Array<Byte> {
    var h = sha256(concatBytes(salt, password.toArray()))
    var i: Int64 = 1
    while (i < iterations) {
        h = sha256(concatBytes(h, salt))
        i++
    }
    return h
}

public func hashPassword(password: String): String {
    let salt = randomBytes(SALT_BYTES)
    let hash = deriveKey(password, salt, PASSWORD_ITERATIONS)
    return "sha256$" + PASSWORD_ITERATIONS.toString() + "$" + base64UrlEncode(salt) + "$" +
        base64UrlEncode(hash)
}

public func verifyPassword(password: String, stored: String): Bool {
    let parts = stored.split("$")
    if (parts.size != 4 || parts[0] != "sha256") {
        return false
    }
    let iterations = match (Int64.tryParse(parts[1])) {
        case Some(v) => v
        case None => return false
    }
    if (iterations <= 0 || iterations > 1000000) {
        return false
    }
    let salt = match (base64UrlDecode(parts[2])) {
        case Some(b) => b
        case None => return false
    }
    return constantTimeEquals(base64UrlEncode(deriveKey(password, salt, iterations)), parts[3])
}

public func constantTimeEquals(a: String, b: String): Bool {
    if (a.size != b.size) {
        return false
    }
    var diff: UInt8 = 0
    for (i in 0..a.size) {
        diff |= (a[i] ^ b[i])
    }
    return diff == 0
}
