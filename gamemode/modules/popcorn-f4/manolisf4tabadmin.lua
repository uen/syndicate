AddCSLuaFile()
local PANEL = {}

function PANEL:Init()
	self:SetSize(650,535)

	self.Paint = function(panel,w,h)
		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(0,0,w,h)
	end

	local tabs = vgui.Create("ManolisTabs", self)
	tabs:SetPos(0,0)
	tabs:SetSize(650,540)

	local territories = vgui.Create("Panel")
	territories:SetSize(650,535-45)
	tabs:AddTab(DarkRP.getPhrase('territories'), territories)

	local addTerritory = vgui.Create("ManolisButton", territories)
	addTerritory:SetPos(5,5)
	addTerritory:SetText(DarkRP.getPhrase('new_territory'))

	local addTerritoryF
	addTerritory.DoClick = function()
		if(addTerritoryF and addTerritoryF:IsVisible()) then return end
		addTerritoryF = vgui.Create("ManolisFrame")
		addTerritoryF:SetText(DarkRP.getPhrase('new_territory'))
		addTerritoryF:SetRealSize(300+10+10,170)
		addTerritoryF:Center()
		addTerritoryF:SetBackgroundBlur(true)
		addTerritoryF:SetBackgroundBlurOverride(true)

		local nameOfTerritory = vgui.Create("DLabel", addTerritoryF)
		nameOfTerritory:SetFont("manolisHeaderFont")
		nameOfTerritory:SetText(DarkRP.getPhrase('name_territory'))
		nameOfTerritory:SizeToContents()
		nameOfTerritory:SetPos(10,45+5)
		addTerritoryF:MakePopup()

		local okay

		searchBox = vgui.Create("ManolisTextEntry", addTerritoryF)
		searchBox:SetSize(300,30)
		searchBox:SetPos(10,45+5+nameOfTerritory:GetTall()+10)
		searchBox.OnEnter = function()
			okay.DoClick()
		end

		searchBox:RequestFocus()

		okay = vgui.Create("ManolisButton", addTerritoryF)
		okay:SetText(DarkRP.getPhrase('create'))
		okay:SetPos(300+10+10-101-10,45+5+nameOfTerritory:GetTall()+10+searchBox:GetTall()+10)
		okay.DoClick = function()
			RunConsoleCommand("ManolisPopcornNewTerritory",searchBox:GetValue())
				addTerritoryF:Close()
		end
	end



	local territoryList = vgui.Create( "ManolisScrollPanel", territories)
	territoryList:SetPos(5,50)
	territoryList:SetSize(650-10, 535-50-10-35)

	local rTerritories = function()
		for k,v in pairs(manolis.popcorn.gangs.territories.territories) do
			local territory = vgui.Create("ManolisItemPanel")
			territory:Go(v.id, v.name, Material("manolis/popcorn/icons/gangs/4.png"), DarkRP.getPhrase('territory_map', v.map), {{label=DarkRP.getPhrase('territory_remove', v.name), DoClick = function()	
				Manolis_Query(DarkRP.getPhrase('territory_remove_confirm',v.name), DarkRP.getPhrase('confirm'),DarkRP.getPhrase('confirm'),function() RunConsoleCommand("ManolisPopcornRemoveTerritory", v.id) end, DarkRP.getPhrase('cancel'))
			end}, {label=DarkRP.getPhrase('territory_locations'), DoClick = function()

				local vL = vgui.Create("ManolisFrame")
				vL:SetRealSize(650, 500)
				vL:Center()
				vL:SetText(DarkRP.getPhrase('territory_locations_view'))
				vL:SetBackgroundBlur( true )
				vL:SetBackgroundBlurOverride( true )
				vL:MakePopup()
				vL:SetZPos(2000)
	

				local scrollPanel = vgui.Create("ManolisScrollPanel", vL)
				scrollPanel:SetSize(650-10, 500-50)
				scrollPanel:SetPos(5,45)

				for ka,va in pairs(v.locations) do
					local item = vgui.Create("ManolisItemPanel")

					item:Go(va.id, v.name..' ('..va.id..')', Material("manolis/popcorn/icons/gangs/4.png"), DarkRP.getPhrase('territory_position',va.x,va.y,va.z), {{label=DarkRP.getPhrase('territory_location_remove'), DoClick=function()
						RunConsoleCommand("ManolisPopcornRemoveTerritoryLocation", va.id)
						vL:Close()
					end}})

					scrollPanel:Add(item)

				end


			end}, {label=DarkRP.getPhrase('territory_location_new'), DoClick = function() Manolis_Query(DarkRP.getPhrase('territory_location_confirm',v.name), DarkRP.getPhrase('confirm'), DarkRP.getPhrase('confirm'),function() RunConsoleCommand("ManolisPopcornSaveTerritoryLocation", v.id) end, "Cancel") end}})
			territoryList:Add(territory)
		end
	end

	hook.Add("manolis:TerritoryUpdate", "manolis:RefreshF4Territories", function()
		territoryList:ClearPanel()
		rTerritories()
	end)
		
	rTerritories()

	local positions = vgui.Create("Panel")
	positions:SetSize(650,535-45)
	tabs:AddTab(DarkRP.getPhrase('positions'), positions)

	local positionList = vgui.Create( "ManolisScrollPanel", positions)
	positionList:SetPos(5,5)
	positionList:SetSize(650-10, 535-50-10-35+45)

	for k,v in pairs(manolis.popcorn.positions.positions) do
		local position = vgui.Create("ManolisItemPanel")
		position:Go(v.name, v.name, Material("manolis/logo.png"), v.ent, {{label="Set Position", DoClick=function()
					Manolis_Query(DarkRP.getPhrase('positions_set',v.name), DarkRP.getPhrase('confirm'),DarkRP.getPhrase('confirm'),function() RunConsoleCommand("ManolisPopcornSetPosition", manolis.popcorn.config.hashFunc(v.name)) end, "Cancel")end}})


		position:SetModel(v.model)
		positionList:Add(position)
	end

	local buildings = vgui.Create("Panel")
	buildings:SetSize(650,535-45)
	tabs:AddTab(DarkRP.getPhrase('buildings'), buildings)

	local addBuildingButton = vgui.Create("ManolisButton", buildings)
	addBuildingButton:SetPos(5,5)
	addBuildingButton:SetText(DarkRP.getPhrase('buildings_new'))
	local addBuilding
	addBuildingButton.DoClick = function()
			if(addBuilding and addBuilding:IsVisible()) then return false end		
			addBuilding = vgui.Create("ManolisFrame")
			addBuilding:SetText(DarkRP.getPhrase('buildings_new2'))
			addBuilding:SetRealSize(300+10+10,45+50+5+25+45)
			addBuilding:Center()
			addBuilding:SetBackgroundBlur( true )
			addBuilding:SetBackgroundBlurOverride(true)
			addBuilding:MakePopup()
			local nameOfBuilding = vgui.Create("DLabel", addBuilding)
			nameOfBuilding:SetFont("manolisHeaderFont")
			nameOfBuilding:SetText(DarkRP.getPhrase('buildings_name'))
			nameOfBuilding:SizeToContents()
			nameOfBuilding:SetPos(10,45+5)
			local okay
			local searchBox = vgui.Create("ManolisTextEntry", addBuilding)
			searchBox:SetSize(300,30)
			searchBox:SetPos(10,45+5+nameOfBuilding:GetTall()+10)
			searchBox.OnEnter = function()
				okay.DoClick()
			end
			searchBox:RequestFocus()
			okay = vgui.Create("ManolisButton", addBuilding)
			okay:SetText("Create")
			okay:SetPos(300+10+10-101-10,45+5+nameOfBuilding:GetTall()+10+searchBox:GetTall()+10)
			okay.DoClick = function()
				RunConsoleCommand("ManolisPopcornNewBuilding",searchBox:GetValue())
				addBuilding:Close()
			end
	end

	local buildingList = vgui.Create( "ManolisScrollPanel", buildings)
	buildingList:SetPos(5,50)
	buildingList:SetSize(650-10, 535-50-10-35)
	local rBuildings = function()
		for k,v in pairs(manolis.popcorn.buildings.buildings) do
			local building = vgui.Create("ManolisItemPanel")
			building:Go(v.id, v.name, Material("manolis/popcorn/icons/circle.png"), DarkRP.getPhrase('buildings_rent', DarkRP.formatMoney((v.rent or manolis.popcorn.config.defaultRent))), {{label=DarkRP.getPhrase('buildings_remove'), DoClick=function()
				Manolis_Query(DarkRP.getPhrase('buildings_remove_confirm', v.name), DarkRP.getPhrase('confirm'),DarkRP.getPhrase('confirm'),function()RunConsoleCommand("ManolisPopcornRemoveBuilding", v.id) end, DarkRP.getPhrase('cancel'))
			end}, {label=DarkRP.getPhrase('buildings_clearitems'), DoClick = function() 
				Manolis_Query(DarkRP.getPhrase('buildings_clearitems_confirm'), DarkRP.getPhrase('buildings_clear'), DarkRP.getPhrase('capture_points'), function() RunConsoleCommand("ManolisPopcornClearCapturePoint", v.id) end, DarkRP.getPhrase('power_sockets'), function() RunConsoleCommand("ManolisPopcornClearPowerPoints", v.id) end, DarkRP.getPhrase('cash_spawn'),function() RunConsoleCommand("ManolisPopcornClearCashSpawn", v.id) end, DarkRP.getPhrase('cancel'), function()end)
			end}, {label=DarkRP.getPhrase('buildings_set_rent'), DoClick=function()
				Manolis_StringRequest(DarkRP.getPhrase('buildings_set_rent'), DarkRP.getPhrase('buildings_set_rent_confirm'),'',DarkRP.getPhrase('confirm'), function(t)
					if(!tonumber(t)) then 
						return
					end
					local money = t		
					if(tonumber(money)>1000000000) then return end
					RunConsoleCommand('ManolisPopcornSetRent', v.id, money)
				end)
			end}})
			buildingList:Add(building)
		end
	end

	hook.Add("manolis:BuildingUpdate", "manolis:RefreshF4Buildings", function()
		buildingList:ClearPanel()
		rBuildings()
	end)
	rBuildings()
end
vgui.Register( "manolisF4TabAdmin", PANEL, "DPanel" )