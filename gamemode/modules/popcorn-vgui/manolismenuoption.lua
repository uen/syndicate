local PANEL = {}

function PANEL:Init()

	self:SetFont("manolisItemInfoName")
	self:SetTextColor(Color(255,255,255,255))
	self:SetTextInset(10,0)
end

function PANEL:PerformLayout()
	local w = math.max( self:GetParent():GetWide(), self:GetWide() )
	self:SetSize(w, 35)
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	surface.DrawRect(0,0,w,h)
	surface.SetDrawColor(35, 40, 48, 255)

	if(self.Hovered or self.Highlight) then
		surface.SetDrawColor(43,48,59, 255)
	end

	surface.DrawRect(1,1,w-2,h-2)

	return false
end

derma.DefineControl( "ManolisMenuOption", "Manolis Menu Option Line", PANEL, "DMenuOption" )