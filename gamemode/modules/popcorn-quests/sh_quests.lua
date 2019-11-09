if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.quests) then manolis.popcorn.quests = {} end
if(!manolis.popcorn.quests.quests) then manolis.popcorn.quests.quests = {} end
if(!manolis.popcorn.quests.deals) then manolis.popcorn.quests.deals = {} end
if(!manolis.popcorn.quests.deals.deals) then manolis.popcorn.quests.deals.deals = {} end

manolis.popcorn.quests.NewQuest = function(quest)
	table.insert(manolis.popcorn.quests.quests,quest)
end

manolis.popcorn.quests.RandomQuest = function()
	return manolis.popcorn.quests.quests[math.random(#manolis.popcorn.quests.quests)]
end

manolis.popcorn.quests.GetQuestByUiq = function(uiq)
	for k,v in pairs(manolis.popcorn.quests.quests) do
		if(v.uiq==uiq) then return v end
	end
end

manolis.popcorn.quests.GetQuestXP = function(ply)
	return math.floor(manolis.popcorn.quests.GetQuestCost(ply)/20)
end

manolis.popcorn.quests.GetQuestCost = function(ply)
	return math.floor(2500+((ply:getDarkRPVar('level') or 1)^2.5))
end

manolis.popcorn.quests.NPCKeys = {wendy = 'Wendy', bob='Bob', michael='Michael Sterling', simon = 'Simon Escobar', turkish = 'Turkish'}
manolis.popcorn.quests.GetNPCName = function(npc)
	return manolis.popcorn.quests.NPCKeys[npc] or 'Unknown'
end

manolis.popcorn.quests.deals.AddDeal = function(npc,deal)
	if(!manolis.popcorn.quests.deals.deals[npc]) then manolis.popcorn.quests.deals.deals[npc] = {} end
	table.insert(manolis.popcorn.quests.deals.deals[npc], deal)
end

manolis.popcorn.quests.deals.GetDealByUiq = function(uiq)
	for k,v in pairs(manolis.popcorn.quests.deals.deals) do
		for a,b in pairs(v) do
			if(b.uiq==uiq) then
				return b
			end
		end
	end
end

manolis.popcorn.quests.deals.AddDeal('michael',{
	name = '1x Carbon Giga Crystal',
	uiq = 'michaelgigas',
	price = 1000000,
	icon = 'manolis/popcorn/icons/materials/carbon-giga.png'
})
