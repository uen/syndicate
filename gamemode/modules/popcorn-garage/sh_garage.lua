if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.garage) then manolis.popcorn.garage = {} end
if(!manolis.popcorn.garage.cars) then manolis.popcorn.garage.cars = {} end

manolis.popcorn.garage.CreateCar = function(a)
	local n = {}
	n.name = a.name
	n.ent = a.ent
	n.price = a.price
	n.model = a.model or ""
	n.canBuy = a.canBuy or true
	n.level = a.level or 1
	n.materials = a.materials or {}

	local newMaterials = {}
	for k,v in pairs(n.materials) do
		if(DarkRP.getPhrase(k)) then
			newMaterials[DarkRP.getPhrase(k)] = v
		end
	end

	if(manolis.popcorn.items.NewBlueprint) then
		manolis.popcorn.items.NewBlueprint(n.name, "car", n.materials, 1000, 25,true)
	end
	table.insert(manolis.popcorn.garage.cars, n)
end

manolis.popcorn.garage.Find = function(name)
	for k,v in pairs(manolis.popcorn.garage.cars) do
		if(string.lower(v.name) == string.lower(name)) then
			return v
		end
	end
end