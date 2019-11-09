AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("commands.lua")

util.AddNetworkString("DarkRP_shipmentSpawn")

function ENT:Initialize()
    local contents = CustomShipments[self:Getcontents() or ""]



    self.Destructed = false
    self:SetModel(contents and contents.shipmodel or "models/Items/item_item_crate.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self.damage = 30
    local phys = self:GetPhysicsObject()
    phys:Wake()


    -- The following code should not be reached
    if self:Getcount() < 1 then
        self.PlayerUse = false
        SafeRemoveEntity(self)
        if not contents then
            DarkRP.error("Shipment created with zero or fewer elements.", 2)
        else
            DarkRP.error(string.format("Some smartass thought they were clever by setting the 'amount' of shipment '%s' to 0.\nWhat the fuck do you expect the use of an empty shipment to be?", contents.name), 2)
        end
    end

    self:SetMinLevel(self.DarkRPItem.level or 1)

end


function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)
    if not self.locked then
        self.damage = self.damage - dmg:GetDamage()
        if self.damage <= 0 then
            self:Destruct()
        end
    end
end

function ENT:SetContents(s, c)
    self:Setcontents(s)
    self:Setcount(c)
end

function ENT:SetContent()
    self:Setcontents()
end

function ENT:Use(activator, caller)
    if self.IsPocketed then return end
    if type(self.PlayerUse) == "function" then
        local val = self:PlayerUse(activator, caller)
        if val ~= nil then return val end
    elseif self.PlayerUse ~= nil then
        return self.PlayerUse
    end

    if self.locked or self.USED then return end

    self.locked = true -- One activation per second
    self.USED = true
    self.sparking = true
    self:Setgunspawn(CurTime() + 1)
    timer.Create(self:EntIndex() .. "crate", 0.5, 1, function()
        if not IsValid(self) then return end
        self.SpawnItem(self)
    end)
end


function ENT:SpawnItem()
    if not IsValid(self) then return end
    timer.Remove(self:EntIndex() .. "crate")
    self.sparking = false
    local count = self:Getcount()
    if count <= 1 then self:Remove() end
    local contents = self:Getcontents()

    if CustomShipments[contents] and CustomShipments[contents].spawn then self.USED = false return CustomShipments[contents].spawn(self, CustomShipments[contents]) end

    local weapon = ents.Create("spawned_weapon")
  
    weapon.DarkRPItem = self.DarkRPItem
    weapon:SetMinLevel(self.DarkRPItem.level or 1)

    local weaponAng = self:GetAngles()
    local weaponPos = self:GetAngles():Up() * 40 + weaponAng:Up() * (math.sin(CurTime() * 3) * 8)
    weaponAng:RotateAroundAxis(weaponAng:Up(), (CurTime() * 180) % 360)

    if not CustomShipments[contents] then
        weapon:Remove()
        self:Remove()
        return
    end

    local class = CustomShipments[contents].entity
    local model = CustomShipments[contents].model

    weapon:SetWeaponClass(class)
    weapon:SetModel(model)
    weapon.ammoadd = self.ammoadd or (weapons.Get(class) and weapons.Get(class).Primary.DefaultClip)
    weapon.clip1 = self.clip1
    weapon.clip2 = self.clip2
    weapon:SetPos(self:GetPos() + weaponPos)
    weapon:SetAngles(weaponAng)
    weapon.nodupe = true
    weapon:Spawn()
    count = count - 1
    self:Setcount(count)
    self.locked = false
    self.USED = nil
end

function ENT:Think()
    if self.sparking then
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetMagnitude(1)
        effectdata:SetScale(1)
        effectdata:SetRadius(2)
        util.Effect("Sparks", effectdata)
    end
end

function ENT:Destruct()
    if self.Destructed then return end
    self.Destructed = true
    local vPoint = self:GetPos()
    local contents = self:Getcontents()
    local count = self:Getcount()
    local class = nil
    local model = nil

    if CustomShipments[contents] then
        class = CustomShipments[contents].entity
        model = CustomShipments[contents].model
    else
        self:Remove()
        return
    end

    for i=1,count do
        local weapon = ents.Create("spawned_weapon")
        weapon:SetModel(model)
        weapon:SetWeaponClass(class)
        weapon:SetPos(Vector(vPoint.x, vPoint.y, vPoint.z + 5)+Vector(0,0,i*6))
        weapon.ammoadd = self.ammoadd or (weapons.Get(class) and weapons.Get(class).Primary.DefaultClip)
        weapon.nodupe = true
        weapon.DarkRPItem = self.DarkRPItem or {}
        weapon:SetMinLevel(self.DarkRPItem.level or 1)
        weapon:Spawn()

        weapon.dt.amount = count
    end


    

    self:Remove()
end


function ENT:GetItemData()
    local t = self.itemInventoryData
    local a = {}

    for k,v in pairs(t) do
        a[k] = v
    end


    local name = t.name .. ' (x'..self:Getcount()..')'
    a.name = name

    a.json.quantity = self:Getcount() 

    return a
end

function ENT:SetItemData(t)
    self.itemInventoryData = t
    t.name = t.json.name and t.json.name or t.name
end