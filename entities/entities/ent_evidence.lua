AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Evidence"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

if(SERVER) then
	function ENT:Initialize()
		self:SetModel('models/props_lab/jar01b.mdl')
		self:SetSolid(SOLID_BBOX)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		timer.Simple(manolis.popcorn.config.cpEvidenceDeletionTime(), function()
			if(IsValid(self)) then
				self:Remove()
			end
		end)
	end
end

function ENT:Use(ply)
	if(!ply.Ghost) then
		if(!self.killed or !self.murderer) then self:Remove() return end
		if(!IsValid(self.killed) or !IsValid(self.murderer)) then self:Remove() return end
		if(ply:isCP()) then
			self.murderer:wanted(ply, 'The murder of '..self.killed:Name())
			self:Remove()
		else
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('police_inspect'))
		end
	end
end

if(CLIENT) then
	local mats = Material( "manolis/popcorn/evidence.png" )
	function ENT:Draw()
		self:DrawModel()
		if(LocalPlayer():isCP()) then
			local pos = self:GetPos() + Vector(0,0,20)
			local ang = (LocalPlayer():GetPos() - self:GetPos()):Angle() + Angle(0,0,0)  
			ang:RotateAroundAxis(ang:Forward(),90)
			ang:RotateAroundAxis(ang:Right(),270)

			cam.Start3D2D(pos, ang, 1)
				surface.SetMaterial(mats)

				surface.SetDrawColor(manolis.popcorn.config.promColor) 
				surface.DrawTexturedRect(-15/2,0,15,15)		
			
			cam.End3D2D()
		end

	end
end