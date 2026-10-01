-- =============================================================================
-- 畅溪后端 — 聊天消息表
-- 代表"一条聊天记录"（用户问的 / AI 答的），每个会话里有多条
--
-- 依赖：必须先建好 conversation 表（sql/conversation.sql）
-- 执行顺序：user.sql → conversation.sql → message.sql
-- =============================================================================

USE `changxi`;

CREATE TABLE IF NOT EXISTS `message` (
  -- 主键：消息ID
  `id`              BIGINT      NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  -- 属于哪个会话，外键指向 conversation.id（一个会话有多条消息）
  `conversation_id` BIGINT      NOT NULL                COMMENT '所属会话ID',
  -- 角色：user = 用户发的，assistant = AI 回的
  `role`            VARCHAR(20) NOT NULL                COMMENT '角色: user/assistant',
  -- 消息内容（AI 回复可能很长，用 TEXT）
  `content`         TEXT        NOT NULL                COMMENT '消息内容',
  `created_at`      DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

  PRIMARY KEY (`id`),
  KEY `idx_conversation_id` (`conversation_id`),  -- 按会话拉取消息记录要加索引
  CONSTRAINT `fk_message_conversation`
    FOREIGN KEY (`conversation_id`) REFERENCES `conversation` (`id`)
    ON DELETE CASCADE                             -- 会话删除时，消息一起删
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '聊天消息表';
