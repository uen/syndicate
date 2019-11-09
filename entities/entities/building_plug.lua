AddCSLuaFile()


ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Power Socket"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.HasBeenSetup = false

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"BuildingID")
	self:NetworkVar("Int",1,"Appliances")
end

function ENT:Initialize()
	if(SERVER) then
		self:SetModel( "models/props_lab/powerbox02b.mdl" )
		self:SetUseType(SIMPLE_USE)

		self:SetSolid(SOLID_BBOX)
	end
	self.LastScan = 0
	self.connected = {}

end

if(SERVER) then
	function ENT:Use(ply)
		
	end
 
	function ENT:Think()
		if(self.LastScan+1 < CurTime()) then 
			self.LastScan = CurTime()
			for k,v in pairs(self.connected) do
				if(!v or !IsValid(v)) then
					self.connected[k] = nil
					continue
				end

				if(v:GetPos():Distance(self:GetPos())>manolis.popcorn.config.maxPlugDistance) then
					v:SetHasPower(0)
					if(v.OnPowerDisconnect) then
						v:OnPowerDisconnect()
					end

					self.connected[k] = nil
				end
			end

			local connections = 0
			for a,b in pairs(self.connected) do
				connections = connections + 1
			end

			self:SetAppliances(connections)
		end	
	end
end

if(CLIENT) then

	function ENT:DrawDisplay()
		local pos = self:GetPos()
		pos.z = pos.z + 10
		pos = pos:ToScreen()
		local connectedAppliances = self:GetAppliances() or 0
		draw.DrawText('Power socket\n'..connectedAppliances..' connected appliance'..((connectedAppliances==1) and '' or 's'), "manolisItemNopeC", pos.x-2, pos.y-2, Color(0, 0, 0, 200), 1)
		draw.DrawText('Power socket\n'..connectedAppliances..' connected appliance'..((connectedAppliances==1) and '' or 's'), "manolisItemNopeC", pos.x , pos.y, manolis.popcorn.config.promColor, 1)
	end

	function ENT:Draw()
		self:DrawModel()
		for k,v in pairs(self.connected) do
			render.DrawBeam(self:GetPos(), v:GetPos(), 2,0,0,Color(255,255,255,255))
		end
	end
end