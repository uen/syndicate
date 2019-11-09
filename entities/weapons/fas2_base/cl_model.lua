local vm, EP, EA, FT, CT, TargetPos, TargetAng, cos1, cos2, sin1, sin2, vel, att, ang, delta, tan, mod, tr, dist, move, rs, pos, ang, wm, ong, iv, dif1, dif2, VM, ws, x, y
local BlendSpeed, BlendType, ApproachSpeed = 8, 1, 10
local AngMod, PosMod, Vec0, VecDown, BipodVec = Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, -10), Vector(1, 4, -1)
local PeekVec
local SprintPos, SprintAng, AngDif, AngleTable = Vector(4, -2.09, -0.24), Vector(-12.968, 47.729, 0), Angle(0, 0, 0), Angle(0, 0, 0)
local td = {}
local NadeTargetPos, NadeTargetAng
local TargetPos, TargetAng = Vector(0, 0, 0), Vector(0, 0, 0)
local Ang0 = Angle(0, 0, 0)

SWEP.PSO1Glass = Material("models/weapons/view/accessories/Lens_EnvSolid")
SWEP.ScopeRT = GetRenderTarget("fas2_scope_rt", 512, 512, false)
SWEP.AngleDelta2 = Angle(0, 0, 0)

local math, draw, surface, cam, render = math, draw, surface, cam, render -- local look-ups are faster than global look-ups, saves a couple of milliseconds, M-MUH PERFORMANCE
local ps2 = render.SupportsPixelShaders_2_0()

local _Material			= Material("pp/toytown-top")
_Material:SetTexture("$fbtexture", render.GetScreenEffectTexture())

local reg = debug.getregistry()
local Right = reg.Angle.Right
local Up = reg.Angle.Up
local Forward = reg.Angle.Forward
local RotateAroundAxis = reg.Angle.RotateAroundAxis
local GetBonePosition = reg.Entity.GetBonePosition
local GetSequence = reg.Entity.GetSequence
local GetSequenceName = reg.Entity.GetSequenceName

local trace

local Lerp, LerpVector, LerpAngle, EyePos, EyeAngles, FrameTime, CurTime, GetConVarNumber = Lerp, LerpVector, LerpAngle, EyePos, EyeAngles, FrameTime, CurTime, GetConVarNumber
local blur = Material("pp/bokehblur")
SWEP.BlurDist = 0
SWEP.BlurStrength = 0

function SWEP:createManagedCModel(...)
	local ent = ClientsideModel(...)
	FASCModelManager:add(ent, self)
	
	return ent
end
	
function SWEP:PreDrawViewModel()
	if GetConVarNumber("fas2_blureffects") > 0 and ps2 then
		FT, CT = FrameTime(), CurTime()
		
		if GetConVarNumber("fas2_blureffects_depth") > 0 then
			if self.dt.Status == FAS_STAT_ADS then
				if (self.BlurOnAim and self.Peeking) or not self.BlurOnAim then
					pos = self.Owner:GetShootPos()
					trace = util.QuickTrace(pos, EyeAngles():Forward() * 4096, self.Owner)
					self.BlurDist = math.Approach(self.BlurDist, trace.HitPos:Distance(pos) / 4096, FT * 3)
					self.BlurStrength = math.Approach(self.BlurStrength, 5, FT * 10)
				else
					self.BlurStrength = math.Approach(self.BlurStrength, 0, FT * 10)
				end
			else
				self.BlurStrength = math.Approach(self.BlurStrength, 0, FT * 10)
			end
			
			if self.BlurStrength > 0 then
				render.UpdateScreenEffectTexture()

				blur:SetTexture("$BASETEXTURE", render.GetScreenEffectTexture())
				blur:SetTexture("$DEPTHTEXTURE", render.GetResolvedFullFrameDepth())

				blur:SetFloat("$size", self.BlurStrength)
				blur:SetFloat("$focus", self.BlurDist)
				blur:SetFloat("$focusradius", 2)

				render.SetMaterial(blur)
				render.DrawScreenQuad()
			end
		end
		
		if self.dt.Status == FAS_STAT_ADS and not self.Peeking then
			if self.AimPos == self.ACOGPos or self.AimPos == self.PSO1Pos or self.AimPos == self.ELCANPos or self.AimPos == self.LeupoldPos or self.BlurOnAim then
				self.BlurAmount = math.Approach(self.BlurAmount, 10, FT * 20)
			else
				self.BlurAmount = math.Approach(self.BlurAmount, 0, FT * 40)
			end
		elseif self.dt.Status == FAS_STAT_CUSTOMIZE then
			self.BlurAmount = math.Approach(self.BlurAmount, 10, FT * 20)
		else
			if not self.MagCheck then
				if self.HealTime and CT + 0.3 < self.HealTime then
					self.BlurAmount = math.Approach(self.BlurAmount, 20, FT * 20)
				else
					self.BlurAmount = math.Approach(self.BlurAmount, 0, FT * 20 * (self.Peeking and 2 or 1))
				end
			end
		end
		
		x, y = ScrW(), ScrH()

		cam.Start2D()
			surface.SetMaterial(_Material)
			surface.SetDrawColor(255, 255, 255, 255)
			
			for i = 1, self.BlurAmount do
				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect(0, 0, x, y * 2)
			end

		cam.End2D()
	else
		DOFModeHack(false)
	end
	
	render.SetBlend(0)
end

hook.Add("NeedsDepthPass", "FAS2_NeedsDepthPass", function()
	if not ps2 or GetConVarNumber("fas2_blureffects") <= 0 or GetConVarNumber("fas2_blureffects_depth") <= 0 then
		return false
	end
	
	ply = LocalPlayer()
	
	if ply:Alive() then
		wep = ply:GetActiveWeapon()
		
		if IsValid(wep) and wep.IsFAS2Weapon then
			if wep.BlurStrength > 0 then
				DOFModeHack(true)
				return true
			end
		end
	end
	
	return false
end)

local veldepend = {pitch = 0, yaw = 0, roll = 0}
local len
	
function SWEP:PostDrawViewModel()
	render.SetBlend(1)
	VM, EP, EA, FT, CT = self.Owner:GetViewModel(), EyePos(), EyeAngles(), FrameTime(), CurTime()
	vel, ong = self.Owner:GetVelocity(), self.Owner:OnGround()
	len = vel:Length()
	vm = self.Nade
	
	AngleTable.p = EA.P
	AngleTable.y = EA.Y
	delta = AngleTable - self.OldDelta
		
	self.OldDelta.p = EA.p
	self.OldDelta.y = EA.y
	
	if not self.dt.Bipod then
		if self.SwayInterpolation == "linear" then
			self.AngleDelta = LerpAngle(math.Clamp(FT * 15, 0, 1), self.AngleDelta, delta)
			self.AngleDelta.y = math.Clamp(self.AngleDelta.y, -15, 15)
		else
			delta.p = math.Clamp(delta.p, -5, 5)
			self.AngleDelta2 = LerpAngle(math.Clamp(FT * 12, 0, 1), self.AngleDelta2, self.AngleDelta)
			AngDif.x = (self.AngleDelta.p - self.AngleDelta2.p)
			AngDif.y = (self.AngleDelta.y - self.AngleDelta2.y)
			self.AngleDelta = LerpAngle(math.Clamp(FT * 15, 0, 1), self.AngleDelta, delta + AngDif)
			self.AngleDelta.y = math.Clamp(self.AngleDelta.y, -25, 25)
		end
	else
		self.AngleDelta = LerpAngle(math.Clamp(FT * 15, 0, 1), self.AngleDelta, Ang0)
	end
	
	if IsValid(vm) then
		if CT < vm.LifeTime then
			NadeTargetPos = Vec0 * 1
			NadeTargetAng = Vec0 * 1
			
			if ong then
				ws = self.Owner:GetWalkSpeed()

				if len > 30 and len < ws * 1.3 then
					move = math.Clamp(len / ws, 0, 1)
						
					if self.Owner:Crouching() then
						cos1, sin1 = math.cos(CT * 5), math.sin(CT * 5)
						tan = math.atan(cos1 * sin1, cos1 * sin1)
					else
						cos1, sin1 = math.cos(CT * 7), math.sin(CT * 7)
						tan = math.atan(cos1 * sin1, cos1 * sin1)
					end

					NadeTargetAng[1] = NadeTargetAng[1] + tan * 2 * move
					NadeTargetAng[2] = NadeTargetAng[2] + cos1 * move
					NadeTargetAng[3] = NadeTargetAng[3] + sin1 * move
								
					NadeTargetPos[1] = NadeTargetPos[1] + sin1 * 0.1 * move
					NadeTargetPos[2] = NadeTargetPos[2] + tan * 0.2 * move
					NadeTargetPos[3] = NadeTargetPos[3] + tan * 0.1 * move
				elseif self.Owner:KeyDown(IN_SPEED) and len >= ws * 1.3 then
					tan = math.atan(cos1 * sin1, cos1 * sin1)
					
					rs = self.Owner:GetRunSpeed()
					cos1, sin1 = math.cos(CT * (7 + rs / 100)), math.sin(CT * (7 + rs / 100))
					move = math.Clamp(len / rs, 0, 1)
					
					NadeTargetAng[1] = NadeTargetAng[1] + tan * 4 * move
					NadeTargetAng[2] = NadeTargetAng[2] + cos1 * 5 * move
					NadeTargetAng[3] = NadeTargetAng[3] + sin1 * 4 * move
					
					NadeTargetPos[1] = NadeTargetPos[1] + sin1 * 0.75 * move
					NadeTargetPos[2] = NadeTargetPos[2] + tan * 0.6 * move
					NadeTargetPos[3] = NadeTargetPos[3] + tan * move
				end
			end
			
			self.NadeBlendPos = LerpVector(FT * 8, self.NadeBlendPos, NadeTargetPos)
			self.NadeBlendAng = LerpVector(FT * 8, self.NadeBlendAng, NadeTargetAng)
			
			EA = EA * 1
			RotateAroundAxis(EA, Right(EA), self.NadeBlendAng[1] + self.AngleDelta.y * 0.075)
			RotateAroundAxis(EA, Up(EA), self.NadeBlendAng[2])
			RotateAroundAxis(EA, Forward(EA), self.NadeBlendAng[3] + self.AngleDelta.y * 0.05)
				
			EP = EP + (self.NadeBlendPos[1] - self.AngleDelta.p * 0.1) * Right(EA)  
			EP = EP + (self.NadeBlendPos[2] + self.AngleDelta.y * 0.1) * Forward(EA)
			EP = EP + (self.NadeBlendPos[3] + self.AngleDelta.y * 0.1) * Up(EA)
			
			vm:SetRenderOrigin(EP - self.Owner:GetAimVector() * 2)
			vm:SetRenderAngles(EA)
			vm:FrameAdvance(FT)
			vm:SetupBones()
			vm:SetParent(VM)
			vm:DrawModel()
		end
	end
	
	vm = self.Wep
	
	EP, EA = EyePos(), EyeAngles() -- fresh eye angles and shit because we're going to modify shit
		
	if IsValid(vm) then
		iv = self.Owner.InVehicle and self.Owner:InVehicle() -- what retard overrides or removes InVehicle?
		
		if self.FirstDeploy then
			FAS2_PlayAnim(self, self.Anims.Draw_First, 1, 0)
			self.FirstDeploy = false
		end
		
		if self.Owner.CurClass then
			if self.Owner.CurClass != self.Class then
				if not self.FirstDeploy then
					if GetSequenceName(vm, GetSequence(vm)) != self.Anims.Draw_First then
						self:PlayDeployAnim()
					end
				end
			end
		end
		
		self.Owner.CurClass = self.Class
		
		if iv then
			if not self.Vehicle then
				self:PlayHolsterAnim()
				self.Vehicle = true
				self:EmitSound("weapons/weapon_holster" .. math.random(1, 3) .. ".wav", 50, 100)
			end
		else
			if self.Vehicle then
				self:PlayDeployAnim()
				self.Vehicle = false
			end
		end
		
		if self.dt.Status == FAS_STAT_ADS then
			self.ViewModelFOV = Lerp(FT * 10, self.ViewModelFOV, self.TargetViewModelFOV)
		else
			self.ViewModelFOV = Lerp(FT * 10, self.ViewModelFOV, self.ViewModelFOV_Orig)
		end	
		
		if self.dt.Status != FAS_STAT_SPRINT then
			TargetPos = Vec0 * 1
			TargetAng = Vec0 * 1
			ApproachSpeed = 10
		end
		
		self.NearWall = false
		
		if self.dt.Status == FAS_STAT_ADS then
			if self.CanPeek and self.Peeking then
				if self.dt.Bipod then
					if self[self.AimPosName .. "_Bipod"] then
						TargetPos = (self[self.AimPosName .. "_Bipod"] + BipodVec) *1
					else
						TargetPos = (self.AimPos + BipodVec) * 1
					end
				else
					TargetPos = (self.AimPos + BipodVec) * 1
				end
			else
				TargetPos = (self.dt.Bipod and self[self.AimPosName .. "_Bipod"] or self.AimPos) * 1
			end
			
			TargetAng = (self.dt.Bipod and self[self.AimAngName .. "_Bipod"] or self.AimAng) * 1
			
			BlendSpeed = Lerp(FT * 3, BlendSpeed, 15)
			self.SlowDownBlend = true
			move = math.Clamp(len / self.Owner:GetWalkSpeed(), 0, 1)
			
			if len > 30 and ong then
				cos1, sin1 = math.cos(CT * 8), math.sin(CT * 8)
				tan = math.atan(cos1 * sin1, cos1 * sin1)
				
				TargetAng[1] = TargetAng[1] + tan * 0.5 * move 
				TargetAng[2] = TargetAng[2] + cos1 * 0.25 * move 
				TargetAng[3] = TargetAng[3] + sin1 * 0.25 * move 
						
				TargetPos[1] = TargetPos[1] + sin1 * 0.05 * move 
				TargetPos[2] = TargetPos[2] + tan * 0.1 * move 
				TargetPos[3] = TargetPos[3] + tan * 0.05 * move 
			end
			
			AngMod = LerpVector(FT * 10, AngMod, Vec0)
			PosMod = LerpVector(FT * 10, PosMod, Vec0)
		elseif self.dt.Status == FAS_STAT_QUICKGRENADE then
			BlendSpeed = 2
			TargetPos = VecDown * 1
			TargetAng = Vec0 * 1
		elseif self.dt.Status == FAS_STAT_SPRINT then
			if self.SlowDownBlend then
				self.SlowDownBlend = false
				BlendSpeed = 5
			end
			
			rs = self.Owner:GetRunSpeed()
			
			if self.FireMode == "safe" then
				cos1, sin1 = math.cos(CT * (8 + rs / 100)), math.sin(CT * (8 + rs / 100))
			else
				if self.MagCheck then
					cos1, sin1 = math.cos(CT * (8 + rs / 100)), math.sin(CT * (8 + rs / 100))
				else
					if self.MoveType == 2 or self.MoveType == 3 then
						cos1, sin1 = math.cos(CT * (8 + rs / 100)), math.sin(CT * (8 + rs / 100))
					else
						cos1, sin1 = math.cos(CT * (7 + rs / 100)), math.sin(CT * (7 + rs / 100))
					end
				end
			end
			
			move = math.Clamp(len / rs, 0, 1)
			
			if self.MagCheck then
				BlendSpeed = Lerp(FT * 3, BlendSpeed, 5)
				tan = math.atan(cos1 * sin1, cos1 * sin1)
				
				TargetPos = Vec0 * 1
				TargetAng = Vec0 * 1
				ApproachSpeed = 10

				TargetAng[1] = TargetAng[1] + tan * 4 * move
				TargetAng[2] = TargetAng[2] + cos1 * 5 * move
				TargetAng[3] = TargetAng[3] + sin1 * 4 * move
				
				TargetPos[1] = TargetPos[1] + sin1 * 0.75 * move
				TargetPos[2] = TargetPos[2] + tan * 0.6 * move
				TargetPos[3] = TargetPos[3] + tan * move
			else
				BlendSpeed = Lerp(FT * 3, BlendSpeed, 9)
				
				--TargetPos = (self.SprintPos and self.SprintPos or Vector(4, -2.09, -0.24)) * 1
				--TargetAng = (self.SprintAng and self.SprintAng or Vector(-12.968, 47.729, 0)) * 1
				
				if self.FireMode == "safe" then
					tan = math.atan(cos1 * sin1, cos1 * sin1)
					AngMod[1] = Lerp(FT * 15, AngMod[1], tan * 7.5 * move)
					AngMod[2] = Lerp(FT * 15, AngMod[2], sin1 * 3 * move)
					AngMod[3] = Lerp(FT * 15, AngMod[3], tan * -5 * move)
					PosMod[1] = Lerp(FT * 15, PosMod[1], tan * 2.5 * move)
					PosMod[2] = Lerp(FT * 15, PosMod[2], sin1 * 2 * move)
					PosMod[3] = Lerp(FT * 15, PosMod[3], math.atan(cos1, sin1) * 5 * move)
					
					if self.SafePosType == "pistol" then
						TargetPos = self.PistolSafePos * 1
						TargetAng = self.PistolSafeAng * 1
					else
						TargetPos = self.RifleSafePos * 1
						TargetAng = self.RifleSafeAng * 1
					end
				else
					if self.MoveType == 2 then
						tan = math.atan(cos1 * sin1, cos1 * sin1)
						
						AngMod[1] = Lerp(FT * 15, AngMod[1], tan * 6 * move)
						AngMod[2] = Lerp(FT * 15, AngMod[2], cos1 * 1.5 * move)
						AngMod[3] = Lerp(FT * 15, AngMod[3], cos1 * -4 * move)
						PosMod[1] = Lerp(FT * 15, PosMod[1], tan * 4 * move)
						PosMod[2] = Lerp(FT * 15, PosMod[2], cos1 * 2 * move)
						PosMod[3] = Lerp(FT * 15, PosMod[3], math.atan(cos1, sin1) * 5 * move)
					elseif self.MoveType == 3 then
						tan = math.atan(cos1 * sin1, cos1 * sin1)
						AngMod[1] = Lerp(FT * 15, AngMod[1], tan * 4 * move)
						AngMod[2] = Lerp(FT * 15, AngMod[2], sin1 * 1.5 * move)
						AngMod[3] = Lerp(FT * 15, AngMod[3], tan * -4 * move)
						PosMod[1] = Lerp(FT * 15, PosMod[1], tan * 2 * move)
						PosMod[2] = Lerp(FT * 15, PosMod[2], sin1 * 2 * move)
						PosMod[3] = Lerp(FT * 15, PosMod[3], math.atan(cos1, sin1) * 5 * move)
					else
						AngMod[1] = Lerp(FT * 15, AngMod[1], cos1 * -2.5 * move)
						AngMod[2] = Lerp(FT * 15, AngMod[2], sin1 * -1.5 * move)
						AngMod[3] = Lerp(FT * 15, AngMod[3], sin1 * -1.5 * move)
						PosMod[1] = Lerp(FT * 15, PosMod[1], math.atan(cos1, sin1) * 3 * move)
						PosMod[2] = Lerp(FT * 15, PosMod[2], cos1 * 5 * move)
						PosMod[3] = Lerp(FT * 15, PosMod[3], sin1 * cos1 * 9 * move)
					end

					if self.MoveType == 1 then
						TargetPos[1] = math.Approach(TargetPos[1], (self.SprintPos and self.SprintPos[1] or 4), FT * 25 + math.Clamp(tan, -0.4, 0.1))
						TargetPos[2] = math.Approach(TargetPos[2], (self.SprintPos and self.SprintPos[2] or -2.09), FT * 25 + math.Clamp(cos1, 0, 0.2))
						TargetPos[3] = math.Approach(TargetPos[3], (self.SprintPos and self.SprintPos[3] or -0.24), FT * 25 + math.Clamp(cos1, 0, 0.4))
					
						TargetAng[1] = math.Approach(TargetAng[1], (self.SprintAng and self.SprintAng[1] or -12.968), FT * ApproachSpeed)
						TargetAng[2] = math.Approach(TargetAng[2], (self.SprintAng and self.SprintAng[2] or 47.729), FT * ApproachSpeed)
						TargetAng[3] = math.Approach(TargetAng[3], (self.SprintAng and self.SprintAng[3] or 0), FT * ApproachSpeed)
						ApproachSpeed = math.Approach(ApproachSpeed, 100, FT * 200)
					elseif self.MoveType == 2 then
						TargetPos[1] = math.Approach(TargetPos[1], (self.SprintPos and self.SprintPos[1] or 4), FT * 15)
						TargetPos[2] = math.Approach(TargetPos[2], (self.SprintPos and self.SprintPos[2] or -2.09), FT * 15)
						TargetPos[3] = math.Approach(TargetPos[3], (self.SprintPos and self.SprintPos[3] or -0.24), FT * 21)
					
						TargetAng[1] = math.Approach(TargetAng[1], (self.SprintAng and self.SprintAng[1] or -12.968), FT * ApproachSpeed)
						TargetAng[2] = math.Approach(TargetAng[2], (self.SprintAng and self.SprintAng[2] or 47.729), FT * ApproachSpeed)
						TargetAng[3] = math.Approach(TargetAng[3], (self.SprintAng and self.SprintAng[3] or 0), FT * ApproachSpeed)
						ApproachSpeed = math.Approach(ApproachSpeed, 300, FT * 600)
					else
						TargetPos = (self.SprintPos and self.SprintPos or SprintPos) * 1
						TargetAng = (self.SprintAng and self.SprintAng or SprintAng) * 1
					end
				end
				
				//AngMod[1] = Lerp(FT * 15, AngMod[1], cos1 * -2.5)
				//AngMod[2] = Lerp(FT * 15, AngMod[2], sin1 * -1.5)
				//AngMod[3] = Lerp(FT * 15, AngMod[3], sin1 * -1.5)
				//PosMod[1] = Lerp(FT * 15, PosMod[1], math.atan(cos1, sin1) * 3)
				//PosMod[2] = Lerp(FT * 15, PosMod[2], cos1 * 5)
				//PosMod[3] = Lerp(FT * 15, PosMod[3], sin1 * cos1 * 9)
			end
		else
			if self.dt.Status == FAS_STAT_CUSTOMIZE then
				TargetPos = self.CustomizePos * 1
				TargetAng = self.CustomizeAng * 1
			else
				if self.FireMode == "safe" then
					if self.SafePosType == "pistol" then
						TargetPos = self.PistolSafePos * 1
						TargetAng = self.PistolSafeAng * 1
					else
						TargetPos = self.RifleSafePos * 1
						TargetAng = self.RifleSafeAng * 1
					end
				else
					if GetConVarNumber("fas2_differentorigins") > 0 then
						TargetPos[1] = TargetPos[1] - 0.5
						TargetPos[3] = TargetPos[3] + 0.25
					end
				end
			end
			
			if self.dt.Status != FAS_STAT_CUSTOMIZE and not self.NoNearWall and self.FireMode != "safe" then
				td.start = self.Owner:GetShootPos()
				td.endpos = td.start + self.Owner:GetAimVector() * 30
				td.filter = self.Owner
				
				tr = util.TraceLine(td)
				
				if tr.Hit then
					self.NearWall = true
					dist = tr.HitPos:Distance(td.start)
					
					TargetAng[1] = TargetAng[1] - math.Clamp((30 - dist), 0, 10)
					TargetAng[2] = TargetAng[2] + math.Clamp((30 - dist) * 2, 0, 20)
					TargetPos[2] = TargetPos[2] + math.Clamp((30 - dist) * 0.1, 0, 1)
				end
			end
			
			BlendSpeed = Lerp(FT * 3, BlendSpeed, 12)
			
			if len > 30 and ong then
				move = math.Clamp(len / self.Owner:GetWalkSpeed(), 0, 1)
				
				if self.Owner:Crouching() then
					cos1, sin1 = math.cos(CT * 6), math.sin(CT * 6)
					tan = math.atan(cos1 * sin1, cos1 * sin1)
				else
					cos1, sin1 = math.cos(CT * 8.5), math.sin(CT * 8.5)
					tan = math.atan(cos1 * sin1, cos1 * sin1)
				end
				
				TargetAng[1] = TargetAng[1] + tan * 2 * move
				TargetAng[2] = TargetAng[2] + cos1 * move
				TargetAng[3] = TargetAng[3] + sin1 * move
						
				TargetPos[1] = TargetPos[1] + sin1 * 0.1 * move
				TargetPos[2] = TargetPos[2] + tan * 0.2 * move
				TargetPos[3] = TargetPos[3] + tan * 0.1 * move
				
				/*AngMod[1] = Lerp(FT * 15, AngMod[1], cos1 * sin1 * 0.5)
				AngMod[2] = Lerp(FT * 15, AngMod[2], math.atan(cos1, sin1) * 0.35)
				AngMod[3] = Lerp(FT * 15, AngMod[3], cos1 * -0.5)
				PosMod[1] = Lerp(FT * 15, PosMod[1], cos1 * sin1)
				PosMod[2] = Lerp(FT * 15, PosMod[2], cos1)
				PosMod[3] = Lerp(FT * 15, PosMod[3], cos1 * 0.5)*/
			else
				if self.dt.Status != FAS_STAT_ADS and not self.dt.Bipod then
					cos1, sin1 = math.cos(CT), math.sin(CT)
					tan = math.atan(cos1 * sin1, cos1 * sin1)
						
					TargetAng[1] = TargetAng[1] + tan * 1.15
					TargetAng[2] = TargetAng[2] + cos1 * 0.4
					TargetAng[3] = TargetAng[3] + tan
						
					TargetPos[2] = TargetPos[2] + tan * 0.2
				end
			end
			
			AngMod = LerpVector(FT * 10, AngMod, Vec0)
			PosMod = LerpVector(FT * 10, PosMod, Vec0)
		end
		
		mod = 1
		
		if self.dt.Status == FAS_STAT_ADS then
			mod = 0.25
		end
		
		if ong and (self.Owner:Crouching() or self.Owner:KeyDown(IN_DUCK)) and self.dt.Status != FAS_STAT_ADS and self.dt.Status != FAS_STAT_CUSTOMIZE then
			TargetPos[3] = TargetPos[3] - 0.5
			TargetPos[1] = TargetPos[1] - 0.5
			TargetPos[2] = TargetPos[2] - 0.5
		end
		
		dif1, dif2 = 0, 0
		
		if GetConVarNumber("fas2_alternatebipod") > 0 then
			if self.dt.Bipod and self.DeployAngle and self.dt.Status == FAS_STAT_IDLE then
				dif1 = math.AngleDifference(self.DeployAngle.y, EA.y)
				dif2 = math.AngleDifference(self.DeployAngle.p, EA.p)
				TargetPos[3] = TargetPos[3] - 1
				TargetPos[2] = TargetPos[2] + 2
				
				if CT < self.BipodMoveTime then
					self.BipodPos[1] = math.Approach(self.BipodPos[1], dif1 * 0.3, FT * 50)
					self.BipodPos[3] = math.Approach(self.BipodPos[3], dif2 * 0.3 --[[+ 1]], FT * 50)
					
					self.BipodAng[1] = math.Approach(self.BipodAng[1], dif1 * 0.1, FT * 50)
					self.BipodAng[3] = math.Approach(self.BipodAng[3], dif2 * 0.1, FT * 50)
				else
					self.BipodPos[1] = dif1 * 0.3
					self.BipodPos[3] = dif2 * 0.3 // + 1
					
					self.BipodAng[1] = dif1 * 0.1
					self.BipodAng[3] = dif2 * 0.1
				end
			else
				self.BipodPos = LerpVector(FT * 10, self.BipodPos, Vec0)
				self.BipodAng = LerpVector(FT * 10, self.BipodAng, Vec0)
				self.BipodMoveTime = CT + 0.2
			end
		else
			self.BipodPos[1] = 0
			self.BipodPos[3] = 0
					
			self.BipodAng[1] = 0
			self.BipodAng[3] = 0
		end
		
		veldepend.roll = math.Clamp((vel:DotProduct(EA:Right()) * 0.04) * len / self.Owner:GetWalkSpeed(), -5, 5)
		
		self.BlendPos[1] = Lerp(FT * BlendSpeed, self.BlendPos[1], TargetPos[1] + self.AngleDelta.y * (0.15 * mod))
		self.BlendPos[2] = Lerp(FT * BlendSpeed * 0.6, self.BlendPos[2], TargetPos[2])
		self.BlendPos[3] = Lerp(FT * BlendSpeed * 0.75, self.BlendPos[3], TargetPos[3] + self.AngleDelta.p * (0.2 * mod) + math.abs(self.AngleDelta.y) * (0.02 * mod))
			
		self.BlendAng[1] = Lerp(FT * BlendSpeed * 0.75, self.BlendAng[1], TargetAng[1] + AngMod[1] - self.AngleDelta.p * (1.5 * mod))
		self.BlendAng[2] = Lerp(FT * BlendSpeed, self.BlendAng[2], TargetAng[2] + AngMod[2] + self.AngleDelta.y * (0.3 * mod))
		self.BlendAng[3] = Lerp(FT * BlendSpeed, self.BlendAng[3], TargetAng[3] + AngMod[3] + self.AngleDelta.y * (0.6 * mod) + veldepend.roll)
		
		EA = EA * 1
		RotateAroundAxis(EA, Right(EA), self.BlendAng[1] + PosMod[1] + self.BipodAng[3])
		RotateAroundAxis(EA, Up(EA), self.BlendAng[2] + PosMod[2] - self.BipodAng[1])
		RotateAroundAxis(EA, Forward(EA), self.BlendAng[3] + PosMod[3])
		
		EP = EP + (self.BlendPos[1] - self.BipodPos[1]) * Right(EA)  
		EP = EP + self.BlendPos[2] * Forward(EA)
		EP = EP + (self.BlendPos[3] - self.BipodPos[3]) * Up(EA)
		
		/*EA:RotateAroundAxis(EA:Right(), self.BlendAng[1] + PosMod[1] + (self.dt.Bipod and math.AngleDifference(self.DeployAngle.p, EA.p) or 0) * 0.1)
		EA:RotateAroundAxis(EA:Up(), self.BlendAng[2] + PosMod[2] - (self.dt.Bipod and math.AngleDifference(self.DeployAngle[2], EA[2]) or 0) * 0.1)
		EA:RotateAroundAxis(EA:Forward(), self.BlendAng[3] + PosMod[3])
		
		EP = EP + (self.BlendPos[1] - (self.dt.Bipod and math.AngleDifference(self.DeployAngle[2], EA[2]) or 0) * 0.3) * EA:Right()  
		EP = EP + self.BlendPos[2] * EA:Forward()
		EP = EP + (self.BlendPos[3] - (self.dt.Bipod and math.AngleDifference(self.DeployAngle.p, EA.p) or 0) * 0.3) * EA:Up()*/
		
		vm:SetRenderOrigin(EP)
		vm:SetRenderAngles(EA)
		vm:FrameAdvance(FT)
		vm:SetupBones()
		vm:SetParent(VM)
		vm:DrawModel()
		
		self:Draw3D2DCamera()
	end
end

function SWEP:DrawWorldModel()
	if not self.HideWorldModel then
		self:DrawModel()
	end
	
	if self.dt.Status == FAS_STAT_SPRINT or self.dt.Holstered then
		self:SetWeaponHoldType(self.RunHoldType)
	else
		self:SetWeaponHoldType(self.HoldType)
	end
	
	wm = self.W_Wep
	
	if IsValid(wm) then
		if IsValid(self.Owner) then
			if self.Owner:InVehicle() then
				return
			end
	
			local bone = self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")
			
			if bone then
				pos, ang = GetBonePosition(self.Owner, bone)
				
				if pos and ang then
					RotateAroundAxis(ang, ang:Right(ang), self.WMAng[1])
					RotateAroundAxis(ang, ang:Up(ang), self.WMAng[2])
					RotateAroundAxis(ang, Forward(ang), self.WMAng[3])
					
					pos = pos + self.WMPos[1] * Right(ang) 
					pos = pos + self.WMPos[2] * Forward(ang)
					pos = pos + self.WMPos[3] * Up(ang)
					
					wm:SetRenderOrigin(pos)
					wm:SetRenderAngles(ang)
					wm:SetModelScale(self.WMScale, 0)
					wm:DrawModel()
				end
			end
		else
			wm:SetRenderOrigin(self:GetPos())
			wm:SetRenderAngles(self:GetAngles())
			wm:DrawModel()
			wm:DrawShadow()
		end
	end
end

local grad = surface.GetTextureID("VGUI/fas2/gradient")
local compm4_reticle = Material("models/weapons/view/accessories/aimpoint_reticle")
local eotech_reticle = Material("sprites/fas2/eotech_reddot")
local seq, cyc, att, t, tex, x, y, y2, diff, mag, dir, dist, namefound
local YOff, XOff = 0

SWEP.AnimRecognition = {["Reload1"] = true, 
	["Reload2"] = true, 
	["Reload3"] = true, 
	["Reload4"] = true, 
	["Reload5"] = true, 
	["Reload1_nomen"] = true, 
	["Reload2_nomen"] = true, 
	["Reload3_nomen"] = true, 
	["Reload4_nomen"] = true, 
	["Reload5_nomen"] = true, 
	["Reload_1"] = true, 
	["Reload_2"] = true, 
	["Reload_3"] = true, 
	["Reload_4"] = true, 
	["Reload_1_Nomen"] = true, 
	["Reload_2_Nomen"] = true, 
	["Reload_3_Nomen"] = true, 
	["Reload_4_Nomen"] = true, 
	["Reload_empty"] = true,
	["Reload"] = true, 
	["Reload_Empty"] = true,
	["Reload_Nomen"] = true,
	["Reload_Empty_Nomen"] = true,
	["Reload_10"] = true,
	["Reload_10_Nomen"] = true,
	["Reload_Empty_10"] = true,
	["Reload_Empty_10_Nomen"] = true,
	["Reload_20"] = true,
	["Reload_20_Nomen"] = true,
	["Reload_Empty_20"] = true,
	["Reload_Empty_20_Nomen"] = true,
	["Reload_30"] = true,
	["Reload_30_Nomen"] = true,
	["Reload_Empty_30"] = true,
	["Reload_Empty_30_Nomen"] = true}
	
local White, Black, Grey, Red, Green = Color(255, 255, 255, 255), Color(0, 0, 0, 255), Color(200, 200, 200, 255), Color(255, 137, 119, 255), Color(202, 255, 163, 255)
local MagTextColor = {r = 255, g = 255, b = 255}

local GetAttachment = reg.Entity.GetAttachment
local LookupAttachment = reg.Entity.LookupAttachment
local ShadowText

timer.Simple(1, function()
	ShadowText = draw.ShadowText
end)

function SWEP:Draw3D2DCamera()
	vm = self.Wep
	att = GetAttachment(vm, LookupAttachment(vm, "muzzle"))
	
	if att then
		self.TracePos = att.Pos
	end
	
	if not att then
		return
	end
	
	if self.dt.Status == FAS_STAT_CUSTOMIZE  then
		ang = self.Owner:EyeAngles()
		RotateAroundAxis(ang, Right(ang), 90)
		RotateAroundAxis(ang, Up(ang), -90)
		RotateAroundAxis(ang, Forward(ang), 0)
		
		YOff = 0
		
		cam.Start3D2D(att.Pos + Forward(ang) * -4 + Right(ang) * -2, ang, 0.015 * GetConVarNumber("fas2_textsize"))
			cam.IgnoreZ(true)
				if not self.ShowStats then
					for k, v in ipairs(self.Attachments) do
						x = v.x and v.x or 0
						y = v.y and v.y or 0
						y2 = 0
						XOff = 0
						
						surface.SetDrawColor(0, 0, 0, 225)
						surface.SetTexture(grad)
						surface.DrawTexturedRect(0 + x, 2 + YOff + y, 200, 52) 
						ShadowText(self:GetKeyBind("slot" .. k) .. " " .. v.header, "FAS2_HUD48", 0 + x, YOff + y, White, Black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
						
						for k2, v2 in ipairs(v.atts) do
							t = FAS2_Attachments[v2]
							
							if v.active == t.key then
								surface.SetTexture(grad)
								surface.SetDrawColor(0, 0, 0, 225)
								surface.DrawTexturedRect(0 + XOff + x, 175 + YOff + y, 300, 25 + #t.desc * 25)
								
								ShadowText(t.namefull, "FAS2_HUD24", 0 + XOff + x, 175 + YOff + y, White, Black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
								
								for k3, v3 in ipairs(t.desc) do
									ShadowText(v3.t, "FAS2_HUD24", 0 + XOff + x, 175 + YOff + y + k3 * 25, v3.c, Black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
								end
								
								surface.SetDrawColor(0, 255, 0, 255)
							else
								if not table.HasValue(FAS2AttOnMe, t.key) then
									surface.SetDrawColor(255, 108, 91, 255)
								else
									surface.SetDrawColor(107, 149, 255, 255)
								end
							end
							
							surface.DrawOutlinedRect(0 + XOff + x, 60 + YOff + y, 90, 90)
							surface.DrawOutlinedRect(1 + XOff + x, 61 + YOff + y, 88, 88)
							
							if v.active == t.key then
								surface.SetDrawColor(0, 0, 0, 225)
							else
								surface.SetDrawColor(0, 0, 0, 150)
							end
							
							surface.DrawRect(0 + XOff + x, 60 + YOff + y, 90, 90)
							
							surface.SetDrawColor(White)
							surface.SetTexture(t.displaytexture)
							surface.DrawTexturedRect(4 + XOff + x, 63 + YOff + y, 83, 83)
							ShadowText(t.nameshort, "FAS2_HUD24", 0 + XOff + x, 150 + YOff + y, White, Black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
							XOff = XOff + 100
						end
						
						YOff = YOff + 180
					end
				else
					ShadowText("STAT", "FAS2_HUD24", 0, -30, White, Black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
					
					ShadowText("DAMAGE", "FAS2_HUD28", 0, 5, White, Black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
					ShadowText("HIP SPREAD", "FAS2_HUD28", 0, 35, White, Black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
					ShadowText("ACCURACY", "FAS2_HUD28", 0, 65, White, Black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
					ShadowText("RECOIL", "FAS2_HUD28", 0, 95, White, Black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
					ShadowText("MOBILITY", "FAS2_HUD28", 0, 125, White, Black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
					ShadowText("FIRERATE", "FAS2_HUD28", 0, 155, White, Black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
					ShadowText("SPREAD INC", "FAS2_HUD28", 0, 185, White, Black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
					ShadowText("MAX SPREAD", "FAS2_HUD28", 0, 215, White, Black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
					surface.SetDrawColor(0, 0, 0, 150)
					surface.DrawRect(175, 0, 80, 250)
					surface.DrawRect(270, 0, 80, 250)
					
					ShadowText("BASE", "FAS2_HUD24", 215, -30, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					ShadowText("CUR", "FAS2_HUD24", 310, -30, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					
					ShadowText(self.Damage_Orig, "FAS2_HUD28", 215, 5, Grey, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					ShadowText(math.Round(self.HipCone_Orig * 1000) .. "%", "FAS2_HUD28", 215, 35, Grey, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					ShadowText(math.Round(100 - self.AimCone_Orig * 1000) .. "%", "FAS2_HUD28", 215, 65, Grey, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					ShadowText(math.Round(self.Recoil_Orig * 100) .. "%", "FAS2_HUD24", 215, 95, Grey, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					ShadowText(math.Round(100 - self.VelocitySensitivity_Orig / 3 * 100) .. "%", "FAS2_HUD28", 215, 125, Grey, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					ShadowText(math.Round(60 / self.FireDelay_Orig), "FAS2_HUD28", 215, 155, Grey, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					ShadowText("+" .. math.Round(self.SpreadPerShot_Orig * 1000) .. "%", "FAS2_HUD24", 215, 185, Grey, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					ShadowText("+" .. math.Round(self.MaxSpreadInc_Orig * 1000) .. "%", "FAS2_HUD24", 215, 215, Grey, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					
					if self.Damage > self.Damage_Orig then
						ShadowText(math.Round(self.Damage), "FAS2_HUD28", 310, 5, Green, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					elseif self.Damage < self.Damage_Orig then
						ShadowText(math.Round(self.Damage), "FAS2_HUD28", 310, 5, Red, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					else
						ShadowText(math.Round(self.Damage), "FAS2_HUD28", 310, 5, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					end
					
					if self.HipCone < self.HipCone_Orig then
						ShadowText(math.Round(self.HipCone * 1000) .. "%", "FAS2_HUD28", 310, 35, Green, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					elseif self.HipCone > self.HipCone_Orig then
						ShadowText(math.Round(self.HipCone * 1000) .. "%", "FAS2_HUD28", 310, 35, Red, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					else
						ShadowText(math.Round(self.HipCone * 1000) .. "%", "FAS2_HUD28", 310, 35, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					end
					
					if self.AimCone < self.AimCone_Orig then
						ShadowText(math.Round(100 - self.AimCone * 1000) .. "%", "FAS2_HUD28", 310, 65, Green, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					elseif self.AimCone > self.AimCone_Orig then
						ShadowText(math.Round(100 - self.AimCone * 1000) .. "%", "FAS2_HUD28", 310, 65, Red, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					else
						ShadowText(math.Round(100 - self.AimCone * 1000) .. "%", "FAS2_HUD28", 310, 65, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					end
					
					if self.Recoil < self.Recoil_Orig then
						ShadowText(math.Round(self.Recoil * 100) .. "%", "FAS2_HUD24", 310, 95, Green, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					elseif self.Recoil > self.Recoil_Orig then
						ShadowText(math.Round(self.Recoil * 100) .. "%", "FAS2_HUD24", 310, 95, Red, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					else
						ShadowText(math.Round(self.Recoil * 100) .. "%", "FAS2_HUD24", 310, 95, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					end
					
					if self.VelocitySensitivity < self.VelocitySensitivity_Orig then
						ShadowText(math.Round(100 - self.VelocitySensitivity / 3 * 100) .. "%", "FAS2_HUD28", 310, 125, Green, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					elseif self.VelocitySensitivity > self.VelocitySensitivity_Orig then
						ShadowText(math.Round(100 - self.VelocitySensitivity / 3 * 100) .. "%", "FAS2_HUD28", 310, 125, Red, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					else
						ShadowText(math.Round(100 - self.VelocitySensitivity / 3 * 100) .. "%", "FAS2_HUD28", 310, 125, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					end
					
					if self.FireDelay < self.FireDelay_Orig then
						ShadowText(math.Round(60 / self.FireDelay), "FAS2_HUD28", 310, 155, Green, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					elseif self.FireDelay > self.FireDelay_Orig then
						ShadowText(math.Round(60 / self.FireDelay), "FAS2_HUD28", 310, 155, Red, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					else
						ShadowText(math.Round(60 / self.FireDelay), "FAS2_HUD28", 310, 155, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					end
					
					if self.SpreadPerShot < self.SpreadPerShot_Orig then
						ShadowText("+" .. math.Round(self.SpreadPerShot * 1000) .. "%", "FAS2_HUD24", 310, 185, Green, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					elseif self.SpreadPerShot > self.SpreadPerShot_Orig then
						ShadowText("+" .. math.Round(self.SpreadPerShot * 1000) .. "%", "FAS2_HUD24", 310, 185, Red, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					else
						ShadowText("+" .. math.Round(self.SpreadPerShot * 1000) .. "%", "FAS2_HUD24", 310, 185, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					end
					
					if self.MaxSpreadInc < self.MaxSpreadInc_Orig then
						ShadowText("+" .. math.Round(self.MaxSpreadInc * 1000) .. "%", "FAS2_HUD24", 310, 215, Green, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					elseif self.MaxSpreadInc > self.MaxSpreadInc then
						ShadowText("+" .. math.Round(self.MaxSpreadInc * 1000) .. "%", "FAS2_HUD24", 310, 215, Red, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					else
						ShadowText("+" .. math.Round(self.MaxSpreadInc * 1000) .. "%", "FAS2_HUD24", 310, 215, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					end
				end
			cam.IgnoreZ(false)
		cam.End3D2D()
		
		return
	end
	
	if self.dt.Status == FAS_STAT_ADS then
		if self.AimPos == self.CompM4Pos then
			diff = (self.BlendPos[1] + self.BlendPos[3]) / (self.CompM4Pos[1] + self.CompM4Pos[3])
				
			if diff > 0.9 and diff < 1.1 then
				cam.IgnoreZ(true)
					render.SetMaterial(compm4_reticle)
					dist = math.Clamp(math.Distance(1, 1, diff, diff), 0, 0.13)
					
					render.DrawSprite(EyePos() + EyeAngles():Forward() * 100, 0.7, 0.7, Color(255, 255, 255, (0.13 - dist) / 0.13 * 255))
				cam.IgnoreZ(false)
			end
		elseif self.AimPos == self.EoTechPos then
			diff = (self.BlendPos[1] + self.BlendPos[3]) / (self.EoTechPos[1] + self.EoTechPos[3])
			
			if diff > 0.9 and diff < 1.1 then
				cam.IgnoreZ(true)
					render.SetMaterial(eotech_reticle)
					dist = math.Clamp(math.Distance(1, 1, diff, diff), 0, 0.1)
					
					render.DrawSprite(EyePos() + EyeAngles():Forward() * 100, 4, 4, Color(255, 255, 255, (0.13 - dist) / 0.1 * 255))
				cam.IgnoreZ(false)
			end
		end
	end
	
	vm = self.Wep
	seq = GetSequenceName(vm, GetSequence(vm))
	cyc = vm:GetCycle()
			
	FT = FrameTime()
	animfound = self.CurAnim:find("reload")
	
	if (animfound or self.AnimOverride and self.AnimOverride[self.CurAnim]) and cyc <= self.ReloadCycleTime and self.dt.Status != FAS_STAT_ADS or (self.Owner:KeyDown(IN_RELOAD) and self.dt.Status == FAS_STAT_ADS) then
		self.MagCheckAlpha = math.Approach(self.MagCheckAlpha, 255, FT * 500)

		if not self.NoBlurOnPump or animfound then
			self.BlurAmount = math.Approach(self.BlurAmount, 10, FT * 20)
		end
		
		self.CheckTime = CT + 1
		self.MagCheck = true
	else
		CT = CurTime()
			
		if (CT < self.CheckTime and self.dt.Status != FAS_STAT_ADS) or CT < self.FireModeSwitchTime then
			self.MagCheckAlpha = math.Approach(self.MagCheckAlpha, 255, FT * 500)
		else
			self.MagCheckAlpha = math.Approach(self.MagCheckAlpha, 0, FT * 500)
		end
		
		if self.dt.Status != FAS_STAT_ADS and self.dt.Status != FAS_STAT_CUSTOMIZE then
			self.BlurAmount = math.Approach(self.BlurAmount, 0, FT * 20)
		end
		
		self.MagCheck = false
	end
	
	if GetConVarNumber("fas2_nohud") <= 0 and GetConVarNumber("fas2_customhud") > 0 then
		if self.CockRemindTime > CT then
			self.CockRemindAlpha = math.Approach(self.CockRemindAlpha, 255, FT * 500)
		else	
			self.CockRemindAlpha = math.Approach(self.CockRemindAlpha, 0, FT * 500)
		end
		
		if self.MagCheckAlpha > 0 or self.CockRemindAlpha > 0 then
			att = GetAttachment(vm, LookupAttachment(vm, (self.MuzzleName and self.MuzzleName or "muzzle")))
			ang = self.Owner:EyeAngles()
			RotateAroundAxis(ang, Right(ang), 90)
			RotateAroundAxis(ang, Up(ang), -90)
			RotateAroundAxis(ang, Forward(ang), 0)
			
			if att then
				cam.Start3D2D(att.Pos + Forward(ang) * self.Text3DForward + Right(ang) * self.Text3DRight, ang, self.Text3DSize * GetConVarNumber("fas2_textsize"))
					cam.IgnoreZ(true)
						if self.CockRemindAlpha > 0 then
							ShadowText(self.BoltReminderText, "FAS2_HUD48", 0, -40, Color(255, 255, 255, self.CockRemindAlpha), Color(0, 0, 0, self.CockRemindAlpha), 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
						end
						
						if self.MagCheckAlpha > 0 then
							mag = self:Clip1()
							
							if mag <= self.Primary.ClipSize * 0.3 then
								MagTextColor.g = Lerp(FT * 5, MagTextColor.g, 125)
								MagTextColor.b = Lerp(FT * 5, MagTextColor.b, 125)
							else
								MagTextColor.g = Lerp(FT * 5, MagTextColor.g, 255)
								MagTextColor.b = Lerp(FT * 5, MagTextColor.b, 255)
							end
							
							if mag > self.Primary.ClipSize then
								ShadowText(self.MagText .. self.Primary.ClipSize .. " + " .. mag - self.Primary.ClipSize, "FAS2_HUD72", 0, 0, Color(MagTextColor.r, MagTextColor.g, MagTextColor.b, self.MagCheckAlpha), Color(0, 0, 0, self.MagCheckAlpha), 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
							else
								ShadowText(self.MagText .. mag, "FAS2_HUD72", 0, 0, Color(MagTextColor.r, MagTextColor.g, MagTextColor.b, self.MagCheckAlpha), Color(0, 0, 0, self.MagCheckAlpha), 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
							end
								
							ShadowText("RESERVE " .. self.Owner:GetAmmoCount(self.Primary.Ammo), "FAS2_HUD48", 0, 60, Color(255, 255, 255, self.MagCheckAlpha), Color(0, 0, 0, self.MagCheckAlpha), 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
							ShadowText(self.FireModeDisplay, "FAS2_HUD36", 0, 105, Color(255, 255, 255, self.MagCheckAlpha), Color(0, 0, 0, self.MagCheckAlpha), 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
							ShadowText(self.Primary.Ammo, "FAS2_HUD24", 0, 140, Color(255, 255, 255, self.MagCheckAlpha), Color(0, 0, 0, self.MagCheckAlpha), 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
								
							if self.MagCheck then
								if animfound and cyc < 0.99 then
									surface.SetDrawColor(0, 0, 0, self.MagCheckAlpha)
									surface.DrawRect(3, 175, 270, 10)
										
									surface.SetDrawColor(255, 255, 255, self.MagCheckAlpha)
									surface.DrawRect(2, 175, 300 * cyc, 8)
								end
							end
						end
					cam.IgnoreZ(false)
				cam.End3D2D()
			end
		end
	end
end

function SWEP:GetViewModelPosition(pos, ang)
	pos = pos + ang:Up() * 100
	return pos, ang
end

local pos, dir

function SWEP:GetTracerOrigin()
	if self.TracePos then
		return self.TracePos
	end
	
	pos = self.Owner:GetShootPos()
	dir = self.Owner:EyeAngles()
	pos = pos + Forward(dir) * 10
	pos = pos + Right(dir) * 5

	return 
end