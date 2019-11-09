AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Spawned Item"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpositione			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "NameOfItem" );
end

if(SERVER) then
	function ENT:Initialize()
		self:SetModel(self.mdl) 
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:Wake()
	end

	function ENT:SetItemData(data)
		self.itemInventoryData = data

		local str = data.name
		if(data.quantity>1) then
			str = data.quantity.."x "..str.."s"
		end
		self:SetNameOfItem(str)
	end

	function ENT:GetItemData()
		return self.itemInventoryData
	end
end

if(CLIENT) then
	function ENT:DrawDisplay()
		local position = self:GetPos()
		position.z = position.z+8
		position = position:ToScreen()
		draw.DrawText(self:GetNameOfItem(), "manolisItemNope", position.x+2, position.y+2, Color(0,0,0,200), TEXT_ALIGN_CENTER)
		draw.DrawText(self:GetNameOfItem(), "manolisItemNope", position.x, position.y, Color(255,255,255,255), TEXT_ALIGN_CENTER)
	end
end