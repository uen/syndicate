AddCSLuaFile()
local PANEL = {}
local gangFrame = nil

local lastOpen = 0
local CUR = '$'
local tInit = true


function PANEL:Init()

	self:SetSize(650,535)

	self.Paint = function(panel,w,h)
		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(0,0,w,h)
	end
	gangFrame = self

	local tabs = vgui.Create('ManolisTabs', self)
	tabs:SetPos(0,0)
	tabs:SetSize(650,535)

	gangFrame.refresh = function(newid)
		if(!newid) then newid = manolis.popcorn.gangs.GetPlayerGang(LocalPlayer()) end
		tabs:Clear()
		if(0<newid) then

			if(!manolis.popcorn.gangs.gang.info) then return false end
			local general = vgui.Create('Panel')
			general:SetSize(650,700-95)

			local xpBar = vgui.Create('Panel', general)
			xpBar:SetSize(640, 20)
			xpBar:SetPos(5,5)
			xpBar.Paint = function(self,w,h)
				surface.SetDrawColor(35, 40, 48, 255)
				surface.DrawRect(0,0,w,h)
				
				surface.SetDrawColor(35-4, 40-4, 48-4, 255)
				surface.DrawRect(0,0,w*(manolis.popcorn.gangs.gang.info.xp / (15000*manolis.popcorn.gangs.gang.info.level^2)),h)
			end

			local xpLabel = vgui.Create('DLabel', general)
			xpLabel:SetPos(5, 5)
			xpLabel:SetSize(640, 20)
			xpLabel:SetText(string.Comma(manolis.popcorn.gangs.gang.info.xp)..' / '..string.Comma((15000*manolis.popcorn.gangs.gang.info.level^2)))
			xpLabel:SetFont('ManolisXPFontGang')
			xpLabel:SetTextColor(Color(255,255,255,255))
			xpLabel:SetContentAlignment(5)

			local secondIcon = vgui.Create('DImage', general)
			secondIcon:SetPos(6+2,30+2)
			secondIcon:SetSize(64,64)

			local icon = vgui.Create('DImage', general)
			icon:SetPos(6,30)
			icon:SetSize(64,64)

			icon:SetImage('manolis/popcorn/icons/gangs/'..manolis.popcorn.gangs.gang.info.logo..'.png')
			secondIcon:SetImage('manolis/popcorn/icons/gangs/'..manolis.popcorn.gangs.gang.info.logo..'.png')

			local c1 = split(manolis.popcorn.gangs.gang.info.color, ',')
			local c2 = split(manolis.popcorn.gangs.gang.info.secondcolor, ',')
			color1 = Color(c1[1], c1[2], c1[3])
			color2 = Color(c2[1], c2[2], c2[3])

			icon:SetImageColor(color1)
			secondIcon:SetImageColor(color2)

			local infoPanel = vgui.Create('ManolisAdvancedPanel', general)
			infoPanel:SetPos(6+2+64+5,30)
			infoPanel:SetPadding(-5)

			local nameOfGang = vgui.Create('DLabel')
			nameOfGang:SetText(manolis.popcorn.gangs.gang.info.name)
			nameOfGang:SetFont('manolisGangName')
			nameOfGang:SizeToContents()
			nameOfGang:SetPos(5,0)
			infoPanel:Add(nameOfGang)

			local points = vgui.Create('DLabel')
			local p = manolis.popcorn.gangs.gang.info.points == 1 and DarkRP.getPhrase('gang_level_point') or DarkRP.getPhrase('gang_level_points')
			points:SetText(DarkRP.getPhrase('gang_level_p', manolis.popcorn.gangs.gang.info.level, manolis.popcorn.gangs.gang.info.points, p))
			points:SetFont('manolisGangPoints')
			points:SetPos(5,nameOfGang:GetTall()-5) 
			points:SizeToContents()
			infoPanel:Add(points)

			local bank = vgui.Create('DLabel')
			bank:SetText(DarkRP.formatMoney(manolis.popcorn.gangs.gang.info.bank))
			bank:SetFont('manolisGangPoints')
			bank:SetPos(5,nameOfGang:GetTall()-5+points:GetTall()-5) 
			bank:SizeToContents()
			infoPanel:Add(bank)

			local buttons = vgui.Create('ManolisPanel', general)
			buttons:SetPos(395,30)
			buttons:SetSize(260,650)

			local refreshButton = vgui.Create('ManolisButton')
			refreshButton:SetText(DarkRP.getPhrase('refresh_view'))
			refreshButton:SetSize(250, 45)
			refreshButton.DoClick = function()
				RunConsoleCommand('ManolisPopcornRefreshGang')
			end
			buttons:Add(refreshButton)	

			local donateButton = vgui.Create('ManolisButton')
			donateButton:SetText(DarkRP.getPhrase('donate_to_gang'))
			donateButton:SetSize(250,45)
			donateButton.DoClick = function()	
				Manolis_StringRequest(DarkRP.getPhrase('donate_to_gang'), DarkRP.getPhrase('donate_to_gang_confirm'), '', DarkRP.getPhrase('donate'), function(v)
					RunConsoleCommand('ManolisPopcornGangDonate', v)
				end, function() end, DarkRP.getPhrase('donate'))
			end
			buttons:Add(donateButton)

			local inviteMember = vgui.Create('ManolisButton')
			inviteMember:SetText(DarkRP.getPhrase('gang_invite_confirm'))
			inviteMember:SetSize(250,45)
			inviteMember.DoClick = function()
				Manolis_PlayerSelect(DarkRP.getPhrase('gang_invite_confirm'), DarkRP.getPhrase('gang_invite_confirm'), 'Invite', function(player)
					if(player) then
						RunConsoleCommand('ManolisPopcornInviteToGang',player:UserID())
					end
				end)
			end

			buttons:Add(inviteMember)

			local leaveGang = vgui.Create('ManolisButton')
			leaveGang:SetText(DarkRP.getPhrase('gang_leave'))
			leaveGang:SetSize(250,45)
			leaveGang.DoClick = function()
				Manolis_Query(DarkRP.getPhrase('gang_leave_confirm'), DarkRP.getPhrase('gang_leave'), DarkRP.getPhrase('confirm'), function() RunConsoleCommand('ManolisPopcornLeaveGang') end, DarkRP.getPhrase('cancel'))
			end

			buttons:Add(leaveGang)

			tabs:AddTab(DarkRP.getPhrase('gang_general'), general)

			local gangMembers = vgui.Create('Panel')
			gangMembers:SetSize(650,535-45)

			local gangMemberList = vgui.Create('ManolisScrollPanel', gangMembers)
			gangMemberList:SetPos(5,5)
			gangMemberList:SetSize(650-10, 535-40-5-5)
	 
			local rMembers = function()
				if(gangMemberList.ClearPanel) then
					gangMemberList:ClearPanel()
				end

				table.SortByMember(manolis.popcorn.gangs.gang.members, 'rank', function(a,b) return b>a end)
				if(manolis.popcorn.gangs.gang.members) then
					for k,v in pairs(manolis.popcorn.gangs.gang.members) do
						local member = vgui.Create('ManolisGangMemberPanel')
						member:Go(v.rpname, v.uid, manolis.popcorn.gangs.GetRank(v.rank))
						gangMemberList:Add(member)
						
					end
				end
			end

			rMembers()

			hook.Add('manolis:GangRankUpdate', 'manolis:GangRankUpdateRefreshF4', function(player)
				for k,v in pairs(gangMemberList:GetItems()) do
					if(player.player == v.steam) then
						v.rank:SetText(manolis.popcorn.gangs.GetRank(player.rank))
						v.rank:SizeToContents()
					end
				end
			end)

			hook.Add('manolis:GangMemberRefresh', 'manolis:GangMemberUpdateRefreshF4', function()
				rMembers()
			end)

			tabs:AddTab(DarkRP.getPhrase('gang_members'), gangMembers)

			// Rivals:

			local rivals = vgui.Create('Panel')
			rivals:SetSize(650,700-90-5)

			local addRival = vgui.Create('ManolisButton', rivals)
			addRival:SetPos(5,5)
			addRival:SetText(DarkRP.getPhrase('gang_add_rival'))
			local rivalPanel = false
			addRival.DoClick = function()
				if(!rivalPanel) then
					local addRivalPanel = vgui.Create('ManolisFrame')
					addRivalPanel:SetText(DarkRP.getPhrase('gang_rival_add'))
					addRivalPanel:SetRealSize(635,45+50+5)
					addRivalPanel:Center()
					addRivalPanel:SetBackgroundBlur( true )
					addRivalPanel:SetBackgroundBlurOverride( true )
					addRivalPanel:MakePopup()

					local gangs = vgui.Create('Panel',addRivalPanel)
					gangs:SetSize(630,0)
					gangs:SetPos(5,45+50+5)

					local searchPadHack = vgui.Create('ManolisClearPanel', addRivalPanel)
					searchPadHack:SetSize(625,50)
					searchPadHack:SetPos(5,45)

					local searchBox = vgui.Create('ManolisTextEntry', addRivalPanel)
					searchBox:SetSize(615,50)
					searchBox:SetPos(10,45)

					searchBox.OnEnter = function()
						net.Start('ManolisPopcornSearchGangs')
							net.WriteString(searchBox:GetValue())
						net.SendToServer()

						searchBox:RequestFocus()
					end

					local noGangText = {}

					net.Receive('ManolisPopcornSearchGangs', function()
						local g = net.ReadTable()
						for k,v in pairs(gangs:GetChildren()) do
							v:Remove()
						end
						local y = 0

						local rivals = {}
						for k,v in pairs(g) do
							local rival = vgui.Create('ManolisRivalPanel', gangs)
							rival:Go(v.id, v.name, v.logo, v.color or '0,0,0', v.secondcolor or '0,0,0', v.level or 1, v.kills or 0, v.stashes or 0, v.truce or false)
							rival.gData = v
							table.insert(rivals, rival)
							rival:SetPos(0,k*95-95)

							rival:Alternative()

							rival.addRival.DoClick = function()
								Manolis_Query(DarkRP.getPhrase('gang_become_rivals',v.name), DarkRP.getPhrase('confirm'), DarkRP.getPhrase('confirm'), function()
									RunConsoleCommand('ManolisPopcornRivalGang', v.id)
									addRivalPanel:Remove()
									addRivalPanel = nil
									rivalPanel = nil
								end, DarkRP.getPhrase('cancel'), function()

								end)
							end
						end
	 
						if(#g==0) then
							noGangText = vgui.Create('DLabel', gangs)
							gangs:SetTall(35)
							noGangText:SetTextColor(Color(255,255,255,255))
							noGangText:SetFont('manolisHeaderFont')
							noGangText:SetText(DarkRP.getPhrase('gang_no'))
							noGangText:SetSize(625,40)
							noGangText:SetContentAlignment(5)
							noGangText:SetPos(0,5)
							addRivalPanel:SetTall(45+50+5+60)
						else
							if(noGangText.Remove) then
								noGangText:Remove()
							end

							if(#g>2) then
								addRivalPanel:SetTall(45+50+5+(#g*90)+15)
								gangs:SetSize(625,#g*90+20)
							else
								addRivalPanel:SetTall(45+50+(#g*90)+15)
								gangs:SetSize(625,#g*90+20)
							end

							if(#g==1) then
								addRivalPanel:SetTall(45+50-5+(#g*90)+15)
								gangs:SetSize(625,#g*90+20)
							end
							addRivalPanel:Center()

						end
					end)

		
					addRivalPanel.header.closeButton.DoClick = function()
						addRivalPanel:SetVisible(false)	
						addRivalPanel:Remove()
						rivalPanel = nil
					end

					rivalPanel = addRivalPanel
				end
			end

			local rivalList = vgui.Create( 'ManolisScrollPanel', rivals)
			rivalList:SetPos(5,50)
			rivalList:SetSize(650-10, 535-50-10-40+5)

			tabs:AddTab(DarkRP.getPhrase('gang_rivals'), rivals)

			// Shop


			local shop = vgui.Create('Panel')
			shop:SetSize(650,535-40)

			local shopTab = vgui.Create( 'ManolisScrollPanel', shop)
			shopTab:SetPos(5,5)
			shopTab:SetSize(650-10, 535-10-40)

			table.SortByMember(manolis.popcorn.gangs.shop.items, 'level', true)
			local showPermissions = ((manolis.popcorn.gangs.GetPlayerGangRank(LocalPlayer()) or 0) <= 1)

			gangFrame.refreshPermissions = function()
		        if(manolis.popcorn.temp.ignorePermissionGangRefresh) then 
		        	manolis.popcorn.temp.ignorePermissionGangRefresh = false
		        	return 
		        end
				shopTab:ClearPanel()
				for k,v in pairs(manolis.popcorn.gangs.shop.items) do
				
					local item = vgui.Create('ManolisGangShopPanel')
					local permissions = {}
					if(manolis.popcorn.gangs.shop.permissions[manolis.popcorn.config.hashFunc(v.name)]) then
						permissions = manolis.popcorn.gangs.shop.permissions[manolis.popcorn.config.hashFunc(v.name)]
					end


					item:Go(manolis.popcorn.config.hashFunc(v.name), v.name, v.model, v.price, v.level, v.description, showPermissions, permissions)
					shopTab:Add(item)
				end
			end

			gangFrame.refreshPermissions()

			tabs:AddTab(DarkRP.getPhrase('gang_shop'), shop)


			local upgrades = vgui.Create('Panel')
			upgrades:SetSize(650,535-40)

			local upgradeList = vgui.Create('ManolisScrollPanel', upgrades)
			upgradeList:SetPos(5,5)
			upgradeList:SetSize(650-10, 535-10-40)

			local upgradeLevels = {}

			table.SortByMember(manolis.popcorn.gangs.upgrades.upgrades, 'level', true)

			for k,v in pairs(manolis.popcorn.gangs.upgrades.upgrades) do
				local upgrade = vgui.Create('ManolisGangUpgradePanel')
				upgrade:Go(manolis.popcorn.config.hashFunc(v.uiq), v.name, v.icon, v.prices, v.uiq,manolis.popcorn.gangs.gang.upgrades[v.uiq] or 0,v.description)
				upgradeList:Add(upgrade)
			end

			net.Receive('ManolisPopcornGangUpgradeChange', function()
				local upgrades = net.ReadTable()
	
				for k,v in pairs(upgrades) do
					manolis.popcorn.gangs.gang.upgrades[k] = v
				end
				for k,v in pairs(upgradeList:GetItems()) do 

					for a,b in pairs(upgrades) do
						if(v.uiq == a) then
							
							v:SetLevel(b,v.t)
						end
					end
				end
			end)

			tabs:AddTab(DarkRP.getPhrase('gang_upgrades'), upgrades)

			local refreshRivals = function()
				if(rivalList and rivalList.ClearPanel) then
					rivalList:ClearPanel()
				end

				if(manolis.popcorn.gangs.gang.rivals) then
					local rivals = {}
					for k,v in pairs(manolis.popcorn.gangs.gang.rivals) do
						local rival = vgui.Create('ManolisRivalPanel')
						rival:Go(v.id, v.name, v.logo, v.color or '0,0,0', v.secondcolor or '0,0,0', v.level or 1, v.kills or 0, v.stashes or 0, v.truce or false)
						rival.gData = v
						table.insert(rivals,rival)
						rivalList:Add(rival)
					end

					manolis.popcorn.gangs.rivalPanels = rivals
				end
			end

			refreshRivals()
			hook.Add('manolis:GangUpdate', 'manolis:UpdateGangRivalPanel', function()
				refreshRivals()
			end)

		else

			local createGang = vgui.Create('Panel')
			createGang:SetSize(650,700-140)

			local y = 60

			local editPanel = vgui.Create('EditablePanel', createGang)
			editPanel:SetPos(0,0)
			editPanel:SetSize(650,360)

			local preview = vgui.Create('ManolisRivalPanel', editPanel)
			preview:Alternative2()
			local logoSelection = 1

			preview:Go(0,DarkRP.getPhrase('gang_name'), manolis.popcorn.gangs.logos[1], Color(255,255,255), Color(0,0,0))
			preview:SetPos(5,y)
			preview.name:SetWide(300)
			y=y+50

			local createGangLabel = vgui.Create('DLabel', editPanel)
			createGangLabel:SetText(DarkRP.getPhrase('create_new_gang'))
			createGangLabel:SetPos(10,10)
			createGangLabel:SetTextColor(Color(255,255,255,255))
			createGangLabel:SetFont('manolisBigC')
			createGangLabel:SizeToContents()
			y=y+60

			local gangName = vgui.Create('DLabel', editPanel)
			gangName:SetText(DarkRP.getPhrase('gang_name'))
			gangName:SetTextColor(Color(255,255,255,255))
			gangName:SetFont('manolisC')
			gangName:SetSize(90, 30)
			gangName:SetPos(10,y)
			gangName:SetContentAlignment(4)

			local gangNameEntry = vgui.Create('ManolisTextEntry', editPanel)

			gangNameEntry:SetPos(130-25,y)
			gangNameEntry:SetSize(200,30)
			gangNameEntry:SetText('')
			gangNameEntry:SetFont('manolisItemInfoName')

			gangNameEntry.OnChange = function(self)
				preview.name:SetText(self:GetValue())
			end
			y=y+40

			local gangPassword = vgui.Create('DLabel', createGang)
			gangPassword:SetText(DarkRP.getPhrase('gang_pass'))
			gangPassword:SetTextColor(Color(255,255,255,255))
			gangPassword:SetFont('manolisC')
			gangPassword:SetSize(90, 30)
			gangPassword:SetPos(10,y)
			gangPassword:SetContentAlignment(4)

			local gangPasswordEntry = vgui.Create('ManolisTextEntry', editPanel)
			gangPasswordEntry:SetPos(130-25,y)
			gangPasswordEntry:SetSize(200,30)
			gangPasswordEntry:SetText('')
			gangPasswordEntry:SetFont('manolisItemInfoName')
			gangPasswordEntry:SetEditable(true)
			gangPasswordEntry:SetTooltip(DarkRP.getPhrase('gang_pass_tip'))
			y=y+40

			local gangC = vgui.Create('DLabel', editPanel)
			gangC:SetText(DarkRP.getPhrase('color'))
			gangC:SetTextColor(Color(255,255,255,255))
			gangC:SetFont('manolisC')
			gangC:SetSize(90, 30)
			gangC:SetPos(10,y)
			gangC:SetContentAlignment(4)

			local defColor = Color(35, 40, 48, 255)

			local gangColor1 = vgui.Create( 'ManolisColorButton', editPanel )
			gangColor1:SetPos(130-25, y)
			gangColor1:SetSize( 200, 30)
			gangColor1:SetColor(defColor)

			local cSelect
			gangColor1.DoClick = function()
				if(cSelect and cSelect:IsVisible()) then return false end
				cSelect = vgui.Create('ManolisColorPalette')	
				cSelect.OnValueChanged = function(self,col)
					gangColor1:SetColor(col)
					preview:SetFirstColor(col)
					self:Remove()
					cSelect = nil
				end

				local a,b = gui.MousePos()
				cSelect:SetPos(a,b)
				cSelect:MakePopup()
				cSelect:SetButtonSize(20)
				
			end
			y=y+40

			local gangC2 = vgui.Create('DLabel', editPanel)
			gangC2:SetText(DarkRP.getPhrase('background'))
			gangC2:SetTextColor(Color(255,255,255,255))
			gangC2:SetFont('manolisC')
			gangC2:SetSize(90, 30)
			gangC2:SetPos(10,y)
			gangC2:SetContentAlignment(4)

			local gangColor2 = vgui.Create( 'ManolisColorButton', editPanel )
			gangColor2:SetPos( 130-25, y)
			gangColor2:SetSize( 200, 30)
			gangColor2:SetColor(defColor)

			local cSelect2
			gangColor2.DoClick = function()
				if(cSelect2 and cSelect2:IsVisible()) then return false end
				cSelect2 = vgui.Create('ManolisColorPalette')	
				cSelect2.OnValueChanged = function(self,col)
					gangColor2:SetColor(col)
					preview:SetSecondColor(col)
					self:Remove()
					cSelect2 = nil
				end

				local a,b = gui.MousePos()
				cSelect2:SetPos(a,b)
				cSelect2:MakePopup()
				cSelect2:SetButtonSize(20)
				
			end
			y = y + 40

			local logo = vgui.Create('DLabel', editPanel)
			logo:SetText(DarkRP.getPhrase('logo'))
			logo:SetTextColor(Color(255,255,255,255))
			logo:SetFont('manolisC')
			logo:SetSize(90, 30)
			logo:SetPos(10,y)
			logo:SetContentAlignment(4)

			local logo2 = vgui.Create( 'ManolisButton', editPanel )
			logo2:SetPos( 130-25, y)
			logo2:SetSize( 200, 30)
			logo2:SetText('')
			logo2.Paint = function(self,w,h)
				surface.SetDrawColor(defColor)
				surface.DrawRect(0,0,w,h)
			end

			logo2.DoClick = function()
				logoSelection = next(manolis.popcorn.gangs.logos, logoSelection)
				if(!logoSelection) then logoSelection = 1 end
				preview:SetLogo(manolis.popcorn.gangs.logos[logoSelection])
			end

			preview.createGang.DoClick = function()
				if(gangNameEntry:GetValue()=='') then
					return
				end
				Manolis_Query(DarkRP.getPhrase('gang_create_confirm', gangNameEntry:GetValue(), DarkRP.formatMoney(manolis.popcorn.config.gangCreateCost)), DarkRP.getPhrase('create_gang'), DarkRP.getPhrase('create'), function()
				
					local c1 = gangColor1:GetColor()
					local c2 = gangColor2:GetColor()
					c1 = c1.r..','..c1.g..','..c1.b
					c2 = c2.r..','..c2.g..','..c2.b

					RunConsoleCommand('ManolisPopcornCreateGang', gangNameEntry:GetValue(), gangPasswordEntry:GetValue(), manolis.popcorn.gangs.logos[logoSelection],c1, c2)
				end, DarkRP.getPhrase('cancel'), function() end)
			end

			tabs:AddTab(DarkRP.getPhrase('create_gang'), createGang)

			local gangInvites = vgui.Create('Panel')
			gangInvites:SetSize(650,700-95)	

			local gangInvitesList = vgui.Create('ManolisScrollPanel', gangInvites)
			gangInvitesList:SetPos(5,5)
			gangInvitesList:SetSize(650-10, 535-50)

			local refreshInvites = function()
				gangInvitesList:ClearPanel()
				if(manolis.popcorn.gangs.invites) then
					for k,v in pairs(manolis.popcorn.gangs.invites or {}) do
						local gang = vgui.Create('ManolisRivalPanel')
						gang:Invite(v.id, v.name, v.level,v.logo,v.color,v.secondcolor)
						gang.addRival.DoClick = function()
							Manolis_Query(DarkRP.getPhrase('gang_join_confirm', v.name), DarkRP.getPhrase('gang_join'), DarkRP.getPhrase('gang_j'), function()
								RunConsoleCommand('ManolisPopcornJoinGang', v.id)
							end, DarkRP.getPhrase('cancel'), function() end)
						end

						gang.decline.DoClick = function()
							Manolis_Query('Are you sure you want to decline this invite?',DarkRP.getPhrase('gang_decline'),DarkRP.getPhrase('confirm'),function()
								RunConsoleCommand('ManolisPopcornDeclineInvite',v.id)
							end, DarkRP.getPhrase('cancel'), function() end)
						end

						gangInvitesList:Add(gang)
					end
				end
			end
			refreshInvites()

			hook.Add('manolis:GangInviteUpdate', 'manolis:UpdateInvitesOnPanel', function(invites)
				refreshInvites()
			end)

			tabs:AddTab(DarkRP.getPhrase('gang_invites'),gangInvites)

			local y = 0

			local recoverGang = vgui.Create('Panel')
			recoverGang:SetSize(650,700-140)

			local editPanel = vgui.Create('EditablePanel', recoverGang)
			editPanel:SetPos(0,0)
			editPanel:SetSize(650,550)

			local createGangLabel = vgui.Create('DLabel', editPanel)
			createGangLabel:SetText(DarkRP.getPhrase('recover_gang'))
			createGangLabel:SetPos(10,10)
			createGangLabel:SetTextColor(Color(255,255,255,255))
			createGangLabel:SetFont('manolisBigC')
			createGangLabel:SizeToContents()
			y=y+60

			local gangName = vgui.Create('DLabel', editPanel)
			gangName:SetText(DarkRP.getPhrase('gang_name'))
			gangName:SetTextColor(Color(255,255,255,255))
			gangName:SetFont('manolisC')
			gangName:SetSize(90, 30)
			gangName:SetPos(30,y)
			gangName:SetContentAlignment(4)

			local gangNameEntry = vgui.Create('ManolisTextEntry', editPanel)
			gangNameEntry:SetPos(130,y)
			gangNameEntry:SetSize(200,30)
			gangNameEntry:SetText('')
			gangNameEntry:SetFont('manolisItemInfoName')
			y=y+40

			local gangPassword = vgui.Create('DLabel', editPanel)
			gangPassword:SetText(DarkRP.getPhrase('gang_pass'))
			gangPassword:SetTextColor(Color(255,255,255,255))
			gangPassword:SetFont('manolisC')
			gangPassword:SetSize(90, 30)
			gangPassword:SetPos(30,y)
			gangPassword:SetContentAlignment(4)

			local gangPasswordEntry = vgui.Create('ManolisTextEntry', editPanel)
			gangPasswordEntry:SetPos(130,y)
			gangPasswordEntry:SetSize(200,30)
			gangPasswordEntry:SetText('')
			gangPasswordEntry:SetFont('manolisItemInfoName')

			gangNameEntry.OnChange = function(self)
				preview.name:SetText(self:GetValue())
			end
			y=y+40

				
			local createButton = vgui.Create('ManolisButton', editPanel)
			createButton:SetPos(130+200-101,y)
			createButton:SetText(DarkRP.getPhrase('recover_gang2'))

			createButton.DoClick = function()
				RunConsoleCommand('ManolisPopcornRecoverGang',gangNameEntry:GetValue(), gangPasswordEntry:GetValue())
			end

			tabs:AddTab(DarkRP.getPhrase('recover_gang'),recoverGang)
		end
	end

	hook.Add('DarkRPVarChanged', 'gangFrameRefreshF', function(ply,var,old,new)
		if(ply==LocalPlayer()) then
			if(!tInit) then
				if(var=='gang') then
					if(new==0) then
						gangFrame.refresh(0)
					end
				end
			else
				tInit = false
			end
		end
	end)


	hook.Add('manolis:GangUpdate', 'gangFrameRefreshFSecond', function(ply,var,old,new)
		gangFrame.refresh(1)
	end)

	self.refresh()
	manolis.popcorn.f4.panel = self
end
vgui.Register( 'manolisF4TabGangs', PANEL, 'DPanel')