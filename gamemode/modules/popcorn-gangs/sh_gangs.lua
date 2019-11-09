if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.gangs) then manolis.popcorn.gangs = {} end
if(!manolis.popcorn.gangs.shop) then manolis.popcorn.gangs.shop = {} end
if(!manolis.popcorn.gangs.cache) then manolis.popcorn.gangs.cache = {} end
if(!manolis.popcorn.gangs.logos) then manolis.popcorn.gangs.logos = {} end
if(!manolis.popcorn.gangs.shop.items) then manolis.popcorn.gangs.shop.items = {} end
if(!manolis.popcorn.gangs.upgrades) then manolis.popcorn.gangs.upgrades = {} end
if(!manolis.popcorn.gangs.upgrades.upgrades) then manolis.popcorn.gangs.upgrades.upgrades = {} end
if(!manolis.popcorn.gangs.territories) then manolis.popcorn.gangs.territories = {} end
if(!manolis.popcorn.gangs.territories.territoryLocations) then manolis.popcorn.gangs.territories.territoryLocations = {} end
if(!manolis.popcorn.gangs.territories.territories) then manolis.popcorn.gangs.territories.territories = {} end


manolis.popcorn.gangs.GetPlayerGang = function(ply)
	if(!IsValid(ply)) then
		return 0
	end
	return ply:getDarkRPVar('gang') or 0
end

manolis.popcorn.gangs.GetPlayerGangRank = function(ply)
	if(!IsValid(ply)) then
		return 0
	end
	return ply:getDarkRPVar('gangrank') or 0
end

manolis.popcorn.gangs.GetRank = function(rank)
	if(rank==1) then
		return DarkRP.getPhrase("leader")
	elseif(rank==2) then
		return DarkRP.getPhrase("coleader")
	elseif(rank==3) then
		return DarkRP.getPhrase("captain")
	elseif(rank==4) then
		return DarkRP.getPhrase("soldier")
	elseif(rank==5) then
		return DarkRP.getPhrase("recruit")
	end
end

manolis.popcorn.gangs.shop.AddItem = function(item)
	local n = {}
	for k,v in pairs(item) do
 		n[k] = v
	end
 

	n.name = item.name or "Unknown"
	n.level = item.level or 1 
	n.model = item.model or ''
	n.description = item.description or ''
	n.price = item.price or 100
	n.model = item.model or ''
	n.entity = item.entity or ''
	n.type = item.type or ''
	

	table.insert(manolis.popcorn.gangs.shop.items, n)
end

manolis.popcorn.gangs.AddLogo = function(logo)
	table.insert(manolis.popcorn.gangs.logos, logo)
end

manolis.popcorn.gangs.AddLogo('1')
manolis.popcorn.gangs.AddLogo('3')
manolis.popcorn.gangs.AddLogo('4')
manolis.popcorn.gangs.AddLogo('5')
manolis.popcorn.gangs.AddLogo('6')
manolis.popcorn.gangs.AddLogo('7')