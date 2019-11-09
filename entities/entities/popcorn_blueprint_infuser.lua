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
	self:NetworkVar("Bool", 1, "IsInfusing")
	self:NetworkVar("Int", 0, "InfuseAmount" )
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Int", 2, "HasPower")
end

function ENT:Initialize()
	if(SERVER) then
		self:SetModel('models/maxofs2d/hover_plate.mdl')
		self:SetUseType(SIMPLE_USE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)


		self.OldTick = SysTime()
		self.fuelLeft = 0

		self:SetTrigger(true)

		self.sound = CreateSound(self, Sound("ambient/machines/electric_machine.wav"))
		self.sound:SetSoundLevel(52)

		self.isPowered = true


		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:Wake()

		self:CPPISetOwner(self:Getowning_ent())
		self:SetIsInfusing(false)
		self:SetInfuseAmount(0)


		self:SetModelScale(2)
		self:Activate()

		self.LastScan = 0
		
	end
end


function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg)

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
	effectdata:SetScale(.1)
	util.Effect("Explosion", effectdata)
end


function ENT:StartTouch(ent)
	if(SERVER) then
		if (IsValid(ent) and (self:GetHasPower()>0) and (!self:GetIsInfusing()) and (ent:GetClass()=='popcorn_blueprint_infuser_card')) then
			if((!ent.isInfused) and (ent.isInfuserCard) and ent.DarkRPItem) then
				self:SetIsInfusing(true)
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
		
		if(self.LastScan+1.5 < CurTime()) then 
			self.LastScan = CurTime()

			if(!(self:GetHasPower()>0)) then return end
			
			if(self:GetIsInfusing()) then
				self:SetInfuseAmount(self:GetInfuseAmount()+1)
				if(self:GetInfuseAmount()>=100) then
					self:SetIsInfusing(false)
			
					local i = ents.Create('popcorn_blueprint_infuser_card')
					i:SetModel('models/props/cs_office/computer_caseb_p3a.mdl')
					i:SetPos(self:GetPos()+Vector(0,0,5))
					i:Setinfused(true)
					
					i:Spawn()
					i.isInfused = true
					i:Setinfused(true)

					self:SetInfuseAmount(0)
					
				end				
			end
					
		end
	end
end


function ENT:OnPowered()
	if(!manolis.popcorn.config.printerSound) then
		self.sound:PlayEx(1, 100)
	end
end

function ENT:OnPowerDisconnected()
	if(!manolis.popcorn.config.printerSound) then
		self.sound:Stop()
	end
end


local material = Material("cable/physbeam")
if(CLIENT) then
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

		draw.DrawText('Blueprint Infuser'..'\n'..(self:GetIsInfusing() and (self:GetInfuseAmount() .. '% infused') or ''), "manolisItemNopeC", pos.x+2, pos.y+2, Color(0, 0, 0, 230), 1)
		draw.DrawText('Blueprint Infuser'..'\n'..(self:GetIsInfusing() and (self:GetInfuseAmount() .. '% infused') or ''), "manolisItemNopeC", pos.x , pos.y, manolis.popcorn.config.promColor, 1)
	end



	function ENT:Draw()
		self:DrawModel()

		local socket = Entity(self:GetHasPower())
		if(IsValid(socket)) then
			render.SetMaterial(material)
			render.DrawBeam(self:GetPos(), socket:GetPos(), 3,0,0,Color(50,50,255))
		end
	end
end