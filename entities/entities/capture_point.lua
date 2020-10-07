AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
 
ENT.PrintName		= "Building Capture Point"
ENT.Author			= "Manolis Vrondakis"
ENT.Contact			= "http://manolisvrondakis.com/"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.HasBeenSetup = false

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "BuildingID" );
end

function ENT:Initialize()
	if(SERVER) then
		self:SetModel( "models/props_lab/tpswitch.mdl" )
		self:SetUseType(SIMPLE_USE)

		self:SetSolid(SOLID_BBOX)
		self.gettingCaptured = false
		self.captureTime = manolis.popcorn.config.capBuildingTime
		self.OldTick = SysTime()
	end
end

if(SERVER) then
	function ENT:Use(ply)
		local aDoor
		local building
		
		if(ply and table.HasValue(manolis.popcorn.config.bannedBuildingPurchase, ply:Team())) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('building_capture_cannot'))
			return
		end

		for k,v in pairs(manolis.popcorn.buildings.buildings) do
			if(v.id == self:GetBuildingID()) then
				for doorKey,doorValue in pairs(v.doors or {}) do
					local door = DarkRP.doorIndexToEnt(doorValue.id)
					if(!IsValid(door) or !door:isDoor()) then continue end
					aDoor = doorValue
				end

				building = v
			end
		end

		if(!aDoor) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('building_capture_nodoors'))
			return
		end
		
		aDoor.ent = DarkRP.doorIndexToEnt(aDoor.id)

		if(!self.HasBeenSetup) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('building_capture_setup'))
			return
		end

		if(aDoor.ent:isKeysOwnedBy(ply)) then 
			DarkRP.notify(ply,0,4,DarkRP.getPhrase('building_capture_own'))
			return
		else
			if(!building.ownedBy or !IsValid(building.ownedBy)) then
				manolis.popcorn.buildings.CaptureBuilding(ply, self:GetBuildingID())
			end
		end
	
		if(!self.gettingCaptured) then
			local owner = building.ownedBy
			self.gettingCaptured = ply

			net.Start("ManolisPopcornBuildingStartCapturing")
				net.WriteBool(true)
			net.Send(self.gettingCaptured)

			manolis.popcorn.alerts.NewAlert(v, self:GetBuildingID().."BuildCap", DarkRP.getPhrase('building_contest'), self:GetPos(), manolis.popcorn.config.capBuildingTime)
		end
	end
 	
	function ENT:Think()
		local tickTime = SysTime() - self.OldTick
		self.OldTick = SysTime()
		if(self.gettingCaptured) then
			local timeMult = 1
			if(IsValid(self.gettingCaptured) and self.gettingCaptured:GetPos():Distance(self:GetPos())>300) then
				net.Start("ManolisPopcornBuildingStartCapturing")
					net.WriteBool(false)
				net.Send(self.gettingCaptured)

				self.gettingCaptured = false
				self.captureTime = manolis.popcorn.config.capBuildingTime				
			else
				self.captureTime = self.captureTime - ((tickTime)*timeMult)
			end

			if(self.captureTime <= 0) then	
				manolis.popcorn.buildings.CaptureBuilding(self.gettingCaptured, self:GetBuildingID())

				net.Start("ManolisPopcornBuildingStartCapturing")
					net.WriteBool(false)
				net.Send(self.gettingCaptured)

				self.gettingCaptured = false
				self.captureTime = manolis.popcorn.config.capBuildingTime
			end
		end
	end
end

if(CLIENT) then
	function ENT:DrawDisplay()
		local pos = self:GetPos()
		pos.z = pos.z + 10
		pos = pos:ToScreen()
		draw.DrawText('Capture Point', "manolisItemNopeC", pos.x-2, pos.y-2, Color(0, 0, 0, 200), 1)
		draw.DrawText('Capture Point', "manolisItemNopeC", pos.x , pos.y, manolis.popcorn.config.promColor, 1)
	end
end