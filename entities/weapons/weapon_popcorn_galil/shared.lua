-- Read the weapon_real_base if you really want to know what each action does

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "ar2"
end

if (CLIENT) then
	SWEP.PrintName 		= "GALIL SAR 5.56MM"
	SWEP.Slot 			= 3
	SWEP.SlotPos 		= 1
	SWEP.IconLetter 		= "v"
	SWEP.ViewModelFlip	= false

	killicon.AddFont("weapon_real_cs_galil", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ))
end

SWEP.Instructions 		= "Damage: 25% \nRecoil: 6.5% \nPrecision: 83% \nType: Automatic \nRate of Fire: 650 rounds per minute \n\nChange Mode: E + Right Click"

SWEP.Base 				= "weapon_popcorn_base_rifle"

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 		= true

SWEP.ViewModel 			= "models/weapons/v_rif_galil.mdl"
SWEP.WorldModel 			= "models/weapons/w_rif_galil.mdl"

SWEP.Primary.Sound 		= Sound("Weapon_Galil.Single")
SWEP.Primary.Recoil 		= 0.65
SWEP.Primary.Damage 		= 25
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 		= 0.017
SWEP.Primary.ClipSize 		= 35
SWEP.Primary.Delay 		= 0.09
SWEP.Primary.DefaultClip 	= 35
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 		= "smg1"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.IronSightsPos 		= Vector(-5.15,-3,2.37)
SWEP.IronSightsAng 		= Vector(-.4,0,0)