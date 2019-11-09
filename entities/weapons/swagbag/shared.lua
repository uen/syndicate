AddCSLuaFile()

if SERVER then
    AddCSLuaFile("cl_menu.lua")
    include("sv_init.lua")
end

if CLIENT then
    include("cl_menu.lua")
end

SWEP.PrintName = "Swag Bag"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Base = "weapon_cs_base2"

SWEP.Author = "Manolis Vrondakis"
SWEP.Instructions = "Left click to pick up a printer/forge\nRight click to drop\nReload to open the menu"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.IconLetter = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix  = "rpg"
SWEP.WorldModel = ""

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "DarkRP (Utility)"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    return true
end

function SWEP:DrawWorldModel() end

function SWEP:PreDrawViewModel(vm)
    return true
end

function SWEP:Holster()
    if not SERVER then return true end

    self:GetOwner():DrawViewModel(true)
    self:GetOwner():DrawWorldModel(true)

    return true
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.2)

    if not SERVER then return end
    local ent = self:GetOwner():GetEyeTrace().Entity
    local canPickup, message = hook.Call("canSwagbag", GAMEMODE, self:GetOwner(), ent)

    if not canPickup then
        if message then DarkRP.notify(self:GetOwner(), 1, 4, message) end
        return
    end

    self:GetOwner():addSwagbagItem(ent)
end

function SWEP:SecondaryAttack()
    if not SERVER then return end

    local maxK = 0

    for k, v in pairs(self:GetOwner():getSwagbagItems()) do
        if k < maxK then continue end
        maxK = k
    end

    if maxK == 0 then
        DarkRP.notify(self:GetOwner(), 1, 4, DarkRP.getPhrase("swagbag_no_items"))
        return
    end

    self:GetOwner():dropSwagbagItem(maxK)
end

function SWEP:Reload()
    if not CLIENT then return end

    DarkRP.openSwagbagMenu()
end