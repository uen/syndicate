--[[
		You must setup MySQL for this gamemode to work! 
]]

if(!MySQLite_config) then MySQLite_config = {} end // Ignore this line

MySQLite_config.EnableMySQL = true -- Set to true once you have entered your DarkRP details
MySQLite_config.Host = "127.0.0.1" -- This is the IP address of the MySQL host. Make sure the IP address is correct and in quotation marks (" ")
MySQLite_config.Username = "root" -- This is the username to log in on the MySQL server.
								-- contact the owner of the server about the username and password. Make sure it's in quotation marks! (" ")
MySQLite_config.Password = "" -- This is the Password to log in on the MySQL server,
									-- Everyone who has access to FTP on the server can read this password.
									-- Make sure you know who to trust. Make sure it's in quotation marks (" ")
MySQLite_config.Database_name = "syndicate" -- This is the name of the Database on the MySQL server. Contact the MySQL server host to find out what this is
MySQLite_config.Database_port = 3306 -- This is the port of the MySQL server. Again, contact the MySQL server host if you don't know this.
MySQLite_config.Preferred_module = "tmysql4" -- Preferred module, case sensitive, must be either "mysqloo" or "tmysql4". Only applies when both are installed.
MySQLite_config.MultiStatements = false -- Only available in tmysql4: allow multiple SQL statements per query. Has no effect if no scripts use it.


--[[
MANUAL! 
HOW TO USE MySQL FOR DARKRP!
Download andyvincent's/Drakehawke's/KingofBeast's gm_MySQL OO module and read the guide here:
http://facepunch.com/showthread.php?t=1357773


WHAT TO DO IF YOU CAN'T GET IT TO WORK!
	- There are always errors on the server, try if you can see those (with HLDS/server logs)
	- the same errors are also in the logs if you can't find the errors on the server.
		the logs are at garrysmod/data/DarkRP_logs/ on the SERVER!
		The MySQL lines in the log always precede with "MySQL Error:" (without the quotation marks)
	- make sure the settings in this file (mysql.lua) are correct
	- make sure the MySQL server is accessible from the servers IP
]]
