AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Armor Kit"
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

		self.armorAmount = self.DarkRPItem.amountOfArmor or 0
		self:SetCustomCollisionCheck(true)
	end

	function ENT:Use(ply)
		ply:SetArmor(math.min(ply:Armor () + self.armorAmount,ply:getDarkRPVar('maxarmor')))
		self:Remove()
		ply:EmitSound('items/battery_pickup.wav', 100, 100)
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