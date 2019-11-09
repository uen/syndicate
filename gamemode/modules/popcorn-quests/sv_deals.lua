if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.quests) then manolis.popcorn.quests = {} end
if(!manolis.popcorn.quests.deals) then manolis.popcorn.quests.deals = {} end
if(!manolis.popcorn.quests.deals.funcs) then manolis.popcorn.quests.deals.funcs = {} end
if(!manolis.popcorn.quests.deals.deals) then manolis.popcorn.quests.deals.deals = {} end

manolis.popcorn.quests.deals.funcs['michaelgigas'] = function(ply)
	local giga = manolis.popcorn.crafting.FindMaterial(DarkRP.getPhrase('carbon_giga'))
	if(giga) then
		local data = manolis.popcorn.crafting.CreateMaterialData(giga)
		manolis.popcorn.inventory.addItem(ply,manolis.popcorn.items.CreateItemData(data), function()
			ply:RefreshInventory()
		end)

	end
end