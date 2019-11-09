AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Bomb"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "rods")
	self:NetworkVar("Int", 1, "Armed")
end

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.IsBomb		= true

if(SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_wasteland/laundry_washer001a.mdl")
		
		self.Init = CurTime()

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:Wake()
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetColor(Color(0,100,0,150))
		self:SetMaterial("models/XQM/LightLinesRed_tool")


		self:SetTrigger(true)

		self:SetArmed(0)

		self:SetPos(self:GetPos()+Vector(0,0,15))
	end

	function ENT:Defuse(ply)
		self:ResetBomb()

		timer.Remove('ManolisBombTimer')

		DarkRP.notifyAll(0,4,DarkRP.getPhrase('terror_defused_ply', ply:Name()))
		local xp = ply:addXP(5*ply:getDarkRPVar('level')^2)
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('terror_defused_local',xp))
	end

	function ENT:ResetBomb()
		self:SetColor(Color(0,100,0,150))
		self:Setrods(0)	
		self:SetArmed(0)

		if(self.sound) then self.sound:Stop() end
	end

	function ENT:Touch(ent)
		if(IsValid(ent) and ent:GetClass()=='popcorn_rod') then
			if(self:Getrods()+1>manolis.popcorn.config.bombRods) then return end
			if(ent:Getprogress()>=100) then
				ent:Remove()
				self:Setrods(self:Getrods()+1)
				if(self:Getrods()>=manolis.popcorn.config.bombRods) then
					self:SetColor(Color(200,0,0,100))
					DarkRP.notifyAll(0,4,DarkRP.getPhrase('terror_active'))
					manolis.popcorn.terrorism.bombActivated = true

					self.filter = RecipientFilter()
					self.filter:AddAllPlayers()

					self.sound = CreateSound(game.GetWorld(), 'ambient/alarms/siren.wav', self.filter)
					self.sound:SetSoundLevel(0)
					self.sound:ChangeVolume(1,0)
					self.sound:Play()

					self:SetMaterial("models/XQM/LightLinesRed_tool")
					self:SetColor(Color(255,255,255,255))

					self:SetArmed(1)

					timer.Create("ManolisBombTimer", manolis.popcorn.config.bombExplosionTime, 1, function()
						manolis.popcorn.terrorism.bombActivated = false
						self.sound:Stop()

						local nuke = ents.Create("sent_nuke")
						nuke:SetPos( self:GetPos() )
						nuke:SetVar("owner",self)
						nuke:Spawn()
						nuke:Activate()
	
						for _, v in pairs(ents.FindInSphere( self.Entity:GetPos(), 1500 )) do  
					    	v:Fire("enablemotion","",0)
					    	constraint.RemoveAll( v ) 
						end

						local count = 0
						local terrorists = {}
						for k,v in pairs(player.GetAll()) do
							if(v:Team()!=TEAM_TERRORIST) then
								count = count + 1
							else
								table.insert(terrorists,v)
							end
						end

						local totalCash = 20000*count
						for k,v in pairs(terrorists) do
							local xp = v:addXP(5*v:getDarkRPVar('level')^2)
							DarkRP.notify(v,0,4,DarkRP.getPhrase('terror_getreward',DarkRP.formatMoney(totalCash),xp))
							v:addMoney(totalCash)
						end		
				
						self:ResetBomb()
					end)
				end
			end
		end
	end
end

if(CLIENT) then
	function ENT:Initialize()
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetColor(Color(0,70,0,150))
	end

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:DrawDisplay()
		local pos = self:GetPos()
		pos.z = pos.z + 10
		pos = pos:ToScreen()

		local str = DarkRP.getPhrase('terror_bomb')

		if(LocalPlayer():Team()==TEAM_TERRORIST) then
			str = str..'\n'..DarkRP.getPhrase('terror_enriched', math.ceil(((self:Getrods()/manolis.popcorn.config.bombRods)*100)))
		end

		draw.DrawText(str,"manolisItemNopeC", pos.x+2,pos.y+2,Color(0,0,0,200), 1)
		draw.DrawText(str,"manolisItemNopeC",pos.x,pos.y,manolis.popcorn.config.promColor, 1)
	end
end 