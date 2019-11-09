AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Generator"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "fuelAmount" )
	self:NetworkVar("Entity", 0, "owning_ent")
end


if(SERVER) then
	function ENT:Initialize()
		self:SetModel('models/props_junk/metalgascan.mdl')
		self:SetUseType(SIMPLE_USE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)

		self:SetfuelAmount(self.DarkRPItem.fuelAmount or 1)

		
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:Wake()

	end
end

if(CLIENT) then
	function ENT:DrawDisplay()
		local pos = self:GetPos()
		pos.z = pos.z + 10
		pos = pos:ToScreen()
		
		draw.DrawText('Generator fuel\n'..(self:GetfuelAmount() or 0)..' litres', "manolisItemNopeC", pos.x-2, pos.y-2, Color(0, 0, 0, 200), 1)
		draw.DrawText('Generator fuel\n'..(self:GetfuelAmount() or 0)..' litres', "manolisItemNopeC", pos.x , pos.y, manolis.popcorn.config.promColor, 1)
	end

	function ENT:Draw()
		self:DrawModel()

	end
end