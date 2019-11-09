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
	self:NetworkVar("Entity", 1, "cashOwner")
end

if(SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props/cs_assault/MoneyPallet03D.mdl")
		self.Init = CurTime()

		self:SetSolid(SOLID_BBOX)

		self.taken = false
	end

	function ENT:OnTake()
	end

	function ENT:Use(ply)
		if(self.GetcashOwner) then
			if(IsValid(self:GetcashOwner()) and self:GetcashOwner()==ply and !self.taken) then return end
			ply:addMoney(self:Getvalue() or 100)
			self.taken = true
			DarkRP.notify(ply,0,4,'You stole the stash')
			if(self.OnTake) then self:OnTake() end
			self:Remove()
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