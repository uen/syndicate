AddCSLuaFile()

ENT.Base = "npc_quest"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true

DEFINE_BASECLASS('npc_quest')
 
ENT.PrintName		= "Michael"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
	BaseClass.Initialize(self)
	if(SERVER) then
		self:SetModel('models/manolis/player.mdl')
		self:SetBodygroup(5,1)
		self:SetBodygroup(4,1)
	end

	self.manolisNPC = 'michael'
	self:SetNPCName('Michael Sterling')
end