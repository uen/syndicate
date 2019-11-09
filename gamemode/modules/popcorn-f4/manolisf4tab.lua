local PANEL = {}
AddCSLuaFile()

function PANEL:Init()
	self:SetSize(210, 60)
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(0,0,59, 255)
	surface.DrawRect(0,0, w, h)
end

vgui.Register("ManolisF4SidebarTab", PANEL, "DButton")