function pointinrectangle( px, py, x, y, width, height )
	return px >= x and
	py >= y and
	px < x + width and
	py < y + height
end

local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(77,77)
	local findParent
	findParent = function(self)
		if(self:GetParent()) then
			if(self:GetParent():GetName()=='ManolisFrame') then
				return self:GetParent()
			else
				findParent(self:GetParent())
			end
		else
			return nil
		end 
	end	
	local frame = findParent(self)
	manolis.popcorn.inventory.AddItemDrop(self, frame)

	self.item = nil
	self.Disabled = false
	self.pos = 0
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	if(self.Hovered) then
		surface.SetDrawColor(37,42,50,255)
	end

	surface.DrawRect(0,0, w, h)
	if(self.Selected) then
		if(self.item and !self.item.Selected) then
			self.item.Selected = true
		end
	else
		if(self.item and self.item.Selected) then
			self.item.Selected = false
		end
	end
end

function PANEL:OnSelected(o) 

end

function PANEL:OnMousePressed(key)
	if(self:GetParent() and self:GetParent().DeselectAll) then
		self:GetParent():DeselectAll()
	end
end

function PANEL:ItemDropped(item)
	table.sort(manolis.popcorn.inventory.itemDrops, function(a,b) return (a.GetParentZPos and a:GetParentZPos() or 0) > (b.GetParentZPos and b:GetParentZPos() or 0) end)
	for k,v in pairs(manolis.popcorn.inventory.itemDrops or {}) do
		if(IsValid(v)) then
			if(v:IsVisible() and (v:GetParent() and v:GetParent():IsVisible())) then
				if(v != self) then
					local mouseX,mouseY = gui.MouseX(),gui.MouseY()
					local localX, localY = v:ScreenToLocal(mouseX, mouseY)
					if(pointinrectangle(localX,localY,0,0,v:GetWide(), v:GetTall())) and ((!(v:GetParent().page)) or (v:GetParent().page:IsVisible())) then
						return v
					end
				end
			end
		end
	end
	return false
end

function PANEL:DroppedInto()
	return true
end
vgui.Register("ManolisSlot", PANEL, "Panel")


