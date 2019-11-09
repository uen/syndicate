ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Material Printer"
ENT.Author = "Manolis Vrondakis"
ENT.Contact	= "http://manolisvrondakis.com/"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "MaterialsStored")
	self:NetworkVar("Int", 1, "Time")
	self:NetworkVar("Int", 2, "MaxMaterials")
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Int", 3, "HasPower")
	self:NetworkVar("String", 0, "NameX")
end 