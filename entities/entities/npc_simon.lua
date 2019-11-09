AddCSLuaFile()

ENT.Base = "npc_quest"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true

DEFINE_BASECLASS('npc_quest')
 
ENT.PrintName		= "Simon"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
	BaseClass.Initialize(self)
	if(SERVER) then
		self:SetModel('models/Humans/Group01/male_09.mdl')
	end

	self.manolisNPC = 'simon'
	self:SetNPCName('Simon Escobar')
end