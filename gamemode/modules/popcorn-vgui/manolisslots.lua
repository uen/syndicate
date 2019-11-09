local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(0,0)
	self.slot = {}
	self.items = {}
	local size = {}
end

function PANEL:SetSlots(sx,sy)
	local pos = 0 
	for y=1,sy do
		for x=1,sx do
			pos = pos + 1
			local slot = vgui.Create("ManolisSlot", self)
			local size = 77
			slot:SetPos((x*(size+3)-size),(y*(size+3))-size)
			slot.pos = pos
			table.insert(self.slot, slot)
		end
	end

	size = {sx,sy}

	self:SetSize(80*sx, 80*sy)

	self.isSlots = true
end

function PANEL:SetItems(items)
	self:RemoveAllItems()
	local c = 1
	for k,v in pairs(items) do
		v.slot = c
		self:AddInventoryItemToSlot(v)
		c=c+1
	end
end

function PANEL:SetSelectCallback(f)
	for k,v in pairs(self.slot) do
		v.OnSelected = function(o)
			for k2,v2 in pairs(self.slot) do
				if(v2==v) then
					f(o)
					v.Selected = true
				else
					v2.Selected = false
				end
			end
		end
	end
end

function PANEL:DeselectAll()
	self:ClearSelect()
end

function PANEL:ClearSelect()
	for k,v in pairs(self.slot) do
		v.Selected = false
	end
end

function PANEL:RemoveLocalItem(id)
	for k,v in pairs(self.items) do
		
		if(IsValid(v)) then
			if(v.t.id == id) then
				
				v:GetParent().Selected = false
				v:GetParent().item = nil
				v:Remove()
				table.remove(self.items,k)
			end
		end
	end
end

function PANEL:RemoveAllItems()
	for k,v in pairs(self.slot) do
		if(IsValid(v)) then
			if(v.item) then
				v.item:Remove()
				v.item = nil
			end			
		end
	end

	for k,v in pairs(self.items) do
		v:Remove()
		v = nil
	end
	
	self.items = {}
end

function PANEL:AddInventoryItem(t)
	for k,v in pairs(self.slot) do
		if(!v.item) then
			local item = vgui.Create("ManolisItem", v)
			item:SetPos(0,0)
			item.t = t
			item:Go()
			table.insert(self.items,item)

			return
		end
	end
end

function PANEL:AddInventoryItemToSlot(t)
	for k,v in pairs(self.items) do
		if(v.item) then
			if(v.item.t.id == t.id) then
				return false
			end
		end
	end

	local item = vgui.Create("ManolisItem", self.slot[t.slot])
	item:SetPos(0,0)
	item.t = t
	if(item.icon) then
		item:Go()
	end
	

	table.insert(self.items, item)

	return true
end

vgui.Register("ManolisSlots", PANEL, "Panel")


