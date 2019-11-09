local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(101,40)

	self:SetFont("manolisButtonFont")
	self:SetTextColor(Color(100,100,100,255))
end

function PANEL:SetColor(c)
	self:SetTextColor(c)
end

PANEL.isDepressed = false
function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)

	if(self.Hovered) then
		self:GetParent().Hovered = true
		surface.SetDrawColor(35+2,40+2,48+2, 255)
	end

	if(self.active) then
		surface.SetDrawColor(43,48,59, 255)	
	end

	surface.DrawRect(0,0, w, h)
end

vgui.Register("ManolisF4Button", PANEL, "DButton")