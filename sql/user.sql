-- =============================================================================
-- 畅溪后端 — 用户表初始化脚本
-- 对应代码：src/db.cj（当前为内存存储，本文件是落地到 MySQL 后的表结构）
--
-- 执行方式：
--   sudo mariadb < sql/user.sql
--   （或进入 mariadb 客户端后执行：source sql/user.sql）
-- =============================================================================

-- 1. 建库（不存在才建，可重复执行，不会报错）
CREATE DATABASE IF NOT EXISTS `changxi`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `changxi`;

-- 2. 用户表
CREATE TABLE IF NOT EXISTS `users` (
  -- 主键：自增用户 ID，对应代码里的 userIds / nextUserId
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  -- 手机号：登录账号，必须唯一，对应 userPhones（代码/接口里字段名是 number）
  `number`       VARCHAR(20)     NOT NULL                COMMENT '手机号',
  -- 密码：存 SHA256 十六进制（64 个字符），对应 userPasswords
  `password`     VARCHAR(64)     NOT NULL DEFAULT ''     COMMENT '密码哈希',
  -- 验证码：6 位数字，对应 userVerifyCodes
  `verify_code`  VARCHAR(10)     NOT NULL DEFAULT ''     COMMENT '短信验证码',
  -- 验证码过期时间：毫秒时间戳，对应 userCodeExpires
  `code_expire`  BIGINT          NOT NULL DEFAULT 0      COMMENT '验证码过期时间(毫秒)',
  -- 下面两个字段代码里还没有，但真实业务表建议加上（可选）
  `created_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                 ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  PRIMARY KEY (`id`),              -- 主键索引
  UNIQUE KEY `uk_number` (`number`)  -- 手机号唯一索引（保证 findUserByNumber 只查到一条）
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '用户表';
