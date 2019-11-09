AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Cactus"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false


if(SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_lab/cactus.mdl")
	
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:Wake()

		self:SetUseType(SIMPLE_USE)
	end

	function ENT:Use(ply)
		ply:AddXP(1000)
	end
end

if(CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end
	function ENT:DrawDisplay()
		local pos = self:GetPos()

		pos.z = pos.z + 8
		pos = pos:ToScreen()

		draw.DrawText("Cactus", "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 200), 1)
		draw.DrawText("Cactus", "TargetID", pos.x, pos.y, Color(0,255,0,255), 1)
	end
end