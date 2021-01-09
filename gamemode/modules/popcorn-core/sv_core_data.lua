if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.data) then manolis.popcorn.data = {} end

manolis.popcorn.data.duplicateUpdate = function(key)
	if(MySQLite.isMySQL()) then
		return " ON DUPLICATE KEY UPDATE"
	else
		return "ON CONFLICT("..key..") DO UPDATE SET"
	end
end

hook.Add("DarkRPDBInitialized", "Manolis:Popcorn:InitDatabaseTables", function()
	print("db initialized")
	local AUTOINCREMENT = MySQLite.isMySQL() and "AUTO_INCREMENT" or "AUTOINCREMENT"


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_achievements` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `aid` varchar(50) NOT NULL,
	  `progress` double NOT NULL,
	  `uid` varchar(50) NOT NULL
	);]])

	MySQLite.query([[
		ALTER TABLE manolis_popcorn_achievements ADD CONSTRAINT `uniq` UNIQUE (`aid`, `uid`)")
	]])



	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_bank` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `uid` bigint(20) NOT NULL,
	  `slot` int(11) NOT NULL,
	  `name` varchar(255) NOT NULL,
	  `entity` varchar(255) NOT NULL,
	  `value` varchar(2555) NOT NULL,
	  `type` varchar(255) NOT NULL,
	  `json` text NOT NULL,
	  `icon` varchar(10000) NOT NULL,
	  `level` int(10) NOT NULL,
	  `quantity` int(10) NOT NULL
	);]])

	MySQLite.query([[
		ALTER TABLE manolis_popcorn_bank ADD CONSTRAINT `uid` UNIQUE (`uid`, `slot`)")
	]])


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_buildings` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `map` varchar(255) NOT NULL,
	  `name` varchar(255) NOT NULL
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_buildings_capturepoints` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `map` varchar(255) NOT NULL,
	  `bid` int(11) NOT NULL,
	  `px` double NOT NULL,
	  `py` double NOT NULL,
	  `pz` double NOT NULL,
	  `a1` double NOT NULL,
	  `a2` double NOT NULL,
	  `a3` double NOT NULL
	);]])

	MySQLite.query([[
		ALTER TABLE manolis_popcorn_buildings_capturepoints ADD CONSTRAINT `bid` UNIQUE (`bid`, `map`)")
	]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_buildings_cash` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `map` varchar(255) NOT NULL,
	  `bid` int(11) NOT NULL,
	  `px` double NOT NULL,
	  `py` double NOT NULL,
	  `pz` double NOT NULL,
	  `a1` double NOT NULL,
	  `a2` double NOT NULL,
	  `a3` double NOT NULL
	);]])


	MySQLite.query([[
		ALTER TABLE manolis_popcorn_buildings_cash ADD CONSTRAINT `cash` UNIQUE (`bid`, `map`)")
	]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_buildings_doors` (
	  `id` int(11) NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `map` varchar(255) NOT NULL,
	  `main` int(11) NOT NULL,
	  `bid` int(11) NOT NULL
	);]])

	MySQLite.query([[
		ALTER TABLE manolis_popcorn_buildings_doors ADD CONSTRAINT `cash` UNIQUE (`bid`, `map`)")
	]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_buildings_power` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `map` varchar(255) NOT NULL,
	  `bid` int(11) NOT NULL,
	  `px` double NOT NULL,
	  `py` double NOT NULL,
	  `pz` double NOT NULL,
	  `a1` double NOT NULL,
	  `a2` double NOT NULL,
	  `a3` double NOT NULL
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_buildings_rent` (
	  `bid` int(11) PRIMARY KEY NOT NULL,
	  `rent` int(11) NOT NULL
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_equipment` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `uid` bigint(20) NOT NULL,
	  `slot` varchar(255) NOT NULL,
	  `item` int(11) NOT NULL
	);]])


	MySQLite.query([[
		ALTER TABLE manolis_popcorn_equipment ADD CONSTRAINT `uid` UNIQUE (`uid`, `slot`)")
	]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gangs` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `name` varchar(255) NOT NULL,
	  `password` varchar(255) NOT NULL,
	  `logo` varchar(2556) NOT NULL,
	  `bank` int(11) NOT NULL,
	  `points` int(11) NOT NULL,
	  `level` int(255) NOT NULL,
	  `xp` int(255) NOT NULL,
	  `color` varchar(255) NOT NULL,
	  `secondcolor` varchar(255) NOT NULL,
	  `timestamp` varchar(255) NOT NULL
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gangs_members` (
	  `uid` varchar(255) NOT NULL,
	  `gangid` int(11) NOT NULL,
	  `rank` int(11) NOT NULL
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gangs_rivals` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `g1` int(11) NOT NULL,
	  `g2` int(11) NOT NULL,
	  `active` int(1) NOT NULL,
	  `timestamp` varchar(255) NOT NULL
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gangs_truces` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `g1` int(11) NOT NULL,
	  `g2` int(11) NOT NULL,
	  `truce` int(11) NOT NULL
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_blocked` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `g1` int(11) NOT NULL,
	  `g2` int(11) NOT NULL,
	  `timestamp` varchar(255) NOT NULL
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_invites` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `uid` varchar(255) NOT NULL,
	  `gangid` int(11) NOT NULL
	);]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_kills` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `attacker` int(11) NOT NULL,
	  `victim` int(11) NOT NULL,
	  `amount` int(11) NOT NULL
	);]])

	MySQLite.query([[
		ALTER TABLE manolis_popcorn_gang_kills ADD CONSTRAINT `item` UNIQUE (`item`, `gangid`)")
	]])

	

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_permissions` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `item` varchar(255) NOT NULL,
	  `r1` int(11),
	  `r2` int(11),
	  `r3` int(11),
	  `r4` int(11),
	  `r5` int(11),
	  `gangid` int(11) NOT NULL
	);]])

	MySQLite.query([[
		ALTER TABLE manolis_popcorn_gang_permissions ADD CONSTRAINT `item` UNIQUE (`item`, `gangid`)")
	]])
		
	MySQLite.query([[ALTER TABLE `manolis_popcorn_gang_permissions` MODIFY r1 int(11);]])
	MySQLite.query([[ALTER TABLE `manolis_popcorn_gang_permissions` MODIFY r2 int(11);]])
	MySQLite.query([[ALTER TABLE `manolis_popcorn_gang_permissions` MODIFY r3 int(11);]])
	MySQLite.query([[ALTER TABLE `manolis_popcorn_gang_permissions` MODIFY r4 int(11);]])
	MySQLite.query([[ALTER TABLE `manolis_popcorn_gang_permissions` MODIFY r5 int(11);]])
		



	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_stashes` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `attacker` int(11) NOT NULL,
	  `victim` int(11) NOT NULL,
	  `amount` int(11) NOT NULL
	);]])



	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_territories` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `map` varchar(255) NOT NULL,
	  `name` varchar(255) NOT NULL
	);]])


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_territories_locations` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `map` varchar(255) NOT NULL,
	  `x` float NOT NULL,
	  `y` float NOT NULL,
	  `z` float NOT NULL,
	  `tid` int(11) NOT NULL
	);]])


	MySQLite.query([[ALTER TABLE  `manolis_popcorn_gang_territories_locations` CHANGE  `map`  `map` VARCHAR( 255 ) NOT NULL ;]])

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gang_upgrades` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `ukey` varchar(255) NOT NULL,
	  `gangid` int(11) NOT NULL,
	  `val` int(11) NOT NULL
	);]])

	MySQLite.query([[
		ALTER TABLE manolis_popcorn_gang_territories_locations ADD CONSTRAINT `ukey` UNIQUE (`ukey`, `gangid`)")
	]])

	

	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_garage` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `uid` varchar(50) NOT NULL,
	  `name` varchar(50) NOT NULL,
	  `json` text NOT NULL
	);]])

	MySQLite.query([[
		ALTER TABLE manolis_popcorn_garage ADD CONSTRAINT `name` UNIQUE (`name`, `uid`)")
	]])


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_gifts` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `name` varchar(255) NOT NULL,
	  `uid` varchar(255) NOT NULL
	);]])


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_inventory` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
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
	  `quantity` int(10) NOT NULL
	);]])

	MySQLite.query([[
		ALTER TABLE manolis_popcorn_inventory ADD CONSTRAINT `uid` UNIQUE (`uid`, `slot`, `page`)")
	]])



	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_levels` (
	  `uid` bigint(20) NOT NULL,
	  `level` int(11) NOT NULL,
	  `xp` int(11) NOT NULL
	);]])


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_positions` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `name` varchar(50) NOT NULL,
	  `map` varchar(50) NOT NULL,
	  `x` double NOT NULL,
	  `y` double NOT NULL,
	  `z` double NOT NULL,
	  `ax` double NOT NULL,
	  `ay` double NOT NULL,
	  `az` double NOT NULL
	);]])

	MySQLite.query([[
		ALTER TABLE manolis_popcorn_inventory ADD CONSTRAINT `name` UNIQUE (`name`, `map`)")
	]])


	MySQLite.query([[CREATE TABLE IF NOT EXISTS `manolis_popcorn_quickbuy` (
	  `id` integer NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
	  `uid` varchar(255) NOT NULL,
	  `slot` int(11) NOT NULL,
	  `cmd` varchar(255) NOT NULL,
	  `mdl` varchar(255) NOT NULL
	);]])


end)
