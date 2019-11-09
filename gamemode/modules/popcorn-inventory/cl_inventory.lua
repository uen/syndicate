if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.inventory) then manolis.popcorn.inventory = {} end
if(!manolis.popcorn.inventory.itemDrops) then manolis.popcorn.inventory.itemDrops = {} end
if(!manolis.popcorn.inventory.selectedItem) then manolis.popcorn.inventory.selectedItem = {} end
if(!manolis.popcorn.inventory.itemInfoShow) then manolis.popcorn.inventory.itemInfoShow = {} end

local inventoryFrame = nil


manolis.popcorn.inventory.GetClassColor = function(class)
	local classes = {
		{name=DarkRP.getPhrase('epic'), color=Color(255,255,255)},
		{name=DarkRP.getPhrase('elite'), color=Color(175,175,175)},
		{name=DarkRP.getPhrase('unique'), color=Color(200,0,150)},
		{name=DarkRP.getPhrase('rare'), color=Color(255,220,0)},
		{name=DarkRP.getPhrase('uncommon'), color=Color(200,0,0)},
		{name=DarkRP.getPhrase('standard'), color=Color(0,255,0)}
	}

	for k,v in pairs(classes) do
		if(v.name==class) then
			return v.color
		end
	end
end

manolis.popcorn.inventory.AddItemDrop = function(item, frame)
	item.GetParentZPos = (frame and frame.GetZPos) or function() return 1 end
	table.insert(manolis.popcorn.inventory.itemDrops, item)
end

local lastOpen = 0
local refreshMat = Material('manolis/popcorn/refresh.png')
local toggleInventory = function(hide)
	if not (LocalPlayer():Alive()) then return end
	if(CurTime() < lastOpen+.25) then return end
	lastOpen = CurTime()

	if ((not inventoryFrame) or (not IsValid(inventoryFrame))) then
		inventoryFrame = vgui.Create('ManolisFrame')
		inventoryFrame:SetRealSize(403,443)
		inventoryFrame:Center()
		inventoryFrame:SetBackgroundBlur(true)
		inventoryFrame:SetVisible(true)

		inventoryFrame:SetText(DarkRP.getPhrase('inventory'))

		local refreshButton = vgui.Create("Button", inventoryFrame)
		refreshButton:SetPos(0,48-(10*3.5)-2)
		refreshButton:SetSize(20,20)
		refreshButton:MoveRightOf(inventoryFrame.header.title, 	5)
		
		refreshButton.Paint = function(self,w,h)
			return
		end

		refreshButton:SetText("")
		
		refreshButton.DoClick = function()
			RunConsoleCommand("manolisRefreshInventory")
		end	

		local rIcon = vgui.Create("DImage", refreshButton)
		rIcon:SetMaterial(refreshMat)
		rIcon:SetSize(20,20)

		local currentPage = 1

		local pages = {}
		for p=1, 4 do
			local page = vgui.Create('Panel', inventoryFrame)
			page:SetPos(0,80)
			page:SetSize(403,323)
			page.idF = p
			page.slots = {}

			local button = vgui.Create("ManolisPageButton", inventoryFrame)
			button:SetPos((p*101)-101, 40)
			button:SetText(DarkRP.getPhrase('inventory_page', p))

			button.DroppedInto = function(self, item, previousParent)
				if(previousParent:GetParent() and previousParent:GetParent():GetName()=='mainInventory') then
					if(item.page!=p) then
						if(item.id) then
							RunConsoleCommand('ManolisPopcornChangeInventoryPage', item.id, p)
							return 1
						end
					else
						return false	
					end
				end
			end

			button.pageNumber = p

			button.DoClick = function()
				for k,v in pairs(pages) do
					if(v==page) then
						v:SetVisible(true)
						currentPage = k
						button.depressed = true
					else
						v.button.depressed = false
						v:SetVisible(false)
					end
				end
			end

			page.button = button
			manolis.popcorn.inventory.AddItemDrop(button, inventoryFrame)

			local slots = vgui.Create("ManolisSlots", page, 'mainInventory')
			slots:SetPos(0,0)
			slots:SetSlots(5,4)
			slots.page = page
			
			local inventoryDrop = function(self, t, previousParent)
				if(previousParent:GetParent() and previousParent:GetParent():GetName()=='mainInventory') then
					if(!manolis.popcorn.keys[IN_SPEED]) then
						RunConsoleCommand("ManolisPopcornChangeItemSlot", t.id, self.pos)
					end
					return true
				end

				if(previousParent:GetParent() and previousParent:GetParent():GetName()=='mainTrade') then
					net.Start("ManolisPopcornRemoveItemFromTrade")
						net.WriteInt(t.id,32)
					net.SendToServer()
					return true
				end

				if(previousParent:GetParent() and previousParent:GetParent():GetName()=='mainEquipment') then
					RunConsoleCommand("ManolisPopcornDequipItem", t.id, self:GetParent().page.idF, self.pos)
					return true
				end

				if(previousParent:GetParent() and previousParent:GetParent():GetName()=='mainBank') then
					RunConsoleCommand("ManolisPopcornMoveItemToInventoryFromBank", t.id, self:GetParent().page.idF, self.pos)
					return true
				end

				if(previousParent:GetParent() and previousParent:GetParent():GetName()=='creditShop') then
					RunConsoleCommand('ManolisPopcornCreditShopTransferToInventory', t.id, self:GetParent().page.idF, self.pos)
					return true
				end
			end

			for k,v in pairs(slots.slot) do
				v.DroppedInto = inventoryDrop
			end

			slots:SetSelectCallback(function(item)
				manolis.popcorn.inventory.selectedItem = item.item
			end)

			page.slots = slots
			page:SetVisible(false)

			table.insert(pages, page)
		end

		pages[1]:SetVisible(true)
		pages[1].button.depressed = true
		pages[1].slots.slot[1].item = item

		local dropButton = vgui.Create("ManolisButton", inventoryFrame)
		dropButton:SetVisible(true)
		dropButton:SetSize(101,40)
		dropButton:SetText(DarkRP.getPhrase('drop_inventory'))
		dropButton:SetPos(0*101,403)

		dropButton.DoClick = function()
			if(manolis.popcorn.inventory.selectedItem) then
				if(manolis.popcorn.inventory.selectedItem.t) then
					RunConsoleCommand('ManolisPopcornDropItem', manolis.popcorn.inventory.selectedItem.t.id)
				end
			end
		end

		local useButton = vgui.Create("ManolisButton", inventoryFrame)
		useButton:SetVisible(true)
		useButton:SetSize(101,40)
		useButton:SetText(DarkRP.getPhrase('use_inventory'))
		useButton:SetPos(1*101,403)

		useButton.DoClick = function()
			if(manolis.popcorn.inventory.selectedItem) then
				RunConsoleCommand('ManolisPopcornUseItem', manolis.popcorn.inventory.selectedItem and manolis.popcorn.inventory.selectedItem.t and manolis.popcorn.inventory.selectedItem.t.id or 0)
			end
		end

		local equipButton = vgui.Create("ManolisButton", inventoryFrame)
		equipButton:SetVisible(true)
		equipButton:SetSize(101,40)
		equipButton:SetText(DarkRP.getPhrase('equip_inventory'))
		equipButton:SetPos(2*101,403)

		equipButton.DoClick = function()
			if(manolis.popcorn.inventory.selectedItem and manolis.popcorn.inventory.selectedItem.Selected) then
				if(manolis.popcorn.inventory.selectedItem.t.type=='primary' or manolis.popcorn.inventory.selectedItem.t.type=='side') then
					RunConsoleCommand('ManolisPopcornEquipItemAlt', manolis.popcorn.inventory.selectedItem.t.id)
					pages[currentPage].slots:RemoveLocalItem(manolis.popcorn.inventory.selectedItem.t.id)
					manolis.popcorn.inventory.selectedItem = nil
				end
			end
		end

		local sellButton = vgui.Create("ManolisButton", inventoryFrame)
		sellButton:SetVisible(true)
		sellButton:SetSize(101,40)
		sellButton:SetText(DarkRP.getPhrase('sell_inventory'))
		sellButton:SetPos(3*101,403)
		sellButton.DoClick = function()
			if(manolis.popcorn.inventory.selectedItem and manolis.popcorn.inventory.selectedItem.Selected) then
				local item = manolis.popcorn.inventory.selectedItem.t
				Manolis_Query(DarkRP.getPhrase('sell_confirm_inventory',((item.quantity or 1)>1 and item.quantity..'x ' or '') ..item.name,DarkRP.formatMoney(math.floor(((item.value or 0)/100)*(item.quantity or 1)))), DarkRP.getPhrase('sell_do'), DarkRP.getPhrase('sell_cancel'), function() end, DarkRP.getPhrase('sell_sell'), function() 
					RunConsoleCommand("ManolisPopcornSellItem", item.id)
					pages[currentPage].slots:RemoveLocalItem(item.id)
					manolis.popcorn.inventory.selectedItem = nil
				end)
			end
		end

		inventoryFrame.pageButtons = pageButtons
		inventoryFrame.slots = slots

		inventoryFrame.refresh = function(page)
			if(!page) then
				for k,v in pairs(pages) do
					v.slots:RemoveAllItems()
				end
			else
				for k,v in pairs(pages) do
					if(v.idF==page) then
						v.slots:RemoveAllItems()	
					end 
				end
			end


			local addedItems = {}
			for k,v in pairs(manolis.popcorn.inventory.items) do
				if(!v) then continue end

				if(!tonumber(v.page)) or (!tonumber(v.slot)) then continue end

				if((page and (tonumber(v.page)==tonumber(page))) or (!page)) then
	
					if(tonumber(v.slot)>0) then 
		
						v.page = tonumber(v.page)
						v.slot = tonumber(v.slot)

						if(pages[v.page]) then
			
							for ka,va in pairs(addedItems) do
								if(va.id==v.id) then
									continue
								end
							end
						
							if(pages[v.page].slots:AddInventoryItemToSlot(v)) then
								table.insert(addedItems, v)
							end
						end
					end
				end
			

			end
		end

		inventoryFrame.header.closeButton.DoClick = function()
			inventoryFrame:SetVisible(false)
			manolis.popcorn.enableClicker(false)
		end

		

		manolis.popcorn.inventory.panel = inventoryFrame
		inventoryFrame.refresh()

		if(hide) then
			inventoryFrame:SetVisible(false)
		else
			manolis.popcorn.enableClicker(true)
		end

	elseif(inventoryFrame:IsVisible()) then
		inventoryFrame:SetVisible(false)
		manolis.popcorn.enableClicker(false)
	else
		inventoryFrame:SetVisible(true)
		manolis.popcorn.enableClicker(true)
	end
end
concommand.Add("inventory", toggleInventory)
manolis.popcorn.inventory.toggle = toggleInventory

manolis.popcorn.inventory.open = function(otherFrame)
	if(inventoryFrame) then	inventoryFrame:SetVisible(false) end
	manolis.popcorn.inventory.toggle()
	manolis.popcorn.inventory.panel:SetPos(ScrW()/2 - (manolis.popcorn.inventory.panel:GetWide())-20, ScrH()/2 - (manolis.popcorn.inventory.panel:GetTall()/2))
	otherFrame:SetPos(ScrW()/2+20, ScrH()/2 - (otherFrame:GetTall()/2))
end

manolis.popcorn.inventory.close = function(otherFrame)
	if(inventoryFrame) then inventoryFrame:SetVisible(false) end
	if(IsValid(otherFrame)) then otherFrame:SetVisible(false) end
end