ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Spawned Weapon"
ENT.Author = "Rickster and Manolis Vrondakis"
ENT.Spawnable = false
ENT.IsSpawnedWeapon = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "amount")
    self:NetworkVar("String", 0, "WeaponClass")
    self:NetworkVar("String", 1, "NameOfItem")
    self:NetworkVar("Int", 1, "MinLevel")
    self:NetworkVar("Int", 2, "XP")
	self:SetCustomCollisionCheck(true)
end
