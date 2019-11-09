if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.crafting) then manolis.popcorn.crafting = {} end
if(!manolis.popcorn.crafting.refine) then manolis.popcorn.crafting.refine = {} end

local craftingFrame = nil
local lastOpen = 0

local toggleCrafting = function()
	if not (LocalPlayer():Alive()) then return end
	if(CurTime() < lastOpen+.5) then return end
	lastOpen = CurTime()

	if(manolis.popcorn.crafting.panel and manolis.popcorn.crafting.panel:IsVisible()) then
		return
	end


	
	craftingFrame = vgui.Create('ManolisFrame', nil)
	craftingFrame:SetRealSize(400+3,323+40+7+10+(75+5*2))
	craftingFrame:Center()
	craftingFrame:SetVisible(true)
	craftingFrame:SetBackgroundBlur(true)
	craftingFrame:SetText(DarkRP.getPhrase('blacksmith'))
	manolis.popcorn.inventory.open(craftingFrame)
	local page = vgui.Create('Panel', craftingFrame)
	page:SetPos(0,40+10+40+2+10+40)
	page:SetSize(403,320)
	page.slots = {}

	local slots = vgui.Create("ManolisSlots", page, 'blacksmith')
	slots:SetPos(0,0)
	slots:SetSlots(5,4)

	local craftingDrop = function(self, t, previousParent)
		if(previousParent:GetParent() and ( previousParent:GetParent():GetName()=='mainInventory' or previousParent:GetParent():GetName()=='blacksmith')) then		
			if(t.type=='material') then
				return true
			end
		end
	end

	for k,v in pairs(slots.slot) do
		v.DroppedInto = craftingDrop
	end

	local bpSlot = vgui.Create("ManolisSlot", craftingFrame, 'blacksmithBlueprint')
	bpSlot:SetPos(10, 40+10+(((40*2)/2)-(72/2)))
	bpSlot.DroppedInto = function(self,t,previousParent)
		if(previousParent:GetParent() and ( previousParent:GetParent():GetName()=='mainInventory')) then		
			if(t.type=='blueprint') then
				return true
			end
		end			
	end

	local cancelButton = vgui.Create("ManolisButton", craftingFrame)
	cancelButton:SetPos(403-101-10, 40+10+40+5)
	cancelButton:SetText(DarkRP.getPhrase('cancel'))
	cancelButton.DoClick = function()
		craftingFrame:Remove()
		slots:RemoveAllItems()
		if(bpSlot.item) then
			bpSlot.item:Remove()
			bpSlot.item = nil
		end
		if(manolis.popcorn.inventory and manolis.popcorn.inventory.panel) then
			manolis.popcorn.inventory.panel.refresh()
		end

		craftingFrame = nil

		manolis.popcorn.enableClicker(false)
	end

	local craftButton = vgui.Create("ManolisButton", craftingFrame)		
	craftButton:SetPos(403-101-10, 40+10)	
	craftButton:SetText(DarkRP.getPhrase('craft_item'))
	craftButton.DoClick = function()
		if(bpSlot.item) then
			local items = {}
			for k,v in pairs(slots.slot) do
				if(v.item) then
					table.insert(items, v.item.t.id)
				end
			end

			net.Start("ManolisPopcornCraftItem")
				net.WriteInt(bpSlot.item.t.id, 32)
				net.WriteTable(items)
			net.SendToServer()

			cancelButton.DoClick()
		end
	end

	page:SetVisible(true)
	craftingFrame.slots = slots

	manolis.popcorn.enableClicker(true)
	craftingFrame.header.closeButton:Remove()
	manolis.popcorn.crafting.panel = craftingFrame
end

local toggleRefine = function()
	if not (LocalPlayer():Alive()) then return end
	if(CurTime() < lastOpen+.5) then return end
	lastOpen = CurTime()

	if(manolis.popcorn.crafting.refine and manolis.popcorn.crafting.refine.panel and manolis.popcorn.crafting.refine.panel:IsVisible()) then
		return
	end

	if(refineFrame and refineFrame:IsVisible()) then return end
	if(refineFrame and !refineFrame:IsVisible()) then refineFrame:Remove() refineFrame = nil end


	
	local refineFrame = vgui.Create('ManolisFrame', nil)
	refineFrame:SetRealSize(347,120+3)
	refineFrame:Center()
	refineFrame:SetVisible(true)
	refineFrame:SetBackgroundBlur(true)
	manolis.popcorn.inventory.open(refineFrame)

	refineFrame:SetText(DarkRP.getPhrase('refiner'))

	local page = vgui.Create('Panel', refineFrame)
	page:SetPos(0,40)
	page:SetSize(80*3,80)
	page.slots = {}

	local slots = vgui.Create("ManolisSlots", page, 'refine')
	slots:SetPos(0,0)
	slots:SetSlots(3,1)

	local craftingDrop = function(self, t, previousParent)
		if(previousParent:GetParent() and ( previousParent:GetParent():GetName()=='mainInventory' or previousParent:GetParent():GetName()=='refine')) then		
			if(t.type=='upgrade') then
				return true
			end
		end
	end

	for k,v in pairs(slots.slot) do
		v.DroppedInto = craftingDrop
	end

	local cancelButton = vgui.Create("ManolisButton", refineFrame)
	cancelButton:SetPos(3+(80*3), 40+3+37+3)
	cancelButton:SetText(DarkRP.getPhrase('cancel'))
	cancelButton:SetSize(101,37)
	cancelButton.DoClick = function()
		slots:RemoveAllItems()
		if(manolis.popcorn.inventory.panel) then
			manolis.popcorn.inventory.panel.refresh()
		end
		refineFrame:Remove()
		refineFrame = nil
		manolis.popcorn.enableClicker(false)
	end

	local craftButton = vgui.Create("ManolisButton", refineFrame)
	craftButton:SetSize(101,37)
		
	craftButton:SetPos(3+(80*3), 40+3)	
	craftButton:SetText(DarkRP.getPhrase('refine_item'))
	craftButton.DoClick = function()
		local items = {}
		for k,v in pairs(slots.slot) do
			if(v.item) then
				table.insert(items, v.item.t.id)
			end
		end

		net.Start("ManolisPopcornRefineUpgrades")
			net.WriteTable(items)
		net.SendToServer()
		cancelButton.DoClick()
	end

	page:SetVisible(true)
	refineFrame.slots = slots

	manolis.popcorn.enableClicker(true)
	refineFrame.header.closeButton:Remove()
	manolis.popcorn.crafting.refine.panel = refineFrame
end

net.Receive("ManolisPopcornBlacksmithOpen", function(len)
	toggleCrafting()
end)

net.Receive("ManolisPopcornRefineOpen", function(len)
	toggleRefine()
end)

manolis.popcorn.crafting.refine.toggle = toggleRefine
manolis.popcorn.crafting.toggle = toggleCrafting