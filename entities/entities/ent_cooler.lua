AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Printer Booster"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false



function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "CType")
	self:NetworkVar("Float", 1, "Rate")
	self:NetworkVar("Int", 2, "Range")
	self:NetworkVar("Int", 3, "Time")
	self:NetworkVar("String", 0, "SName")
end

if(SERVER) then
	function ENT:Initialize()
		self:SetModel("models/weapons/w_c4_planted.mdl")
		self.Init = CurTime()
		self:SetCType(self.DarkRPItem.pTable.type)

		self:SetRate(self.DarkRPItem.pTable.rate)
		self:SetRange(self.DarkRPItem.pTable.range)
		self:SetTime(self.DarkRPItem.pTable.time)

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:Wake()

		self.sparking = false
		self.damage = 100
		self:SetSName(self.DarkRPItem.name)
	end

	function ENT:Think()
	 	if(CurTime() > self.Init+self:GetTime()) then
	 		self:Destruct()
	 		self:Remove()
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
		self.Cooled = {}
		self.LastScan = 0

		self.color = Color(50,50,255)
		self.matToUse = material

		local type = self:GetCType()
		if(type==2) then
			self.color = Color(0,255,0,255)
		elseif(type==3) then
			self.color = Color(255,0,0,255)
		else
			self.matToUse = coolerMat
		end

	end

	function ENT:Draw()
		self:DrawModel()

		if(self.LastScan+.5 < CurTime()) then
			self.LastScan = CurTime()
			self.Cooled = ents.FindInSphere(self:GetPos(), self:GetRange())
		end

		if(#self.Cooled>0) then
			for k,v in pairs(self.Cooled) do
				if(IsValid(v) and (v:GetClass() == "popcorn_printer" or v:GetClass()=='gang_printer')) then

					render.SetMaterial(self.matToUse)
					render.DrawBeam(self:GetPos(), v:GetPos(), 3,2,2,self.color)
				end
			end
		end
	end

	function ENT:DrawDisplay()
		local pos = self:GetPos()
		pos.z = pos.z + 10
		pos = pos:ToScreen()

		draw.DrawText(self:GetSName(),"manolisItemNopeF", pos.x+2,pos.y+2,Color(0,0,0,200), 1)
		draw.DrawText(self:GetSName(),"manolisItemNopeF",pos.x,pos.y,manolis.popcorn.config.promColor, 1)
	end
end