/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization.macros.ast

import std.ast.*
import std.collection.*

// 简化宏代码拼接，避免大量字符串模板 + cangjieLex。
protected class TokensBuilder {
    TokensBuilder(let data: ArrayList<Tokens>) {}

    init() {
        data = ArrayList<Tokens>()
    }

    func append(builder: TokensBuilder): TokensBuilder {
        data.add(all: builder.data)
        return this
    }

    func append(kind: TokenKind): TokensBuilder {
        data.add(Tokens(Token(kind)))
        return this
    }

    func append<T>(tokens: T): TokensBuilder where T <: ToTokens {
        match (tokens) {
            case builder: TokensBuilder => return append(builder)
            case _ => ()
        }
        data.add(tokens.toTokens())
        return this
    }

    func curlyBraces(body: (TokensBuilder) -> Unit): TokensBuilder {
        append(TokenKind.LCURL).append(TokenKind.NL)
        body(this)
        append(TokenKind.RCURL).append(TokenKind.NL)
    }

    public func toTokens(): Tokens {
        let allTokens = ArrayList<Token>()
        for (chunk in data) {
            for (token in chunk) {
                allTokens.add(token)
            }
        }
        return Tokens(allTokens)
    }
}

/*
用于在ast场景下判定是否是Option类型
 */
extend TypeNode {

    /**
     * @brief 获取可空类型节点的底层类型。
     * @return 可空类型对应的底层类型；不是可空类型时返回 `None`。
     */
    public func getUnderlyingType(): ?TypeNode {
        if (!isNullableType(this)) {
            return None
        }
        return match (this) {
            case declType: PrefixType => declType.baseType
            case declType: RefType => declType.typeArguments[0]
            case _ => throw ASTException(this.toTokens().toString())
        }
    }

    /*
    判定是否是Nullable类型
     */
    private static func isNullableType(typeNode: TypeNode) {
        if (let typeNode: PrefixType <- typeNode) {
            return typeNode.prefixOps.size == 1 && typeNode.prefixOps[0].kind == TokenKind.QUEST &&
                typeNode.prefixOps[0].value == "?"
        }

        if (let typeNode: RefType <- typeNode) {
            return typeNode.identifier.kind == TokenKind.IDENTIFIER && typeNode.identifier.value == "Option" &&
                typeNode.typeArguments.size == 1
        }

        return false
    }
}

// 统一 class / struct 的最小能力集合，避免宏生成逻辑复制两套。
protected interface ClassLikeDecl {
    mut prop body: Body
    mut prop superTypes: ArrayList<TypeNode>
    func getTypeName(): Tokens
    func isOpen(): Bool
    func isStruct(): Bool
}

extend ClassDecl <: ClassLikeDecl {
    /**
     * @brief 获取类声明的完整类型名。
     * @return 类声明对应的类型名标记。
     */
    public func getTypeName(): Tokens {
        if (!this.isGenericDecl) {
            return Tokens(this.identifier)
        }
        return quote($(this.identifier)$(this.genericParam))
    }

    /**
     * @brief 判断类声明是否包含 `open` 修饰符。
     * @return 包含 `open` 修饰符时返回 `true`。
     */
    public func isOpen(): Bool {
        for (index in 0..this.modifiers.size) {
            if (this.modifiers[index].keyword.kind == TokenKind.OPEN) {
                return true
            }
        }
        return false
    }

    /**
     * @brief 判断当前声明是否为结构体。
     * @return 对类声明始终返回 `false`。
     */
    public func isStruct(): Bool {
        return false
    }
}

extend StructDecl <: ClassLikeDecl {
    /**
     * @brief 获取结构体声明的完整类型名。
     * @return 结构体声明对应的类型名标记。
     */
    public func getTypeName(): Tokens {
        if (!this.isGenericDecl) {
            return Tokens(this.identifier)
        }
        return quote($(this.identifier)$(this.genericParam))
    }

    /**
     * @brief 判断结构体声明是否可继承。
     * @return 结构体不支持 `open`，始终返回 `false`。
     */
    public func isOpen(): Bool {
        return false
    }

    /**
     * @brief 判断当前声明是否为结构体。
     * @return 对结构体声明始终返回 `true`。
     */
    public func isStruct(): Bool {
        return true
    }
}

private let KEYWORDS = HashSet<String>(
    ["abstract", "break", "Bool", "case", "catch", "class", "const", "continue", "Rune", "do", "else", "enum", "extend",
        "for", "func", "false", "finally", "foreign", "Float16", "Float32", "Float64", "if", "in", "is", "init",
        "import", "interface", "Int8", "Int16", "Int32", "Int64", "IntNative", "let", "mut", "main", "macro", "match",
        "Nothing", "open", "operator", "override", "prop", "public", "package", "private", "protected", "quote", "redef",
        "return", "spawn", "super", "static", "struct", "synchronized", "try", "this", "true", "type", "throw", "This",
        "unsafe", "Unit", "UInt8", "UInt16", "UInt32", "UInt64", "UIntNative", "var", "VArray", "where", "while"])

extend VarDecl {
    /**
     * @brief 获取字段映射后的属性名。
     * @return 去除前导下划线后的属性名；遇到关键字时返回转义名称。
     */
    public func getPropertyName(): String {
        let name = identifier.value[1..]

        if (KEYWORDS.contains(name)) {
            return "`${name}`"
        }

        return name
    }
}

protected func tryGetStringLiteralValue(expr: Expr): ?String {
    if (let literal: LitConstExpr <- expr) {
        match (literal.literal.kind) {
            case TokenKind.STRING_LITERAL | TokenKind.SINGLE_QUOTED_STRING_LITERAL | TokenKind.JSTRING_LITERAL =>
                return literal.literal.value
            case _ => ()
        }
    }
    return None
}
