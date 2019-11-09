local GAMEMODE = GAMEMODE or GM

TEAM_HOBO = DarkRP.createJob("Hobo", {
	color = Color(80,45,0,255),
	model = "models/player/corpse1.mdl",
	description = '',
	weapons = {},
	command = "hobos",
	level = 1,
	max = 99,
	salary = 0,
	admin = 0
})


TEAM_POLICE2 = DarkRP.createJob("Police", {
	color = Color(25, 25, 170, 255),
	model = "models/player/police.mdl",
	description = '',
	weapons = {'arrest_stick', 'taser', 'keypad_cracker', 'door_ram', 'weapon_bombdefuse'},
	command = "cps",
	level = 10,
	max = 4,
	salary = 450,
	admin = 0
})


TEAM_POLICECHIEF = DarkRP.createJob("Police Chief", {
	color = Color(20, 20, 255, 255),
	model = "models/player/combine_soldier_prisonguard.mdl",
	description = '',
	weapons = {'arrest_stick', 'taser', 'keypad_cracker', 'door_ram', 'weapon_bombdefuse'},
	command = "cpchief",
	level = 15,
	max = 1,
	salary = 60,
	admin = 0
})


if(!GAMEMODE.CivilProtection) then GAMEMODE.CivilProtection = {} end
GAMEMODE.CivilProtection[TEAM_POLICECHIEF] = true
GAMEMODE.CivilProtection[TEAM_POLICE2] = true

TEAM_GANGSTER = DarkRP.createJob("Gangster", {
	color = Color(60, 160, 255, 255),
	model = "models/player/group03/male_01.mdl",
	description = '',
	weapons = {},
	command = "gangsters",
	level = 3,
	max = 5,
	salary = 100,
	admin = 0
})

TEAM_MERCHANT = DarkRP.createJob("Merchant", {
	color = Color(0, 240, 150,255),
	model = "models/player/odessa.mdl",
	description = [[Merchants sell useful items to players]],
	weapons = {},
	command = "merchant",
	level = 5,
	max = 2,
	salary = 250,
	admin = 0,
})

TEAM_THIEF = DarkRP.createJob("Thief", {
	color = Color(180, 180, 180, 255),
	model = "models/player/monk.mdl",
	command = "thief",
	description = '',
	max = 4,
	level = 13,
	salary = 200,
	admin = 0,
	weapons = {'pickpocket', 'keypad_cracker', 'lockpick', 'swagbag'}
})

TEAM_EXPLOSIVE = DarkRP.createJob("Explosives Trader", {
	color = Color(255,140,0,255),
	model = "models/player/phoenix.mdl",
	description = '',
	command = "explosives",
	max = 2,
	level = 15,
	salary = 200,
	admin = 0
})

TEAM_PROTHIEF = DarkRP.createJob("Pro Thief", {
	color = Color(110, 110, 110, 255),
	model = "models/player/urban.mdl",
	command = "prothief",
	max = 3,
	description = '',
	level = 19,
	salary = 200,
	admin = 0,
	weapons = {'pickpocket', 'pro_keypad_cracker', 'pro_lockpick', 'pro_swagbag'}
})


TEAM_TERRORIST = DarkRP.createJob("Terrorist", {
	color = Color(0,0,0, 255),
	model = "models/player/guerilla.mdl",
	command = 'terrorist',
	max = 4,
	weapons = {'pro_lockpick'},
	description = '',
	salary = 0,
	admin = 0,
	level = 24
})


TEAM_BLACKMARKET = DarkRP.createJob("Black Market Tradesman", {
	color=Color(40,40,40,255),
	model = "models/player/odessa.mdl",
	max = 2,
	command = 'bmd',
	salary = 1400,
	description = '',
	level = 35,
	admin = 0
})


TEAM_MASTERTHIEF = DarkRP.createJob("Master Thief", {
	color = Color(110,110,110,255),
	model = "models/player/urban.mdl",
	salary = 1000,
	level = 45,
	weapons = {'pickpocket', 'master_keypad_cracker', 'pro_lockpick', 'pro_swagbag'},
	command = "masterthief",
	admin = 0,
	description = '',
	max = 2,
})

TEAM_ADMIN = DarkRP.createJob("Admin On Duty", {
	color = Color(255,0,0,255),
	model = "models/player/Combine_Super_Soldier.mdl",
	salary = 0,
	max = 5,
	description = '',
	level = 99,
	weapons = {},
	command = "aod",
	admin = 1
})