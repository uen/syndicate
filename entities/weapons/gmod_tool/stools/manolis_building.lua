TOOL.Category = "Popcorn Admin"
TOOL.Name = "Building Marker Tool"

function TOOL:LeftClick(trace)
	if(trace and trace.HitWorld) then
		if(SERVER) then
			if(manolis.popcorn.config.canEditServer(self:GetOwner())) then
				net.Start("ManolisPopcornSetupBuilding")
				net.Send(self:GetOwner())
			end
		end
	end
end

function TOOL:UpdateGhostCapturePoint( ent, pl )
	if ( !IsValid( ent ) ) then return end
	local trace = util.TraceLine( util.GetPlayerTrace( pl ) )
	if ( !trace.Hit ) then return end

	if ( trace.Entity && trace.Entity:GetClass() == "manolis_building" || trace.Entity && trace.Entity:GetClass()=="manolis_power" ||  trace.Entity:IsPlayer() || !trace.HitWorld) then
		ent:SetNoDraw( true )
		return
	end

	local Ang = trace.HitNormal:Angle()
	ent:SetPos(trace.HitPos)
	ent:SetAngles(trace.HitNormal:Angle())
	ent:SetNoDraw( false )
end

function TOOL:Think()
	if ( !IsValid( self.GhostEntity )) then
		self:MakeGhostEntity( 'models/props_lab/tpswitch.mdl', Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end
	self:UpdateGhostCapturePoint( self.GhostEntity, self:GetOwner() )
end

if(CLIENT) then
	language.Add("Tool.manolis_building.name", "Building Marker Tool")
	language.Add("Tool.manolis_building.desc", "Mark a building's capture point")

	language.Add("Tool.manolis_building.0", "Click on the inside wall of a building")
end