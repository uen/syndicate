local PANEL = {}

function PANEL:Init()

end

local figure = Material('manolis/popcorn/hud/character/bp.png', 'smooth mips')
function PANEL:Paint(w,h)
	surface.SetDrawColor(255,255,255,255)
	surface.SetMaterial(figure)
	surface.DrawTexturedRect(0,0,w,h)
end

vgui.Register("ManolisCharacter", PANEL, "Panel")