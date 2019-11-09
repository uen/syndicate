local PANEL = {}

local closeButton = Material('manolis/popcorn/close-button.png')
function PANEL:Init()
	self:SetSize(20,10)
	self:SetCursor("hand")
	self.m_Image = vgui.Create("DImage", self)
	self.m_Image:SetMaterial(closeButton)
	self.m_Image:SetSize(10,10)
	self.m_Image:SetPos(0,0)

	self:SetText("")
end

function PANEL:DoClick()
	if(self:GetParent():GetParent().Close) then
		self:GetParent():GetParent():Close()
	else
		self:GetParent():GetParent():Remove()
	end
	gui.EnableScreenClicker(false)
end

function PANEL:Paint(w,h)
	return
end

vgui.Register("ManolisCloseButton", PANEL, "Button")