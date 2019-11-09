AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true
 
ENT.PrintName		= "Quest NPC"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "hasQuests")
	self:NetworkVar("String", 0, "NPCName")
end

function ENT:Initialize()
	if(SERVER) then
		self:SetModel( "models/gman_high.mdl" )

		self:SetHullType( HULL_HUMAN ) 
		self:SetHullSizeNormal( )
		self:SetNPCState( NPC_STATE_SCRIPT )
		self:SetSolid(  SOLID_BBOX ) 
		self:CapabilitiesAdd( CAP_ANIMATEDFACE )
		self:CapabilitiesAdd( CAP_TURN_HEAD) 
		self:SetUseType( SIMPLE_USE ) 
		self:DropToFloor()
		self.manolisQuests = {}	
	end
	
	self.isManolisNPC = true
	self.manolisNPC = 'unknown'
end

function ENT:HasQuest(quest)
	for k,v in pairs(self.manolisQuests) do
		if(v.uiq == quest.uiq) then return v end
	end

	return false
end

function ENT:StartQuest(ply,quest)
	ply.quest = quest
	quest:Start(ply)

	for k,v in pairs(self.manolisQuests) do
		if(quest.uiq == v.uiq) then
			table.remove(self.manolisQuests,k)
		end
	end
end

function ENT:GetQuests()
	return self.manolisQuests
end


function ENT:AcceptInput(type,activator,ply)
	if(type=='Use') then
		if(!((ply:GetPos():Distance(self:GetPos()))<250)) then return end

		if(ply.quest) then
					if(ply.quest.target and ply.quest.target==self.manolisNPC) then
						if(manolis.popcorn.quests.HasDialogue(ply)) then
							manolis.popcorn.quests.NextDialogue(ply)
						else
							ply.quest:Next(ply)
						end
					else
						if(ply.quest.target) then
							DarkRP.notify(ply,1,4,'Go and to speak to '..manolis.popcorn.quests.GetNPCName(ply.quest.target))
						end
					end
		else
			local quests = manolis.popcorn.quests.prepareNPCQuests(self.manolisNPC)
			local deals = manolis.popcorn.quests.deals.getDeals(self.manolisNPC)
			net.Start('ManolisPopcornQuestOpen')
				net.WriteString(self.manolisNPC)
				net.WriteTable(quests or {})
				net.WriteTable(deals or {})
			net.Send(activator)
		end	
	end
end

if(CLIENT) then
	local mats = Material( "manolis/popcorn/npcs/quest.png", 'smooth mips')

		
	function ENT:Draw()
		self:DrawModel()

		if(self:GethasQuests()>0) then

			local pos = self:GetPos() + Vector(0,0,89)
			local ang = (LocalPlayer():GetPos() - self:GetPos()):Angle() + Angle(0,0,0)  
			ang:RotateAroundAxis(ang:Forward(),90)
			ang:RotateAroundAxis(ang:Right(),270)

			cam.Start3D2D(pos, ang, 1)
				surface.SetMaterial(mats)

				surface.SetDrawColor(manolis.popcorn.config.promColor) 
				surface.DrawTexturedRect(-15/2,0,15,15)		
			
			cam.End3D2D()
		end
	end

	function ENT:DrawDisplay()

	end
end