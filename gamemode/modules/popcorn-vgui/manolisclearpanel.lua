local PANEL = {}

function PANEL:Init()

end

function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	surface.DrawRect(0,0,w,h)
end

vgui.Register("ManolisClearPanel", PANEL, "Panel")