if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.weapons) then manolis.popcorn.weapons = {} end


manolis.popcorn.weapons.CreateWeaponData = function(ply, data, giga)
	local luck = ply:GetLuck()
	if(giga) then luck = luck + manolis.popcorn.config.gigaLuck end

	local data = {}
	data.level = 1 + math.Round(math.random(0,10) * luck)
	data.class = {name=DarkRP.getPhrase("standard"),chance=100, slots=0}

	local classes = {
		{name=DarkRP.getPhrase('epic'), chance = 0.99, slots = 8},
		{name=DarkRP.getPhrase('elite'), chance = 0.95, slots = 6},
		{name=DarkRP.getPhrase('unique'), chance= 0.60, slots = 4},
		{name=DarkRP.getPhrase('rare'), chance=0.30, slots = 2},
		{name=DarkRP.getPhrase('uncommon'), chance=0.1, slots = 1}
	}

	local random = math.random()

	local foundClass = false 
	for k,v in pairs(classes) do
		if(foundClass) then continue end
	
		if((random*(luck))>v.chance) then
			data.class = v
			foundClass = true
		end
	end

	data.slots = math.random()>0.5 and 2 or math.random()>0.5 and 1 or 0 
	data.slots = math.Clamp(data.slots + data.class.slots, 0, 8)
	data.type = 'weapon'
	data.upgrades = {}

	data.crafted = ply:Name()

	data.class = data.class.name

	return data
end