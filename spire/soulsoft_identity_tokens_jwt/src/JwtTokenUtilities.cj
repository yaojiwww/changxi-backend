package soulsoft_identity_tokens_jwt

protected class JwtTokenUtilities {
    private static let MAX_PART_LIMIT = 5

    /**
     * @brief 统计 JWT 字符串的分段数量。
     * @param token 要统计的 JWT 字符串。
     * @return 检测到的分段数量，最多返回 `5`。
     */
    public static func countJwtTokenPart(token: String): Int64 {
        var count = 0
        for (b in token) {
            if (b == b'.') { // '.' 的 ASCII 码是 46
                count++
                if (count >= MAX_PART_LIMIT) {
                    return MAX_PART_LIMIT
                }
            }
        }
        return count + 1
    }
}
