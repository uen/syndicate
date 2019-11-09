AddCSLuaFile()

ENT.Base = "npc_quest"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true

DEFINE_BASECLASS('npc_quest')
 
ENT.PrintName		= "Bob"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
	BaseClass.Initialize(self)
	if(SERVER) then
		self:SetModel('models/odessa.mdl')
	end

	self.manolisNPC = 'bob'
	self:SetNPCName('Bob')
end