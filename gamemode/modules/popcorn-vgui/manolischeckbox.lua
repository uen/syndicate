local PANEL = {}
local Checked = Material('manolis/popcorn/checkbox2.png')
function PANEL:Init()
	self:SetVisible(true)

	self.image = vgui.Create("DImage", self)
	self.image:SetMaterial(Checked)
	self.image:SetPos(0,0)
	self.image:SetSize(20,20)
	self.image:SetVisible(false)

	self:SetSize(20,20)
	self:SetCursor("hand")

	self.oldChecked = false
	self.checked = false
end

function PANEL:SetSize(a,b)
	self.BaseClass.SetSize(self,a,b)
	self.image:StretchToParent(1,1,1,1)
end

function PANEL:Changed(v)
	self.image:SetVisible(v)
	self.checked = v
end

function PANEL:SetDisabled(a)
	if(a) then
		if(!self.barrier) then
			self.barrier = vgui.Create("Panel", self)
			self.barrier:SetSize(self:GetSize())
			self.barrier:SetPos(0,0)
		end
	else
		if(self.barrier) then
			self.barrier:Remove()
		end
	end
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(43,48,59, 255)

	local c = self:GetChecked()

	if(self.Alternate) then
		surface.SetDrawColor(35, 40, 48, 255)

		if(self.Hovered) then
			surface.SetDrawColor(35+1, 40+1, 48+1, 255)
		end

		if(c) then
		end
	else
		if(self.Hovered) then
			surface.SetDrawColor(43+2,48+2,59+2, 255)
			self:GetParent().Hovered = true
		end

		if(c) then
			surface.SetDrawColor(43+2,48+2,59+2)
		end

	end

	if(self.oldChecked!=c) then
		self.oldChecked = c
		self:Changed(c)
	end

	surface.DrawRect(0,0, w, h)
end

vgui.Register("ManolisCheckbox", PANEL, "DCheckBox")
