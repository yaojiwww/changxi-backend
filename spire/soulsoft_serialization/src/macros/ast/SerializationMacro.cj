/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization.macros.ast

import std.ast.*
import std.collection.*

protected open class SerializationMacro {
    private let _superType: ?Tokens
    private let _typeDecl: ClassLikeDecl
    private let _jsonFieldCatalog: JsonFieldCatalog
    private let _memberPropDecls: Collection<MacroCallExpr<PropDecl>>
    private let _polymorphicDefinition: ?PolymorphicDefinition

    protected init(
        superType: ?Tokens,
        typeDecl: ClassLikeDecl,
        declMacros: Collection<MacroExpandDecl>,
        derivedTypeDefinitions: ArrayList<DerivedTypeDefinition>
    ) {
        _superType = superType
        _typeDecl = typeDecl
        _jsonFieldCatalog = JsonFieldCatalog.parse(typeDecl, getMemberVarDecls(typeDecl))
        _memberPropDecls = getMemberPropDecls(typeDecl)
        _polymorphicDefinition = PolymorphicDefinition.parse(typeDecl, declMacros, derivedTypeDefinitions)
    }

    public open func apply() {
        if (_typeDecl.isStruct() && _superType.isSome()) {
            throw ASTException("@Serialization[superType: ...] is not supported for struct.")
        }
        defineDefaultConstructor() // 添加无参构造函数
        defineSerializeFuncDecl()
        defineWriteJsonFieldsFuncDecl()
        defineDeserializeFuncDecl()
        defineReadJsonSupportFuncDecls() // 生成反序列化辅助函数
        defineSuperTypes() // 实现 Serializable 接口
        defineMemberPropDecls() // 生成属性访问器
    }

    private func wrapFunc(signature: Tokens, body: Tokens): Tokens {
        let builder = TokensBuilder()
        builder.append(signature).curlyBraces {
            block => block.append(body)
        }
        return builder.toTokens()
    }

    private func wrapInstanceFuncByInheritance(openSignature: Tokens, overrideSignature: Tokens,
        privateSignature: Tokens, body: Tokens): Tokens {
        let signature = if (_typeDecl.isOpen()) {
            openSignature
        } else if (_superType.isSome()) {
            overrideSignature
        } else {
            privateSignature
        }
        return wrapFunc(signature, body)
    }

    private func wrapStaticFuncBySuperType(publicSignature: Tokens, privateSignature: Tokens, body: Tokens): Tokens {
        let signature = if (_superType.isSome()) {
            publicSignature
        } else {
            privateSignature
        }
        return wrapFunc(signature, body)
    }

    /*
    添加无参构造函数
     */
    private func defineDefaultConstructor() {
        if (hasParameterlessConstructor()) {
            return
        }
        let defaultInitDecl = FuncDecl()
        defaultInitDecl.modifiers.add(Modifier(Token(TokenKind.PUBLIC)))
        defaultInitDecl.keyword = Token(TokenKind.INIT)
        defaultInitDecl.block.lBrace = Token(TokenKind.LCURL)
        defaultInitDecl.block.rBrace = Token(TokenKind.RCURL)
        for (field in _jsonFieldCatalog.fields) {
            let paramName = Token(TokenKind.IDENTIFIER, field.propertyName)
            let declType = field.member.decl.declType
            let expr = quote(
                $(paramName)!: $(declType) = $(field.member.decl.expr)
            )
            defaultInitDecl.funcParams.add(FuncParam(expr))
        }
        for (field in _jsonFieldCatalog.fields) {
            let param = Token(TokenKind.IDENTIFIER, field.propertyName)
            let expr = quote(
                $(field.backingFieldName) = $(param)
            )
            defaultInitDecl.block.nodes.add(AssignExpr(expr))
        }
        _typeDecl.body.decls.add(defaultInitDecl, at: 0)
    }

    /*
    是否存在无参构造函数
     */
    private func hasParameterlessConstructor() {
        let hasEmptyInitFunc = _typeDecl.body.decls |> filterMap {decl => decl as FuncDecl} |>
            any {funcDecl => funcDecl.keyword.kind == TokenKind.INIT && funcDecl.funcParams.size == 0}

        let hasEmptyPrimaryCtor = _typeDecl.body.decls |> filterMap {decl => decl as PrimaryCtorDecl} |>
            any {primaryCtorDecl => primaryCtorDecl.funcParams.size == 0}

        return hasEmptyInitFunc || hasEmptyPrimaryCtor
    }

    /*
    为类型补齐自动生成的属性。
     */
    private func defineMemberPropDecls(): Unit {
        for (field in _jsonFieldCatalog.fields) {
            // 用户已声明同名属性时，跳过自动生成。
            let memberPropName = normalizeIdentifierName(field.propertyName)
            if (_memberPropDecls |>
                any {propDecl => normalizeIdentifierName(propDecl.decl.identifier.value) == memberPropName}) {
                continue
            }
            let generatedPropDecl = createMemberPropDecl(field.member.decl)
            if (field.member.macros.size > 0) {
                let macroWrappedPropDecl = MacroCallExpr<PropDecl>.create(
                    MacroCallExpr<PropDecl>(generatedPropDecl, field.member.macros))
                _typeDecl.body.decls.add(macroWrappedPropDecl)
            } else {
                _typeDecl.body.decls.add(generatedPropDecl)
            }
        }
    }

    /*
    根据后备字段生成属性包装器。
     */
    private func createMemberPropDecl(fieldDecl: VarDecl) {
        let propDecl = PropDecl()
        let propName = fieldDecl.getPropertyName()
        propDecl.keyword = Token(TokenKind.PROP)
        propDecl.modifiers.add(Modifier(Token(TokenKind.PUBLIC)))
        propDecl.identifier = Token(TokenKind.IDENTIFIER, propName)
        propDecl.declType = fieldDecl.declType

        // getter
        propDecl.getter = FuncDecl()
        propDecl.getter.identifier = Token(TokenKind.IDENTIFIER, "get")
        propDecl.getter.block.lBrace = Token(TokenKind.LCURL)
        propDecl.getter.block.nodes.add(RefExpr(quote($(fieldDecl.identifier))))
        propDecl.getter.block.rBrace = Token(TokenKind.RCURL)

        // setter
        propDecl.modifiers.add(Modifier(Token(TokenKind.MUT)))
        propDecl.setter = FuncDecl()
        propDecl.setter.identifier = Token(TokenKind.IDENTIFIER, "set")
        let funcParam = FuncParam()
        funcParam.identifier = Token(TokenKind.IDENTIFIER, "value")
        propDecl.setter.funcParams.add(funcParam)
        propDecl.setter.block.lBrace = Token(TokenKind.LCURL)
        propDecl.setter.block.nodes.add(AssignExpr(quote($(fieldDecl.identifier) = value)))
        propDecl.setter.block.rBrace = Token(TokenKind.RCURL)

        return propDecl
    }

    /*
     添加序列化函数。
     */
    private func defineSerializeFuncDecl() {
        _typeDecl.body.decls.add(parseDecl(buildSerializeFuncTokens()))
    }

    /*
     为子类生成序列化字段写入函数。
     */
    private func defineWriteJsonFieldsFuncDecl() {
        _typeDecl.body.decls.add(parseDecl(buildWriteJsonFieldsFuncTokens()))
    }

    /*
     生成反序列化入口函数。
      */
    private func defineDeserializeFuncDecl() {
        _typeDecl.body.decls.add(parseDecl(buildReadJsonObjectFuncTokens()))
    }

    /*
     添加反序列化辅助函数。
      */
    private func defineReadJsonSupportFuncDecls() {
        _typeDecl.body.decls.add(parseDecl(buildReadJsonObjectImplTokens()))
        if (shouldGenerateReadJsonFieldFunc()) {
            _typeDecl.body.decls.add(parseDecl(buildReadJsonFieldFuncTokens()))
        }
        if (!_typeDecl.isStruct()) {
            _typeDecl.body.decls.add(parseDecl(buildIsDeclaredJsonFieldFuncTokens()))
            _typeDecl.body.decls.add(parseDecl(buildHasExtensionDataInChainFuncTokens()))
        }
    }

    private func buildSerializeFuncTokens(): Tokens {
        return if (_typeDecl.isOpen()) {
            quote(
                    public open func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
                    w.startObject()
        __serialization_write_json_fields(w, options)
                    w.endObject()
                }
            )
        } else {
            quote(
                public func toJson(w: JsonWriter, options: JsonSerializerOptions): Unit {
                    w.startObject()
        __serialization_write_json_fields(w, options)
                    w.endObject()
                }
            )
        }
    }

    private func buildWriteJsonFieldsFuncTokens(): Tokens {
        let builder = TokensBuilder()
        builder.append(buildWriteJsonFieldsSignatureTokens())
        builder.curlyBraces {
            body =>
                body.append(buildPolymorphicTypeDiscriminatorWriteTokens())
                body.append(buildExtensionDataInheritanceValidationTokens())
                if (_superType.isSome() && !_typeDecl.isStruct()) {
                    body.append(quote(super.__serialization_write_json_fields(w, options))).append(TokenKind.NL)
                }
                for (field in _jsonFieldCatalog.declaredFields) {
                    body.append(field.buildWriteTokens()).append(TokenKind.NL)
                }
                if (let Some(extensionDataField) <- _jsonFieldCatalog.extensionDataField) {
                    body.append(buildWriteExtensionDataTokens(extensionDataField)).append(TokenKind.NL)
                }
        }
        return builder.toTokens()
    }

    private func buildWriteExtensionDataTokens(field: JsonFieldMetadata): Tokens {
        return quote(
            for ((key, value) in this.$(field.backingFieldName)) {
                if (this.__serialization_is_declared_json_field(key)) {
                    throw JsonSerializationException(
                        "Extension data key '" + key + "' conflicts with declared JSON field."
                    )
                }
                w.writeName(key)
                value.toJson(w, options)
            }
        )
    }

    private func buildReadJsonObjectFuncTokens(): Tokens {
        let serializedTypeName = _typeDecl.getTypeName()
        let body = TokensBuilder()
        let nonObjectMessage = Token(TokenKind.STRING_LITERAL, "JSON value is not object.")
        body
            .append(
                quote(
            match (r.peek()) {
                case Some(BeginObject) => ()
                case _ => throw JsonSerializationException($(nonObjectMessage))
            }
        ))
            .append(TokenKind.NL)
        body.append(quote(r.startObject())).append(TokenKind.NL)
        if (let Some(definition) <- _polymorphicDefinition) {
            body.append(buildPolymorphicDataReadTokens(definition, serializedTypeName))
        } else {
            body.append(quote(let data = __serialization_read_json_object(r, options, None))).append(TokenKind.NL)
        }
        body.append(quote(r.endObject())).append(TokenKind.NL)
        body.append(quote(return data)).append(TokenKind.NL)
        return quote(
            public static func fromJson(r: JsonReader, options: JsonSerializerOptions): $(serializedTypeName) {
                $(body.toTokens())
            }
        )
    }

    private func buildPolymorphicDataReadTokens(definition: PolymorphicDefinition, serializedTypeName: Tokens): Tokens {
        return quote(
            let data: $(serializedTypeName) = $(buildPolymorphicDataReadExprTokens(definition))
        )
    }

    private func buildPolymorphicDataReadExprTokens(definition: PolymorphicDefinition): Tokens {
        let propertyName = Token(TokenKind.STRING_LITERAL, definition.typeDiscriminatorPropertyName)
        let builder = TokensBuilder()
        builder.append(quote(if (r.peek() != EndObject))).curlyBraces {
            ifBody =>
                // 多态读取时优先消费首字段，做一次快速分发。
                ifBody.append(quote(let firstFieldName = r.readName())).append(TokenKind.NL)
                ifBody.append(quote(match (firstFieldName))).curlyBraces {
                    matchBody =>
                        matchBody.append(
                            quote(
                    case $(propertyName) =>
                        let typeDiscriminator = String.fromJson(r, options)
                        match (typeDiscriminator) {
                ))
                        matchBody.append(buildPolymorphicTypeReadCases(definition)).append(TokenKind.NL)
                        matchBody
                            .append(
                                quote(
                        }
                ))
                            .append(TokenKind.NL)
                        matchBody
                            .append(
                                quote(
                    case _ => __serialization_read_json_object(r, options, firstFieldName)
                ))
                            .append(TokenKind.NL)
                }
        }
        builder.append(quote(else)).curlyBraces {
            elseBody =>
                elseBody.append(quote(__serialization_read_json_object(r, options, None))).append(TokenKind.NL)
        }
        return builder.toTokens()
    }

    private func buildPolymorphicTypeReadCases(definition: PolymorphicDefinition): Tokens {
        let cases = TokensBuilder()
        for (derivedType in definition.derivedTypes) {
            let discriminator = Token(TokenKind.STRING_LITERAL, derivedType.typeDiscriminator)
            cases
                .append(
                    quote(
                case $(discriminator) => $(derivedType.derivedType).__serialization_read_json_object(r, options, None)
            ))
                .append(TokenKind.NL)
        }
        cases
            .append(
                quote(
            case _ => throw JsonSerializationException($(definition.getUnknownTypeDiscriminatorMessageToken()))
        ))
            .append(TokenKind.NL)
        return cases.toTokens()
    }

    private func buildReadJsonObjectImplTokens(): Tokens {
        let serializedTypeName = _typeDecl.getTypeName()
        let body = TokensBuilder()
        body.append(buildReadJsonObjectDataInitializationTokens(serializedTypeName)).append(TokenKind.NL)
        body.append(buildExtensionDataInheritanceValidationTokens()).append(TokenKind.NL)
        body.append(buildCurrentFieldReadTokens()).append(TokenKind.NL)
        body.append(buildRemainingFieldReadLoopTokens()).append(TokenKind.NL)
        body.append(quote(return data)).append(TokenKind.NL)
        return wrapStaticFuncBySuperType(
            quote(
                public static func __serialization_read_json_object(
                    r: JsonReader,
                    options: JsonSerializerOptions,
                    currentFieldName: ?String
                ): $(serializedTypeName)
            ),
            quote(
                private static func __serialization_read_json_object(
                    r: JsonReader,
                    options: JsonSerializerOptions,
                    currentFieldName: ?String
                ): $(serializedTypeName)
            ),
            body.toTokens()
        )
    }

    private func buildCurrentFieldReadTokens(): Tokens {
        return quote(
            // 外层多态分发已读取首字段时，这里复用该字段名。
            if (let Some(currentField) <- currentFieldName) {
                $(buildSingleFieldReadAttemptTokens(quote(currentField)))
            }
        )
    }

    private func buildRemainingFieldReadLoopTokens(): Tokens {
        return quote(
            while (r.peek() != EndObject) {
                let name = r.readName()
                $(buildSingleFieldReadAttemptTokens(quote(name)))
            }
        )
    }

    private func buildSingleFieldReadAttemptTokens(fieldName: Tokens): Tokens {
        return if (_typeDecl.isStruct()) {
            buildStructSingleFieldReadTokens(fieldName)
        } else if (shouldGenerateReadJsonFieldFunc()) {
            quote(
                if (!__serialization_read_json_field($(fieldName), r, data, options)) {
                    r.skip()
                }
            )
        } else {
            buildInlineClassSingleFieldReadTokens(fieldName)
        }
    }

    private func buildStructSingleFieldReadTokens(fieldName: Tokens): Tokens {
        return quote(
            var updated = data
            match ($(fieldName)) {
                $(_jsonFieldCatalog.buildDeclaredReadMatchCases(
                    Token(TokenKind.IDENTIFIER, "updated"),
                    quote(data = updated),
                    quote(case _ => r.skip())
                ))
            }
        )
    }

    private func buildInlineClassSingleFieldReadTokens(fieldName: Tokens): Tokens {
        return quote(
            var handled = false
            $(buildClassSingleFieldReadCoreTokens(quote($(fieldName)), Token(TokenKind.IDENTIFIER, "handled")))
            if (!handled) {
                r.skip()
            }
        )
    }

    private func buildReadJsonFieldFuncTokens(): Tokens {
        let serializedTypeName = _typeDecl.getTypeName()
        let body = quote(
            var handled = false
            $(buildClassSingleFieldReadCoreTokens(quote(name), Token(TokenKind.IDENTIFIER, "handled")))
            return handled
        )
        return wrapFunc(buildReadJsonFieldSignatureTokens(serializedTypeName), body)
    }

    private func buildClassSingleFieldReadCoreTokens(fieldName: Tokens, handledName: Token): Tokens {
        let body = TokensBuilder()
        if (let Some(superType) <- _superType) {
            body
                .append(
                    quote(
                // 先让父类消费自己声明的字段。
                $(handledName) = $(superType).__serialization_read_json_field($(fieldName), r, data, options)
            ))
                .append(TokenKind.NL)
        }
        let fallbackCase = buildReadFieldFallbackCaseTokens(
            fieldName,
            quote($(handledName) = true),
            quote($(handledName) = false)
        )
        body
            .append(
                quote(
            if (!$(handledName)) {
                match ($(fieldName)) {
                    $(_jsonFieldCatalog.buildDeclaredReadMatchCases(
                        Token(TokenKind.IDENTIFIER, "data"),
                        quote($(handledName) = true),
                        fallbackCase
                    ))
                }
            }
        ))
            .append(TokenKind.NL)
        return body.toTokens()
    }

    private func buildReadFieldFallbackCaseTokens(
        fieldName: Tokens,
        handledResult: Tokens,
        unhandledResult: Tokens
    ): Tokens {
        if (let Some(extensionDataField) <- _jsonFieldCatalog.extensionDataField) {
            return quote(
                case _ =>
                    if (!data.__serialization_is_declared_json_field($(fieldName))) {
                        data.$(extensionDataField.backingFieldName).add($(fieldName), JsonValue.fromJson(r, options))
                        $(handledResult)
                    } else {
                        $(unhandledResult)
                    }
            )
        }
        return quote(case _ => $(unhandledResult))
    }

    private func buildWriteJsonFieldsSignatureTokens(): Tokens {
        return if (_typeDecl.isOpen()) {
            quote(protected open func __serialization_write_json_fields(w: JsonWriter, options: JsonSerializerOptions): Unit)
        } else if (_superType.isSome()) {
            quote(protected func __serialization_write_json_fields(w: JsonWriter, options: JsonSerializerOptions): Unit)
        } else {
            quote(private func __serialization_write_json_fields(w: JsonWriter, options: JsonSerializerOptions): Unit)
        }
    }

    private func buildReadJsonObjectDataInitializationTokens(serializedTypeName: Tokens): Tokens {
        return if (_typeDecl.isStruct()) {
            quote(var data = $(serializedTypeName)())
        } else {
            quote(let data = $(serializedTypeName)())
        }
    }

    private func buildReadJsonFieldSignatureTokens(serializedTypeName: Tokens): Tokens {
        return quote(
            protected static func __serialization_read_json_field(
                name: String,
                r: JsonReader,
                data: $(serializedTypeName),
                options: JsonSerializerOptions
            ): Bool
        )
    }

    private func buildIsDeclaredJsonFieldFuncTokens(): Tokens {
        let body = TokensBuilder()
        if (let Some(superType) <- _superType) {
            body
                .append(
                    quote(
                if (super.__serialization_is_declared_json_field(name)) {
                    return true
                }
            ))
                .append(TokenKind.NL)
        }

        body
            .append(
                quote(
            match (name) {
                $(_jsonFieldCatalog.buildDeclaredFieldPresenceCases())
            }
        ))
            .append(TokenKind.NL)

        return wrapInstanceFuncByInheritance(
            quote(protected open func __serialization_is_declared_json_field(name: String): Bool),
            quote(protected override func __serialization_is_declared_json_field(name: String): Bool),
            quote(private func __serialization_is_declared_json_field(name: String): Bool),
            body.toTokens()
        )
    }

    private func buildHasExtensionDataInChainFuncTokens(): Tokens {
        let body = TokensBuilder()
        if (_jsonFieldCatalog.extensionDataField.isSome()) {
            body.append(quote(return true)).append(TokenKind.NL)
        } else if (let Some(superType) <- _superType) {
            body.append(quote(
                return $(superType).__serialization_has_extension_data_in_chain()
            )).append(TokenKind.NL)
        } else {
            body.append(quote(return false)).append(TokenKind.NL)
        }

        return wrapFunc(buildHasExtensionDataInChainSignatureTokens(), body.toTokens())
    }

    private func buildExtensionDataInheritanceValidationTokens(): Tokens {
        let body = TokensBuilder()
        if (_jsonFieldCatalog.extensionDataField.isSome() && let Some(superType) <- _superType) {
            let message = Token(
                TokenKind.STRING_LITERAL,
                "Only one @JsonExtensionData field is allowed in an inheritance chain."
            )
            body
                .append(
                    quote(
                // 运行时拒绝继承链上的第二个扩展数据字段。
                if ($(superType).__serialization_has_extension_data_in_chain()) {
                    throw JsonSerializationException($(message))
                }
            ))
                .append(TokenKind.NL)
        }
        return body.toTokens()
    }

    private func shouldGenerateReadJsonFieldFunc(): Bool {
        return !_typeDecl.isStruct() && _typeDecl.isOpen()
    }

    private func buildHasExtensionDataInChainSignatureTokens(): Tokens {
        return if (_typeDecl.isOpen() || _superType.isSome()) {
            quote(protected static func __serialization_has_extension_data_in_chain(): Bool)
        } else {
            quote(private static func __serialization_has_extension_data_in_chain(): Bool)
        }
    }


    private func buildPolymorphicTypeDiscriminatorWriteTokens(): Tokens {
        if (let Some(definition) <- _polymorphicDefinition) {
            let propertyName = Token(TokenKind.STRING_LITERAL, definition.typeDiscriminatorPropertyName)
            let builder = TokensBuilder()
            builder.append(quote(match (this))).curlyBraces {
                body =>
                    body.append(buildPolymorphicTypeWriteCases(definition, propertyName)).append(TokenKind.NL)
                    body.append(quote(case _ => ())).append(TokenKind.NL)
            }
            return builder.toTokens()
        }
        return Tokens()
    }

    private func buildPolymorphicTypeWriteCases(definition: PolymorphicDefinition, propertyName: Token): Tokens {
        let cases = TokensBuilder()
        for (derivedType in definition.derivedTypes) {
            let discriminator = Token(TokenKind.STRING_LITERAL, derivedType.typeDiscriminator)
            cases
                .append(
                    quote(
                case _: $(derivedType.derivedType) =>
                    w.writeName($(propertyName))
                    $(discriminator).toJson(w, options)
            ))
                .append(TokenKind.NL)
        }
        return cases.toTokens()
    }

    /*
    实现 Serializable 接口。
     */
    private func defineSuperTypes() {
        // 实现接口
        let serializedTypeName = _typeDecl.getTypeName()
        let tokens = quote(
            ISerialization<$(serializedTypeName)>
        )
        _typeDecl.superTypes.add(RefType(tokens))

        // 继承父类时，superType 必须是 class，且必须放在最前面。
        if (let Some(superType) <- _superType) {
            _typeDecl.superTypes.add(RefType(superType), at: 0)
        }
    }

    /*
    收集参与序列化的后备字段。
     */
    private static func getMemberVarDecls(typeDecl: ClassLikeDecl): ArrayList<MacroCallExpr<VarDecl>> {
        let memberVarDecls = ArrayList<MacroCallExpr<VarDecl>>()

        // 直接声明的字段
        for (varDecl in typeDecl.body.decls |> filterMap {decl => decl as VarDecl}) {
            if (isAllowedMemberVarDecl(varDecl)) {
                memberVarDecls.add(MacroCallExpr<VarDecl>(varDecl))
            }
        }

        // 宏包装后的字段
        for (macroDecl in typeDecl.body.decls |> filterMap {decl => decl as MacroExpandDecl}) {
            if (let Some(memberVarMacro) <- MacroCallExpr<VarDecl>.parse(macroDecl) && isAllowedMemberVarDecl(
                memberVarMacro.decl)) {
                memberVarDecls.add(memberVarMacro)
            }
        }
        return memberVarDecls
    }

    private static func getMemberPropDecls(typeDecl: ClassLikeDecl) {
        let memberPropDecls = ArrayList<MacroCallExpr<PropDecl>>()

        // 直接声明的属性
        for (propDecl in typeDecl.body.decls |> filterMap {decl => decl as PropDecl}) {
            memberPropDecls.add(MacroCallExpr<PropDecl>(propDecl))
        }

        // 宏包装后的属性
        for (macroDecl in typeDecl.body.decls |> filterMap {decl => decl as MacroExpandDecl}) {
            if (let Some(propMacro) <- MacroCallExpr<PropDecl>.parse(macroDecl)) {
                memberPropDecls.add(propMacro)
            }
        }
        return memberPropDecls
    }

    /*
    后备字段的合法形态。
     */
    private static func isAllowedMemberVarDecl(varDecl: VarDecl) {
        /*
        字段约束：
            1. 以 `_` 开头
            2. 使用 `var` 关键字
            3. 必须显式声明类型
         */
        return varDecl.identifier.value.startsWith("_") && varDecl.keyword.kind == TokenKind.VAR &&
            !varDecl.colon.value.isEmpty()
    }

    private static func normalizeIdentifierName(name: String): String {
        return name.removePrefix("`").removeSuffix("`")
    }
}

public struct DerivedTypeDefinition {
    let derivedType: Tokens
    let typeDiscriminator: String

    public init(derivedType: Tokens, typeDiscriminator: String) {
        this.derivedType = derivedType
        this.typeDiscriminator = typeDiscriminator
    }
}

private struct JsonFieldCatalog {
    let fields: ArrayList<JsonFieldMetadata>
    let declaredFields: ArrayList<JsonFieldMetadata>
    let extensionDataField: ?JsonFieldMetadata

    init(
        fields: ArrayList<JsonFieldMetadata>,
        declaredFields: ArrayList<JsonFieldMetadata>,
        extensionDataField: ?JsonFieldMetadata
    ) {
        this.fields = fields
        this.declaredFields = declaredFields
        this.extensionDataField = extensionDataField
    }
}

extend JsonFieldCatalog {
    public static func parse(
        decl: ClassLikeDecl,
        memberVarDecls: Collection<MacroCallExpr<VarDecl>>
    ): JsonFieldCatalog {
        let fields = ArrayList<JsonFieldMetadata>()
        let declaredFields = ArrayList<JsonFieldMetadata>()
        let extensionDataFields = ArrayList<JsonFieldMetadata>()
        for (member in memberVarDecls) {
            let field = JsonFieldMetadata(member)
            fields.add(field)
            if (field.isExtensionData) {
                extensionDataFields.add(field)
            } else {
                declaredFields.add(field)
            }
        }
        if (extensionDataFields.size > 1) {
            throw ASTException("Only one @JsonExtensionData field is allowed per type.")
        }
        if (let Some(field) <- extensionDataFields.first) {
            validateExtensionDataField(decl, field.member)
            return JsonFieldCatalog(fields, declaredFields, field)
        }
        return JsonFieldCatalog(fields, declaredFields, None)
    }

    public func buildDeclaredReadMatchCases(
        targetName: Token,
        handledResult: Tokens,
        fallbackCase: Tokens
    ): Tokens {
        let cases = TokensBuilder()
        for (field in this.declaredFields) {
            cases.append(field.buildReadCaseTokens(targetName, handledResult)).append(TokenKind.NL)
        }
        cases.append(fallbackCase).append(TokenKind.NL)
        return cases.toTokens()
    }

    public func buildDeclaredFieldPresenceCases(): Tokens {
        let cases = TokensBuilder()
        for (field in this.declaredFields) {
            cases.append(quote(case $(field.getJsonFieldNameToken()) => return true)).append(TokenKind.NL)
        }
        cases.append(quote(case _ => return false)).append(TokenKind.NL)
        return cases.toTokens()
    }

    private static func validateExtensionDataField(decl: ClassLikeDecl, member: MacroCallExpr<VarDecl>): Unit {
        if (decl.isStruct()) {
            throw ASTException("@JsonExtensionData is not supported for struct.")
        }
        if (member.hasJsonPropertyName()) {
            throw ASTException("@JsonExtensionData field does not support @JsonPropertyName.")
        }
    }
}

private struct JsonFieldMetadata {
    let member: MacroCallExpr<VarDecl>
    let backingFieldName: Token
    let propertyName: String
    let dataType: Tokens
    let isNullable: Bool
    let jsonFieldName: ?Token
    let isExtensionData: Bool

    init(member: MacroCallExpr<VarDecl>) {
        let isExtensionData = member.isJsonExtensionData()
        this.member = member
        this.backingFieldName = member.decl.identifier
        this.propertyName = member.getPropertyName()
        this.dataType = member.getDataType()
        this.isNullable = member.decl.declType.getUnderlyingType().isSome()
        this.jsonFieldName = if (isExtensionData) {
            None
        } else {
            Token(TokenKind.STRING_LITERAL, member.getJsonPropertyName())
        }
        this.isExtensionData = isExtensionData
    }

    public func getJsonFieldNameToken(): Token {
        if (let Some(jsonFieldName) <- this.jsonFieldName) {
            return jsonFieldName
        }
        throw ASTException("Internal error: extension data field does not have a declared JSON field name.")
    }

    public func getReadErrorPrefix(): Token {
        Token(TokenKind.STRING_LITERAL, "The '${this.propertyName}' field ")
    }
}

extend JsonFieldMetadata {
    public func buildWriteTokens(): Tokens {
        let jsonFieldName = this.getJsonFieldNameToken()
        if (this.isNullable) {
            return quote(
                match ((this.$(this.backingFieldName).isNone(), options.defaultIgnoreCondition)) {
                    case (true, JsonIgnoreCondition.WhenWritingNull) => ()
                    case _ =>
                        w.writeName($(jsonFieldName))
                        this.$(this.backingFieldName).toJson(w, options)
                }
            )
        }
        return quote(
            w.writeName($(jsonFieldName))
            this.$(this.backingFieldName).toJson(w, options)
        )
    }

    public func buildReadCaseTokens(targetName: Token, handledResult: Tokens): Tokens {
        let jsonFieldName = this.getJsonFieldNameToken()
        return quote(
            case $(jsonFieldName) =>
                $(this.buildReadBodyTokens(targetName))
                $(handledResult)
        )
    }

    private func buildReadBodyTokens(targetName: Token): Tokens {
        let jsonPath = this.getJsonFieldNameToken()
        let readValue = quote(
            try {
                if (let Some(converter) <- options.getConverter<$(this.dataType)>()) {
                    $(targetName).$(this.backingFieldName) = converter.read(r, options)
                } else {
                    $(targetName).$(this.backingFieldName) = $(this.dataType).fromJson(r, options)
                }
            } catch (ex: JsonSerializationException) {
                throw JsonSerializationException($(this.getReadErrorPrefix()) + ex.message, $(jsonPath), ex)
            }
        )
        return quote(
            match (r.peek()) {
                case Some(JsonToken.JsonNull) =>
                    r.skip()
                case _ =>
                    $readValue
            }
        )
    }
}

private struct MacroNamedArguments {
    let macroName: String
    let arguments: HashMap<String, Expr>

    init(macroName: String, arguments: HashMap<String, Expr>) {
        this.macroName = macroName
        this.arguments = arguments
    }
}

extend MacroNamedArguments {
    public static func parse(
        macroDecl: MacroExpandDecl,
        macroName: String,
        exactArgumentCount: Int64,
        countErrorMessage: String,
        invalidArgumentsErrorMessage: String,
        allowedArgumentNames: Array<String>
    ): MacroNamedArguments {
        let arguments = getMacroArguments(macroDecl)
        if (arguments.size != exactArgumentCount) {
            throw ASTException(countErrorMessage)
        }
        if (arguments |> any {argument => argument.colon.value.isEmpty()}) {
            throw ASTException(invalidArgumentsErrorMessage)
        }

        let namedArguments = HashMap<String, Expr>()
        for (argument in arguments) {
            let name = argument.identifier.value
            if (!isAllowedArgumentName(name, allowedArgumentNames)) {
                throw ASTException(invalidArgumentsErrorMessage)
            }
            if (namedArguments.get(name).isSome()) {
                throw ASTException("${macroName} does not allow duplicate argument '${name}'.")
            }
            namedArguments.add(name, argument.expr)
        }
        return MacroNamedArguments(macroName, namedArguments)
    }

    public func requireStringLiteral(name: String): String {
        if (let Some(expr) <- this.arguments.get(name)) {
            return parseStringLiteral(expr)
        }
        throw ASTException("${this.macroName} requires named argument '${name}'.")
    }

    public func requireTypeReference(name: String): Tokens {
        if (let Some(expr) <- this.arguments.get(name)) {
            if (tryGetStringLiteralValue(expr).isSome()) {
                throw ASTException("${this.macroName} requires '${name}' to be a type reference, not a string literal.")
            }
            return expr.toTokens()
        }
        throw ASTException("${this.macroName} requires named argument '${name}'.")
    }

    private static func getMacroArguments(macroDecl: MacroExpandDecl): ArrayList<Argument> {
        let syntheticCallExpr = CallExpr(quote(
            f($(macroDecl.macroAttrs))
        ))
        return syntheticCallExpr.arguments
    }

    private static func isAllowedArgumentName(name: String, allowedArgumentNames: Array<String>): Bool {
        return allowedArgumentNames |> any {allowedName => allowedName == name}
    }

    private func parseStringLiteral(expr: Expr): String {
        if (let Some(value) <- tryGetStringLiteralValue(expr)) {
            return value
        }
        throw ASTException("${this.macroName} only supports string literal arguments.")
    }
}

private struct PolymorphicDefinition {
    let baseTypeName: String
    let typeDiscriminatorPropertyName: String
    let derivedTypes: ArrayList<DerivedTypeDefinition>

    init(baseTypeName: String, typeDiscriminatorPropertyName: String, derivedTypes: ArrayList<DerivedTypeDefinition>) {
        this.baseTypeName = baseTypeName
        this.typeDiscriminatorPropertyName = typeDiscriminatorPropertyName
        this.derivedTypes = derivedTypes
    }
}

extend PolymorphicDefinition {
    public static func parse(
        decl: ClassLikeDecl,
        declMacros: Collection<MacroExpandDecl>,
        derivedTypeDefinitions: ArrayList<DerivedTypeDefinition>
    ): ?PolymorphicDefinition {
        let polymorphicMacro = declMacros |> filter {macroDecl => macroDecl.identifier.value == "JsonPolymorphic"} |> first
        let derivedTypes = collectDerivedTypeDefinitions(declMacros, derivedTypeDefinitions)
        if (derivedTypes.isEmpty()) {
            return None
        }

        if (decl.isStruct()) {
            throw ASTException("@JsonPolymorphic/@JsonDerivedType is not supported for struct.")
        }

        let discriminatorPropertyName = if (let Some(macroDecl) <- polymorphicMacro) {
            parseTypeDiscriminatorPropertyName(macroDecl)
        } else {
            "$type"
        }
        return PolymorphicDefinition(
            decl.getTypeName().toString(),
            discriminatorPropertyName,
            derivedTypes
        )
    }

    public func getUnknownTypeDiscriminatorMessageToken(): Token {
        return Token(
            TokenKind.STRING_LITERAL,
            "Unknown polymorphic type discriminator for '${this.baseTypeName}'."
        )
    }

    private static func parseTypeDiscriminatorPropertyName(macroDecl: MacroExpandDecl): String {
        return MacroNamedArguments.parse(
            macroDecl,
            "@JsonPolymorphic",
            1,
            "@JsonPolymorphic requires exactly one discriminator property name.",
            "@JsonPolymorphic only supports named argument 'typeDiscriminatorPropertyName'.",
            ["typeDiscriminatorPropertyName"]
        ).requireStringLiteral("typeDiscriminatorPropertyName")
    }

    private static func parseDerivedTypeDefinition(macroDecl: MacroExpandDecl): DerivedTypeDefinition {
        let arguments = MacroNamedArguments.parse(
            macroDecl,
            "@JsonDerivedType",
            2,
            "@JsonDerivedType requires exactly two arguments: derived type and discriminator.",
            "@JsonDerivedType only supports named arguments 'derivedType' and 'typeDiscriminator'.",
            ["derivedType", "typeDiscriminator"]
        )
        return DerivedTypeDefinition(
            arguments.requireTypeReference("derivedType"),
            arguments.requireStringLiteral("typeDiscriminator")
        )
    }

    private static func isJsonDerivedTypeDecl(macroDecl: MacroExpandDecl): Bool {
        let name = macroDecl.identifier.value
        return name == "JsonDerivedType" || name.endsWith(".JsonDerivedType")
    }

    private static func collectDerivedTypeDefinitions(
        declMacros: Collection<MacroExpandDecl>,
        derivedTypeDefinitions: ArrayList<DerivedTypeDefinition>
    ): ArrayList<DerivedTypeDefinition> {
        let resolved = ArrayList<DerivedTypeDefinition>()
        for (derivedTypeDefinition in derivedTypeDefinitions) {
            resolved.add(derivedTypeDefinition)
        }
        if (!resolved.isEmpty()) {
            return resolved
        }
        for (macroDecl in declMacros) {
            if (isJsonDerivedTypeDecl(macroDecl)) {
                resolved.add(parseDerivedTypeDefinition(macroDecl))
            }
        }
        return resolved
    }

}
