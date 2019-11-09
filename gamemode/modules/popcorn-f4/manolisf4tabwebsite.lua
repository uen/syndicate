local PANEL = {}

function PANEL:Init()

	self:SetSize(670,580)

	self.html = vgui.Create("HTML",self)
	self.html:Dock(FILL)
	self.html:OpenURL("http://manolis.io/?")
end
vgui.Register( "manolisF4TabWebsite", PANEL, "DPanel" )