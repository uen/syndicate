AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Blueprint Infuser"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 1, "infused" )
	self:NetworkVar("Entity", 0, "owning_ent")
end


if(SERVER) then
	function ENT:Initialize()
		self:SetModel('models/props/cs_office/computer_caseb_p3a.mdl')
		self:SetUseType(SIMPLE_USE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)

		self:Setinfused(false)
		self:SetTrigger(true)

		
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:Wake()

		self.isInfused = false
		self.isInfuserCard = true

	end
end

if(CLIENT) then
	function ENT:DrawDisplay()
		local pos = self:GetPos()
		pos.z = pos.z + 10
		pos = pos:ToScreen()
	

		draw.DrawText('Blueprint Infuser Card\n'..(self:Getinfused() and 'Infused' or ''), "manolisItemNopeC", pos.x-2, pos.y-2, Color(0, 0, 0, 200), 1)
		draw.DrawText('Blueprint Infuser Card\n'..(self:Getinfused() and 'Infused' or ''), "manolisItemNopeC", pos.x , pos.y, manolis.popcorn.config.promColor, 1)
	end

	function ENT:Draw()
		self:DrawModel()
	end
end