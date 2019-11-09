if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.quests) then manolis.popcorn.quests = {} end
if(!manolis.popcorn.quests.quests) then manolis.popcorn.quests.quests = {} end
if(!manolis.popcorn.quests.npcs) then manolis.popcorn.quests.npcs = {} end
if(!manolis.popcorn.quests.deals) then manolis.popcorn.quests.deals = {} end
if(!manolis.popcorn.quests.deals.funcs) then manolis.popcorn.quests.deals.funcs = {} end
if(!manolis.popcorn.quests.deals.deals) then manolis.popcorn.quests.deals.deals = {} end

local base = 'syndicate/gamemode/quests/'
for k,v in pairs(file.Find(base.."*.lua", "LUA")) do
	include(base..v)
	AddCSLuaFile(base..v)
end


manolis.popcorn.quests.prepareNPCQuests = function(npc)
	local npc = manolis.popcorn.quests.FindNPC(npc)
	if(npc) then
		local quests = {}
		for k,v in pairs(npc:GetQuests()) do
			table.insert(quests,v.uiq)
		end
		return quests
	end
end


concommand.Add("ManolisPopcornAcceptDeal", function(ply,cmd,args)
	if(ply.quest) then return end
	if(!args[1]) then return end

	local found
	for k,v in pairs(manolis.popcorn.quests.deals.deals) do
		if(found) then continue end
		for k,v in pairs(v) do
			if(v.uiq == args[1]) then found = v end
		end
	end

	if(found) then
		if(ply:canAfford(found.price)) then
			if(manolis.popcorn.quests.deals.funcs[found.uiq]) then
				DarkRP.notify(ply,0,4,'You made a deal for '..found.name..' for ',DarkRP.formatMoney(found.price))
				manolis.popcorn.quests.deals.funcs[found.uiq](ply)
				ply:addMoney(-found.price)
			end
		else
			DarkRP.notify(ply,1,4,'You cannot afford this')
		end
	end
end)

concommand.Add("ManolisPopcornAcceptQuest",function(ply,cmd,args)
	if(ply.quest) then return end
	if(!args[1]) then return end

	if(ply:getDarkRPVar('PopcornGhost')) then
		DarkRP.notify(ply, 0,4,'You cannot do a quest when you are a ghost')
		return
	end

	local found
	for k,v in pairs(manolis.popcorn.quests.quests) do
		if(found) then continue end
		if(v.uiq == args[1]) then
			found = v
		end
	end

	if(found) then
		local npc = manolis.popcorn.quests.npcs[found.npc]
		if(!npc) then
			DarkRP.notify('Quest NPCs have not been setup. Notify an admin')
			return
		end

		if(!((ply:GetPos():Distance(npc:GetPos()))<250)) then return end
		local quest = npc:HasQuest(found)
		if(quest) then
			local cost = manolis.popcorn.quests.GetQuestCost(ply)
			if(!ply:canAfford(cost)) then 
				DarkRP.notify(ply,1,4,'You cannot afford this quest')
				return 
			end

			quest.reward = cost


			npc:StartQuest(ply,quest)
		else
			DarkRP.notify(ply,1,4,'Somebody has already accepted this quest')
		end
	end
end)

timer.Create("Manolis:QuestTimer", manolis.popcorn.config.questTime, 0, function()
	if(table.Count(player.GetAll())<manolis.popcorn.config.questPlayers) then return end

	for i=1,100 do
		local quest = manolis.popcorn.quests.RandomQuest()
		if(quest) then
			if(manolis.popcorn.quests.npcs[quest.npc]) then
				if(manolis.popcorn.quests.npcs[quest.npc]:HasQuest(quest)) then continue end
				local copy = table.Copy(quest)
				table.insert(manolis.popcorn.quests.npcs[copy.npc].manolisQuests, copy)
				manolis.popcorn.quests.npcs[copy.npc]:SethasQuests(1)
				return
			end
		end
	end
end)

hook.Add("PositionEntitiesSpawned", "manolis:quest:initNpcs", function()
	for k,v in pairs(ents.GetAll()) do
		if(v.isManolisNPC) then
			manolis.popcorn.quests.npcs[v.manolisNPC] = v
		end
	end
end)

local lastCheck = 0
hook.Add('Think', 'manolis:DialogueAwayFail', function()
	if(lastCheck<CurTime()-1) then
		lastCheck = CurTime()
		for k,v in pairs(player.GetAll()) do
			if(v.isInDialogue) then
				if(manolis.popcorn.quests.DialogueCache[v]) then
					local npc = manolis.popcorn.quests.npcs[manolis.popcorn.quests.DialogueCache[v].npc]
					if(v:GetPos():Distance(npc:GetPos())>250) then
						manolis.popcorn.quests.CompleteQuest(v,true,true)

						net.Start('ManolisPopcornNextDialogue')
							net.WriteString('')
						net.Send(v)

						manolis.popcorn.quests.DialogueCache[v] = nil
						v.isInDialogue = false


						DarkRP.notify(v,1,4,'You have failed the quest and lost your deposit as you walked too far away from the the quest npc')
					end
				end
			end
		end
	end
end)

manolis.popcorn.quests.FindNPC = function(key)
	return manolis.popcorn.quests.npcs[key]
end

manolis.popcorn.quests.CompleteQuest = function(ply,fail, supress)
	if(ply.quest) then
		manolis.popcorn.quests.DialogueCache[ply] = nil

		if(!fail) then
			if(math.random(1,5)<=3) then
				
				local bp = manolis.popcorn.crafting.PlayerRandomBlueprint(ply)
				if(bp) then
					local item = manolis.popcorn.items.CreateItemData(bp)
					DarkRP.notify(ply,0,4,'You got a '..item.name)
					manolis.popcorn.inventory.addItem(ply, item, function()
						ply:RefreshInventory()
					end)
				end
			else
				local amount = math.random(1,5)

				local mat = manolis.popcorn.crafting.FindMaterial(DarkRP.getPhrase('rein_stone'))
				if(mat) then
					mat.quantity = amount
					local mat = manolis.popcorn.crafting.CreateMaterialData(mat)
					mat.quantity = amount
					manolis.popcorn.inventory.addItem(ply,mat, function()
						ply:RefreshInventory()
					end)
				end
				DarkRP.notify(ply,0,4,'You got '..amount..' reinforcement stones')
			end

			ply:addMoney(ply.quest.reward)
			local xp = manolis.popcorn.quests.GetQuestXP(ply)
			ply:addXP(xp,true)

			DarkRP.notify(ply,0,4,'You received '..DarkRP.formatMoney(ply.quest.reward)..' and '..xp..'XP from this mission')
		else
			if(!supress) then
				DarkRP.notify(ply,0,4,'You have failed the quest and have lost your deposit')
			end
		end
		ply.quest = nil
	end
end


manolis.popcorn.quests.deals.getDeals = function(npc)
	local uiqs = {}
	for k,v in pairs(manolis.popcorn.quests.deals.deals[npc] or {}) do
		table.insert(uiqs,v.uiq)
	end

	return uiqs
end

manolis.popcorn.quests.DialogueCache = {}
manolis.popcorn.quests.NextDialogue = function(ply)
	if(manolis.popcorn.quests.DialogueCache[ply]) then
		local v = manolis.popcorn.quests.DialogueCache[ply]
		manolis.popcorn.quests.SendDialogue(ply,v.npc,v.dialogue,v.callback)
	end
end

manolis.popcorn.quests.HasDialogue = function(ply)
	if(ply.isInDialogue) then return true end
	return false
end

manolis.popcorn.quests.SendDialogue = function(ply,npc,dialogue,callback)
	if(ply.isInDialogue) then
		ply.isInDialogue = ply.isInDialogue+1

		if(!dialogue[ply.isInDialogue]) then 
			ply.isInDialogue = false
			if(callback) then
				callback()
			end 
		end

		net.Start('ManolisPopcornNextDialogue')
			net.WriteString(dialogue[ply.isInDialogue] or '')
		net.Send(ply)
	else
		net.Start('ManolisPopcornStartDialogue')
			net.WriteString(npc)
			net.WriteString(dialogue[1])
		net.Send(ply)

		manolis.popcorn.quests.DialogueCache[ply] = {npc = npc, dialogue = dialogue, callback = callback}

		ply.isInDialogue = 1

	end
end

manolis.popcorn.quests.SendRadioDialogue = function(ply,dialogue)
	if(!ply.isInDialogue) then
		net.Start('ManolisPopcornStartRadioDialogue')
			net.WriteTable(dialogue)
		net.Send(ply)
	end
end