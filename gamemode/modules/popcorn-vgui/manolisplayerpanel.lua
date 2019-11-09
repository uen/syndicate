local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(320,45)

	self.icon = vgui.Create("SpawnIcon", self)
	self.icon:SetPos(13,13)
	self.icon:SetSize(32,32)

	self.icon.Paint = function(self,w,h)
		return
	end

	self.icon.PaintOver = function()
		return
	end

	self.icon.PerformLayout = function(self)
		self.Icon:StretchToParent(0,0,0,0)
		return
	end

	self.icon:SetTooltip(false)
	local y = 7

	self.name = vgui.Create("DLabel", self)
	self.name:SetPos(13+64+13, 20+y)
	self.name:SetFont('manolisItemInfoName')
	self.name:SetTextColor(Color(255, 255, 255, 255))
	self.name:SetText(DarkRP.getPhrase('vgui_unknown'))

	self.price = vgui.Create("DLabel", self)
	self.price:SetPos(13+64+13,20+17+y)
	self.price:SetFont('manolisItemInfoName')
	self.price:SetTextColor(Color(0,255,0,255))
	self.price:SetText(DarkRP.formatMoney(0))

	self.purchase = vgui.Create("ManolisButton", self)
	self.purchase.Alternate = true
	self.purchase:SetPos(625-110-20-10, (90/2)-(self.purchase:GetTall()/2))
	self.purchase:SetWide(25*5-5)
	self.purchase:SetText(DarkRP.getPhrase('purchase'))

	self.pNum = 0
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	
	if(self.Hovered) then
		surface.SetDrawColor(35+1,40+1,48+1,255)
	end

	surface.DrawRect(0,0,w,h)

end

vgui.Register("ManolisPlayerPanel", PANEL, "Panel")