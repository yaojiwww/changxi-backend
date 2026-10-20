#创建测试用户
CREATE USER 'native_user'@'%' IDENTIFIED WITH mysql_native_password BY 'native_user';
CREATE USER 'sha256_user'@'%' IDENTIFIED WITH sha256_password BY 'sha256_user';
CREATE USER 'caching_user'@'%' IDENTIFIED WITH caching_sha2_password BY 'caching_user';
CREATE USER 'test_user'@'%' IDENTIFIED BY 'test_user';
GRANT ALL PRIVILEGES ON driver_test.* TO 'test_user'@'%';

#创建测试数据库
CREATE DATABASE driver_test CHARSET utf8mb4;
USE driver_test;

#数字类型测试表
CREATE TABLE numeric_types (
  `bool_col` tinyint(1) ,             -- bool_col (TINYINT(1), 0/1)
  `bit_col` bit(64) ,                  -- -- bit_col (BIT类型，64位二进制存储，范围: b'0'~b'1111111111111111111111111111111111111111111111111111111111111111')
  `tinyint_col` tinyint ,             -- tinyint_col (有符号TINYINT, 范围: -128~127)
  `utinyint_col` tinyint UNSIGNED ,   -- utinyint_col (无符号TINYINT, 范围: 0~255)
  `smallint_col` smallint,            -- smallint_col (有符号SMALLINT, 范围: -32768~32767)
  `usmallint_col` smallint UNSIGNED , -- usmallint_col (无符号SMALLINT, 范围: 0~65535)
  `mediumint_col` mediumint ,         -- mediumint_col (有符号MEDIUMINT, 范围: -8388608~8388607)
  `umediumint_col` mediumint UNSIGNED,-- umediumint_col (无符号MEDIUMINT, 范围: 0~16777215)
  `int_col` int ,                     -- int_col (有符号INT, 范围: -2147483648~2147483647)
  `uint_col` int UNSIGNED ,           -- uint_col (无符号INT, 范围: 0~4294967295)
  `bigint_col` bigint ,               -- bigint_col (有符号BIGINT, 范围: -2^63~2^63-1)
  `ubigint_col` bigint UNSIGNED,      -- ubigint_col (无符号BIGINT, 范围: 0~2^64-1)
  `float_col` float ,                 -- float_col (单精度浮点数)
  `double_col` double ,               -- double_col (双精度浮点数)
  `decimal_col` decimal(65, 30)       -- decimal_col (精确小数，65位精度，30位小数)
)

#时间类型测试表
CREATE TABLE time_types (
  `date_col` date ,
  `time_col` time ,
  `datetime_col` datetime ,
  `timestamp_col` timestamp,
  `year_col` year
)

#字符类型测试表
CREATE TABLE character_types (
  `char_col` char(255) ,
  `varchar_col` varchar(255) ,
  `tinytext_col` tinytext ,
  `text_col` text,
  `mediumtext_col` mediumtext,
  `longtext_col` longtext,
  `tinyblob_col` tinyblob ,
  `blob_col` blob ,
  `mediumblob_col` mediumblob ,
  `longblob_col` longblob ,
  `json_col` json ,
  `set_col` set('value1','value2','value3','value4','value5'),
  `enum_col` enum('value1','value2','value3','value4','value5')
)
