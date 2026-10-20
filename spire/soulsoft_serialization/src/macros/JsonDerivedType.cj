/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

macro package soulsoft_serialization.macros

import std.ast.*

/**
 * @brief 标记多态派生类型映射，只接受类型引用形式的 `derivedType`。
 * @param attr 宏属性参数。
 * @param input 宏展开的目标类型声明。
 * @return 原始类型声明；映射信息由外层宏在编译期直接消费。
 */
public macro JsonDerivedType(attr: Tokens, input: Tokens): Tokens {
    if (let Some(message) <- parseMessage(attr)) {
        message.sendMessage()
    }
    return input
}

protected struct JsonDerivedTypeMacroData {
    let derivedType: Tokens
    let typeDiscriminator: String

    init(derivedType: Tokens, typeDiscriminator: String) {
        this.derivedType = derivedType
        this.typeDiscriminator = typeDiscriminator
    }

    public static prop Key: String {
        get() {
            "JsonDerivedType"
        }
    }

    public func sendMessage(): Unit {
        setItem("derivedType", derivedType)
        setItem("typeDiscriminator", typeDiscriminator)
    }

    public static func fromMessage(message: MacroMessage): ?JsonDerivedTypeMacroData {
        if (!message.hasItem("derivedType") || !message.hasItem("typeDiscriminator")) {
            return None
        }
        return JsonDerivedTypeMacroData(
            message.getTokens("derivedType"),
            message.getString("typeDiscriminator")
        )
    }
}

private func parseMessage(attr: Tokens): ?JsonDerivedTypeMacroData {
    let syntheticCallExpr = CallExpr(quote(
        f($(attr))
    ))
    let arguments = syntheticCallExpr.arguments
    if (arguments.size != 2) {
        diagReport(
            DiagReportLevel.ERROR,
            attr,
            "@JsonDerivedType requires exactly two arguments: derived type and discriminator.",
            "Use named arguments `derivedType: SomeType, typeDiscriminator: \"text\"`."
        )
        return None
    }

    for (argument in arguments) {
        if (argument.colon.value.isEmpty()) {
            diagReport(
                DiagReportLevel.ERROR,
                attr,
                "@JsonDerivedType only supports named arguments 'derivedType' and 'typeDiscriminator'.",
                "Add argument names explicitly."
            )
            return None
        }
    }

    var derivedTypeExpr: ?Expr = None
    var typeDiscriminatorExpr: ?Expr = None
    var hasError = false
    for (argument in arguments) {
        match (argument.identifier.value) {
            case "derivedType" =>
                if (derivedTypeExpr.isSome()) {
                    diagReport(
                        DiagReportLevel.ERROR,
                        Tokens(argument.identifier),
                        "@JsonDerivedType does not allow duplicate argument 'derivedType'.",
                        "Keep only one `derivedType` argument."
                    )
                    hasError = true
                } else {
                    derivedTypeExpr = argument.expr
                }
            case "typeDiscriminator" =>
                if (typeDiscriminatorExpr.isSome()) {
                    diagReport(
                        DiagReportLevel.ERROR,
                        Tokens(argument.identifier),
                        "@JsonDerivedType does not allow duplicate argument 'typeDiscriminator'.",
                        "Keep only one `typeDiscriminator` argument."
                    )
                    hasError = true
                } else {
                    typeDiscriminatorExpr = argument.expr
                }
            case _ =>
                diagReport(
                    DiagReportLevel.ERROR,
                    Tokens(argument.identifier),
                    "@JsonDerivedType only supports named arguments 'derivedType' and 'typeDiscriminator'.",
                    "Remove unsupported arguments."
                )
                hasError = true
        }
    }

    if (hasError) {
        return None
    }

    if (let Some(derivedTypeExpr) <- derivedTypeExpr && let Some(typeDiscriminatorExpr) <- typeDiscriminatorExpr) {
        if (let Some(value) <- tryGetStringLiteralValue(derivedTypeExpr)) {
            diagReport(
                DiagReportLevel.ERROR,
                derivedTypeExpr.toTokens(),
                "@JsonDerivedType requires 'derivedType' to be a type reference, not a string literal.",
                "Use `derivedType: ${value}` instead of `derivedType: \"${value}\"`."
            )
            return None
        }

        if (let Some(typeDiscriminator) <- tryGetStringLiteralValue(typeDiscriminatorExpr)) {
            return JsonDerivedTypeMacroData(derivedTypeExpr.toTokens(), typeDiscriminator)
        }

        diagReport(
            DiagReportLevel.ERROR,
            typeDiscriminatorExpr.toTokens(),
            "@JsonDerivedType only supports string literal argument 'typeDiscriminator'.",
            "Use a string literal such as `typeDiscriminator: \"text\"`."
        )
        return None
    }

    diagReport(
        DiagReportLevel.ERROR,
        attr,
        "@JsonDerivedType requires named arguments 'derivedType' and 'typeDiscriminator'.",
        "Provide both named arguments."
    )
    return None
}

private func tryGetStringLiteralValue(expr: Expr): ?String {
    if (let literal: LitConstExpr <- expr) {
        match (literal.literal.kind) {
            case TokenKind.STRING_LITERAL | TokenKind.SINGLE_QUOTED_STRING_LITERAL | TokenKind.JSTRING_LITERAL =>
                return literal.literal.value
            case _ => ()
        }
    }
    return None
}
