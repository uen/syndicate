AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Uranium Enricher"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int", 3, "HasPower")
	self:NetworkVar("Int", 0, "IsEnriching")
end

if(SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_mine01.mdl")
		self.Init = CurTime()
		self.isPowered = true
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:Wake() 
	end

	function ENT:OnPowerDisconnect()
		if(self.Enriching and IsValid(self.Enriching)) then
			self.Enriching:Remove()
			self.Enriching = nil
			if(self.Rod) then self.Rod.Enriching = nil end
		end
	end

	ENT.lastCheck = 0
	function ENT:Think()
		if(self:GetHasPower()>0 and !self.Enriching) then
			if(CurTime()-1>self.lastCheck) then
				self.lastCheck = CurTime()
				for k,v in pairs(ents.FindInSphere(self:GetPos(),75)) do
					if(IsValid(v) and v:GetClass()=="popcorn_rod" and (!v.Enriching)) then
						v:SetOwner(self)
						v:SetPos(self:GetPos()+self:GetUp()*20)
						
						local p1 = self:GetPhysicsObject()
						local p2 = v:GetPhysicsObject()	

						p2:SetAngles(Angle(0,0,0))

						// garrysmod/lua/includes/modules/constraint.lua
						local const = ents.Create("phys_constraint")	
						const:SetKeyValue("forcelimit", 0)
						const:SetPhysConstraintObjects(p1,p2)
						const:Spawn()
						const:Activate()	

						v.Enriching = const
						v.Enricher = self
						self.Enriching = const
						self.Rod = v

						self:SetIsEnriching(1)
					end
				end
			end
		end

		if(self.Enriching) then
			if(!IsValid(self.Enriching)) then
				self.Enriching = false
				self:SetIsEnriching(0)
			end
		end
	end

	function ENT:OnTakeDamage(dmg)
		self.damage = (self.damage or 100) - dmg:GetDamage()
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
end

if(CLIENT) then
	local material = Material("trails/laser")
	local coolerMat = Material('cable/blue_elec')

	function ENT:Initialize()
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
	end

	function ENT:Draw()
		self:DrawModel()
		local socket = Entity(self:GetHasPower())
		if(IsValid(socket)) then
			render.SetMaterial(material)
			render.DrawBeam(self:GetPos(), socket:GetPos(), 3,0,0,Color(50,50,255))
		end
	end

	function ENT:DrawDisplay()
		local pos = self:GetPos()
		pos.z = pos.z + 10
		pos = pos:ToScreen()

		if(self:GetHasPower()==0) then
			draw.DrawText(DarkRP.getPhrase('no_power'), 'manolisItemNopeD', pos.x+2, pos.y-25+2, Color(0,0,0,200), TEXT_ALIGN_CENTER)
			draw.DrawText(DarkRP.getPhrase('no_power'), 'manolisItemNopeD', pos.x, pos.y-25, Color(255,0,0,255), TEXT_ALIGN_CENTER)
		else
			draw.DrawText(DarkRP.getPhrase('powered'), 'manolisItemNopeD', pos.x+2, pos.y-25+2, Color(0,0,0,200), TEXT_ALIGN_CENTER)
			draw.DrawText(DarkRP.getPhrase('powered'), 'manolisItemNopeD', pos.x, pos.y-25, Color(0,255,0,255), TEXT_ALIGN_CENTER)
		end

		draw.DrawText(DarkRP.getPhrase('terror_enricher'),"manolisItemNopeF", pos.x+2,pos.y+2,Color(0,0,0,200), 1)
		draw.DrawText(DarkRP.getPhrase('terror_enricher'),"manolisItemNopeF",pos.x,pos.y,manolis.popcorn.config.promColor, 1)
	end
end