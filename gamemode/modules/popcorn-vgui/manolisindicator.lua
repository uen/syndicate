local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(90,30)
	self.active = false
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(200, 0,0, 255)
	if(self.active) then
		surface.SetDrawColor(0,200,0)
	end

	surface.DrawRect(0,0, w, h)
end

vgui.Register("ManolisIndicator", PANEL, "Panel")
