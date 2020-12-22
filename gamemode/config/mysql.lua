-- MySQL is optional but highly recommended

if(!MySQLite_config) then MySQLite_config = {} end // Ignore this line

MySQLite_config.EnableMySQL = false
MySQLite_config.Host = "127.0.0.1"
MySQLite_config.Username = "root"
MySQLite_config.Password = ""
MySQLite_config.Database_name = "syndicate"
MySQLite_config.Database_port = 3306
MySQLite_config.Preferred_module = "tmysql4" -- tmysql or mysqloo
MySQLite_config.MultiStatements = false 