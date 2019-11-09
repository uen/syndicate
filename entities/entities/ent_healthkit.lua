AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Health Kit"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

if(SERVER) then
	function ENT:Initialize()
		self:SetModel(self.DarkRPItem.model)
	
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:Wake()

		self:SetUseType(SIMPLE_USE)

		self.healthAmount = self.DarkRPItem.amountOfHealth or 0


		self:SetCustomCollisionCheck(true)

	end

	function ENT:Use(ply)
		ply:SetHealth(math.min(ply:Health () + self.healthAmount,ply:getDarkRPVar('maxhealth')))
		self:Remove()
		ply:EmitSound('items/smallmedkit1.wav', 100, 100)
	end
end

if(CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:Initialize()
    	self:SetCustomCollisionCheck(true)
	end
end