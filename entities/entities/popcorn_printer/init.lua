AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.StoredMoney = 0
ENT.StoredXP = 0

local PrintMore
function ENT:Initialize()
	self:SetModel(self.DarkRPItem.model)
	self:SetColor(self.DarkRPItem.pTable.color)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:Wake()

	self:SetMType(self.DarkRPItem.name)

	self.sparking = false
	self.damage = 8
	self.IsMoneyPrinter = true

	self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
	self.sound:SetSoundLevel(52)
	
	self.steal = {}
	self.steal.uid = ''
	self.steal.count = 0

	self:SetUseType(SIMPLE_USE)

	local steal = {}
	steal.uid = 0
	steal.c = 0

	local ply = self:Getowning_ent()
	ply.PrinterAmount = ply.PrinterAmount + 1
	self.origBuyer = ply:SteamID64()

	self.isPowered = true
	self:SetCustomCollisionCheck(true)

	self:SetTrigger(true)
	
	if(manolis.popcorn.config.autoConnectPrinters) then 
		local selfEntIndex = self:EntIndex()
		timer.Create("printTimerConnectAutomatic"..selfEntIndex, 3, 0, function()
			if(!IsValid(self)) then
				timer.Remove("printTimerConnectAutomatic"..selfEntIndex)
				return
			end
			if(!(self:GetHasPower()>0)) then
				local e = ents.FindInSphere(self:GetPos(),manolis.popcorn.config.maxPlugDistance)
				local plug
				for k,v in pairs(e) do
					if(!plug and v:GetClass()=="building_plug") then
						plug = v
					end
				end

				if(plug) then
					local aDoor
					local building

					for k,v in pairs(manolis.popcorn.buildings.buildings) do
						if(v.id==plug:GetBuildingID()) then
							if(v.doors[1]) then
								aDoor = v.doors[1]
							end

							building = v
						end
					end

					aDoor.ent = DarkRP.doorIndexToEnt(aDoor.id)

					if(!building or !aDoor or !IsValid(aDoor.ent)) then
						return
					end

					if(!aDoor.ent:isKeysOwned()) then
						return
					end

					local upgrades = manolis.popcorn.buildings.buildingUpgrades[building.id]
					local amountOfPower = manolis.popcorn.config.powerBuildingUpgradeAmount[1]

					if(upgrades and upgrades['power']) then
						amountOfPower = manolis.popcorn.config.powerBuildingUpgradeAmount[upgrades['power']+1]
					end

					if((plug:GetAppliances() or 0)>=(amountOfPower or 2)) then
						return
					end

					plug:SetAppliances(plug:GetAppliances()+1)
					self.connectedBuilding = building
					self:SetHasPower(plug:EntIndex())
					plug.connected[self:GetCreationID()] = self

					if(self.OnPowered) then
						self:OnPowered()
					end
				end	
			end
		end)
	end
end

function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg)

	self.damage = (self.damage or 8) - dmg:GetDamage()
	if self.damage <= 0 then
		self:Destruct()
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
	if(IsValid(self:Getowning_ent())) then
		DarkRP.notify(self:Getowning_ent(), 1, 4, DarkRP.getPhrase("money_printer_exploded"))
	end
end


function ENT:Fireball()
	if not self:IsOnFire() then self.burningup = false return end
	local dist = math.random(20, 280) -- Explosion radius
	self:Destruct()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), dist)) do
		if not v:IsPlayer() and not v:IsWeapon() and v:GetClass() ~= "predicted_viewmodel" and not v.IsMoneyPrinter then
			v:Ignite(math.random(5, 22), 0)
		elseif v:IsPlayer() then
			local distance = v:GetPos():Distance(self:GetPos())
			v:TakeDamage(distance / dist * 100, self, self)
		end
	end
	self:Remove()
end

function ENT:BurstIntoFlames()
	DarkRP.notify(self:Getowning_ent(), 0, 4, DarkRP.getPhrase("money_printer_overheating"))
	self.burningup = true
	local burntime = math.random(8, 18)
	self:Ignite(burntime, 0)
	timer.Simple(burntime, function() if(IsValid(self) and self.Fireball) then self:Fireball() end end)
end


PrintMore = function(ent)
	if(IsValid(ent)) then
		if(ent:GetHasPower()>0) then
			if not IsValid(ent) then return end

			ent.sparking = true
			timer.Simple(1, function()
				if not IsValid(ent) then return end
				ent:CreateMoneybag()
			end)
		end
	end
end

function ENT:CreateMoneybag()
	if(self:GetHasPower()>0) then

		if not IsValid(self) or self:IsOnFire() then return end
		local MoneyPos = self:GetPos()

		local boosters = ents.FindInSphere(self:GetPos(), 500)
		local upgrades = {}
		for k,v in pairs(boosters) do
			if(v:GetClass()=='ent_cooler') then
				if((v:GetPos():Distance(self:GetPos()))<v:GetRange()) then
					local typex = v:GetCType()
	
					if(typex==1) then
						upgrades['cooled'] = true
					elseif(typex==2) then
						upgrades['boosted'] = v:GetRate()
					elseif(typex==3) then

						upgrades['amount'] = v:GetRate()
					end
				end
			end
		end

		if(!upgrades['cooled']) then
			if(math.random(1,5)==2) then
				self:BurstIntoFlames()
				return
			end
		end

		if((self.StoredMoney+self.DarkRPItem.pTable.money) <= (self.DarkRPItem.pTable.money*(manolis.popcorn.config.maxPrints or 4))) then

			local amount = self.DarkRPItem.pTable.money
			local xpamount = self.DarkRPItem.pTable.xp

			if(upgrades['amount']) then
				amount = amount * upgrades['amount']
			end

			self.StoredMoney = self.StoredMoney + amount
			self:SetMoney(self.StoredMoney)
			if(self:Getinfused()) then
				local rand = math.random(0,50)
				if(rand==18) then
					if(IsValid(self:Getowning_ent())) then
						local bp = manolis.popcorn.crafting.PlayerRandomBlueprint(self:Getowning_ent())
						if(bp) then
							local item = manolis.popcorn.items.CreateItemData(bp)
							manolis.popcorn.items.SpawnItem(self:Getowning_ent(), item, function() end, self:GetPos()+Vector(0,0,10))
						end
					end
				end
			end
		end

		self.sparking = false
		timer.Simple(manolis.popcorn.config.printerTime,function() PrintMore(self) end)
	end
end

function ENT:OnPowered()
	if(!manolis.popcorn.config.printerSound) then
		self.sound:PlayEx(1, 100)
	end

	timer.Simple(manolis.popcorn.config.printerTime,function() PrintMore(self) end)
end

function ENT:OnPowerDisconnected()
	if(!manolis.popcorn.config.printerSound) then
		self.sound:Stop()
	end
end

function ENT:Use(activator,caller)
	local xpAdded = 0
		
	if(activator and table.HasValue(manolis.popcorn.config.bannedPrinterUse, activator:Team())) then
		DarkRP.notify(activator,1,4,DarkRP.getPhrase('printer_cannot_take'))
		return
	end

	if(IsValid(activator)) then
		if(activator:IsPlayer()) then
			if(!(manolis.popcorn.levels.HasLevel(activator, self.DarkRPItem.pTable.level-manolis.popcorn.config.printerHigherLevelAmount))) then
				DarkRP.notify(activator,1,4,DarkRP.getPhrase('printer_must_be_level',(self.DarkRPItem.pTable.level-manolis.popcorn.config.printerHigherLevelAmount)))
				return
			end

			if(activator:isCP()) then
				DarkRP.notify(activator,1,4,DarkRP.getPhrase('printer_cp'))
				return
			end

			if(self.StoredMoney>0) then
				local owner = self:Getowning_ent()
				if(IsValid(owner) and ((owner.PrinterAmount or 0)>manolis.popcorn.config.maxAvailablePrinters)) then
					self:BurstIntoFlames()
					return
				end		

				self:SetMoney(0)	
				self.StoredXP = 20+math.Clamp(self.StoredMoney / 25, 0,manolis.popcorn.config.maxXPCollect)

				if(activator:getDarkRPVar('gang')) then
					local gangId = activator:getDarkRPVar('gang')
					if(manolis.popcorn.gangs.cache[gangId]) then
						if(manolis.popcorn.gangs.cache[gangId].upgrades['gangPrinterMoney']>0) then self.StoredMoney = self.StoredMoney + self.StoredMoney*((manolis.popcorn.gangs.upgrades.upgrades['gangPrinterMoney'].effect[manolis.popcorn.gangs.cache[gangId].upgrades['gangPrinterMoney']])/100) end
					end
				end

				self.StoredMoney = math.Round(self.StoredMoney)
				
				activator:AddAchievementProgress('millionaire', self.StoredMoney)
				activator:AddAchievementProgress('multimillionaire', self.StoredMoney)



				if(IsValid(owner) and owner:SteamID64()==activator:SteamID64()) then
					local xpAdded = activator:AddXP(self.StoredXP,true)
					DarkRP.notify(activator,0,4,DarkRP.getPhrase('printer_collect', DarkRP.formatMoney(self.StoredMoney), string.Comma(xpAdded)))
					activator:addMoney(self.StoredMoney or 0)
					self.StoredXP = 0
					self.StoredMoney = 0
				else
					if(IsValid(owner) and !(owner:GetPos():Distance(activator:GetPos())>700)) then
						activator:addMoney(self.StoredMoney or 0)
						DarkRP.notify(activator,0,4,DarkRP.getPhrase('printer_friend', DarkRP.formatMoney(self.StoredMoney)))
					else
						local xpAdded = activator:AddXP(math.Clamp(self.StoredXP*manolis.popcorn.config.stolenPrinterMult, 0, manolis.popcorn.config.maxXPCollect), true)
						activator:AddAchievementProgress('stealer',1)
						DarkRP.notify(activator,0,4,DarkRP.getPhrase('printer_steal', DarkRP.formatMoney(self.StoredMoney),string.Comma(xpAdded)))
						activator:addMoney(self.StoredMoney or 0)
					end

					self.StoredXP = 0
					self.StoredMoney = 0

					if(self.steal.uid != activator:SteamID64()) then
						self.steal.uid = activator:SteamID64()
						self.steal.count = 0
					else
						self.steal.count = self.steal.count + 1
					end

					if(self.steal.count > manolis.popcorn.config.stolenPrinterCount) then
						self:Setowning_ent(activator)
						self.origBuyer = activator:SteamID64()
						activator.PrinterAmount = activator.PrinterAmount + 1
						DarkRP.notify(activator,0,4,DarkRP.getPhrase('printer_yours'))
						if(IsValid(owner)) then
							DarkRP.notify(owner,0,4,DarkRP.getPhrase('printer_stolen'))
							owner.PrinterAmount = (owner.PrinterAmount - 1)
							owner:removeCustomEntity(self.DarkRPItem)
						end
					end
				end
			end
		end
	end
end

function ENT:Think()
	if self:WaterLevel() > 0 then
		self:Destruct()
		self:Remove()
		return
	end

	if not self.sparking then return end

	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetMagnitude(1)
	effectdata:SetScale(1)
	effectdata:SetRadius(2)
	util.Effect("Sparks", effectdata)
end

function ENT:StartTouch(ent)
	if(SERVER) then
		if (IsValid(ent) and (!self:Getinfused()) and (ent:GetClass()=='popcorn_blueprint_infuser_card')) then
			if((ent.isInfused) and (ent.isInfuserCard)) then
				self:Setinfused(true)
				ent:Remove()
			end
		end
	end
end

function ENT:OnRemove()
	if self.sound then
		self.sound:Stop()
	end

	local owner = self:Getowning_ent()
	if(IsValid(owner)) then
		owner.PrinterAmount = owner.PrinterAmount - 1
	end
end
