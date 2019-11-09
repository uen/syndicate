ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Money Printer"
ENT.Author = "Manolis Vrondakis"
ENT.Contact = "http://manolisvrondakis.com/"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "price")
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Int", 1, "Money")
	self:NetworkVar("Int", 2, "HasPower")
	self:NetworkVar("String",0,"MType")
	self:NetworkVar("Bool",0,"infused")
end

function ENT:initVars()

end