local muz, muz2, eyeang, vm, dlight, att, dir

function SWEP:CreateMuzzle()
	if self.Owner:ShouldDrawLocalPlayer() then
		return
	end

	vm = self.Wep
	vm:StopParticles()
	
	if self.dt.Suppressed then
		muz2 = vm:LookupAttachment("muzzle_suppressor")
	else
		muz2 = vm:LookupAttachment(self.MuzzleName and self.MuzzleName or "muzzle")
	end
	
	muz = vm:GetAttachment(muz2)
	eyeang = self.Owner:EyeAngles()
	
	if self.MuzzleEffect then
		if self.dt.Suppressed then
			ParticleEffectAttach("muzzleflash_suppressed", PATTACH_POINT_FOLLOW, vm, muz2)
		else
			ParticleEffectAttach(self.MuzzleEffect, PATTACH_POINT_FOLLOW, vm, muz2)
		end
	end
	
	if not self.dt.Suppressed and muz then
		dlight = DynamicLight(self:EntIndex())
		
		dlight.r = 255 
		dlight.g = 218
		dlight.b = 74
		dlight.Brightness = 4
		dlight.Pos = muz.Pos + self.Owner:GetAimVector() * 3
		dlight.Size = 96
		dlight.Decay = 128
		dlight.DieTime = CurTime() + FrameTime()
	end
end

function SWEP:CreateShell(sh)
	if self.Owner:ShouldDrawLocalPlayer() then
		return
	end
	
	sh = self.Shell or sh
	att = self.Wep:GetAttachment(self.Wep:LookupAttachment("ejector"))

	if att then
		att.Pos.z = att.Pos.z - 2
		dir = att.Ang:Forward()
	
		FAS2_MakeFakeShell(sh, att.Pos + dir * 3, EyeAngles(), dir * 200, 0.6, 5)
	end
end