local PANEL = {}

function PANEL:Init()
	self.disableOutline = true
	self:SetSize(355,500-40)
	self:SetVisible(true)

	self.items = {}
	self.pickingUp = false
	self.a = 0
	self.padding = 5
end

function PANEL:SetPadding(a)
	self.padding = a
end

function PANEL:Add(item, padding)
	if(!padding) then padding = self.padding end
	item:SetParent(self)

	self.a = self.a + item:GetTall() + padding

	self:SetTall(self.a-padding)

	table.insert(self.items, item)
end


vgui.Register("ManolisAdvancedPanel", PANEL, "ManolisPanel")