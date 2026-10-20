// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_claims

/**
 * @brief 定义常用声明值类型常量。
 */
public abstract class ClaimValueTypes {
    private static const XmlSchemaNamespace = "http://www.w3.org/2001/XMLSchema"

    /**
     * @brief 表示 Base64 二进制值类型。
     */
    public static const Base64Binary = XmlSchemaNamespace + "#base64Binary"
    /**
     * @brief 表示 Base64 八位字节值类型。
     */
    public static const Base64Octet = XmlSchemaNamespace + "#base64Octet"
    /**
     * @brief 表示布尔值类型。
     */
    public static const Boolean = XmlSchemaNamespace + "#boolean"
    /**
     * @brief 表示日期值类型。
     */
    public static const Date = XmlSchemaNamespace + "#date"
    /**
     * @brief 表示日期时间值类型。
     */
    public static const DateTime = XmlSchemaNamespace + "#dateTime"
    /**
     * @brief 表示双精度数值类型。
     */
    public static const Double = XmlSchemaNamespace + "#double"
    /**
     * @brief 表示完全限定二进制名值类型。
     */
    public static const Fqbn = XmlSchemaNamespace + "#fqbn"
    /**
     * @brief 表示十六进制二进制值类型。
     */
    public static const HexBinary = XmlSchemaNamespace + "#hexBinary"
    /**
     * @brief 表示整数值类型。
     */
    public static const Integer = XmlSchemaNamespace + "#integer"
    /**
     * @brief 表示安全标识符值类型。
     */
    public static const Sid = XmlSchemaNamespace + "#sid"
    /**
     * @brief 表示字符串值类型。
     */
    public static const String = XmlSchemaNamespace + "#string"
    /**
     * @brief 表示时间值类型。
     */
    public static const Time = XmlSchemaNamespace + "#time"

    private static const SoapSchemaNamespace = "http://schemas.xmlsoap.org/"

    /**
     * @brief 表示 DNS 名称值类型。
     */
    public static const DnsName = SoapSchemaNamespace + "claims/dns"
    /**
     * @brief 表示邮箱地址值类型。
     */
    public static const Email = SoapSchemaNamespace + "ws/2005/05/identity/claims/emailaddress"
    /**
     * @brief 表示 RSA 密钥值类型。
     */
    public static const Rsa = SoapSchemaNamespace + "ws/2005/05/identity/claims/rsa"
    /**
     * @brief 表示 UPN 名称值类型。
     */
    public static const UpnName = SoapSchemaNamespace + "claims/UPN"

    private static const XmlSignatureConstantsNamespace = "http://www.w3.org/2000/09/xmldsig#"

    /**
     * @brief 表示 DSA 密钥值类型。
     */
    public static const DsaKeyValue = XmlSignatureConstantsNamespace + "DSAKeyValue"
    /**
     * @brief 表示密钥信息值类型。
     */
    public static const KeyInfo = XmlSignatureConstantsNamespace + "KeyInfo"
    /**
     * @brief 表示 RSA 公钥值类型。
     */
    public static const RsaKeyValue = XmlSignatureConstantsNamespace + "RSAKeyValue"

    private static const XQueryOperatorsNameSpace = "http://www.w3.org/TR/2002/WD-xquery-operators-20020816"

    /**
     * @brief 表示日间时长值类型。
     */
    public static const DaytimeDuration = XQueryOperatorsNameSpace + "#dayTimeDuration"
    /**
     * @brief 表示年月时长值类型。
     */
    public static const YearMonthDuration = XQueryOperatorsNameSpace + "#yearMonthDuration"

    private static const Xacml10Namespace = "urn:oasis:names:tc:xacml:1.0"

    /**
     * @brief 表示 RFC822 名称值类型。
     */
    public static const Rfc822Name = Xacml10Namespace + ":data-type:rfc822Name"
    /**
     * @brief 表示 X500 名称值类型。
     */
    public static const X500Name = Xacml10Namespace + ":data-type:x500Name"
}
