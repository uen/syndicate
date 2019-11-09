manolis.popcorn.gangs.shop.AddItem({
	level = 1,
	name = "Gang Unarrest Stick",
	model = "models/weapons/w_stunbaton.mdl",
	description = "Rescue gang members from jail",
	price = 12000,
	entity = "spawned_weapon",
	type = "unarrest_stick"
})

manolis.popcorn.gangs.shop.AddItem({
	level = 3,
	model = "models/weapons/w_c4_planted.mdl",
	name = "Gang Printer Cooler",
	description = "Overclocked printer cooler for gangs",
	price = 20000,
	entity = "ent_cooler",
	type = 1,
	range = 200,
	time = 1000,
	rate = 1
})

manolis.popcorn.gangs.shop.AddItem({
	level = 5,
	model = "models/weapons/w_c4_planted.mdl",
	name = "Gang Printer Rate Increaser",
	description = "Overclocked printer rate increaser for gangs",
	price = 10000,
	entity = "ent_cooler",
	type = 2,
	range = 200,
	time = 1000,
	rate = 0.4
})

manolis.popcorn.gangs.shop.AddItem({
	level = 7,
	model = "models/weapons/w_c4_planted.mdl",
	name = "Gang Printer Amount Increaser",
	description = "Overclocked printer amount increaser for gangs",
	price = 15000,
	entity = "ent_cooler",
	type = 3,
	range = 200,
	time = 1000,
	rate = 1.4

})


manolis.popcorn.gangs.shop.AddItem({
	level = 3,
	model = "models/props_c17/consolebox03a.mdl",
	name = "White Gang Printer",
	description = "Printer for gangs, collected money goes to your gang bank",
	price = 100000,
	money = 25000,
	isPrinter = true,
	entity = "gang_printer",
	color = Color(255,255,255,220),
	type = 1
})

manolis.popcorn.gangs.shop.AddItem({
	level = 6,
	model = "models/props_c17/consolebox01a.mdl",
	name = "Gold Gang Printer",
	description = "Printer for gangs, collected money goes to your gang bank",
	price = 250000,
	money = 65000,
	isPrinter = true,
	color = Color(220,210,15,220),
	entity = "gang_printer",
	type = 2
})

manolis.popcorn.gangs.shop.AddItem({
	level = 9,
	model = "models/props_lab/partsbin01.mdl",
	name = "Purple Gang Printer",
	description = "Printer for gangs, collected money goes to your gang bank",
	price = 2000000,
	money = 500000,
	isPrinter = true,
	Color(100,255,100,220),
	entity = "gang_printer",
	type = 3
})