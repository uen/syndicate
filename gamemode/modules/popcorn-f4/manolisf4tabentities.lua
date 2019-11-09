AddCSLuaFile()
local PANEL = {}

function PANEL:Init()
	self:SetSize(650,535)
	self.Paint = function(panel,w,h)
		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(0,0,w,h)
	end

	local tabs = vgui.Create("ManolisTabs", self)
	tabs:SetPos(0,0)
	tabs:SetSize(650,535)

	local items = vgui.Create("Panel")
	items:SetSize(650,535-40-5)
	items:SetPos(0,0)

	local itemList = vgui.Create("ManolisScrollPanel", items)
	itemList:SetPos(5,5)
	itemList:SetSize(650-10, 535-40-5-5)

	local categories = DarkRP.getCategories().entities

	local refreshItems = function()
		itemList:ClearPanel()
		table.sort(categories, function(a,b) return (a.sortOrder or 0) < (b.sortOrder or 0) end)
		for k,v in pairs(categories) do
			if(#v.members<=0) then continue end
			if(v.canSee and !v:canSee()) then continue end 
			local c = false

			for k,item in pairs(v.members) do
				if((istable(item.allowed) and table.HasValue(item.allowed, LocalPlayer():Team())) or !istable(item.allowed)) then
					if((item.customCheck and item.customCheck(LocalPlayer())) or !item.customCheck) then
						if((item.canSee and item:canSee() or true)) then
							c = true
						end
					end
				end
			end

			if(!c) then continue end
			if(#v.members>0) then
			local category = vgui.Create("ManolisPanel", items)
				category:SetWide(650-25)
				category:SetPos(5,0)
				local catLabel = vgui.Create("ManolisCategory")

				catLabel:SetPos(0,0)

				catLabel:Go(v.name)
				category:Add(catLabel)
				if(#v.members>0) then
					local catItemList = vgui.Create("ManolisPanel")
					catItemList:SetSize(0,0)
					catItemList:SetWide(650-25)

						catItemList:ClearPanel()
						
					table.sort(v.members, function(a,b) return (a.level or 0) < (b.level or 0) end)
					for k,item in pairs(v.members) do
						if((istable(item.allowed) and table.HasValue(item.allowed, LocalPlayer():Team())) or !istable(item.allowed)) then
							if((item.customCheck and item.customCheck(LocalPlayer())) or !item.customCheck) then
								local itemE = vgui.Create("ManolisShopPanel")
								itemE:Go(item.modelViewColor or false, item.name, item.model or '', item.price, item.level or 1, item.cmd)
								catItemList:Add(itemE)
							end
						end	
					end
					
					catItemList:SetPos(0,20)
					category:Add(catItemList)
 
					catLabel.expandButton.DoClick = function()
						if(catLabel:GetTall()!=category:GetTall()) then
							category.previousHeight = category:GetTall()
							category:SetTall(catLabel:GetTall())
							itemList:Refresh()


						else
							category:SetTall(category.previousHeight)
							itemList:Refresh()
						end

						catLabel:ToggleButton()
					end
				end

				itemList:Add(category)

			end
		end
	end

	refreshItems()

	tabs:AddTab(DarkRP.getPhrase('items'), items)

	local shipments = vgui.Create("Panel")
	shipments:SetSize(650,535-40-5)
	shipments:SetPos(0,0)

	local shipmentList = vgui.Create("ManolisScrollPanel", shipments)
	shipmentList:SetPos(5,5)
	shipmentList:SetSize(650-10, 535-40-5-5) 


	local shCategories = DarkRP.getCategories().shipments
	local refreshShipments = function()
		shipmentList:ClearPanel()
		table.sort(shCategories, function(a,b) return (a.sortOrder or 0) < (b.sortOrder or 0) end)
		for k,v in pairs(shCategories) do
			
			if(#v.members<=0) then continue end
			if(v.canSee and !v:canSee()) then continue end 
			local c = false

			for k,item in pairs(v.members) do
				if((istable(item.allowed) and table.HasValue(item.allowed, LocalPlayer():Team())) or !istable(item.allowed)) then
					if((item.customCheck and item.customCheck(LocalPlayer())) or !item.customCheck) then
						if((item.canSee and item:canSee() or true)) then
							c = true
						end
					end
				end
			end

			if(!c) then continue end
			if(#v.members>0) then
				local category = vgui.Create("ManolisPanel")
				category:SetWide(650-25)
				category:SetPos(5,0) 
				local catLabel = vgui.Create("ManolisCategory")
				catLabel:SetSize(650-25,35)
				catLabel:SetPos(0,0)
				
				catLabel:Go(v.name)
				category:Add(catLabel)
				
				if(#v.members>0) then
					local catItemList = vgui.Create("ManolisPanel")
					catItemList:SetSize(0,0)
					catItemList:SetWide(650-25)

						catItemList:ClearPanel()
						 
						table.sort(v.members, function(a,b) return (a.level or 0) < (b.level or 0) end)
						for k,item in pairs(v.members) do
	
							if((istable(item.allowed) and table.HasValue(item.allowed, LocalPlayer():Team())) or !istable(item.allowed)) then
								if((item.customCheck and item.customCheck(LocalPlayer())) or !item.customCheck) then
									local itemE = vgui.Create("ManolisShopPanel") 
									itemE:Go(false,item.name, item.model or '', item.price, item.level or 1, true, function()
										RunConsoleCommand("DarkRP", "buyshipment", item.name)
									end, item.cmd)
									catItemList:Add(itemE)
								end
							end	
						end
					
					catItemList:SetPos(0,20)
					category:Add(catItemList)
				end
				shipmentList:Add(category)
			end
		end
	end 
	refreshShipments()

	tabs:AddTab(DarkRP.getPhrase('shipments'), shipments)

	manolis.popcorn.f4.varCallbacks.add('job', function(new)
		refreshShipments()
		refreshItems()
	end)

	local ammo = vgui.Create("Panel")
	ammo:SetSize(650,535-40-5)
	ammo:SetPos(0,0)

	local ammoList = vgui.Create("ManolisScrollPanel", ammo)
	ammoList:SetPos(5,5)
	ammoList:SetSize(650-10,535-40-5-5)

	for k,v in ipairs(GAMEMODE.AmmoTypes) do
		if((istable(v.allowed) and table.HasValue(v.allowed, LocalPlayer():Team())) or !istable(v.allowed)) then
			if((v.customCheck and v.customCheck(LocalPlayer())) or !v.customCheck) then
				local item = vgui.Create("ManolisShopPanel")
		
				item:Go(false, v.name, v.model or '', v.price, v.level or 1, v.ammoType)
	
				item.purchase.DoClick = fn.Compose{fn.Partial(RunConsoleCommand, "DarkRP", "buyammo", v.ammoType)}
				ammoList:Add(item)
			end		
		end		
	end

	tabs:AddTab(DarkRP.getPhrase('ammo'), ammo)

	local updateItems = function(itemList,type,new)
		for a,category in pairs(itemList:GetItems()) do
			if(category.GetItems and category:GetItems()[2]) then
				if(category:GetItems()[2]) then
					for a,item in pairs(category:GetItems()[2]:GetItems()) do
						item:Update(type, new)
					end
				end
			end
		end
	end

	manolis.popcorn.f4.varCallbacks.add('money', function(new)
		updateItems(itemList,'money', new)
		updateItems(ammoList,'money', new)
		updateItems(shipmentList,'money', new)
	end)

	manolis.popcorn.f4.varCallbacks.add('level', function(new)
		updateItems(itemList,'level', new)
		updateItems(ammoList,'level', new)
		updateItems(shipmentList,'level', new)
	end)

	local cars = vgui.Create("Panel")
	cars:SetSize(650,535-40-5)
	cars:SetPos(0,0)

	local carList = vgui.Create("ManolisScrollPanel", cars)
	carList:SetPos(5,5)
	carList:SetSize(650-10,535-40-5-5)
	table.sort(manolis.popcorn.garage.cars, function(a,b) return (a.price or 0) < (b.price or 0) end)
	for k,v in ipairs(manolis.popcorn.garage.cars) do
		if(v.canBuy) then
			local item = vgui.Create("ManolisShopPanel")
			item:Go(false, v.name, v.model or '', v.price, v.level or 1, false, function()
				Manolis_Query(DarkRP.getPhrase('purchase_car_confirm',v.name), DarkRP.getPhrase('confirm'), DarkRP.getPhrase('purchase'), function()
					RunConsoleCommand("ManolisPopcornPurchaseVehicle", v.name)
					manolis.popcorn.f4.closeF4Menu()
				end, DarkRP.getPhrase('cancel'))
			end)

			carList:Add(item)
		end


	end

	tabs:AddTab(DarkRP.getPhrase('car_blueprints'), cars)

	manolis.popcorn.f4.refresh = function()
		refreshShipments()
		refreshItems()
	end

end
vgui.Register( "manolisF4TabEntities", PANEL, "DPanel" )