function pointinrectangle( px, py, x, y, width, height )
	return px >= x and
	py >= y and
	px < x + width and
	py < y + height
end

local PANEL = {}
local slotx = Material('manolis/popcorn/hud/small-slotx.png')
function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(67,67)

	local icon = vgui.Create('SpawnIcon',self)
	local spac = 20
	icon:SetSize(58-spac,58-spac)
	icon:SetPos(67/2 - 25,67/2-25)

	icon.SetHidden = function(self,x)

		if(x) then
			icon.PaintOver = function(self,w,h)
				surface.SetDrawColor(255,255,255,255)
				surface.SetMaterial(slotx)
				surface.DrawTexturedRect(0,0,w,h)
			end
		else
			icon.PaintOver = function() end
		end
	end
	
	self.icon = icon


	self.icon.Paint = function(self,w,h)
		return
	end

	self.icon.PaintOver = function()
		return
	end

	self.icon.PerformLayout = function(self)
		self.Icon:StretchToParent(0,0,0,0)
		return
	end

	self.icon:SetHidden(true)
	self.icon:SetTooltip('')
	self:SetText('')


	self.icon.DoClick = self.DoClick
	self.icon.DoRightClick = self.DoRightClick

	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )
end

local slot = Material('manolis/popcorn/hud/small-slot.png')
function PANEL:SetModel(model)
	self.icon:SetModel(model)
	self.icon:SetVisible(true)

	self.icon:SetTooltip('')
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(255,255,255,255)
	surface.SetMaterial(slot)
	surface.DrawTexturedRect(0,0,w,h)
	
end

function PANEL:OnSelected(o) 

end

function PANEL:OnMousePressed(key)
end

function PANEL:ItemDropped(item)
	return false
end

function PANEL:DroppedInto()
	return true
end
vgui.Register("ManolisSmallSlot", PANEL, "DButton")


