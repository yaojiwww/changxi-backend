-- =============================================================================
-- 畅溪后端 — 会话表
-- 代表"一次连续对话"，对应聊天接口 api-spec.md 里的 conversationId
--
-- 依赖：必须先建好 users 表（sql/user.sql），因为 user_id 外键指向它
-- 执行顺序：user.sql → conversation.sql → message.sql
-- =============================================================================

USE `changxi`;

CREATE TABLE IF NOT EXISTS `conversation` (
  -- 主键：会话ID（内部用，返回给前端的就是它）
  `id`                   BIGINT       NOT NULL AUTO_INCREMENT COMMENT '会话ID',
  -- 属于哪个用户，外键指向 users.id（一个用户有多个会话）
  -- 注意：类型必须和 users.id 完全一致，users.id 是 UNSIGNED，这里也得是 UNSIGNED
  `user_id`              BIGINT UNSIGNED NOT NULL             COMMENT '所属用户ID',
  -- Dify 侧的会话ID：续聊时要传回给 Dify，用来延续它的上下文
  `dify_conversation_id` VARCHAR(64)  NOT NULL DEFAULT ''     COMMENT 'Dify侧会话ID',
  -- 会话标题（可选，比如取第一句用户消息）
  `title`                VARCHAR(255) NOT NULL DEFAULT ''     COMMENT '会话标题',
  `created_at`           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                         ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),  -- 按"用户的会话列表"查询要加索引
  CONSTRAINT `fk_conversation_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
    ON DELETE CASCADE             -- 用户删除时，他的会话一起删
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '会话表';
