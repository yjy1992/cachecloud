-- MySQL dump 10.15  Distrib 10.0.16-MariaDB, for Linux (x86_64)
--
-- Host: localhostDatabase: cachecloud_open
-- ------------------------------------------------------
-- Server version	10.0.16-MariaDB-log

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

--
-- Table structure for table `app_audit`
--

DROP TABLE IF EXISTS `app_audit`;
CREATE TABLE `app_audit` (
 `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
 `app_id` bigint(20) NOT NULL COMMENT '应用id',
 `user_id` bigint(20) NOT NULL COMMENT '申请人的id',
 `user_name` varchar(64) NOT NULL COMMENT '用户名',
 `type` tinyint(4) NOT NULL COMMENT '申请类型:0:申请应用,1:应用扩容,2:修改配置',
 `param1` varchar(600) DEFAULT NULL COMMENT '预留参数1',
 `param2` varchar(600) DEFAULT NULL COMMENT '预留参数2',
 `param3` varchar(600) DEFAULT NULL COMMENT '预留参数3',
 `info` varchar(360) NOT NULL COMMENT '申请描述',
 `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0:等待审批; 1:审批通过; -1:驳回',
 `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 `modify_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 `refuse_reason` varchar(360) DEFAULT NULL COMMENT '驳回理由',
 `task_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '任务id',
 `operate_id` bigint(20) DEFAULT NULL COMMENT '工单处理人',
 PRIMARY KEY (`id`),
 KEY `idx_appid` (`app_id`),
 KEY `idx_create_time` (`create_time`),
 KEY `idx_status_create_time` (`status`,`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='应用审核表' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `app_audit_log`
--

DROP TABLE IF EXISTS `app_audit_log`;
CREATE TABLE `app_audit_log` (
 `id` bigint(20) NOT NULL AUTO_INCREMENT,
 `app_id` bigint(20) NOT NULL COMMENT '应用id',
 `user_id` bigint(20) NOT NULL COMMENT '审批操作人id',
 `info` longtext NOT NULL COMMENT 'app审批的详细信息',
 `type` tinyint(4) NOT NULL,
 `create_time` datetime NOT NULL,
 `app_audit_id` bigint(20) NOT NULL COMMENT '审批id',
 PRIMARY KEY (`id`),
 KEY `idx_audit_appid` (`app_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='app审核日志表' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `app_client_command_minute_statistics`
--

DROP TABLE IF EXISTS `app_client_command_minute_statistics`;
CREATE TABLE `app_client_command_minute_statistics` (
`id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
`current_min` bigint(20) NOT NULL COMMENT '统计时间',
`client_ip` varchar(20) NOT NULL COMMENT '客户端ip',
`app_id` bigint(20) NOT NULL COMMENT '应用id',
`command` varchar(20) NOT NULL COMMENT '命令明文',
`cost` bigint(20) DEFAULT NULL COMMENT '命令累计毫秒耗时',
`bytes_in` bigint(20) DEFAULT NULL COMMENT '输入流量',
`bytes_out` bigint(20) DEFAULT NULL COMMENT '输出流量',
`create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
`count` int(11) DEFAULT NULL,
PRIMARY KEY (`id`),
UNIQUE KEY `idx__appid_client_command_currentMin` (`app_id`,`client_ip`,`command`,`current_min`),
KEY `idx_currentmin_appid_count_cost` (`current_min`,`app_id`,`count`,`cost`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='客户端每分钟命令调用上报数据';

--
-- Table structure for table `app_client_exception_minute_statistics`
--

DROP TABLE IF EXISTS `app_client_exception_minute_statistics`;
CREATE TABLE `app_client_exception_minute_statistics` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `current_min` bigint(20) NOT NULL COMMENT '统计时间',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `client_ip` varchar(20) NOT NULL COMMENT '客户端ip',
  `type` tinyint(4) NOT NULL COMMENT '0:connect exception;1:command exception',
  `app_id` bigint(20) DEFAULT NULL COMMENT '应用id',
  `node` varchar(30) NOT NULL COMMENT '节点信息host:port',
  `count` bigint(20) DEFAULT NULL COMMENT '累计连接失败次数',
  `cost` bigint(20) DEFAULT NULL COMMENT '累计连接失败毫秒耗时',
  `latency_commands` varchar(255) DEFAULT NULL COMMENT '统计命令topN id,逗号分隔',
  `redis_pool_config` varchar(255) DEFAULT NULL COMMENT 'redis连接池配置信息',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx__client_node_type_currentMin` (`client_ip`,`node`,`type`,`current_min`),
  KEY `idx_appid_current_min` (`app_id`,`current_min`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='客户端每分钟异常上报数据';

--
-- Table structure for table `app_client_latency_command`
--

DROP TABLE IF EXISTS `app_client_latency_command`;
CREATE TABLE `app_client_latency_command` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `command` varchar(255) NOT NULL COMMENT '命令明文',
  `size` bigint(20) DEFAULT NULL COMMENT '参数长度',
  `args` varchar(255) DEFAULT NULL COMMENT '裁剪后参数明文',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `invoke_time` bigint(20) DEFAULT NULL COMMENT '命令调用时间戳',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='客户端异常命令调用详情';

--
-- Table structure for table `app_client_statistic_gather`
--

DROP TABLE IF EXISTS `app_client_statistic_gather`;
CREATE TABLE `app_client_statistic_gather` (
   `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
   `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
   `gather_time` varchar(20) NOT NULL COMMENT '统计时间，格式yyyy-mm-dd',
   `app_id` bigint(20) NOT NULL COMMENT '应用id',
   `cmd_count` bigint(20) DEFAULT '0' COMMENT '命令调用次数',
   `conn_exp_count` bigint(20) DEFAULT '0' COMMENT '连接异常次数',
   `avg_cmd_cost` double DEFAULT '0' COMMENT '命令调用平均耗时，单位毫秒',
   `avg_cmd_exp_cost` double DEFAULT '0' COMMENT '命令超时平均耗时，单位毫秒',
   `avg_conn_exp_cost` double DEFAULT '0' COMMENT '连接异常平均耗时，单位毫秒',
   `cmd_exp_count` bigint(20) DEFAULT '0' COMMENT '命令超时次数',
   `instance_count` int(11) DEFAULT NULL COMMENT '应用实例数',
   `avg_mem_frag_ratio` double DEFAULT NULL COMMENT '平均碎片率',
   `mem_used_ratio` double DEFAULT NULL COMMENT '内存使用率',
   `exception_count` bigint(20) DEFAULT '0' COMMENT '异常数（旧，待下线）',
   `slow_log_count` bigint(20) DEFAULT '0' COMMENT '慢查询次数',
   `latency_count` bigint(20) DEFAULT '0' COMMENT '延迟事件次数',
   `object_size` bigint(20) DEFAULT '0' COMMENT '存储对象数',
   `used_memory` bigint(20) DEFAULT '0' COMMENT '内存占用 byte',
   `used_memory_rss` bigint(20) DEFAULT '0' COMMENT '物理内存占用 byte',
   `max_cpu_sys` bigint(20) DEFAULT '0' COMMENT '进程系统态消耗(单位:秒)',
   `max_cpu_user` bigint(20) DEFAULT '0' COMMENT '进程用户态消耗(单位:秒)',
   `connected_clients` bigint(20) DEFAULT '0' COMMENT '应用客户端连接数',
   `topology_exam_result` tinyint(4) DEFAULT NULL COMMENT '拓扑诊断结果，0：正常，1：异常',
   PRIMARY KEY (`id`),
   UNIQUE KEY `idx_appid_gathertime` (`app_id`,`gather_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='客户端上报数据全天统计';

--
-- Table structure for table `app_client_value_minute_stat`
--

DROP TABLE IF EXISTS `app_client_value_minute_stat`;
CREATE TABLE `app_client_value_minute_stat` (
`id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
`app_id` bigint(20) NOT NULL COMMENT '应用appid',
`collect_time` bigint(20) NOT NULL COMMENT '数据收集时间yyyyMMddHHmm00',
`update_time` datetime NOT NULL COMMENT '更新时间',
`command` varchar(20) NOT NULL COMMENT '执行命令',
`distribute_type` tinyint(4) NOT NULL COMMENT '值分布',
`count` int(11) NOT NULL COMMENT '命令执行次数',
PRIMARY KEY (`id`),
UNIQUE KEY `app_collect_command_dis` (`app_id`,`collect_time`,`command`,`distribute_type`),
KEY `idx_collect_time` (`collect_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='客户端每分钟值分布上报数据统计';

--
-- Table structure for table `app_client_version_statistic`
--

DROP TABLE IF EXISTS `app_client_version_statistic`;
CREATE TABLE `app_client_version_statistic` (
`id` bigint(20) NOT NULL AUTO_INCREMENT,
`app_id` bigint(20) NOT NULL COMMENT '应用id',
`client_ip` varchar(20) NOT NULL COMMENT '客户端ip地址',
`client_version` varchar(20) NOT NULL COMMENT '客户端版本',
`report_time` datetime DEFAULT NULL COMMENT '上报时间',
PRIMARY KEY (`id`),
UNIQUE KEY `app_client_ip` (`app_id`,`client_ip`),
KEY `app_id` (`app_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='客户端上报版本信息统计' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `app_daily`
--

DROP TABLE IF EXISTS `app_daily`;
CREATE TABLE `app_daily` (
 `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增id',
 `app_id` bigint(20) NOT NULL COMMENT '应用id',
 `date` date NOT NULL COMMENT '日期',
 `create_time` datetime NOT NULL,
 `slow_log_count` bigint(20) NOT NULL COMMENT '慢查询个数',
 `client_exception_count` bigint(20) NOT NULL COMMENT '客户端异常个数',
 `max_minute_client_count` bigint(20) NOT NULL COMMENT '每分钟最大客户端连接数',
 `avg_minute_client_count` bigint(20) NOT NULL COMMENT '每分钟平均客户端连接数',
 `max_minute_command_count` bigint(20) NOT NULL COMMENT '每分钟最大命令数',
 `avg_minute_command_count` bigint(20) NOT NULL COMMENT '每分钟平均命令数',
 `avg_hit_ratio` double NOT NULL COMMENT '平均命中率',
 `min_minute_hit_ratio` double NOT NULL COMMENT '每分钟最小命中率',
 `max_minute_hit_ratio` double NOT NULL COMMENT '每分钟最大命中率',
 `avg_used_memory` bigint(20) NOT NULL COMMENT '最大内存使用量',
 `max_used_memory` bigint(20) NOT NULL COMMENT '平均内存使用量',
 `expired_keys_count` bigint(20) NOT NULL COMMENT '过期键个数',
 `evicted_keys_count` bigint(20) NOT NULL COMMENT '剔除键个数',
 `avg_minute_net_input_byte` double NOT NULL COMMENT '每分钟平均网络input量',
 `max_minute_net_input_byte` double NOT NULL COMMENT '每分钟最大网络input量',
 `avg_minute_net_output_byte` double NOT NULL COMMENT '每分钟平均网络output量',
 `max_minute_net_output_byte` double NOT NULL COMMENT '每分钟最大网络output量',
 `avg_object_size` bigint(20) NOT NULL COMMENT '键个数平均值',
 `max_object_size` bigint(20) NOT NULL COMMENT '键个数最大值',
 `big_key_times` bigint(20) NOT NULL COMMENT 'bigkey次数',
 `big_key_info` varchar(512) COLLATE utf8_bin NOT NULL COMMENT 'bigkey详情',
 `client_cmd_count` bigint(20) NOT NULL COMMENT '累计命令调用次数',
 `client_avg_cmd_cost` double NOT NULL COMMENT '平均命令调用耗时',
 `client_conn_exp_count` bigint(20) NOT NULL COMMENT '累计连接异常事件次数',
 `client_avg_conn_exp_cost` double NOT NULL COMMENT '平均连接异常事件耗时',
 `client_cmd_exp_count` bigint(20) NOT NULL COMMENT '累计命令超时事件次数',
 `client_avg_cmd_exp_cost` double NOT NULL COMMENT '平均命令超时事件耗时',
 PRIMARY KEY (`id`),
 KEY `idx_appid_date` (`app_id`,`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='app日报';

--
-- Table structure for table `app_data_migrate_status`
--

DROP TABLE IF EXISTS `app_data_migrate_status`;
CREATE TABLE `app_data_migrate_status` (
   `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增id',
   `migrate_machine_ip` varchar(255) NOT NULL COMMENT '迁移工具所在机器ip',
   `migrate_machine_port` int(11) NOT NULL COMMENT '迁移工具所占port',
   `source_migrate_type` tinyint(4) NOT NULL COMMENT '源迁移类型,0:single,1:redis cluster,2:rdb file,3:twemproxy',
   `source_servers` varchar(2048) NOT NULL COMMENT '源实例列表',
   `target_migrate_type` tinyint(4) NOT NULL COMMENT '目标迁移类型,0:single,1:redis cluster,2:rdb file,3:twemproxy',
   `target_servers` varchar(2048) NOT NULL COMMENT '目标实例列表',
   `source_app_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '源应用id',
   `target_app_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '目标应用id',
   `user_id` bigint(20) NOT NULL COMMENT '操作人',
   `status` tinyint(4) NOT NULL COMMENT '迁移执行状态,0:开始,1:结束,2:异常',
   `start_time` datetime NOT NULL COMMENT '迁移开始执行时间',
   `end_time` datetime DEFAULT NULL COMMENT '迁移结束执行时间',
   `log_path` varchar(255) NOT NULL COMMENT '日志文件路径',
   `config_path` varchar(255) NOT NULL COMMENT '配置文件路径',
   `migrate_id` varchar(50) DEFAULT NULL COMMENT 'migrate id',
   `migrate_tool` tinyint(4) DEFAULT NULL COMMENT 'migrate_tool, 0:redis-shake,1:redis-migrate-tool',
   `redis_source_version` varchar(20) DEFAULT NULL,
   `redis_target_version` varchar(20) DEFAULT NULL,
   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='应用迁移记录详情';

--
-- Table structure for table `app_desc`
--

DROP TABLE IF EXISTS `app_desc`;
CREATE TABLE `app_desc` (
`app_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '应用id',
`name` varchar(36) NOT NULL COMMENT '应用名',
`user_id` bigint(20) NOT NULL COMMENT '申请人id',
`status` tinyint(4) NOT NULL COMMENT '应用状态, 0未分配，1申请未审批，2审批并发布 3:应用下线',
`intro` varchar(255) NOT NULL COMMENT '应用描述',
`create_time` datetime NOT NULL COMMENT '创建时间',
`passed_time` datetime NOT NULL COMMENT '审批通过时间',
`type` int(10) NOT NULL DEFAULT '0' COMMENT 'cache类型，1. memcached, 2. redis-cluster, 3. memcacheq, 4. 非cache-cloud ,5. redis-sentinel ,6.redis-standalone ',
`officer` varchar(32) NOT NULL COMMENT '负责人，中文',
`ver_id` int(11) NOT NULL COMMENT '版本',
`is_test` tinyint(4) DEFAULT '0' COMMENT '是否测试：1是0否',
`need_persistence` tinyint(4) DEFAULT '1' COMMENT '是否需要持久化: 1是0否',
`need_hot_back_up` tinyint(4) DEFAULT '1' COMMENT '是否需要热备: 1是0否',
`has_back_store` tinyint(4) DEFAULT '1' COMMENT '是否有后端数据源: 1是0否',
`forecase_qps` int(11) DEFAULT NULL COMMENT '预估qps',
`forecast_obj_num` int(11) DEFAULT NULL COMMENT '预估条目数',
`mem_alert_value` int(11) DEFAULT NULL COMMENT '内存报警阀值',
`client_machine_room` varchar(36) DEFAULT NULL COMMENT '客户端机房信息',
`client_conn_alert_value` int(11) DEFAULT '2000' COMMENT '客户端连接报警阀值',
`app_key` varchar(255) DEFAULT NULL COMMENT '应用秘钥',
`important_level` tinyint(4) NOT NULL DEFAULT '2' COMMENT '应用级别，1:最重要，2:一般重要，3:一般',
`password` varchar(255) DEFAULT '' COMMENT 'redis密码',
`hit_precent_alert_value` int(11) DEFAULT '0' COMMENT '命中率报警阀值 0:不报警 ',
`is_access_monitor` int(11) DEFAULT '0' COMMENT '是否接入全局监控报警 默认0,0:不接入监控 1:接入监控',
`app_fsync_value` int(11) DEFAULT '1' COMMENT '应用刷盘策略 1:主从节点appdendfsync=everysec 2:主从节点 appdendfsync=no',
`version_id` int(11) NOT NULL DEFAULT '1' COMMENT 'Redis版本表主键id',
PRIMARY KEY (`app_id`),
UNIQUE KEY `uidx_app_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='app应用描述' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `app_hour_command_statistics`
--

DROP TABLE IF EXISTS `app_hour_command_statistics`;
CREATE TABLE `app_hour_command_statistics` (
   `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
   `app_id` bigint(20) NOT NULL COMMENT '应用id',
   `collect_time` bigint(20) NOT NULL COMMENT '统计时间:格式yyyyMMddHH',
   `command_name` varchar(60) NOT NULL COMMENT '命令名称',
   `command_count` bigint(20) NOT NULL COMMENT '命令执行次数',
   `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
   `modify_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
   PRIMARY KEY (`id`),
   UNIQUE KEY `app_id` (`app_id`,`command_name`,`collect_time`),
   KEY `idx_create_time` (`create_time`),
   KEY `idx_modify_time` (`modify_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='应用的每小时命令统计' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `app_hour_statistics`
--

DROP TABLE IF EXISTS `app_hour_statistics`;
CREATE TABLE `app_hour_statistics` (
   `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
   `app_id` bigint(20) NOT NULL COMMENT '应用id',
   `collect_time` bigint(20) NOT NULL COMMENT '收集时间:格式yyyyMMddHH',
   `hits` bigint(20) NOT NULL COMMENT '每小时命中数量和',
   `misses` bigint(20) NOT NULL COMMENT '每小时未命中数量和',
   `command_count` bigint(20) DEFAULT '0' COMMENT '命令总数',
   `used_memory` bigint(20) NOT NULL COMMENT '每小时内存占用最大值',
   `used_memory_rss` bigint(20) NOT NULL DEFAULT '0' COMMENT '物理内存占用',
   `expired_keys` bigint(20) NOT NULL COMMENT '每小时过期key数量和',
   `evicted_keys` bigint(20) NOT NULL COMMENT '每小时驱逐key数量和',
   `net_input_byte` bigint(20) DEFAULT '0' COMMENT '网络输入字节',
   `net_output_byte` bigint(20) DEFAULT '0' COMMENT '网络输出字节',
   `connected_clients` int(10) NOT NULL COMMENT '每小时客户端连接数最大值',
   `object_size` bigint(20) NOT NULL COMMENT '每小时存储对象数最大值',
   `cpu_sys` bigint(20) DEFAULT '0' COMMENT '进程系统态消耗',
   `cpu_user` bigint(20) DEFAULT '0' COMMENT '进程用户态消耗',
   `cpu_sys_children` bigint(20) DEFAULT '0' COMMENT '子进程系统态消耗',
   `cpu_user_children` bigint(20) DEFAULT '0' COMMENT '子进程用户态消耗',
   `accumulation` int(10) NOT NULL DEFAULT '0' COMMENT '每小时参与累加实例数最小值',
   `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
   `modify_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '每小时修改时间最大值',
   PRIMARY KEY (`id`),
   UNIQUE KEY `app_id` (`app_id`,`collect_time`),
   KEY `idx_create_time` (`create_time`) USING BTREE,
   KEY `idx_modify_time` (`modify_time`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='应用统计数据每小时统计' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `app_minute_command_statistics`
--

DROP TABLE IF EXISTS `app_minute_command_statistics`;
CREATE TABLE `app_minute_command_statistics` (
 `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
 `app_id` bigint(20) NOT NULL COMMENT '应用id',
 `collect_time` bigint(20) NOT NULL COMMENT '统计时间:格式yyyyMMddHHmm',
 `command_name` varchar(60) NOT NULL COMMENT '命令名称',
 `command_count` bigint(20) NOT NULL COMMENT '命令执行次数',
 `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
 `modify_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
 PRIMARY KEY (`id`),
 UNIQUE KEY `app_id` (`app_id`,`collect_time`,`command_name`),
 KEY `idx_create_time` (`create_time`),
 KEY `idx_modify_time` (`modify_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='应用的每分钟命令统计' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `app_minute_statistics`
--

DROP TABLE IF EXISTS `app_minute_statistics`;
CREATE TABLE `app_minute_statistics` (
 `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
 `app_id` bigint(20) NOT NULL COMMENT '应用id',
 `collect_time` bigint(20) NOT NULL COMMENT '收集时间:格式yyyyMMddHHmm',
 `hits` bigint(20) NOT NULL COMMENT '命中数量',
 `misses` bigint(20) NOT NULL COMMENT '未命中数量',
 `command_count` bigint(20) DEFAULT '0' COMMENT '命令总数',
 `used_memory` bigint(20) NOT NULL COMMENT '内存占用',
 `used_memory_rss` bigint(20) NOT NULL DEFAULT '0' COMMENT '物理内存占用',
 `expired_keys` bigint(20) NOT NULL COMMENT '过期key数量',
 `evicted_keys` bigint(20) NOT NULL COMMENT '驱逐key数量',
 `net_input_byte` bigint(20) DEFAULT '0' COMMENT '网络输入字节',
 `net_output_byte` bigint(20) DEFAULT '0' COMMENT '网络输出字节',
 `connected_clients` int(10) NOT NULL COMMENT '客户端连接数',
 `object_size` bigint(20) NOT NULL COMMENT '每分钟存储对象数最大值',
 `cpu_sys` bigint(20) DEFAULT '0' COMMENT '进程系统态消耗',
 `cpu_user` bigint(20) DEFAULT '0' COMMENT '进程用户态消耗',
 `cpu_sys_children` bigint(20) DEFAULT '0' COMMENT '子进程系统态消耗',
 `cpu_user_children` bigint(20) DEFAULT '0' COMMENT '子进程用户态消耗',
 `accumulation` int(10) NOT NULL DEFAULT '0' COMMENT '参与累加实例数',
 `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
 `modify_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
 PRIMARY KEY (`id`),
 UNIQUE KEY `app_id` (`app_id`,`collect_time`),
 KEY `idx_create_time` (`create_time`) USING BTREE,
 KEY `idx_modify_time` (`modify_time`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- Table structure for table `app_to_user`
--

DROP TABLE IF EXISTS `app_to_user`;
CREATE TABLE `app_to_user` (
   `id` bigint(20) NOT NULL AUTO_INCREMENT,
   `user_id` bigint(20) NOT NULL COMMENT '用户id',
   `app_id` bigint(20) NOT NULL COMMENT '应用id',
   PRIMARY KEY (`id`),
   KEY `app_id` (`app_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `app_user`
--

DROP TABLE IF EXISTS `app_user`;
CREATE TABLE `app_user` (
`id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
`name` varchar(64) NOT NULL COMMENT '用户名',
`ch_name` varchar(255) NOT NULL COMMENT '中文名',
`email` varchar(64) NOT NULL COMMENT '邮箱',
`mobile` varchar(16) NOT NULL COMMENT '手机',
`type` int(4) NOT NULL DEFAULT '2' COMMENT '0管理员，1预留，2普通用户，-1无效',
`weChat` varchar(32) DEFAULT NULL COMMENT '微信号',
`isAlert` tinyint(4) NOT NULL DEFAULT '1' COMMENT '用户是否接收报警 0:不接收 1:接收',
`password` varchar(64) DEFAULT NULL COMMENT '密码',
`register_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
`purpose` varchar(255) DEFAULT NULL COMMENT '使用目的',
`company` varchar(255) DEFAULT NULL COMMENT '公司名称',
PRIMARY KEY (`id`),
UNIQUE KEY `uidx_user_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户表' /* `compression`='tokudb_zlib' */;

-- ----------------------------
--  Records of `app_user`
-- ----------------------------
BEGIN;
INSERT INTO `app_user` VALUES ('1', 'admin', 'admin', 'admin@xxx.com', '13500000000', '0', null, '1', NULL, current_timestamp(), NULL, NULL);
COMMIT;

--
-- Table structure for table `brevity_schedule_resources`
--

DROP TABLE IF EXISTS `brevity_schedule_resources`;
CREATE TABLE `brevity_schedule_resources` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `type` tinyint(4) NOT NULL COMMENT '类型,见:BrevityScheduleType',
  `version` bigint(20) NOT NULL DEFAULT '0' COMMENT '时间版本',
  `host` varchar(16) NOT NULL COMMENT '资源ip',
  `port` int(11) NOT NULL DEFAULT '0' COMMENT '端口',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_type_host_port` (`type`,`host`,`port`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='短频任务表';

--
-- Table structure for table `diagnostic_task_record`
--

DROP TABLE IF EXISTS `diagnostic_task_record`;
CREATE TABLE `diagnostic_task_record` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `app_id` bigint(20) DEFAULT NULL COMMENT '应用id',
  `type` int(11) DEFAULT NULL COMMENT '诊断类型：0scan 1bigkey 2idle key 3hotkey 4del key 5slot analysis 6topology exam',
  `task_id` bigint(20) DEFAULT NULL COMMENT '任务流id',
  `audit_id` bigint(20) DEFAULT NULL COMMENT '审批id',
  `status` int(11) DEFAULT NULL COMMENT '诊断状态：0开始 1结束 2异常',
  `cost` bigint(20) DEFAULT NULL COMMENT '耗时，毫秒',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `modify_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `redis_key` varchar(100) DEFAULT NULL COMMENT '结果的key',
  `node` varchar(100) DEFAULT NULL COMMENT '实例，host:port',
  `parent_task_id` bigint(20) DEFAULT NULL COMMENT '父任务id',
  `diagnostic_condition` varchar(100) DEFAULT NULL COMMENT '诊断条件',
  `param1` varchar(100) DEFAULT NULL COMMENT '备用参数1',
  `param2` varchar(100) DEFAULT NULL COMMENT '备用参数2',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='应用诊断记录';

--
-- Table structure for table `instance_alert_configs`
--

DROP TABLE IF EXISTS `instance_alert_configs`;
CREATE TABLE `instance_alert_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `alert_config` varchar(255) NOT NULL COMMENT '报警配置',
  `alert_value` varchar(512) NOT NULL COMMENT '报警阀值',
  `config_info` varchar(255) NOT NULL COMMENT '配置说明',
  `type` tinyint(4) NOT NULL COMMENT '1:全局报警,2:实例报警',
  `instance_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '0:全局配置，其他代表实例id',
  `status` tinyint(4) NOT NULL COMMENT '1:可用,0:不可用',
  `compare_type` tinyint(4) NOT NULL COMMENT '比较类型：1小于,2等于,3大于,4不等于',
  `check_cycle` tinyint(4) NOT NULL COMMENT '1:一分钟,2:五分钟,3:半小时4:一个小时,5:一天',
  `update_time` datetime NOT NULL COMMENT '报警配置更新时间',
  `last_check_time` datetime NOT NULL COMMENT '上次检查时间',
  `important_level` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '重要程度（0：一般；1：重要；2：紧急）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_index` (`type`,`instance_id`,`alert_config`,`compare_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='实例报警阀值配置';

-- ----------------------------
--  Records of `instance_alert_configs`
-- ----------------------------
BEGIN;
INSERT INTO `instance_alert_configs` VALUES ('9', 'aof_current_size', '6000', 'aof当前尺寸(单位：MB)', '1', '0', '1', '3', '3', '2017-06-19 09:43:22', '2020-09-17 10:52:00', 0), ('10', 'aof_delayed_fsync', '3', '分钟aof阻塞个数', '1', '0', '1', '3', '1', '2017-06-19 10:38:19', '2020-09-17 11:09:00', 1), ('11', 'client_biggest_input_buf', '10', '输入缓冲区最大buffer大小(单位：MB)', '1', '0', '1', '3', '1', '2017-06-19 10:47:03', '2020-09-17 11:09:00', 1), ('12', 'client_longest_output_list', '50000', '输出缓冲区最大队列长度', '1', '0', '1', '3', '1', '2017-06-19 10:55:45', '2020-09-17 11:09:00', 1), ('13', 'instantaneous_ops_per_sec', '60000', '实时ops', '1', '0', '1', '3', '1', '2017-06-19 11:02:38', '2020-09-17 11:09:00', 1),('14', 'latest_fork_usec', '400000', '上次fork所用时间(单位：微秒)', '1', '0', '1', '3', '5', '2017-06-19 11:21:35', '2020-09-16 16:51:00', 1), ('15', 'mem_fragmentation_ratio', '1.5', '内存碎片率(检测大于500MB)', '1', '0', '1', '3', '5', '2017-06-19 12:49:16', '2020-09-16 16:51:00', 0), ('16', 'rdb_last_bgsave_status', 'ok', '上一次bgsave状态', '1', '0', '1', '4', '4', '2017-06-19 14:15:21', '2020-09-17 10:19:00', 0), ('17', 'total_net_output_bytes', '5000', '分钟网络输出流量(单位：MB)', '1', '0', '1', '3', '1', '2017-06-19 16:39:44', '2020-09-17 11:09:00', 0), ('19', 'total_net_input_bytes', '1200', '分钟网络输入流量(单位：MB)', '1', '0', '1', '3', '1', '2017-06-19 16:45:44', '2020-09-17 11:09:00', 0), ('20', 'sync_partial_err', '0', '分钟部分复制失败次数', '1', '0', '1', '3', '1', '2017-06-19 18:34:41', '2020-09-17 11:09:00', 1), ('21', 'sync_partial_ok', '0', '分钟部分复制成功次数', '1', '0', '1', '3', '1', '2017-06-19 18:35:01', '2020-09-17 11:09:00', 1), ('22', 'sync_full', '0', '分钟全量复制执行次数', '1', '0', '1', '3', '1', '2017-06-19 18:35:17', '2020-09-17 11:09:00', 1), ('23', 'rejected_connections', '0', '分钟拒绝连接数', '1', '0', '1', '3', '1', '2017-06-19 18:35:36', '2020-09-17 11:09:00', 2), ('54', 'master_slave_offset_diff', '20000000', '主从节点偏移量差(单位：字节)', '1', '0', '1', '3', '2', '2017-06-20 18:58:56', '2020-09-17 11:06:00', 0), ('56', 'cluster_state', 'ok', '集群状态', '1', '0', '1', '4', '1', '2017-06-21 18:01:52', '2020-09-17 11:09:00', 2), ('57', 'cluster_slots_ok', '16384', '集群成功分配槽个数', '1', '0', '1', '4', '1', '2017-06-21 18:02:04', '2020-09-17 11:09:00', 2);
COMMIT;

--
-- Table structure for table `instance_big_key`
--

DROP TABLE IF EXISTS `instance_big_key`;
CREATE TABLE `instance_big_key` (
`id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
`instance_id` bigint(20) NOT NULL COMMENT '实例的id',
`app_id` bigint(20) NOT NULL COMMENT 'app id',
`audit_id` bigint(20) NOT NULL COMMENT 'audit id',
`role` tinyint(255) NOT NULL COMMENT '主从，1主2从，详见InstanceRoleEnum',
`ip` varchar(32) NOT NULL COMMENT 'ip',
`port` int(11) NOT NULL COMMENT 'port',
`big_key` varchar(255) NOT NULL COMMENT '键',
`type` varchar(16) NOT NULL COMMENT '类型:string,hash,list,set,zset',
`length` int(11) NOT NULL COMMENT '长度',
`create_time` datetime NOT NULL COMMENT '记录创建时间',
PRIMARY KEY (`id`),
KEY `idx_app_audit` (`app_id`,`audit_id`),
KEY `idx_app_create_time` (`app_id`,`create_time`),
KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='实例bigkey列表';

--
-- Table structure for table `instance_config`
--

DROP TABLE IF EXISTS `instance_config`;
CREATE TABLE `instance_config` (
   `id` int(11) NOT NULL AUTO_INCREMENT,
   `config_key` varchar(128) NOT NULL COMMENT '配置名',
   `config_value` varchar(512) NOT NULL COMMENT '配置值',
   `info` varchar(512) NOT NULL COMMENT '配置说明',
   `update_time` datetime NOT NULL COMMENT '更新时间',
   `type` mediumint(9) NOT NULL COMMENT '类型：2.cluster节点特殊配置, 5:sentinel节点配置, 6:redis普通节点',
   `status` tinyint(4) NOT NULL COMMENT '1有效,0无效',
   `version_id` int(11) NOT NULL COMMENT 'Redis版本表主键id',
   `refresh` mediumint(9) DEFAULT '0' COMMENT '是否可重置：0不可，1可重置',
   PRIMARY KEY (`id`),
   UNIQUE KEY `uniq_configkey_type_version_id` (`config_key`,`type`,`version_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='实例配置模板';

-- ----------------------------
--  Records of `instance_config`
-- ----------------------------
BEGIN;
INSERT INTO `instance_config` VALUES ('1', 'cluster-enabled', 'yes', '是否开启集群模式', '2016-07-05 15:08:30', '2', '1', '29', '0'), ('2', 'cluster-node-timeout', '15000', '集群节点超时时间,默认15秒', '2016-07-05 15:08:30', '2', '1', '29', '0'), ('3', 'cluster-slave-validity-factor', '10', '从节点延迟有效性判断因子,默认10秒', '2016-07-05 15:08:30', '2', '1', '29', '0'), ('4', 'cluster-migration-barrier', '1', '主从迁移至少需要的从节点数,默认1个', '2016-07-05 15:08:30', '2', '1', '29', '0'), ('5', 'cluster-config-file', 'nodes-%d.conf', '集群配置文件名称,格式:nodes-{port}.conf', '2016-07-05 15:08:30', '2', '1', '29', '0'), ('6', 'cluster-require-full-coverage', 'no', '节点部分失败期间,其他节点是否继续工作', '2016-07-05 15:08:31', '2', '1', '29', '0'), ('7', 'port', '%d', 'sentinel实例端口', '2016-07-05 15:08:31', '5', '1', '29', '0'), ('8', 'dir', '%s', '工作目录', '2016-07-05 15:08:31', '5', '1', '29', '0'), ('9', 'sentinel monitor', '%s %s %d 1', 'master名称定义和最少参与监控的sentinel数,格式:masterName ip port num', '2016-07-05 15:08:31', '5', '1', '29', '0'), ('10', 'sentinel down-after-milliseconds', '%s 20000', 'Sentinel判定服务器断线的毫秒数', '2016-07-05 15:08:31', '5', '1', '29', '0'), ('11', 'sentinel failover-timeout', '%s 180000', '故障迁移超时时间,默认:3分钟', '2016-07-05 15:08:31', '5', '1', '29', '0'), ('12', 'sentinel parallel-syncs', '%s 1', '在执行故障转移时,最多有多少个从服务器同时对新的主服务器进行同步,默认:1', '2016-07-05 15:08:31', '5', '1', '29', '0'), ('13', 'daemonize', 'no', '是否守护进程', '2016-07-14 14:00:05', '6', '1', '29', '0'), ('14', 'tcp-backlog', '511', 'TCP连接完成队列', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('15', 'timeout', '0', '客户端闲置多少秒后关闭连接,默认为0,永不关闭', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('16', 'tcp-keepalive', '60', '检测客户端是否健康周期,默认关闭', '2016-12-06 11:40:46', '6', '1', '29', '0'), ('17', 'loglevel', 'notice', '日志级别', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('18', 'databases', '16', '可用的数据库数，默认值为16个,默认数据库为0', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('19', 'dir', '%s', 'redis工作目录', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('20', 'stop-writes-on-bgsave-error', 'no', 'bgsave出错了不停写', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('21', 'repl-timeout', '60', 'master批量数据传输时间或者ping回复时间间隔,默认:60秒', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('22', 'repl-ping-slave-period', '10', '指定slave定期ping master的周期,默认:10秒', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('23', 'repl-disable-tcp-nodelay', 'no', '是否禁用socket的NO_DELAY,默认关闭，影响主从延迟', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('24', 'repl-backlog-size', '10M', '复制缓存区,默认:1mb,配置为:10Mb', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('25', 'repl-backlog-ttl', '7200', 'master在没有Slave的情况下释放BACKLOG的时间多久:默认:3600,配置为:7200', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('26', 'slave-serve-stale-data', 'yes', '当slave服务器和master服务器失去连接后，或者当数据正在复制传输的时候，如果此参数值设置“yes”，slave服务器可以继续接受客户端的请求', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('27', 'slave-read-only', 'yes', 'slave服务器节点是否只读,cluster的slave节点默认读写都不可用,需要调用readonly开启可读模式', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('28', 'slave-priority', '100', 'slave的优先级,影响sentinel/cluster晋升master操作,0永远不晋升', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('29', 'lua-time-limit', '5000', 'Lua脚本最长的执行时间，单位为毫秒', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('30', 'slowlog-log-slower-than', '10000', '慢查询被记录的阀值,默认10毫秒', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('31', 'slowlog-max-len', '128', '最多记录慢查询的条数', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('32', 'hash-max-ziplist-entries', '512', 'hash数据结构优化参数', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('33', 'hash-max-ziplist-value', '64', 'hash数据结构优化参数', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('34', 'list-max-ziplist-entries', '512', 'list数据结构优化参数', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('35', 'list-max-ziplist-value', '64', 'list数据结构优化参数', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('36', 'set-max-intset-entries', '512', 'set数据结构优化参数', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('37', 'zset-max-ziplist-entries', '128', 'zset数据结构优化参数', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('38', 'zset-max-ziplist-value', '64', 'zset数据结构优化参数', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('39', 'activerehashing', 'yes', '是否激活重置哈希,默认:yes', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('40', 'client-output-buffer-limit normal', '0 0 0', '客户端输出缓冲区限制(客户端)', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('41', 'client-output-buffer-limit slave', '512mb 256mb 60', '客户端输出缓冲区限制(复制)', '2016-11-24 10:24:21', '6', '1', '29', '0'), ('42', 'client-output-buffer-limit pubsub', '32mb 8mb 60', '客户端输出缓冲区限制(发布订阅)', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('43', 'hz', '10', '执行后台task数量,默认:10', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('44', 'port', '%d', '端口', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('45', 'maxmemory', '%dmb', '当前实例最大可用内存', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('46', 'maxmemory-policy', 'volatile-lru', '内存不够时,淘汰策略,默认:volatile-lru', '2016-07-05 15:08:31', '6', '1', '29', '0'), ('47', 'appendonly', 'yes', '开启append only持久化模式', '2016-07-05 15:08:32', '6', '1', '29', '0'), ('48', 'appendfsync', 'everysec', '默认:aof每秒同步一次', '2016-07-05 15:08:32', '6', '1', '29', '0'), ('49', 'appendfilename', 'appendonly-%d.aof', 'aof文件名称,默认:appendonly-{port}.aof', '2016-07-05 15:08:32', '6', '1', '29', '0'), ('50', 'dbfilename', 'dump-%d.rdb', 'RDB文件默认名称,默认dump-{port}.rdb', '2016-07-05 15:08:32', '6', '1', '29', '0'), ('51', 'aof-rewrite-incremental-fsync', 'yes', 'aof rewrite过程中,是否采取增量文件同步策略,默认:yes', '2016-07-05 15:08:32', '6', '1', '29', '0'), ('52', 'no-appendfsync-on-rewrite', 'yes', '是否在后台aof文件rewrite期间调用fsync,默认调用,修改为yes,防止可能fsync阻塞,但可能丢失rewrite期间的数据', '2016-07-05 15:08:32', '6', '1', '29', '0'), ('53', 'auto-aof-rewrite-min-size', '64m', '触发rewrite的aof文件最小阀值,默认64m', '2016-07-05 15:08:32', '6', '1', '29', '0'), ('54', 'auto-aof-rewrite-percentage', '%d', 'Redis重写aof文件的比例条件,默认从100开始,统一机器下不同实例按4%递减', '2016-07-05 15:08:32', '6', '1', '29', '0'), ('55', 'maxclients', '10000', '客户端最大连接数', '2016-07-05 15:08:32', '6', '1', '29', '0'), ('126', 'cluster-enabled', 'yes', '是否开启集群模式', '2018-09-18 18:23:03', '2', '1', '31', '0'), ('127', 'cluster-node-timeout', '15000', '集群节点超时时间,默认15秒', '2018-09-18 18:23:03', '2', '1', '31', '0'), ('128', 'cluster-slave-validity-factor', '10', '从节点延迟有效性判断因子,默认10秒', '2018-09-18 18:23:03', '2', '1', '31', '0'), ('129', 'cluster-migration-barrier', '1', '主从迁移至少需要的从节点数,默认1个', '2018-09-18 18:23:03', '2', '1', '31', '0'), ('130', 'cluster-config-file', 'nodes-%d.conf', '集群配置文件名称,格式:nodes-{port}.conf', '2018-09-18 18:23:03', '2', '1', '31', '0'), ('131', 'cluster-require-full-coverage', 'no', '节点部分失败期间,其他节点是否继续工作', '2018-09-18 18:23:03', '2', '1', '31', '0'), ('132', 'port', '%d', 'sentinel实例端口', '2018-09-18 18:23:03', '5', '1', '31', '0'), ('133', 'dir', '%s', '工作目录', '2018-09-18 18:23:03', '5', '1', '31', '0'), ('134', 'sentinel monitor', '%s %s %d 1', 'master名称定义和最少参与监控的sentinel数,格式:masterName ip port num', '2018-09-18 18:23:03', '5', '1', '31', '0'), ('135', 'sentinel down-after-milliseconds', '%s 20000', 'Sentinel判定服务器断线的毫秒数', '2018-09-18 18:23:03', '5', '1', '31', '0'), ('136', 'sentinel failover-timeout', '%s 180000', '故障迁移超时时间,默认:3分钟', '2018-09-18 18:23:03', '5', '1', '31', '0'), ('137', 'sentinel parallel-syncs', '%s 1', '在执行故障转移时,最多有多少个从服务器同时对新的主服务器进行同步,默认:1', '2018-09-18 18:23:03', '5', '1', '31', '0'), ('138', 'daemonize', 'no', '是否守护进程', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('139', 'tcp-backlog', '511', 'TCP连接完成队列', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('140', 'timeout', '0', '客户端闲置多少秒后关闭连接,默认为0,永不关闭', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('141', 'tcp-keepalive', '60', '检测客户端是否健康周期,默认关闭', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('142', 'loglevel', 'notice', '日志级别', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('143', 'databases', '16', '可用的数据库数，默认值为16个,默认数据库为0', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('144', 'dir', '%s', 'redis工作目录', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('145', 'stop-writes-on-bgsave-error', 'no', 'bgsave出错了不停写', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('146', 'repl-timeout', '60', 'master批量数据传输时间或者ping回复时间间隔,默认:60秒', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('147', 'repl-ping-slave-period', '10', '指定slave定期ping master的周期,默认:10秒', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('148', 'repl-disable-tcp-nodelay', 'no', '是否禁用socket的NO_DELAY,默认关闭，影响主从延迟', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('149', 'repl-backlog-size', '10M', '复制缓存区,默认:1mb,配置为:10Mb', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('150', 'repl-backlog-ttl', '7200', 'master在没有Slave的情况下释放BACKLOG的时间多久:默认:3600,配置为:7200', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('151', 'slave-serve-stale-data', 'yes', '当slave服务器和master服务器失去连接后，或者当数据正在复制传输的时候，如果此参数值设置“yes”，slave服务器可以继续接受客户端的请求', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('152', 'slave-read-only', 'yes', 'slave服务器节点是否只读,cluster的slave节点默认读写都不可用,需要调用readonly开启可读模式', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('153', 'slave-priority', '100', 'slave的优先级,影响sentinel/cluster晋升master操作,0永远不晋升', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('154', 'lua-time-limit', '5000', 'Lua脚本最长的执行时间，单位为毫秒', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('155', 'slowlog-log-slower-than', '10000', '慢查询被记录的阀值,默认10毫秒', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('156', 'slowlog-max-len', '128', '最多记录慢查询的条数', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('157', 'hash-max-ziplist-entries', '512', 'hash数据结构优化参数', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('158', 'hash-max-ziplist-value', '64', 'hash数据结构优化参数', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('159', 'list-max-ziplist-entries', '512', 'list数据结构优化参数', '2018-09-18 18:25:32', '6', '0', '31', '0'), ('160', 'list-max-ziplist-value', '64', 'list数据结构优化参数', '2018-09-18 18:25:40', '6', '0', '31', '0'), ('161', 'set-max-intset-entries', '512', 'set数据结构优化参数', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('162', 'zset-max-ziplist-entries', '128', 'zset数据结构优化参数', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('163', 'zset-max-ziplist-value', '64', 'zset数据结构优化参数', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('164', 'activerehashing', 'yes', '是否激活重置哈希,默认:yes', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('165', 'client-output-buffer-limit normal', '0 0 0', '客户端输出缓冲区限制(客户端)', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('166', 'client-output-buffer-limit slave', '512mb 256mb 60', '客户端输出缓冲区限制(复制)', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('167', 'client-output-buffer-limit pubsub', '32mb 8mb 60', '客户端输出缓冲区限制(发布订阅)', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('168', 'hz', '10', '执行后台task数量,默认:10', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('169', 'port', '%d', '端口', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('170', 'maxmemory', '%dmb', '当前实例最大可用内存', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('171', 'maxmemory-policy', 'volatile-lru', '内存不够时,淘汰策略,默认:volatile-lru', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('172', 'appendonly', 'yes', '开启append only持久化模式', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('173', 'appendfsync', 'everysec', '默认:aof每秒同步一次', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('174', 'appendfilename', 'appendonly-%d.aof', 'aof文件名称,默认:appendonly-{port}.aof', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('175', 'dbfilename', 'dump-%d.rdb', 'RDB文件默认名称,默认dump-{port}.rdb', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('176', 'aof-rewrite-incremental-fsync', 'yes', 'aof rewrite过程中,是否采取增量文件同步策略,默认:yes', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('177', 'no-appendfsync-on-rewrite', 'yes', '是否在后台aof文件rewrite期间调用fsync,默认调用,修改为yes,防止可能fsync阻塞,但可能丢失rewrite期间的数据', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('178', 'auto-aof-rewrite-min-size', '64m', '触发rewrite的aof文件最小阀值,默认64m', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('179', 'auto-aof-rewrite-percentage', '%d', 'Redis重写aof文件的比例条件,默认从100开始,统一机器下不同实例按4%递减', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('180', 'maxclients', '10000', '客户端最大连接数', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('181', 'protected-mode', 'yes', '开启保护模式', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('182', 'bind', '0.0.0.0', '默认客户端都可连接', '2018-09-18 18:23:03', '6', '1', '31', '0'), ('185', 'list-max-ziplist-size', '-2', '8Kb对象以内采用ziplist', '2018-09-18 18:26:32', '6', '1', '31', '0'), ('186', 'list-compress-depth', '0', '压缩方式，0:不压缩', '2018-09-18 18:27:12', '6', '1', '31', '0'), ('253', 'protected-mode', 'no', '关闭保护模式', '2018-11-01 16:10:59', '5', '1', '31', '0'), ('354', 'cluster-enabled', 'yes', '是否开启集群模式', '2019-10-24 17:33:26', '2', '1', '12', '0'), ('355', 'cluster-node-timeout', '15000', '集群节点超时时间,默认15秒', '2019-10-24 17:33:26', '2', '1', '12', '0'), ('356', 'cluster-slave-validity-factor', '10', '从节点延迟有效性判断因子,默认10秒', '2019-10-24 17:33:26', '2', '1', '12', '0'), ('357', 'cluster-migration-barrier', '1', '主从迁移至少需要的从节点数,默认1个', '2019-10-24 17:33:26', '2', '1', '12', '0'), ('358', 'cluster-config-file', 'nodes-%d.conf', '集群配置文件名称,格式:nodes-{port}.conf', '2019-10-24 17:33:26', '2', '1', '12', '0'), ('359', 'cluster-require-full-coverage', 'no', '节点部分失败期间,其他节点是否继续工作', '2019-10-24 17:33:26', '2', '1', '12', '0'), ('360', 'port', '%d', 'sentinel实例端口', '2019-10-24 17:33:26', '5', '1', '12', '0'), ('361', 'dir', '%s', '工作目录', '2019-10-24 17:33:26', '5', '1', '12', '0'), ('362', 'sentinel monitor', '%s %s %d 1', 'master名称定义和最少参与监控的sentinel数,格式:masterName ip port num', '2019-10-24 17:33:26', '5', '1', '12', '0'), ('363', 'sentinel down-after-milliseconds', '%s 20000', 'Sentinel判定服务器断线的毫秒数', '2019-10-24 17:33:26', '5', '1', '12', '0'), ('364', 'sentinel failover-timeout', '%s 180000', '故障迁移超时时间,默认:3分钟', '2019-10-24 17:33:26', '5', '1', '12', '0'), ('365', 'sentinel parallel-syncs', '%s 1', '在执行故障转移时,最多有多少个从服务器同时对新的主服务器进行同步,默认:1', '2019-10-24 17:33:26', '5', '1', '12', '0'), ('366', 'daemonize', 'no', '是否守护进程', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('367', 'tcp-backlog', '511', 'TCP连接完成队列', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('368', 'timeout', '0', '客户端闲置多少秒后关闭连接,默认为0,永不关闭', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('369', 'tcp-keepalive', '60', '检测客户端是否健康周期,默认关闭', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('370', 'loglevel', 'notice', '日志级别', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('371', 'databases', '16', '可用的数据库数，默认值为16个,默认数据库为0', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('372', 'dir', '%s', 'redis工作目录', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('373', 'stop-writes-on-bgsave-error', 'no', 'bgsave出错了不停写', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('374', 'repl-timeout', '60', 'master批量数据传输时间或者ping回复时间间隔,默认:60秒', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('375', 'repl-ping-slave-period', '10', '指定slave定期ping master的周期,默认:10秒', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('376', 'repl-disable-tcp-nodelay', 'no', '是否禁用socket的NO_DELAY,默认关闭，影响主从延迟', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('377', 'repl-backlog-size', '10M', '复制缓存区,默认:1mb,配置为:10Mb', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('378', 'repl-backlog-ttl', '7200', 'master在没有Slave的情况下释放BACKLOG的时间多久:默认:3600,配置为:7200', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('379', 'slave-serve-stale-data', 'yes', '当slave服务器和master服务器失去连接后，或者当数据正在复制传输的时候，如果此参数值设置“yes”，slave服务器可以继续接受客户端的请求', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('380', 'slave-read-only', 'yes', 'slave服务器节点是否只读,cluster的slave节点默认读写都不可用,需要调用readonly开启可读模式', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('381', 'slave-priority', '100', 'slave的优先级,影响sentinel/cluster晋升master操作,0永远不晋升', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('382', 'lua-time-limit', '5000', 'Lua脚本最长的执行时间，单位为毫秒', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('383', 'slowlog-log-slower-than', '10000', '慢查询被记录的阀值,默认10毫秒', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('384', 'slowlog-max-len', '128', '最多记录慢查询的条数', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('385', 'hash-max-ziplist-entries', '512', 'hash数据结构优化参数', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('386', 'hash-max-ziplist-value', '64', 'hash数据结构优化参数', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('387', 'list-max-ziplist-entries', '512', 'list数据结构优化参数', '2019-10-24 17:33:26', '6', '0', '12', '0'), ('388', 'list-max-ziplist-value', '64', 'list数据结构优化参数', '2019-10-24 17:33:26', '6', '0', '12', '0'), ('389', 'set-max-intset-entries', '512', 'set数据结构优化参数', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('390', 'zset-max-ziplist-entries', '128', 'zset数据结构优化参数', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('391', 'zset-max-ziplist-value', '64', 'zset数据结构优化参数', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('392', 'activerehashing', 'yes', '是否激活重置哈希,默认:yes', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('393', 'client-output-buffer-limit normal', '0 0 0', '客户端输出缓冲区限制(客户端)', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('394', 'client-output-buffer-limit slave', '512mb 256mb 60', '客户端输出缓冲区限制(复制)', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('395', 'client-output-buffer-limit pubsub', '32mb 8mb 60', '客户端输出缓冲区限制(发布订阅)', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('396', 'hz', '10', '执行后台task数量,默认:10', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('397', 'port', '%d', '端口', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('398', 'maxmemory', '%dmb', '当前实例最大可用内存', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('399', 'maxmemory-policy', 'volatile-lfu', '内存不够时,淘汰策略,默认:volatile-lfu', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('400', 'appendonly', 'yes', '开启append only持久化模式', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('401', 'appendfsync', 'everysec', '默认:aof每秒同步一次', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('402', 'appendfilename', 'appendonly-%d.aof', 'aof文件名称,默认:appendonly-{port}.aof', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('403', 'dbfilename', 'dump-%d.rdb', 'RDB文件默认名称,默认dump-{port}.rdb', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('404', 'aof-rewrite-incremental-fsync', 'yes', 'aof rewrite过程中,是否采取增量文件同步策略,默认:yes', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('405', 'no-appendfsync-on-rewrite', 'yes', '是否在后台aof文件rewrite期间调用fsync,默认调用,修改为yes,防止可能fsync阻塞,但可能丢失rewrite期间的数据', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('406', 'auto-aof-rewrite-min-size', '64m', '触发rewrite的aof文件最小阀值,默认64m', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('407', 'auto-aof-rewrite-percentage', '%d', 'Redis重写aof文件的比例条件,默认从100开始,统一机器下不同实例按4%递减', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('408', 'maxclients', '10000', '客户端最大连接数', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('409', 'protected-mode', 'yes', '开启保护模式', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('410', 'bind', '0.0.0.0', '默认客户端都可连接', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('411', 'list-max-ziplist-size', '-2', '8Kb对象以内采用ziplist', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('412', 'list-compress-depth', '0', '压缩方式，0:不压缩', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('413', 'always-show-logo', 'yes', 'redis启动是否显示logo', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('414', 'lazyfree-lazy-eviction', 'yes', '在被动淘汰键时，是否采用lazy free机制,默认:no', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('415', 'lazyfree-lazy-expire', 'yes', 'TTL的键过期是否采用lazyfree机制 默认值:no', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('416', 'lazyfree-lazy-server-del', 'yes', '隐式的DEL键(rename)是否采用lazyfree机制 默认值:no', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('417', 'slave-lazy-flush', 'yes', 'slave发起全量复制,是否采用flushall async清理老数据 默认值 no', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('418', 'aof-use-rdb-preamble', 'yes', '是否开启混合持久化,默认值 no 不开启', '2019-10-31 11:15:57', '6', '1', '12', '0'), ('419', 'protected-mode', 'no', '关闭sentinel保护模式', '2019-10-24 17:33:26', '5', '1', '12', '0'), ('420', 'activedefrag', 'no', '碎片整理开启', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('421', 'active-defrag-threshold-lower', '10', '碎片率达到百分之多少开启整理', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('422', 'active-defrag-threshold-upper', '100', '碎片率小余多少百分比开启整理', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('423', 'active-defrag-ignore-bytes', '300mb', '内存碎片达到多少兆开启碎片', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('424', 'active-defrag-cycle-min', '10', '碎片整理最小cpu百分比', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('425', 'active-defrag-cycle-max', '30', '碎片整理最大cpu百分比', '2019-10-24 17:33:26', '6', '1', '12', '0'), ('506', 'cluster-enabled', 'yes', '是否开启集群模式', '2020-04-26 18:12:55', '2', '1', '37', '0'), ('507', 'cluster-node-timeout', '15000', '集群节点超时时间,默认15秒', '2020-04-26 18:12:55', '2', '1', '37', '0'), ('508', 'cluster-migration-barrier', '1', '主从迁移至少需要的从节点数,默认1个', '2020-04-26 18:12:55', '2', '1', '37', '0'), ('509', 'cluster-config-file', 'nodes-%d.conf', '集群配置文件名称,格式:nodes-{port}.conf', '2020-04-26 18:12:55', '2', '1', '37', '0'), ('510', 'cluster-require-full-coverage', 'no', '节点部分失败期间,其他节点是否继续工作', '2020-04-26 18:12:55', '2', '1', '37', '0'), ('511', 'port', '%d', 'sentinel实例端口', '2020-04-26 18:12:55', '5', '1', '37', '0'), ('512', 'dir', '%s', '工作目录', '2020-04-26 18:12:55', '5', '1', '37', '0'), ('513', 'sentinel monitor', '%s %s %d 1', 'master名称定义和最少参与监控的sentinel数,格式:masterName ip port num', '2020-04-26 18:12:55', '5', '1', '37', '0'), ('514', 'sentinel down-after-milliseconds', '%s 20000', 'Sentinel判定服务器断线的毫秒数', '2020-04-26 18:12:55', '5', '1', '37', '0'), ('515', 'sentinel failover-timeout', '%s 180000', '故障迁移超时时间,默认:3分钟', '2020-04-26 18:12:55', '5', '1', '37', '0'), ('516', 'sentinel parallel-syncs', '%s 1', '在执行故障转移时,最多有多少个从服务器同时对新的主服务器进行同步,默认:1', '2020-04-26 18:12:55', '5', '1', '37', '0'), ('517', 'daemonize', 'no', '是否守护进程', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('518', 'tcp-backlog', '511', 'TCP连接完成队列', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('519', 'timeout', '0', '客户端闲置多少秒后关闭连接,默认为0,永不关闭', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('520', 'tcp-keepalive', '60', '检测客户端是否健康周期,默认关闭', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('521', 'loglevel', 'notice', '日志级别', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('522', 'databases', '16', '可用的数据库数，默认值为16个,默认数据库为0', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('523', 'dir', '%s', 'redis工作目录', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('524', 'stop-writes-on-bgsave-error', 'no', 'bgsave出错了不停写', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('525', 'repl-timeout', '60', 'master批量数据传输时间或者ping回复时间间隔,默认:60秒', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('526', 'repl-disable-tcp-nodelay', 'no', '是否禁用socket的NO_DELAY,默认关闭，影响主从延迟', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('527', 'repl-backlog-size', '10M', '复制缓存区,默认:1mb,配置为:10Mb', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('528', 'repl-backlog-ttl', '7200', 'master在没有从节点的情况下释放BACKLOG的时间多久:默认:3600,配置为:7200', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('529', 'lua-time-limit', '5000', 'Lua脚本最长的执行时间，单位为毫秒', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('530', 'slowlog-log-slower-than', '10000', '慢查询被记录的阀值,默认10毫秒', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('531', 'slowlog-max-len', '128', '最多记录慢查询的条数', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('532', 'hash-max-ziplist-entries', '512', 'hash数据结构优化参数', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('533', 'hash-max-ziplist-value', '64', 'hash数据结构优化参数', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('534', 'list-max-ziplist-entries', '512', 'list数据结构优化参数', '2020-04-26 18:12:55', '6', '0', '37', '0'), ('535', 'list-max-ziplist-value', '64', 'list数据结构优化参数', '2020-04-26 18:12:55', '6', '0', '37', '0'), ('536', 'set-max-intset-entries', '512', 'set数据结构优化参数', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('537', 'zset-max-ziplist-entries', '128', 'zset数据结构优化参数', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('538', 'zset-max-ziplist-value', '64', 'zset数据结构优化参数', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('539', 'activerehashing', 'yes', '是否激活重置哈希,默认:yes', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('540', 'client-output-buffer-limit normal', '0 0 0', '客户端输出缓冲区限制(客户端)', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('541', 'client-output-buffer-limit pubsub', '32mb 8mb 60', '客户端输出缓冲区限制(发布订阅)', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('542', 'hz', '10', '执行后台task数量,默认:10', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('543', 'port', '%d', '端口', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('544', 'maxmemory', '%dmb', '当前实例最大可用内存', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('545', 'maxmemory-policy', 'volatile-lfu', '内存不够时,淘汰策略,默认:volatile-lfu', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('546', 'appendonly', 'yes', '开启append only持久化模式', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('547', 'appendfsync', 'everysec', '默认:aof每秒同步一次', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('548', 'appendfilename', 'appendonly-%d.aof', 'aof文件名称,默认:appendonly-{port}.aof', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('549', 'dbfilename', 'dump-%d.rdb', 'RDB文件默认名称,默认dump-{port}.rdb', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('550', 'aof-rewrite-incremental-fsync', 'yes', 'aof rewrite过程中,是否采取增量文件同步策略,默认:yes', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('551', 'no-appendfsync-on-rewrite', 'yes', '是否在后台aof文件rewrite期间调用fsync,默认调用,修改为yes,防止可能fsync阻塞,但可能丢失rewrite期间的数据', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('552', 'auto-aof-rewrite-min-size', '64m', '触发rewrite的aof文件最小阀值,默认64m', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('553', 'auto-aof-rewrite-percentage', '%d', 'Redis重写aof文件的比例条件,默认从100开始,统一机器下不同实例按4%递减', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('554', 'maxclients', '10000', '客户端最大连接数', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('555', 'protected-mode', 'yes', '开启保护模式', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('556', 'bind', '0.0.0.0', '默认客户端都可连接', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('557', 'list-max-ziplist-size', '-2', '8Kb对象以内采用ziplist', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('558', 'list-compress-depth', '0', '压缩方式，0:不压缩', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('559', 'always-show-logo', 'yes', 'redis启动是否显示logo', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('560', 'lazyfree-lazy-eviction', 'yes', '在被动淘汰键时，是否采用lazy free机制,默认:no', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('561', 'lazyfree-lazy-expire', 'yes', 'TTL的键过期是否采用lazyfree机制 默认值:no', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('562', 'lazyfree-lazy-server-del', 'yes', '隐式的DEL键(rename)是否采用lazyfree机制 默认值:no', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('563', 'aof-use-rdb-preamble', 'yes', '是否开启混合持久化,默认值 no 不开启', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('564', 'protected-mode', 'no', '关闭sentinel保护模式', '2020-04-26 18:12:55', '5', '1', '37', '0'), ('565', 'activedefrag', 'yes', '碎片整理开启', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('566', 'active-defrag-threshold-lower', '10', '碎片率达到百分之多少开启整理', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('567', 'active-defrag-threshold-upper', '100', '碎片率小余多少百分比开启整理', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('568', 'active-defrag-ignore-bytes', '300mb', '内存碎片达到多少兆开启碎片', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('569', 'active-defrag-cycle-min', '10', '碎片整理最小cpu百分比', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('570', 'active-defrag-cycle-max', '30', '碎片整理最大cpu百分比', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('571', 'active-defrag-max-scan-fields', '1000', '内存碎片处理set/hash/zset/list 中的最大数量的项', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('572', 'replica-serve-stale-data', 'yes', '从节点与master断连或复制命令响应：yes 继续响应 no:相关命令返回异常信息', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('573', 'cluster-replica-validity-factor', '10', '从节点延迟有效性判断因子,默认10秒', '2020-04-26 18:12:55', '2', '1', '37', '0'), ('574', 'replica-priority', '100', '从节点的优先级,影响sentinel/cluster晋升master操作,0永远不晋升', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('575', 'replica-read-only', 'yes', '从节点是否只读: yes 只读', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('576', 'replica-lazy-flush', 'yes', '从节点发起全量复制,是否采用flushall async清理老数据 默认值 no', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('577', 'client-output-buffer-limit replica', '512mb 256mb 60', '客户端输出缓冲区限制', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('578', 'replica-ignore-maxmemory', 'yes', '从节点是否开启最大内存，避免一些过大缓冲区导致oom', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('579', 'stream-node-max-bytes', '4096', 'stream数据结构优化参数', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('580', 'stream-node-max-entries', '100', 'stream数据结构优化参数', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('581', 'dynamic-hz', 'yes', '自适应平衡空闲CPU的使用率和响应', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('582', 'rdb-save-incremental-fsync', 'yes', 'rdb同步刷盘是否采用增量fsync，每32MB执行一次fsync', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('583', 'repl-ping-replica-period', '10', '指定从节点定期ping master的周期,默认:10秒', '2020-04-26 18:12:55', '6', '1', '37', '0'), ('585', 'latency-monitor-threshold', '30', '延迟事件阀值，单位ms', '2020-05-26 15:45:22', '6', '1', '37', '0'), ('587', 'latency-monitor-threshold', '30', '延迟事件阀值，单位ms', '2020-05-26 15:46:18', '6', '1', '12', '0'), ('589', 'latency-monitor-threshold', '30', '延迟事件阀值，单位ms', '2020-05-26 15:46:49', '6', '1', '31', '0'), ('590', 'latency-monitor-threshold', '30', '延迟事件阀值，单位ms', '2020-05-26 15:49:47', '6', '1', '29', '0');
COMMIT;


--
-- Table structure for table `instance_fault`
--

DROP TABLE IF EXISTS `instance_fault`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_fault` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_id` bigint(20) NOT NULL COMMENT '应用id',
  `inst_id` bigint(20) NOT NULL COMMENT '实例id',
  `ip` varchar(16) NOT NULL COMMENT 'ip地址',
  `port` int(11) NOT NULL COMMENT '端口',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态:0:心跳停止,1:心跳恢复',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `type` mediumint(4) NOT NULL COMMENT '类型：1. memcached, 2. redis-cluster, 3. memcacheq, 4. 非cache-cloud 5. redis-sentinel 6.redis-standalone',
  `reason` mediumtext NOT NULL COMMENT '故障原因描述',
  PRIMARY KEY (`id`),
  KEY `idx_ip_port` (`ip`,`port`),
  KEY `app_id` (`app_id`),
  KEY `inst_id` (`inst_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8927 DEFAULT CHARSET=utf8 COMMENT='实例故障表' /* `compression`='tokudb_zlib' */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance_host`
--

DROP TABLE IF EXISTS `instance_host`;
CREATE TABLE `instance_host` (
 `id` bigint(20) NOT NULL AUTO_INCREMENT,
 `ip` varchar(16) NOT NULL COMMENT '机器ip',
 `ssh_user` varchar(32) DEFAULT NULL COMMENT 'ssh用户',
 `ssh_pwd` varchar(32) DEFAULT NULL COMMENT 'ssh密码',
 `warn` int(5) DEFAULT '1' COMMENT '0不报警，1报警',
 PRIMARY KEY (`id`),
 UNIQUE KEY `uidx_host_ip` (`ip`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='机器表' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `instance_info`
--

DROP TABLE IF EXISTS `instance_info`;
CREATE TABLE `instance_info` (
 `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'memcached instance id',
 `parent_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '对等实例的id',
 `app_id` bigint(20) NOT NULL COMMENT '应用id，与app_desc关联',
 `host_id` bigint(20) NOT NULL COMMENT '对应的主机id，与instance_host关联',
 `ip` varchar(16) NOT NULL COMMENT '实例的ip',
 `port` int(11) NOT NULL COMMENT '实例端口',
 `status` tinyint(4) NOT NULL COMMENT '是否启用:0:节点异常,1:正常启用,2:节点下线',
 `mem` int(11) NOT NULL COMMENT '内存大小',
 `conn` int(11) NOT NULL COMMENT '连接数',
 `cmd` varchar(255) NOT NULL COMMENT '启动实例的命令/redis-sentinel的masterName',
 `type` mediumint(11) NOT NULL COMMENT '类型：1. memcached, 2. redis-cluster, 3. memcacheq, 4. 非cache-cloud 5. redis-sentinel 6.redis-standalone',
 `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
 PRIMARY KEY (`id`),
 UNIQUE KEY `uidx_inst_ipport` (`ip`,`port`) USING BTREE,
 KEY `app_id` (`app_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='实例信息' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `instance_latency_history`
--

DROP TABLE IF EXISTS `instance_latency_history`;
CREATE TABLE `instance_latency_history` (
`id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增id',
`instance_id` bigint(20) NOT NULL COMMENT '实例的id',
`app_id` bigint(20) NOT NULL COMMENT 'app id',
`ip` varchar(32) NOT NULL COMMENT 'ip',
`port` int(11) NOT NULL COMMENT 'port',
`event` varchar(255) NOT NULL COMMENT '事件名称',
`execute_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '执行时间点',
`execution_cost` bigint(20) NOT NULL COMMENT '耗时(微妙)',
`create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
PRIMARY KEY (`id`),
UNIQUE KEY `latencyistorykey` (`instance_id`,`event`,`execute_date`),
KEY `idx_app_create_time` (`app_id`,`create_time`),
KEY `idx_app_executedate` (`app_id`,`execute_date`),
KEY `idx_executedate` (`execute_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='实例延迟事件信息表';

--
-- Table structure for table `instance_minute_stats`
--

DROP TABLE IF EXISTS `instance_minute_stats`;
CREATE TABLE `instance_minute_stats` (
 `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
 `collect_time` bigint(20) NOT NULL COMMENT '收集时间:格式yyyyMMddHHmm',
 `ip` varchar(16) NOT NULL COMMENT 'ip地址',
 `port` int(11) NOT NULL COMMENT '端口/hostId',
 `db_type` varchar(16) NOT NULL COMMENT '收集的数据类型',
 `json` text NOT NULL COMMENT '统计json数据',
 `created_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
 PRIMARY KEY (`id`),
 UNIQUE KEY `uniq_index` (`ip`,`port`,`db_type`,`collect_time`),
 KEY `idx_collect_time` (`collect_time`),
 KEY `idx_created_time` (`created_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='实例分钟统计表';

--
-- Table structure for table `instance_reshard_process`
--

DROP TABLE IF EXISTS `instance_reshard_process`;
CREATE TABLE `instance_reshard_process` (
`id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增id',
`app_id` bigint(20) NOT NULL COMMENT '应用id',
`audit_id` bigint(20) NOT NULL COMMENT '审核id',
`source_instance_id` int(11) NOT NULL COMMENT '源实例id',
`target_instance_id` int(11) NOT NULL COMMENT '目标实例id',
`start_slot` int(11) NOT NULL COMMENT '开始slot',
`end_slot` int(11) NOT NULL COMMENT '结束slot',
`migrating_slot` int(11) NOT NULL COMMENT '正在迁移的slot',
`is_pipeline` tinyint(4) NOT NULL COMMENT '是否为pipeline,0:否,1:是',
`finish_slot_num` int(11) NOT NULL COMMENT '已经完成迁移的slot数量',
`status` tinyint(4) NOT NULL COMMENT '0:运行中 1:完成 2:出错',
`start_time` datetime NOT NULL COMMENT '迁移开始时间',
`end_time` datetime NOT NULL COMMENT '迁移结束时间',
`create_time` datetime NOT NULL COMMENT '创建时间',
`update_time` datetime NOT NULL COMMENT '更新时间',
PRIMARY KEY (`id`),
KEY `idx_audit` (`audit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='实例Reshard进度';

--
-- Table structure for table `instance_slow_log`
--

DROP TABLE IF EXISTS `instance_slow_log`;
CREATE TABLE `instance_slow_log` (
 `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增id',
 `instance_id` bigint(20) NOT NULL COMMENT '实例的id',
 `app_id` bigint(20) NOT NULL COMMENT 'app id',
 `ip` varchar(32) NOT NULL COMMENT 'ip',
 `port` int(11) NOT NULL COMMENT 'port',
 `slow_log_id` bigint(20) NOT NULL COMMENT '慢查询id',
 `cost_time` int(11) NOT NULL COMMENT '耗时(微妙)',
 `command` varchar(255) NOT NULL COMMENT '执行命令',
 `execute_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '执行时间点',
 `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
 PRIMARY KEY (`id`),
 UNIQUE KEY `slowlogkey` (`instance_id`,`slow_log_id`,`execute_time`),
 KEY `idx_app_create_time` (`app_id`,`create_time`),
 KEY `idx_app_executetime` (`app_id`,`execute_time`),
 KEY `idx_executetime` (`execute_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='实例慢查询列表';

--
-- Table structure for table `instance_statistics`
--

DROP TABLE IF EXISTS `instance_statistics`;
CREATE TABLE `instance_statistics` (
   `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增id',
   `inst_id` bigint(20) NOT NULL COMMENT '实例的id',
   `app_id` bigint(20) NOT NULL COMMENT 'app id',
   `host_id` bigint(20) NOT NULL COMMENT '机器的id',
   `ip` varchar(16) COLLATE utf8_bin NOT NULL COMMENT 'ip',
   `port` int(255) NOT NULL COMMENT 'port',
   `role` tinyint(255) NOT NULL COMMENT '主从，1主2从',
   `max_memory` bigint(255) NOT NULL COMMENT '预分配内存，单位byte',
   `used_memory` bigint(255) NOT NULL COMMENT '已使用内存，单位byte',
   `curr_items` bigint(255) NOT NULL COMMENT '当前item数量',
   `curr_connections` int(255) NOT NULL COMMENT '当前连接数',
   `misses` bigint(255) NOT NULL COMMENT 'miss数',
   `hits` bigint(255) NOT NULL COMMENT '命中数',
   `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
   `modify_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
   `mem_fragmentation_ratio` double DEFAULT '0' COMMENT '碎片率',
   `aof_delayed_fsync` int(11) DEFAULT '0' COMMENT 'aof阻塞次数',
   PRIMARY KEY (`id`),
   UNIQUE KEY `ip` (`ip`,`port`),
   KEY `app_id` (`app_id`),
   KEY `machine_id` (`host_id`),
   KEY `idx_inst_id` (`inst_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='实例的最新统计信息' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `machine_info`
--

DROP TABLE IF EXISTS `machine_info`;
CREATE TABLE `machine_info` (
`id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '机器的id',
`ssh_user` varchar(20) COLLATE utf8_bin NOT NULL DEFAULT 'cachecloud' COMMENT 'ssh用户',
`ssh_passwd` varchar(20) COLLATE utf8_bin NOT NULL DEFAULT 'cachecloud' COMMENT 'ssh密码',
`ip` varchar(16) COLLATE utf8_bin NOT NULL COMMENT 'ip',
`room` varchar(20) COLLATE utf8_bin NOT NULL COMMENT '所属机房',
`mem` int(11) unsigned NOT NULL COMMENT '内存大小，单位G',
`cpu` mediumint(24) unsigned NOT NULL COMMENT 'cpu数量',
`virtual` tinyint(8) unsigned NOT NULL DEFAULT '1' COMMENT '是否虚拟，0表示否，1表示是',
`real_ip` varchar(16) COLLATE utf8_bin NOT NULL COMMENT '宿主机ip',
`service_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上线时间',
`fault_count` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '故障次数',
`modify_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
`warn` tinyint(255) unsigned NOT NULL DEFAULT '1' COMMENT '是否启用报警，0不启用，1启用',
`available` tinyint(255) NOT NULL COMMENT '表示机器是否可用，1表示可用，0表示不可用；',
`groupId` int(11) NOT NULL DEFAULT '0' COMMENT '机器分组，默认为0，表示原生资源，非0表示外部提供的资源(可扩展)',
`type` int(11) NOT NULL DEFAULT '0' COMMENT '0原生 1 其他',
`extra_desc` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '对于机器的额外说明(例如机器安装的其他服务(web,mysql,queue等等))',
`collect` int(11) DEFAULT '1' COMMENT 'switch of collect server status, 1:open, 0:close',
`version_install` varchar(512) COLLATE utf8_bin DEFAULT NULL COMMENT '机器安装redis版本状态',
`use_type` tinyint(4) DEFAULT '2' COMMENT '使用类型：Redis专用机器(0)，Redis测试机器(1)，混合部署机器(2)，Redis-Sentinel机器(3)',
`k8s_type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否k8s容器：0:不是 1:是',
`rack` varchar(128) COLLATE utf8_bin DEFAULT '' COMMENT '机器所在机架信息',
`is_allocating` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否在分配中,1是0否',
`disk` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '磁盘空间:G',
PRIMARY KEY (`id`),
UNIQUE KEY `ip` (`ip`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='机器信息表' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `machine_relation`
--

DROP TABLE IF EXISTS `machine_relation`;
CREATE TABLE `machine_relation` (
`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
`ip` varchar(64) NOT NULL COMMENT '虚拟机ip',
`real_ip` varchar(64) NOT NULL COMMENT '宿主机ip',
`extra_desc` varchar(128) DEFAULT NULL COMMENT '实例描述信息',
`status` int(255) NOT NULL COMMENT '实例变更状态 0:offline ,1:online',
`is_sync` tinyint(4) NOT NULL DEFAULT '0' COMMENT '数据同步状态 0: 未同步数据  -1:同步中 1:数据已同步 -2:同步失败 ',
`sync_time` timestamp NULL DEFAULT NULL COMMENT '同步时间',
`update_time` timestamp NULL DEFAULT NULL COMMENT 'pod最后更新时间',
`taskid` bigint(11) DEFAULT NULL COMMENT '任务id',
PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `machine_room`
--

DROP TABLE IF EXISTS `machine_room`;
CREATE TABLE `machine_room` (
`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '机房id',
`name` varchar(255) NOT NULL COMMENT '机房名称',
`status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '0:无效 1:有效',
`desc` varchar(255) DEFAULT NULL COMMENT '机房描述信息',
`ip_network` varchar(32) NOT NULL DEFAULT '' COMMENT '机房网段信息',
`operator` varchar(255) DEFAULT NULL COMMENT '运营商',
PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Records of `machine_room`
-- ----------------------------
BEGIN;
INSERT INTO `machine_room` VALUES ('1', '阿里云杭州', '1', '阿里云-杭州机房', '172.27.*.*', '阿里云');
COMMIT;

--
-- Table structure for table `machine_statistics`
--

DROP TABLE IF EXISTS `machine_statistics`;
CREATE TABLE `machine_statistics` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `host_id` bigint(20) NOT NULL COMMENT '机器id',
  `ip` varchar(16) NOT NULL COMMENT '机器ip',
  `cpu_usage` varchar(120) NOT NULL COMMENT 'cpu使用率',
  `load` varchar(120) NOT NULL COMMENT '机器负载',
  `traffic` varchar(120) NOT NULL COMMENT 'io网络流量',
  `memory_usage_ratio` varchar(120) NOT NULL COMMENT '内存使用率',
  `memory_free` varchar(120) NOT NULL COMMENT '内存剩余',
  `memory_total` varchar(120) NOT NULL COMMENT '总内存量',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `modify_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  `max_memory` int(11) DEFAULT '0' COMMENT '机器分配内存,单位MB',
  `instance_count` int(11) DEFAULT '0' COMMENT '机器实例数量',
  `machine_memory` int(11) DEFAULT '0' COMMENT '机器入库总内存,单位MB',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uidx_ip` (`ip`),
  KEY `host_id` (`host_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='机器状态统计信息' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `qrtz_blob_triggers`
--

DROP TABLE IF EXISTS `qrtz_blob_triggers`;
CREATE TABLE `qrtz_blob_triggers` (
  `SCHED_NAME` varchar(120) NOT NULL,
  `TRIGGER_NAME` varchar(200) NOT NULL,
  `TRIGGER_GROUP` varchar(200) NOT NULL,
  `BLOB_DATA` blob,
  PRIMARY KEY (`SCHED_NAME`,`TRIGGER_NAME`,`TRIGGER_GROUP`),
  KEY `SCHED_NAME` (`SCHED_NAME`,`TRIGGER_NAME`,`TRIGGER_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Trigger 作为 Blob 类型存储(用于 Quartz 用户用 JDBC 创建他们自己定制的 Trigger 类型' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `qrtz_calendars`
--

DROP TABLE IF EXISTS `qrtz_calendars`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qrtz_calendars` (
  `SCHED_NAME` varchar(120) NOT NULL COMMENT 'scheduler名称',
  `CALENDAR_NAME` varchar(200) NOT NULL COMMENT 'calendar名称',
  `CALENDAR` blob NOT NULL COMMENT 'calendar信息',
  PRIMARY KEY (`SCHED_NAME`,`CALENDAR_NAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='以 Blob 类型存储 Quartz 的 Calendar 信息' /* `compression`='tokudb_zlib' */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qrtz_cron_triggers`
--

DROP TABLE IF EXISTS `qrtz_cron_triggers`;
CREATE TABLE `qrtz_cron_triggers` (
  `SCHED_NAME` varchar(120) NOT NULL COMMENT 'scheduler名称',
  `TRIGGER_NAME` varchar(200) NOT NULL COMMENT 'trigger名',
  `TRIGGER_GROUP` varchar(200) NOT NULL COMMENT 'trigger组',
  `CRON_EXPRESSION` varchar(120) NOT NULL COMMENT 'cron表达式',
  `TIME_ZONE_ID` varchar(80) DEFAULT NULL COMMENT '时区',
  PRIMARY KEY (`SCHED_NAME`,`TRIGGER_NAME`,`TRIGGER_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='存储 Cron Trigger，包括 Cron 表达式和时区信息' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `qrtz_fired_triggers`
--

DROP TABLE IF EXISTS `qrtz_fired_triggers`;
CREATE TABLE `qrtz_fired_triggers` (
   `SCHED_NAME` varchar(120) NOT NULL,
   `ENTRY_ID` varchar(195) NOT NULL,
   `TRIGGER_NAME` varchar(200) NOT NULL,
   `TRIGGER_GROUP` varchar(200) NOT NULL,
   `INSTANCE_NAME` varchar(200) NOT NULL,
   `FIRED_TIME` bigint(13) NOT NULL,
   `SCHED_TIME` bigint(13) NOT NULL,
   `PRIORITY` int(11) NOT NULL,
   `STATE` varchar(16) NOT NULL,
   `JOB_NAME` varchar(200) DEFAULT NULL,
   `JOB_GROUP` varchar(200) DEFAULT NULL,
   `IS_NONCONCURRENT` varchar(1) DEFAULT NULL COMMENT '是否非并行执行',
   `REQUESTS_RECOVERY` varchar(1) DEFAULT NULL COMMENT '是否持久化',
   PRIMARY KEY (`SCHED_NAME`,`ENTRY_ID`),
   KEY `IDX_QRTZ_FT_TRIG_INST_NAME` (`SCHED_NAME`,`INSTANCE_NAME`),
   KEY `IDX_QRTZ_FT_INST_JOB_REQ_RCVRY` (`SCHED_NAME`,`INSTANCE_NAME`,`REQUESTS_RECOVERY`),
   KEY `IDX_QRTZ_FT_J_G` (`SCHED_NAME`,`JOB_NAME`,`JOB_GROUP`),
   KEY `IDX_QRTZ_FT_JG` (`SCHED_NAME`,`JOB_GROUP`),
   KEY `IDX_QRTZ_FT_T_G` (`SCHED_NAME`,`TRIGGER_NAME`,`TRIGGER_GROUP`),
   KEY `IDX_QRTZ_FT_TG` (`SCHED_NAME`,`TRIGGER_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='存储已触发的 Trigger相关的状态信息，以及关联 Job 的执行信息' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `qrtz_job_details`
--

DROP TABLE IF EXISTS `qrtz_job_details`;
CREATE TABLE `qrtz_job_details` (
`SCHED_NAME` varchar(120) NOT NULL,
`JOB_NAME` varchar(200) NOT NULL,
`JOB_GROUP` varchar(200) NOT NULL,
`DESCRIPTION` varchar(250) DEFAULT NULL,
`JOB_CLASS_NAME` varchar(250) NOT NULL,
`IS_DURABLE` varchar(1) NOT NULL COMMENT '是否持久化，0不持久化，1持久化',
`IS_NONCONCURRENT` varchar(1) NOT NULL COMMENT '是否非并发，0非并发，1并发',
`IS_UPDATE_DATA` varchar(1) NOT NULL,
`REQUESTS_RECOVERY` varchar(1) NOT NULL COMMENT '是否可恢复，0不恢复，1恢复',
`JOB_DATA` blob,
PRIMARY KEY (`SCHED_NAME`,`JOB_NAME`,`JOB_GROUP`),
KEY `IDX_QRTZ_J_REQ_RECOVERY` (`SCHED_NAME`,`REQUESTS_RECOVERY`),
KEY `IDX_QRTZ_J_GRP` (`SCHED_NAME`,`JOB_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='存储每一个已配置的 Job 的详细信息' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `qrtz_locks`
--

DROP TABLE IF EXISTS `qrtz_locks`;
CREATE TABLE `qrtz_locks` (
  `SCHED_NAME` varchar(120) NOT NULL,
  `LOCK_NAME` varchar(40) NOT NULL,
  PRIMARY KEY (`SCHED_NAME`,`LOCK_NAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='存储程序的悲观锁的信息(假如使用了悲观锁)' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `qrtz_paused_trigger_grps`
--

DROP TABLE IF EXISTS `qrtz_paused_trigger_grps`;
CREATE TABLE `qrtz_paused_trigger_grps` (
`SCHED_NAME` varchar(120) NOT NULL,
`TRIGGER_GROUP` varchar(200) NOT NULL,
PRIMARY KEY (`SCHED_NAME`,`TRIGGER_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='存储已暂停的 Trigger 组的信息' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `qrtz_scheduler_state`
--

DROP TABLE IF EXISTS `qrtz_scheduler_state`;
CREATE TABLE `qrtz_scheduler_state` (
`SCHED_NAME` varchar(120) NOT NULL,
`INSTANCE_NAME` varchar(200) NOT NULL COMMENT '执行quartz实例的主机名',
`LAST_CHECKIN_TIME` bigint(13) NOT NULL COMMENT '实例将状态报告给集群中的其它实例的上一次时间',
`CHECKIN_INTERVAL` bigint(13) NOT NULL COMMENT '实例间状态报告的时间频率',
PRIMARY KEY (`SCHED_NAME`,`INSTANCE_NAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='存储少量的有关 Scheduler 的状态信息' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `qrtz_simple_triggers`
--

DROP TABLE IF EXISTS `qrtz_simple_triggers`;
CREATE TABLE `qrtz_simple_triggers` (
`SCHED_NAME` varchar(120) NOT NULL,
`TRIGGER_NAME` varchar(200) NOT NULL,
`TRIGGER_GROUP` varchar(200) NOT NULL,
`REPEAT_COUNT` bigint(7) NOT NULL COMMENT '重复次数',
`REPEAT_INTERVAL` bigint(12) NOT NULL COMMENT '重复间隔',
`TIMES_TRIGGERED` bigint(10) NOT NULL COMMENT '已出发次数',
PRIMARY KEY (`SCHED_NAME`,`TRIGGER_NAME`,`TRIGGER_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='存储简单的 Trigger，包括重复次数，间隔，以及已触的次数' /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `qrtz_simprop_triggers`
--

DROP TABLE IF EXISTS `qrtz_simprop_triggers`;
CREATE TABLE `qrtz_simprop_triggers` (
 `SCHED_NAME` varchar(120) NOT NULL,
 `TRIGGER_NAME` varchar(200) NOT NULL,
 `TRIGGER_GROUP` varchar(200) NOT NULL,
 `STR_PROP_1` varchar(512) DEFAULT NULL,
 `STR_PROP_2` varchar(512) DEFAULT NULL,
 `STR_PROP_3` varchar(512) DEFAULT NULL,
 `INT_PROP_1` int(11) DEFAULT NULL,
 `INT_PROP_2` int(11) DEFAULT NULL,
 `LONG_PROP_1` bigint(20) DEFAULT NULL,
 `LONG_PROP_2` bigint(20) DEFAULT NULL,
 `DEC_PROP_1` decimal(13,4) DEFAULT NULL,
 `DEC_PROP_2` decimal(13,4) DEFAULT NULL,
 `BOOL_PROP_1` varchar(1) DEFAULT NULL,
 `BOOL_PROP_2` varchar(1) DEFAULT NULL,
 PRIMARY KEY (`SCHED_NAME`,`TRIGGER_NAME`,`TRIGGER_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 /* `compression`='tokudb_zlib' */;

--
-- Table structure for table `qrtz_triggers`
--

DROP TABLE IF EXISTS `qrtz_triggers`;
CREATE TABLE `qrtz_triggers` (
 `SCHED_NAME` varchar(120) NOT NULL,
 `TRIGGER_NAME` varchar(200) NOT NULL,
 `TRIGGER_GROUP` varchar(200) NOT NULL,
 `JOB_NAME` varchar(200) NOT NULL,
 `JOB_GROUP` varchar(200) NOT NULL,
 `DESCRIPTION` varchar(250) DEFAULT NULL,
 `NEXT_FIRE_TIME` bigint(13) DEFAULT NULL,
 `PREV_FIRE_TIME` bigint(13) DEFAULT NULL,
 `PRIORITY` int(11) DEFAULT NULL,
 `TRIGGER_STATE` varchar(16) NOT NULL,
 `TRIGGER_TYPE` varchar(8) NOT NULL,
 `START_TIME` bigint(13) NOT NULL,
 `END_TIME` bigint(13) DEFAULT NULL,
 `CALENDAR_NAME` varchar(200) DEFAULT NULL,
 `MISFIRE_INSTR` smallint(2) DEFAULT NULL,
 `JOB_DATA` blob,
 PRIMARY KEY (`SCHED_NAME`,`TRIGGER_NAME`,`TRIGGER_GROUP`),
 KEY `IDX_QRTZ_T_J` (`SCHED_NAME`,`JOB_NAME`,`JOB_GROUP`),
 KEY `IDX_QRTZ_T_JG` (`SCHED_NAME`,`JOB_GROUP`),
 KEY `IDX_QRTZ_T_C` (`SCHED_NAME`,`CALENDAR_NAME`),
 KEY `IDX_QRTZ_T_G` (`SCHED_NAME`,`TRIGGER_GROUP`),
 KEY `IDX_QRTZ_T_STATE` (`SCHED_NAME`,`TRIGGER_STATE`),
 KEY `IDX_QRTZ_T_N_STATE` (`SCHED_NAME`,`TRIGGER_NAME`,`TRIGGER_GROUP`,`TRIGGER_STATE`),
 KEY `IDX_QRTZ_T_N_G_STATE` (`SCHED_NAME`,`TRIGGER_GROUP`,`TRIGGER_STATE`),
 KEY `IDX_QRTZ_T_NEXT_FIRE_TIME` (`SCHED_NAME`,`NEXT_FIRE_TIME`),
 KEY `IDX_QRTZ_T_NFT_ST` (`SCHED_NAME`,`TRIGGER_STATE`,`NEXT_FIRE_TIME`),
 KEY `IDX_QRTZ_T_NFT_MISFIRE` (`SCHED_NAME`,`MISFIRE_INSTR`,`NEXT_FIRE_TIME`),
 KEY `IDX_QRTZ_T_NFT_ST_MISFIRE` (`SCHED_NAME`,`MISFIRE_INSTR`,`NEXT_FIRE_TIME`,`TRIGGER_STATE`),
 KEY `IDX_QRTZ_T_NFT_ST_MISFIRE_GRP` (`SCHED_NAME`,`MISFIRE_INSTR`,`NEXT_FIRE_TIME`,`TRIGGER_GROUP`,`TRIGGER_STATE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='存储已配置的 Trigger 的信息' /* `compression`='tokudb_zlib' */;


--
-- Table structure for table `server`
--

DROP TABLE IF EXISTS `server`;
CREATE TABLE `server` (
  `ip` varchar(16) NOT NULL COMMENT 'ip',
  `host` varchar(255) DEFAULT NULL COMMENT 'host',
  `nmon` varchar(255) DEFAULT NULL COMMENT 'nmon version',
  `cpus` tinyint(4) DEFAULT NULL COMMENT 'logic cpu num',
  `cpu_model` varchar(255) DEFAULT NULL COMMENT 'cpu 型号',
  `dist` varchar(255) DEFAULT NULL COMMENT '发行版信息',
  `kernel` varchar(255) DEFAULT NULL COMMENT '内核信息',
  `ulimit` varchar(255) DEFAULT NULL COMMENT 'ulimit -n,ulimit -u',
  `updatetime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `server_stat`
--

DROP TABLE IF EXISTS `server_stat`;
CREATE TABLE `server_stat` (
   `ip` varchar(16) NOT NULL COMMENT 'ip',
   `cdate` date NOT NULL COMMENT '数据收集天',
   `ctime` char(4) NOT NULL COMMENT '数据收集小时分钟',
   `cuser` float DEFAULT NULL COMMENT '用户态占比',
   `csys` float DEFAULT NULL COMMENT '内核态占比',
   `cwio` float DEFAULT NULL COMMENT 'wio占比',
   `c_ext` text COMMENT '子cpu占比',
   `cload1` float DEFAULT NULL COMMENT '1分钟load',
   `cload5` float DEFAULT NULL COMMENT '5分钟load',
   `cload15` float DEFAULT NULL COMMENT '15分钟load',
   `mtotal` float DEFAULT NULL COMMENT '总内存,单位M',
   `mfree` float DEFAULT NULL COMMENT '空闲内存',
   `mcache` float DEFAULT NULL COMMENT 'cache',
   `mbuffer` float DEFAULT NULL COMMENT 'buffer',
   `mswap` float DEFAULT NULL COMMENT 'cache',
   `mswap_free` float DEFAULT NULL COMMENT 'cache',
   `nin` float DEFAULT NULL COMMENT '网络入流量 单位K/s',
   `nout` float DEFAULT NULL COMMENT '网络出流量 单位k/s',
   `nin_ext` text COMMENT '各网卡入流量详情',
   `nout_ext` text COMMENT '各网卡出流量详情',
   `tuse` int(11) DEFAULT NULL COMMENT 'tcp estab连接数',
   `torphan` int(11) DEFAULT NULL COMMENT 'tcp orphan连接数',
   `twait` int(11) DEFAULT NULL COMMENT 'tcp time wait连接数',
   `dread` float DEFAULT NULL COMMENT '磁盘读速率 单位K/s',
   `dwrite` float DEFAULT NULL COMMENT '磁盘写速率 单位K/s',
   `diops` float DEFAULT NULL COMMENT '磁盘io速率 交互次数/s',
   `dbusy` float DEFAULT NULL COMMENT '磁盘io带宽使用百分比',
   `d_ext` text COMMENT '磁盘各分区占比',
   `dspace` text COMMENT '磁盘各分区空间使用率',
   PRIMARY KEY (`ip`,`cdate`,`ctime`),
   KEY `idx_cdate` (`cdate`),
   KEY `idx_cdate_ctime` (`cdate`,`ctime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `system_config`
--

DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config` (
 `config_key` varchar(255) NOT NULL COMMENT '配置key',
 `config_value` varchar(512) NOT NULL COMMENT '配置value',
 `info` varchar(255) NOT NULL COMMENT '配置说明',
 `status` tinyint(4) NOT NULL COMMENT '1:可用,0:不可用',
 `order_id` int(11) NOT NULL COMMENT '顺序',
 PRIMARY KEY (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='系统配置';

-- ----------------------------
--  Records of `system_config`
-- ----------------------------
BEGIN;
INSERT INTO `system_config` VALUES ('cachecloud.admin.user.name','admin','cachecloud-admin用户名',1,11),('cachecloud.admin.user.password','admin','cachelcoud-admin密码',1,12),('cachecloud.app.client.conn.threshold','2000','应用连接数报警阀值',1,33),('cachecloud.base.dir','/opt','cachecloud根目录，要和cachecloud-init.sh脚本中的目录一致',1,31),('cachecloud.contact','user1:(xx@zz.com, user1:135xxxxxxxx)<br/>user2: (user2@zz.com, user2:138xxxxxxxx)','值班联系人信息',1,14),('cachecloud.cookie.domain','','cookie登录方式所需要的域名',1,22),('cachecloud.email.alert.interface','','邮件报警接口(参考报警接口规范)',1,24),('cachecloud.machine.ssh.name','cachecloud-open','机器ssh用户名',1,2),('cachecloud.machine.ssh.password','cachecloud-open','机器ssh密码',1,3),('cachecloud.machine.ssh.port','22','机器ssh端口',1,10),('cachecloud.machine.stats.cron.minute','1','机器性能统计周期(分钟)',1,35),('cachecloud.nmon.dir','/opt/cachecloud','nmon安装目录',1,32),('cachecloud.owner.email','xx@sohu.com,yy@qq.com','邮件报警(逗号隔开)',1,21),('cachecloud.owner.phone','xxx,yyy','手机号报警(逗号隔开)',1,21),('cachecloud.owner.weChat','xxx,yyy','微信号报警(逗号隔开)',1,21),('cachecloud.public.key.pem','/opt/ssh/id_rsa','密钥路径',1,5),('cachecloud.public.user.name','cachecloud-open','公钥用户名',1,4),('cachecloud.ssh.auth.type','1','ssh授权方式',1,1),('cachecloud.superAdmin','admin,xx,yy','超级管理员组',1,13),('cachecloud.user.login.type','1','用户登录状态保存方式(session或cookie)',1,22),('cachecloud.weChat.alert.interface','','微信报警接口(参考报警接口规范)',1,23),('cachecloud.whether.schedule.clean.data','false','是否定期清理统计数据',1,34),('machine.load.alert.ratio','8.0','机器负载报警阀值',1,32);
COMMIT;

-- ----------------------------
--  Table structure for `system_resource`
-- ----------------------------
DROP TABLE IF EXISTS `system_resource`;
CREATE TABLE `system_resource` (
   `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '资源ID',
   `name` varchar(64) NOT NULL COMMENT '资源名称',
   `intro` varchar(255) DEFAULT NULL COMMENT '资源说明',
   `type` tinyint(4) NOT NULL COMMENT '1:仓库地址 2:脚本 3:资源包 4:公钥/私钥 6:目录管理 7:迁移工具管理',
   `lastmodify` datetime DEFAULT NULL COMMENT '最后更新时间',
   `dir` varchar(128) DEFAULT NULL COMMENT '资源路径',
   `url` varchar(128) DEFAULT NULL COMMENT '仓库地址',
   `ispush` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0:未推送 1:已推送',
   `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '0:无效 1:有效',
   `username` varchar(255) DEFAULT NULL COMMENT '最后修改人',
   `task_id` bigint(11) DEFAULT NULL COMMENT '迁移任务id',
   `compile_info` varchar(255) DEFAULT NULL COMMENT '编译信息',
   PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8;

-- ----------------------------
--  Records of `system_resource`
-- ----------------------------
BEGIN;
INSERT INTO `system_resource` VALUES (1,'cachecloud-init.sh','容器初始化脚本',2,'2020-07-15 18:35:41','/script','',0,1,NULL,NULL,NULL),(2,'x.x.x.x',NULL,1,'2020-08-10 10:31:51','/opt/download/software/cachecloud/resource','http://x.x.x.x/software/cachecloud/resource',0,1,'admin',0,NULL),(4,'cachecloud-env.sh','宿主环境脚本',2,'2020-07-15 18:36:28','/script','',0,1,NULL,NULL,NULL),(5,'id_rsa','私钥文件',4,'2020-07-07 10:45:39','/ssh','',0,1,NULL,NULL,NULL),(6,'id_rsa.pub','公钥文件',4,'2020-07-07 10:45:45','/ssh','',0,1,NULL,NULL,NULL),(12,'redis-4.0.14','redis 4.0.14资源包',3,'2020-08-10 09:52:41','/redis','http://download.redis.io/releases/redis-4.0.14.tar.gz',0,1,'admin',532,NULL),(21,'/script','脚本目录管理',6,'2020-08-10 10:51:34','',NULL,0,1,'admin',0,NULL),(28,'/ssh','ssh目录',6,'2020-07-20 17:55:03',NULL,NULL,0,1,'admin',0,NULL),(29,'redis-3.0.7','redis3.0.7 资源包',3,'2020-08-10 09:53:32','/redis','http://download.redis.io/releases/redis-3.0.7.tar.gz',0,1,'admin',529,NULL),(31,'redis-3.2.12','redis 3.2.12 资源包',3,'2020-08-10 15:08:21','/redis','http://download.redis.io/releases/redis-3.2.12.tar.gz',0,1,'admin',530,NULL),(32,'/redis','redis资源包管理',6,'2020-07-20 17:54:59',NULL,NULL,0,1,'admin',0,NULL),(33,'/tool','迁移工具资源包',6,'2020-07-20 17:54:53',NULL,NULL,0,1,'admin',0,NULL),(37,'redis-5.0.9','redis5.0.9 资源包',3,'2020-08-10 09:51:41','/redis','http://download.redis.io/releases/redis-5.0.9.tar.gz',0,1,'admin',533,NULL),(40,'redis-shake-2.0.3','redis 2.0.3\n修复fix 5.0迁移类型问题',7,'2020-08-11 10:53:26','/tool','https://github.com/alibaba/RedisShake/releases/download/release-v2.0.3-20200724/redis-shake-v2.0.3.tar.gz',0,1,'admin',518,NULL);
COMMIT;

--
-- Table structure for table `task_queue`
--

DROP TABLE IF EXISTS `task_queue`;
CREATE TABLE `task_queue` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `app_id` bigint(20) NOT NULL COMMENT '应用id',
  `class_name` varchar(255) NOT NULL COMMENT '类名',
  `important_info` varchar(255) NOT NULL DEFAULT '' COMMENT '重要信息',
  `execute_ip_port` varchar(255) DEFAULT '' COMMENT '执行任务的ip:port',
  `param` longtext NOT NULL COMMENT '任务参数(json):随着任务变化',
  `init_param` longtext NOT NULL COMMENT '初始化任务参数(json):不变',
  `status` tinyint(4) NOT NULL COMMENT '状态：0等待，1运行，2中断，3失败',
  `parent_task_id` bigint(20) NOT NULL COMMENT '父任务id',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '修改时间',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `priority` int(11) NOT NULL COMMENT '优先级',
  `error_code` int(11) NOT NULL COMMENT '错误代码',
  `error_msg` varchar(255) NOT NULL COMMENT '错误消息',
  `task_note` varchar(255) NOT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_app_id` (`app_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务表';

--
-- Table structure for table `task_step_flow`
--

DROP TABLE IF EXISTS `task_step_flow`;
CREATE TABLE `task_step_flow` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `task_id` bigint(20) NOT NULL COMMENT '任务id',
  `child_task_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '子任务id',
  `execute_ip_port` varchar(255) DEFAULT '' COMMENT '执行任务的ip:port',
  `class_name` varchar(255) NOT NULL COMMENT '类名',
  `step_name` varchar(255) NOT NULL COMMENT '步骤名',
  `order_no` int(11) NOT NULL COMMENT '序号',
  `status` tinyint(4) NOT NULL COMMENT '状态：0未开始、1成功、2中断、3跳过、4失败',
  `log` text COMMENT '日志',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_class_step` (`task_id`,`class_name`,`step_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务步骤流表';

--
-- Table structure for table `task_step_meta`
--

DROP TABLE IF EXISTS `task_step_meta`;
CREATE TABLE `task_step_meta` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `class_name` varchar(255) NOT NULL COMMENT '类名',
  `step_name` varchar(255) NOT NULL COMMENT '步骤名',
  `step_desc` varchar(255) NOT NULL COMMENT '步骤描述',
  `ops_device` varchar(255) NOT NULL COMMENT '运维建议',
  `timeout` int(11) NOT NULL COMMENT '超时时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '修改时间',
  `order_no` int(11) NOT NULL COMMENT '序号',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_class_step` (`class_name`,`step_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务步骤元数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

-- ----------------------------
--  Table structure for `standard_statistics`
-- ----------------------------
DROP TABLE IF EXISTS `standard_statistics`;
CREATE TABLE `standard_statistics` (
   `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
   `collect_time` bigint(20) NOT NULL COMMENT '收集时间:格式yyyyMMddHHmm',
   `ip` varchar(16) NOT NULL COMMENT 'ip地址',
   `port` int(11) NOT NULL COMMENT '端口/hostId',
   `db_type` varchar(16) NOT NULL COMMENT '收集的数据类型',
   `info_json` text NOT NULL COMMENT '收集的json数据',
   `diff_json` text NOT NULL COMMENT '上一次收集差异的json数据',
   `created_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
   `cluster_info_json` varchar(20480) NOT NULL DEFAULT '' COMMENT '收集的cluster info json数据',
   PRIMARY KEY (`id`),
   UNIQUE KEY `uniq_index` (`ip`,`port`,`db_type`,`collect_time`),
   KEY `idx_create_time` (`created_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- Table structure for table `app_alert_record`
--
DROP TABLE IF EXISTS `app_alert_record`;
CREATE TABLE `app_alert_record` (
`id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增id',
`visible_type` int(1) NOT NULL COMMENT '可见类型（0：均可见；1：仅管理员可见；）',
`important_level` int(1) NOT NULL COMMENT '重要类型（0：一般；1：重要；2：紧急）',
`create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
`app_id` bigint(20) DEFAULT NULL COMMENT 'app id',
`instance_id` bigint(20) DEFAULT NULL COMMENT '实例id',
`ip` varchar(16) COLLATE utf8_bin DEFAULT NULL COMMENT '机器ip',
`port` int(10) DEFAULT NULL COMMENT '端口号',
`title` varchar(255) COLLATE utf8_bin NOT NULL COMMENT '报警标题',
`content` varchar(500) COLLATE utf8_bin NOT NULL COMMENT '报警内容',
PRIMARY KEY (`id`),
KEY `app_id` (`app_id`),
KEY `ip` (`ip`),
KEY `idx_inst_id` (`instance_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='报警记录表';

--
-- Table structure for table `config_restart_record`
--
DROP TABLE IF EXISTS `config_restart_record`;
CREATE TABLE `config_restart_record` (
 `id` bigint(20) NOT NULL AUTO_INCREMENT,
 `app_id` bigint(20) NOT NULL COMMENT '应用id',
 `app_name` varchar(36) NOT NULL COMMENT '应用名称',
 `operate_type` char(1) NOT NULL COMMENT '操作类型（0:滚动重启，1:修改配置强制重启；2：修改配置）',
 `param` varchar(2000) NOT NULL COMMENT '初始化任务参数(json):不变',
 `status` tinyint(4) NOT NULL COMMENT '状态：0等待，1运行，2成功，3失败，4配置修改待重启',
 `start_time` datetime NOT NULL COMMENT '开始时间',
 `end_time` datetime NOT NULL COMMENT '结束时间',
 `create_time` datetime NOT NULL COMMENT '创建时间',
 `update_time` datetime NOT NULL COMMENT '修改时间',
 `log` longtext COMMENT '日志信息',
 `user_name` varchar(64) DEFAULT NULL COMMENT '操作人员姓名',
 `user_id` bigint(20) NOT NULL COMMENT '用户id',
 `instances` varchar(1000) DEFAULT NULL COMMENT '涉及实例id列表的json格式',
 PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='重启记录表';

--
-- Table structure for table `module_info`
--
DROP TABLE IF EXISTS `module_info`;
CREATE TABLE `module_info` (
   `id` int(11) NOT NULL AUTO_INCREMENT,
   `name` varchar(64) NOT NULL,
   `git_url` varchar(255) NOT NULL DEFAULT '' COMMENT 'git resource',
   `info` varchar(128) DEFAULT NULL COMMENT '模块信息说明',
   `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '0:无效 1:有效',
   PRIMARY KEY (`id`),
   UNIQUE KEY `NAMEKEY` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Redis模块信息表';

--
-- Table structure for table `module_version`
--
DROP TABLE IF EXISTS `module_version`;
CREATE TABLE `module_version` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module_id` int(11) NOT NULL,
  `version_id` int(11) NOT NULL COMMENT '关联版本号',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `so_path` varchar(255) DEFAULT NULL COMMENT '编译后so库的地址',
  `tag` varchar(64) NOT NULL COMMENT '模块版本号',
  `status` int(255) NOT NULL DEFAULT '0' COMMENT '是否可用(关联so地址)：0 不可用 1：可用',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Redis模块版本管理表';

--
-- Table structure for table `app_import`
--
DROP TABLE IF EXISTS `app_import`;
CREATE TABLE `app_import` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `app_id` bigint(20) DEFAULT NULL COMMENT '目标应用id',
  `instance_info` text COMMENT '源redis实例信息',
  `redis_password` varchar(200) DEFAULT NULL COMMENT '源redis密码',
  `status` int(11) DEFAULT NULL COMMENT '迁移状态：PREPARE(0, "准备", "应用导入-未开始"), START(1, "进行中...", "应用导入-开始"), ERROR(2, "error", "应用导入-出错"), VERSION_BUILD_START(11, "进行中...", "新建redis版本-进行中"), VERSION_BUILD_ERROR(12, "error", "新建redis版本-出错"), VERSION_BUILD_END(20, "成功", "新建redis版本-完成"), APP_BUILD_INIT(21, "准备就绪", "新建redis应用-准备就绪"), APP_BUILD_START(22, "进行中...", "新建redis应用-进行中"), APP_BUILD_ERROR(23, "error", "新建redis应用-出错"), APP_BUILD_END(30, "成功", "新建redis应用-完成"), MIGRATE_INIT(31, "准备就绪", "数据迁移-准备就绪"), MIGRATE_START(32, "进行中...", "数据迁移-进行中"), MIGRATE_ERROR(33, "error", "数据迁移-出错"), MIGRATE_END(3, "成功", "应用导入-成功")',
  `step` int(11) DEFAULT NULL COMMENT '导入阶段',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `migrate_id` bigint(20) DEFAULT NULL COMMENT '数据迁移id',
  `mem_size` int(11) DEFAULT NULL COMMENT '目标应用内存大小，单位G',
  `redis_version_name` varchar(20) DEFAULT NULL COMMENT '目标应用redis版本，格式：redis-x.x.x',
  `app_build_task_id` bigint(20) DEFAULT NULL COMMENT '目标应用部署任务id',
  `source_type` int(11) DEFAULT NULL COMMENT '源redis类型：7:cluster, 6:sentinel, 5:standalone',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;