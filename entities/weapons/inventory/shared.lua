if (CLIENT) then
    SWEP.CrossHairScale = 0
    SWEP.ViewModelFOV   = 62
    SWEP.DrawCrosshair  = false
    SWEP.DrawAmmo       = false
    SWEP.AnimPrefix     = "rpg"

    SWEP.DrawCrosshair = true
    SWEP.WorldModel     = ""
end

SWEP.Base               = "weapon_base"
SWEP.Author             = "Manolis Vrondakis"
SWEP.Instructions       = "Left click to add an item to your inventory\nReload to open your inventory"

SWEP.Spawnable          = false
SWEP.AdminSpawnable     = false

SWEP.PrintName          = "Inventory"
SWEP.Slot               = 2
SWEP.SlotPos            = 1

SWEP.ViewModelFlip      = false

SWEP.Primary.Ammo       = ""
SWEP.Secondary.Ammo     = ""
SWEP.Primary.Automatic  = false
SWEP.Primary.Damage     = 0



SWEP.HoldType = "normal"
SWEP.AnimDeploy     = nil

function SWEP:DrawWorldModel() end

function SWEP:PreDrawViewModel(vm)
    return true
end

function SWEP:Deploy()
    return true
end

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Holster()
    if not SERVER then return true end

    self:GetOwner():DrawViewModel(true)
    self:GetOwner():DrawWorldModel(true)

    return true
end


function SWEP:PrimaryAttack()
    if not SERVER then return end
    self:SetNextPrimaryFire(CurTime() + 0.2)

    local ent = self:GetOwner():GetEyeTrace().Entity
    if(!ent or !IsValid(ent)) then
        return
    end
    
    local data = ent.itemInventoryData


    if(ent.pickingUp) then
        DarkRP.notify(self:GetOwner(),1,4,"Someone else is already picking this item up")
        return false
    end   
    
    if(!data) then
        DarkRP.notify(self:GetOwner(),1,4,"You cannot add this to your inventory")
        return false
    end   


    if(manolis.popcorn.config.inventoryAddAllowed[ent:GetClass()]) then
        if(ent:GetPos():Distance(self:GetOwner():GetPos())>100) then
            return false
        end

        if(!data) then
            DarkRP.notify(self:GetOwner(),1,4,"You cannot pick this up")
            return false
        end
        

        ent.pickingUp = true
            
        manolis.popcorn.inventory.getFreeSlots(self:GetOwner(), function(amount)
            if(amount<1) then
                ent.pickingUp = false
                DarkRP.notify(self:GetOwner(),1,4,'You do not have enough inventory space to pick this up')
                return
            end
        
            manolis.popcorn.inventory.addWorldItem(self:GetOwner(), ent:GetItemData(), function(success)
                ent.pickingUp = false
                if(!success) then
                    DarkRP.notify(self:GetOwner(),1,4,"An error occurred adding the item to your inventory")
                    return
                else
                    ent:Remove()
                end
            end)         
                
        end)
       
    else
        DarkRP.notify(self:GetOwner(),1,4,"You cannot pick this up")
        return
    end

end

function SWEP:SecondaryAttack()
    if(CLIENT) then
        RunConsoleCommand("inventory")
    end

    return false
end

function SWEP:Reload()
    if(CLIENT) then
        RunConsoleCommand("inventory")
    end

    return false
end
function SWEP:CanPrimaryAttack() return true end
function SWEP:CanSecondaryAttack() return false end
