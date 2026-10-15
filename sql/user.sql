-- =============================================================================
-- 畅溪后端 — 用户表初始化脚本
-- 对应代码：src/infrastructure/repositories/UserRepository.cj、src/domain/entities/User.cj
--
-- 执行方式（容器里已有数据卷，脚本会在首次启动时自动跑一遍）：
--   docker compose exec -T db mariadb -uroot -pchangxi_root < sql/user.sql
-- 或者进容器客户端：
--   docker compose exec db mariadb -uroot -pchangxi_root
--   MariaDB [(none)]> source /docker-entrypoint-initdb.d/user.sql
-- =============================================================================

-- 1. 建库（不存在才建，可重复执行）
CREATE DATABASE IF NOT EXISTS `changxi`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `changxi`;

-- 2. 用户表
-- 注册流程分两步落地，所以"用户信息"三列先给空默认值：
--   步骤一 send-code  → 建行，只填 number + verify_code + code_expire
--   步骤二 register   → 填 password（已验证码，随后清空验证码）
--   步骤三 信息完善   → 填 nickname / real_name / exam_level
CREATE TABLE IF NOT EXISTS `users` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `number`       VARCHAR(20)     NOT NULL                COMMENT '手机号，登录账号',
  `password`     VARCHAR(64)     NOT NULL DEFAULT ''     COMMENT '密码哈希，SHA256 十六进制(64字符)，绝不存明文',
  `verify_code`  VARCHAR(10)     NOT NULL DEFAULT ''     COMMENT '短信验证码，6位数字',
  `code_expire`  BIGINT          NOT NULL DEFAULT 0      COMMENT '验证码过期时间，毫秒时间戳',
  `nickname`     VARCHAR(32)     NOT NULL DEFAULT ''     COMMENT '昵称',
  `real_name`    VARCHAR(32)     NOT NULL DEFAULT ''     COMMENT '真实姓名',
  `exam_level`   TINYINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '报考等级：0未选 1初级 2中级 3高级',
  `created_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                 ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  PRIMARY KEY (`id`),
  -- 手机号唯一：保证"一个手机号一个人"，也让按手机号查询只命中一行
  UNIQUE KEY `uk_number` (`number`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '用户表';
