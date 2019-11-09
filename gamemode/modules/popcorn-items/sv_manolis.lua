if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.initialItems) then manolis.popcorn.initialItems = {} end

manolis.popcorn.initialItems = {
	{id = '76561198050532576', items = {'Ring of Lua'}}
}

hook.Add('PlayerInitialSpawn', 'manolis:oneOffItems', function(ply)
	timer.Simple(1, function()
		for k,v in pairs(manolis.popcorn.initialItems) do
			if(v.id==ply:SteamID64()) then
				manolis.popcorn.don.HasGift(ply, util.CRC(ply:SteamID64()), function(a)
					if(!a) then
						for k,v in pairs(v.items) do
							local item = manolis.popcorn.items.FindItem(v)
							if(item) then 
								local data = manolis.popcorn.items.CreateItemData(item)
								if(data) then
									manolis.popcorn.don.AddAcceptedGift(ply,util.CRC(ply:SteamID64()), function()
										manolis.popcorn.inventory.addItem(ply, data)
									end)
								end
							end
						end
					end
				end)
			end
		end
	end)
end)