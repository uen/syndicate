TOOL.Category = "Popcorn Admin"
TOOL.Name = "Power Socket Creation Tool"

function TOOL:LeftClick(trace)
	if(trace and trace.HitWorld) then
		if(SERVER) then
			if(manolis.popcorn.config.canEditServer(self:GetOwner())) then
				net.Start("ManolisPopcornSetupBuildingPower")
				net.Send(self:GetOwner())
			end
		end
	end
end

function TOOL:UpdateGhostSocket( ent, pl )
	if ( !IsValid( ent ) ) then return end

	local trace = util.TraceLine( util.GetPlayerTrace( pl ) )
	if ( !trace.Hit ) then return end

	if ( trace.Entity and trace.Entity:GetClass() == "manolis_building" || trace.Entity and trace.Entity:GetClass()=="manolis_power" ||  trace.Entity:IsPlayer() || !trace.HitWorld) then
		ent:SetNoDraw( true )
		return
	end

	local Ang = trace.HitNormal:Angle()
	ent:SetPos(trace.HitPos+(trace.HitNormal:Angle():Forward()*2))
	ent:SetAngles(trace.HitNormal:Angle())

	ent:SetNoDraw( false )
end

function TOOL:Think()
	if ( !IsValid( self.GhostEntity )) then
		self:MakeGhostEntity( 'models/props_lab/powerbox02b.mdl', Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostSocket( self.GhostEntity, self:GetOwner() )
end

if(CLIENT) then
	language.Add("Tool.manolis_power_admin.name", "Power Socket Creation Tool")
	language.Add("Tool.manolis_power_admin.desc", "Add plug sockets to buildings")
	language.Add("Tool.manolis_power_admin.0", "Click to create a socket")
end