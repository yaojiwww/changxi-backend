/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.annotations

import soulsoft_web_openapi.metadata.*

/**
 * @brief 为控制器或动作提供 OpenAPI 元数据。
 */
@Annotation[target: [MemberFunction, Type, MemberProperty, MemberVariable, Parameter]]
public class OpenApi <: IApiTagsMetadata & IApiNameMetadata & IApiGroupNameProvider & IApiDescriptionMetadata & IApiSummaryMetadata & IApiVisibilityProvider {
    private let _ignore: Bool
    private let _name: ?String
    private let _tags: ?String
    private let _summary: ?String
    private let _groupName: ?String
    private let _description: ?String

    /**
     * @brief 创建 OpenAPI 注解实例。
     * @param name API 名称。
     * @param ignore 是否忽略当前 API。
     * @param summary API 摘要。
     * @param groupName API 分组名称。
     * @param description API 描述。
     * @param tags API 标签字符串。
     */
    public const init(name!: ?String = None, ignore!: Bool = false, summary!: ?String = None,
        groupName!: ?String = None, description!: ?String = None, tags!: ?String = None) {
        _tags = tags
        _name = name
        _ignore = ignore
        _summary = summary
        _groupName = groupName
        _description = description
    }

    /**
     * @brief 返回 API 标签字符串。
     * @return 当前 API 的标签字符串。
     */
    public prop tags: ?String {
        get() {
            _tags
        }
    }

    /**
     * @brief 返回 API 名称。
     * @return 当前 API 的名称。
     */
    public prop name: ?String {
        get() {
            _name 
        }
    }

    /**
     * @brief 返回当前 API 是否应被忽略。
     * @return 如果当前 API 需要从文档中忽略则返回 `true`。
     */
    public prop ignore: Bool {
        get() {
            _ignore
        }
    }

    /**
     * @brief 返回 API 摘要信息。
     * @return 当前 API 的摘要信息。
     */
    public prop summary: ?String {
        get() {
            _summary
        }
    }

    /**
     * @brief 返回 API 分组名称。
     * @return 当前 API 的分组名称。
     */
    public prop groupName: ?String {
        get() {
            _groupName
        }
    }

    /**
     * @brief 返回 API 描述信息。
     * @return 当前 API 的描述信息。
     */
    public prop description: ?String {
        get() {
            _description
        }
    }
}
