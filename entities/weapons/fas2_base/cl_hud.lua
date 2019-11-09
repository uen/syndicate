local FT, x, y, x2, y2, CT, size, tr, lp
local ClumpSpread = surface.GetTextureID("VGUI/clumpspread_ring")
local Deploy, UnDeploy = surface.GetTextureID("VGUI/bipod_deploy"), surface.GetTextureID("VGUI/bipod_undeploy")
local Gradient_Dual = surface.GetTextureID("VGUI/fas2/gradient_dual")
local HitMarker = surface.GetTextureID("hud/hit")
local td = {}
local FrameTime, CurTime, ScrW, ScrH, Lerp = FrameTime, CurTime, ScrW, ScrH, Lerp

local Green = Color(202, 255, 163, 255)
local White, Black = Color(255, 255, 255, 255), Color(0, 0, 0, 255)

function SWEP:DrawHUD()
	if GetConVarNumber("fas2_nohud") > 0 then
		return
	end
	
	FT, CT, x, y = FrameTime(), CurTime(), ScrW(), ScrH()
	lp = self.Owner:ShouldDrawLocalPlayer()
	
	if (self.dt.Status == FAS_STAT_ADS or self.dt.Status == FAS_STAT_SPRINT or self.dt.Status == FAS_STAT_CUSTOMIZE or self.dt.Status == FAS_STAT_QUICKGRENADE or self.MagCheck or self.NearWall or self.Vehicle) and not lp or self.FireMode == "safe" then
		self.CrossAlpha = Lerp(FT * 10, self.CrossAlpha, 0)
	else
		self.CrossAlpha = Lerp(FT * 10, self.CrossAlpha, 255)
	end
	
	if lp then
		td.start = self.Owner:GetShootPos()
		td.endpos = td.start + (self.Owner:EyeAngles() + self.Owner:GetPunchAngle()):Forward() * 16384
		td.filter = self.Owner
		
		tr = util.TraceLine(td)
		
		x2 = tr.HitPos:ToScreen()
		x2, y2 = x2.x, x2.y
	else
		x2, y2 = math.Round(x * 0.5), math.Round(y * 0.5)
	end
	
	if self.dt.Status == FAS_STAT_QUICKGRENADE then
		surface.SetDrawColor(0, 0, 0, 255 - self.CrossAlpha)
		surface.SetTexture(ClumpSpread)
		surface.DrawTexturedRect(x2 - 20, y2 - 20, 40, 40)
		
		surface.SetDrawColor(255, 255, 255, 255 - self.CrossAlpha)
		surface.DrawTexturedRect(x2 - 19, y2 - 19, 38, 38)
		
		White.a, Black.a = 255 - self.CrossAlpha, 255 - self.CrossAlpha
		draw.ShadowText(self.Owner:GetAmmoCount("M67 Grenades") .. "x M67", "FAS2_HUD24", x / 2, y / 2 + 200, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	if self.ClumpSpread then
		size = math.ceil(self.ClumpSpread * 2500)
		surface.SetDrawColor(0, 0, 0, self.CrossAlpha)
		surface.SetTexture(ClumpSpread)
		surface.DrawTexturedRect(x2 - size * 0.5 - 1, y2 - size * 0.5 - 1, size + 2, size + 2)
				
		surface.SetDrawColor(255, 255, 255, self.CrossAlpha)
		surface.DrawTexturedRect(x2 - size * 0.5, y2 - size * 0.5, size, size)
	end
	
	self.CrossAmount = Lerp(FT * 10, self.CrossAmount, self.CurCone * 350)
	surface.SetDrawColor(0, 0, 0, self.CrossAlpha * 0.75) -- BLACK crosshair parts
	surface.DrawRect(x2 - 13 - self.CrossAmount, y2 - 1, 12, 3) -- left cross
	surface.DrawRect(x2 + 3 + self.CrossAmount, y2 - 1, 12, 3) -- right cross
		
	surface.DrawRect(x2 - 1, y2 - 13 - self.CrossAmount, 3, 12) -- upper cross
	surface.DrawRect(x2 - 1, y2 + 3 + self.CrossAmount, 3, 12) -- lower cross
		
	surface.SetDrawColor(255, 255, 255, self.CrossAlpha) -- WHITE crosshair parts
	surface.DrawRect(x2 - 12 - self.CrossAmount, y2, 10, 1) -- left cross
	surface.DrawRect(x2 + 4 + self.CrossAmount, y2, 10, 1) -- right cross
		
	surface.DrawRect(x2, y2 - 12 - self.CrossAmount, 1, 10) -- upper cross
	surface.DrawRect(x2, y2 + 4 + self.CrossAmount, 1, 10) -- lower cross
	
	if CT < self.ProficientTextTime then
		self.ProficientAlpha = Lerp(FT * 10, self.ProficientAlpha, 255)
	else
		self.ProficientAlpha = Lerp(FT * 10, self.ProficientAlpha, 0)
	end
	
	White.a, Black.a, Green.a = self.ProficientAlpha, self.ProficientAlpha, self.ProficientAlpha
	
	if self.ProficientAlpha > 2 then
		draw.ShadowText("You've become proficient with this weapon.", "FAS2_HUD36", x / 2, y / 2 - 200, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.ShadowText("Reload speed increased.", "FAS2_HUD24", x / 2, y / 2 - 170, Green, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.ShadowText("Weapon bolting speed increased.", "FAS2_HUD24", x / 2, y / 2 - 145, Green, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	White.a, Black.a = 255, 255
	
	if self.dt.Status != FAS_STAT_CUSTOMIZE then
		if self.InstalledBipod then
			if not self.dt.Bipod then 
				if self:CanDeployBipod() then
					draw.ShadowText("[USE KEY]", "FAS2_HUD24", x / 2, y / 2 + 100, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					
					surface.SetTexture(Deploy)
					
					surface.SetDrawColor(0, 0, 0, 255)
					surface.DrawTexturedRect(x / 2 - 47, y / 2 + 126, 96, 96)
					
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(x / 2 - 48, y / 2 + 125, 96, 96)
				end
			else
				draw.ShadowText("[USE KEY]", "FAS2_HUD24", x / 2, y / 2 + 100, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					
				surface.SetTexture(UnDeploy)
					
				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawTexturedRect(x / 2 - 47, y / 2 + 126, 96, 96)
					
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(x / 2 - 48, y / 2 + 125, 96, 96)
			end
		end
	else
		if self.Attachments then
			surface.SetTexture(Gradient_Dual)
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawTexturedRect(x / 2 - 128, y - 180, 256, 54)
			
			draw.ShadowText("[USE KEY]", "FAS2_HUD24", x / 2, y - 165, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				
			if self.ShowStats then
				draw.ShadowText("Customize weapon", "FAS2_HUD24", x / 2, y - 143, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.ShadowText("Show weapon stats", "FAS2_HUD24", x / 2, y - 143, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
	
	surface.SetTexture(HitMarker)
	
	surface.SetDrawColor(0, 0, 0, self.HitMarkerAlpha)
	surface.DrawTexturedRect(x2 - 33, y2 - 33, 66, 66)
	
	surface.SetDrawColor(255, 255, 255, self.HitMarkerAlpha)
	surface.DrawTexturedRect(x2 - 32, y2 - 32, 64, 64)
	
	if CT > self.HitMarkerTime then
		self.HitMarkerAlpha = math.Approach(self.HitMarkerAlpha, 0, FT * 1400)
	end
end