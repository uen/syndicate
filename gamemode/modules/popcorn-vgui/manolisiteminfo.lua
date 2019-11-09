local PANEL = {}

local getUpgrades = function(item)
	if(not(item)) then return "" end
	local upgrades = ""

	local dcD = {}
	for k,v in pairs(item.json.upgrades or {}) do
		if(manolis.popcorn.upgrades.upgrades[item.json.type]) then
			if(manolis.popcorn.upgrades.upgrades[item.json.type][v.class]) then
				if(!dcD[v.class]) then 
					dcD[v.class] = 0
				end	
				if(manolis.popcorn.upgrades.upgrades[item.json.type][v.class].levels) then
					if(manolis.popcorn.upgrades.upgrades[item.json.type][v.class].levels[v.level]) then
						dcD[v.class] = dcD[v.class] + manolis.popcorn.upgrades.upgrades[item.json.type][v.class].levels[v.level]	
					end
				end			
			end
		end
	end

	for k,v in pairs(dcD) do
		if(manolis.popcorn.upgrades.upgrades[item.json.type][k].levels) then
			upgrades = upgrades..'+'..(v)..manolis.popcorn.upgrades.upgrades[item.json.type][k].levelsString..'\n'
		end
	end

	return upgrades
end

local getBaseUpgrades = function(item)
	if(not(item)) then return "" end
	local upgrades = ""

	if(item.json.base) then
		for k,v in pairs(item.json.base) do
			if(manolis.popcorn.upgrades.upgrades[item.json.type] and manolis.popcorn.upgrades.upgrades[item.json.type][k]) then
				upgrades = upgrades..(v>0 and '+' or '')..v..manolis.popcorn.upgrades.upgrades[item.json.type][k].levelsString..'\n'
			end
		end
	end

	return upgrades
end

function PANEL:Init()
	self:SetSize(400,180)	
end

function PANEL:Paint(w,h)
	if(self.t) then
		surface.SetDrawColor(43,48,59, 255)
		if(self.t.type=='blueprint') then
			surface.SetDrawColor(14,44,106,255)
		end
		surface.DrawRect(0,0,w,h)
	end
end

function PANEL:Armor()
	local t = self.t
	local ySize = 10
	local xPos = 10+4
	local space = 20
	self.Paint = function(self,w,h)
		surface.SetDrawColor(28,31,38,255)
		surface.DrawRect(0,0,w,h)
		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(4,4,w-8,h-8)
	end

	local icon = vgui.Create("ManolisImage", self)
	icon:SetImage('manolis/popcorn/icons/'..t.icon)
	icon:SetSize(77,77)
	icon:SetPos(400-77-10, ySize)

	icon.Paint = function(self,w,h)
		surface.SetDrawColor(255,255,255,255)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(manolis.popcorn.materialCache['item-bg'])
		surface.DrawTexturedRect(0,0,w,h)
		self:PaintAt( 0, 0, self:GetWide(), self:GetTall() )
	end


	local useModel = false
	if(!file.Exists("materials/manolis/popcorn/icons/"..self.t.icon, 'GAME')) then
		if(self.t.json and self.t.json.model) then
		
			local icon_ = vgui.Create("SpawnIcon", icon)
			icon_:SetSize(60,60)
			icon_:SetModel(self.t.json.model)
			icon_:SetPos(((77-60)/2),((77-60)/2))
			icon_.Paint = function(self,w,h)
				return
			end

			icon_.PaintOver = function()
				return
			end

			icon_:SetTooltip(false)

			icon_.OnMousePressed = function(s, key)
				icon:OnMousePressed(key)
				return false
			end

			icon_.OnMouseReleased = function(s, key)
				icon:OnMouseReleased(key)
				return false
			end

			icon_.PerformLayout = function(self)
				//icon:StretchToParent(0,0,0,0)
				return
			end

			icon_.OnCursorEntered =  function()
				icon:OnCursorEntered()
			end

			icon_.OnCursorExited =  function()
				icon:OnCursorExited()
			end

			useModel = true
		end
	end

	if(!useModel) then
		icon:SetImage('manolis/popcorn/icons/'..t.icon)
	end

	local name = vgui.Create("DLabel", self)
	name:SetFont("manolisItemInfoName")
	name:SetPos(xPos,ySize)
	name:SetTextColor(Color(255,255,255,255))
	
	if(!t.json or (!t.json.class and !t.json.classOverride)) then return end
	if(!t.json.class) then t.json.class = t.json.classOverride end
	if(!t.json.level) then t.json.level = 1 end

	local nameB = !t.json.title and t.json.class.." "..t.name or t.json.title..' ('..t.json.class..')'
	name:SetColor(manolis.popcorn.inventory.GetClassColor(t.json.class))
	name:SetText(nameB..' (+'..t.json.level..')')
	name:SizeToContents()

	ySize = ySize + space

	local level = vgui.Create("DLabel", self)
	level:SetFont("manolisItemInfoName")
	level:SetPos(xPos,ySize)
	level:SetTextColor(manolis.popcorn.levels.HasLevel(LocalPlayer(), t.level) and Color(255, 200, 0, 255) or Color(200,0,0))
	
	local text = t.json.crafted and DarkRP.getPhrase('crafted_by', t.json.crafted)..' '..DarkRP.getPhrase('vgui_level', t.level) or DarkRP.getPhrase('vgui_level2', t.level)
	level:SetText(text)
	level:SizeToContents()
	ySize = ySize + 30

	local base = getBaseUpgrades(t)
	local st = vgui.Create("DLabel", self)
	st:SetPos(xPos,ySize)
	st:SetFont("manolisItemInfoName")
	st:SetTextColor(Color(250,250,0,255))
	st:SetWide(155)
	st:SetText(base)
	st:SizeToContents()

	local stats = getUpgrades(t)
	local st2 = vgui.Create("DLabel", self)
	st2:SetPos(xPos+155,ySize)
	st2:SetTall(0)
	st2:SetWide(155)
	st2:SetFont("manolisItemInfoName")
	st2:SetTextColor(Color(0,255,0,255))
	st2:SetText(stats)
	st2:SizeToContents()

	ySize = ySize + math.max(45,math.max(st:GetTall(), st2:GetTall())+(((t.json.slots or 0)>0 and 10 or 0)))

	if(t.json.slots and t.json.slots > 0) then
		local slots = vgui.Create("ManolisSlotsItem", self)

		local numX = math.min(4, t.json.slots)
		slots:SetPos(400-(numX*80)-7,ySize-10)
		slots:SetSlots(t.json.slots)
			
		for k,v in pairs(t.json.upgrades) do
			local item = manolis.popcorn.upgrades.FindUpgrade(t.json.type, v.class, v.level)
			if(item) then
				local upgrade = vgui.Create("ManolisItem", slots.slot[k])
				upgrade.t = item
				upgrade.t.icon = manolis.popcorn.upgrades.GetUpgradeIcon(t.json.type, v.class, v.level)
				upgrade:Go()
			end
		end
	end
	local cal = t.json.slots or 0
	ySize = ySize + math.ceil((cal/4))*81
	self:SetSize(400,ySize)
end

function PANEL:Upgrade()
	local t = self.t
	local ySize = 10
	local xPos = 10+4
	local space = 20
	self.Paint = function(self,w,h)
		surface.SetDrawColor(28,31,38,255)
		surface.DrawRect(0,0,w,h)
		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(4,4,w-8,h-8)
	end

	local icon = vgui.Create("ManolisImage", self)
	icon:SetImage('manolis/popcorn/icons/'..t.icon)
	icon:SetSize(77,77)
	icon:SetPos(400-77-10, ySize)

	icon.Paint = function(self,w,h)
		surface.SetDrawColor(255,255,255,255)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(manolis.popcorn.materialCache['item-bg'])
		surface.DrawTexturedRect(0,0,w,h)
		self:PaintAt( 0, 0, self:GetWide(), self:GetTall() )
	end


	local useModel = false
	if(!file.Exists("materials/manolis/popcorn/icons/"..self.t.icon, 'GAME')) then
		if(self.t.json and self.t.json.model) then
		
			local icon_ = vgui.Create("SpawnIcon", icon)
			icon_:SetSize(60,60)
			icon_:SetModel(self.t.json.model)
			icon_:SetPos(((77-60)/2),((77-60)/2))
			icon_.Paint = function(self,w,h)
				return
			end

			icon_.PaintOver = function()
				return
			end

			icon_:SetTooltip(false)

			icon_.OnMousePressed = function(s, key)
				icon:OnMousePressed(key)
				return false
			end

			icon_.OnMouseReleased = function(s, key)
				icon:OnMouseReleased(key)
				return false
			end

			icon_.PerformLayout = function(self)
				//icon:StretchToParent(0,0,0,0)
				return
			end

			icon_.OnCursorEntered =  function()
				icon:OnCursorEntered()
			end

			icon_.OnCursorExited =  function()
				icon:OnCursorExited()
			end

			useModel = true
		end
	end

	if(!useModel) then
		icon:SetImage('manolis/popcorn/icons/'..t.icon)
	end


	local level = vgui.Create("DLabel", self)
	level:SetFont("manolisItemInfoName")
	level:SetPos(xPos,ySize)
	level:SetTextColor(manolis.popcorn.levels.HasLevel(LocalPlayer(), t.level) and Color(0,200,0,255) or Color(200,0,0))
	level:SetText(DarkRP.getPhrase('vgui_level',t.level))
	level:SizeToContents()

	ySize = ySize + space

	local wep = vgui.Create("DLabel", self)
	wep:SetFont("manolisItemInfoName")
	wep:SetPos(xPos, ySize)
	wep:SetTextColor(Color(255, 200, 0, 255))
	wep:SetText(t.json.type:sub(1,1):upper()..t.json.type:sub(2)..' Upgrade')
	wep:SizeToContents()
	ySize = ySize + space

	local name = vgui.Create("DLabel", self)
	name:SetFont("manolisItemInfoName")
	name:SetPos(xPos,ySize)
	name:SetTextColor(Color(255, 255, 255, 255))
	name:SetText(t.name)
	name:SizeToContents()
	ySize = ySize + space

	local af = ""
	if(manolis.popcorn.upgrades.upgrades[t.json.type][t.json.class].levels and manolis.popcorn.upgrades.upgrades[t.json.type][t.json.class].levels[t.json.level] and manolis.popcorn.upgrades.upgrades[t.json.type][t.json.class].levelsString) then
		af = (manolis.popcorn.upgrades.upgrades[t.json.type][t.json.class].levels[t.json.level])..(manolis.popcorn.upgrades.upgrades[t.json.type][t.json.class].levelsString or '')..'\n'
	end


	local damage = vgui.Create("DLabel", self)
	damage:SetFont("manolisItemInfoName")
	damage:SetPos(xPos,ySize)
	damage:SetTextColor(Color(255, 255, 255, 255))
	damage:SetText('+'..af)
	damage:SizeToContents()
	ySize = ySize + space

	local value = vgui.Create("DLabel", self)
	value:SetFont("manolisItemInfoName")
	value:SetPos(xPos,ySize)
	value:SetTextColor(Color(255, 255, 255, 255))
	value:SetText(DarkRP.getPhrase('value_x',DarkRP.formatMoney(tonumber(t.value))))
	value:SizeToContents()
	ySize = ySize + space

	local desc = vgui.Create("DLabel", self)
	desc:SetFont("manolisItemInfoName")
	desc:SetPos(xPos,ySize)
	desc:SetTextColor(Color(255, 255, 255, 255))
	desc:SetText(DarkRP.getPhrase('upgrade_str', t.json.type))
	desc:SizeToContents()
	ySize = ySize + 25 
	ySize = ySize + 7

	self:SetSize(400,math.min(ySize, 250))
end

function PANEL:Blueprint()
	local t = self.t
	if(!t or !t.json or !t.json.materials) then return end

	local ySize = 10
	local xPos = 10+4
	local space = 20
	self.Paint = function(self,w,h)
		surface.SetDrawColor(28,31,38,255)
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(4,4,w-8,h-8)
	end

	local icon = vgui.Create("ManolisImage", self)
	icon:SetImage('manolis/popcorn/icons/'..t.icon)
	icon:SetSize(77,77)
	icon:SetPos(400-77-10, ySize)

	icon.Paint = function(self,w,h)
		surface.SetDrawColor(255,255,255,255)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(manolis.popcorn.materialCache['item-bg'])
		surface.DrawTexturedRect(0,0,w,h)
		self:PaintAt( 0, 0, self:GetWide(), self:GetTall() )
	end


	local useModel = false
	if(!file.Exists("materials/manolis/popcorn/icons/"..self.t.icon, 'GAME')) then
		if(self.t.json and self.t.json.model) then
		
			local icon_ = vgui.Create("SpawnIcon", icon)
			icon_:SetSize(60,60)
			icon_:SetModel(self.t.json.model)
			icon_:SetPos(((77-60)/2),((77-60)/2))
			icon_.Paint = function(self,w,h)
				return
			end

			icon_.PaintOver = function()
				return
			end

			icon_:SetTooltip(false)

			icon_.OnMousePressed = function(s, key)
				icon:OnMousePressed(key)
				return false
			end

			icon_.OnMouseReleased = function(s, key)
				icon:OnMouseReleased(key)
				return false
			end

			icon_.PerformLayout = function(self)
				//icon:StretchToParent(0,0,0,0)
				return
			end

			icon_.OnCursorEntered =  function()
				icon:OnCursorEntered()
			end

			icon_.OnCursorExited =  function()
				icon:OnCursorExited()
			end

			useModel = true
		end
	end

	if(!useModel) then
		icon:SetImage('manolis/popcorn/icons/'..t.icon)
	end
	
	local namestr = t.name
	if(t.json.level) then
		namestr = namestr .. ' ' .. DarkRP.getPhrase('vgui_level_item', t.json.level)
	end

	local name = vgui.Create("DLabel", self)
	name:SetFont("manolisItemInfoName")
	name:SetPos(xPos,ySize)
	name:SetTextColor(Color(255, 200, 0, 255))
	name:SetText(namestr)
	name:SizeToContents()
	ySize = ySize + space

	local value = vgui.Create("DLabel", self)
	value:SetFont("manolisItemInfoName")
	value:SetPos(xPos,ySize)
	value:SetTextColor(Color(255,255,255,255))
	value:SetText(DarkRP.getPhrase('value_x', DarkRP.formatMoney(tonumber(t.value))))
	value:SizeToContents()
	ySize = ySize + (space*2)

	local req = vgui.Create("DLabel", self)
	req:SetFont("manolisItemInfoName")
	req:SetPos(xPos, ySize)
	req:SetTextColor(Color(255, 200, 0, 255))
	req:SetText("Requirements:")
	req:SizeToContents()
	ySize = ySize + space

	local matsStr = ''
	for k,v in pairs(t.json.materials) do
		local mat = manolis.popcorn.crafting.FindMaterial(k)

		if(mat) then
			matsStr = matsStr..v..'x '..mat.name..'\n'
		end
	end

	local mats = vgui.Create("DLabel", self)
	mats:SetFont("manolisItemInfoName")
	mats:SetPos(xPos, ySize)
	mats:SetTextColor(Color(255,255,255,255))
	mats:SetText(matsStr)
	mats:SizeToContents()

	ySize = ySize -5 + mats:GetTall()
	self:SetSize(400,math.min(ySize, 250))
end



function PANEL:Weapon()
	local t = self.t
	if(!t or !t.json) then return end
	local ySize = 10
	local xPos = 10+4
	self.Paint = function(self,w,h)
		surface.SetDrawColor(28,31,38,255)
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(4,4,w-8,h-8)
	end

	local icon = vgui.Create("ManolisImage", self)
	
	icon:SetSize(77,77)
	icon:SetPos(400-77-10, ySize)

	icon.Paint = function(self,w,h)
		surface.SetDrawColor(255,255,255,255)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(manolis.popcorn.materialCache['item-bg'])
		surface.DrawTexturedRect(0,0,w,h)
		self:PaintAt( 0, 0, self:GetWide(), self:GetTall() )
	end

	local useModel = false
	if(!file.Exists("materials/manolis/popcorn/icons/"..self.t.icon, 'GAME')) then
		if(self.t.json and self.t.json.model) then
		
			local icon_ = vgui.Create("SpawnIcon", icon)
			icon_:SetSize(60,60)
			icon_:SetModel(self.t.json.model)
			icon_:SetPos(((77-60)/2),((77-60)/2))
			icon_.Paint = function(self,w,h)
				return
			end

			icon_.PaintOver = function()
				return
			end

			icon_:SetTooltip(false)

			icon_.OnMousePressed = function(s, key)
				icon:OnMousePressed(key)
				return false
			end

			icon_.OnMouseReleased = function(s, key)
				icon:OnMouseReleased(key)
				return false
			end

			icon_.PerformLayout = function(self)
				//icon:StretchToParent(0,0,0,0)
				return
			end

			icon_.OnCursorEntered =  function()
				icon:OnCursorEntered()
			end

			icon_.OnCursorExited =  function()
				icon:OnCursorExited()
			end

			useModel = true
		end
	end

	if(!useModel) then
		icon:SetImage('manolis/popcorn/icons/'..t.icon)
	end


	local name = vgui.Create("DLabel", self)
	name:SetFont("manolisItemInfoName")
	name:SetPos(xPos,ySize)
	name:SetTextColor(Color(255,255,255,255))
	ySize = ySize + 20

	local level = vgui.Create("DLabel", self)
	level:SetFont("manolisItemInfoName")
	level:SetPos(xPos,ySize)
	level:SetTextColor(manolis.popcorn.levels.HasLevel(LocalPlayer(), t.level) and Color(255, 200, 0, 255) or Color(200,0,0))
	
	local text = t.json.crafted and DarkRP.getPhrase('crafted_by', t.json.crafted)..' '..DarkRP.getPhrase('vgui_level', t.level) or DarkRP.getPhrase('vgui_level2', t.level)
	level:SetText(text)
	level:SizeToContents()
	ySize = ySize + 20

	local a = DarkRP.getPhrase('s_weapon', (t.type:sub(1,1):upper()..t.type:sub(2)))
	local b = vgui.Create("DLabel", self)
	b:SetPos(xPos,ySize)
	b:SetFont("manolisItemInfoName")
	b:SetTextColor(Color(255,200,0,255))
	b:SetText(a)
	b:SizeToContents()
	ySize = ySize + 30

	local nameB = !t.json.title and t.json.class.." "..t.name or t.json.title
	name:SetText(nameB..' (+'..t.json.level..')')
	name:SetColor(manolis.popcorn.inventory.GetClassColor(t.json.class))
	name:SizeToContents()
	local stats = getUpgrades(t)

	local st = vgui.Create("DLabel", self)
	st:SetPos(xPos,ySize)
	st:SetFont("manolisItemInfoName")
	st:SetTextColor(Color(0,255,0,255))
	st:SizeToContents()
	st:SetText(stats)
	st:SizeToContents()

	ySize = ySize + st:GetTall()+ (t.json.slots>0 and 20 or 0)
	if(t.json.slots) then
		local slots = vgui.Create("ManolisSlotsItem", self)

		local numX = math.min(4, t.json.slots)
		slots:SetPos(400-(numX*80)-10,ySize-10)
		slots:SetSlots(t.json.slots)
			
		for k,v in pairs(t.json.upgrades) do
			local item = manolis.popcorn.upgrades.FindUpgrade(t.json.type, v.class, v.level)
			if(item) then
				local upgrade = vgui.Create("ManolisItem", slots.slot[k])
				upgrade.t = item
				upgrade.t.icon = manolis.popcorn.upgrades.GetUpgradeIcon(t.json.type, v.class, v.level)
				upgrade:Go()
			end
		end
	end
	ySize = ySize + math.ceil((t.json.slots/4))*81
	self:SetSize(400,ySize)
end

function PANEL:CreditItem()
	local t = self.t
	local ySize = 10
	local xPos = 10+4
	self.Paint = function(self,w,h)
		surface.SetDrawColor(28,31,38,255)
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(4,4,w-8,h-8)
	end

	local icon = vgui.Create("ManolisImage", self)
	icon:SetImage('manolis/popcorn/icons/'..t.icon)
	icon:SetSize(77,77)
	icon:SetPos(400-77-10, ySize)

	icon.Paint = function(self,w,h)
		surface.SetDrawColor(255,255,255,255)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(manolis.popcorn.materialCache['item-bg'])
		surface.DrawTexturedRect(0,0,w,h)
		self:PaintAt( 0, 0, self:GetWide(), self:GetTall() )
	end


	local useModel = false
	if(!file.Exists("materials/manolis/popcorn/icons/"..self.t.icon, 'GAME')) then
		if(self.t.json and self.t.json.model) then
		
			local icon_ = vgui.Create("SpawnIcon", icon)
			icon_:SetSize(60,60)
			icon_:SetModel(self.t.json.model)
			icon_:SetPos(((77-60)/2),((77-60)/2))
			icon_.Paint = function(self,w,h)
				return
			end

			icon_.PaintOver = function()
				return
			end

			icon_:SetTooltip(false)

			icon_.OnMousePressed = function(s, key)
				icon:OnMousePressed(key)
				return false
			end

			icon_.OnMouseReleased = function(s, key)
				icon:OnMouseReleased(key)
				return false
			end

			icon_.PerformLayout = function(self)
				//icon:StretchToParent(0,0,0,0)
				return
			end

			icon_.OnCursorEntered =  function()
				icon:OnCursorEntered()
			end

			icon_.OnCursorExited =  function()
				icon:OnCursorExited()
			end

			useModel = true
		end
	end

	if(!useModel) then
		icon:SetImage('manolis/popcorn/icons/'..t.icon)
	end

	local name = vgui.Create("DLabel", self)
	name:SetFont("manolisItemInfoName")
	name:SetPos(xPos,ySize)
	name:SetTextColor(Color(255,255,255,255))
	name:SetText(t.name or DarkRP.getPhrase('unknown'))
	name:SizeToContents()


	ySize = ySize + 20
	local item = manolis.popcorn.creditShop.findItem(t.json.aid)
	local class
	if(item) then
		class = vgui.Create("DLabel", self)
		class:SetFont('manolisItemInfoName')
		class:SetPos(xPos,ySize)
		
		class:SetTextColor(Color(255,255,255,255))
		class:SetSize(290, 0)
		
		class:SetWrap(true)
		class:SetAutoStretchVertical(true)
		class:SetText(item.description)
	end

	timer.Simple(0, function()

		ySize = ySize + (IsValid(class) and class:GetTall() or 0)

		local level = vgui.Create("DLabel", self)
		level:SetFont("manolisItemInfoName")
		level:SetPos(xPos,ySize)
		level:SetTextColor(manolis.popcorn.levels.HasLevel(LocalPlayer(), t.level) and Color(255, 200, 0, 255) or Color(200,0,0))
		local text = t.json.crafted and DarkRP.getPhrase('crafted_by', t.json.crafted)..' '..DarkRP.getPhrase('vgui_level', t.level) or DarkRP.getPhrase('vgui_level2', t.level)
		level:SetText(text)
		level:SizeToContents()
		ySize = ySize + 20

		local value = vgui.Create("DLabel", self)
		value:SetFont("manolisItemInfoName")
		value:SetPos(xPos,ySize)
		value:SetTextColor(Color(255,255,255,255))
		value:SetText(DarkRP.getPhrase('value_x', DarkRP.formatMoney(tonumber(t.value))))
		value:SizeToContents()
		ySize = ySize + 20+10

		self:SetSize(400,ySize)
	end)

end

function PANEL:Other()
	local t = self.t
	local ySize = 10
	local xPos = 10+4
	self.Paint = function(self,w,h)
		surface.SetDrawColor(28,31,38,255)
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(4,4,w-8,h-8)
	end

	local icon = vgui.Create("ManolisImage", self)
	icon:SetImage('manolis/popcorn/icons/'..t.icon)
	icon:SetSize(77,77)
	icon:SetPos(400-77-10, ySize)

	icon.Paint = function(self,w,h)
		surface.SetDrawColor(255,255,255,255)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(manolis.popcorn.materialCache['item-bg'])
		surface.DrawTexturedRect(0,0,w,h)
		self:PaintAt( 0, 0, self:GetWide(), self:GetTall() )
	end


	local useModel = false
	if(!file.Exists("materials/manolis/popcorn/icons/"..self.t.icon, 'GAME')) then
		if(self.t.json and self.t.json.model) then
		
			local icon_ = vgui.Create("SpawnIcon", icon)
			icon_:SetSize(60,60)
			icon_:SetModel(self.t.json.model)
			icon_:SetPos(((77-60)/2),((77-60)/2))
			icon_.Paint = function(self,w,h)
				return
			end

			icon_.PaintOver = function()
				return
			end

			icon_:SetTooltip(false)

			icon_.OnMousePressed = function(s, key)
				icon:OnMousePressed(key)
				return false
			end

			icon_.OnMouseReleased = function(s, key)
				icon:OnMouseReleased(key)
				return false
			end

			icon_.PerformLayout = function(self)
				//icon:StretchToParent(0,0,0,0)
				return
			end

			icon_.OnCursorEntered =  function()
				icon:OnCursorEntered()
			end

			icon_.OnCursorExited =  function()
				icon:OnCursorExited()
			end

			useModel = true
		end
	end

	if(!useModel) then
		icon:SetImage('manolis/popcorn/icons/'..t.icon)
	end

	local name = vgui.Create("DLabel", self)
	name:SetFont("manolisItemInfoName")
	name:SetPos(xPos,ySize)
	name:SetTextColor(Color(255,255,255,255))
	name:SetText(t.name or DarkRP.getPhrase('unknown'))
	name:SizeToContents()


	ySize = ySize + 20

	local n = ''
	local classes = {}
	classes.shipment = DarkRP.getPhrase('shipment')
	classes.material = DarkRP.getPhrase('craft_mat')

	for k,v in pairs(classes) do
		if(k==t.type) then
			n=v
		end
	end

	if(n) then
		local class = vgui.Create("DLabel", self)
		class:SetFont('manolisItemInfoName')
		class:SetPos(xPos,ySize)
		class:SetTextColor(Color(255,255,255,255))
		class:SetText(n)
		class:SizeToContents()
		ySize = ySize + 20
	end

	local level = vgui.Create("DLabel", self)
	level:SetFont("manolisItemInfoName")
	level:SetPos(xPos,ySize)
	level:SetTextColor(manolis.popcorn.levels.HasLevel(LocalPlayer(), t.level) and Color(255, 200, 0, 255) or Color(200,0,0))
	local text = t.json.crafted and DarkRP.getPhrase('crafted_by', t.json.crafted)..' '..DarkRP.getPhrase('vgui_level', t.level) or DarkRP.getPhrase('vgui_level2', t.level)
	level:SetText(text)
	level:SizeToContents()
	ySize = ySize + 20

	local value = vgui.Create("DLabel", self)
	value:SetFont("manolisItemInfoName")
	value:SetPos(xPos,ySize)
	value:SetTextColor(Color(255,255,255,255))
	value:SetText(DarkRP.getPhrase('value_x', DarkRP.formatMoney(tonumber(t.value))))
	value:SizeToContents()
	ySize = ySize + 20+15

	self:SetSize(400,ySize)
end


function PANEL:Initiate()
	local t = self.t
	if(t.type=='blueprint') then
		self:Blueprint()
	elseif(t.type=='upgrade') then
		self:Upgrade()
	elseif(t.type=='armor') then
		self:Armor()
	elseif(t.type=='side' or t.type=='primary') then
		self:Weapon()
	elseif(t.type=='credit_item') then
		self:CreditItem()
	else
		self:Other()
	end
end
vgui.Register("ManolisItemInfo", PANEL, "Panel")