local PANEL = {}


function PANEL:Init()
	self.disableOutline = true
	self:SetSize(355,500-40)
	self:SetVisible(true)

	self.items = {}
	self.pickingUp = false
	self.a = 0
end

function PANEL:GetItems()
	return self.items
end

function PANEL:SetPadding()
end

function PANEL:PerformLayout()
end

function PANEL:ClearPanel()
	self:Clear()
	self.a = 0

	for i,v in pairs(self.items) do
		self.items[i] = nil
	end
end

function PANEL:Paint(x,y)
end

function PANEL:Add(item, p)
	item:SetParent(self)

	item:SetPos(0,self.a)
	self.a = self.a + item:GetTall() + (p or 5)

	self:SetTall(self.a- (p or 5))

	table.insert(self.items, item)
end

vgui.Register("ManolisPanel", PANEL, "Panel")