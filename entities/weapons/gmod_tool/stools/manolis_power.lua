TOOL.Category = "Popcorn Tools"
TOOL.Name = "Power Tool"
TOOL.isGen = false
function TOOL:LeftClick(trace)
	if(CLIENT) then
		if(trace and trace.HitWorld) then
			return false
		else
			return true
		end
	end


	if(self:GetOperation()==0) then
		if(trace and trace.Entity and IsValid(trace.Entity) and ((trace.Entity:GetClass()=='building_plug') or (trace.Entity:GetClass()=='popcorn_generator'))) then
			if(SERVER) then
				if(trace.Entity:GetClass()=='popcorn_generator') then
					self.isGen = true
				end
				self:SetStage(1)
				self.firstEnt = trace.Entity
				self:SetOperation(1)
			end
		end

	elseif(self:GetOperation()==1) then

		if(!self.firstEnt or !IsValid(self.firstEnt)) then return false end 
		if(trace and trace.Entity and IsValid(trace.Entity) and trace.Entity.isPowered) then
			local building
			local amountOfPower = 0
			if(!self.isGen) then
				local aDoor
				
				for k,v in pairs(manolis.popcorn.buildings.buildings) do
					if(v.id==self.firstEnt:GetBuildingID()) then
						for doorKey,doorValue in pairs(v.doors or {}) do
							local door = DarkRP.doorIndexToEnt(doorValue.id)
							if(!IsValid(door) or !door:isDoor()) then continue end
							aDoor = doorValue
						end
						
						building = v
					end
				end

				aDoor.ent = DarkRP.doorIndexToEnt(aDoor.id)

				if(!building or !aDoor or !IsValid(aDoor.ent)) then
					self:SetOperation(0)
					self:SetStage(0)
					DarkRP.notify(self:GetOwner(),1,4,DarkRP.getPhrase('power_tool_nodoors'))
					return
				end

				if(!aDoor.ent:isKeysOwned()) then
					DarkRP.notify(self:GetOwner(),1,4,DarkRP.getPhrase('power_tool_no_building_owner'))
					self:SetOperation(0)
					self:SetStage(0)
					return
				end

				local upgrades = manolis.popcorn.buildings.buildingUpgrades[building.id]
				amountOfPower = manolis.popcorn.config.powerBuildingUpgradeAmount[1]

				if(upgrades and upgrades['power']) then
					amountOfPower = manolis.popcorn.config.powerBuildingUpgradeAmount[upgrades['power']+1]
				end
			else
				amountOfPower = self.firstEnt.sockets or 2
			end

			if(trace.Entity:GetPos():Distance(self.firstEnt:GetPos())>manolis.popcorn.config.maxPlugDistance) then
				self:SetOperation(0)
				self:SetStage(0)
				DarkRP.notify(self:GetOwner(),1,4,DarkRP.getPhrase('power_tool_toofar'))
				return
			end

			if((self.firstEnt:GetAppliances() or 0)>=(amountOfPower or 2)) then
				self:SetOperation(0)
				self:SetStage(0)
				DarkRP.notify(self:GetOwner(),1,4,DarkRP.getPhrase('power_tool_full'))
				return
			end

			if(trace.Entity:GetHasPower()!=0) then
				self:SetOperation(0)
				self:SetStage(0)
				DarkRP.notify(self:GetOwner(),1,4,DarkRP.getPhrase('power_tool_already'))
				return
			end

			self.firstEnt:SetAppliances(self.firstEnt:GetAppliances()+1)
			DarkRP.notify(self:GetOwner(),0,4,DarkRP.getPhrase('power_tool_success'))

			trace.Entity.connectedBuilding = building
			trace.Entity:SetHasPower(self.firstEnt:EntIndex())
			self.firstEnt.connected[trace.Entity:GetCreationID()] = trace.Entity
			
			if(trace.Entity.OnPowered) then
				trace.Entity:OnPowered()
			end
		else
			if(trace.HitWorld) then
				return
			else
				DarkRP.notify(self:GetOwner(),1,4,DarkRP.getPhrase('power_tool_invalid'))
				self:SetOperation(0)
				self:SetStage(0)
			end
		end

		self:SetOperation(0)
		self:SetStage(0)
		return true
		
	end
end

if(CLIENT) then
	language.Add("Tool.manolis_power.name", "Power Tool")
	language.Add("Tool.manolis_power.desc", "Power various household appliances")

	language.Add("Tool.manolis_power.0", "Click on a power socket")
	language.Add("Tool.manolis_power.1", "Click on an appliance")
end