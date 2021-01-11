-- English is not my first language, so sorry if I did some errors in my little "tutorial"

/*---------------------------------------------------------*/

/*---------------------------------------------------------*/

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight 		= 5
end

if (CLIENT) then
	SWEP.DrawAmmo		= true		-- Should we draw the number of ammos and clips?
	SWEP.DrawCrosshair	= false		-- Should we draw the half life 2 crosshair?
	SWEP.ViewModelFOV		= 60			-- "Y" position of the sweps
	-- SWEP.ViewModelFlip	= true		-- Should we flip the sweps?
	SWEP.CSMuzzleFlashes	= false		-- Should we add a CS Muzzle Flash?

	-- This is the font that's used to draw the death icons
	surface.CreateFont("CSKillIcons", {font = "csd", size = ScreenScale(30), weight = 500, antialias = true, additive = true})

	-- This is the font that's used to draw the select icons
	surface.CreateFont("CSSelectIcons", {font = "csd", size = ScreenScale(60), weight = 500, antialias = true, additive = true})

	-- This is the font that's used to draw the firemod icons
	surface.CreateFont("Firemode", {font = "HalfLife2", size = ScrW() / 60, weight = 500, antialias = true, additive = true})
end

/*---------------------------------------------------------
Muzzle Effect + Shell Effect
---------------------------------------------------------*/
SWEP.MuzzleEffect			= "rg_muzzle_rifle" -- This is an extra muzzleflash effect
-- Available muzzle effects: rg_muzzle_grenade, rg_muzzle_highcal, rg_muzzle_hmg, rg_muzzle_pistol, rg_muzzle_rifle, rg_muzzle_silenced, none

SWEP.ShellEffect			= "rg_shelleject" -- This is a shell ejection effect
-- Available shell eject effects: rg_shelleject, rg_shelleject_rifle, rg_shelleject_shotgun, none

SWEP.MuzzleAttachment		= "1" -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment	= "2" -- Should be "2" for CSS models or "1" for hl2 models

SWEP.EjectDelay			= 0
/*-------------------------------------------------------*/

SWEP.Category			= "CS:S Realistic Weapons"		-- Swep Categorie (You can type what your want)

SWEP.DrawWeaponInfoBox  	= true					-- Should we draw a weapon info when you're selecting your swep?

SWEP.UseHands = true

SWEP.Author 			= "WORSHIPPER"				-- Author Name
SWEP.Contact 			= ""						-- Author E-Mail
SWEP.Purpose 			= ""						-- Author's Informations
SWEP.Instructions 		= ""						-- Instructions of the sweps
SWEP.HoldType			= "pistol"

SWEP.Spawnable 			= false					-- Everybody can spawn this swep
SWEP.AdminSpawnable		= false					-- Admin can spawn this swep

SWEP.Weight 			= 5						-- Weight of the swep
SWEP.AutoSwitchTo 		= false
SWEP.AutoSwitchFrom 	= false

SWEP.SwayScale = 0

SWEP.Primary.Sound 		= Sound("Weapon_AK47.Single")		-- Sound of the gun
SWEP.Primary.Recoil		= 0						-- Recoil of the gun
SWEP.Primary.Damage		= 0						-- Damage of the gun
SWEP.Primary.NumShots	= 0						-- How many bullet(s) should be fired by the gun at the same time
SWEP.Primary.Cone 		= 0						-- Precision of the gun
SWEP.Primary.ClipSize 	= 0						-- Number of bullets in 1 clip
SWEP.Primary.Delay 		= 0						-- Exemple: If your weapon shoot 800 bullets per minute, this is what you need to do: 1 / (800 / 60) = 0.075
SWEP.Primary.DefaultClip = 0						-- How many ammos come with your weapon (ClipSize + "The number of ammo you want"). If you don't want to add additionnal ammo with your weapon, type the ClipSize only!
SWEP.Primary.Automatic	= false					-- Is the weapon automatic? 
SWEP.Primary.Ammo 		= "none"					-- Type of ammo ("pistol" "ar2" "grenade" "smg1" "xbowbolt" "rpg_round" "351")

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo 	= "none"

SWEP.data 				= {}
SWEP.mode 				= "semi" 					-- The starting firemode
SWEP.data.ironsights	= 1

SWEP.data.semi 			= {}
SWEP.data.semi.FireMode	= "p"

SWEP.data.auto 			= {}
SWEP.data.auto.FireMode	= "ppppp"

SWEP.data.burst			= {}
SWEP.data.burst.FireMode = "ppp"

/*---------------------------------------------------------
Auto/Semi/Burst Configuration
---------------------------------------------------------*/
function SWEP.data.semi.Init(self)

	self.Primary.Automatic = false
	self.Weapon:EmitSound("weapons/smg1/switch_single.wav")
	self.Weapon:SetNetworkedInt("firemode", 3)
end

function SWEP.data.auto.Init(self)

	self.Primary.Automatic = true
	self.Weapon:EmitSound("weapons/smg1/switch_burst.wav")
	self.Weapon:SetNetworkedInt("firemode", 1)
end

function SWEP.data.burst.Init(self)

	self.Primary.Automatic = false
	self.Weapon:EmitSound("weapons/smg1/switch_burst.wav")
	self.Weapon:SetNetworkedInt("firemode", 2)
end

/*---------------------------------------------------------
IronSight
---------------------------------------------------------*/
function SWEP:IronSight()

	if !self.Owner:KeyDown(IN_USE) then
	-- If the key E (Use Key) is not pressed, then

		if self.Owner:KeyPressed(IN_ATTACK2) then
		-- When the right click is pressed, then

			self.Owner:SetFOV( 65, 0.15 )

			self:SetIronsights(true, self.Owner)
			-- Set the ironsight true

			if CLIENT then return end
 		end
	end

	if self.Owner:KeyReleased(IN_ATTACK2) then
	-- If the right click is released, then

		self.Owner:SetFOV( 0, 0.15 )

		self:SetIronsights(false, self.Owner)
		-- Set the ironsight false

		if CLIENT then return end
	end
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()

	self:IronSight()
end

/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/
function SWEP:Initialize()

	self:SetWeaponHoldType(self.HoldType) 	-- Hold type of the 3rd person animation

	self.Reloadaftershoot = 0 				-- Can't reload when firering

	self.data[self.mode].Init(self)

    self.upgrades = {}
	self.t = {}
	self.item = {}
end



if SERVER then
    function SWEP:Upgrade(ply, id, item)
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
        end)

    end
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()

	if ( self.Reloadaftershoot > CurTime() ) then return end 
	-- If you're firering, you can't reload

	self.Weapon:DefaultReload(ACT_VM_RELOAD) 
	-- Animation when you're reloading

	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
	-- When the current clip < full clip and the rest of your ammo > 0, then

		self.Owner:SetFOV( 0, 0.15 )
		-- Zoom = 0

		self:SetIronsights(false)
		-- Set the ironsight to false
	end
end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	-- Set the deploy animation when deploying

	self.Reloadaftershoot = CurTime() + 1
	-- Can't shoot while deploying

	self:SetIronsights(false)
	-- Set the ironsight mod to false

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	-- Set the next primary fire to 1 second after deploying

	return true
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	-- If your gun have a problem or if you are under water, you'll not be able to fire

	self.Reloadaftershoot = CurTime() + self.Primary.Delay
	-- Set the reload after shoot to be not able to reload when firering

	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	-- Set next secondary fire after your fire delay

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	-- Set next primary fire after your fire delay

	self.Weapon:EmitSound(self.Primary.Sound)
	-- Emit the gun sound when you fire

	self:RecoilPower()

	self:TakePrimaryAmmo(1)
	-- Take 1 ammo in you clip

	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

end

/*---------------------------------------------------------
CanPrimaryAttack
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()

	if ( self.Weapon:Clip1() <= 0 ) and self.Primary.ClipSize > -1 then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		self.Weapon:EmitSound("Weapons/ClipEmpty_Pistol.wav")
		return false
	end
	return true
end

/*---------------------------------------------------------
DrawWeaponSelection
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)

	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)
	-- Draw a CS:S select icon

	self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	-- Print weapon information
end

SWEP.CrossHairScale = 1
-- CROSSHAIR THAT I DIDN'T ADD IN THIS VERSION. IT WAS JUST EXPERIMENTAL AGAIN.
/*---------------------------------------------------------
DrawHUD
---------------------------------------------------------*/
function SWEP:DrawHUD()

	local mode = self.Weapon:GetNetworkedInt("firemode")

	if mode == 1 then
		self.mode = "auto"
	elseif mode == 2 then
		self.mode = "burst"
	elseif mode == 3 then
		self.mode = "semi"
	else
		self.mode = "semi"
	end

	surface.SetFont("Firemode")
	surface.SetTextPos(surface.ScreenWidth() * .9225, surface.ScreenHeight() * .9125)
	surface.SetTextColor(255,220,0,100)

	surface.DrawText(self.data[self.mode].FireMode)

/*---------------------------------------------------------
	local x = ScrW() / 2
	local y = ScrH() / 2

	if self:GetNetworkedBool("Ironsights") then
		return
	end

	local scalebyheight = (ScrH() / 770) * 15

	local scale

	if not self.Owner:IsValid() then return end

	if self.Owner:GetVelocity():Length() > 0 then
		scale = scalebyheight * (self.Primary.Cone * 1.5)

	elseif self.Owner:Crouching() then
		scale = scalebyheight * (self.Primary.Cone / 1.5)

	else
		scale = scalebyheight * self.Primary.Cone
	end

	LastShootTime = self.Weapon:GetNetworkedFloat( "LastShootTime", 0 )
	scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))

	surface.SetDrawColor(255, 255, 255, 230)

	self.CrossHairScale = math.Approach(self.CrossHairScale, scale, FrameTime() * 3 + math.abs(self.CrossHairScale - scale) * 0.012)

	local dispscale = self.CrossHairScale

	local gap = 40 * dispscale
	local length = gap + 15
	surface.DrawLine(x - length, y, x - gap, y)
	surface.DrawLine(x + length, y, x + gap, y)
	surface.DrawLine(x, y - length, x, y - gap)
	surface.DrawLine(x, y + length, x, y + gap)

--	surface.SetDrawColor(200, 0, 0, 230)
--	surface.DrawRect(x - 2, y - 2, 2, 2)
---------------------------------------------------------*/
end

/*---------------------------------------------------------
GetViewModelPosition
---------------------------------------------------------*/
local IRONSIGHT_TIME = 0.15
-- Time to enter in the ironsight mod

function SWEP:GetViewModelPosition(pos, ang)
	if SERVER then return Vector(0,0,0), Angle(0,0,0) end

	if (not self.IronSightsPos) then return pos, ang end

	local bIron = self.Weapon:GetNWBool("Ironsights")

	if (bIron != self.bLastIron) then
		self.bLastIron = bIron
		self.fIronTime = CurTime()

		if (bIron) then
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	end

	local fIronTime = self.fIronTime or 0

	if (not bIron and fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
	end

	local Mul = 1.0

	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

		if not bIron then Mul = 1 - Mul end
	end

	local Offset	= self.IronSightsPos

	if (self.IronSightsAng) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 		self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul)
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
end

/*---------------------------------------------------------
SetIronsights
---------------------------------------------------------*/
function SWEP:SetIronsights(b)

	self.Weapon:SetNetworkedBool("Ironsights", b)
end

function SWEP:GetIronsights()

	return self.Weapon:GetNWBool("Ironsights")
end

/*---------------------------------------------------------
RecoilPower
---------------------------------------------------------*/
function SWEP:RecoilPower()
	if !IsValid(self.Owner) then return end

	if(self:GetOwner().upgrades and self:GetOwner().upgrades.accuracyboost) then
       	self.primary.Recoil = math.max(0,self.primary.Recoil-(self.primary.Recoil*(self:GetOwner().upgrades.accuracyboost/100)))
    end    

	if not self.Owner:IsOnGround() then
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
			-- Put normal recoil when you're in ironsight mod

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil), math.Rand(-1,1) * (self.Primary.Recoil), 0))
			-- Punch the screen 1x less hard when you're in ironsigh mod
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil * 2.5, self.Primary.NumShots, self.Primary.Cone)
			-- Recoil * 2.5

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil * 2.5), math.Rand(-1,1) * (self.Primary.Recoil * 2.5), 0))
			-- Punch the screen * 2.5
		end

	elseif self.Owner:KeyDown(bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) then
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 2, self.Primary.NumShots, self.Primary.Cone)
			-- Put recoil / 2 when you're in ironsight mod

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil / 1.5), math.Rand(-1,1) * (self.Primary.Recoil / 1.5), 0))
			-- Punch the screen 1.5x less hard when you're in ironsigh mod
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil * 1.5, self.Primary.NumShots, self.Primary.Cone)
			-- Recoil * 1.5

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil * 1.5), math.Rand(-1,1) * (self.Primary.Recoil * 1.5), 0))
			-- Punch the screen * 1.5
		end

	elseif self.Owner:Crouching() then
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, 0, self.Primary.NumShots, self.Primary.Cone)
			-- Put 0 recoil when you're in ironsight mod

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil / 3), math.Rand(-1,1) * (self.Primary.Recoil / 3), 0))
			-- Punch the screen 3x less hard when you're in ironsigh mod
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 2, self.Primary.NumShots, self.Primary.Cone)
			-- Recoil / 2

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil / 2), math.Rand(-1,1) * (self.Primary.Recoil / 2), 0))
			-- Punch the screen / 2
		end
	else
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 6, self.Primary.NumShots, self.Primary.Cone)
			-- Put recoil / 4 when you're in ironsight mod

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil / 2), math.Rand(-1,1) * (self.Primary.Recoil / 2), 0))
			-- Punch the screen 2x less hard when you're in ironsigh mod
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
			-- Put normal recoil when you're not in ironsight mod

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * self.Primary.Recoil, math.Rand(-1,1) *self.Primary.Recoil, 0))
			-- Punch the screen
		end
	end
end

/*---------------------------------------------------------
ShootBullet
---------------------------------------------------------*/
function SWEP:CSShootBullet(dmg, recoil, numbul, cone)
    dmg = 1 // Ignore weapon damage

	numbul 		= numbul or 1
	cone 			= cone or 0.01

	if(self.t) then
		
		// Required level of rweapon
        if(self.t.level) then
            dmg = dmg + (self.t.level / 4)
        end

		// Weapon level
        if(self.t.json and self.t.json.level) then
            dmg = dmg + (self.t.json.level)
        end

		// Owner level
        if(manolis.popcorn.levels.GetLevel(self:GetOwner())) then
            dmg = dmg + math.Round(manolis.popcorn.levels.GetLevel(self:GetOwner())/4)
        end
        
        if(self:GetOwner().upgrades and self:GetOwner().upgrades.basedamage) then
               dmg = dmg + self:GetOwner().upgrades.basedamage
        end           

        if(self.upgrades) then
            if(self.upgrades.damage) then
                dmg = dmg + (dmg*(self.upgrades.damage/100))
            end
		end
		
		if(manolis.popcorn.config.damageMultiplier) then
			dmg = dmg * manolis.popcorn.config.damageMultiplier
		end

		if(self.item.meta and self.item.meta.damageMultiplier) then
			damage = damage * self.item.meta.damageMultiplier
		end
    end


	local bullet 	= {}
	bullet.Num  	= numbul
	bullet.Src 		= self.Owner:GetShootPos()       					-- Source
	bullet.Dir 		= self.Owner:GetAimVector()      					-- Dir of bullet
	bullet.Spread 	= Vector(cone, cone, 0)     						-- Aim Cone
	bullet.Tracer 	= 1       									-- Show a tracer on every x bullets
	bullet.Force 	= 0.5 * dmg     								-- Amount of force to give to phys objects
	bullet.Damage 	= dmg									-- Amount of damage to give to the bullets
	bullet.Callback 	= function(ply,trace,info)

        local hit = EffectData()
        hit:SetOrigin(trace.HitPos)
        hit:SetNormal(trace.HitNormal)
        hit:SetScale(20)
        util.Effect("effect_hit", hit)

        if(!SERVER) then return end
        if(!(trace.Entity:IsPlayer())) then return end 

        local pushVelocity = trace.Normal * manolis.popcorn.config.bulletForceMult * dmg 
        trace.Entity:SetGroundEntity(nil)
        trace.Entity:SetLocalVelocity(trace.Entity:GetVelocity() + pushVelocity)

        local attacker = info:GetAttacker()
        if(!attacker.popcorn.weapons[self.t.type].upgrades) then return false end
        if(attacker.popcorn.weapons[self.t.type].upgrades.ice) then
            
            if(attacker.popcorn.weapons[self.t.type].upgrades.ice > (math.random()*50)) then
                local ice = tonumber(attacker.popcorn.weapons[self.t.type].upgrades.ice)

                if(trace.Entity and trace.Entity.upgrades and trace.Entity.upgrades.iceresist) then
                    ice = math.max(0, ice-trace.Entity.upgrades.iceresist)
                end

                local t = trace.Entity:UserID()..'ice'
                GAMEMODE:SetPlayerSpeed(trace.Entity, math.max(10,trace.Entity.WalkSpeed - (trace.Entity.WalkSpeed*(ice/100))), math.max(10,trace.Entity.RunSpeed - (trace.Entity.RunSpeed*(ice/100))))
                if(timer.Exists(t)) then
                    timer.Destroy(t)
                end
                timer.Create(t, ice*.04, 1, function()
                    trace.Entity:LimitSpeed()
                end)
                
            end
        end

        if(attacker.popcorn.weapons[self.t.type].upgrades.fire) then
            local ignitiontime = attacker.popcorn.weapons[self.t.type].upgrades.fire
            if(trace.Entity and trace.Entity.upgrades and trace.Entity.upgrades.fireresist) then
                ignitiontime = math.max(0, ignitiontime-trace.Entity.upgrades.fireresist)
            end
            
            if(attacker.popcorn.weapons[self.t.type].upgrades.fire > (math.random()*50)) then
                trace.Entity:Ignite(0.01*ignitiontime)
            end
        end



    end

	self.Owner:FireBullets(bullet)					-- Fire the bullets

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)      	-- View model animation
	self.Owner:MuzzleFlash()        					-- Crappy muzzle light

	self.Owner:SetAnimation(PLAYER_ATTACK1)       			-- 3rd Person Animation

	local fx = EffectData()
	fx:SetEntity(self.Weapon)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetAttachment(self.MuzzleAttachment)
	util.Effect(self.MuzzleEffect, fx)					-- Additional muzzle effects

	timer.Simple( self.EjectDelay, function()
		if  not IsFirstTimePredicted() then 
			return
		end

			local fx 	= EffectData()
			fx:SetEntity(self.Weapon)
			if !IsValid(self.Owner) then fx = nil return end
			fx:SetNormal(self.Owner:GetAimVector())
			fx:SetAttachment(self.ShellEjectAttachment)

			util.Effect(self.ShellEffect,fx)				-- Shell ejection
	end)

	if ((game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT)) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles(eyeang)
	end
end

-- BULLET PENETRATION | EXPERIMENTAL CODE | BULLETS CAN PASS TROUGHT THE SMALL PROPS
/*---------------------------------------------------------
BulletPenetration
---------------------------------------------------------*/

/*---------------------------------------------------------
function BulletPenetration( hitNum, attacker, tr, dmginfo ) 

 	local DoDefaultEffect = true; 
 	if ( !tr.HitWorld ) then DoDefaultEffect = true end
	if ( tr.HitWorld ) then return end

	if tr.Hit then
	end

 	if ( CLIENT ) then return end 
 	if ( hitNum > 6 ) then return end 

 	local bullet =  
 	{	 
 		Num 		= 1, 
 		Src 		= tr.HitPos + attacker:GetAimVector() * 4, 
 		Dir 		= attacker:GetAimVector(),
 		Spread 	= Vector( 0.005, 0.005, 0 ), 
 		Tracer	= 1, 
 		TracerName 	= "effect_trace_bulletpenetration", 
 		Force		= 0, 
 		Damage	= 25 / hitNum, 
 		AmmoType 	= "Pistol"  
 	} 
 	if (SERVER) then 
 		bullet.Callback    = function( a, b, c ) BulletPenetration( hitNum + 1, a, b, c ) end 
 	end 
 	timer.Simple( 0.01 * hitNum, attacker.FireBullets, attacker, bullet ) 
 	return { damage = true, effects = DoDefaultEffect } 
end
---------------------------------------------------------*/