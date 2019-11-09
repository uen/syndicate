DarkRP.createShipment("100hp Health Kit", {
	level = 1,
	amountOfHealth = 100,
	model = "models/Items/battery.mdl",
	entity = "ent_healthkit",
	price = 500, 
	amount = 5, 
	separate = false,
	noship = false,
    category = "Health Kits",
    sortOrder = 100,
})

DarkRP.createShipment("500hp Health Kit", {
	level = 1,
	amountOfHealth = 500,
	model = "models/Items/combine_rifle_ammo01.mdl",
	entity = "ent_healthkit",
	price = 5000, 
	amount = 5, 
	separate = false,
	noship = false,
    category = "Health Kits",
    sortOrder = 100,
})

DarkRP.createShipment("1000hp Health Kit", {
	level = 31,
	amountOfHealth = 1000,
	model = "models/Items/car_battery01.mdl",
	entity = "ent_healthkit",
	price = 10000, 
	amount = 5, 
	separate = false,
	noship = false,
    category = "Health Kits",
    sortOrder = 100,
})

DarkRP.createShipment("2500hp Health Kit", {
	level = 31,
	amountOfHealth = 2500,
	model = "models/Items/car_battery01.mdl",
	entity = "ent_healthkit",
	price = 10000, 
	amount = 5, 
	separate = false,
	noship = false,
    category = "Health Kits",
    sortOrder = 100,
    allowed = {TEAM_MERCHANT}
})

DarkRP.createShipment("250+ Armor Kit", {
	level = 1,
	amountOfArmor = 250,
	model = "models/Items/BoxMRounds.mdl",
	entity = "ent_armorkit",
	price = 4000, 
	amount = 5, 
	separate = false,
	noship = false,
    category = "Armor Kits",
    sortOrder = 100,
})

DarkRP.createShipment("1000+ Armor Kit", {
	level = 31,
	amountOfArmor = 1,
	model = "models/Items/BoxMRounds.mdl",
	entity = "ent_armorkit",
	price = 4000, 
	amount = 5, 
	separate = false,
	noship = false,
    category = "Armor Kits",
    sortOrder = 100,
    allowed = {TEAM_MERCHANT}
})


DarkRP.createShipment("Lockpick",{
	level = 5,
	model = "models/weapons/w_crowbar.mdl",
	entity = "lockpick",
	price = 7000,
	amount = 5,
	seperate = false,
	noship = false,
	category = "Lockpicks",
	sortOrder = 100,
	allowed = {TEAM_MERCHANT}
})

DarkRP.createShipment("Pro Lockpick",{
	level = 10,
	model = "models/weapons/w_crowbar.mdl",
	entity = "pro_lockpick",
	price = 20000,
	amount = 5,
	seperate = false,
	noship = false,
	category = "Lockpicks",
	sortOrder = 100,
	allowed = {TEAM_MERCHANT}
})

DarkRP.createShipment("Keypad Cracker",{
	level = 5,
	model = "models/weapons/w_c4.mdl",
	entity = "keypad_cracker",
	price = 7000,
	amount = 5,
	seperate = false,
	noship = false,
	category = "Keypad Crackers",
	sortOrder = 100,
	allowed = {TEAM_MERCHANT}
})

DarkRP.createShipment("Pro Keypad Cracker",{
	level = 10,
	model = "models/weapons/w_c4.mdl",
	entity = "keypad_cracker_pro",
	price = 20000,
	amount = 5,
	seperate = false,
	noship = false,
	category = "Keypad Crackers",
	sortOrder = 100,
	allowed = {TEAM_MERCHANT}
})



DarkRP.createShipment("Grenade",{
	level = 9,
	allowed = {TEAM_GUN, TEAM_HEAVYGUN, TEAM_MERCHANT},
	price = 45000,
	amount = 5,
	seperate = false,
	noship = false,
	entity = "weapon_popcorn_grenade",
	model = "models/weapons/w_eq_fraggrenade.mdl"
})



// Terrorism
DarkRP.createEntity('Uranium Core', {
	ent = "popcorn_rod",
	model = "models/props_phx/gears/bevel12.mdl",
	category = 'Terrorism',
	price = 100000,
	level = 24,
	max = 8, 
	cmd = "popcornuraniumrod",
	allowed = {TEAM_TERRORIST}
})


DarkRP.createEntity('Uranium Enricher', {
	ent = "popcorn_enricher",
	model = "models/props_combine/combine_mine01.mdl",
	category = 'Terrorism',
	price = 100000,
	level = 24,
	max = 1,
	cmd = "popcornuraniumenricher",
	allowed = {TEAM_TERRORIST}
})