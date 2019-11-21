if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.hud) then manolis.popcorn.hud = {} end

local itemSelect = false
manolis.popcorn.hud.OpenItemSelect = function(i)
	if(itemSelect and itemSelect:IsVisible()) then return false end
	if(itemSelect) then itemSelect:Remove() end

	itemSelect = vgui.Create("ManolisFrame")
	itemSelect:SetRealSize(650, 500)
	itemSelect:Center()
	itemSelect:SetText(DarkRP.getPhrase("select_an_item"))
	itemSelect:SetBackgroundBlur( true )
	itemSelect:SetBackgroundBlurOverride( true )
	itemSelect:MakePopup()


	local scrollPanel = vgui.Create("ManolisScrollPanel", itemSelect)
	scrollPanel:SetSize(650-10, 500-50)
	scrollPanel:SetPos(5,45)

	local categories = DarkRP.getCategories().entities
	local shCategories = DarkRP.getCategories().shipments
 	
 	table.sort(categories, function(a,b) return (a.sortOrder or 0) < (b.sortOrder or 0) end)
 	table.sort(shCategories, function(a,b) return (a.sortOrder or 0) < (b.sortOrder or 0) end)
 

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
 			catLabel.expandButton:Remove()
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

 							itemE:Go(item.modelViewColor or false, item.name, item.model or '', item.price, item.level or 1, item.cmd, function()
 								RunConsoleCommand("ManolisAddQuickBuy", item.model, i, item.cmd)
 								itemSelect:Remove()
 							end)
 							itemE.purchase:SetText(DarkRP.getPhrase("select_item"))
 							catItemList:Add(itemE)
 						end
 					end	
 				end

 				catItemList:SetPos(0,20)
 				category:Add(catItemList)
 
 			end
 		

 		scrollPanel:Add(category)
 		end

 	end

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
			catLabel.expandButton:Remove()
			
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
									RunConsoleCommand("ManolisAddQuickBuy", item.model, i, item.cmd)
									itemSelect:Remove()
								end, item.cmd)
								itemE.purchase:SetText(DarkRP.getPhrase("select_item"))
								catItemList:Add(itemE)
							end
						end	
					end
				
				catItemList:SetPos(0,20)
				category:Add(catItemList)
			end
			scrollPanel:Add(category)
		end
	end

	local ammo = vgui.Create("ManolisPanel")
	ammo:SetWide(650-25)
	ammo:SetPos(5,0)
	local catLabel = vgui.Create("ManolisCategory")
	catLabel:SetSize(650-25,35)
	catLabel:SetPos(0,0)
	catLabel.expandButton:Remove()
	
	catLabel:Go("Ammo")
	ammo:Add(catLabel)
	
	local catItemList = vgui.Create("ManolisPanel")
	catItemList:SetSize(0,0)
	catItemList:SetWide(650-25)
	catItemList:ClearPanel()
	catItemList:SetPos(0,20)
	
	for k,v in ipairs(GAMEMODE.AmmoTypes) do
		if((istable(v.allowed) and table.HasValue(v.allowed, LocalPlayer():Team())) or !istable(v.allowed)) then
			if((v.customCheck and v.customCheck(LocalPlayer())) or !v.customCheck) then
				local item = vgui.Create("ManolisShopPanel")
				item:Go(false,v.name, v.model or '', v.price, v.level or 1, true, function()
										RunConsoleCommand("ManolisAddQuickBuy", v.model, i, 'buyammo ' .. v.ammoType)
										itemSelect:Remove()
									end, "buyammo "..v.ammoType)
				item.purchase:SetText(DarkRP.getPhrase("select_item"))
	
				catItemList:Add(item)
			end		
		end		
	end
	
	
	ammo:Add(catItemList)
	
	scrollPanel:Add(ammo)

 end
