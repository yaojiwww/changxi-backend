-- =============================================================================
-- 开发用测试账号（**仅开发环境**，别在生产库执行）
--
-- 为什么要单独一个文件、而且不放在 sql/ 目录下？
--   因为 docker-compose 把 ./sql 挂成了 MariaDB 的初始化目录，
--   放进去的话**每次新建数据卷都会自动执行**——生产上第一次起库就会凭空多出
--   这 6 个密码已知的账号。放在 tools/ 就只在你想用的时候手动执行。
--
-- 什么时候用：前端要联调登录，但注册流程还没做通，需要现成账号。
-- 怎么执行（数据库已经在跑的情况下）：
--   docker compose exec -T db mariadb -uroot -pchangxi_root changxi < tools/dev-accounts.sql
--
-- 密码统一 123456，哈希是用 src/password.cj 里同一套算法（sha256 + 随机盐 + 12000 轮）
-- 现算出来的，所以这些账号走的是和注册完全一样的校验路径，不是数据库里塞的伪数据。
-- 每条都是幂等的：手机号已存在就重置密码、昵称和状态，不会插出重复账号。
-- =============================================================================

insert into `user` (phone, password_hash, nickname) values ('13812345678', 'sha256$12000$y9URNXuD5UfRL765-FJiyg$CoXKev84junC5J_HDVwHiwkiL5BZOlf4OHbVeuhFnLw', '学员5678') on duplicate key update password_hash = values(password_hash), nickname = values(nickname), status = 0;
insert into `user` (phone, password_hash, nickname) values ('13998765432', 'sha256$12000$6z8400N6Oc0qph4bMuqu6A$-JQI1NwHioiHpJVEuCoKzwELg3QK8mWOf5UIJtOmg5o', '学员5432') on duplicate key update password_hash = values(password_hash), nickname = values(nickname), status = 0;
insert into `user` (phone, password_hash, nickname) values ('15012348888', 'sha256$12000$1dVwePkaspQw1qT0ySvRnA$cUfpM5t-pBIVfOWOceRzhhS9FWnhvKCCKNfMCp3OGLI', '学员8888') on duplicate key update password_hash = values(password_hash), nickname = values(nickname), status = 0;
insert into `user` (phone, password_hash, nickname) values ('18612340001', 'sha256$12000$b_kalXi16wRwi5bP24FIcA$KYxBQZkMVWvFoUSW64vIgqoiZvr7PklTN8aD6HtGL84', '学员0001') on duplicate key update password_hash = values(password_hash), nickname = values(nickname), status = 0;
insert into `user` (phone, password_hash, nickname) values ('17701234567', 'sha256$12000$0LEKDOXxNeqUOKqoS2xWCg$JBpbN3xaCCi8nbRaJdKaOR7BxZISwFaVCD-DEiG79ck', '学员4567') on duplicate key update password_hash = values(password_hash), nickname = values(nickname), status = 0;
insert into `user` (phone, password_hash, nickname) values ('13800001111', 'sha256$12000$hITDECIl86RJPYaRzvP2sA$ROtOu2uFA5KReg5FLgawni9klb8oBEFD-9dIuxtwZG8', '学员1111') on duplicate key update password_hash = values(password_hash), nickname = values(nickname), status = 0;
