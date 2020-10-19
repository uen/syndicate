AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.StoredMaterials = 0

function ENT:Initialize()
	self:SetModel(self.DarkRPItem.model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetUseType(SIMPLE_USE)

	local ply = self:Getowning_ent()
	ply.ForgeAmount = ply.ForgeAmount + 1

	self.origBuyer = ply:SteamID64()

	self:SetMaxMaterials(self.DarkRPItem.pTable.maxMaterials)
	self:SetMaterial("models/rendertarget")
	self.isPowered = true
	
	self:SetNameX(self.DarkRPItem.name)
	self.damage = 8
end

function ENT:CreateMaterial()
	if(self.StoredMaterials < self.DarkRPItem.pTable.maxMaterials) then
		if(self:GetHasPower()>0) then
			self.StoredMaterials = self.StoredMaterials + 1
			self:SetMaterialsStored(self.StoredMaterials)
			
			local time = manolis.popcorn.config.forgeTime()
			self:SetTime(time)
			if(timer.Exists('popcorn_forge_'..self:GetCreationID())) then
				timer.Adjust('popcorn_forge_'..self:GetCreationID(),time,1,function() if(self and IsValid(self) and self.CreateMaterial) then self:CreateMaterial() end end)
			else
				timer.Create('popcorn_forge_'..self:GetCreationID(),time,1,function() if(self and IsValid(self) and self.CreateMaterial) then self:CreateMaterial() end end)
			end
		end
	end
end

function ENT:OnTakeDamage(dmg)
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
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
end

function ENT:OnPowered()
		local time = manolis.popcorn.config.forgeTime()
		self:SetTime(time)
		timer.Simple(time, function() if(self and IsValid(self) and self.CreateMaterial) then self:CreateMaterial() end end)
end

ENT.BeingTaken = false
function ENT:Use(activator,caller)
	if(self.BeingTaken) then return false end
	if(IsValid(activator)) then
		if(activator:IsPlayer()) then
			if(self.StoredMaterials>0) then
				self.BeingTaken = true
				local matsToAdd = 0
				manolis.popcorn.inventory.getFreeSlots(activator, function(slots)
					if(slots>=self.StoredMaterials) then
						matsToAdd = self.StoredMaterials
					else
						matsToAdd = slots
					end
					
					if(matsToAdd > 0) then
						local sway = 0
						if(activator.syndicateCreditShop.hasCollector) then
							local credit = manolis.popcorn.creditShop.findItem('collector')
							if(credit) then
								sway = credit.affectLevels[activator.syndicateCreditShop.hasCollector]
							end
						end
						for i=1, matsToAdd do
							local material = manolis.popcorn.crafting.RandomMaterial(sway)
							manolis.popcorn.inventory.addItem(activator, material, function(data)
								
							end)
						end

						timer.Simple(1, function()
							if(IsValid(activator)) then
								activator:RefreshInventory()
							end
						end)

						DarkRP.notify(activator,0,4,DarkRP.getPhrase('picked_up_forge_mats', matsToAdd))
						self.StoredMaterials = self.StoredMaterials - matsToAdd
						self:SetMaterialsStored(self.StoredMaterials)

						self.BeingTaken = false

						if(self.StoredMaterials < self.DarkRPItem.pTable.maxMaterials) then
							local time = manolis.popcorn.config.forgeTime()
							self:SetTime(time)
							if(timer.Exists('popcorn_forge_'..self:GetCreationID())) then
								timer.Adjust('popcorn_forge_'..self:GetCreationID(),time,1,function() if(self and IsValid(self) and self.CreateMaterial) then self:CreateMaterial() end end)
							else
								timer.Create('popcorn_forge_'..self:GetCreationID(),time,1,function() if(self and IsValid(self) and self.CreateMaterial) then self:CreateMaterial() end end)
							end
						end
					else
						self.BeingTaken = false
					end
				end)

			end
		end
	end
end

function ENT:OnRemove()
	local owner = self:Getowning_ent()
	if(IsValid(owner)) then
		owner.ForgeAmount = owner.ForgeAmount - 1
	end
end