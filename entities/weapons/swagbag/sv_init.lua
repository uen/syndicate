local meta = FindMetaTable("Player")


--[[---------------------------------------------------------------------------
Functions
---------------------------------------------------------------------------]]
-- workaround: GetNetworkVars doesn't give entities because the /duplicator/ doesn't want to save entities
local function getDTVars(ent)
    if not ent.GetNetworkVars then return nil end
    local name, value = debug.getupvalue(ent.GetNetworkVars, 1)
    if name ~= "datatable" then
        ErrorNoHalt("Warning: Datatable cannot be stored properly in Swagbag. Tell a developer!")
    end

    local res = {}

    for k,v in pairs(value) do
        res[k] = v.GetFunc(ent, v.index)
    end

    return res
end

local function serialize(ent)
    local serialized = duplicator.CopyEntTable(ent)
    serialized.DT = getDTVars(ent)
    
    local v = {} 
    if(ent.DarkRPItem) then
        if(ent.DarkRPItem.pTable) then
            for ka,va in pairs(ent.DarkRPItem.pTable) do
                if(!v.pTable) then v.pTable = {} end
                v.pTable[ka] = va
            end
        end
        for ka,va in pairs(ent.DarkRPItem) do
            v[ka] = va
        end
    end

    serialized.DarkRPItem = v
    return serialized
end

local function deserialize(ply, item)
    local ent = ents.Create(item.Class)
    duplicator.DoGeneric(ent, item)


    duplicator.DoGenericPhysics(ent, ply, item)
    table.Merge(ent:GetTable(), item)

    local pos, mins = ent:GetPos(), ent:WorldSpaceAABB()
    local offset = pos.z - mins.z

    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 85
    trace.filter = ply

    local tr = util.TraceLine(trace)
    ent:SetPos(tr.HitPos + Vector(0, 0, offset))


    ent:Spawn()
    ent:Activate()

    local phys = ent:GetPhysicsObject()
    timer.Simple(0, function() if phys:IsValid() then phys:Wake() end end)

    return ent
end

local function dropAllSwagbagItems(ply)
    for k,v in pairs(ply.darkRPSwagbag or {}) do
        ply:dropSwagbagItem(k)
    end
end

util.AddNetworkString("DarkRP_Swagbag")
local function sendSwagbagItems(ply)
    net.Start("DarkRP_Swagbag")
        net.WriteTable(ply:getSwagbagItems())
    net.Send(ply)
end

--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
function meta:addSwagbagItem(ent)
    if not IsValid(ent) then DarkRP.error("Entity not valid", 2) end
    if ent.USED then return end

    -- This item cannot be used until it has been removed
    ent.USED = true

    local serialized = serialize(ent)

    hook.Call("onSwagbagItemAdded", nil, self, ent, serialized)

    ent:Remove()

    self.darkRPSwagbag = self.darkRPSwagbag or {}

    local id = table.insert(self.darkRPSwagbag, serialized)
    sendSwagbagItems(self)
    return id
end

function meta:removeSwagbagItem(item)
    if not self.darkRPSwagbag or not self.darkRPSwagbag[item] then DarkRP.error("Player does not contain " .. item .. " in their Swagbag.", 2) end

    hook.Call("onSwagbagItemRemoved", nil, self, item)

    self.darkRPSwagbag[item] = nil
    sendSwagbagItems(self)
end

function meta:dropSwagbagItem(item)
    if not self.darkRPSwagbag or not self.darkRPSwagbag[item] then DarkRP.error("Player does not contain " .. item .. " in their Swagbag.", 2) end

    local id = self.darkRPSwagbag[item]
    local ent = deserialize(self, id)

    -- reset USED status
    ent.USED = nil

    hook.Call("onSwagbagItemDropped", nil, self, ent, item, id)

    self:removeSwagbagItem(item)

    return ent
end

-- serverside implementation
function meta:getSwagbagItems()
    self.darkRPSwagbag = self.darkRPSwagbag or {}

    local res = {}
    for k,v in pairs(self.darkRPSwagbag) do
        res[k] = {
            model = v.Model,
            class = v.Class
        }
    end

    return res
end

--[[---------------------------------------------------------------------------
Commands
---------------------------------------------------------------------------]]
util.AddNetworkString("DarkRP_spawnSwagbag")
net.Receive("DarkRP_spawnSwagbag", function(len, ply)
    local item = net.ReadFloat()
    if not ply.darkRPSwagbag or not ply.darkRPSwagbag[item] then return end
    ply:dropSwagbagItem(item)
end)

--[[---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------]]

local function onAdded(ply, ent, serialized)
    if not ent:IsValid() or not ent.DarkRPItem or not ent.Getowning_ent or not IsValid(ent:Getowning_ent()) then return end

    ply = ent:Getowning_ent()

    ply:addCustomEntity(ent.DarkRPItem)
end
hook.Add("onSwagbagItemAdded", "defaultImplementation", onAdded)

function GAMEMODE:canSwagbag(ply, item)
    if not IsValid(item) then return false end
    local class = item:GetClass()

    if item.Removed then return false, DarkRP.getPhrase("cannot_swagbag_x") end
    if item.jailWall then return false, DarkRP.getPhrase("cannot_swagbag_x") end
    if !manolis.popcorn.config.SwagbagWhitelist[class] then return false, DarkRP.getPhrase("cannot_swagbag_x") end
    if string.find(class, "func_") then return false, DarkRP.getPhrase("cannot_swagbag_x") end
    if item:IsRagdoll() then return false, DarkRP.getPhrase("cannot_swagbag_x") end
    if item:IsNPC() then return false, DarkRP.getPhrase("cannot_swagbag_x") end

    local trace = ply:GetEyeTrace()
    if ply:EyePos():DistToSqr(trace.HitPos) > 22500 then return false end

    local phys = trace.Entity:GetPhysicsObject()
    if not phys:IsValid() then return false end


    local job = ply:Team()
    local max = RPExtraTeams[job].maxSwagbag or manolis.popcorn.config.Swagbagitems or 4
    if table.Count(ply.darkRPSwagbag or {}) >= max then return false, DarkRP.getPhrase("swagbag_full") end

    return true
end


-- Drop Swagbag items on death
hook.Add("PlayerDeath", "DropSwagbagItems", function(ply)
    if not GAMEMODE.Config.dropSwagbagdeath or not ply.darkRPSwagbag then return end
    dropAllSwagbagItems(ply)
end)

hook.Add("playerArrested", "DropSwagbagItems", function(ply)
    if not GAMEMODE.Config.dropSwagbagarrest then return end
    dropAllSwagbagItems(ply)
end)
