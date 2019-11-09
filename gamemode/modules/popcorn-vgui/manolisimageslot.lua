local PANEL = {}
function PANEL:SetImage(mat)
	self.Image = mat
end

function PANEL:Paint(w,h)
	if(self.Image) then
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(self.Image)
		surface.DrawTexturedRect(0,0,w,h)
	end
end

vgui.Register("ManolisImageSlot", PANEL, "ManolisSlot")