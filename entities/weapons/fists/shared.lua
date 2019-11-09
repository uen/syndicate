if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	resource.AddFile("materials/vgui/entities/fists_weapon.vtf")
	resource.AddFile("materials/vgui/entities/fists_weapon.vmt")
	resource.AddFile("models/weapons/v_fists_t.dx80.vtx")
	resource.AddFile("models/weapons/v_fists_t.dx90.vtx")
	resource.AddFile("models/weapons/v_fists_t.mdl")
	resource.AddFile("models/weapons/v_fists_t.sw.vtx")
	resource.AddFile("models/weapons/v_fists_t.vvd")
	resource.AddFile("models/weapons/v_fists_tt.dx90.vtx")
	resource.AddFile("models/weapons/w_fists_t.dx80.vtx")
	resource.AddFile("models/weapons/w_fists_t.dx90.vtx")
	resource.AddFile("models/weapons/w_fists_t.mdl")
	resource.AddFile("models/weapons/w_fists_t.phy")
	resource.AddFile("models/weapons/w_fists_t.sw.vtx")
	resource.AddFile("models/weapons/w_fists_t.vvd")
	resource.AddFile("sound/weapons/fist1.wav")
	resource.AddFile("sound/weapons/fist2.wav")
	resource.AddFile("sound/weapons/fist3.wav")
	resource.AddFile("sound/weapons/fist4.wav")
	resource.AddFile("sound/weapons/fistwall1.wav")
	resource.AddFile("sound/weapons/fistmiss1.wav")
	resource.AddFile("sound/weapons/fistmiss2.wav")

end

if (CLIENT) then

	SWEP.CrossHairScale = 0
	SWEP.ViewModelFOV	= 64
	SWEP.DrawCrosshair 	= false
	SWEP.DrawAmmo 		= false

end

SWEP.Base				= "weapon_base"
SWEP.Author				= "Manolis Vrondakis"
SWEP.Instructions		= "Punch players"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.PrintName 			= "Fists"
SWEP.Slot				= 3
SWEP.SlotPos			= 3

SWEP.ViewModel			= "models/weapons/v_fists_t.mdl"
SWEP.WorldModel			= "models/weapons/w_fists_t.mdl"
SWEP.ViewModelFlip		= false

SWEP.Primary.Ammo 		= "none"
SWEP.Secondary.Ammo		= "none"
SWEP.Primary.Automatic	= true
SWEP.Primary.Damage		= 0
SWEP.Primary.Delay		= 0.3

SWEP.Secondary.Delay	= 300

SWEP.FistHit			= 	"weapons/fistwall1.wav"
SWEP.FistHitFlesh		= {	"weapons/fist1.wav",
							"weapons/fist2.wav",
							"weapons/fist3.wav",
							"weapons/fist4.wav" }
SWEP.FistMiss			= {	"weapons/fistmiss1.wav",
							"weapons/fistmiss2.wav" }

SWEP.HoldType = "fist"
SWEP.ViewPunch			= Angle( 0, 0, 0 )
SWEP.Enabled = true

SWEP.AnimDeploy		= nil

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )
	
end

function SWEP:Precache()

	util.PrecacheSound("weapons/fist1.wav")
	util.PrecacheSound("weapons/fist2.wav")
	util.PrecacheSound("weapons/fist3.wav")
	util.PrecacheSound("weapons/fist4.wav")
	util.PrecacheSound("weapons/fistwall1.wav")
	util.PrecacheSound("weapons/fistmiss1.wav")
	util.PrecacheSound("weapons/fistmiss2.wav")

end

function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:Punch( self.Primary.Damage, self.FistHit, self.FistHitFlesh, self.FistMiss )

end

function SWEP:SecondaryAttack()

	if !self:CanSecondaryAttack() then return end
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	self:Toggle()

end

function SWEP:Toggle()
	if self.Enabled then

		self.Enabled = false
		self:SetWeaponHoldType( normal )
		self.Owner:DrawViewModel( false )
	
	else

		self.Enabled = true
		self:SetWeaponHoldType( self.HoldType )
		self.Owner:DrawViewModel( true )
	
	end
end

function SWEP:Punch( dmg, hitworld_sound, hitply_sound, miss_sound )

	local trace = util.TraceHull({start=self.Owner:GetShootPos(),
			endpos=self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50,
			mins=Vector(-8, -8, -8), maxs=Vector(8, 8, 8),
			filter=self.Owner})

	local sound = miss_sound
	if trace.Hit then
		if IsValid(trace.Entity) && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() ) then
			sound = hitply_sound
		else
			sound = hitworld_sound
		end
	end

	if sound && IsFirstTimePredicted() then
		if type(sound) == "table" then
			self.Weapon:EmitSound( sound[math.random(1, #sound)] )
		else
			self.Weapon:EmitSound( sound )
		end
	end

	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:ViewPunch( self.ViewPunch )

	if(IsValid(self.Owner) and self.Owner:getDarkRPVar('level')) then
		self.Primary.Damage = self.Owner:getDarkRPVar('level') or 1
	end
	if SERVER && IsValid( trace.Entity ) then
		if ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() ) then
	
			trace.Entity:TakeDamage( self.Primary.Damage, self.Owner )
			trace.Entity:SetVelocity( self.Owner:GetAimVector() * 10, 0 )
			
		else
			local phys = trace.Entity:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity( self.Owner:GetVelocity() + (self.Owner:GetAimVector() * 10) )
			end
		end			

	end
end

function SWEP:Deploy()

	self.Enabled = true
	self:SendWeaponAnim( self.AnimDeploy or ACT_VM_DRAW )
	
	return true

end

function SWEP:Reload() return false end
function SWEP:CanPrimaryAttack() return true end
function SWEP:CanSecondaryAttack() return false end