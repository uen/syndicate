AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Cash Stack"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "value")
	self:NetworkVar("Int", 0, "maxValue")
	self:NetworkVar("Int", 1, "gang")
	self:NetworkVar("String", 0, "cashType")
	self:NetworkVar("Entity", 0, "cashOwner")
end

function ENT:AddCash(amount)
	self:Setvalue(self:Getvalue()+amount)
end

if(SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props/cs_assault/MoneyPallet03D.mdl")
		self.Init = CurTime()

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:Wake()
	end

	function ENT:OnTake()
	end

	function ENT:Use(ply)
		local cash = self:Getvalue()
		local gang = self:Getgang()

		if(ply:getDarkRPVar('gang')==self:Getgang()) then
			if(self:Getvalue()>=self:getmaxValue()) then
				// Add cash
			else
				DarkRP.notify(ply,1,4,'This stash can only be collected when it has '..DarkRP.formatMoney(self:getValue()))
			end
		end


	end
end

if(CLIENT) then


	function ENT:Draw()
		self:DrawModel()


	end

	function ENT:DrawDisplay()
		local pos = self:GetPos()
		pos.z = pos.z + 40
		pos = pos:ToScreen()

		local str = "Stash"
		draw.DrawText(str,"manolisItemNopeC", pos.x+2,pos.y+2,Color(0,0,0,200), TEXT_ALIGN_CENTER)
		draw.DrawText(str,"manolisItemNopeC",pos.x,pos.y,manolis.popcorn.config.promColor, TEXT_ALIGN_CENTER)

		local str = "Value: "..DarkRP.formatMoney(self:Getvalue())
		local sec = self:GetcashOwner()!=LocalPlayer() and '\nPress '..string.upper(input.LookupBinding("+use"))..' to take cash!' or ''
		pos.y = pos.y + 25
		draw.DrawText(str..sec, "manolisItemNopeC",pos.x+2,pos.y+2,Color(0,0,0,200), TEXT_ALIGN_CENTER)
		draw.DrawText(str..sec, "manolisItemNopeC",pos.x,pos.y,manolis.popcorn.config.promColor,TEXT_ALIGN_CENTER)

	end
end 