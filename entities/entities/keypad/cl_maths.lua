-- Avoiding the clutter

function ENT:CalculateCursorPos()
	local ply = LocalPlayer()

	if not IsValid(ply) then
		return 0, 0
	end

	local tr = util.TraceLine({
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:GetAimVector() * 65,
		filter = ply
	})

	if tr.Entity ~= self then
		return 0, 0
	end

	local scale = self.Scale

	local pos, ang = self:CalculateRenderPos(), self:CalculateRenderAng()
	local normal = self:GetForward()
	
	local intersection = util.IntersectRayWithPlane(ply:EyePos(), ply:GetAimVector(), pos, normal)
	
	if not intersection then
		return 0, 0
	end

	local diff = pos - intersection

	local x = diff:Dot(-ang:Forward()) / scale
	local y = diff:Dot(-ang:Right()) / scale

	return x, y
end

function ENT:CalculateRenderPos()
	local pos = self:GetPos()
		pos:Add(self:GetForward() * self.Maxs.x) -- Translate to front
		pos:Add(self:GetRight() * self.Maxs.y) -- Translate to left
		pos:Add(self:GetUp() * self.Maxs.z) -- Translate to top

		pos:Add(self:GetForward() * 0.15) -- Pop out of front to stop culling

	return pos
end

function ENT:CalculateRenderAng()
	local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Right(), -90)
		ang:RotateAroundAxis(ang:Up(), 90)	

	return ang
end