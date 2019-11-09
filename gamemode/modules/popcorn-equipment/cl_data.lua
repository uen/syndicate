if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.equipment) then manolis.popcorn.equipment = {} end
if(!manolis.popcorn.equipment.items) then manolis.popcorn.equipment.items = {} end

net.Receive('manolisPopcornEquipmentFullRefresh', function()
	local items = net.ReadTable()
	//if(items!=manolis.popcorn.equipment.items) then
		manolis.popcorn.equipment.items = items
		if(manolis.popcorn.equipment.panel) then
			if(IsValid(manolis.popcorn.equipment.panel)) then manolis.popcorn.equipment.panel.refresh() end
		end
	//end
end)