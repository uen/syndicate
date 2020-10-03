hook.Add("DarkRPDBInitialized", "Manolis:Popcorn:InitDatabaseTables", function()


	local AUTOINCREMENT = MySQLite.isMySQL() and "AUTO_INCREMENT" or "AUTOINCREMENT"


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_achievements` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `aid` varchar(50) NOT NULL,
	  `progress` double NOT NULL,
	  `uid` varchar(50) NOT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `uniq` (`aid`,`uid`)
	);]])



	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_bank` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `uid` bigint(20) NOT NULL,
	  `slot` int(11) NOT NULL,
	  `name` varchar(255) NOT NULL,
	  `entity` varchar(255) NOT NULL,
	  `value` varchar(2555) NOT NULL,
	  `type` varchar(255) NOT NULL,
	  `json` text NOT NULL,
	  `icon` varchar(10000) NOT NULL,
	  `level` int(10) NOT NULL,
	  `quantity` int(10) NOT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `uid` (`uid`,`slot`)
	);]])


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_buildings` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `map` varchar(255) NOT NULL,
	  `name` varchar(255) NOT NULL,
	  UNIQUE KEY `id` (`id`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_buildings_capturepoints` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `map` varchar(255) NOT NULL,
	  `bid` int(11) NOT NULL,
	  `px` double NOT NULL,
	  `py` double NOT NULL,
	  `pz` double NOT NULL,
	  `a1` double NOT NULL,
	  `a2` double NOT NULL,
	  `a3` double NOT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `bid` (`bid`,`map`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_buildings_cash` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `map` varchar(255) NOT NULL,
	  `bid` int(11) NOT NULL,
	  `px` double NOT NULL,
	  `py` double NOT NULL,
	  `pz` double NOT NULL,
	  `a1` double NOT NULL,
	  `a2` double NOT NULL,
	  `a3` double NOT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `bid` (`bid`,`map`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_buildings_doors` (
	  `id` int(11) NOT NULL,
	  `map` varchar(255) NOT NULL,
	  `main` int(11) NOT NULL,
	  `bid` int(11) NOT NULL,
	  UNIQUE KEY `id` (`id`,`map`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_buildings_power` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `map` varchar(255) NOT NULL,
	  `bid` int(11) NOT NULL,
	  `px` double NOT NULL,
	  `py` double NOT NULL,
	  `pz` double NOT NULL,
	  `a1` double NOT NULL,
	  `a2` double NOT NULL,
	  `a3` double NOT NULL,
	  PRIMARY KEY (`id`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_buildings_rent` (
	  `bid` int(11) NOT NULL,
	  `rent` int(11) NOT NULL,
	  PRIMARY KEY (`bid`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_equipment` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `uid` bigint(20) NOT NULL,
	  `slot` varchar(255) NOT NULL,
	  `item` int(11) NOT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `uid` (`uid`,`slot`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gangs` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `name` varchar(255) NOT NULL,
	  `password` varchar(255) NOT NULL,
	  `logo` varchar(2556) NOT NULL,
	  `bank` int(11) NOT NULL,
	  `points` int(11) NOT NULL,
	  `level` int(255) NOT NULL,
	  `xp` int(255) NOT NULL,
	  `color` varchar(255) NOT NULL,
	  `secondcolor` varchar(255) NOT NULL,
	  `timestamp` varchar(255) NOT NULL,
	  PRIMARY KEY (`id`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gangs_members` (
	  `uid` varchar(255) NOT NULL,
	  `gangid` int(11) NOT NULL,
	  `rank` int(11) NOT NULL,
	  PRIMARY KEY (`uid`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gangs_rivals` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `g1` int(11) NOT NULL,
	  `g2` int(11) NOT NULL,
	  `active` int(1) NOT NULL,
	  `timestamp` varchar(255) NOT NULL,
	  PRIMARY KEY (`id`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gangs_truces` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `g1` int(11) NOT NULL,
	  `g2` int(11) NOT NULL,
	  `truce` int(11) NOT NULL,
	  PRIMARY KEY (`id`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_blocked` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `g1` int(11) NOT NULL,
	  `g2` int(11) NOT NULL,
	  `timestamp` varchar(255) NOT NULL,
	  PRIMARY KEY (`id`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_invites` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `uid` varchar(255) NOT NULL,
	  `gangid` int(11) NOT NULL,
	  PRIMARY KEY (`id`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_kills` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `attacker` int(11) NOT NULL,
	  `victim` int(11) NOT NULL,
	  `amount` int(11) NOT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `victim` (`victim`,`attacker`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_permissions` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `item` varchar(255) NOT NULL,
	  `r1` int(11),
	  `r2` int(11),
	  `r3` int(11),
	  `r4` int(11),
	  `r5` int(11),
	  `gangid` int(11) NOT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `item` (`item`,`gangid`)
	);]])
		
	MySQLite.query([[ALTER TABLE `manolis_popcorn_gang_permissions` MODIFY r1 int(11);]])
	MySQLite.query([[ALTER TABLE `manolis_popcorn_gang_permissions` MODIFY r2 int(11);]])
	MySQLite.query([[ALTER TABLE `manolis_popcorn_gang_permissions` MODIFY r3 int(11);]])
	MySQLite.query([[ALTER TABLE `manolis_popcorn_gang_permissions` MODIFY r4 int(11);]])
	MySQLite.query([[ALTER TABLE `manolis_popcorn_gang_permissions` MODIFY r5 int(11);]])
		



	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_stashes` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `attacker` int(11) NOT NULL,
	  `victim` int(11) NOT NULL,
	  `amount` int(11) NOT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `victim` (`victim`,`attacker`)
	);]])



	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_territories` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `map` varchar(255) NOT NULL,
	  `name` varchar(255) NOT NULL,
	  PRIMARY KEY (`id`)
	);]])


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_territories_locations` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `map` varchar(255) NOT NULL,
	  `x` float NOT NULL,
	  `y` float NOT NULL,
	  `z` float NOT NULL,
	  `tid` int(11) NOT NULL,
	  PRIMARY KEY (`id`)
	);]])


	MySQLite.query([[ALTER TABLE  `manolis_popcorn_gang_territories_locations` CHANGE  `map`  `map` VARCHAR( 255 ) NOT NULL ;]])


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_upgrades` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `ukey` varchar(255) NOT NULL,
	  `gangid` int(11) NOT NULL,
	  `val` int(11) NOT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `ukey` (`ukey`,`gangid`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_garage` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `uid` varchar(50) NOT NULL,
	  `name` varchar(50) NOT NULL,
	  `json` text NOT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `name` (`name`,`uid`)
	);]])


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gifts` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `name` varchar(255) NOT NULL,
	  `uid` varchar(255) NOT NULL,
	  PRIMARY KEY (`id`)
	);]])


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_inventory` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `uid` bigint(20) NOT NULL,
	  `slot` int(11) NOT NULL,
	  `name` varchar(255) NOT NULL,
	  `entity` varchar(255) NOT NULL,
	  `value` varchar(2555) NOT NULL,
	  `type` varchar(255) NOT NULL,
	  `json` text NOT NULL,
	  `page` varchar(255) NOT NULL,
	  `icon` varchar(10000) NOT NULL,
	  `level` int(10) NOT NULL,
	  `quantity` int(10) NOT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `uid` (`uid`,`slot`,`page`)
	);]])


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_levels` (
	  `uid` bigint(20) NOT NULL,
	  `level` int(11) NOT NULL,
	  `xp` int(11) NOT NULL,
	  UNIQUE KEY `uid` (`uid`)
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_positions` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `name` varchar(50) NOT NULL,
	  `map` varchar(50) NOT NULL,
	  `x` double NOT NULL,
	  `y` double NOT NULL,
	  `z` double NOT NULL,
	  `ax` double NOT NULL,
	  `ay` double NOT NULL,
	  `az` double NOT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `name` (`name`,`map`)
	);]])


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_quickbuy` (
	  `id` int(11) NOT NULL ]]..AUTOINCREMENT..[[,
	  `uid` varchar(255) NOT NULL,
	  `slot` int(11) NOT NULL,
	  `cmd` varchar(255) NOT NULL,
	  `mdl` varchar(255) NOT NULL,
	  PRIMARY KEY (`id`)
	);]])


end)
