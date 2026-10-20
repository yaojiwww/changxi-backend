/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

import std.reflect.*
import std.convert.*
import std.collection.*
import std.math.numeric.*

/**
 * @brief 提供将配置数据绑定到对象实例的工具方法。
 */
public class ConfigurationBinder {
    private init() {}

    /**
     * @brief 按泛型目标类型从配置中获取绑定结果。
     * @param configuration 提供配置数据的配置对象。
     * @return 与泛型目标类型匹配的绑定结果；如果无法绑定则返回空。
     */
    public static func get<T>(configuration: IConfiguration): ?T {
        return get(configuration, TypeInfo.of<T>()).flatMap {f => f as T}
    }

    /**
     * @brief 按指定类型信息从配置中获取绑定结果。
     * @param configuration 提供配置数据的配置对象。
     * @param typeInfo 目标结果的类型信息。
     * @return 与目标类型匹配的绑定结果；如果无法绑定则返回空。
     */
    public static func get(configuration: IConfiguration, typeInfo: TypeInfo): ?Any {
        if (let Some(underlyingType) <- Nullable.getUnderlyingType(typeInfo)) {
            if (let Some(value) <- get(configuration, underlyingType)) {
                return createNullableSome(typeInfo, value)
            }
            return None
        }

        if (let Some(value) <- getScalarValue(configuration)) {
            if (let enumTypeInfo: EnumTypeInfo <- typeInfo) {
                return tryCreateEnumValue(enumTypeInfo, value)
            }
            if (let Some(converted) <- tryConvertValue(typeInfo, value)) {
                return converted
            }
        }

        if (typeInfo == TypeInfo.of<Array<String>>()) {
            let values = configuration.getChildren() |> filterMap {f => f.value} |> collectArray
            return if (values.size > 0) {
                values
            } else {
                None
            }
        }
        if (let Some(values) <- tryGetArray<Bool>(configuration, typeInfo)) {
            return values
        }
        if (let Some(values) <- tryGetArray<Int8>(configuration, typeInfo)) {
            return values
        }
        if (let Some(values) <- tryGetArray<Int16>(configuration, typeInfo)) {
            return values
        }
        if (let Some(values) <- tryGetArray<Int32>(configuration, typeInfo)) {
            return values
        }
        if (let Some(values) <- tryGetArray<Int64>(configuration, typeInfo)) {
            return values
        }
        if (let Some(values) <- tryGetArray<UInt8>(configuration, typeInfo)) {
            return values
        }
        if (let Some(values) <- tryGetArray<UInt16>(configuration, typeInfo)) {
            return values
        }
        if (let Some(values) <- tryGetArray<UInt32>(configuration, typeInfo)) {
            return values
        }
        if (let Some(values) <- tryGetArray<UInt64>(configuration, typeInfo)) {
            return values
        }
        if (let Some(values) <- tryGetArray<Float16>(configuration, typeInfo)) {
            return values
        }
        if (let Some(values) <- tryGetArray<Float64>(configuration, typeInfo)) {
            return values
        }
        if (let Some(values) <- tryGetArray<Float32>(configuration, typeInfo)) {
            return values
        }

        if (let classTypeInfo: ClassTypeInfo <- typeInfo) {
            if (!hasConfigurationData(configuration)) {
                return None
            }
            let instance = classTypeInfo.construct([])
            bind(instance, configuration)
            return instance
        }

        return None
    }

    /**
     * @brief 获取指定配置键并按泛型目标类型转换其值。
     * @param configuration 提供配置数据的配置对象。
     * @param name 要读取的配置键名。
     * @return 转换后的配置值；如果配置键不存在或无法转换则返回空。
     */
    public static func getValue<T>(configuration: IConfiguration, name: String): ?T {
        return getValue(configuration, TypeInfo.of<T>(), name).flatMap {f => f as T}
    }

    /**
     * @brief 获取指定配置键并按目标类型转换其值。
     * @param configuration 提供配置数据的配置对象。
     * @param typeInfo 配置值要转换成的目标类型信息。
     * @param name 要读取的配置键名。
     * @return 转换后的配置值；如果配置键不存在则返回空。
     */
    public static func getValue(configuration: IConfiguration, typeInfo: TypeInfo, name: String): ?Any {
        if (let Some(value) <- configuration[name]) {
            return convertValue(typeInfo, value)
        }
        return None
    }

    /**
     * @brief 将配置中的值递归绑定到对象实例。
     * @param instance 要接收绑定结果的对象实例。
     * @param configuration 提供绑定数据的配置对象。
     */
    public static func bind(instance: Any, configuration: IConfiguration): Unit {
        let classTypeInfo = ClassTypeInfo.of(instance)
        bindProperties(instance, classTypeInfo, configuration)
    }

    // -------------------------------------------------------------------------
    // 核心绑定逻辑
    // -------------------------------------------------------------------------

    private static func bindProperties(
        instance: Any,
        classTypeInfo: ClassTypeInfo,
        configuration: IConfiguration
    ): Unit {
        // std 标准库对象通常不应按配置对象递归绑定，避免对库类型做无意义的成员写入。
        if (classTypeInfo.qualifiedName.startsWith("std.")) {
            return
        }

        for (variable in getBindableVariables(instance, classTypeInfo)) {
            if (!variable.isMutable()) {
                continue
            }

            let underlyingType = Nullable.getUnderlyingType(variable.typeInfo)
            if (let Some(underlying) <- underlyingType) {
                tryBindNullable(variable, instance, underlying, configuration)
                continue
            }

            // 以下分支可安全访问 variable.typeInfo
            if (tryBindNested(variable, instance, configuration)) {
                continue
            }
            if (tryBindScalar(variable, instance, configuration)) {
                continue
            }
            tryBindArray(variable, instance, configuration)
        }
    }

    private static func getBindableVariables(instance: Any, classTypeInfo: ClassTypeInfo): Collection<InstanceVariableInfo> {
        if (instance is IConfigurationBinding) {
            return ReflectUtilities.getAllInstanceVariables(classTypeInfo)
        }
        return classTypeInfo.instanceVariables
    }

    private static func setBoundValue(variable: InstanceVariableInfo, instance: Any, value: Any): Unit {
        // 自定义绑定路径优先，可覆盖继承字段等默认反射写回无法处理的场景。
        if (let binding: IConfigurationBinding <- instance) {
            binding.bind(variable.name, value)
            return
        }
        variable.setValue(instance, value)
    }

    // -------------------------------------------------------------------------
    // 嵌套 class 绑定：递归调用 bind
    // -------------------------------------------------------------------------

    private static func tryBindNested(
        variable: InstanceVariableInfo,
        instance: Any,
        configuration: IConfiguration
    ): Bool {
        if (let classTypeInfo: ClassTypeInfo <- variable.typeInfo) {
            let _ = classTypeInfo
            let section = configuration.getSection(variable.name)
            if (!hasChildren(section)) {
                return false
            }
            bind(variable.getValue(instance), section)
            return true
        }
        return false
    }

    // -------------------------------------------------------------------------
    // Nullable(?T) 绑定：解析底层类型值后用 Some(...) 包装再 setValue
    // -------------------------------------------------------------------------

    private static func tryBindNullable(
        variable: InstanceVariableInfo,
        instance: Any,
        underlyingType: TypeInfo,
        configuration: IConfiguration
    ): Unit {
        // ?String 单独处理（String 不经过 tryParse）
        if (underlyingType == TypeInfo.of<String>()) {
            if (let Some(v) <- configuration.getValue<String>(variable.name)) {
                setBoundValue(variable, instance, createNullableSome(variable.typeInfo, v))
            }
            return
        }
        if (underlyingType == TypeInfo.of<Rune>()) {
            if (let Some(v) <- configuration.getValue<Rune>(variable.name)) {
                setBoundValue(variable, instance, createNullableSome(variable.typeInfo, v))
            }
            return
        }

        // ?Parsable<T> 类型逐一尝试；均未匹配时保持原值不变。
        if (tryBindNullableParsable<Bool>(variable, instance, underlyingType, configuration)) {
            return
        }
        if (tryBindNullableParsable<Int8>(variable, instance, underlyingType, configuration)) {
            return
        }
        if (tryBindNullableParsable<Int16>(variable, instance, underlyingType, configuration)) {
            return
        }
        if (tryBindNullableParsable<Int32>(variable, instance, underlyingType, configuration)) {
            return
        }
        if (tryBindNullableParsable<Int64>(variable, instance, underlyingType, configuration)) {
            return
        }
        if (tryBindNullableParsable<UInt8>(variable, instance, underlyingType, configuration)) {
            return
        }
        if (tryBindNullableParsable<UInt16>(variable, instance, underlyingType, configuration)) {
            return
        }
        if (tryBindNullableParsable<UInt32>(variable, instance, underlyingType, configuration)) {
            return
        }
        if (tryBindNullableParsable<UInt64>(variable, instance, underlyingType, configuration)) {
            return
        }
        if (tryBindNullableParsable<Float16>(variable, instance, underlyingType, configuration)) {
            return
        }
        if (tryBindNullableParsable<Float64>(variable, instance, underlyingType, configuration)) {
            return
        }
        if (tryBindNullableParsable<Float32>(variable, instance, underlyingType, configuration)) {
            return
        }
        if (tryBindNullableEnum(variable, instance, underlyingType, configuration)) {
            return
        }

        if (tryBindNullableNested(variable, instance, underlyingType, configuration)) {
            return
        }
    }

    /**
     * @brief 尝试绑定 ?class。
     * @details 仅当配置节包含子节点时才构造实例并递归绑定；标量值不会视为可绑定的嵌套对象。
     */
    private static func tryBindNullableNested(
        variable: InstanceVariableInfo,
        instance: Any,
        underlyingType: TypeInfo,
        configuration: IConfiguration
    ): Bool {
        if (let classTypeInfo: ClassTypeInfo <- underlyingType) {
            let section = configuration.getSection(variable.name)
            if (!hasChildren(section)) {
                return true
            }

            let nested = classTypeInfo.construct([])
            bind(nested, section)
            setBoundValue(variable, instance, createNullableSome(variable.typeInfo, nested))
            return true
        }
        return false
    }

    /**
     * @brief 尝试将配置值绑定到 ?T。
     * @details 类型不匹配返回 false；类型匹配后无论是否成功解析，都视为该分支已处理。
     */
    private static func tryBindNullableParsable<T>(
        variable: InstanceVariableInfo,
        instance: Any,
        underlyingType: TypeInfo,
        configuration: IConfiguration
    ): Bool where T <: Parsable<T> {
        if (underlyingType != TypeInfo.of<T>()) {
            return false
        }
        if (let Some(str) <- configuration.getValue<String>(variable.name)) {
            if (let Some(v) <- tryConvertValue<T>(str)) {
                setBoundValue(variable, instance, createNullableSome(variable.typeInfo, v))
            }
        }
        return true
    }

    /**
     * @brief 尝试绑定 ?enum。
     * @details 当前支持无参枚举构造器，配置值可写为 Constructor 或 Enum.Constructor。
     */
    private static func tryBindNullableEnum(
        variable: InstanceVariableInfo,
        instance: Any,
        underlyingType: TypeInfo,
        configuration: IConfiguration
    ): Bool {
        if (let enumTypeInfo: EnumTypeInfo <- underlyingType) {
            if (let Some(str) <- configuration.getValue<String>(variable.name)) {
                if (let Some(enumValue) <- tryCreateEnumValue(enumTypeInfo, str)) {
                    setBoundValue(variable, instance, createNullableSome(variable.typeInfo, enumValue))
                }
            }
            return true
        }
        return false
    }

    /**
     * @brief 反射构造 Option<T>.Some(value)。
     * @details 反射赋值不会自动把 T 包装成 Option<T>，因此这里显式构造。
     */
    private static func createNullableSome(optionType: TypeInfo, value: Any): Any {
        if (let enumTypeInfo: EnumTypeInfo <- optionType) {
            return enumTypeInfo.getConstructor("Some", argsCount: 1).apply([value])
        }
        throw IllegalTypeException("Expected Option type, but got `${optionType.qualifiedName}`.")
    }

    // -------------------------------------------------------------------------
    // 标量绑定：String + 所有 Parsable 基本类型
    // -------------------------------------------------------------------------

    private static func tryBindScalar(
        variable: InstanceVariableInfo,
        instance: Any,
        configuration: IConfiguration
    ): Bool {
        if (variable.typeInfo == TypeInfo.of<String>()) {
            if (let Some(v) <- configuration.getValue<String>(variable.name)) {
                setBoundValue(variable, instance, v)
            }
            return true
        }
        if (variable.typeInfo == TypeInfo.of<Rune>()) {
            if (let Some(v) <- configuration.getValue<Rune>(variable.name)) {
                setBoundValue(variable, instance, v)
            }
            return true
        }

        if (trySetParsable<Bool>(variable, instance, configuration)) {
            return true
        }
        if (trySetParsable<Int8>(variable, instance, configuration)) {
            return true
        }
        if (trySetParsable<Int16>(variable, instance, configuration)) {
            return true
        }
        if (trySetParsable<Int32>(variable, instance, configuration)) {
            return true
        }
        if (trySetParsable<Int64>(variable, instance, configuration)) {
            return true
        }
        if (trySetParsable<UInt8>(variable, instance, configuration)) {
            return true
        }
        if (trySetParsable<UInt16>(variable, instance, configuration)) {
            return true
        }
        if (trySetParsable<UInt32>(variable, instance, configuration)) {
            return true
        }
        if (trySetParsable<UInt64>(variable, instance, configuration)) {
            return true
        }
        if (trySetParsable<Float16>(variable, instance, configuration)) {
            return true
        }
        if (trySetParsable<Float64>(variable, instance, configuration)) {
            return true
        }
        if (trySetParsable<Float32>(variable, instance, configuration)) {
            return true
        }
        if (tryBindEnum(variable, instance, configuration)) {
            return true
        }

        return false
    }

    /**
     * @brief 尝试将配置值绑定到 T。
     * @details 类型不匹配返回 false；类型匹配后无论是否成功解析，都视为该分支已处理。
     */
    private static func trySetParsable<T>(
        variable: InstanceVariableInfo,
        instance: Any,
        configuration: IConfiguration
    ): Bool where T <: Parsable<T> {
        if (variable.typeInfo != TypeInfo.of<T>()) {
            return false
        }
        if (let Some(str) <- configuration.getValue<String>(variable.name)) {
            if (let Some(v) <- tryConvertValue<T>(str)) {
                setBoundValue(variable, instance, v)
            }
        }
        return true
    }

    /**
     * @brief 尝试绑定 enum。
     * @details 当前支持无参枚举构造器，配置值可写为 Constructor 或 Enum.Constructor。
     */
    private static func tryBindEnum(
        variable: InstanceVariableInfo,
        instance: Any,
        configuration: IConfiguration
    ): Bool {
        if (let enumTypeInfo: EnumTypeInfo <- variable.typeInfo) {
            if (let Some(str) <- configuration.getValue<String>(variable.name)) {
                if (let Some(enumValue) <- tryCreateEnumValue(enumTypeInfo, str)) {
                    setBoundValue(variable, instance, enumValue)
                }
            }
            return true
        }
        return false
    }

    /**
     * @brief 从配置字符串构造枚举实例。
     * @details 当前仅支持无参构造器；找不到或不匹配时返回 None。
     */
    private static func tryCreateEnumValue(enumTypeInfo: EnumTypeInfo, rawValue: String): ?Any {
        let constructorName = normalizeEnumConstructorName(rawValue)
        try {
            return enumTypeInfo.getConstructor(constructorName).apply([])
        } catch (_: Exception) {
            return None
        }
    }

    private static func normalizeEnumConstructorName(rawValue: String): String {
        let trimmed = rawValue.trimAscii()
        if (let Some(idx) <- trimmed.lastIndexOf(".")) {
            return trimmed[idx + 1..]
        }
        return trimmed
    }

    // -------------------------------------------------------------------------
    // 数组绑定：按子配置节点逐项转换并写回。
    // -------------------------------------------------------------------------

    private static func tryBindArray(
        variable: InstanceVariableInfo,
        instance: Any,
        configuration: IConfiguration
    ): Bool {
        if (variable.typeInfo == TypeInfo.of<Array<String>>()) {
            let children = configuration.getSection(variable.name).getChildren()
            let values = children |> filterMap {f => f.value} |> collectArray
            setBoundValue(variable, instance, values)
            return true
        }

        if (trySetArrayParsable<Bool>(variable, instance, configuration)) {
            return true
        }
        if (trySetArrayParsable<Int8>(variable, instance, configuration)) {
            return true
        }
        if (trySetArrayParsable<Int16>(variable, instance, configuration)) {
            return true
        }
        if (trySetArrayParsable<Int32>(variable, instance, configuration)) {
            return true
        }
        if (trySetArrayParsable<Int64>(variable, instance, configuration)) {
            return true
        }
        if (trySetArrayParsable<UInt8>(variable, instance, configuration)) {
            return true
        }
        if (trySetArrayParsable<UInt16>(variable, instance, configuration)) {
            return true
        }
        if (trySetArrayParsable<UInt32>(variable, instance, configuration)) {
            return true
        }
        if (trySetArrayParsable<UInt64>(variable, instance, configuration)) {
            return true
        }
        if (trySetArrayParsable<Float16>(variable, instance, configuration)) {
            return true
        }
        if (trySetArrayParsable<Float64>(variable, instance, configuration)) {
            return true
        }
        if (trySetArrayParsable<Float32>(variable, instance, configuration)) {
            return true
        }

        return false
    }

    private static func trySetArrayParsable<T>(
        variable: InstanceVariableInfo,
        instance: Any,
        configuration: IConfiguration
    ): Bool where T <: Parsable<T> {
        if (variable.typeInfo != TypeInfo.of<Array<T>>()) {
            return false
        }
        let children = configuration.getSection(variable.name).getChildren()
        let values = children |> filterMap {f => f.value} |> filterMap {f => tryConvertValue<T>(f)} |> collectArray
        setBoundValue(variable, instance, values)
        return true
    }

    private static func getScalarValue(configuration: IConfiguration): ?String {
        if (let section: IConfigurationSection <- configuration) {
            return section.value
        }
        return None
    }

    private static func hasConfigurationData(configuration: IConfiguration): Bool {
        if (getScalarValue(configuration).isSome()) {
            return true
        }
        return configuration.getChildren().size > 0
    }

    private static func hasChildren(configuration: IConfiguration): Bool {
        return configuration.getChildren().size > 0
    }

    private static func tryGetArray<T>(configuration: IConfiguration, typeInfo: TypeInfo): ?Array<T> where T <: Parsable<T> {
        if (typeInfo != TypeInfo.of<Array<T>>()) {
            return None
        }
        let values = configuration.getChildren() |> filterMap {f => f.value} |> filterMap {f => tryConvertValue<T>(f)} |>
            collectArray
        return if (values.size > 0) {
            values
        } else {
            None
        }
    }

    private static func convertValue(typeInfo: TypeInfo, value: String): ?Any {
        if (TypeInfo.of<String>() == typeInfo) {
            return value
        }
        if (TypeInfo.of<Bool>() == typeInfo) {
            return Bool.parse(value)
        }
        if (TypeInfo.of<Int8>() == typeInfo) {
            return Int8.parse(value)
        }
        if (TypeInfo.of<UInt8>() == typeInfo) {
            return UInt8.parse(value)
        }
        if (TypeInfo.of<Int16>() == typeInfo) {
            return Int16.parse(value)
        }
        if (TypeInfo.of<UInt16>() == typeInfo) {
            return UInt16.parse(value)
        }
        if (TypeInfo.of<Int32>() == typeInfo) {
            return Int32.parse(value)
        }
        if (TypeInfo.of<UInt32>() == typeInfo) {
            return UInt32.parse(value)
        }
        if (TypeInfo.of<Int64>() == typeInfo) {
            return Int64.parse(value)
        }
        if (TypeInfo.of<UInt64>() == typeInfo) {
            return UInt64.parse(value)
        }
        if (TypeInfo.of<Float16>() == typeInfo) {
            return Float16.parse(value)
        }
        if (TypeInfo.of<Float64>() == typeInfo) {
            return Float64.parse(value)
        }
        if (TypeInfo.of<Float32>() == typeInfo) {
            return Float32.parse(value)
        }
        if (TypeInfo.of<BigInt>() == typeInfo) {
            return BigInt.parse(value)
        }
        if (TypeInfo.of<Decimal>() == typeInfo) {
            return Decimal.parse(value)
        }
        if (TypeInfo.of<Rune>() == typeInfo) {
            return value.toRuneArray().first.getOrThrow()
        }
        // 未命中特定转换规则时，保留原始字符串，让调用方自行决定是否接受。
        return value
    }

    private static func tryConvertValue(typeInfo: TypeInfo, value: String): ?Any {
        try {
            return convertValue(typeInfo, value)
        } catch (_: Exception) {
            return None
        }
    }

    private static func tryConvertValue<T>(value: String): ?T {
        return tryConvertValue(TypeInfo.of<T>(), value).flatMap {f => f as T}
    }
}
