AddCSLuaFile()

local PANEL = {}

function PANEL:Init()
	self:SetSize(650,535)
	self.Paint = function(panel,w,h)
		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(0,0,w,h)
	end

	local infos = {
		{name=DarkRP.getPhrase('total_kills'), val = 0, color=Color(250,50,50), type='kills'},
		{name=DarkRP.getPhrase('total_deaths'), val = 0, color=Color(67,200,60), type='deaths'},
		{name=DarkRP.getPhrase('joins'), val = 0, color=Color(82,185,233), type='joins'},
		{name=DarkRP.getPhrase('levelx'), val = 1, color=Color(147,42,182), type='level'},
	}

	local infoText = {}

	local infoBoxes = vgui.Create('Panel', self)
	infoBoxes:SetSize((650/4)*#infos,530)
	infoBoxes:SetPos(645/2 - (#infos*(650/4))/2,5)

	for i,v in pairs(infos) do
		local box = vgui.Create('Panel',infoBoxes)

		local xMod = 0
		if(i==4) then xMod = 5 end

		box:SetSize(620/#infos+xMod,70)
		box:SetPos(10+((i-1)*5) +((620/#infos)*(i-1))-3,0)
		box.Paint = function(self,w,h)
			surface.SetDrawColor(35,40,48,255)
			surface.DrawRect(0,0,w,h)
		end

		local yMod = 3

		local am = vgui.Create('DLabel',box)
		am:SetSize(box:GetWide(),25)
		am:SetPos(0,10+yMod)
		am:SetText(v.val)
		am:SetFont('manolisName')
		am:SetColor(Color(209,209,209))
		am:SetContentAlignment(5)
		table.insert(infoText, {type=v.type, label=am})

		local des = vgui.Create('DLabel', box)
		des:SetSize(box:GetWide(70-30),20)
		des:SetPos(0,5+am:GetTall()+5+yMod)
		des:SetText(v.name)
		des:SetFont('manolisNameSmall')
		des:SetColor(Color(209,209,209))
		des:SetContentAlignment(5)
	end

	local refreshInfo = function()
		local info = LocalPlayer():getDarkRPVar('playerstatsmv') or {}
		for k,v in pairs(infoText) do
			if(info[v.type]) then
				v.label:SetText(info[v.type])
			end
		end
	end

	refreshInfo()


	hook.Add('DarkRPVarChanged', 'characterFrameRefreshF', function(ply,var,old,new)
		if(ply==LocalPlayer()) then
			if(var=='playerstatsmv') then
				refreshInfo()
			end
		end
	end)

	local padding = vgui.Create('Panel', self)
	padding:SetSize(645,530)
	padding:SetPos(5,5+75)

	local i1 = vgui.Create('Panel', padding)
	i1.Paint = function(self,w,h)
		surface.SetDrawColor(35,40,48,255)
		surface.DrawRect(0,0,w,h)
	end

	i1:SetSize(315, 10+64+10)
	local aSize = 64
	local avatar = vgui.Create('ManolisAvatar', i1)
	avatar:SetSize(aSize,aSize)
	avatar:SetPlayer(LocalPlayer(),128)
	avatar:SetPos(10, 10)

	local yMod = 6
	local name = vgui.Create('DLabel', i1)
	name:SetText(LocalPlayer():Name())
	name:SetFont('manolisAction')
	name:SetPos(64+10+10,10+yMod)
	name:SizeToContents()
	name:SetColor(Color(209,209,209))

	local cash = vgui.Create('DLabel',i1)
	cash:SetText(DarkRP.formatMoney(LocalPlayer():getDarkRPVar('money')))
	cash:SetFont('manolisAction2')
	cash:SetPos(64+10+10,10+name:GetTall()+yMod)
	cash:SizeToContents()
	cash:SetColor(Color(209,209,209))

	local b = vgui.Create('ManolisButton', padding)
	b:SetPos(0,90)
	b:SetText(DarkRP.getPhrase('equipment'))
	b.DoClick = function()
		manolis.popcorn.f4.closeF4Menu()
		manolis.popcorn.equipment.toggle()
	end

	local c = vgui.Create('ManolisButton', padding)
	c:SetPos(b:GetWide()+6,90)
	c:SetText(DarkRP.getPhrase('inventory'))
	c.DoClick = function()
		manolis.popcorn.f4.closeF4Menu()
		manolis.popcorn.inventory.toggle()
	end

	local d = vgui.Create('ManolisButton', padding)
	d:SetPos(b:GetWide()+c:GetWide()+12,90)
	d:SetText(DarkRP.getPhrase('server_info'))
	d.DoClick = function()
		manolis.popcorn.f4.closeF4Menu()
		manolis.f1.toggleF1Menu()
	end

	local a_ = vgui.Create('Panel', padding)
	a_:SetSize(315,320)
	a_:SetPos(0,90+6+d:GetTall())

	a_.Paint = function(self,w,h)
		surface.SetDrawColor(35,40,48,255)
		surface.DrawRect(0,0,w-16,h)
	end

	local currentAffects = vgui.Create('ManolisScrollPanel', a_)
	currentAffects:SetPos(5, 0)
	currentAffects:SetSize(310, 320)

	local title = vgui.Create('DLabel')
	title:SetWide(310,20)
	title:SetText(DarkRP.getPhrase("active_items"))
	title:SetFont("manolisAffectsTitle")
	currentAffects:Add(title)
	local x,y = title:GetPos()
	title:SetPos(x+6,y+8)


	local affects = vgui.Create('DLabel')
	affects:SetPos(5+10,5)
	affects:SetSize(300,310)
	affects:SetWrap(true)
	affects:SetContentAlignment(7)
	
	affects:SetAutoStretchVertical(true)
	affects:SetFont("manolisItemCreditDescription")
	currentAffects:Add(affects)
	local x,y = affects:GetPos()
	affects:SetPos(x+5, y+8)
	


	local refreshAffects = function()
		affects:SetText('')
		local affect = LocalPlayer():getDarkRPVar('creditShopActiveItems')
		local str = ''
		for k,v in pairs(affect or {}) do
			local credit = manolis.popcorn.creditShop.findItem(k)
			if(credit) then
				str = str .. credit.name..': '..(credit.effectStr and credit.effectStr((credit.affectLevels and credit.affectLevels[v.level]) or 1))..'\n'
			end
		end

		if(str=='') then
			str=DarkRP.getPhrase("no_active_items")
		end

		affects:SetText(str)
	end

	refreshAffects()
	
	hook.Add('DarkRPVarChanged', 'characterFrameRefreshCreditAffects', function(ply,var,old,new)
		if(ply==LocalPlayer()) then
			if(var=='creditShopActiveItems') then
				refreshAffects()
			end
		end
	end)





	local actionList = vgui.Create('ManolisPanel', padding)
	actionList:SetPos(640-10-310,0)
	actionList:SetSize(320,50)

	local actions = vgui.Create('ManolisCategory')
	actions:SetSize(320,35)
	actions:Go(DarkRP.getPhrase('actions'))
	actions.expandButton:Remove()

	local action = vgui.Create('ManolisComboBox')
	action:SetSize(320,35)
	action:SetValue(DarkRP.getPhrase('action_select'))

	local ac = {
		{
			name = DarkRP.getPhrase('party_invite'), 
			DoClick = function() 
				Manolis_PlayerSelect(DarkRP.getPhrase('party_invite'), DarkRP.getPhrase('party_invite_confirm'), DarkRP.getPhrase('party_inv'), function(player)
					if(player) then
						RunConsoleCommand('ManolisPopcornAddParty',player:UserID())
					end
				end)
			end
		},
		{
			name = DarkRP.getPhrase('drop_money'),
			DoClick = function()
				Manolis_StringRequest(DarkRP.getPhrase('drop_money'), DarkRP.getPhrase('drop_money_confirm'), '', 'Drop', function(v)
					RunConsoleCommand('say','/dropmoney '..v)
				end, function() end, DarkRP.getPhrase('drop_money'))
			end
		},
		{
			name = DarkRP.getPhrase('give_money'),
			DoClick = function()
				Manolis_StringRequest(DarkRP.getPhrase('give_money'), DarkRP.getPhrase('give_money_confirm'), '', 'Give', function(v)
					RunConsoleCommand('say','/give '..v)
				end, function() end, DarkRP.getPhrase('give_money'))
			end
		},
		{
			name = DarkRP.getPhrase('sell_buildings'),
			DoClick = function()
				Manolis_Query(DarkRP.getPhrase('sell_buildings_confirm'), DarkRP.getPhrase('confirm'), DarkRP.getPhrase('confirm'),function() RunConsoleCommand("say", "/unownalldoors") end, DarkRP.getPhrase('cancel'))
			end
		},
		{
			name = DarkRP.getPhrase('view_gamemode_info'),
			DoClick = function()
				RunConsoleCommand("SyndicateGamemodeInfo")
				// I kindly request that you do not remove/change this 
			end
		}
	}

	for k,v in pairs(ac) do
		action:AddChoice(v.name)
	end

	action.OnSelect = function(p,index,val)
		if(ac[index]) then
			ac[index].DoClick()
		end

		action:SetValue(DarkRP.getPhrase('action_select'))
	end
	
	actionList:Add(actions,0)
	actionList:Add(action,0)

end
vgui.Register( "manolisF4TabCharacter", PANEL, "DPanel" )
