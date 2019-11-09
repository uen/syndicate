if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.inventory) then manolis.popcorn.inventory = {} end
if(!manolis.popcorn.inventory.itemDrops) then manolis.popcorn.inventory.itemDrops = {} end
if(!manolis.popcorn.inventory.selectedItem) then manolis.popcorn.inventory.selectedItem = {} end
if(!manolis.popcorn.inventory.items) then manolis.popcorn.inventory.items = {} end

local preCache = false
net.Receive('manolisPopcornInventoryFullRefresh', function(len)
	manolis.popcorn.inventory.items = {}
	local items = net.ReadTable()
	manolis.popcorn.inventory.items = items
	if(manolis.popcorn.inventory.panel) then
		manolis.popcorn.inventory.panel.refresh()
	end

	if(!preCache) then
		if(!inventoryFrame) then
			timer.Create("manolisPreloadInventory", 1,0,function()
				if(LocalPlayer() and LocalPlayer().Team) then
					manolis.popcorn.inventory.toggle(true)
					timer.Remove("manolisPreloadInventory")
				end
			end)
		end
		preCache = true
	end
end)

net.Receive('manolisPopcornInventoryPartialRefresh', function(len)
	local items = net.ReadTable()
	local page = net.ReadInt(32)
	if(!page or !items) then return end
	for k,v in pairs(manolis.popcorn.inventory.items) do
		if(v.page==page) then 
			manolis.popcorn.inventory.items[k] = nil
			continue
		end

		for ka,va in pairs(items) do
			if(v.id==va.id) then
				manolis.popcorn.inventory.items[k] = nil
			end
		end
	end



	for k,v in pairs(items) do
		table.insert(manolis.popcorn.inventory.items, v)
	end
	

	//table.sort(manolis.popcorn.inventory.items, function(a,b) if(a and b) then return a.slot < b.slot end end)
	if(manolis.popcorn.inventory.panel) then
		manolis.popcorn.inventory.panel.refresh(page)
	end
end)