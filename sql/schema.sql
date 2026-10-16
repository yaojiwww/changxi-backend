-- =============================================================================
-- 保育通后端 — 表结构
--
-- 执行方式：
--   容器首次初始化时会自动跑 ./sql 下所有 .sql（docker-compose 把它挂在
--   /docker-entrypoint-initdb.d）。但那个只在**数据卷为空**时执行一次，
--   库已经有数据了就要手动跑：
--     docker compose exec -T db mariadb -uroot -pchangxi_root < sql/schema.sql
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `changxi`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `changxi`;

-- -----------------------------------------------------------------------------
-- 用户表
--
-- 表名 user 在 MariaDB 里是保留字（有个同名的 USER() 函数），
-- 所以这个表名和后面所有 SQL 里的列名都**必须带反引号**，漏一个就报语法错。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `user` (
  `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  -- 登录账号。接口请求体里叫 number，数据库里叫 phone —— 名字不一样是有意的：
  -- 前者跟着前端契约走，后者跟着数据库语义走，映射在 Controller 那一层做。
  --
  -- 宽度为什么是 64 而不是 11（手机号只要 11 位）？
  -- 因为注销账号时要把它改写成 `del_{id}_{原号}` 这种"墓碑值"，好把 UNIQUE 键释放出来，
  -- 让这个手机号能被重新注册。11 位放不下墓碑值——实测会报
  -- "Data too long for column 'phone'"，注销接口直接 500。
  -- 宽一点不浪费：VARCHAR 按实际长度存，不会因为定义成 64 就占 64 字节。
  -- 手机号 11 位的规则由接口层校验（isValidPhone），不靠列宽兜。
  `phone`          VARCHAR(64)     NOT NULL                COMMENT '手机号（注销后改写为 del_{id}_{原号}）',
  -- 只存哈希。算法是 SHA256(盐 + 密码) 迭代多轮，盐每个用户随机生成，
  -- 格式见 src/password.cj（sha256$轮数$盐$摘要）
  `password_hash`  VARCHAR(255)    NOT NULL                COMMENT '密码哈希，绝不存明文',
  `nickname`       VARCHAR(32)     NOT NULL DEFAULT ''     COMMENT '昵称，注册时生成 学员xxxx',
  `avatar_url`     VARCHAR(512)    NOT NULL DEFAULT ''     COMMENT '头像地址',
  -- 预留微信登录。NULL 表示没绑微信；UNIQUE 允许存在多行 NULL（MariaDB 的行为），
  -- 所以"没绑微信的用户"不会互相顶掉唯一键。
  `wechat_openid`  VARCHAR(64)     NULL                    COMMENT '微信 openid，预留',
  `level_index`    TINYINT         NOT NULL DEFAULT 1      COMMENT '备考目标：0初级 1中级 2高级',
  `exam_date`      DATE            NULL                    COMMENT '考试目标日期，NULL=未设置',
  `status`         TINYINT         NOT NULL DEFAULT 0      COMMENT '0正常 1禁用 2已注销',
  -- 登出时 +1，JWT 里带着签发那一刻的值；校验时对不上就是"已被登出"的旧令牌。
  -- 为什么不用黑名单？黑名单要存、要过期清理、要保证所有实例都查得到；自增一个整数全解决了。
  `token_version`  INT             NOT NULL DEFAULT 0      COMMENT '登出时自增，作废旧 JWT',
  `last_login_at`  DATETIME        NULL                    COMMENT '最后登录时间',
  `created_at`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                   ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_phone` (`phone`),
  UNIQUE KEY `uk_wechat_openid` (`wechat_openid`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '用户表';

-- -----------------------------------------------------------------------------
-- 短信验证码表
--
-- 为什么不放在 user 表里两列（verify_code / code_expire）？
--   1. 一个手机号在"注册/换绑/找回密码"三个场景下各要一份码，塞进 user 表就得开三组列；
--   2. user 表是"一个人"，验证码是"一条一次性凭证"，生命周期也完全不同
--      （5 分钟就废、用完要留痕防重放），混在一起将来必炸。
-- 独立成表后，"查这个手机号最新的、没用过的、还没过期的注册码"就是一条 SQL。
-- 注意：这个表**允许同一个手机号有多行**（反复获取验证码就会有多行），
-- 所以 phone 上不能加唯一键，只能加普通索引。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sms_code` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `phone`       VARCHAR(11)     NOT NULL                COMMENT '手机号',
  `code`        VARCHAR(6)      NOT NULL                COMMENT '6位数字验证码',
  `scene`       VARCHAR(20)     NOT NULL                COMMENT '场景：register/change_phone/reset_password',
  `expires_at`  DATETIME        NOT NULL                COMMENT '过期时间 = 签发时间 + 5 分钟',
  `used_at`     DATETIME        NULL                    COMMENT '使用时间，NULL=未使用；写入后不可再用（防重放）',
  `created_at`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '签发时间',

  PRIMARY KEY (`id`),
  -- 索引顺序不能反：查的时候一定带 phone，scene 是次要条件。
  -- 反过来 (scene, phone) 就变成"先按场景筛"，一个场景下有几万行，索引白建。
  KEY `idx_phone_scene` (`phone`, `scene`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '短信验证码表';

-- -----------------------------------------------------------------------------
-- 命令行版遗留的 users 表（字段是 number/verify_code/code_expire），新代码不再使用。
-- 确认库里没有要留的数据之后再手动执行：
--   DROP TABLE IF EXISTS `users`;
-- -----------------------------------------------------------------------------


-- =============================================================================
-- 题库 + 刷题闭环（知识点 / 题目 / 练习记录 / 作答流水 / 错题本 / 收藏）
--
-- 这两段（表结构 + 种子数据）都放在这个文件里，因为 docker-compose 把 ./sql 挂成
-- MariaDB 的初始化目录，加表加题库意味着**开发环境要 down -v 重建数据卷**才会生效。
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 知识点
--
-- 这张表的两套名字要分清：
--   name  —— 纯章节名（「组织饮水」），给后端自己看；
--   label —— 带级别前缀的展示名（「初级 · 组织饮水」），**接口对外一律用 label**。
-- 为什么不让前端自己拿 level_index 去拼前缀？因为错题本/收藏是**按展示名分组**的
-- （见接口 4.5/4.7 的 category），如果拼接规则写在前端，后端返回的分组名和前端
-- 自己算出来的对不上，分组就会莫名其妙裂成两组。所以拼接只在这里做一次，库里的
-- label 就是最终对外字符串。
--
-- kp_id 是**业务码**（kp-beginner-water 这种），不是自增数字：前端本地兜底题库里
-- 内置的就是这套码，将来切真接口时题目要能对上号，用自增 id 就串了。
-- 所以它直接当主键，而不是另加一个自增 id 再在业务码上建唯一键。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `knowledge_point` (
  `kp_id`        VARCHAR(64)  NOT NULL                COMMENT '业务码，与前端一致',
  `name`         VARCHAR(128) NOT NULL                COMMENT '章节名，如 组织饮水',
  `label`        VARCHAR(128) NOT NULL                COMMENT '带级别前缀的展示名，如 初级 · 组织饮水',
  -- -1 是不分级别（法律法规对所有级别都考），0/1/2 对应初级/中级/高级。
  -- 用 -1 而不是 NULL：NULL 在 where level_index = ? 里永远匹配不上，
  -- 接口 4.1 按 level 过滤时会把不分级别的章节整个漏掉。
  `level_index`  INT          NOT NULL                COMMENT '报考级别 -1不分级别 0初级 1中级 2高级',
  `tab`          VARCHAR(32)  NOT NULL                COMMENT '所属页签 basic/professional',
  -- 一级章节为 NULL。目前四个知识点都是平铺的（没有父子关系），
  -- 这一列是给将来「大章 → 小节」留的位置，现在恒为 NULL。
  `parent_kp_id` VARCHAR(64)  NULL                    COMMENT '父章节，一级章节为 NULL',
  `sort_no`      INT          NOT NULL                COMMENT '同级排序',
  -- ★ 这是**知识点题库总题量**（358/67/45/36），不是"这次录进去几道题"。
  -- 前端进度条和「x/N」显示的是这个 N，表示"这个知识点一共有多少题"，
  -- 而实际能抽到的只有 question 表里那几道。这是有意的：题库是逐渐录的，
  -- 总量先按考纲挂上，抽题时有多少给多少。
  `total`        INT          NOT NULL                COMMENT '该知识点题库总题量',
  `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                 ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  PRIMARY KEY (`kp_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '知识点（章节）表';

-- -----------------------------------------------------------------------------
-- 题目
--
-- code 是题目业务码（kp-basic-law-q01），和 knowledge_point.kp_id 一样是对外契约的一部分：
-- 错题本、收藏、作答流水里存的全是 code 而不是自增 id。
-- 为什么要这样？因为前端本地兜底题库用的就是这套码，"先请求接口、失败才本地兜底"
-- 意味着同一道题在两套数据源里都必须有同一个身份，否则将来切真接口时，
-- 用户昨天用兜底数据答错的题今天就对不上了。自增 id 做不到这一点（它只在本库里唯一）。
--
-- 自增 id 仍然保留，纯粹当物理主键用（InnoDB 聚簇索引喜欢短的自增键）。
--
-- 答案和解析**只在这里存一份**，绝不下发（见接口 4.2）——下发一次就等于把题库送出去了，
-- 判题逻辑放在服务端，前端拿不到答案就没法作弊。
--
-- 这里没有加 FK 到 knowledge_point：题库是批量导入的（seed、将来的导入脚本），
-- 有外键约束时导入顺序写错就直接报错，而题目挂错知识点这种事，一条 join 就能查出来。
-- idx_kp 索引负责 join 和"按知识点抽题"这两件事（where kp_id=? and status=1）。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `question` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '自增主键（物理键，对外一律用 code）',
  `code`        VARCHAR(64)  NOT NULL                COMMENT '题目业务码，如 kp-basic-law-q01',
  `kp_id`       VARCHAR(64)  NOT NULL                COMMENT '外键 -> knowledge_point.kp_id',
  `stem`        VARCHAR(1024) NOT NULL               COMMENT '题干',
  `option_a`    VARCHAR(512) NOT NULL                COMMENT 'A 选项文案（不带 A. 前缀）',
  `option_b`    VARCHAR(512) NOT NULL                COMMENT 'B 选项文案',
  `option_c`    VARCHAR(512) NOT NULL                COMMENT 'C 选项文案',
  `option_d`    VARCHAR(512) NOT NULL                COMMENT 'D 选项文案',
  -- 存字母 A/B/C/D 而不是 0-3 下标：出题人写的是字母，导入时不用做一次容易写错的转换。
  -- 转下标这件事只发生在接口出参的那一层（列表类接口回下标，判题类接口回字母）。
  `answer`      CHAR(1)      NOT NULL                COMMENT '正确选项字母 A/B/C/D',
  `explanation` TEXT         NOT NULL                COMMENT '解析',
  -- 目前只有单选。留这一列是为了将来加多选/判断题时，老的查询语句不用改。
  `q_type`      VARCHAR(16)  NOT NULL DEFAULT 'single' COMMENT '题型，当前只有 single',
  -- 下架而不是删除：已经答过这道题的用户，错题本/流水里还引用着它的 code，
  -- 物理删掉 join 就成了空题。下架后抽题抽不到，历史记录照常能 join 出来。
  `status`      TINYINT      NOT NULL DEFAULT 1      COMMENT '1上架 0下架',
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`),
  -- 索引顺序按"查询一定带 kp_id，status 是次要条件"来定，和 sms_code 的 idx_phone_scene 同一个道理
  KEY `idx_kp` (`kp_id`, `status`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '题目表';

-- -----------------------------------------------------------------------------
-- 练习记录（一次交卷 = 一行）
--
-- 为什么要把"一次练习"独立成表，而不是只留逐题流水？
--   ① 练习报告页（正确率、用时、与上次对比）是**按次**统计的，逐题流水里没有"次"的概念；
--   ② "这一次没作答"这种情况在流水里根本不存在（没答就没有行），
--      但报告要显示 accuracy=null，这个信息只能挂在"次"这一层。
--
-- item_id / item_name / practice_type 都是交卷时由服务端按 kpId 查出来的**快照**，
-- 这里存快照是有意的（和 question 的代码不同）：报告页回看历史练习时，
-- 即使将来知识点被改名甚至下架，历史报告也该保持当时的样子。
--
-- accuracy 允许 NULL：交卷时一题没答（前端直接点了提交）正确率是没有定义的，
-- 存 0 会被展示成"考了 0 分"，和"没考"是两回事。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `practice_record` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`       BIGINT       NOT NULL                COMMENT '用户ID',
  -- 前端 batch-submit 的 itemId 查询参数原样落库：将来要"按条目查历史练习"就靠它
  `item_id`       VARCHAR(64)  NOT NULL                COMMENT '练习条目 ID，前端 batch-submit 的 itemId 查询参数',
  `item_name`     VARCHAR(128) NOT NULL                COMMENT '知识条目名，报告页直接用',
  `practice_type` VARCHAR(64)  NOT NULL                COMMENT '如 基础知识·单选练习',
  `correct_count` INT          NOT NULL                COMMENT '答对题数',
  `total`         INT          NOT NULL                COMMENT '本次题数',
  `accuracy`      DECIMAL(5,2) NULL                    COMMENT '正确率百分比；本次没作答时为 NULL',
  `duration`      INT          NOT NULL DEFAULT 0      COMMENT '练习时长秒',
  -- 不让数据库默认 CURRENT_TIMESTAMP：报告页显示的提交时间是**前端那次的时刻**，
  -- 服务端处理延迟不该体现在用户的报告里，所以由应用层显式写入。
  `submit_time`   DATETIME     NOT NULL                COMMENT '提交时间',
  `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

  PRIMARY KEY (`id`),
  -- 取"这个用户上一次练习"（报告页的 compare 字段）就走这个索引：user_id 等值 + submit_time 排序
  KEY `idx_user_time` (`user_id`, `submit_time`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '练习记录表（一次交卷一行）';

-- -----------------------------------------------------------------------------
-- 逐题作答流水（一次交卷 = 若干行）
--
-- 为什么 question_id 存 code 而不是 question.id？
--   和 user 表里 number/phone 的分工相反：那里是"接口名 ≠ 库列名"，这里是
--   "对外身份就是 code"。错题本、收藏、前端本地兜底题库全都用 code 对话，
--   中间再引入一个自增 id 只是多一层映射，没有任何收益。
--
-- user_id 冗余存一份（本该通过 record_id 查出来）：流水表只会越来越大，
-- "某个用户某道题的作答历史"是最常见的查询，多存一列能省一次 join。
-- 这属于有意的反范式，不是漏了。
--
-- correct / correct_option 都在这里存下来：判题那一刻的结论要固化，
-- 将来题库答案改了（勘误），也不能篡改用户"当时答对/答错"的事实。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `practice_answer` (
  `id`             BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `record_id`      BIGINT      NOT NULL                COMMENT '-> practice_record.id',
  `user_id`        BIGINT      NOT NULL                COMMENT '用户ID（反范式，省 join）',
  `question_id`    VARCHAR(64) NOT NULL                COMMENT '题目业务码',
  -- 允许为空串的场景这里不考虑：没作答的题**不写行**，报告里的 total 来自请求体，
  -- 所以"没答的题"在流水里就是不存在，而不是一行空答案。
  `user_answer`    CHAR(1)     NOT NULL                COMMENT '用户所选字母 A/B/C/D',
  `correct`        TINYINT     NOT NULL                COMMENT '是否答对 1/0',
  `correct_option` CHAR(1)     NOT NULL                COMMENT '判题时的正确选项字母',
  `created_at`     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

  PRIMARY KEY (`id`),
  KEY `idx_record` (`record_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '逐题作答流水表';

-- -----------------------------------------------------------------------------
-- 错题本
--
-- ★ 这张表**故意不存题干/选项/答案/知识点**。
--   列表接口要展示的内容全部 join question + knowledge_point 实时取。
--   理由：题库在持续录入和勘误，如果错题本里存了一份快照，改了题干之后
--   错题本里还是老题干，用户看到的和练习时看到的不一致。冗余快照在这种
--   "被引用数据会变"的场景里是负债不是资产（对比 practice_record 的 item_name：
--   那里存快照恰恰是因为那是**历史事实**，不该跟着变）。
--
-- 消除规则（接口 4.6）：重练答对 correct_streak+1，到 3 就 eliminated=1；
-- 答错 correct_streak 归 0、wrong_count+1。为什么用"连续答对 3 次"而不是"答对 1 次"？
-- 一次蒙对不代表掌握，连续三次才算稳定记忆——这个阈值前端 mock 已经实现，
-- 后端必须一致，否则用户体验会前后矛盾。
--
-- eliminated 用标记位而不是物理删除：消除后如果又答错，还要能把它"复活"
-- （correct_streak 归 0、eliminated 归 0），物理删了就得重新 insert，
-- 而且丢了"这题曾经错过几次"的历史。
--
-- uk_user_question 是关键：错题本的写入路径有两条（交卷时批量 upsert、重练时更新），
-- 有唯一键才能用 on duplicate key update 把两条路径都写成一条幂等的 SQL。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `wrong_book` (
  `id`             BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`        BIGINT      NOT NULL                COMMENT '用户ID',
  `question_id`    VARCHAR(64) NOT NULL                COMMENT '题目业务码',
  `wrong_count`    INT         NOT NULL DEFAULT 1      COMMENT '累计答错次数',
  `correct_streak` INT         NOT NULL DEFAULT 0      COMMENT '重练连续答对次数 0-3，达到 3 即消除',
  `eliminated`     TINYINT     NOT NULL DEFAULT 0      COMMENT '1 已消除（不再出现在列表）',
  `source`         VARCHAR(16) NOT NULL DEFAULT 'practice' COMMENT '来源 practice/daily',
  `last_wrong_at`  DATETIME    NOT NULL                COMMENT '最后一次答错时间',
  `created_at`     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP
                   ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  PRIMARY KEY (`id`),
  -- 用户维度 + 题目维度的唯一：同一道题错一百次也只占一行，计数记在 wrong_count 里
  UNIQUE KEY `uk_user_question` (`user_id`, `question_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '错题本';

-- -----------------------------------------------------------------------------
-- 收藏
--
-- 和错题本长得像但**计数语义完全不同**：收藏只有"收没收藏"两个状态，
-- 所以没有 count / streak 这些列，重复 add 是幂等的（UNIQUE 冲突按已收藏处理）。
-- 收藏和错题是两个独立动作，用户可能收藏一道从没错过的题，所以不能合并成一张表。
--
-- favorited_at 是列表接口 4.7 做"今日/近一周"筛选的字段。为什么不复用 created_at？
-- 语义不同：将来如果加了"取消收藏再重新收藏"，用户期望的收藏时间是最后一次收藏的时刻，
-- 而 created_at 是这行数据第一次出现的时刻（取消收藏如果是软删，两者就会分叉）。
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `favorite` (
  `id`           BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`      BIGINT      NOT NULL                COMMENT '用户ID',
  `question_id`  VARCHAR(64) NOT NULL                COMMENT '题目业务码',
  `source`       VARCHAR(16) NOT NULL DEFAULT 'practice' COMMENT '来源 practice/daily',
  `favorited_at` DATETIME    NOT NULL                COMMENT '收藏时间',
  `created_at`   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_question` (`user_id`, `question_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '收藏表';


-- =============================================================================
-- 种子数据（可重复执行）
--
-- 写法对齐 tools/dev-accounts.sql：每条 insert 都带 on duplicate key update，
-- 所以这个文件既能当"首次初始化"跑，也能对着已经在跑的库反复跑——
-- 改一条解析、加一道题，重跑一次就同步过去了，不用先删库。
-- （但表结构改动不在此列：那需要 docker compose down -v 重建数据卷。）
--
-- 注意题目里的单引号：解析文案一律用中文引号“ ”而不是英文 '，
-- 就是为了不用在 SQL 里写转义。加新题时保持这个习惯。
-- =============================================================================

-- —— 知识点 ——
-- total 是考纲题量（358/67/45/36），不是实际录进去的题数，见建表处的说明。
insert into `knowledge_point` (`kp_id`, `name`, `label`, `level_index`, `tab`, `parent_kp_id`, `sort_no`, `total`) values
  ('kp-basic-law',         '相关法律法规及其它试题', '相关法律法规及其它试题', -1, 'basic',        NULL, 1, 358),
  ('kp-beginner-water',    '组织饮水',               '初级 · 组织饮水',        0, 'professional', NULL, 1,  67),
  ('kp-intermediate-meal', '组织进餐',               '中级 · 组织进餐',        1, 'professional', NULL, 1,  45),
  ('kp-advanced-sleep',    '组织睡眠',               '高级 · 组织睡眠',        2, 'professional', NULL, 1,  36)
on duplicate key update
  `name` = values(`name`), `label` = values(`label`), `level_index` = values(`level_index`),
  `tab` = values(`tab`), `parent_kp_id` = values(`parent_kp_id`),
  `sort_no` = values(`sort_no`), `total` = values(`total`);

-- —— 题目 ——
-- 题干和选项取自 cli/quiz.cj（已去掉「N.（单选）」这类题号前缀），
-- 解析取自 docs/知识点练习题(1).docx 的完整版（cli 那版是精简过的）。
-- 题码和答案必须与前端本地兜底题库一致，不能改。
insert into `question` (`code`, `kp_id`, `stem`, `option_a`, `option_b`, `option_c`, `option_d`, `answer`, `explanation`, `q_type`, `status`) values

  -- 基础：相关法律法规及其它试题
  ('kp-basic-law-q01', 'kp-basic-law',
   '根据《托儿所幼儿园卫生保健管理办法》，婴幼儿入园（所）时应当查验的健康证明文件是（ ）',
   '出生医学证明', '儿童入园（所）健康检查表', '预防接种完成证明原件', '体格发育评价报告',
   'B',
   '管理办法规定儿童入园（所）前须经医疗卫生机构健康检查，合格后方可入园，查验的是“儿童入园（所）健康检查表”；预防接种证是入园时同步查验并督促补种的证件，但健康证明的核心是体检合格证明。',
   'single', 1),

  ('kp-basic-law-q02', 'kp-basic-law',
   '依据《未成年人保护法》，未成年人是指未满（ ）周岁的公民。',
   '14', '16', '18', '20',
   'C',
   '《未成年人保护法》第二条：未成年人指未满十八周岁的公民。托育、幼儿园服务对象全部属于未成年人，高频送分题。',
   'single', 1),

  ('kp-basic-law-q03', 'kp-basic-law',
   '根据《食品安全法》，托幼机构食堂制作的食品应当（ ）',
   '每餐样品留存48小时以上，每样不少于125克', '每餐样品留存24小时以上，每样不少于100克',
   '每餐样品留存72小时以上，每样不少于150克', '无需留样，但需做好进货查验记录',
   'A',
   '依据《食品安全法》及《学校食品安全与营养健康管理规定》，每餐食品成品留样，每品种不少于125克、留存48小时以上并记录，目的是发生食源性疾病时可追溯。干扰项常改时间或克数。',
   'single', 1),

  ('kp-basic-law-q04', 'kp-basic-law',
   '依据《托育机构保育指导大纲（试行）》，托育机构保育工作应遵循的基本原则中，不包括以下哪项？（ ）',
   '尊重儿童', '安全健康', '积极回应', '提前教学',
   'D',
   '《托育机构保育指导大纲（试行）》规定四项基本原则：尊重儿童、安全健康、积极回应、科学规范。“提前教学”违背婴幼儿成长规律，托育的定位是照护与早期发展支持，不是提前教小学知识。',
   'single', 1),

  -- 初级：组织饮水
  ('kp-beginner-water-q01', 'kp-beginner-water',
   '组织幼儿饮水时，最适宜的饮用水是（ ）',
   '冰镇凉白开', '温开水', '碳酸饮料', '纯净水替代日常饮水',
   'B',
   '温开水最接近体温、对胃肠刺激最小。冰水刺激肠胃易引起腹痛，饮料含糖高影响食欲和牙齿健康，长期用纯净水替代也不能替代白开水在日常饮水中的地位。',
   'single', 1),

  ('kp-beginner-water-q02', 'kp-beginner-water',
   '幼儿每次饮水前，保育员应先组织幼儿（ ）',
   '排队取杯', '洗手', '漱口', '做安静游戏',
   'B',
   '饮水前洗手是第一顺序，防止手上的污染物沾到杯口。排队取杯是洗手之后的组织环节，出题时常用“取杯”做干扰项，注意先后顺序：洗手→排队→取杯→饮水。',
   'single', 1),

  ('kp-beginner-water-q03', 'kp-beginner-water',
   '保育员为幼儿准备饮用水、判断水温是否适宜的正确方法是（ ）',
   '用嘴直接抿一口试温', '将水滴在自己手腕内侧试温', '用手触摸杯壁外侧即可', '凭经验估计，无需试温',
   'B',
   '手腕内侧皮肤娇嫩、敏感，是试温的标准部位。A项用嘴直接接触幼儿水杯不卫生，C项摸杯壁不能准确判断水温（尤其是保温杯），D项是失职行为。',
   'single', 1),

  -- 中级：组织进餐
  ('kp-intermediate-meal-q01', 'kp-intermediate-meal',
   '幼儿进餐前，保育员对餐桌进行消毒的正确顺序是（ ）',
   '清水擦→消毒液擦→清水擦', '消毒液擦→清水擦→消毒液擦', '清水擦→消毒液擦，无需再清擦', '只需用清水擦一遍即可',
   'A',
   '标准桌面消毒流程是“清—消—清”：先清水擦去浮尘，再用消毒液擦拭并保留作用时间，最后清水擦去残留。这是中级实操的高频考点，顺序不能颠倒。',
   'single', 1),

  ('kp-intermediate-meal-q02', 'kp-intermediate-meal',
   '幼儿进餐过程中，保育员的正确做法是（ ）',
   '对吃得慢的幼儿进行批评，督促其快点吃', '随时添加饭菜，要求幼儿必须吃完',
   '观察幼儿进食情况，鼓励细嚼慢咽，不催食不训斥', '利用进餐时间教育挑食的幼儿，当场点名批评',
   'C',
   '中级考点核心是“回应性照料”态度：观察、鼓励、耐心，反对催食、强制、当众批评。A、B、D都是反面做法。',
   'single', 1),

  ('kp-intermediate-meal-q03', 'kp-intermediate-meal',
   '组织进餐时培养幼儿独立性的做法是（ ）',
   '全部由保育员代劳，幼儿只管吃', '鼓励幼儿力所能及地自取餐具、参与分发餐具，饭后自己清理餐具',
   '让幼儿互相喂饭，锻炼合作能力', '由吃得快的幼儿帮助吃得慢的幼儿喂饭',
   'B',
   '组织进餐不只是“喂饱”，更要培养自理能力：自取餐具、分发餐具、饭后参与收拾，都是适宜的独立性培养。C、D互相喂饭有卫生和安全问题，A剥夺锻炼机会。',
   'single', 1),

  -- 高级：组织睡眠
  ('kp-advanced-sleep-q01', 'kp-advanced-sleep',
   '组织幼儿睡眠前，保育员应首先安排幼儿（ ）',
   '脱衣上床', '排尿', '听故事', '做安静游戏',
   'B',
   '睡前先排尿，防止尿床和起夜干扰睡眠，这是睡眠照料的第一环节；安静活动、听故事等是排尿后帮助入眠的组织手段。',
   'single', 1),

  ('kp-advanced-sleep-q02', 'kp-advanced-sleep',
   '对幼儿睡眠姿势的指导，正确的是（ ）',
   '俯卧压着睡最安稳，不必干预', '仰卧或右侧卧位较好，发现蒙头睡要及时纠正',
   '左侧卧位最有利于消化', '睡姿由幼儿自由选择，蒙头睡也不用管',
   'B',
   '适宜睡姿是仰卧或右侧卧（右侧卧利于胃排空、不压迫心脏）；蒙头睡会导致缺氧，必须及时纠正。俯卧对婴幼儿有捂闷风险。高级考点常结合“睡眠安全”出题。',
   'single', 1),

  ('kp-advanced-sleep-q03', 'kp-advanced-sleep',
   '幼儿睡眠期间，保育员巡视观察的重点不包括（ ）',
   '睡眠姿势与盖被情况', '面色、呼吸是否正常', '是否有遗尿、身体不适等异常', '幼儿入睡的快慢排名并记录名次',
   'D',
   '巡视观察的内容：睡姿、盖被、面色、呼吸、有无遗尿/异常出汗/发热惊厥等，发现异常及时处理并报告保健员。给入睡快慢排名既无照护价值，还会造成心理压力，不是巡视内容。',
   'single', 1)

on duplicate key update
  `kp_id` = values(`kp_id`), `stem` = values(`stem`),
  `option_a` = values(`option_a`), `option_b` = values(`option_b`),
  `option_c` = values(`option_c`), `option_d` = values(`option_d`),
  `answer` = values(`answer`), `explanation` = values(`explanation`),
  `q_type` = values(`q_type`), `status` = values(`status`);
