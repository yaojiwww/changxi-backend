# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此代码库中工作时提供指导。

## 项目概述

保育员考试刷题app，内置AI解析和AI助手。
客户端：采用 HarmonyOS NEXT (API 24) 开发，采用 MVVM 架构模式和 V2 状态管理。
服务端：后端使用仓颉（Cangjie）+ Spire 框架，数据库使用 mariadb。

## 项目结构

```text
changxi-backend/                # 后端：仓颉 + Spire
├── src/
│   ├── main.cj                 # 入口：WebHost 配置、中间件管道
│   ├── controllers/            # 控制器：路由入口，参数绑定
│   ├── application/
│   │   ├── commands/           # 命令（CQRS 写）：Command + Handler
│   │   ├── queries/            # 查询（CQRS 读）：Query 对象
│   │   ├── services/           # 业务服务：跨模块复用的逻辑
│   │   ├── models/             # 应用层模型：SearchModel 等
│   │   └── behaviors/          # 管道行为：事务、日志等
│   ├── domain/
│   │   ├── entities/           # 实体：数据库表映射（代码生成）
│   │   ├── models/             # DTO：序列化模型（代码生成）
│   │   └── views/              # 视图实体（代码生成）
│   ├── infrastructure/
│   │   ├── AdminDbContext.cj   # 数据库上下文
│   │   ├── repositories/       # 仓储层
│   │   ├── MapperUtilities.cj  # 对象映射
│   │   ├── UserAccessor.cj     # 当前用户访问器
│   │   └── middlewares/        # 中间件
│   └── abstractions/           # 抽象基类：Entity、QueryModel、PageResult
└── sql/                        # 数据库初始化脚本


<!-- # CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此代码库中工作时提供指导。

## 项目概述

这是一个基于 HarmonyOS NEXT (API 20) 开发的**在线图书管理系统**，采用 MVVM 架构模式和 V2 状态管理。

**应用信息：**
- 包名：`com.xyr.bookmanager`
- 目标 SDK：HarmonyOS 6.0.0 (API Level 20)
- 构建工具：Hvigor (HarmonyOS 构建系统)
- 架构模式：MVVM (Model-View-ViewModel)
- 状态管理：V2 (`@ObservedV2`, `@Trace`, `@ComponentV2`)

## 构建和开发命令

### 构建项目
```bash
# 构建项目（调试模式，默认）
hvigorw assembleHap

# 构建发布版本
hvigorw assembleHap --mode release

# 清理构建产物
hvigorw clean
```

### 运行测试
```bash
# 运行所有单元测试
hvigorw test

# 运行特定模块测试
hvigorw test --module entry
```

### 代码检查
项目使用 `code-linter.json5` 配置的代码检查工具，包含安全性和 TypeScript 规则。检查自动应用于所有 `**/*.ets` 文件（排除测试和构建目录）。

## 项目架构

### 技术栈
- **系统**: HarmonyOS NEXT (API 20)
- **语言**: ArkTS (TypeScript 扩展)
- **框架**: ArkUI (声明式 UI 框架)
- **状态管理**: V2 版本装饰器
  - `@ObservedV2` - 观察者类装饰器
  - `@Trace` - 响应式属性装饰器
  - `@ComponentV2` - V2 组件装饰器
  - `@Param` - V2 组件参数装饰器
  - `@Event` - V2 事件装饰器
- **双向绑定**: 使用 `!!` 语法（严禁使用 `$$`）

### 目录结构
```
entry/src/main/ets/
├── model/
│   └── Book.ets                    # 数据模型：图书实体类
├── view/
│   └── BookItemView.ets            # 视图组件：单行图书展示
├── viewmodel/
│   ├── BookItemViewModel.ets       # 单个图书的视图模型
│   └── BookManagerViewModel.ets    # 全局图书管理视图模型（核心业务逻辑）
└── pages/
    └── BookManagerPage.ets         # 主页面：图书管理界面
```

### 架构分层

#### 1. Model 层 (model/)
**Book.ets** - 图书数据模型
- 字段：`id`, `title`, `author`, `price`, `isBorrowed`
- 纯数据类，无业务逻辑

#### 2. ViewModel 层 (viewmodel/)

**BookItemViewModel.ets**
- 使用 `@ObservedV2` 装饰器
- 使用 `@Trace` 装饰所有属性，实现响应式
- 包装单个 Book 对象

**BookManagerViewModel.ets** - 核心业务逻辑
- 使用 `@ObservedV2` 装饰器
- 状态（`@Trace`）：
  - `bookList: BookItemViewModel[]` - 图书列表
  - `newBookTitle: string` - 新书名输入
  - `newBookAuthor: string` - 新作者输入
  - `newBookPrice: string` - 新价格输入
- 计算属性（getters）：
  - `totalCount` - 总数量
  - `borrowedCount` - 已借出数量
  - `inLibraryCount` - 在馆数量
  - `totalValue` - 总价值
- 方法：
  - `addBook()` - 添加图书（含验证）
  - `deleteBook(id)` - 删除图书
  - `toggleBorrowed(id)` - 切换借阅状态
  - `clearAll()` - 清空列表

#### 3. View 层 (view/ & pages/)

**BookItemView.ets** - 图书列表项组件
- 使用 `@ComponentV2` 装饰器
- 接收 `@Param bookVM: BookItemViewModel` 参数
- 定义 `@Event` 事件回调：
  - `onToggle: (id: number) => void` - 借阅/归还
  - `onDelete: (id: number) => void` - 删除
- 显示图书信息和操作按钮

**BookManagerPage.ets** - 主页面
- 使用 `@Entry` 和 `@ComponentV2` 装饰器
- 实例化 `BookManagerViewModel`
- UI 包含：
  - 统计信息面板（总数、在馆、已借出、总价值）
  - 添加新书表单（书名、作者、价格输入）
  - 图书列表（使用 `ForEach` 渲染）
- 双向绑定使用 `!!` 语法：
  ```typescript
  TextInput({ text: this.vm.newBookTitle!! })
  ```

## 重要开发规则

### V2 装饰器使用规则

⚠️ **关键规则：V2 装饰器不需要导入！**

HarmonyOS 的 V2 装饰器是**内置全局装饰器**，直接使用即可，**严禁**导入以下内容：

```typescript
// ❌ 错误 - 不要这样导入
import { ObservedV2, Trace } from '@arkts-ts/decorators';
import { ComponentV2, Param, Event } from '@arkts-ts/decorators';

// ✅ 正确 - 直接使用，无需导入
@ObservedV2
export class MyViewModel {
  @Trace myProperty: string = '';
}

@ComponentV2
export struct MyComponent {
  @Param myParam: string = '';
  @Event onMyEvent: () => void = () => {};
}
```

### V1 vs V2 装饰器对比

| 功能 | V1 装饰器 | V2 装饰器 |
|------|----------|----------|
| 类观察者 | `@Observed` | `@ObservedV2` |
| 属性追踪 | `@Track` | `@Trace` |
| 组件 | `@Component` | `@ComponentV2` |
| 参数 | `@Prop` | `@Param` |
| 事件 | 无 | `@Event` |

**本项目统一使用 V2 装饰器！**

### 双向绑定语法

```typescript
// ✅ 正确 - 使用 !!
TextInput({ text: this.vm.property!! })

// ❌ 错误 - 不要使用 $$
TextInput({ text: $$this.vm.property })
```

### MVVM 架构分层规则

⚠️ **关键规则：严格遵守 MVVM 分层，禁止跨层依赖！**

**依赖方向：**
```
View 层 (pages/, view/) → ViewModel 层 (viewmodel/) → Model 层 (model/)
```

**禁止的依赖：**
- ❌ View 层不能直接依赖 Model 层
- ❌ View 层不能直接创建 Model 对象
- ✅ View 层只能依赖 ViewModel 层
- ✅ ViewModel 层可以依赖 Model 层

**常见错误示例：**

```typescript
// ❌ 错误 - View 层直接导入 Model
import { Book } from '../model/Book';

@ComponentV2
export struct BookItemView {
  @Param bookVM: BookItemViewModel = new BookItemViewModel(new Book(0, '', '', 0, false));
}

// ❌ 错误 - 使用无类型对象字面量（ArkTS 限制）
@ComponentV2
export struct BookItemView {
  @Param bookVM: BookItemViewModel = new BookItemViewModel({ id: 0, title: '', author: '', price: 0, isBorrowed: false });
}

// ✅ 正确 - 使用 ViewModel 层的静态工厂方法
@ComponentV2
export struct BookItemView {
  @Param bookVM: BookItemViewModel = BookItemViewModel.createEmpty();
}
```

**解决方案：在 ViewModel 层提供静态工厂方法**

```typescript
// BookItemViewModel.ets
@ObservedV2
export class BookItemViewModel {
  constructor(book: Book) {
    // ...
  }

  // 提供静态工厂方法，封装 Model 创建逻辑
  static createEmpty(): BookItemViewModel {
    const emptyBook = new Book(0, '', '', 0, false);
    return new BookItemViewModel(emptyBook);
  }
}
```

**架构优势：**
- View 层不依赖 Model 层，降低耦合
- 创建逻辑封装在 ViewModel 层，职责清晰
- 代码更易测试和维护

## 数据流向

```
用户交互 (BookManagerPage)
    ↓
事件回调触发
    ↓
ViewModel 方法 (BookManagerViewModel)
    ↓
修改 @Trace 状态
    ↓
自动触发 UI 更新
    ↓
视图刷新 (BookItemView)
```

## 应用启动流程

1. **EntryAbility.ets** (`entry/src/main/ets/entryability/EntryAbility.ets:25`)
   - 加载主页面：`windowStage.loadContent('pages/BookManagerPage')`
   - 应用启动入口

2. **BookManagerPage.ets** 初始化
   - 创建 `BookManagerViewModel` 实例
   - 渲染 UI 界面

3. **数据绑定**
   - 输入框绑定到 ViewModel 的输入状态
   - 列表绑定到 `bookList` 数组
   - 按钮绑定到 ViewModel 方法

## 资源管理

- 资源位置：`entry/src/main/resources/`
- 资源引用语法：
  - 字符串：`$string:resource_name`
  - 图片：`$media:resource_name`
  - 尺寸：`$float:resource_name`
- 主题支持：base（默认）和 dark（深色模式）

## 日志系统

应用使用 `hilog` 进行日志记录：
- Domain: `0x0000`
- Tag: `'testTag'`
- 格式化：`%{public}s`（公开字符串）

## 常见任务

### 添加新的图书字段
1. 在 `Book.ets` 添加字段
2. 在 `BookItemViewModel.ets` 添加 `@Trace` 属性
3. 在 `BookManagerViewModel.ets` 更新输入状态和验证逻辑
4. 在 `BookItemView.ets` 添加 UI 显示
5. 在 `BookManagerPage.ets` 添加输入框

### 添加新的统计功能
1. 在 `BookManagerViewModel.ets` 添加 getter 方法
2. 在 `BookManagerPage.ets` 的统计面板显示

### 修改页面样式
- `BookManagerPage.ets` - 主页面布局
- `BookItemView.ets` - 列表项样式
- 使用 ArkUI 的样式属性：`.fontSize()`, `.backgroundColor()`, `.margin()` 等

## 应用功能清单

✅ **已实现功能：**
- 添加图书（书名、作者、价格验证）
- 删除图书
- 借阅/归还状态切换
- 清空图书列表
- 实时统计（总数、在馆、已借出、总价值）
- 响应式 UI 更新
- 表单输入验证（非空、数字验证） -->
