local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(101,40)
end

vgui.Register("ManolisPageButton", PANEL, "ManolisButton")