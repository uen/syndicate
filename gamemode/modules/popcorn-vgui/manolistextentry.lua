local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetFont("manolisItemInfoName")
	self:SetDrawBackground(false)
	self:SetTextColor(Color(255,255,255,255))
	self:SetCursorColor(Color(255,255,255,120))
	self:SetMultiline(false)
	self:SetDrawBorder( false )
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	if(self.Hovered) then
		surface.SetDrawColor(35+2,40+2,48+2,255)
	end
	surface.DrawRect(0,0,w,h)
	derma.SkinHook( "Paint", "TextEntry", self, w, h )
	return false
end

vgui.Register("ManolisTextEntry", PANEL, "DTextEntry")
