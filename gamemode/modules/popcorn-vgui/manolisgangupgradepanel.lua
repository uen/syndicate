local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(625,130)


	local p = vgui.Create('Panel',self)
	p:SetPos(13,13)
	p:SetSize(64,64)

	self.icon = vgui.Create("DImage", p)
	self.icon:SetPos(4,0)
	self.icon:SetSize(56,56)

	self.name = vgui.Create("DLabel", self)
	self.name:SetPos(13+64+13, 10)
	self.name:SetFont('manolisItemInfoName')
	self.name:SetTextColor(Color(255, 255, 255, 255))
	self.name:SetText(DarkRP.getPhrase('vgui_unknown'))

	self.price = vgui.Create("DLabel", self)
	self.price:SetPos(13+64+13,10+20+3-4)
	self.price:SetFont('manolisItemInfoName')
	self.price:SetTextColor(Color(0,255,0,255))
	self.price:SetText('$0')

	self.description = vgui.Create("DLabel", self)
	self.description:SetPos(13+64+13,45+3) // 60 +4
	self.description:SetFont('manolisButtonFontAlt')
	self.description:SetTextColor(Color(255,255,255,255))
	self.description:SetSize(400,35)
	self.description:SetContentAlignment(7)
	self.description:SetWrap(true)
	self.description:SetMultiline(true)

	local current = vgui.Create("DLabel", self)
	current:SetPos(13+64+13,45+35+10-2)
	current:SetFont('manolisButtonFontAlt')
	current:SetTextColor(Color(255,255,255,255))
	current:SetText(DarkRP.getPhrase('gang_currentlevel'))
	current:SizeToContents()

	self.current = vgui.Create("DLabel", self)
	self.current:SetPos(13+64+13,45+35+16+10-2)
	self.current:SetFont('manolisButtonFontAlt')
	self.current:SetTextColor(Color(255,255,255,255))
	self.current:SetText('')
	self.current:SizeToContents()


	local n = vgui.Create("DLabel", self)
	n:SetPos(13+10+64+250,45+35+10-2)
	n:SetFont('manolisButtonFontAlt')
	n:SetTextColor(Color(255,255,255,255))
	n:SetText(DarkRP.getPhrase('gang_next'))
	n:SizeToContents()

	self.next = vgui.Create("DLabel", self)
	self.next:SetPos(13+10+64+250,45+35+16+10-2)
	self.next:SetFont('manolisButtonFontAlt')
	self.next:SetTextColor(Color(255,255,255,255))
	self.next:SetText('')
	self.next:SizeToContents()


	self.addRival = vgui.Create("ManolisButton", self)
	self.addRival.Alternate = true
	self.addRival:SetPos(625-110-20, (90/2)-(self.addRival:GetTall()/2)-15+2)
	self.addRival:SetWide(25*5-5)
	self.addRival:SetText(DarkRP.getPhrase('gang_purchase'))

	self.uiq = ''
	self.t = {}
end

function PANEL:SetLevel(curLevel)
	local nameStr = self.t.name
	nameStr = nameStr .. ' '..DarkRP.getPhrase('gang_upgrade_level', curLevel,manolis.popcorn.config.maxGangUpgrade)

	local price = self.t.price
	if(type(price)=='table') then
		self.price:SetText(DarkRP.formatMoney(price[curLevel+1] or 1000000))
	else
		self.price:SetText(DarkRP.formatMoney(price*curLevel))
	end


	local curAf = ''
	local nAf = ''
	local afStr = ''
	local uiq = ''
	for k,v in pairs(manolis.popcorn.gangs.upgrades.upgrades) do
		if(v.uiq==self.t.upgrade) then
			local affect = v.effect[curLevel] or 0
			curAf = affect >= 0 and '+'..affect or affect
			nAf = v.effect[curLevel+1] and (v.effect[curLevel+1]>=0 and '+'..v.effect[curLevel+1] or v.effect[curLevel+1]) or ''

			afStr = v.effectStr

		end
	end


	self.current:SetText(curAf..afStr)
	self.next:SetText((#nAf > 0 and nAf..afStr or DarkRP.getPhrase('gang_maxed')))
	self.name:SetText(nameStr)

	self.current:SizeToContents()
	self.next:SizeToContents()
	self.price:SizeToContents()
	self.name:SizeToContents()

end

function PANEL:Go(id, name, icon, price, upgrade, curLevel, description)
	local nameStr = name
	nameStr = nameStr .. " "..DarkRP.getPhrase('gang_upgrade_level', curLevel,manolis.popcorn.config.maxGangUpgrade)
	
	self.name:SetText(nameStr)
	self.name:SizeToContents()

	self.uiq = upgrade
	self.t = {name=name,price=price, upgrade=upgrade}


	self.price:SizeToContents()

	self.description:SetText(description)
	self.icon:SetImage("manolis/popcorn/icons/gangs/upgrades/"..icon)

	self:SetLevel(curLevel)
	self.addRival.DoClick = function()
		if(manolis.popcorn.config.maxGangUpgrade<=curLevel) then return end
		Manolis_Query(DarkRP.getPhrase('gang_purchase_upgrade',name,(curLevel+1),self.price:GetText()), DarkRP.getPhrase('confirm'), DarkRP.getPhrase('gang_purchase'), function() RunConsoleCommand("ManolisPopcornGangUpgradeBuy", upgrade) end, DarkRP.getPhrase('cancel'))
	end
end


function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	
	if(self.Hovered) then
		surface.SetDrawColor(35+1,40+1,48+1,255)
	end

	surface.DrawRect(0,0,w,h)
end

vgui.Register("ManolisGangUpgradePanel", PANEL, "Panel")