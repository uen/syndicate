-- Read the weapon_real_base if you really want to know what each action does

/*---------------------------------------------------------*/
local HitImpact = function(attacker, tr, dmginfo)

	local hit = EffectData()
	hit:SetOrigin(tr.HitPos)
	hit:SetNormal(tr.HitNormal)
	hit:SetScale(20)
	util.Effect("effect_hit", hit)

	return true
end
/*---------------------------------------------------------*/

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType = "ar2"
end

if (CLIENT) then
	SWEP.PrintName 		= "COLT M4A1"
	SWEP.ViewModelFOV		= 60
	SWEP.Slot 			= 3
	SWEP.SlotPos 		= 1
	SWEP.IconLetter 		= "w"

	killicon.AddFont("weapon_real_cs_m4a1", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ))
end

SWEP.Instructions 		= "Damage: 20% \nRecoil: 5% \nPrecision: 88% \nType: Automatic \nRate of Fire: 780 rounds per minute \n\nChange Mode: E + Right Click \nSilence Mode: E + Left Click"

SWEP.Base 				= "weapon_popcorn_base_special_aim"

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 		= true

SWEP.ViewModel 			= "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel 			= "models/weapons/w_rif_m4a1.mdl"

SWEP.Primary.Sound 		= Sound("Weapon_M4A1.Single")
SWEP.Primary.Damage 		= 20
SWEP.Primary.Recoil 		= 0.5
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 		= 0.012
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 		= 0.08
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 		= "smg1"

SWEP.IronSightsPos 		= Vector (3.963, -3.271, 1.7058)
SWEP.IronSightsAng 		= Vector (1.5025, 0.6891, 0)

SWEP.data 				= {}
SWEP.mode 				= "auto"

SWEP.data.semi 			= {}

SWEP.data.auto 			= {}

/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/
function SWEP:Initialize()

	self.data.sync = true
	self.data.init = true
	
	if (SERVER) then
		self:SetWeaponHoldType(self.HoldType)
	end

	self.Reloadaftershoot = 0

	self.data[self.mode].Init(self)
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()

	if self.data.init then		
		self.data.init = nil
	end

	if self.deployed then
		if self.deployed == 0 then
			if self.data.silenced then
				self.Weapon:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
			else
				self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
			end
			self.deployed = false
			self.Weapon:SetNextPrimaryFire( CurTime() + .001 )
		else
			self.deployed = self.deployed - 1
		end
	end

	if (self:GetIronsights() == true) then
			self.DrawCrosshair = true
	else
			self.DrawCrosshair = false
	end

	self:IronSight()
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	if !self.Owner:KeyDown(IN_USE) then

		if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
		-- If your gun have a problem or if you are under water, you'll not be able to fire

		self.Reloadaftershoot = CurTime() + self.Primary.Delay
		-- Set the reload after shoot to be not able to reload when firering

		self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
		-- Set next secondary fire after your fire delay

		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		-- Set next primary fire after your fire delay

		self:TakePrimaryAmmo(1)
		-- Take 1 ammo in you clip

		self.Weapon:EmitSound(self.Primary.Sound)
		-- Emit the gun sound when you fire
	
		self:RecoilPower()

	else
		if self.data.silenced then
			self.Weapon:SendWeaponAnim(ACT_VM_DETACH_SILENCER)
			self.Primary.Sound			= Sound("Weapon_M4A1.Single")
			self.data.silenced = false
		else
			self.Weapon:SendWeaponAnim(ACT_VM_ATTACH_SILENCER)
			self.Primary.Sound			= Sound("Weapon_M4A1.Silenced")
 			self.data.silenced = true
		end
		self.Weapon:SetNextPrimaryFire( CurTime() + 2 )
		self.Reloadaftershoot = CurTime() + 2
	end
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	if self.Owner:KeyDown(IN_USE) then
		if self.mode == "semi" then
			self.mode = "auto"
		else
			self.mode = "semi"
		end
		self.data[self.mode].Init(self)
		
		if self.mode == "auto" then
			self.Weapon:SetNetworkedInt("csef",1)
		elseif self.mode == "semi" then
			self.Weapon:SetNetworkedInt("csef",3)
		end

	elseif SERVER then
	end
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()

	if ( self.Reloadaftershoot > CurTime() ) then return end 
	-- If you're firering, you can't reload

	if not IsValid(self.Owner) then return end

	if self.data.silenced then
		self.Weapon:DefaultReload(ACT_VM_RELOAD_SILENCED)
	else
		self.Weapon:DefaultReload(ACT_VM_RELOAD)
	end

	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then

		self.Owner:SetFOV( 0, 0.15 )
		-- Zoom = 0

		self:SetIronsights(false)
		-- Set the ironsight to false
	end

	return true
end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	if self.data.silenced then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
	else
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	end

	self.Reloadaftershoot = CurTime() + 1
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)

	return true
end

/*---------------------------------------------------------
ShootEffects
---------------------------------------------------------*/
function SWEP:CSShootBullet(dmg, recoil, numbul, cone)

	numbul 		= numbul or 1
	cone 			= cone or 0.01

	local bullet 	= {}
	bullet.Num  	= numbul
	bullet.Src 		= self.Owner:GetShootPos()       					-- Source
	bullet.Dir 		= self.Owner:GetAimVector()      					-- Dir of bullet
	bullet.Spread 	= Vector(cone, cone, 0)     						-- Aim Cone
	bullet.Tracer 	= 1       									-- Show a tracer on every x bullets
	bullet.Force 	= 0.5 * dmg     								-- Amount of force to give to phys objects
	bullet.Damage 	= dmg										-- Amount of damage to give to the bullets
	bullet.Callback 	= HitImpact
--	bullet.Callback	= function ( a, b, c ) BulletPenetration( 0, a, b, c ) end

	self.Owner:FireBullets(bullet)
	if self.data.silenced then
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)
		self.MuzzleEffect			= "rg_muzzle_silenced"
	else
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self.Owner:MuzzleFlash()
		self.MuzzleEffect			= "rg_muzzle_hmg"
	end
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	local fx 		= EffectData()
	fx:SetEntity(self.Weapon)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetAttachment(self.MuzzleAttachment)
	util.Effect(self.MuzzleEffect,fx)					-- Additional muzzle effects
	
	timer.Simple( self.EjectDelay, function()
		if  not IsFirstTimePredicted() then 
			return
		end

			local fx 	= EffectData()
			fx:SetEntity(self.Weapon)
			fx:SetNormal(self.Owner:GetAimVector())
			fx:SetAttachment(self.ShellEjectAttachment)

			util.Effect(self.ShellEffect,fx)				-- Shell ejection
	end)

	if (CLIENT) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles(eyeang)
	end
end