AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()

    if not phys:IsValid() then
        self:SetModel("models/weapons/w_rif_ak47.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        phys = self:GetPhysicsObject()
    end

    phys:Wake()

    if self:Getamount() == 0 then
        self:Setamount(1)
    end
end

function ENT:DecreaseAmount()
    local amount = self.dt.amount

    self.dt.amount = amount - 1

    if self.dt.amount <= 0 then
        self:Remove()
        self.PlayerUse = false
        self.Removed = true -- because it is not removed immediately
    end
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)
end

function ENT:Use(activator, caller)
    
    if(activator:IsPlayer()) then
        if(!manolis.popcorn.levels.HasLevel(activator, self:GetMinLevel() or 1)) then
            return
        end 
        

        local class = self:GetWeaponClass()
 
        local weapon = ents.Create(class)
        if(weapon:IsWeapon()) then
            local amType = weapon:GetPrimaryAmmoType()

            if(activator:HasWeapon(class)) then
                activator:GiveAmmo(1, amType)
            else
                activator:Give(class, true)
            end

            weapon:Remove()
            self:Remove()
            return
        end
        if(!IsValid(weapon)) then return false end
        weapon.DarkRPItem = self.DarkRPItem
        weapon:SetPos(self:GetPos())
        weapon:SetAngles(self:GetAngles())
        weapon:Spawn()
        weapon:Activate()

        self:Remove()
    end
end


function ENT:SetItemData(data)
    self.itemInventoryData = data

    local str = data.name
    if(data.quantity>1) then
        str = data.quantity.."x "..str.."s"
    end
    if(data.model) then
        self:SetModel(data.model)
    end

    self:SetWeaponClass(data.type)
    self:SetNameOfItem(str)
end

function ENT:SetMinLevel(level)
    self:SetMinLevel(level)
end

function ENT:SetXP(xp)
    self:SetXP(xp)
end

function ENT:GetItemData()
    return self.itemInventoryData
end