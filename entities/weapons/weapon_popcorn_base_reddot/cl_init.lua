include("shared.lua")

-- We need to get these so we can scale everything to the player's current resolution.
local iScreenWidth = surface.ScreenWidth()
local iScreenHeight = surface.ScreenHeight()

local SCOPEFADE_TIME = 0.4
function SWEP:DrawHUD()

	if self.UseScope then

		local bScope = self.Weapon:GetNetworkedBool("Scope")
		if bScope ~= self.bLastScope then -- Are we turning the scope off/on?
	
			self.bLastScope = bScope
			self.fScopeTime = CurTime()
			
		elseif 	bScope then
		
			local fScopeZoom = self.Weapon:GetNetworkedFloat("ScopeZoom")
			if fScopeZoom ~= self.fLastScopeZoom then -- Are we changing the scope zoom level?
		
				self.fLastScopeZoom = fScopeZoom
				self.fScopeTime = CurTime()
			end
		end
			
		local fScopeTime = self.fScopeTime or 0

		if fScopeTime > CurTime() - SCOPEFADE_TIME then
		
			local Mul = 1.0 -- This scales the alpha
			Mul = 1 - math.Clamp((CurTime() - fScopeTime)/SCOPEFADE_TIME, 0, 1)
		
			surface.SetDrawColor(0, 0, 0, 255*Mul) -- Draw a black rect over everything and scale the alpha for a neat fadein effect
			surface.DrawRect(0,0,iScreenWidth,iScreenHeight)
		end

		if bScope then 
	
			-- Put the texture
			surface.SetDrawColor(0,0,0,255)
			surface.SetTexture(surface.GetTextureID("scope/scope_reddot"))
			surface.DrawTexturedRect(self.LensTable.x, self.LensTable.y, self.LensTable.w, self.LensTable.h)

			-- Fill in everything else
			surface.SetDrawColor(0,0,0,255)
			surface.DrawRect(self.QuadTable.x1 - 2.5, self.QuadTable.y1 - 2.5, self.QuadTable.w1 + 5, self.QuadTable.h1 + 5)
			surface.DrawRect(self.QuadTable.x2 - 2.5, self.QuadTable.y2 - 2.5, self.QuadTable.w2 + 5, self.QuadTable.h2 + 5)
			surface.DrawRect(self.QuadTable.x3 - 2.5, self.QuadTable.y3 - 2.5, self.QuadTable.w3 + 5, self.QuadTable.h3 + 5)
			surface.DrawRect(self.QuadTable.x4 - 2.5, self.QuadTable.y4 - 2.5, self.QuadTable.w4 + 5, self.QuadTable.h4 + 5)
		end
	end
	
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
end