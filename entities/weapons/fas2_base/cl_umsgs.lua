local ply, wep, anim, speed, CT, class, Mode, t, t2, mod, group, att, cyc, amt, ang

local function FAS2_Animate(um)
	anim = um:ReadString()
	speed = um:ReadFloat()
	cyc = um:ReadFloat()
	
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	if IsValid(wep) and wep.IsFAS2Weapon then
		FAS2_PlayAnim(wep, anim, speed, cyc)
	end
end

usermessage.Hook("FAS2ANIM", FAS2_Animate)

local function FAS2_EndSounds()
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	if IsValid(wep) and wep.IsFAS2Weapon then
		wep.CurSoundTable = nil
		wep.CurSoundEntry = nil
		wep.SoundTime = nil
		wep.SoundSpeed = 1
	end
end

usermessage.Hook("FAS2_ENDSOUNDS", FAS2_EndSounds)

local function FAS2_HitMarker()
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	if IsValid(wep) and wep.IsFAS2Weapon then
		wep.HitMarkerTime = CurTime() + 0.2
		wep.HitMarkerAlpha = 255
	end
end

usermessage.Hook("FAS2_HITMARKER", FAS2_HitMarker)

local function FAS2_Attach(um)
	group = um:ReadShort()
	att = um:ReadString()
	
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	if IsValid(wep) and wep.IsFAS2Weapon then
		t = wep.Attachments[group]
		
		t.active = att
		t.last[att] = true
		t2 = FAS2_Attachments[att]
		
		if t2.aimpos then
			wep.AimPos = wep[t2.aimpos]
			wep.AimAng = wep[t2.aimang]
			wep.AimPosName = t2.aimpos
			wep.AimAngName = t2.aimang
		end
		
		if t.lastdeattfunc then
			t.lastdeattfunc(ply, wep)
		end
		
		if t2.clattfunc then
			t2.clattfunc(ply, wep)
		end
		
		t.lastdeattfunc = t2.cldeattfunc
		
		wep:AttachBodygroup(att)
		surface.PlaySound("cstm/attach.wav")
	end
end

usermessage.Hook("FAS2_ATTACH", FAS2_Attach)

local function FAS2_Detach(um)
	group = um:ReadShort()
	
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	if IsValid(wep) and wep.IsFAS2Weapon then
		t = wep.Attachments[group]
		t.last = {}
		
		if t.sight then
			wep.AimPos = wep.AimPos_Orig
			wep.AimAng = wep.AimAng_Orig
			wep.AimPosName = "AimPos"
			wep.AimAngName = "AimAng"
		end

		if t.lastdeattfunc then
			t.lastdeattfunc(ply, wep)
		end
		
		t.lastdeattfunc = nil
		
		wep:DetachBodygroup(group)
		t.active = nil
		surface.PlaySound("cstm/detach.wav")
	end
end

usermessage.Hook("FAS2_DETACH", FAS2_Detach)

local function FAS2_UpdateSpread()
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	if IsValid(wep) and wep.IsFAS2Weapon then
		CT = CurTime()
		mod = ply:Crouching() and 0.75 or 1
		
		//FAS2_StartRecoil(wep.ViewKick * 0.5, 0, 0.2)
		//FAS2_StartADSR(0.1, 0.1, 0.1, 0.1, 0, wep.ViewKick)
			
		wep.CheckTime = 0
		wep.SpreadWait = CT + wep.SpreadCooldown
		
		if wep.BurstAmount > 0 then
			wep.AddSpread = math.Clamp(wep.AddSpread + wep.SpreadPerShot * mod * 0.5, 0, wep.MaxSpreadInc)
			wep.AddSpreadSpeed = math.Clamp(wep.AddSpreadSpeed - 0.2 * mod * 0.5, 0, 1)
		else
			wep.AddSpread = math.Clamp(wep.AddSpread + wep.SpreadPerShot, 0, wep.MaxSpreadInc)
			wep.AddSpreadSpeed = math.Clamp(wep.AddSpreadSpeed - 0.2, 0, 1)
		end
		
		if wep.CockAfterShot then
			wep.Cocked = false
		end
		
		wep:CreateMuzzle()
	
		if wep.Shell and wep.CreateShell then
			wep:CreateShell()
		end
	end
end

usermessage.Hook("FAS2SPREAD", FAS2_UpdateSpread)

local function FAS2_MuzzleFlash()
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	if IsValid(wep) and wep.IsFAS2Weapon then
		wep:CreateMuzzle()
	end
end

usermessage.Hook("FAS2MUZZLE", FAS2_MuzzleFlash)

local function FAS2_CockRemind()
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	if IsValid(wep) and wep.IsFAS2Weapon then
		wep.CockRemindTime = CurTime() + 1
	end
end

usermessage.Hook("FAS2_COCKREMIND", FAS2_CockRemind)

local function FAS2_DeployAngle(um)
	ang = um:ReadAngle()
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	if IsValid(wep) and wep.IsFAS2Weapon then
		wep.DeployAngle = ang
	end
end

usermessage.Hook("FAS2_DEPLOYANGLE", FAS2_DeployAngle)

local function FAS2_FamiliarisedWithWeapon(um)
	class = um:ReadString()
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	ply.FAS_FamiliarWeapons = FAS_FamiliarWeapons and FAS_FamiliarWeapons or {}
	ply.FAS_FamiliarWeapons[class] = true
	chat.AddText(Color(150, 255, 150), "You've become proficient with this weapon; reload and weapon bolting speed increased.")
	
	if IsValid(wep) and wep.IsFAS2Weapon then
		wep.ProficientTextTime = CurTime() + 6
	end
end

usermessage.Hook("FAS2_FAMILIARISE", FAS2_FamiliarisedWithWeapon)

local function FAS2_ReceiveFireMode(um)
	ply = um:ReadEntity()
	Mode = um:ReadString()
	
	if not IsValid(ply) then
		return
	end
	
	wep = ply:GetActiveWeapon()
	
	wep.FireMode = Mode
	
	if IsValid(ply) and IsValid(wep) then
		if wep.FireModeNames then
			t = wep.FireModeNames[Mode]
			
			wep.Primary.Automatic = t.auto
			wep.BurstAmount = t.burstamt
			wep.FireModeDisplay = t.display
			wep.CheckTime = CurTime() + 2
			wep.FireModeSwitchTime = CurTime() + 0.6
			
			if ply == LocalPlayer() then
				ply:EmitSound("FAS2_Switch", 70, 100)
			end
		end
	end
end

usermessage.Hook("FAS2_FIREMODE", FAS2_ReceiveFireMode)

local function FAS2_CheckWeapon()
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	if IsValid(ply) and IsValid(wep) then
		wep.CheckTime = CurTime() + 0.5
	end
end

usermessage.Hook("FAS2_CHECKWEAPON", FAS2_CheckWeapon)

local function FAS2_M24BoltShellEject()
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	if IsValid(ply) and IsValid(wep) then
		timer.Simple(0.25, function()
			wep:CreateShell("7.62x51")
		end)
	end
end

usermessage.Hook("FAS2_M24BOLTSHELLEJECT", FAS2_M24BoltShellEject)

local function FAS2_MakeLiveSKSRounds(um)
	t = um:ReadFloat()
	amt = um:ReadShort()
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	wep:MakeLiveSKSRounds(t, amt)
end

usermessage.Hook("FAS2_MAKELIVESKSROUNDS", FAS2_MakeLiveSKSRounds)

local function FAS2_SKSStripper(um)
	t = um:ReadFloat()
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	wep:MakeSKSStripper(t)
end

usermessage.Hook("FAS2_SKSSTRIPPER", FAS2_SKSStripper)

local function FAS2_EjectFromCylinder(um)
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	amt = 5 - wep:Clip1()
	
	wep:EjectFromCylinder(amt, wep["EjectTime_" .. amt])
end

usermessage.Hook("FAS2_EJECTFROMCYLINDER", FAS2_EjectFromCylinder)

local function FAS2_EjectFromCylinderNomen(um)
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	amt = 5 - wep:Clip1()
	
	wep:EjectFromCylinder(amt, wep["EjectTime_" .. amt .. "_Nomen"])
end

usermessage.Hook("FAS2_EJECTFROMCYLINDERNOMEN", FAS2_EjectFromCylinderNomen)

local function FAS2_MakePumpShell(um)
	t = um:ReadFloat()
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	wep:MakePumpShell()
end

usermessage.Hook("FAS2_MAKEPUMPSHELL", FAS2_MakePumpShell)

local function FAS2_PullPin()
	FAS2_PullGrenadePin() -- 2 separate funcs, don't get confused yo
end

usermessage.Hook("FAS2_PULLPIN", FAS2_PullPin)

local function FAS2_ThrowNade()
	FAS2_ThrowGrenade() -- same as before
end

usermessage.Hook("FAS2_THROWGRENADE", FAS2_ThrowNade)

local function FAS2_DeployGrenade()
	FAS2_DrawGrenade() -- and again
end

usermessage.Hook("FAS2_DRAWGRENADE", FAS2_DeployGrenade)