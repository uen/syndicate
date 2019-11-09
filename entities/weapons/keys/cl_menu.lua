local function AddButtonToFrame(Frame)
    Frame:SetTall(Frame:GetTall() + 110)

    local button = vgui.Create('ManolisButton', Frame)
    button:SetPos(10, Frame:GetTall() - 110)
    button:SetSize(180, 100)

    Frame.buttonCount = (Frame.buttonCount or 0) + 1
    Frame.lastButton = button
    return button
end

local KeyFrameVisible = false

local function openMenu(setDoorOwnerAccess, doorSettingsAccess)
    if KeyFrameVisible then return end

    local ent = LocalPlayer():GetEyeTrace().Entity
    -- Don't open the menu if the entity is not ownable, the entity is too far away or the door settings are not loaded yet
    if not IsValid(ent) or not ent:isKeysOwnable() or ent:GetPos():Distance(LocalPlayer():GetPos()) > 200 then return end

    KeyFrameVisible = true
    local Frame = vgui.Create('ManolisFrame')
    Frame:SetRealSize(200, 50)
    Frame:SetVisible(true)
    Frame:MakePopup()

    Frame:SetBackgroundBlur(true)

    function Frame:Think()
        local LAEnt = LocalPlayer():GetEyeTrace().Entity
        if not IsValid(LAEnt) or not LAEnt:isKeysOwnable() or LAEnt:GetPos():Distance(LocalPlayer():GetPos()) > 200 then
            self:Close()
        end
        if not self.Dragging then return end
        local x = gui.MouseX() - self.Dragging[1]
        local y = gui.MouseY() - self.Dragging[2]
        x = math.Clamp(x, 0, ScrW() - self:GetWide())
        y = math.Clamp(y, 0, ScrH() - self:GetTall())
        self:SetPos(x, y)
    end

    local entType = DarkRP.getPhrase(ent:IsVehicle() and 'vehicle' or 'door')
    Frame:SetText(DarkRP.getPhrase('x_options', entType:gsub('^%a', string.upper)))

    function Frame:Close()
        KeyFrameVisible = false
        self:SetVisible(false)
        self:Remove()
    end

    if ent:isKeysOwnedBy(LocalPlayer()) then
        if(!ent:IsVehicle()) then
            local Owndoor = AddButtonToFrame(Frame)
            Owndoor:SetText(DarkRP.getPhrase('sell_x', entType))
            Owndoor.DoClick = function() RunConsoleCommand('darkrp', 'toggleown') Frame:Close() end
        end

        local AddOwner = AddButtonToFrame(Frame)
        AddOwner:SetText(DarkRP.getPhrase('add_owner'))
        AddOwner.DoClick = function()
            local menu = ManolisMenu()
            menu.found = false

            for k,v in pairs(DarkRP.nickSortedPlayers()) do
                if not ent:isKeysOwnedBy(v) and not ent:isKeysAllowedToOwn(v) then
                    local steamID = v:SteamID()
                    menu.found = true
                    menu:AddOption(v:Nick(), function() RunConsoleCommand('darkrp', 'ao', steamID) end)
                end
            end

            if not menu.found then
                menu:AddOption(DarkRP.getPhrase('noone_available'), function() end)
            end
            menu:Open()
        end

        local RemoveOwner = AddButtonToFrame(Frame)
        RemoveOwner:SetText(DarkRP.getPhrase('remove_owner'))
        RemoveOwner.DoClick = function()
            local menu = ManolisMenu()
            for k,v in pairs(DarkRP.nickSortedPlayers()) do
                if (ent:isKeysOwnedBy(v) and not ent:isMasterOwner(v)) or ent:isKeysAllowedToOwn(v) then
                    local steamID = v:SteamID()
                    menu.found = true
                    menu:AddOption(v:Nick(), function() RunConsoleCommand('darkrp', 'ro', steamID) end)
                end
            end

            if not menu.found then
                menu:AddOption(DarkRP.getPhrase('noone_available'), function() end)
            end
            menu:Open()
        end

        if not ent:isMasterOwner(LocalPlayer()) then
            RemoveOwner:SetDisabled(true)
        end
    end

    if(!ent:IsVehicle()) then
        if doorSettingsAccess then
            local DisableOwnage = AddButtonToFrame(Frame)
            DisableOwnage:SetText(DarkRP.getPhrase(ent:getKeysNonOwnable() and 'allow_ownership' or 'disallow_ownership'))
            DisableOwnage.DoClick = function() Frame:Close() RunConsoleCommand('darkrp', 'toggleownable') end
        end
    end 

    local upgradeFrame
    local f = false

    for a,b in pairs(manolis.popcorn.buildings.buildings) do
        for k,door in pairs(b.doors) do
            if(door.id == LocalPlayer():GetEyeTrace().Entity:getDoorData().MapID) then
                f = b
            end
        end
    end

    if (doorSettingsAccess and (ent:isKeysOwned()) or ent:isKeysOwnedBy(LocalPlayer())) and f and f.id then
        local UpgradeMenu = AddButtonToFrame(Frame)
        UpgradeMenu:SetText(DarkRP.getPhrase('upgrade_building'))

        UpgradeMenu.DoClick = function()
            local pTab = manolis.popcorn.buildings.buildingUpgrades[f and f.id or 0]
            if(!pTab) then pTab = {} end

            if(upgradeFrame and IsValid(upgradeFrame)) then upgradeFrame:Remove() end
            local wh = 50
            upgradeFrame = vgui.Create('ManolisFrame')
            upgradeFrame:SetRealSize(380,50+wh+10+50+10)
            upgradeFrame:Center()
            upgradeFrame:SetBackgroundBlur(true)
            upgradeFrame:SetBackgroundBlurOverride(true)
            upgradeFrame:MakePopup()
            local powerUpgrade = vgui.Create('ManolisButton', upgradeFrame)
            powerUpgrade:SetPos(10,50)
            powerUpgrade:SetWide(120)
            powerUpgrade:SetTall(wh)
            powerUpgrade:SetText(DarkRP.getPhrase('upgrade_power'))

            powerUpgrade.DoClick = function()
                if(f and f.id) then
                    RunConsoleCommand('ManolisPopcornUpgradeBuilding',1,LocalPlayer():GetEyeTrace().Entity:getDoorData().MapID, f.id)
                end
            end

            local powerUpgradeButtons = {}
            local refreshPower = function(d)
                for k,v in pairs(powerUpgradeButtons) do
                    v:Remove()
                end
                for a=1,4 do
                    local upg = vgui.Create('ManolisCheckbox', upgradeFrame)
                    upg.Alternate = true
                    upg:SetSize(wh,wh)
                    upg:SetDisabled(true)
                    upg:SetTooltip(DarkRP.getPhrase('level_standard',a))
                    if(a<=d) then
                        upg:SetChecked(true)
                    end

                    upg:SetPos(10+powerUpgrade:GetWide()+(a*(wh+10))-wh,50)    
                    powerUpgradeButtons[a] = upg
                end

                if(d>=4) then
                    powerUpgrade:SetTooltip(DarkRP.getPhrase('building_max_upgrade'))
                else
                    powerUpgrade:SetTooltip(DarkRP.getPhrase('upgrade_power_for', DarkRP.formatMoney(manolis.popcorn.config.buildingUpgrades.power[(d+1>0) and d+1 or 1])))
                end
            end

            refreshPower(pTab['power'] or 0)

            local lockpickUpgrade = vgui.Create('ManolisButton', upgradeFrame)
            lockpickUpgrade:SetPos(10,50+wh+10)
            lockpickUpgrade:SetWide(120)
            lockpickUpgrade:SetTall(wh)
            lockpickUpgrade:SetText(DarkRP.getPhrase('upgrade_lockpick'))    

            lockpickUpgrade.DoClick = function()
                if(f and f.id) then
                    RunConsoleCommand('ManolisPopcornUpgradeBuilding',2,LocalPlayer():GetEyeTrace().Entity:getDoorData().MapID, f.id)
                end 
            end

            local lockpickUpgradeButtons = {}
            local refreshLockpick = function(d)
                for k,v in pairs(lockpickUpgradeButtons) do
                    v:Remove()
                end

                for a=1,4 do
                    local upg = vgui.Create('ManolisCheckbox', upgradeFrame)
                    upg.Alternate = true
                    upg:SetSize(wh,wh)
                    upg:SetDisabled(true)
                    upg:SetTooltip(DarkRP.getPhrase('level_standard',a))
                    if(a<=d) then
                        upg:SetChecked(true)
                    end
                    upg:SetPos(10+powerUpgrade:GetWide()+(a*(wh+10))-wh,50+wh+10)
                    lockpickUpgradeButtons[a] = upg
                end

                if(d>=4) then
                    lockpickUpgrade:SetTooltip(DarkRP.getPhrase('building_max_upgrade'))
                else
                    lockpickUpgrade:SetTooltip(DarkRP.getPhrase('upgrade_lockpick_for', DarkRP.formatMoney(manolis.popcorn.config.buildingUpgrades.lockpick[(d+1>0) and d+1 or 1])))
                end
            end
            refreshLockpick(pTab['lockpick'] or 0)

            hook.Add('manolis:BuildingUpgradeUpdate', 'manolis:buildingUpgradeUpdateInfo', function(c)
                local f = false
                for a,b in pairs(manolis.popcorn.buildings.buildings) do
                    for k,door in pairs(b.doors) do
                        if(door.id == LocalPlayer():GetEyeTrace().Entity:getDoorData().MapID) then
                            f= b
                        end
                    end
                end
                if(f) then
                    refreshPower(c.data['power'] or 0)
                    refreshLockpick(c.data['lockpick'] or 0)
                end
            end)

            upgradeFrame:SetText(DarkRP.getPhrase('upgrade_building'))
        end
    end

    if not ent:isKeysOwned() and not ent:getKeysNonOwnable() and not ent:getKeysDoorGroup() and not ent:getKeysDoorTeams() or not ent:isKeysOwnedBy(LocalPlayer()) and ent:isKeysAllowedToOwn(LocalPlayer()) then
        local Owndoor = AddButtonToFrame(Frame)
        Owndoor:SetText(DarkRP.getPhrase('buy_x', entType))
        Owndoor.DoClick = function() RunConsoleCommand('darkrp', 'toggleown') Frame:Close() end
    end

    if doorSettingsAccess then
        if(!ent:IsVehicle()) then

            local SetBuilding = AddButtonToFrame(Frame)
            SetBuilding:SetText(DarkRP.getPhrase('building_set_building'))
            SetBuilding.DoClick = function()
                local frame = vgui.Create('ManolisFrame')
                frame:SetRealSize(300+10+10,205)
                frame:Center()
                frame:SetText(DarkRP.getPhrase('building_edit_door'))
                frame:MakePopup()
                frame:SetBackgroundBlur(true)
                frame:SetBackgroundBlurOverride(true)

                local building = vgui.Create('DLabel', frame)
                building:SetText(DarkRP.getPhrase('part_building'))
                building:SetFont('manolisItemInfoName')
                building:SizeToContents()
                building:SetPos(10, 45+5)

                local bSelect = vgui.Create('ManolisComboBox', frame)
                bSelect:SetPos(10, 45+5+building:GetTall()+10)
                bSelect:SetSize(300,35)

                local selected
                for k,v in pairs(manolis.popcorn.buildings.buildings) do
                    bSelect:AddChoice(v.name)
                end

                bSelect.OnSelect = function(panel,index,value)
                    selected = manolis.popcorn.buildings.buildings[index]
                end

                local isMainDoor = vgui.Create('ManolisCheckbox', frame)
                isMainDoor:SetPos(10,45+5+building:GetTall()+10+bSelect:GetTall()+10)
                isMainDoor.Alternate = true

                local isMainDoorLabel = vgui.Create('DLabel', frame)
                isMainDoorLabel:SetText(DarkRP.getPhrase('building_entrance_exit'))
                isMainDoorLabel:SetFont('manolisItemInfoName')
                isMainDoorLabel:SizeToContents()
                isMainDoorLabel:SetPos(0+20+10+5+5,45+5+building:GetTall()+10+bSelect:GetTall()+10)

                local saveButton = vgui.Create('ManolisButton', frame)
                saveButton:SetPos(300+10+10-101-10,45+5+building:GetTall()+10+bSelect:GetTall()+10+isMainDoorLabel:GetTall()+15)
                saveButton:SetText(DarkRP.getPhrase('save'))
                saveButton.DoClick = function()
                    RunConsoleCommand('ManolisPopcornSaveDoor', selected.id, isMainDoor:GetChecked() and 1)
                    frame:Close()
                    Frame:Close()
                end
            end

            local EditDoorGroups = AddButtonToFrame(Frame)
            EditDoorGroups:SetText(DarkRP.getPhrase('edit_door_group'))
            EditDoorGroups.DoClick = function()
            local menu = ManolisMenu()
            local groups = menu:AddSubMenu(DarkRP.getPhrase('door_groups'))
            local teams = menu:AddSubMenu(DarkRP.getPhrase('jobs'))
            local add = teams:AddSubMenu(DarkRP.getPhrase('add'))
            local remove = teams:AddSubMenu(DarkRP.getPhrase('remove'))

            menu:AddOption(DarkRP.getPhrase('none'), function()
                RunConsoleCommand('darkrp', 'togglegroupownable')
                if IsValid(Frame) then Frame:Close() end
            end)

            for k,v in pairs(RPExtraTeamDoors) do
                groups:AddOption(k, function()
                    RunConsoleCommand('darkrp', 'togglegroupownable', k)
                    if IsValid(Frame) then Frame:Close() end
                end)
            end

            local doorTeams = ent:getKeysDoorTeams()
            for k,v in pairs(RPExtraTeams) do
                local which = (not doorTeams or not doorTeams[k]) and add or remove
                which:AddOption(v.name, function()
                    RunConsoleCommand('darkrp', 'toggleteamownable', k)
                    if IsValid(Frame) then Frame:Close() end
                end)
            end

            menu:Open()
        end
    end

    if Frame.buttonCount == 1 then
        Frame.lastButton:DoClick()
        elseif Frame.buttonCount == 0 or not Frame.buttonCount then
            Frame:Close()
            KeyFrameVisible = true
            timer.Simple(0.3, function() KeyFrameVisible = false end)
        end

        hook.Call('onKeysMenuOpened', nil, ent, Frame)

        Frame:Center()
        Frame:SetSkin(GAMEMODE.Config.DarkRPSkin)
    end

    Frame:Center()
end

function DarkRP.openKeysMenu(um)
    CAMI.PlayerHasAccess(LocalPlayer(), 'DarkRP_SetDoorOwner', function(setDoorOwnerAccess)
        CAMI.PlayerHasAccess(LocalPlayer(), 'DarkRP_ChangeDoorSettings', fp{openMenu, setDoorOwnerAccess})
    end)
end
usermessage.Hook('KeysMenu', DarkRP.openKeysMenu)