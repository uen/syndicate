AddCSLuaFile()


ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true
 
ENT.PrintName		= "Blacksmith PC"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
	if(SERVER) then
		self:SetModel( "models/Barney.mdl" )
	
		self:SetHullType( HULL_HUMAN ) 
		self:SetHullSizeNormal( )
		self:SetNPCState( NPC_STATE_SCRIPT )
		self:SetSolid(  SOLID_BBOX ) 
		self:CapabilitiesAdd( CAP_ANIMATEDFACE  ) 
		self:SetUseType( SIMPLE_USE ) 
		self:DropToFloor()
	end

	manolis.popcorn.crafting.blacksmith = self


end

if(SERVER) then

	function ENT:OnTakeDamange(damage)
		return false 
	end

	function ENT:AcceptInput(type,activator,ply)
		if(type=='Use') then
			if((ply:GetPos():Distance(self:GetPos()))<250) then
				net.Start('ManolisPopcornBlacksmithOpen')
				net.Send(ply)
			end
		end
	end

end