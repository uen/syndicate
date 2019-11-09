AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Uranium Rod"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
local material = Material("cable/physbeam")
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "progress")
end

if(SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_phx/gears/bevel12.mdl")
		self:SetMaterial('models/shadertest/shader4')
		self.Init = CurTime()

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:Wake()
		phys:SetMass(5)

		self:SetTrigger(true)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
	end

	ENT.LastUpdate = 0
	function ENT:Think()
		if(self:Getprogress()<100) then
			if(self.Enriching and IsValid(self.Enriching)) then
				if((CurTime()-(manolis.popcorn.config.bombEnrichTime()))>=self.LastUpdate) then
					self:Setprogress(self:Getprogress()+1)
					self.LastUpdate = CurTime()
				end
			end
		end
	end

function ENT:effsion()

	local effsion = effsion()
	effsion:SetOrigin( self.Entity:GetPos() )
	util.Effect( "HelicopterMegaBomb", effsion )	 -- Big flame
	
	local eff = ents.Create( "env_effsion" )
	eff:SetOwner(self:Getowning_ent() )
	eff:SetPos( self:GetPos() )
	eff:SetKeyValue( "iMagnitude", "2500" )
	eff:Spawn()
	eff:Activate()
	eff:Fire( "effde", "", 0 )
end


end

if(CLIENT) then
	function ENT:Initialize()
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
	end

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:DrawDisplay()
		local pos = self:GetPos()
		pos.z = pos.z + 10
		pos = pos:ToScreen()

		local str = DarkRP.getPhrase('terror_core')..'\n'
		str = str .. DarkRP.getPhrase('terror_enriched',self:Getprogress())

		draw.DrawText(str,"manolisItemNopeF", pos.x+2,pos.y+2,Color(0,0,0,200), 1)
		draw.DrawText(str,"manolisItemNopeF",pos.x,pos.y,manolis.popcorn.config.promColor, 1)
	end
end 