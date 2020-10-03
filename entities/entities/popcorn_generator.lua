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
	self:NetworkVar( "String", 0, "FuelLeft" )
	self:NetworkVar( "String", 2, "GName" )
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Int",1,"Appliances")
end

ENT.isGenerator = true

function ENT:Initialize()
	if(SERVER) then
		self:SetModel('models/maxofs2d/hover_propeller.mdl')
		self:SetUseType(SIMPLE_USE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)

		self.OldTick = SysTime()
		self.fuelLeft = 0
		self.maxFuel = self.DarkRPItem and self.DarkRPItem.maxFuel or 100

		self.sockets = (self.DarkRPItem and self.DarkRPItem.sockets or 2) or 2
		self:SetTrigger(true)

		self.sound = CreateSound(self, Sound("ambient/levels/canals/generator_ambience_loop1.wav"))
		self.sound:SetSoundLevel(52)


		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:Wake()

		self:CPPISetOwner(self:Getowning_ent())
		self:SetGName(self.DarkRPItem and self.DarkRPItem.name or 'Generator')

		self:SetFuelLeft(0)
		
		self.LastScan = 0
		self.connected = {}
		self.isGenerator = true
	end

	self.LastScan = 0
	self.connected = {}
end


function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg)

	self.damage = (self.damage or 100) - dmg:GetDamage()
	if self.damage <= 0 then
		self:Destruct()
		if(self.sound) then self.sound:Stop() end
		self:Remove()
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(.1)
	util.Effect("Explosion", effectdata)
	
	for k,v in pairs(self.connected) do
		if(IsValid(v) and v.SetHasPower) then
			v:SetHasPower(0)
			if(v.OnPowerDisconnect) then
				v:OnPowerDisconnect()
			end
		end
	end
end


function ENT:StartTouch(ent)
	if(SERVER) then
		if (IsValid(ent) and ent:GetClass()=='popcorn_fuel') then
			if((self.fuelLeft!=self.maxFuel) and ent.DarkRPItem and ent.DarkRPItem.fuelAmount) then
				self.fuelLeft = math.Clamp(self.fuelLeft + ent.DarkRPItem.fuelAmount, 0, self.maxFuel)
				self:SetFuelLeft(math.Round((self.fuelLeft/self.maxFuel)*100))
				ent:Remove()
			end
		end
	end
end

if(SERVER) then
	function ENT:Think()
		if self:WaterLevel() > 0 then
			self:Destruct()
			self:Remove()
			return
		end

		if(!self.LastScan) then self.LastScan = 0 end
		
		if(self.LastScan+2 < CurTime()) then 
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

			if(self:GetAppliances()>0) then
				if(!self.sound:IsPlaying()) then
					self.sound:PlayEx(1, 100)
				end

				if(self.fuelLeft>0) then
					self.fuelLeft = self.fuelLeft - 1
					self:SetFuelLeft(math.Round((self.fuelLeft/self.maxFuel)*100))
				else
					if(self.sound:IsPlaying()) then
						self.sound:Stop()
					end

					for k,v in pairs(self.connected) do
						if(!v or !IsValid(v)) then
							self.connected[k] = nil
							continue
						end

						v:SetHasPower(0)
						if(v.OnPowerDisconnect) then
							v:OnPowerDisconnect()
						end

						self.connected[k] = nil
					end
				end
			else
				if(self.sound:IsPlaying()) then
					self.sound:Stop()
				end
			end
		end	
	end
end


if(CLIENT) then
	function ENT:DrawDisplay()
		local pos = self:GetPos()
		pos.z = pos.z + 10
		pos = pos:ToScreen()
		local connectedAppliances = self:GetAppliances() or 0
		draw.DrawText(self:GetGName()..'\n'..self:GetFuelLeft()..'% fuel\n'..connectedAppliances..' connected appliance'..((connectedAppliances==1) and '' or 's'), "manolisItemNopeC", pos.x+2, pos.y+2, Color(0, 0, 0, 230), 1)
		draw.DrawText(self:GetGName()..'\n'..self:GetFuelLeft()..'% fuel\n'..connectedAppliances..' connected appliance'..((connectedAppliances==1) and '' or 's'), "manolisItemNopeC", pos.x , pos.y, manolis.popcorn.config.promColor, 1)
	end

	function ENT:Draw()
		self:DrawModel()
		for k,v in pairs(self.connected) do
			render.DrawBeam(self:GetPos(), v:GetPos(), 2,0,0,Color(255,255,255,255))
		end
	end
end
