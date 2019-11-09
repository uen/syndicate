if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.gangs) then manolis.popcorn.gangs = {} end
if(!manolis.popcorn.gangs.gang) then manolis.popcorn.gangs.gang = {} end
if(!manolis.popcorn.gangs.invites) then manolis.popcorn.gangs.invites = {} end
if(!manolis.popcorn.gangs.shop) then manolis.popcorn.gangs.shop = {} end
if(!manolis.popcorn.gangs.shop.items) then manolis.popcorn.gangs.shop.items = {} end
if(!manolis.popcorn.gangs.shop.permissions) then manolis.popcorn.gangs.shop.permissions = {} end

net.Receive("ManolisPopcornGangInfo", function()
	local gang = net.ReadTable()
	local rivals = {}
	
	if(gang.rivals) then
		for a,b in pairs(gang.rivals or {}) do
			rivals[b.id] = b

			local c2 = split(b.secondcolor, ',')
			local c1 = split(b.color, ',')

			rivals[b.id].c1 = Color(c1[1], c1[2], c1[3])
			rivals[b.id].c2 = Color(c2[1], c2[2], c2[3])
		end

		gang.rivals = rivals
	end

	for k,v in pairs(gang) do
		manolis.popcorn.gangs.gang[k] = v
	end

	hook.Call("manolis:GangUpdate", DarkRP.hooks, manolis.popcorn.gangs.gang)

	if(manolis.popcorn.gangs.panel) then
		manolis.popcorn.gangs.panel.refresh()
	end
end)

net.Receive("ManolisPopcornGangInviteInfo", function()
	local invites = net.ReadTable()
	if(!invites) then invites = {} end

	manolis.popcorn.gangs.invites = invites
	if(manolis.popcorn.gangs.panel) then
		manolis.popcorn.gangs.panel.refresh()
	end

	hook.Call("manolis:GangInviteUpdate", DarkRP.hooks, invites)
end)

net.Receive("ManolisPopcornGangShopPermissions", function()
	local perms = net.ReadTable()
	for k,v in pairs(perms) do
		manolis.popcorn.gangs.shop.permissions[k] = v
	end

	if(manolis.popcorn.gangs.panel) then
		manolis.popcorn.gangs.panel.refreshPermissions()
	end
end)


net.Receive("ManolisPopcornRivalChange", function()
	local gang = net.ReadTable()
	for k,v in pairs(manolis.popcorn.gangs.rivalPanels or {}) do
		if(v.gData.id == gang.id) then
			v:Go(gang.id, gang.name, gang.logo, gang.color or '0,0,0', gang.secondcolor or '0,0,0', gang.level or 1, gang.kills or 0, gang.stashes or 0, gang.truce and 1 or 0)
		end
	end		
end)

net.Receive("ManolisPopcornTerritoryUpdate", function()
	local territories = net.ReadTable()
	manolis.popcorn.gangs.territories.territories = territories
	hook.Call("manolis:TerritoryUpdate", DarkRP.hooks)
end)

net.Receive("ManolisPopcornGangMemberUpdate", function()
	local members = net.ReadTable()
	manolis.popcorn.gangs.gang.members = members
	hook.Call("manolis:GangMemberRefresh", DarkRP.hooks)
end)

net.Receive("ManolisPopcornGangRankChange", function()
	local a = net.ReadTable()
	for k,v in pairs(manolis.popcorn.gangs.gang.members) do
		if(v.uid == a.player) then
			v.rank = a.rank
		end
	end
	hook.Call("manolis:GangRankUpdate", DarkRP.hooks, a)
end)

manolis.popcorn.gangs.ShowInfo = false
timer.Create("ManolisPopcornTerritoryRadius", 3, 0, function()
	local found = false
	local poles = ents.FindByClass("gang_territory")
	for k,v in pairs(poles) do
		if(v:GetPos():Distance(LocalPlayer():GetPos())<1000) then
			if(IsValid(v) and v.GetTerritory) then
				local id = v:GetTerritory()

				local gTerritories = ents.FindByClass("gang_territory")

				for k,v in pairs(manolis.popcorn.gangs.territories.territories) do
		            if(v.id == id) then
		                manolis.popcorn.gangs.ShowInfo = v


		                local cap = 0
		                for ka,va in pairs(v.locations) do


			                for kx,vx in pairs(gTerritories) do
			                	if(vx:GetLocationID() == va.id) then
			                		if(vx:GetGangID() == LocalPlayer():getDarkRPVar('gang')) then
			                			cap = cap + 1
			                		end
			                	end
			                end
		                end

		                manolis.popcorn.gangs.ShowInfo.numCaptured = cap
		            end
		        end

				found = true
				return
			end
	
		end
	end
	if(!found) then manolis.popcorn.gangs.ShowInfo = false end
end)