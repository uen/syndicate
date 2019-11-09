if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.bank) then manolis.popcorn.bank = {} end
if(!manolis.popcorn.bank.items) then manolis.popcorn.bank.items = {} end

local bankFrame = nil
local lastOpen = 0
local refreshMat = Material('manolis/popcorn/refresh.png')
local function toggleBank()
	if not (LocalPlayer():Alive()) then return end
	if(CurTime() < lastOpen+.5) then return end
	lastOpen = CurTime()
	if(manolis.popcorn.bank.panel and manolis.popcorn.bank.panel:IsVisible()) then
		return
	end


	bankFrame = vgui.Create('ManolisFrame')
	bankFrame:SetRealSize((77+3)*6+3,(77+3)*6+40+3)
	bankFrame:Center()
	bankFrame:SetVisible(true)
	bankFrame:SetText("Storage")
	bankFrame:SetBackgroundBlur(true)
	manolis.popcorn.inventory.open(bankFrame)

	local refreshButton = vgui.Create("Button", bankFrame)
	refreshButton:SetPos(0,48-(10*3.5)-2)
	refreshButton:SetSize(20,20)
	refreshButton:MoveRightOf(manolis.popcorn.inventory.panel.header.title, 	5)
	
	refreshButton.Paint = function(self,w,h)
		return
	end
	refreshButton:SetText("")
	
	refreshButton.DoClick = function()
		RunConsoleCommand("refreshManolisPopcornBank")
	end	
	local rIcon = vgui.Create("DImage", refreshButton)
	rIcon:SetMaterial(refreshMat)
	rIcon:SetSize(20,20)

	manolis.popcorn.enableClicker(true)
	
	local slots = vgui.Create("ManolisSlots", bankFrame, 'mainBank', bankFrame)
	slots:SetPos(0,40)
	slots:SetSlots(6,6)
	slots.page = bankFrame

	local inventoryDrop = function(self,t,previousParent)
		if(previousParent:GetParent() and previousParent:GetParent():GetName()=='mainInventory') then
			RunConsoleCommand("ManolisPopcornMoveItemToBank", t.id, self.pos)
			return true
		end

		if(previousParent:GetParent() and previousParent:GetParent():GetName()=='mainBank') then
			RunConsoleCommand("ManolisPopcornChangeBankItemSlot", t.id, self.pos)
			return true
		end
	end

	for k,v in pairs(slots.slot) do
		v.page = 1
		v.DroppedInto = inventoryDrop
	end

	bankFrame.refresh = function()
		local addedItems = {}
		slots:RemoveAllItems()
		for k,v in pairs(manolis.popcorn.bank.items) do
			if(!addedItems[v.id]) then
				addedItems[v.id] = true
				slots:AddInventoryItemToSlot(v)
			end
		end
	end

	bankFrame.header.closeButton.DoClick = function()
		bankFrame:SetVisible(false)
		manolis.popcorn.enableClicker(false)
	end
			
	manolis.popcorn.bank.panel = bankFrame
	bankFrame.refresh()
end

net.Receive("ManolisPopcornBankOpen", function(len)
	toggleBank()
end)

net.Receive('manolisPopcornBankFullRefresh', function()
	local items = net.ReadTable()
	manolis.popcorn.bank.items = items
	if(manolis.popcorn.bank.panel) then
		manolis.popcorn.bank.panel.refresh()
	end
end)

manolis.popcorn.bank.toggle = toggleBank