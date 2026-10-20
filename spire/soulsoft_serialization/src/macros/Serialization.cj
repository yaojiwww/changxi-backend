/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

macro package soulsoft_serialization.macros

import std.ast.*
import std.collection.*
import soulsoft_serialization.macros.ast.*

/**
 * @brief 为类或结构体生成序列化相关实现。
 * @param input 宏展开的目标类型声明。
 * @return 注入序列化代码后的声明令牌。
 */
public macro Serialization(input: Tokens): Tokens {
    applySerializationMacro(input, None, getJsonDerivedTypeDefinitions())
}

/**
 * @brief 为类或结构体生成可指定父类型的序列化实现。
 * @param attr 宏属性参数。
 * @param input 宏展开的目标类型声明。
 * @return 注入序列化代码后的声明令牌。
 */
public macro Serialization(attr: Tokens, input: Tokens): Tokens {
    let arguments = MacroUtilities.parseMacroArgumentsAsTokens(attr)
    let superType = arguments.get("superType")
    if (let Some(superType) <- superType) {
        setItem("superType", superType)
    }
    applySerializationMacro(input, superType, getJsonDerivedTypeDefinitions())
}

private func applySerializationMacro(
    input: Tokens,
    superType: ?Tokens,
    derivedTypeDefinitions: ArrayList<DerivedTypeDefinition>
) {
    if (let Some(classMacroCall) <- MacroCallExpr<ClassDecl>.parse(input)) {
        SerializationMacro(superType, classMacroCall.decl, classMacroCall.macros, derivedTypeDefinitions).apply()
        return MacroCallExpr<ClassDecl>.create(classMacroCall).toTokens()
    }

    if (let Some(structMacroCall) <- MacroCallExpr<StructDecl>.parse(input)) {
        SerializationMacro(superType, structMacroCall.decl, structMacroCall.macros, derivedTypeDefinitions).apply()
        return MacroCallExpr<StructDecl>.create(structMacroCall).toTokens()
    }

    return input
}

private func getJsonDerivedTypeDefinitions(): ArrayList<DerivedTypeDefinition> {
    let definitions = ArrayList<DerivedTypeDefinition>()
    for (message in getChildMessages(JsonDerivedTypeMacroData.Key)) {
        if (let Some(data) <- JsonDerivedTypeMacroData.fromMessage(message)) {
            definitions.add(DerivedTypeDefinition(data.derivedType, data.typeDiscriminator))
        }
    }
    return definitions
}
