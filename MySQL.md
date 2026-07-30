# MySQL 数据库连接概述

## 数据库连接信息

- 服务端：MySQL
- 客户端：DBeaver
- Host：localhost
- 数据库端口：3306
- 数据库：hm-mysql
- 账号：root
- 密码：123456

## 数据库表结构 

**user**

| 字段名 | 数据类型 | 说明 |
| --- |
| id | INT PRIMARY KEY AUTO_INCREMENT | 主键,自增 |
| phone_number | varchar(20) | 手机号,必填 |
| account_name | varchar(50) | 账号名/昵称,必填 |
| email | varchar(255) | 邮箱,非必填 |
| password_hash| varchar(100) | 密码,必填 |
| avatar_url | varchar(255) | 头像URL,非必填 |
| current_baby_id | INT | 当前选中的宝宝ID,非必填 |
| create_at | DATETIME | 创建时间,默认当前时间 |
| update_at | DATETIME | 更新时间,默认值是创建时间 |

**baby**

| 字段名 | 数据类型 | 说明 |
| --- |
| id | INT PRIMARY KEY AUTO_INCREMENT | 主键,自增 |
| user_id | INT | 用户ID,外键,关联用户 |
| baby_name | varchar(50) | 宝宝姓名,必填 |
| gender | TINYINT | 性别,必填,1男2女 |
| birth_date | DATE | 出生日期,必填 |
| height | FLOAT | 身高 cm |
| weight | FLOAT | 体重 kg |
| blood_type | TINYINT | 血型,1A2B3AB4O |
| avatar_url | varchar(255) | 宝宝头像URL,非必填 |
| create_at | DATETIME | 创建时间,默认当前时间 |
| update_at | DATETIME | 更新时间,默认值是创建时间 |

**allergy**

| 字段名 | 数据类型 | 说明 |
| --- |
| id | INT PRIMARY KEY AUTO_INCREMENT | 主键,自增 |
| baby_id | INT | 宝宝ID,外键,关联宝宝 |

**medical_record**


**growth_record**
## API 接口

Base URL: `http://localhost:3000`

### Auth (认证)

| 方法 | 路径 | 说明 | 请求体 |
|------|------|------|--------|
| POST | /auth/get-code | 获取验证码 | `{"phoneNumber": "138xxx"}` |
| POST | /auth/register | 注册并登录 | `{"phoneNumber": "138xxx", "code": "1234"}` |
| POST | /auth/login | 登录 | `{"phoneNumber": "138xxx", "code": "1234"}` |

> 返回体包含 `token`，后续请求需在 Header 携带 `Authorization: Bearer <token>`

### User

| 方法 | 路径 | 说明 | 请求体 |
|------|------|------|--------|
| POST | /user | 创建用户 | `{"phoneNumber": "...", "accountName": "..."}` |
| GET | /user/:id | 获取用户 | - |
| PATCH | /user/:id | 更新用户 | `{"accountName": "...", ...}` |
| PATCH | /user/:id/current-baby | 切换当前宝宝 | `{"babyId": 1}` |

### Baby

| 方法 | 路径 | 说明 | 请求体 |
|------|------|------|--------|
| POST | /baby | 创建宝宝 | `{"userId": 1, "babyName": "...", "gender": 1, "birthDate": "2023-01-15", "bloodType": 1}` |
| GET | /baby | 获取所有宝宝 | - |
| GET | /baby/user/:userId | 获取某用户的所有宝宝（返回带 isCurrent 标记） | - |
| GET | /baby/:id | 获取单个宝宝 | - |
| PUT | /baby/:id | 更新宝宝 | `{"babyName": "...", "bloodType": 1, ...}` |
| DELETE | /baby/:id | 删除宝宝 | - |

> blood_type: 1=A, 2=B, 3=AB, 4=O