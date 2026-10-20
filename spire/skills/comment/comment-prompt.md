# Cangjie 注释补全提示词

请只为项目中的公共 API 补充文档注释，不要修改任何行为代码、类型签名、参数名、返回类型、可见性或控制流。

## 目标

为公共 API 添加稳定、简洁、可提取的 Cangjie 文档注释，供后续工具抽取 JSON 中间产物并生成 API 文档。

注释内容统一使用中文，如果函数缺失返回类型标注需要补上。

## 处理范围

优先处理这些声明：

- `public class`
- `public struct`
- `public enum`
- `public interface`
- `public type`
- `public func`
- `public init`
- `public prop`
- `public let`
- `public var`
- `public static func`
- `extend` 中的公共成员
- `public class` 中的 `protected init`
- `public class` 中的 `public open func`
- `public class` 中的 `protected open func`

默认不要处理：

- 私有成员
- 局部变量
- 内部辅助函数
- 自动生成代码
- 单元测试代码
- 测试工具代码
- mock、benchmark、fuzz 样例、测试夹具、测试数据构造代码

如果文件、目录、类型或函数明显属于测试用途，也默认跳过。

## 注释规则

每个公共声明至少补一个文档注释块，并至少包含：

- `@brief`

如果声明有参数，必须补：

- `@param`

如果声明有返回值，补：

- `@return`

如果声明可能抛出异常，补：

- `@throws`

必要时补：

- `@description`
- `@since`
- `@deprecated`
- `@see`
- `@note`

文件级注释可补：

- `@file`
- `@brief`
- `@description`
- `@since`
- `@see`
- `@note`

## 标签写法

如果声明前带有语言注解（例如 `@Annotation`、`@When` 等），文档注释块必须放在这些注解的上方，顺序应为：

```cangjie
/**
 * @brief ...
 */
@Annotation[...]
public class Sample {
}
```

标准写法：

```text
@file file purpose text.
@brief Short summary sentence.
@description Optional longer description.
@param name Parameter meaning.
@return Return value meaning.
@throws IllegalArgumentException If the input is invalid.
@since 0.0.0
@deprecated Prefer using Xxx instead.
@see RelatedApi
@note Important usage note.
```

优先使用这些标准标签，不要主动使用别名。

## 句式要求

`@brief`：

- 用一句中文描述 API 做什么
- 推荐句式：`返回...`、`创建...`、`表示...`、`提供...`、`检查是否...`

`@param`：

- 用中文写参数代表什么，不要只重复类型

`@return`：

- 用中文写返回结果的语义，不要只重复类型名

`@throws`：

- 用中文写异常类型和触发条件

## 禁止项

不要做这些事：

1. 不要修改行为代码。
2. 不要编造不存在的异常。
3. 不要编造不存在的返回值语义。
4. 不要给无参函数写 `@param`。
5. 不要给 `Unit` 返回写虚假的复杂说明。
6. 不要把实现细节当成 API 合同来写。
7. 不要写空话，例如 “This function is used to ...”。
8. 不要把语言注解和文档标签混淆，例如 `@Frozen`、`@When`、`@Deprecated` 不是文档注释标签。
9. 不要给单元测试、测试样例或测试辅助代码补文档注释，除非用户明确要求。

## 质量要求

注释必须：

- 简洁
- 准确
- 可读
- 稳定
- 与签名一致
- 使用中文表述

如果无法确定真实语义，就写最保守、最可证实的描述，不要猜。

## 模板

### 类

```cangjie
/**
 * @brief 简短说明这个类的用途。
 * @description 必要时补充更详细的行为说明。
 * @since 0.0.0
 * @see RelatedType
 * @note 必要时写注意事项。
 */
public class Sample {
}
```

### 函数

```cangjie
/**
 * @brief 简短说明这个函数做什么。
 * @description 必要时补充更详细的行为说明。
 * @since 0.0.0
 * @param value 输入值。
 * @return 转换后的结果。
 * @throws IllegalArgumentException 当输入值非法时抛出。
 * @see RelatedApi
 */
public func sample(value: String): String {
    return value
}
```

### 构造函数

```cangjie
/**
 * @brief 创建一个示例实例。
 * @since 0.0.0
 * @param value 初始值。
 * @throws IllegalArgumentException 当初始值非法时抛出。
 */
public init(value: String) {
}
```

### 属性

```cangjie
/**
 * @brief 获取或修改当前级别。
 * @since 0.0.0
 */
public mut prop level: LogLevel {
    get() { ... }
    set(v) { ... }
}
```

### 常量或变量

```cangjie
/**
 * @brief 简短说明这个常量或变量的含义。
 * @since 0.0.0
 */
public let VERSION: String = "1.0.0"
```

## 执行要求

请直接在源码上补注释。

只在需要的声明前添加或完善文档注释。

如果源码已有注释：

- 保留已有真实信息
- 补足缺失标签
- 不要随意重写已有准确内容

如果类型本身是 `public open|abstract class`，则其可供继承或重写的成员也按对外 API 处理：

- `protected init`
- `public open func`
- `protected open func`
- `protected prop`

补充口径：

- 如果命中了 `public class`，必须先检查类本身是否已有类级文档注释。
- 不允许只给该类的 `protected init`、`open` 成员或 `protected prop` 补注释，而遗漏类声明本身的注释。

如果遇到单元测试、测试样例或测试辅助代码：

- 直接跳过
- 不补注释
- 不整理测试描述
