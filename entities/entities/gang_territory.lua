AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Gang Territory"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "Gang" )
	self:NetworkVar( "Int", 0, "GangID" )
	self:NetworkVar( "Int", 1, "UniqueID" )
	self:NetworkVar( "Int", 2, "Territory" )
	self:NetworkVar( "String", 2, "Name" )
	self:NetworkVar( "Int", 3, "LocationID")
end

function ENT:Initialize()
	if(SERVER) then
		self:SetModel( "models/props_trainstation/trainstation_post001.mdl" )
		self:SetUseType(SIMPLE_USE)

		self:SetSolid(SOLID_BBOX)
	
	
		self.gettingCaptured = false

		self.captureTime = manolis.popcorn.config.capPoleTime

		self.OldTick = SysTime()
	end

end

if(SERVER) then
	function ENT:Use(ply)
		if(ply:getDarkRPVar('PopcornGhost')) then
			DarkRP.notify(ply,1,4,'You can only capture this territory when you are alive')
			return
		end
		local allPlayers = player.GetAll()

		if(#allPlayers < (manolis.popcorn.config.territoryPlayers or 10)) then
			DarkRP.notify(ply,1,4,'You can only capture gang terrotories when there are 10 or more people on the server')
			return
		end

		if(ply:isCP()) then
			DarkRP.notify(ply,1,4,'Police cannot capture territories!')
			return
		end
		if(!self.gettingCaptured) then
			local gang = manolis.popcorn.gangs.GetPlayerGang(ply)
			if(!gang) then return false end

			local ownedByGang = self:GetGangID()
			if(ownedByGang==gang) then return false end

			if(ownedByGang) then
				local gangMembers = {}
				for a,b in pairs(allPlayers) do
					if(manolis.popcorn.gangs.GetPlayerGang(b) == ownedByGang) then
						table.insert(gangMembers, b)
					end
				end

				self.gangMembers = gangMembers
			end

			self.gettingCaptured = ply

			net.Start("ManolisPopcornGangStartCapturing")
				net.WriteBool(true)
			net.Send(self.gettingCaptured)

			if(ownedByGang) then
				for k,v in pairs(self.gangMembers or {}) do
					manolis.popcorn.alerts.NewAlert(v, self:EntIndex().."GangTerritory", "Territory Contested!", self:GetPos(), manolis.popcorn.config.capPoleTime)
				end
			end
		end
	end

	
	function ENT:Think()
		local tickTime = SysTime() - self.OldTick
		self.OldTick = SysTime()
		if(self.gettingCaptured) then
			local timeMult = 1
			if(IsValid(self.gettingCaptured) and self.gettingCaptured:GetPos():Distance(self:GetPos())<300) then
				for k,v in pairs(player.GetAll()) do
					if(v!=self.gettingCaptured) then
						if((manolis.popcorn.gangs.GetPlayerGang(v)==manolis.popcorn.gangs.GetPlayerGang(self.gettingCaptured)) and (v:GetPos():Distance(self:GetPos())<300)) then
							timeMult = timeMult + 1
						end
					end
				end

				self.captureTime = self.captureTime - ((tickTime)*timeMult)
			else
				net.Start("ManolisPopcornGangStartCapturing")
					net.WriteBool(false)
				net.Send(self.gettingCaptured)

				self.gettingCaptured = false
				self.captureTime = manolis.popcorn.config.capPoleTime

			end

			if(self.captureTime <= 0) then
				if(self:GetGangID()>0) then
					manolis.popcorn.gangs.Notify(manolis.popcorn.gangs.cache[manolis.popcorn.gangs.GetPlayerGang(self.gettingCaptured)].info.name.. " captured your gang territory")
				end

				self:SetGangID(manolis.popcorn.gangs.GetPlayerGang(self.gettingCaptured))
				self:SetGang(manolis.popcorn.gangs.cache[manolis.popcorn.gangs.GetPlayerGang(self.gettingCaptured)].info.name)



				local tempTerritories = {}
				for x,z in pairs(manolis.popcorn.gangs.territories.territories) do
					for b,l in pairs(z.locations) do
						if(l.id == self:GetLocationID()) then
							l.captured = self:GetGangID()
						end
					end
				end
 
				self.captureTime = manolis.popcorn.config.capPoleTime

				DarkRP.notify(self.gettingCaptured,0,4,'You captured this gang territory')

				local players = self.gangMembers or {}
				table.insert(players, self.gettingCaptured)

				net.Start("ManolisPopcornGangStartCapturing")
					net.WriteBool(false)
				net.Send(players)


				self.gettingCaptured = false
			end
		end
	end
end

if(CLIENT) then

	local ownedRival = Material( "manolis/popcorn/icons/gangs/iconowned.png", 'smooth mips')
	local ownedYou = Material( "manolis/popcorn/icons/gangs/iconownedyou.png", 'smooth mips')
	local ownedNone = Material( "manolis/popcorn/icons/gangs/iconownednone.png", 'smooth mips')
		
	function ENT:DrawDisplay()
		if(!manolis.popcorn.gangs.territories.territories[self:GetTerritory()]) then return end
		local tName = manolis.popcorn.gangs.territories.territories[self:GetTerritory()].name or "Unknown" .. "Territorty"
		local ownedBy = self:GetGangID()

		local drawA = {text='Unoccupied', color=manolis.popcorn.config.promColor}
		if(ownedBy and ownedBy!=0 and ownedBy!=(manolis.popcorn.gangs.gang and manolis.popcorn.gangs.gang.info and manolis.popcorn.gangs.gang.info.id)) then
			drawA.text = 'Owned by '..self:GetGang()
			drawA.color = Color(255,0,0,255)
		elseif(ownedBy==(manolis.popcorn.gangs.gang and manolis.popcorn.gangs.gang.info and manolis.popcorn.gangs.gang.info.id)) then
			drawA.text = 'Owned by '..self:GetGang()
			drawA.color = Color(255,255,255)
		end

		pos = self:GetPos()
		pos.z = pos.z + 50
		pos = pos:ToScreen()

		
		draw.DrawText(tName, "manolisItemNopeB", pos.x+2, pos.y-30+2, Color(0, 0, 0, 200), TEXT_ALIGN_CENTER)
		draw.DrawText(tName, "manolisItemNopeB", pos.x, pos.y-30, manolis.popcorn.config.promColor, TEXT_ALIGN_CENTER)

		draw.DrawText(drawA.text, "manolisItemNopeC", pos.x+2 , pos.y+2, Color(0,0,0, 200), TEXT_ALIGN_CENTER)
		draw.DrawText(drawA.text, "manolisItemNopeC", pos.x , pos.y, drawA.color, TEXT_ALIGN_CENTER)
			 

		if((ownedBy>0 and ownedBy!=(manolis.popcorn.gangs.gang and manolis.popcorn.gangs.gang.info and manolis.popcorn.gangs.gang.info.id) or ownedBy==0) and manolis.popcorn.gangs.gang and manolis.popcorn.gangs.gang.info and (LocalPlayer():getDarkRPVar('gang') or 0)>0) then
			draw.DrawText("Press "..string.upper(input.LookupBinding("+use")).." to capture", "manolisItemNopeC", pos.x+2, pos.y+25+2, Color(0,0,0,200), TEXT_ALIGN_CENTER)
			draw.DrawText("Press "..string.upper(input.LookupBinding("+use")).." to capture", "manolisItemNopeC", pos.x, pos.y+25, manolis.popcorn.config.promColor, TEXT_ALIGN_CENTER)
		end
 


	end


	function ENT:Draw()
		self:DrawModel()

		local gang = manolis.popcorn.gangs.GetPlayerGang(LocalPlayer())


			local pos = self:GetPos() + Vector(0,0,80)
			local ang = (LocalPlayer():GetPos() - self:GetPos()):Angle() + Angle(0,0,0)  
			ang:RotateAroundAxis(ang:Forward(),90)
			ang:RotateAroundAxis(ang:Right(),270)
			local c = (manolis.popcorn.config.promColor) 

			cam.Start3D2D(pos, ang, 1.3)
				surface.SetMaterial(ownedNone)

				if(self:GetGangID()=='' or self:GetGangID()==0) then
					c = manolis.popcorn.config.promColor
			
				elseif(self:GetGangID()!=gang) then
					c = Color(255,0,0,255)
					surface.SetMaterial(ownedRival)
				else
					surface.SetMaterial(ownedYou)
					c = Color(0,255,0,255)
				end

				surface.SetDrawColor(c)

				
				surface.DrawTexturedRect(-15/2,0,15,15)		
			
			cam.End3D2D()

	end




end