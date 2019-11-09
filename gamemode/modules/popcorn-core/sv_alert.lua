if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.alerts) then manolis.popcorn.alerts = {} end
if(!manolis.popcorn.alerts.alerts) then manolis.popcorn.alerts.alerts = {} end

manolis.popcorn.alerts.NewAlert = function(ply,id,name,location,time, callback)
	if(!IsValid(ply)) then return end
	if(!id) then return end
	net.Start("ManolisPopcornAlert")
		net.WriteString(id)
		net.WriteString(name or "Unknown")
		net.WriteVector(location or Vector(0,0,0))
		net.WriteInt(time or 10, 32)
	net.Send(ply)

	timer.Simple(time or 10, function()
		if(IsValid(ply)) then
			manolis.popcorn.alerts.RemoveAlert(ply,id)
		end
	end)

	table.insert(manolis.popcorn.alerts.alerts, {ply=ply, id=id,name=name,location=location,time=time,callback=callback})
end

manolis.popcorn.alerts.NewAlertAll = function(id,name,location,time)
	if(!id) then return end
	net.Start("ManolisPopcornAlert")
		net.WriteString(id)
		net.WriteString(name or "Unknown")
		net.WriteVector(location or Vector(0,0,0))
		net.WriteInt(time or 10, 32)
	net.Broadcast()

	timer.Simple(time or 10, function()
		if(IsValid(ply)) then
			manolis.popcorn.alerts.RemoveAlertAll(ply,id)
		end
	end)
end

manolis.popcorn.alerts.NewTimeAlert = function(ply,time,name, callback)
	if(!IsValid(ply)) then return end

	net.Start('ManolisPopcornAlertTime')
		net.WriteInt(time or 10,32)
		net.WriteString(name or 'Unknown')
	net.Send(ply)

	timer.Create('ManolisPopcornPlayerTimer'..ply:UserID(), time, 1, function()
		if(callback) then
			callback()
		end
	end)
end

manolis.popcorn.alerts.RemoveTimeAlert = function(ply)
	if(!IsValid(ply)) then return end
	net.Start('ManolisPopcornAlertRemoveTime')
	net.Send(ply)

	timer.Stop('ManolisPopcornPlayerTimer'..ply:UserID())
end

manolis.popcorn.alerts.RemoveAlert = function(ply,id)
	if(!IsValid(ply)) then return end
	net.Start("ManolisPopcornAlertRemove")
		net.WriteString(id or "")
	net.Send(ply)

	for k,v in pairs(manolis.popcorn.alerts.alerts) do
		if(v.id==id) then
			table.remove(manolis.popcorn.alerts.alerts,k)
		end
	end
end


manolis.popcorn.alerts.RemoveAlertAll = function(id)
	if(!id) then return end
	net.Start("ManolisPopcornAlertRemove")
		net.WriteString(id or "")
	net.Broadcast()
end

local lastThink = 0
hook.Add('Think', 'manolis:AlertThink', function()
	if(lastThink<CurTime()-0.5) then
		lastThink = CurTime()

		for k,v in pairs(manolis.popcorn.alerts.alerts) do
			if(!IsValid(v.ply)) then
				table.remove(manolis.popcorn.alerts.alerts,k)
				continue
			end

			if(v.ply:GetPos():Distance(v.location)<150) then
				if(v.callback) then
					v.callback()
				end

				table.remove(manolis.popcorn.alerts.alerts,k)
			end
		end
	end
end)