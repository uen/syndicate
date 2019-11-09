TOOL.Category = "Popcorn Admin"
TOOL.Name = "Building Cash Stack Spawn"

function TOOL:LeftClick(trace)
	if(trace and trace.HitWorld) then
		if(SERVER) then
			if(manolis.popcorn.config.canEditServer(self:GetOwner())) then
				net.Start("ManolisPopcornSetupBuildingCash")
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


	ent:SetPos(trace.HitPos)
	ent:SetAngles(Angle(0,0,0))

	ent:SetNoDraw( false )
end

function TOOL:Think()
	if ( !IsValid( self.GhostEntity )) then
		self:MakeGhostEntity( 'models/props/cs_assault/MoneyPallet03D.mdl', Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostSocket( self.GhostEntity, self:GetOwner() )
end

if(CLIENT) then
	language.Add("Tool.manolis_cash.name", "Building Cash Stack Spawn")
	language.Add("Tool.manolis_cash.desc", "Set the spawn point of cash stacks for base defense missions")
	language.Add("Tool.manolis_cash.0", "Click the inside of a building")
end