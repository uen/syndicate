local function addEntityCommands(tblEnt)
    DarkRP.declareChatCommand{
        command = tblEnt.cmd,
        description = "Purchase a " .. tblEnt.name,
        delay = 2,
        condition =
            function(ply)
                if ply:isArrested() then return false end
                if istable(tblEnt.allowed) and not table.HasValue(tblEnt.allowed, ply:Team()) then return false end
                if not ply:canAfford(tblEnt.price) then return false end
                if tblEnt.customCheck and tblEnt.customCheck(ply) == false then return false end

                return true
            end
    }

    if CLIENT then return end

    -- Default spawning function of an entity
    -- used if tblEnt.spawn is not defined
    local function defaultSpawn(ply, tr, tblE)
        local ent = ents.Create(tblE.ent)
        if not ent:IsValid() then error("Entity '" .. tblE.ent .. "' does not exist or is not valid.") end
        ent.dt = ent.dt or {}
        ent.dt.owning_ent = ply
        if ent.Setowning_ent then ent:Setowning_ent(ply) end
        ent:SetPos(tr.HitPos)
        -- These must be set before :Spawn()
        ent.SID = ply.SID
        ent.allowed = tblE.allowed
        ent.DarkRPItem = tblE
        ent:Spawn()

        local phys = ent:GetPhysicsObject()
        if phys:IsValid() then phys:Wake() end

        return ent
    end

    local function buythis(ply, args)
        if ply:isArrested() then return "" end
        if type(tblEnt.allowed) == "table" and not table.HasValue(tblEnt.allowed, ply:Team()) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", tblEnt.name))
            return ""
        end

        if tblEnt.customCheck and not tblEnt.customCheck(ply) then
            local message = isfunction(tblEnt.CustomCheckFailMsg) and tblEnt.CustomCheckFailMsg(ply, tblEnt) or
                tblEnt.CustomCheckFailMsg or
                DarkRP.getPhrase("not_allowed_to_purchase")
            DarkRP.notify(ply, 1, 4, message)
            return ""
        end

        if ply:customEntityLimitReached(tblEnt) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("limit", tblEnt.name))
            return ""
        end

        local canbuy, suppress, message, price = hook.Call("canBuyCustomEntity", nil, ply, tblEnt)

        local cost = price or tblEnt.getPrice and tblEnt.getPrice(ply, tblEnt.price) or tblEnt.price

        if not ply:canAfford(cost) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", tblEnt.name))
            return ""
        end

        if canbuy == false then
            if not suppress and message then DarkRP.notify(ply, 1, 4, message) end
            return ""
        end

        if(ply.syndicateCreditShop.hasGoldenDiscount) then
            local credit = manolis.popcorn.creditShop.findItem('discount1')
            if(credit) then
                cost = cost * (1-(credit.affectLevels[1]/100))
            end
        end

        ply:addMoney(-cost)

        local trace = {}
        trace.start = ply:EyePos()
        trace.endpos = trace.start + ply:GetAimVector() * 85
        trace.filter = ply

        local tr = util.TraceLine(trace)

        local ent = defaultSpawn(ply,tr,tblEnt)//(tblEnt.spawn or defaultSpawn)(ply, tr, tblEnt)
        ent.onlyremover = true
        -- Repeat these properties to alleviate work in tblEnt.spawn:
        ent.SID = ply.SID
        ent.allowed = tblEnt.allowed
        ent.DarkRPItem = tblEnt

        hook.Call("playerBoughtCustomEntity", nil, ply, tblEnt, ent, cost)

        DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", tblEnt.name, DarkRP.formatMoney(cost), ""))

        ply:addCustomEntity(tblEnt)
        return ""
    end
    DarkRP.defineChatCommand(tblEnt.cmd, buythis)
end


local function BuyShipment(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
        return ""
    end

    local found, foundKey = DarkRP.getShipmentByName(args)
    if not found or found.noship or not GAMEMODE:CustomObjFitsMap(found) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", "shipment"))
        return ""
    end

    local canbuy, suppress, message, price = hook.Call("canBuyShipment", DarkRP.hooks, ply, found)

    if not canbuy then
        message = message or DarkRP.getPhrase("incorrect_job", "/buy")
        if not suppress then DarkRP.notify(ply, 1, 4, message) end
        return ""
    end

    local cost = price or found.getPrice and found.getPrice(ply, found.price) or found.price

    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 85
    trace.filter = ply

    local tr = util.TraceLine(trace)

    local crate = ents.Create(found.shipmentClass or "spawned_shipment")
    crate.SID = ply.SID
    crate:Setowning_ent(ply)
    crate:SetContents(foundKey, found.amount)
    crate.DarkRPItem = found

    crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z))
    crate.nodupe = true
    crate.ammoadd = found.spareammo
    crate.clip1 = found.clip1
    crate.clip2 = found.clip2



    local t = {}
    t.name = found.name
    t.entity = 'spawned_shipment'
    t.json = {name = found.name, quantity=found.amount}
    t.model = "models/Items/item_item_crate.mdl"
    t.icon = "misc/shipment.png"
    t.type = "shipment"
    t.level = 1

    t = manolis.popcorn.items.CreateItemData(t)

    crate.itemInventoryData = t


    crate:Spawn()
    crate:SetPlayer(ply)


    if(ply.syndicateCreditShop.hasGoldenDiscount) then
        local credit = manolis.popcorn.creditShop.findItem('discount1')
        if(credit) then
            cost = cost * (1-(credit.affectLevels[1]/100))
        end
    end


    local phys = crate:GetPhysicsObject()
    phys:Wake()
    if found.weight then
        phys:SetMass(found.weight)
    end

    if CustomShipments[foundKey].onBought then
        CustomShipments[foundKey].onBought(ply, CustomShipments[foundKey], crate)
    end
    hook.Call("playerBoughtShipment", nil, ply, CustomShipments[foundKey], crate, cost)

    if IsValid(crate) then
        ply:addMoney(-cost)
        DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", args, DarkRP.formatMoney(cost)))
    else
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyshipment", arg))
    end

    ply.LastShipmentSpawn = CurTime()

    return ""
end
DarkRP.defineChatCommand("buyshipment", BuyShipment)


function DarkRP.createEntity(name, entity, model, price, max, command, classes, CustomCheck)
    local tableSyntaxUsed = type(entity) == "table"

    local tblEnt = tableSyntaxUsed and entity or
        {ent = entity, model = model, price = price, max = max,
        cmd = command, allowed = classes, customCheck = CustomCheck}
    tblEnt.name = name
    tblEnt.default = DarkRP.DARKRP_LOADING

    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["entities"][tblEnt.name] then return end

    if type(tblEnt.allowed) == "number" then
        tblEnt.allowed = {tblEnt.allowed}
    end

    local valid, err, hints = DarkRP.validateEntity(tblEnt)
    if not valid then DarkRP.error(string.format("Corrupt entity: %s!\n%s", name or "", err), 2, hints) end

    tblEnt.customCheck = tblEnt.customCheck and fp{DarkRP.simplerrRun, tblEnt.customCheck}
    tblEnt.CustomCheckFailMsg = isfunction(tblEnt.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, tblEnt.CustomCheckFailMsg} or tblEnt.CustomCheckFailMsg
    tblEnt.getPrice    = tblEnt.getPrice    and fp{DarkRP.simplerrRun, tblEnt.getPrice}
    tblEnt.getMax      = tblEnt.getMax      and fp{DarkRP.simplerrRun, tblEnt.getMax}
    tblEnt.spawn       = tblEnt.spawn       and fp{DarkRP.simplerrRun, tblEnt.spawn}

    -- if SERVER and FPP then
    --  FPP.AddDefaultBlocked(blockTypes, tblEnt.ent)
    -- end

    table.insert(DarkRPEntities, tblEnt)
    DarkRP.addToCategory(tblEnt, "entities", tblEnt.category)
    timer.Simple(0, function() addEntityCommands(tblEnt) end)
end
AddEntity = DarkRP.createEntity


local function BuyAmmo(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
        return ""
    end

    if GAMEMODE.Config.noguns then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "ammo", ""))
        return ""
    end

    local found
    local num = tonumber(args)
    if num and GAMEMODE.AmmoTypes[num] then
        found = GAMEMODE.AmmoTypes[num]
    else
        for k,v in pairs(GAMEMODE.AmmoTypes) do
            if v.ammoType ~= args then continue end

            found = v
            break
        end
    end

    if not found then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", "ammo"))
        return ""
    end

    local canbuy, suppress, message, price = hook.Call("canBuyAmmo", DarkRP.hooks, ply, found)

    if not canbuy then
        message = message or DarkRP.getPhrase("incorrect_job", "/buy")
        if not suppress then DarkRP.notify(ply, 1, 4, message) end
        return ""
    end

    local cost = price or found.getPrice and found.getPrice(ply, found.price) or found.price

    if(ply.syndicateCreditShop.hasGoldenDiscount) then
        local credit = manolis.popcorn.creditShop.findItem('discount1')
        if(credit) then
            cost = cost * (1-(credit.affectLevels[1]/100))
        end
    end
    
    DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", found.name, DarkRP.formatMoney(cost)))
    ply:addMoney(-cost)

    ply:GiveAmmo(found.amountGiven, found.ammoType)
    

    hook.Call("playerBoughtAmmo", nil, ply, found, ammo, cost)

    return ""
end
DarkRP.defineChatCommand("buyammo", BuyAmmo, 1)