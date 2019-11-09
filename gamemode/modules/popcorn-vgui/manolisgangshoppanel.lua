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

	self.name = vgui.Create("DLabel", self)
	self.name:SetPos(13+64+13, 10)
	self.name:SetFont('manolisItemInfoName')
	self.name:SetTextColor(Color(255, 255, 255, 255))
	self.name:SetText(DarkRP.getPhrase('vgui_unknown'))

	self.price = vgui.Create("DLabel", self)
	self.price:SetPos(13+64+13,10+20+3-5+1)
	self.price:SetFont('manolisItemInfoName')
	self.price:SetTextColor(Color(0,255,0,255))
	self.price:SetText('$0')

	self.description = vgui.Create("DLabel", self)
	self.description:SetPos(13+64+13,45+3) // 60 +4
	self.description:SetFont('manolisButtonFontAlt')
	self.description:SetTextColor(Color(255,255,255,255))
	self.description:SetSize(400,60)
	self.description:SetContentAlignment(7)
	self.description:SetWrap(true)
	self.description:SetMultiline(true)

	self.addRival = vgui.Create("ManolisButton", self)
	self.addRival.Alternate = true
	self.addRival:SetPos(625-110-20, (90/2)-(self.addRival:GetTall()/2)-15+2)
	self.addRival:SetWide(25*5-5)
	self.addRival:SetText("Purchase")
	self.permissions = {}

	for i=1, 5 do
		local x = 625-110-20
		local y = 20+8+3+10+2
		local checkBox = vgui.Create("ManolisCheckbox", self)
		checkBox:SetPos(x+(25*i)-25, y+3+12)
		checkBox:SetTooltip(DarkRP.getPhrase('vgui_permission', manolis.popcorn.gangs.GetRank(i)))
		table.insert(self.permissions,checkBox)
	end
end

function PANEL:Go(id, name, icon, price, level, description, showPermissions, permissions)
	local nameStr = name
	if(level>1) then
		nameStr = nameStr .. ' ' ..DarkRP.getPhrase('vgui_level', level)
	end

	self.name:SetText(nameStr)
	self.name:SizeToContents()

	self.price:SetText(DarkRP.formatMoney(price))
	self.price:SizeToContents()

	self.description:SetText(description)


	self.icon:SetModel(icon)
	self.icon:SetTooltip(false)
	
	self.icon:SetColor(Color(0,255,0))

	if(showPermissions) then
		for k,v in pairs(self.permissions) do
			v.OnChange = function(self,val)
				RunConsoleCommand("ManolisPopcornSetGangShopPermission", id, k, val and 1 or 0)
				manolis.popcorn.temp.ignorePermissionGangRefresh = true
			end
		end
	else
		for k,v in pairs(self.permissions) do
			v:SetDisabled(true)
		end
	end

	if(permissions) then
		for k,v in pairs(permissions) do
			self.permissions[k]:SetChecked(v)
		end
	end

	self.addRival.DoClick = function()
		RunConsoleCommand("ManolisPopcornGangShopBuy", id)
	end
end


function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	
	if(self.Hovered) then
		surface.SetDrawColor(35+1,40+1,48+1,255)
	end


	surface.DrawRect(0,0,w,h)
end

vgui.Register("ManolisGangShopPanel", PANEL, "Panel")