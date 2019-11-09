local FT, CT, vm, att, cyc, seq, vel, cos1, cos2, intensity
local Ang0, curang, curviewbob = Angle(0, 0, 0), Angle(0, 0, 0), Angle(0, 0, 0)
SWEP.LerpBackSpeed = 10

function SWEP:CalcView(ply, pos, ang, fov)
	fov = fov or GetConVarNumber("fov_desired")
	
	FT, CT = FrameTime(), CurTime()
	vm = self.Wep
	att = vm:GetAttachment(vm:LookupAttachment((self.MuzzleName and self.MuzzleName or "muzzle")))
	seq = vm:GetSequenceName(vm:GetSequence())
	cyc = vm:GetCycle()
	intensity = GetConVarNumber("fas2_headbob_intensity")
	
	if att then
		if self.CurAnim and (self.CurAnim:find("reload") or self.AnimOverride and self.AnimOverride[self.CurAnim]) then
			if cyc <= 0.9 then
				self.LerpBackSpeed = 1
				ang = ang * 1
				curang = LerpAngle(FT * 10, curang, (ang - att.Ang) * 0.1)
			else
				self.LerpBackSpeed = math.Approach(self.LerpBackSpeed, 10, FT * 50)
				curang = LerpAngle(FT * self.LerpBackSpeed, curang, Ang0)
			end
		else
			curang = LerpAngle(FT * 10, curang, Ang0)
		end
	
		ang:RotateAroundAxis(ang:Right(), curang.p * self.PitchMod)
		ang:RotateAroundAxis(ang:Up(), curang.r * self.YawMod)
	end
	
	if self.dt.Status == FAS_STAT_ADS then
		self.CurFOVMod = Lerp(FT * 10, self.CurFOVMod, self.AimFOV)
	else
		self.CurFOVMod = Lerp(FT * 10, self.CurFOVMod, 0)
	end
	
	fov = fov - self.CurFOVMod
	
	if intensity > 0 then -- don't calculate shit that's not on to save performance
		vel = self.Owner:GetVelocity():Length()

		if self.Owner:OnGround() and vel > self.Owner:GetWalkSpeed() * 0.3 then
			if vel < self.Owner:GetWalkSpeed() * 1.2 then
				cos1 = math.cos(CT * 15)
				cos2 = math.cos(CT * 12)
				curviewbob.p = cos1 * 0.15 * intensity
				curviewbob.y = cos2 * 0.1 * intensity
			else
				cos1 = math.cos(CT * 20)
				cos2 = math.cos(CT * 15)
				curviewbob.p = cos1 * 0.25 * intensity
				curviewbob.y = cos2 * 0.15 * intensity
			end
		else
			curviewbob = LerpAngle(FT * 10, curviewbob, Ang0)
		end
	end
	
	return pos, ang + curviewbob, fov
end

function SWEP:AdjustMouseSensitivity()
	if self.dt.Status == FAS_STAT_ADS then

		if self.Peeking then
			return 0.5
		end
		
		if self.AimSens then
			return self.AimSens * self.MouseSensMod * (self.dt.Bipod and 0.7 or 1)
		end
		
		if self.AimPos == self.ACOGPos or self.AimPos == self.PSO1Pos or self.AimPos == self.ELCANPos then
			return 0.2 * self.MouseSensMod * (self.dt.Bipod and 0.7 or 1)
		elseif self.AimPos == self.LeupoldPos then
			return 0.15 * self.MouseSensMod * (self.dt.Bipod and 0.7 or 1)
		end
	end
		
	return 1 * self.MouseSensMod * (self.dt.Bipod and 0.7 or 1)
end