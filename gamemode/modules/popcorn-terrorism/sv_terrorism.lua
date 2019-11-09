if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.terrorism) then manolis.popcorn.terrorism = {} end

hook.Add('GravGunOnPickedUp', 'manolis:popcorn:terror:removeFromEnricher', function(ply,ent)
	if(ent:GetClass()=='popcorn_rod' and IsValid(ent.Enricher)) then
		ent.Enricher:OnPowerDisconnect()
		return true
	end
end)

hook.Add('playerCanChangeTeam', 'manolis:terrorism:changeAfterBomb', function(ply, team)
	if(team==TEAM_TERRORIST or team==TEAM_POLICECHIEF) then
		if(manolis.popcorn.terrorism.bombActivated) then
			return false, DarkRP.getPhrase('terror_changejob')
		end
	end
end)