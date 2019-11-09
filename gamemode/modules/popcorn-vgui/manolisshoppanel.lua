local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(625,90)

	self.icon = vgui.Create("SpawnIcon", self)
	self.icon:SetPos(13,13)
	self.icon:SetSize(64,64)

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

function PANEL:Update(type,new)
	if(type=='money') then
		self.price:SetTextColor((((LocalPlayer():getDarkRPVar('level') or 1) >= self.pLev) and (new >= self.pNum)) and Color(0,255,0,255) or Color(255,0,0,255))
	elseif(type=='level') then
		self.price:SetTextColor((((LocalPlayer():getDarkRPVar('money') or 0) >= self.pNum) and (new >= self.pLev)) and Color(0,255,0,255) or Color(255,0,0,255))
	end
end


function PANEL:Go(modelViewColor, name, icon, price, level, cmd, s)
	local nameStr = name

	if(level>1) then
		nameStr = nameStr .. ' '..DarkRP.getPhrase('vgui_level',level)
	end
	
	self.name:SetText(nameStr)
	self.name:SizeToContents()

	self.price:SetText(DarkRP.formatMoney(price or 0))

	self.price:SetTextColor((((LocalPlayer():getDarkRPVar('level') or 1) >= level) and (LocalPlayer():canAfford(price))) and Color(0,255,0,255) or Color(255,0,0,255))
	self.price:SizeToContents()

	self.pNum = price
	self.pLev = level
	
	self.icon:SetModel(icon)
	self.icon:SetTooltip(false)
	if(modelViewColor) then
		self.icon:SetColor(modelViewColor)
	end

	self.icon:SetColor(Color(0,255,0))

	if(!s) then
		self.purchase.DoClick = fn.Compose{fn.Partial(RunConsoleCommand, "DarkRP", cmd)}
	else
		self.purchase.DoClick = s
	end
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	
	if(self.Hovered) then
		surface.SetDrawColor(35+1,40+1,48+1,255)
	end

	surface.DrawRect(0,0,w,h)
end

vgui.Register("ManolisShopPanel", PANEL, "Panel")