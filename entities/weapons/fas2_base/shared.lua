if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_drawfuncs.lua")
	AddCSLuaFile("cl_model.lua")
	AddCSLuaFile("cl_umsgs.lua")
	AddCSLuaFile("cl_hud.lua")
	AddCSLuaFile("sh_bullet.lua")
	AddCSLuaFile("cl_calcview.lua")
	AddCSLuaFile("cl_muzzleflash.lua")
	AddCSLuaFile("cl_attachments.lua")
	AddCSLuaFile("cl_cmodel_manager.lua")
	
	include("sv_attachments.lua")
	
	umsg.PoolString("FAS2_SUPPRESSMODEL")
	umsg.PoolString("FAS2_UNSUPPRESSMODEL")
end

include("sh_bullet.lua")

if CLIENT then
	include("cl_model.lua")
	include("cl_umsgs.lua")
	include("cl_hud.lua")
	include("cl_calcview.lua")
	include("cl_muzzleflash.lua")
	include("cl_drawfuncs.lua")
	include("cl_attachments.lua")
	include("cl_cmodel_manager.lua")
	
	SWEP.BounceWeaponIcon = false
	SWEP.PitchMod = 1
	SWEP.YawMod = 1
	SWEP.CrossAlpha = 255
	SWEP.CheckTime = 0
	SWEP.CrossAlpha = 255
	SWEP.CrossAmount = 100
	SWEP.CurFOVMod = 0
	SWEP.AngleDelta = Angle(0, 0, 0)
	SWEP.OldDelta = Angle(0, 0, 0)
	SWEP.ProficientTextTime = 0
	SWEP.ProficientAlpha = 0
	SWEP.CockRemindTime = 0
	SWEP.CockRemindAlpha = 0
	SWEP.MouseSensMod = 1
	SWEP.DeployAnimSpeed = 1
	SWEP.CurAnim = "none"
	SWEP.BoltReminderText = "RELOAD KEY - BOLT WEAPON"
	SWEP.PrintName = ""
	SWEP.Slot = 3
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.MoveType = 1
	SWEP.ReloadCycleTime = 0.9
	SWEP.ShowStats = false
	SWEP.WMAng = Vector(0, 0, 0)
	SWEP.WMPos = Vector(0, 0, 0)
	SWEP.Text3DForward = -4
	SWEP.Text3DRight = -2
	SWEP.Text3DSize = 0.015
	SWEP.WMScale = 1
	SWEP.BlurAmount = 0
	SWEP.HitMarkerAlpha = 0
	SWEP.HitMarkerTime = 0
	SWEP.MagText = "MAG " 
	SWEP.FireModeSwitchTime = 0
	SWEP.SwayInterpolation = "dynamic"
	
	surface.CreateFont("FAS2_HUD72", {font = "Default", size = 72, weight = 700, blursize = 0, antialias = true, shadow = false})
	surface.CreateFont("FAS2_HUD48", {font = "Default", size = 48, weight = 700, blursize = 0, antialias = true, shadow = false})
	surface.CreateFont("FAS2_HUD36", {font = "Default", size = 36, weight = 700, blursize = 0, antialias = true, shadow = false})
	surface.CreateFont("FAS2_HUD28", {font = "Default", size = 28, weight = 700, blursize = 0, antialias = true, shadow = false})
	surface.CreateFont("FAS2_HUD24", {font = "Default", size = 24, weight = 700, blursize = 0, antialias = true, shadow = false})
	
	SWEP.CurSoundTable = nil
	SWEP.CurSoundEntry = nil
	SWEP.HideWorldModel = true
	
	SWEP.CustomizePos = Vector(5.657, -1.688, -2.027)
	SWEP.CustomizeAng = Vector(14.647, 30.319, 15.295)
	SWEP.BipodPos = Vector(0, 0, 0)
	SWEP.BipodAng = Vector(0, 0, 0)
	SWEP.PistolSafePos = Vector(0, 0, 1.203)
	SWEP.PistolSafeAng = Vector(-15.125, 0, 0)
	SWEP.RifleSafePos = Vector(0.324, 0.092, -0.621)
	SWEP.RifleSafeAng = Vector(-8.941, 7.231, -9.535)
	SWEP.BipodMoveTime = 0
	SWEP.SafePosType = "rifle"
end

SWEP.AimSounds = {"weapons/weapon_sightlower.wav", "weapons/weapon_sightlower2.wav"}
SWEP.BackToHipSounds = {"weapons/weapon_sightraise.wav", "weapons/weapon_sightraise2.wav"}
SWEP.EmptySound = Sound("weapons/empty_submachineguns.wav")
SWEP.RunHoldType = "passive"
SWEP.ReloadState = 0
SWEP.BipodDelay = 0
SWEP.BurstFireDelayMod = 0.66
SWEP.ShotToDelayUntil = 0

SWEP.SpreadWait = 0
SWEP.AddSpread = 0
SWEP.AddSpreadSpeed = 1
SWEP.IsFAS2Weapon = true
SWEP.Events = {}

SWEP.SprintDelay = 0
SWEP.ReloadWait = 0
SWEP.MagCheckAlpha = 0
SWEP.ReloadProgress = 0
SWEP.Suppressed = false
SWEP.PenMod = 1

SWEP.PenetrationEnabled = true
SWEP.RicochetEnabled = true

FAS_STAT_IDLE = 0
FAS_STAT_ADS = 1
FAS_STAT_SPRINT = 2
FAS_STAT_HOLSTER = 3
FAS_STAT_CUSTOMIZE = 4
FAS_STAT_HOLSTER_START = 5
FAS_STAT_HOLSTER_END = 6
FAS_STAT_QUICKGRENADE = 7

SWEP.Author            = "Spy"
SWEP.Instructions    = "CONTEXT MENU KEY - Open customization menu\nUSE + RELOAD KEY - Change firemode\nUSE KEY + PRIMARY ATTACK KEY - Quick grenade"
SWEP.Contact        = ""
SWEP.Purpose        = ""
SWEP.HoldType = "ar2"
SWEP.FirstDeploy = true

SWEP.ViewModelFOV    = 55
SWEP.ViewModelFlip    = false

SWEP.Spawnable            = false
SWEP.AdminSpawnable        = false

SWEP.ViewModel      = "models/Items/AR2_Grenade.mdl"
SWEP.WorldModel   = ""

-- Primary Fire Attributes --
SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic       = false    
SWEP.Primary.Ammo             = "none"

-- Secondary Fire Attributes --
SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Automatic = true --       = true
SWEP.Secondary.Ammo         = "none"

SWEP.FireModeNames = {["auto"] = {display = "FULL-AUTO", auto = true, burstamt = 0},
["semi"] = {display = "SEMI-AUTO", auto = false, burstamt = 0},
["double"] = {display = "DOUBLE-ACTION", auto = false, burstamt = 0},
["bolt"] = {display = "BOLT-ACTION", auto = false, burstamt = 0},
["pump"] = {display = "PUMP-ACTION", auto = false, burstamt = 0},
["break"] = {display = "BREAK-ACTION", auto = false, burstamt = 0},
["2burst"] = {display = "2-ROUND BURST", auto = true, burstamt = 2},
["3burst"] = {display = "3-ROUND BURST", auto = true, burstamt = 3},
["safe"] = {display = "SAFE", auto = false, burstamt = 0}}	

local vm, t, a

function SWEP:SetupDataTables()
	self:DTVar("Int", 0, "Status")
	self:DTVar("Int", 1, "Shots")
	
	self:DTVar("Bool", 0, "Suppressed")
	self:DTVar("Bool", 1, "Bipod")
	self:DTVar("Bool", 2, "Holstered")
end

function SWEP:CalculateEffectiveRange()
	self.EffectiveRange = self.CaseLength * 10 - self.BulletLength * 5 -- setup realistic base effective range
	self.EffectiveRange = self.EffectiveRange * 39.37 -- convert meters to units
	self.EffectiveRange = self.EffectiveRange / 2
	self.DamageFallOff = (100 - (self.CaseLength - self.BulletLength)) / 200
	self.PenStr = (self.BulletLength * 0.5 + self.CaseLength * 0.35) * (self.PenAdd and self.PenAdd or 1)
end

local SP = game.SinglePlayer()
local reg = debug.getregistry()
local GetVelocity = reg.Entity.GetVelocity
local Length = reg.Vector.Length
local GetAimVector = reg.Player.GetAimVector

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)

	self.upgrades = {}
	self.t = {}
	self.item = {}
	
	self.CurCone = self.HipCone
	self.Class = self:GetClass()
	
	table.insert(self.FireModes, #self.FireModes + 1, "safe")
	t = self.FireModes[1]
	self.FireMode = t
	t = self.FireModeNames[t]
	
	self.Primary.Auto = t.auto
	self.BurstAmount = t.burstamt
	self.dt.Suppressed = self.Suppressed
	self:CalculateEffectiveRange()
	
	self.Damage_Orig = self.Damage
	self.FireDelay_Orig = self.FireDelay
	self.HipCone_Orig = math.Round(self.HipCone, 4)
	self.AimCone_Orig = math.Round(self.AimCone, 4)
	self.Recoil_Orig = math.Round(self.Recoil, 4)
	self.SpreadPerShot_Orig = self.SpreadPerShot
	self.MaxSpreadInc_Orig = self.MaxSpreadInc
	self.VelocitySensitivity_Orig = self.VelocitySensitivity
	self.AimPosName = "AimPos"
	self.AimAngName = "AimAng"
	
	if not self.Owner.FAS_FamiliarWeapons then
		self.Owner.FAS_FamiliarWeapons = {}
	end
	
	if CLIENT then
		self.BlendPos = Vector(0, 0, 0)
		self.BlendAng = Vector(0, 0, 0)
		
		self.NadeBlendPos = Vector(0, 0, 0)
		self.NadeBlendAng = Vector(0, 0, 0)
		self.FireModeDisplay = t.display
		
		self.AimPos_Orig = self.AimPos
		self.AimAng_Orig = self.AimAng
		self.AimFOV_Orig = self.AimFOV
		self.ViewModelFOV_Orig = self.ViewModelFOV
		
		self.TargetViewModelFOV_Orig = self.TargetViewModelFOV
		self.TargetViewModelFOV = self.TargetViewModelFOV or self.ViewModelFOV
		
		if not self.Wep then
			self.Wep = self:createManagedCModel(self.VM, RENDERGROUP_BOTH)
			self.Wep:SetNoDraw(true)
		end
		
		if not self.W_Wep and self.WM then
			self.W_Wep = self:createManagedCModel(self.WM, RENDERGROUP_BOTH)
			self.W_Wep:SetNoDraw(true)
		end
		
		if not self.Nade then
			self.Nade = self:createManagedCModel("models/weapons/v_m67.mdl", RENDERGROUP_BOTH)
			self.Nade:SetNoDraw(true)
			self.Nade.LifeTime = 0
		end
		
		RunConsoleCommand("fas2_handrig_applynow")		
	end
end

if SERVER then
	function SWEP:Upgrade(ply, id, item)
		self.item = item

		if(!ply.popcorn) then ply.popcorn = {} end
		if(!ply.popcorn.weapons) then ply.popcorn.weapons = {} end

		manolis.popcorn.inventory.retrieveItem(ply,id,function(data)
			if(!data) then return end
			self.t = data
			ply.popcorn.weapons[data.type] = data
			local dcD = {}
			if(data.json) then
				if(data.json.upgrades) then
					
					for k,v in pairs(data.json.upgrades) do
						if(manolis.popcorn.upgrades.upgrades[data.json.type]) then
							if(manolis.popcorn.upgrades.upgrades[data.json.type][v.class]) then
								if(!dcD[v.class]) then 
									dcD[v.class] = 0
								end 
								if(manolis.popcorn.upgrades.upgrades[data.json.type][v.class].levels) then
									dcD[v.class] = dcD[v.class] + manolis.popcorn.upgrades.upgrades[data.json.type][v.class].levels[v.level]    
								end         
							end
						end
					end
				end
			end
			
			self.upgrades = dcD
			ply.popcorn.weapons[data.type].upgrades = dcD
			
			if(self:GetOwner().upgrades and self:GetOwner().upgrades.accuracyboost) then
				self.Recoil = math.max(0,self.Recoil-(self.Recoil*(self:GetOwner().upgrades.accuracyboost/100)))
			end    
		end)
		
	end
end


local mag, CT, ang, cone, vel, ammo

function SWEP:CockLogic()
	if self.Owner.FAS_FamiliarWeapons[self.Class] then
		if self.dt.Status == FAS_STAT_ADS then
			if self.dt.Bipod then
				FAS2_PlayAnim(self, self.Anims.Cock_Bipod_Aim_Nomen)
			else
				FAS2_PlayAnim(self, self.Anims.Cock_Aim_Nomen)
			end
			
			self.Cocked = true
		else
			if self.dt.Bipod then
				FAS2_PlayAnim(self, self.Anims.Cock_Bipod_Nomen)
			else
				FAS2_PlayAnim(self, self.Anims.Cock_Nomen)
			end
			
			self.Cocked = true
		end
		
		if self.dt.Bipod then
			self:SetNextPrimaryFire(CT + self.CockTime_Bipod_Nomen)
			self:SetNextSecondaryFire(CT + self.CockTime_Bipod_Nomen)
			self.SprintWait = CT + self.CockTime_Bipod_Nomen
			self.ReloadWait = CT + self.CockTime_Bipod_Nomen
			self.BipodDelay = CT + self.CockTime_Bipod_Nomen
		else
			self:SetNextPrimaryFire(CT + self.CockTime_Nomen)
			self:SetNextSecondaryFire(CT + self.CockTime_Nomen)
			self.SprintWait = CT + self.CockTime_Nomen
			self.ReloadWait = CT + self.CockTime_Nomen
			self.BipodDelay = CT + self.CockTime_Nomen
		end
	else
		if self.dt.Status == FAS_STAT_ADS then
			if self.dt.Bipod then
				FAS2_PlayAnim(self, self.Anims.Cock_Bipod_Aim)
			else
				FAS2_PlayAnim(self, self.Anims.Cock_Aim)
			end
			
			self.Cocked = true
		else
			if self.dt.Bipod then
				FAS2_PlayAnim(self, self.Anims.Cock_Bipod)
			else
				FAS2_PlayAnim(self, self.Anims.Cock)
			end
			
			self.Cocked = true
		end
		
		if self.dt.Bipod then
			self:SetNextPrimaryFire(CT + self.CockTime_Bipod)
			self:SetNextSecondaryFire(CT + self.CockTime_Bipod)
			self.SprintWait = CT + self.CockTime_Bipod
			self.ReloadWait = CT + self.CockTime_Bipod
			self.BipodDelay = CT + self.CockTime_Bipod
		else
			self:SetNextPrimaryFire(CT + self.CockTime)
			self:SetNextSecondaryFire(CT + self.CockTime)
			self.SprintWait = CT + self.CockTime
			self.ReloadWait = CT + self.CockTime
			self.BipodDelay = CT + self.CockTime
		end
	end
end

function SWEP:AddEvent(time, func)
	table.insert(self.Events, {time = CurTime() + time, func = func})
end

function SWEP:Reload()
	CT = CurTime()
	
	if CT < self.ReloadWait then
		return
	end
	
	if self.ReloadDelay and CT < self.ReloadDelay then
		return
	end
	
	if self.Owner:KeyDown(IN_USE) then
		self:CycleFiremodes()
		return
	end
	
	if self.FireMode == "safe" then
		if SERVER and SP then
			SendUserMessage("FAS2_CHECKWEAPON", self.Owner)
		end
		
		if CLIENT then
			self.CheckTime = CT + 0.5
		end
		
		return
	end
	
	if self.dt.Status == FAS_STAT_ADS then
		return
	end
	
	if self.CockAfterShot and not self.Cocked then
		self:CockLogic()
	end
	
	mag = self:Clip1()
	
	if (not self.CantChamber and mag >= self.Primary.ClipSize + 1 or self.CantChamber and mag >= self.Primary.ClipSize) or self.Owner:GetAmmoCount(self.Primary.Ammo) == 0 then
		if SERVER and SP then
			SendUserMessage("FAS2_CHECKWEAPON", self.Owner)
		end
		
		if CLIENT then
			self.CheckTime = CT + 0.5
		end
		
		return
	end
	
	if SERVER then
		self.dt.Status = FAS_STAT_IDLE
	end
	
	if mag == 0 then
		if self.Owner.FAS_FamiliarWeapons[self.Class] then
			if self.dt.Bipod then
				FAS2_PlayAnim(self, self.Anims.Reload_Bipod_Empty_Nomen)
				self.ReloadDelay = CT + self.ReloadTime_Bipod_Empty_Nomen + 0.3
				self:SetNextPrimaryFire(CT + self.ReloadTime_Bipod_Empty_Nomen + 0.3)
				self:SetNextSecondaryFire(CT + self.ReloadTime_Bipod_Empty_Nomen + 0.3)
			else
				FAS2_PlayAnim(self, self.Anims.Reload_Empty_Nomen)
				self.ReloadDelay = CT + self.ReloadTime_Empty_Nomen + 0.3
				self:SetNextPrimaryFire(CT + self.ReloadTime_Empty_Nomen + 0.3)
				self:SetNextSecondaryFire(CT + self.ReloadTime_Empty_Nomen + 0.3)
			end
		else
			if self.dt.Bipod then
				FAS2_PlayAnim(self, self.Anims.Reload_Bipod_Empty)
				self.ReloadDelay = CT + self.ReloadTime_Bipod_Empty + 0.3
				self:SetNextPrimaryFire(CT + self.ReloadTime_Bipod_Empty + 0.3)
				self:SetNextSecondaryFire(CT + self.ReloadTime_Bipod_Empty + 0.3)
			else
				FAS2_PlayAnim(self, self.Anims.Reload_Empty)
				self.ReloadDelay = CT + self.ReloadTime_Empty + 0.3
				self:SetNextPrimaryFire(CT + self.ReloadTime_Empty + 0.3)
				self:SetNextSecondaryFire(CT + self.ReloadTime_Empty + 0.3)
			end
		end
	else
		if self.Owner.FAS_FamiliarWeapons[self.Class] then
			if self.dt.Bipod then
				FAS2_PlayAnim(self, self.Anims.Reload_Bipod_Nomen)
				self.ReloadDelay = CT + self.ReloadTime_Bipod_Nomen + 0.3
				self:SetNextPrimaryFire(CT + self.ReloadTime_Bipod_Nomen + 0.3)
				self:SetNextSecondaryFire(CT + self.ReloadTime_Bipod_Nomen + 0.3)
			else
				FAS2_PlayAnim(self, self.Anims.Reload_Nomen)
				self.ReloadDelay = CT + self.ReloadTime_Nomen + 0.3
				self:SetNextPrimaryFire(CT + self.ReloadTime_Nomen + 0.3)
				self:SetNextSecondaryFire(CT + self.ReloadTime_Nomen + 0.3)
			end
		else
			if self.dt.Bipod then
				FAS2_PlayAnim(self, self.Anims.Reload_Bipod)
				self.ReloadDelay = CT + self.ReloadTime_Bipod + 0.3
				self:SetNextPrimaryFire(CT + self.ReloadTime_Bipod + 0.3)
				self:SetNextSecondaryFire(CT + self.ReloadTime_Bipod + 0.3)
			else
				FAS2_PlayAnim(self, self.Anims.Reload)
				self.ReloadDelay = CT + self.ReloadTime + 0.3
				self:SetNextPrimaryFire(CT + self.ReloadTime + 0.3)
				self:SetNextSecondaryFire(CT + self.ReloadTime + 0.3)
			end
		end
	end
	
	self.Owner:SetAnimation(PLAYER_RELOAD)
end

function SWEP:PlayDeployAnim()
	if self:Clip1() == 0 and self.Anims.Draw_Empty then
		FAS2_PlayAnim(self, self.Anims.Draw_Empty, self.DeployAnimSpeed)
	else
		FAS2_PlayAnim(self, self.Anims.Draw, self.DeployAnimSpeed)
	end
end

function SWEP:Deploy()
	if not IsValid(self.Owner) then
		return false
	end
	
	if not self.FirstDeploy then
		CT = CurTime()
		
		if (CLIENT and not IsFirstTimePredicted()) then
			self:SetNextPrimaryFire(CT + (self.DeployTime and self.DeployTime or 1))
			self:SetNextSecondaryFire(CT + (self.DeployTime and self.DeployTime or 1))
			self.ReloadWait = CT + (self.DeployTime and self.DeployTime or 1)
			self.SprintDelay = CT + (self.DeployTime and self.DeployTime or 1)
		else
			self:SetNextPrimaryFire(CT + (self.DeployTime and self.DeployTime or 1))
			self:SetNextSecondaryFire(CT + (self.DeployTime and self.DeployTime or 1))
			self.ReloadWait = CT + (self.DeployTime and self.DeployTime or 1)
			self.SprintDelay = CT + (self.DeployTime and self.DeployTime or 1)
		end
		
		self:PlayDeployAnim()
	else
		if SP and SERVER then
			a = self.Anims.Draw_First
			
			if type(a) == "table" then
				a = table.Random(a)
			end
			
			FAS2_PlayAnim(self, a, 1, 0, self.Owner:Ping() / 1000)
		end
		
		//self.CurSoundTable = self.Sounds[a]
		//self.CurSoundEntry = 1
		//self.SoundSpeed = 1
		//self.SoundTime = CT + 0.175 + self:GetOwner():Ping() / 1000
		//self.CurAnim = a
		
		CT = CurTime()
		
		self:SetNextPrimaryFire(CT + (self.FirstDeployTime and self.FirstDeployTime or 1))
		self:SetNextSecondaryFire(CT + (self.FirstDeployTime and self.FirstDeployTime or 1))
		self.ReloadWait = CT + (self.FirstDeployTime and self.FirstDeployTime or 1)
		self.SprintDelay = CT + (self.FirstDeployTime and self.FirstDeployTime or 1)
		self.FirstDeploy = false
	end
	
	if CLIENT then
		self.Peeking = false
	end
	
	if not self.Owner.FAS_FamiliarWeapons then
		self.Owner.FAS_FamiliarWeapons = {}
	end
	
	if SERVER then
		if not self.Owner.FAS_FamiliarWeaponsProgress then
			self.Owner.FAS_FamiliarWeaponsProgress = {}
		end
	end
	
	self.dt.Status = FAS_STAT_IDLE
	self:EmitSound("weapons/weapon_deploy" .. math.random(1, 3) .. ".wav", 50, 100)
	
	return true
end

function SWEP:CycleFiremodes()
	t = self.FireModes
	
	if not t.last then
		t.last = 2
	else
		if not t[t.last + 1] then
			t.last = 1
		else
			t.last = t.last + 1
		end
	end
	
	if self.dt.Status == FAS_STAT_ADS then
		if self.FireModes[t.last] == "safe" then
			t.last = 1
		end
	end
	
	if self.FireMode != self.FireModes[t.last] and self.FireModes[t.last] then
		self:SelectFiremode(self.FireModes[t.last])
		self:SetNextPrimaryFire(CT + 0.25)
		self:SetNextSecondaryFire(CT + 0.25)
		self.ReloadWait = CT + 0.25
	end
end

function SWEP:DelayMe(t)
	t = t + 0.1
	self:SetNextPrimaryFire(t)
	self:SetNextSecondaryFire(t)
	self.ReloadWait = t
end

function SWEP:SelectFiremode(n)
	CT = CurTime()
	
	if CLIENT then
		return
	end
	
	t = self.FireModeNames[n]
	self.Primary.Automatic = t.auto
	self.FireMode = n
	self.BurstAmount = t.burstamt
	
	if self.FireMode == "safe" then
		self.dt.Holstered = true -- more reliable than umsgs
	else
		self.dt.Holstered = false
	end
	
	umsg.Start("FAS2_FIREMODE")
	umsg.Entity(self.Owner)
	umsg.String(n)
	umsg.End()
end

function SWEP:PlayHolsterAnim()
	if self:Clip1() == 0 and self.Anims.Holster_Empty then
		FAS2_PlayAnim(self, self.Anims.Holster_Empty)
	else
		FAS2_PlayAnim(self, self.Anims.Holster)
	end
end

function SWEP:Holster(wep)
	if self == wep then
		return
	end
	
	if self.dt.Status == FAS_STAT_HOLSTER_END then
		self.dt.Status = FAS_STAT_IDLE
		self.ReloadDelay = nil
		return true
	end
	
	if self.ReloadDelay or CurTime() < self.ReloadWait then
		return false
	end
	
	if IsValid(wep) and self.dt.Status != FAS_STAT_HOLSTER_START then
		CT = CurTime()
		
		self:SetNextPrimaryFire(CT + (self.HolsterTime and self.HolsterTime * 2 or 0.75))
		self:SetNextSecondaryFire(CT + (self.HolsterTime and self.HolsterTime * 2 or 0.75))
		self.ReloadWait = CT + (self.HolsterTime and self.HolsterTime * 2 or 0.75)
		self.SprintDelay = CT + (self.HolsterTime and self.HolsterTime * 2 or 0.75)
		
		self.ChosenWeapon = wep:GetClass()
		
		if self.dt.Status != FAS_STAT_HOLSTER_END then
			timer.Simple((self.HolsterTime and self.HolsterTime or 0.45), function()
				if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
					self.dt.Status = FAS_STAT_HOLSTER_END
					self.dt.Bipod = false
					self.Owner:ConCommand("use " .. self.ChosenWeapon)
					//RunConsoleCommand("use", self.ChosenWeapon)
					//if SERVER then
						//	self.Owner:SelectWeapon(self.ChosenWeapon)
						//end
					end
				end)
			end
			
			self.dt.Status = FAS_STAT_HOLSTER_START
			self:PlayHolsterAnim()
		end
		
		//self:EmitSound("Generic_Cloth", 70, 100)
		
		if CLIENT then
			self.CurSoundTable = nil
			self.CurSoundEntry = nil
			self.SoundTime = nil
			self.SoundSpeed = 1
		end
		
		if SERVER and SP then
			SendUserMessage("FAS2_ENDSOUNDS", self.Owner)
		end
		
		self:EmitSound("weapons/weapon_holster" .. math.random(1, 3) .. ".wav", 50, 100)
		return false
	end
	
	local mod, cr, tr, aim
	
	local td = {}
	
	function SWEP:PlayFireAnim(mag)
		if self.dt.Status == FAS_STAT_ADS then
			if mag == 1 and (self.Anims.Fire_Aiming_Last or self.Anims.Fire_Bipod_Aiming_Last) then
				if self.dt.Bipod then
					FAS2_PlayAnim(self, self.Anims.Fire_Bipod_Aiming_Last and self.Anims.Fire_Bipod_Aiming_Last or self.Anims.Fire_Bipod_Last)
				else
					FAS2_PlayAnim(self, self.Anims.Fire_Aiming_Last and self.Anims.Fire_Aiming_Last or self.Anims.Fire_Last)
				end
			else
				if self.dt.Bipod then
					FAS2_PlayAnim(self, self.Anims.Fire_Bipod_Aiming and self.Anims.Fire_Bipod_Aiming or self.Anims.Fire_Bipod)
				else
					FAS2_PlayAnim(self, self.Anims.Fire_Aiming and self.Anims.Fire_Aiming or self.Anims.Fire)
				end
			end
		else
			if mag == 1 and (self.Anims.Fire_Last or self.Anims.Fire_Bipod_Last) then
				if self.dt.Bipod then
					FAS2_PlayAnim(self, self.Anims.Fire_Bipod_Last)
				else
					FAS2_PlayAnim(self, self.Anims.Fire_Last)
				end
			else
				if self.dt.Bipod then
					FAS2_PlayAnim(self, self.Anims.Fire_Bipod)
				else
					FAS2_PlayAnim(self, self.Anims.Fire)
				end
			end
		end
	end
	
	local ef
	
	function SWEP:AimRecoil(mul)
		mul = mul or 1
		mod = self.Owner:Crouching() and 0.75 or 1
		
		self.Owner:ViewPunch(Angle(-self.ViewKick, self.ViewKick * math.Rand(-0.2475, 0.2475), 0) * (1 + self.AddSpread * (self.SpreadToRecoil and self.SpreadToRecoil or 1)) * mod * (self.dt.Bipod and 0.3 or 1) * mul)
		
		if (SERVER and SP) or CLIENT then
			ang = self.Owner:EyeAngles()
			ang.p = ang.p - self.Recoil * (1 + self.AddSpread * (self.SpreadToRecoil and self.SpreadToRecoil or 1)) * mod * (self.dt.Bipod and 0.3 or 1) * mul
			ang.y = ang.y - self.Recoil * math.Rand(-0.375, 0.375) * (1 + self.AddSpread * (self.SpreadToRecoil and self.SpreadToRecoil or 1)) * mod * (self.dt.Bipod and 0.3 or 1) * mul
			self.Owner:SetEyeAngles(ang)
		end
	end
	
	function SWEP:HipRecoil(mul)
		mul = mul or 1
		mod = self.Owner:Crouching() and 0.75 or 1
		
		self.Owner:ViewPunch(Angle(-self.ViewKick, self.ViewKick * math.Rand(-0.33, 0.33), 0) * (1 + self.AddSpread * (self.SpreadToRecoil and self.SpreadToRecoil or 1)) * mod * (self.dt.Bipod and 0.3 or 1) * mul)
		
		if (SERVER and SP) or CLIENT then
			ang = self.Owner:EyeAngles()
			ang.p = ang.p - self.Recoil * (1 + self.AddSpread * (self.SpreadToRecoil and self.SpreadToRecoil or 1)) * mod * (self.dt.Bipod and 0.3 or 1) * mul
			ang.y = ang.y - self.Recoil * math.Rand(-0.5, 0.5) * (1 + self.AddSpread * (self.SpreadToRecoil and self.SpreadToRecoil or 1)) * mod * (self.dt.Bipod and 0.3 or 1) * mul
			self.Owner:SetEyeAngles(ang)
		end
	end
	
	function SWEP:PrimaryAttack()
		if self.FireMode == "safe" then
			if IsFirstTimePredicted() then
				self:CycleFiremodes()
			end
			
			return
		end
		
		if IsFirstTimePredicted() then
			if self.BurstAmount > 0 and self.dt.Shots >= self.BurstAmount then
				return
			end
			
			if self.ReloadState != 0 then
				self.ReloadState = 3
				return
			end
			
			if self.dt.Status == FAS_STAT_CUSTOMIZE then
				return
			end
			
			if self.Cooking or self.FuseTime then
				return
			end
			
			if self.Owner:KeyDown(IN_USE) then
				if self:CanThrowGrenade() then
					self:InitialiseGrenadeThrow()
					return
				end
			end
			
			if self.dt.Status == FAS_STAT_SPRINT or self.dt.Status == FAS_STAT_QUICKGRENADE then
				return
			end
			
			td.start = self.Owner:GetShootPos()
			td.endpos = td.start + self.Owner:GetAimVector() * 30
			td.filter = self.Owner
			
			tr = util.TraceLine(td)
			
			if tr.Hit then
				return
			end
			
			mag = self:Clip1()
			CT = CurTime()
			
			if mag <= 0 or self.Owner:WaterLevel() >= 3 then
				self:EmitSound(self.EmptySound, 60, 100)
				self:SetNextPrimaryFire(CT + 0.2)
				//self:EmitSound("FAS2_DRYFIRE", 70, 100)
				return
			end
			
			if self.CockAfterShot and not self.Cocked then
				if SERVER then
					if SP then
						SendUserMessage("FAS2_COCKREMIND", self.Owner) -- wow okay
					end
				else
					self.CockRemindTime = CurTime() + 1
				end
				
				return
			end
			
			self:FireBullet()
			
			if CLIENT then
				self:CreateMuzzle()
				
				if self.Shell and self.CreateShell then
					self:CreateShell()
				end
			end
			
			ef = EffectData()
			ef:SetEntity(self)
			util.Effect("fas2_ef_muzzleflash", ef)
			
			mod = self.Owner:Crouching() and 0.75 or 1
			
			self:PlayFireAnim(mag)
			
			if self.dt.Status == FAS_STAT_ADS then
				if self.BurstAmount > 0 then
					if self.DelayedBurstRecoil then
						if self.dt.Shots == self.ShotToDelayUntil then
							self:AimRecoil(self.BurstRecoilMod)
						end
					else
						self:AimRecoil(self.BurstRecoilMod)
					end
				else
					self:AimRecoil()
				end
			else
				if self.BurstAmount > 0 then
					if self.DelayedBurstRecoil then
						if self.dt.Shots == self.ShotToDelayUntil then
							self:HipRecoil(self.BurstRecoilMod)
						end
					else
						self:HipRecoil(self.BurstRecoilMod)
					end
				else
					self:HipRecoil()
				end
			end
			
			self.SpreadWait = CT + self.SpreadCooldown
			
			if self.BurstAmount > 0 then
				self.AddSpread = math.Clamp(self.AddSpread + self.SpreadPerShot * mod * 0.5, 0, self.MaxSpreadInc)
				self.AddSpreadSpeed = math.Clamp(self.AddSpreadSpeed - 0.2 * mod * 0.5, 0, 1)
			else
				self.AddSpread = math.Clamp(self.AddSpread + self.SpreadPerShot * mod, 0, self.MaxSpreadInc)
				self.AddSpreadSpeed = math.Clamp(self.AddSpreadSpeed - 0.2 * mod, 0, 1)
			end
			
			if self.CockAfterShot then
				self.Cocked = false
			end
			
			if SERVER and SP then
				SendUserMessage("FAS2SPREAD", self.Owner)
			end
			
			if CLIENT then
				self.CheckTime = 0
			end
			
			if self.dt.Suppressed then
				self:EmitSound(self.FireSound_Suppressed, 75, 100)
			else
				self:EmitSound(self.FireSound, 105, 100)
			end
			
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			
			self.ReloadWait = CT + 0.3
		end
		
		if self.BurstAmount > 0 then
			self.dt.Shots = self.dt.Shots + 1
			self:SetNextPrimaryFire(CT + self.FireDelay * self.BurstFireDelayMod)
		else
			self:SetNextPrimaryFire(CT + self.FireDelay)
		end
		
		self:TakePrimaryAmmo(1)
		
		//self:SetNextSecondaryFire(CT + 0.1)
		
		return 
	end
	
	function SWEP:SecondaryAttack()
		if self.FireMode == "safe" then
			return
		end
		
		if not self.Owner:OnGround() then
			return
		end
		
		if self.ReloadState != 0 then
			return
		end
		
		if self.Owner:KeyDown(IN_USE) then
			return
		end
		
		if self.dt.Status == FAS_STAT_ADS then
			if self.Owner:GetInfoNum("fas2_holdtoaim", 0) <= 0 then
				self.dt.Status = FAS_STAT_IDLE
				self:EmitSound(table.Random(self.BackToHipSounds), 50, 100)
				self:SetNextSecondaryFire(CT + 0.1)
				return
			end
		end
		
		if self.dt.Status == FAS_STAT_SPRINT or self.dt.Status == FAS_STAT_CUSTOMIZE or self.dt.Status == FAS_STAT_QUICKGRENADE or self.dt.Status == FAS_STAT_ADS then
			return
		end
		
		if self.dt.Status != FAS_STAT_ADS then
			self.dt.Status = FAS_STAT_ADS
			self:EmitSound(table.Random(self.AimSounds), 50, 100)
		end
		
		self:SetNextPrimaryFire(CT + 0.1)
		self:SetNextSecondaryFire(CT + 0.1)
		self.ReloadWait = CT + 0.3
		
		return 
	end
	
	function SWEP:Equip()
		if self.ExtraMags then
			if gamemode.Get("sandbox") then
				self.Owner:GiveAmmo(self.ExtraMags * self.Primary.ClipSize, self.Primary.Ammo)
			end
		end
		
		if self.AttOnPickUp then
			for k, v in pairs(self.AttOnPickUp) do
				self.Owner:FAS2_PickUpAttachment(v, true)
			end
		end
	end
	
	function SWEP:UnloadWeapon()
		mag = self:Clip1()
		self:SetClip1(0)
		
		if CLIENT then
			self.CheckTime = CT + 3
		else
			self.Owner:GiveAmmo(mag, self.Primary.Ammo)
		end
	end
	
	function SWEP:CalculateSpread()
		aim = self.Owner:GetAimVector()
		
		if not self.Owner.LastView then
			self.Owner.LastView = aim
			self.Owner.ViewAff = 0
		else
			self.Owner.ViewAff = Lerp(0.25, self.Owner.ViewAff, (aim - self.Owner.LastView):Length() * 0.5)
			self.Owner.LastView = aim
		end
		
		cone = self.HipCone * (cr and 0.75 or 1) * (self.dt.Bipod and 0.3 or 1)
		
		if self.dt.Status == FAS_STAT_ADS then
			td.start = self.Owner:GetShootPos()
			td.endpos = td.start + aim * 30
			td.filter = self.Owner
			
			tr = util.TraceLine(td)
			
			if tr.Hit then
				self.dt.Status = FAS_STAT_IDLE
				self:SetNextPrimaryFire(CT + 0.2)
				self:SetNextSecondaryFire(CT + 0.2)
				self.ReloadWait = CT + 0.2
			else
				cone = self.AimCone
			end
		end
		
		self.CurCone = math.Clamp(cone + self.AddSpread * (self.dt.Bipod and 0.5 or 1) + (vel / 10000 * self.VelocitySensitivity) * (self.dt.Status == FAS_STAT_ADS and 0.25 or 1) + self.Owner.ViewAff, 0, 0.09 + self.MaxSpreadInc)
		
		if CT > self.SpreadWait then
			self.AddSpread = math.Clamp(self.AddSpread - 0.005 * self.AddSpreadSpeed, 0, self.MaxSpreadInc)
			self.AddSpreadSpeed = math.Clamp(self.AddSpreadSpeed + 0.05, 0, 1)
		end
	end
	
	local can
	
	function SWEP:CanDeployBipod()
		vel = Length(GetVelocity(self.Owner))
		
		if vel == 0 and self.Owner:EyeAngles().p <= 45 then
			sp = self.Owner:GetShootPos()
			aim = self.Owner:GetAimVector()
			
			td.start = sp
			td.endpos = td.start + aim * 50
			td.filter = self.Owner
			
			tr = util.TraceLine(td)
			
			if not tr.Hit then
				td.start = sp
				td.endpos = td.start + Vector(aim.x, aim.y, -1) * 25
				td.filter = self.Owner
				td.mins = Vector(-8, -8, -1)
				td.maxs = Vector(8, 8, 1)
				
				tr = util.TraceHull(td)
				
				if tr.Hit and tr.HitPos.z + 10 < sp.z then -- make sure we have something to place the bipod on and we're not placing the bipod on something lower than our standing position
					ent = tr.Entity
					
					if not ent:IsPlayer() and not ent:IsNPC() then
						return true
					end
				end
			end
		end
		
		return false
	end
	
	function SWEP:PlayBipodDeployAnim()
		if self:Clip1() == 0 and self.Anims.Bipod_Deploy_Empty then
			FAS2_PlayAnim(self, self.Anims.Bipod_Deploy_Empty, 1)
		else
			FAS2_PlayAnim(self, self.Anims.Bipod_Deploy, 1)
		end
	end
	
	function SWEP:PlayBipodUnDeployAnim()
		if self:Clip1() == 0 and self.Anims.Bipod_UnDeploy_Empty then
			FAS2_PlayAnim(self, self.Anims.Bipod_UnDeploy_Empty, 1)
		else
			FAS2_PlayAnim(self, self.Anims.Bipod_UnDeploy, 1)
		end
	end
	
	function SWEP:Think()
		if self.ShotgunThink then
			self:ShotgunThink()
		end
		
		cr = self.Owner:Crouching()
		CT, vel = CurTime(), Length(GetVelocity(self.Owner))
		
		if self.ReloadDelay and CT >= self.ReloadDelay then
			mag, ammo = self:Clip1(), self.Owner:GetAmmoCount(self.Primary.Ammo)
			
			if SERVER then
				if not self.NoProficiency then
					if not self.Owner.FAS_FamiliarWeapons[self.Class] then
						if not self.Owner.FAS_FamiliarWeaponsProgress[self.Class] then
							self.Owner.FAS_FamiliarWeaponsProgress[self.Class] = 0
						end
						
						self.Owner.FAS_FamiliarWeaponsProgress[self.Class] = self.Owner.FAS_FamiliarWeaponsProgress[self.Class] + GetConVarNumber("fas2_profgain") * (mag == 0 and 1.5 or 1)
						
						if self.Owner.FAS_FamiliarWeaponsProgress[self.Class] >= 1 then
							self:FamiliariseWithWeapon()
						end
					end
				end
			end
			
			if self.ReloadAmount then
				if SERVER then
					self:SetClip1(math.Clamp(mag + self.ReloadAmount, 0, self.Primary.ClipSize))
					self.Owner:RemoveAmmo(self.ReloadAmount, self.Primary.Ammo)
				end
			else
				if mag > 0 then
					if not self.CantChamber then
						if ammo >= self.Primary.ClipSize - mag + 1 then
							if SERVER then
								self:SetClip1(math.Clamp(self.Primary.ClipSize + 1, 0, self.Primary.ClipSize + 1))
								self.Owner:RemoveAmmo(self.Primary.ClipSize - mag + 1, self.Primary.Ammo)
							end
						else
							if SERVER then
								self:SetClip1(math.Clamp(mag + ammo, 0, self.Primary.ClipSize))
								self.Owner:RemoveAmmo(ammo, self.Primary.Ammo)
							end
						end
					else
						if ammo >= self.Primary.ClipSize - mag then
							if SERVER then
								self:SetClip1(math.Clamp(self.Primary.ClipSize, 0, self.Primary.ClipSize))
								self.Owner:RemoveAmmo(self.Primary.ClipSize - mag, self.Primary.Ammo)
							end
						else
							if SERVER then
								self:SetClip1(math.Clamp(mag + ammo, 0, self.Primary.ClipSize))
								self.Owner:RemoveAmmo(ammo, self.Primary.Ammo)
							end
						end
					end
				else
					if ammo >= self.Primary.ClipSize then
						if SERVER then
							self:SetClip1(math.Clamp(self.Primary.ClipSize, 0, self.Primary.ClipSize))
							self.Owner:RemoveAmmo(self.Primary.ClipSize, self.Primary.Ammo)
						end
					else
						if SERVER then
							self:SetClip1(math.Clamp(ammo, 0, self.Primary.ClipSize))
							self.Owner:RemoveAmmo(ammo, self.Primary.Ammo)
						end
					end
				end
			end
			
			self.ReloadDelay = nil
		end
		
		if (SP and SERVER) or not SP then -- if it's SP, then we run it only on the server (otherwise shit gets fucked); if it's MP we predict it
			if self.dt.Bipod or self.DeployAngle then
				if not self:CanDeployBipod() then
					self.dt.Bipod = false
					self.DeployAngle = nil
					
					if not self.ReloadDelay then
						if CT > self.BipodDelay then
							self:PlayBipodUnDeployAnim()
							self.BipodDelay = CT + self.BipodUndeployTime
							self:SetNextPrimaryFire(CT + self.BipodUndeployTime)
							self:SetNextSecondaryFire(CT + self.BipodUndeployTime)
							self.ReloadWait = CT + self.BipodUndeployTime
						else
							self.BipodUnDeployPost = true
						end
					else
						self.BipodUnDeployPost = true
					end
				end
			end
			
			if not self.ReloadDelay then
				if self.BipodUnDeployPost then
					if CT > self.BipodDelay then
						if not self:CanDeployBipod() then
							self:PlayBipodUnDeployAnim()
							self.BipodDelay = CT + self.BipodUndeployTime
							self:SetNextPrimaryFire(CT + self.BipodUndeployTime)
							self:SetNextSecondaryFire(CT + self.BipodUndeployTime)
							self.ReloadWait = CT + self.BipodUndeployTime
							self.BipodUnDeployPost = false
						else
							self.dt.Bipod = true
							
							if SP and SERVER then
								umsg.Start("FAS2_DEPLOYANGLE", self.Owner)
								umsg.Angle(self.Owner:EyeAngles())
								umsg.End()
							else
								self.DeployAngle = self.Owner:EyeAngles()
							end
							
							self.BipodUnDeployPost = false
						end
					end
				end
				
				if self.Owner:KeyPressed(IN_USE) then
					if CT > self.BipodDelay and CT > self.ReloadWait then
						if self.InstalledBipod then
							if self.dt.Bipod then
								self.dt.Bipod = false
								self.DeployAngle = nil
								
								self.BipodDelay = CT + self.BipodUndeployTime
								self:SetNextPrimaryFire(CT + self.BipodUndeployTime)
								self:SetNextSecondaryFire(CT + self.BipodUndeployTime)
								self.ReloadWait = CT + self.BipodUndeployTime
								self:PlayBipodUnDeployAnim()
							else
								self.dt.Bipod = self:CanDeployBipod()
								
								if self.dt.Bipod then
									self.BipodDelay = CT + self.BipodDeployTime
									self:SetNextPrimaryFire(CT + self.BipodDeployTime)
									self:SetNextSecondaryFire(CT + self.BipodDeployTime)
									self.ReloadWait = CT + self.BipodDeployTime
									
									if SP and SERVER then
										umsg.Start("FAS2_DEPLOYANGLE", self.Owner)
										umsg.Angle(self.Owner:EyeAngles())
										umsg.End()
									else
										self.DeployAngle = self.Owner:EyeAngles()
									end
									
									self:PlayBipodDeployAnim()
								end
							end
						end
					end
				end
				
				
				if tonumber(self.Owner:GetInfo("fas2_holdtoaim")) > 0 then
					self.Secondary.Automatic = true
					
					if not self.Owner:KeyDown(IN_ATTACK2) then
						if self.dt.Status == FAS_STAT_ADS then
							self.dt.Status = FAS_STAT_IDLE
							self:SetNextSecondaryFire(CT + 0.1)
							self.ReloadWait = CT + 0.3
							self:EmitSound(table.Random(self.BackToHipSounds), 50, 100)
						end
					end
				else
					self.Secondary.Automatic = false
				end
			end
		end
		
		if self.Owner:KeyDown(IN_USE) and self.Owner:KeyDown(IN_ATTACK2) then
			if SERVER and SP then
				SendUserMessage("FAS2_CHECKWEAPON", self.Owner)
			end
			
			if CLIENT then
				self.CheckTime = CT + 0.5
			end
			
			return
		end
		
		//if not self.ReloadDelay then
			if self.dt.Status != FAS_STAT_HOLSTER_START and self.dt.Status != FAS_STAT_HOLSTER_END and self.dt.Status != FAS_STAT_QUICKGRENADE then
				if self.Owner:OnGround() then
					if self.Owner:KeyDown(IN_SPEED) and vel >= self.Owner:GetWalkSpeed() * 1.3 then
						if self.dt.Status != FAS_STAT_SPRINT then
							self.dt.Status = FAS_STAT_SPRINT
						end
					else
						if self.dt.Status == FAS_STAT_SPRINT then
							self.dt.Status = FAS_STAT_IDLE
							
							if CT > self.SprintDelay and not self.ReloadDelay then
								self:SetNextPrimaryFire(CT + 0.2)
								self:SetNextSecondaryFire(CT + 0.2)
							end
						end
					end
				else
					if self.dt.Status != FAS_STAT_IDLE then
						self.dt.Status = FAS_STAT_IDLE
						
						if CT > self.SprintDelay and not self.ReloadDelay then
							self:SetNextPrimaryFire(CT + 0.2)
							self:SetNextSecondaryFire(CT + 0.2)
						end
					end
				end
			end
			
			self:CalculateSpread()
			
			if self.dt.Shots > 0 then
				if not self.Owner:KeyDown(IN_ATTACK) then
					self:SetNextPrimaryFire(CT + self.FireDelay * 2)
					self:SetNextSecondaryFire(CT + 0.1)
					self.ReloadWait = CT + self.FireDelay * 3
					self.dt.Shots = 0
				end
			end
			
			if self.CurSoundTable then
				t = self.CurSoundTable[self.CurSoundEntry]
				
				if CLIENT then
					if self.Wep:SequenceDuration() * self.Wep:GetCycle() >= t.time / self.SoundSpeed then
						self:EmitSound(t.sound, 70, 100)
						
						if self.CurSoundTable[self.CurSoundEntry + 1] then
							self.CurSoundEntry = self.CurSoundEntry + 1
						else
							self.CurSoundTable = nil
							self.CurSoundEntry = nil
							self.SoundTime = nil
						end
					end
				else
					if CT >= self.SoundTime + t.time / self.SoundSpeed then
						self:EmitSound(t.sound, 70, 100)
						
						if self.CurSoundTable[self.CurSoundEntry + 1] then
							self.CurSoundEntry = self.CurSoundEntry + 1
						else
							self.CurSoundTable = nil
							self.CurSoundEntry = nil
							self.SoundTime = nil
						end
					end
				end
			end
			
			if self.TimeToAdvance and CT > self.TimeToAdvance then
				if self.AdvanceStage == "draw" then
					self:DrawGrenade()
				elseif self.AdvanceStage == "prepare" then
					self:AdvanceGrenadeThrow()
				end
			end
			
			if self.Cooking then
				if self.FuseTime then
					if not self.Owner:KeyDown(IN_ATTACK) then
						if CT > self.TimeToThrow then
							self:ThrowGrenade()
						end
					else
						if CT > self.TimeToThrow then
							self.ThrowPower = math.Approach(self.ThrowPower, 1, FrameTime())
						end
						
						if SERVER then
							if CT >= self.FuseTime then
								self.Cooking = false
								self.FuseTime = nil
								util.BlastDamage(self.Owner, self.Owner, self:GetPos(), 384, 100)
								self.Owner:Kill()
								
								ef = EffectData()
								ef:SetOrigin(self.Owner:GetPos())
								ef:SetMagnitude(1)
								
								util.Effect("Explosion", ef)
							end
						end
					end
				end
			end
			
			for k, v in pairs(self.Events) do
				if CT > v.time then
					v.func()
					table.remove(self.Events, k)
				end
			end
		end
		
		if SERVER then
			function SWEP:FamiliariseWithWeapon()
				self.Owner.FAS_FamiliarWeapons = self.Owner.FAS_FamiliarWeapons and self.Owner.FAS_FamiliarWeapons or {}
				self.Owner.FAS_FamiliarWeapons[self.Class] = true
				
				umsg.Start("FAS2_FAMILIARISE", self.Owner)
				umsg.String(self.Class)
				umsg.End()
			end
			
			function SWEP:Suppress()
				if self.CantSuppress then
					return
				end
				
				self.dt.Suppressed = true
				
				SendUserMessage("FAS2_SUPPRESSMODEL", self.Owner)
			end
			
			function SWEP:UnSuppress()
				if self.CantSuppress then
					return
				end
				
				self.dt.Suppressed = true
				
				SendUserMessage("FAS2_UNSUPPRESSMODEL", self.Owner)
			end
		end
		
		function SWEP:CanThrowGrenade()
			if self.FireMode != "safe" then
				if self.Owner:HasWeapon("fas2_m67") then
					if self.Owner:GetAmmoCount("M67 Grenades") > 0 then
						return true
					end
				end
			end
			
			return false
		end
		
		function SWEP:InitialiseGrenadeThrow()
			CT = CurTime()
			
			self:EmitSound("weapons/weapon_holster" .. math.random(1, 3) .. ".wav", 50, 100)
			self:PlayHolsterAnim()
			self:DelayMe(CT + 5)
			self.TimeToAdvance = CT + (self.HolsterTime and self.HolsterTime or 0.45)
			self.AdvanceStage = "draw"
			self.dt.Status = FAS_STAT_QUICKGRENADE
		end
		
		function SWEP:DrawGrenade()
			if SP and SERVER then
				SendUserMessage("FAS2_DRAWGRENADE", self.Owner)
			end
			
			if CLIENT then
				FAS2_DrawGrenade()
			end
			
			self.AdvanceStage = "prepare"
			self.TimeToAdvance = CT + 0.1
		end
		
		function SWEP:AdvanceGrenadeThrow()
			CT = CurTime()
			
			self.Cooking = true
			self.FuseTime = CT + 3.5
			self.CookTime = CT + 3.5
			self.TimeToAdvance = nil
			self.ThrowPower = 0.5
			self.TimeToThrow = CT + 0.6
			
			if SP and SERVER then
				SendUserMessage("FAS2_PULLPIN", self.Owner)
			end
			
			if CLIENT then
				FAS2_PullGrenadePin()
			end
		end
		
		local phys, force, pos, EA
		
		function SWEP:ThrowGrenade()
			self.Cooking = false
			CT = CurTime()
			
			if SP and SERVER then
				SendUserMessage("FAS2_THROWGRENADE", self.Owner)
			end
			
			if CLIENT then
				FAS2_ThrowGrenade()
			end
			
			if SERVER then
				timer.Simple(0.15, function()
					if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
						local nade = ents.Create("fas2_thrown_m67")
						EA =  self.Owner:EyeAngles()
						pos = self.Owner:GetShootPos()
						pos = pos + EA:Right() * 5 - EA:Up() * 4 + EA:Forward() * 8
						
						nade:SetPos(pos)
						nade:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
						nade:Spawn()
						nade:SetOwner(self.Owner)
						nade:Fuse(self.CookTime - CT)
						
						phys = nade:GetPhysicsObject()
						
						if IsValid(phys) then
							force = 1000
							
							if self.Owner:KeyDown(IN_FORWARD) and ong then
								force = force + self.Owner:GetVelocity():Length()
							end
							
							phys:SetVelocity(EA:Forward() * force * self.ThrowPower + Vector(0, 0, 100))
							phys:AddAngleVelocity(Vector(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500)))
						end
					end
				end)
			end
			
			self.Owner:RemoveAmmo(1, "M67 Grenades")
			
			timer.Simple(0.65, function()
				if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
					self:DrawWeapon()
				end
			end)
			
			self.FuseTime = nil
		end
		
		function SWEP:DrawWeapon()
			self:DelayMe(CT + self.DeployTime)
			self:PlayDeployAnim()
			self.dt.Status = FAS_STAT_IDLE
		end
		
		function SWEP:OnRemove()
			--[[if CLIENT then
			SafeRemoveEntity(self.Wep)
			SafeRemoveEntity(self.W_Wep)
			SafeRemoveEntity(self.Nade)
		end]]--
	end
