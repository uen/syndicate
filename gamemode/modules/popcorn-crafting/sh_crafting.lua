if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.crafting) then manolis.popcorn.crafting = {} end
if(!manolis.popcorn.crafting.materials) then manolis.popcorn.crafting.materials = {} end
if(!manolis.popcorn.crafting.blueprints) then manolis.popcorn.crafting.blueprints = {} end

local material = {}
material.name = DarkRP.getPhrase('obsidian')
material.rarity = 80
material.value = 3000
material.color = Color(150,150,150,255)
material.maxStack = 99
material.forgeable = true
table.insert(manolis.popcorn.crafting.materials, material)

local material = {}
material.name = DarkRP.getPhrase('amber')
material.rarity = 75
material.value = 1000
material.color = Color(200,120,25,255)
material.maxStack = 99
material.forgeable = true
table.insert(manolis.popcorn.crafting.materials, material)

local material = {}
material.name = DarkRP.getPhrase('bloodstone')
material.rarity = 65
material.value = 2000
material.color = Color(50,50,50,255)
material.maxStack = 99
material.forgeable = true
table.insert(manolis.popcorn.crafting.materials, material)

local material = {}
material.name = DarkRP.getPhrase('zincite')
material.rarity = 45
material.value = 4000
material.color = Color(198,174,138,255)
material.maxStack = 99
material.forgeable = true
table.insert(manolis.popcorn.crafting.materials, material)

local material = {}
material.name = DarkRP.getPhrase('calcite')
material.rarity = 25
material.value = 7500
material.color = Color(100,225,80,255)
material.maxStack = 99
material.forgeable = true
table.insert(manolis.popcorn.crafting.materials, material)

local material = {}
material.name = DarkRP.getPhrase('azurite')
material.rarity = 15
material.value = 10000
material.color = Color(120,200,255,150)
material.maxStack = 99
material.forgeable = true
table.insert(manolis.popcorn.crafting.materials, material)

local material = {}
material.name = DarkRP.getPhrase('carbon_giga')
material.rarity = 3
material.value = 100000
material.color = Color(120,120,120,255)
material.maxStack = 1
table.insert(manolis.popcorn.crafting.materials, material)

local material = {}
material.name = DarkRP.getPhrase('rein_stone')
material.rarity = 0
material.value = 10000
material.color = Color(0,200,0,150)
material.maxStack = 99
table.insert(manolis.popcorn.crafting.materials, material)

manolis.popcorn.crafting.GetAllMaterials = function()
	return manolis.popcorn.crafting.materials
end

manolis.popcorn.crafting.FindMaterial = function(name)
	for k,v in pairs(manolis.popcorn.crafting.materials) do
		
		if(string.lower(v.name)==string.lower(name)) then return v end
	end
end

manolis.popcorn.crafting.FindBlueprint = function(name)
	for k,v in pairs(manolis.popcorn.crafting.blueprints) do
		if(string.lower(v.name)==string.lower(name)) then return v end
	end
end