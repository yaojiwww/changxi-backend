/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization.macros.ast

import std.ast.*
import std.collection.*

/*
宏调用（嵌套）
 */
protected struct MacroCallExpr<T> where T <: Decl {
    public let decl: T
    public let macros: Collection<MacroExpandDecl>

    init(decl: T) {
        this.decl = decl
        this.macros = []
    }

    init(decl: T, macros: Collection<MacroExpandDecl>) {
        this.decl = decl
        this.macros = macros
    }
}

extend<T> MacroCallExpr<T> {

    /**
     * @brief 从标记流解析嵌套宏调用表达式。
     * @param tokens 待解析的标记流。
     * @return 解析得到的宏调用表达式；无法匹配时返回 `None`。
     */
    public static func parse(tokens: Tokens): ?MacroCallExpr<T> {
        let decl = parseDecl(tokens)
        return match (decl) {
            case decl: T => MacroCallExpr<T>(decl) // 优化无嵌套行为
            case _ =>
                let visitor = MacroCallExprVisitor<T>()
                decl.traverse(visitor)
                visitor.getResult()
        }
    }

    /**
     * @brief 从宏展开声明解析嵌套宏调用表达式。
     * @param macroExpandDecl 待解析的宏展开声明。
     * @return 解析得到的宏调用表达式；无法匹配时返回 `None`。
     */
    public static func parse(macroExpandDecl: MacroExpandDecl): ?MacroCallExpr<T> {
        let visitor = MacroCallExprVisitor<T>()
        macroExpandDecl.traverse(visitor)
        return visitor.getResult()
    }

    /**
     * @brief 根据解析结果重新生成宏调用声明。
     * @param decl 宏调用表达式。
     * @return 还原后的声明节点。
     */
    public static func create(macroCallExpr: MacroCallExpr<T>): Decl {
        if (macroCallExpr.macros.isEmpty()) {
            return macroCallExpr.decl
        }

        let tokens = Tokens()
        for (macroDecl in macroCallExpr.macros) {
            tokens.append(cangjieLex("@${macroDecl.identifier.value}[${macroDecl.macroAttrs}]"))
            tokens.append(Token(TokenKind.NL))
        }
        tokens.append(macroCallExpr.decl)
        return MacroExpandDecl(tokens)
    }
}

extend MacroCallExpr<VarDecl> {
    public func isJsonExtensionData(): Bool {
        return this.macros |> any {macroDecl =>
            macroDecl.identifier.value == "JsonExtensionData" ||
                macroDecl.identifier.value.endsWith(".JsonExtensionData")
        }
    }

    public func hasJsonPropertyName(): Bool {
        return this.macros |> any {macroDecl =>
            macroDecl.identifier.value == "JsonPropertyName" ||
                macroDecl.identifier.value.endsWith(".JsonPropertyName")
        }
    }

    /**
     * @brief 获取字段对应的JSON 字段名。
     * @return 字段声明映射后的数据名称。
     */
    public func getJsonPropertyName(): String {
        let jsonPropertyName = this.macros |> filter {macroDecl => macroDecl.identifier.value == "JsonPropertyName"} |>
            first

        if (let Some(jsonPropertyName) <- jsonPropertyName) {
            let expr = parseExpr(jsonPropertyName.macroAttrs)
            if (let Some(value) <- tryGetStringLiteralValue(expr)) {
                return value
            }
            throw ASTException("@JsonPropertyName only supports string literal arguments.")
        }

        return this.decl.identifier.value[1..]
    }

    /**
     * @brief 获取字段对应的属性名称。
     * @return 字段映射后的属性名称。
     */
    public func getPropertyName(): String {
        return this.decl.getPropertyName()
    }

    /**
     * @brief 获取字段对应的JSON 类型标记。
     * @return 用于生成序列化代码的类型标记。
     */
    public func getDataType(): Tokens {
        if (let Some(declType) <- this.decl.declType.getUnderlyingType()) {
            return quote(Option<$(declType)>)
        }

        return this.decl.declType.toTokens()
    }
}
