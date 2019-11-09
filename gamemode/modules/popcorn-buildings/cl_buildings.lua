if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.buildings) then manolis.popcorn.buildings = {} end
if(!manolis.popcorn.buildings.buildings) then manolis.popcorn.buildings.buildings = {} end
if(!manolis.popcorn.buildings.buildingUpgrades) then manolis.popcorn.buildings.buildingUpgrades = {} end

net.Receive("ManolisPopcornBuildingUpdate", function()
	local buildings = net.ReadTable()
	manolis.popcorn.buildings.buildings = buildings 

	hook.Call("manolis:BuildingUpdate", DarkRP.hooks)
end)

net.Receive("ManolisPopcornBuildingUpgradeUpdate", function()
	local upg = net.ReadTable()	
	manolis.popcorn.buildings.buildingUpgrades[upg.key] = upg.data
	
	hook.Call("manolis:BuildingUpgradeUpdate", DarkRP.hooks, upg)
end)

net.Receive("ManolisPopcornBuildingUpgradeData", function()
	local upgrades = net.ReadTable()
	manolis.popcorn.buildings.buildingUpgrades = upgrades
end)

local getAllDoors = function()
	local found = {}
	local class = {
		'func_door',
		'func_door_rotating',
		'prop_door_rotating',
		'prop_dynamic'
	}

	for k,v in pairs(class) do
		local e = ents.FindByClass(v)
		for k,v in pairs(e) do
			table.insert(found, v)
		end

	end

	return found
end

local doors
local lastScan = 0

local showBuilding
local showTime = 0
local realShow = false
local oldB

hook.Add("HUDPaint", "manolisBuildingHUDViewport", function()
	if(CurTime() > lastScan+2) then
		lastScan = CurTime()
		doors = getAllDoors()
		for k,v in pairs(doors) do
			if(IsValid(v) and (v:GetPos():Distance(LocalPlayer():GetPos()) < 100)) then

				local fail = false
				if(oldB and v.EntIndex == oldB.EntIndex) then
					fail = true
				end

				if(!fail) then
					local found = false
					showBuilding = v
					for k2,v2 in pairs(manolis.popcorn.buildings.buildings) do
						for a,b in pairs(v2.doors or {}) do
							if(b.id == v:getDoorData().MapID) then
								showBuilding.buildingInfo = v2
								showBuilding.doorInfo = b
									found = true
								realShow = true
							end
						end
					end
					
					if(found) then							
						showTime = 5
					end
				end
			end
		end
	end

	if(showBuilding and showBuilding.buildingInfo and realShow) then
		if(showBuilding.doorInfo.main==1) then
            if(manolis.popcorn.config.hud.buildingText) then
    		
    			local a = math.Clamp( showTime * 255, 0, 255 )
    			draw.SimpleText(showBuilding.buildingInfo.name, "manolisDoorFont", (ScrW() / 2) + 2, 32 + 2+30+30, Color(0,0,0,a),1)
    			draw.SimpleText(showBuilding.buildingInfo.name, "manolisDoorFont", (ScrW() / 2), 32+30+30, Color(manolis.popcorn.config.promColor.r,manolis.popcorn.config.promColor.g,manolis.popcorn.config.promColor.b,a),1)
    			
    			draw.SimpleText(DarkRP.getPhrase('rent_amount',DarkRP.formatMoney(showBuilding.buildingInfo.rent or manolis.popcorn.config.defaultRent)), "manolisRentFont", (ScrW() / 2) + 2, 65+2+5+30+30, Color(0,0,0,a),1)
    			draw.SimpleText(DarkRP.getPhrase('rent_amount',DarkRP.formatMoney(showBuilding.buildingInfo.rent or manolis.popcorn.config.defaultRent)), "manolisRentFont", (ScrW() / 2), 65+5+30+30, Color(manolis.popcorn.config.promColor.r,manolis.popcorn.config.promColor.g,manolis.popcorn.config.promColor.b,a),1)
    			
    			showTime=showTime-FrameTime()
    			if(showTime < 0) then
    				realShow = false
    				showBuilding = nil
    				oldB = showBuilding
    			end
            end
		end
	end
end)

local frame
net.Receive("ManolisPopcornSetupBuilding", function()
	if(frame) then frame:Remove() end

    frame = vgui.Create("ManolisFrame")
    frame:SetRealSize(300+10+10,100)
    frame:Center()
    frame:SetText(DarkRP.getPhrase('capture_create'))
    frame:MakePopup()
    frame:SetBackgroundBlur(true)
    frame:SetBackgroundBlurOverride(true)

    local building = vgui.Create("DLabel", frame)
    building:SetText(DarkRP.getPhrase('capture_which'))
    building:SetFont("manolisItemInfoName")
    building:SizeToContents()
    building:SetPos(10, 45+5)

    local bSelect = vgui.Create("ManolisComboBox", frame)
    bSelect:SetPos(10, 45+5+building:GetTall()+10)
    bSelect:SetSize(300,35)

    local selected
    for k,v in pairs(manolis.popcorn.buildings.buildings) do
        bSelect:AddChoice(v.name)
    end

    bSelect.OnSelect = function(panel,index,value)
        selected = manolis.popcorn.buildings.buildings[index]
    end

    local saveButton = vgui.Create("ManolisButton", frame)
    saveButton:SetPos(10,45+5+building:GetTall()+bSelect:GetTall()+20)
    saveButton:SetText(DarkRP.getPhrase('save'))
    saveButton:SetWide(300)
    saveButton.DoClick = function()
        RunConsoleCommand("ManolisPopcornSaveCapturePoint", selected.id)
        frame:Close()
    end

    frame:SetTall(45+5+building:GetTall()+bSelect:GetTall()+20+saveButton:GetTall()+10)

	frame.header.closeButton.DoClick = function()
		frame:Close(false)
	end
end)

net.Receive("ManolisPopcornSetupBuildingCash", function()
	if(frame) then frame:Remove() end

    frame = vgui.Create("ManolisFrame")
    frame:SetRealSize(300+10+10,100)
    frame:Center()
    frame:SetText(DarkRP.getPhrase('cashstack_create'))
    frame:MakePopup()
    frame:SetBackgroundBlur(true)
    frame:SetBackgroundBlurOverride(true)


  	local building = vgui.Create("DLabel", frame)
    building:SetText(DarkRP.getPhrase('capture_which'))
    building:SetFont("manolisItemInfoName")
    building:SizeToContents()
    building:SetPos(10, 45+5)

    local bSelect = vgui.Create("ManolisComboBox", frame)
    bSelect:SetPos(10, 45+5+building:GetTall()+10)
    bSelect:SetSize(300,35)

    local selected
    for k,v in pairs(manolis.popcorn.buildings.buildings) do
        bSelect:AddChoice(v.name)
    end

    bSelect.OnSelect = function(panel,index,value)
        selected = manolis.popcorn.buildings.buildings[index]
    end

    local saveButton = vgui.Create("ManolisButton", frame)
    saveButton:SetPos(10,45+5+building:GetTall()+bSelect:GetTall()+20)
    saveButton:SetText(DarkRP.getPhrase('save'))
    saveButton:SetWide(300)
    saveButton.DoClick = function()
    	if(selected and selected.id) then
	        RunConsoleCommand("ManolisPopcornSaveCashStack", selected.id)
	        frame:Close()
	    end
    end

    frame:SetTall(45+5+building:GetTall()+bSelect:GetTall()+20+saveButton:GetTall()+10)

	frame.header.closeButton.DoClick = function()
		frame:Close(false)
	end

end)

net.Receive("ManolisPopcornSetupBuildingPower", function()
	if(frame) then frame:Remove() end

    frame = vgui.Create("ManolisFrame")
    frame:SetRealSize(300+10+10,100)
    frame:Center()
    frame:SetText(DarkRP.getPhrase('socket_create'))
    frame:MakePopup()
    frame:SetBackgroundBlur(true)
    frame:SetBackgroundBlurOverride(true)

    local building = vgui.Create("DLabel", frame)
    building:SetText(DarkRP.getPhrase('capture_which'))
    building:SetFont("manolisItemInfoName")
    building:SizeToContents()
    building:SetPos(10, 45+5)

    local bSelect = vgui.Create("ManolisComboBox", frame)
    bSelect:SetPos(10, 45+5+building:GetTall()+10)
    bSelect:SetSize(300,35)

    local selected
    for k,v in pairs(manolis.popcorn.buildings.buildings) do
        bSelect:AddChoice(v.name)
    end

    bSelect.OnSelect = function(panel,index,value)
        selected = manolis.popcorn.buildings.buildings[index]
    end

    local saveButton = vgui.Create("ManolisButton", frame)
    saveButton:SetPos(10,45+5+building:GetTall()+bSelect:GetTall()+20)
    saveButton:SetText(DarkRP.getPhrase('save'))
    saveButton:SetWide(300)
    saveButton.DoClick = function()
    	if(selected and selected.id) then
	        RunConsoleCommand("ManolisPopcornSavePowerPoint", selected.id)
	        frame:Close()
	    end
    end

    frame:SetTall(45+5+building:GetTall()+bSelect:GetTall()+20+saveButton:GetTall()+10)

	frame.header.closeButton.DoClick = function()
		frame:Close(false)
	end
end)