--[[---------------------------------------------------------------------------
DarkRP custom entities
---------------------------------------------------------------------------

This file contains your custom entities.
This file should also contain entities from DarkRP that you edited.

Note: If you want to edit a default DarkRP entity, first disable it in darkrp_config/disabled_defaults.lua
	Once you've done that, copy and paste the entity to this file and edit it.

The default entities can be found here:
https://github.com/FPtje/DarkRP/blob/master/gamemode/config/addentities.lua#L111

For examples and explanation please visit this wiki page:
http://wiki.darkrp.com/index.php/DarkRP:CustomEntityFields

Add entities under the following line:
---------------------------------------------------------------------------]]

DarkRP.createEntity('2-Way Generator', {
	ent = 'popcorn_generator',
	model = 'models/maxofs2d/hover_propeller.mdl',
	price = 25000,
	max = 2,
	cmd='buypopcorngenerator2',
	level = 25,
	sockets = 2,
	maxFuel = 100
})

DarkRP.createEntity('4-Way Generator', {
	ent = 'popcorn_generator',
	model = 'models/maxofs2d/hover_propeller.mdl',
	price = 40000,
	max = 2,
	cmd='buypopcorngenerator4',
	level = 40,
	sockets = 4,
	maxFuel = 250
})

DarkRP.createEntity('Generator Fuel', {
	ent = 'popcorn_fuel',
	model = 'models/props_junk/metalgascan.mdl',
	price = 1000,
	max = 10,
	cmd='buypopcorngeneratorfuel',
	fuelAmount = 25
})

DarkRP.createEntity('Blueprint Infuser', {
	ent="popcorn_blueprint_infuser",
	model = 'models/maxofs2d/hover_plate.mdl',
	price = 50000,
	max = 1,
	level = 20,
	cmd = 'buypopcornblueprintinfuser',
})

DarkRP.createEntity('Blueprint Infuser Card', {
	ent='popcorn_blueprint_infuser_card',
	price = 10000,
	max = 5,
	level = 20,
	cmd = 'buypopcornblueprintinfusercard',
	model = 'models/props/cs_office/computer_caseb_p3a.mdl'
})