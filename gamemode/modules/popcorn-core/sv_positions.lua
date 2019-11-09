if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.positions) then manolis.popcorn.positions = {} end
if(!manolis.popcorn.positions.positions) then manolis.popcorn.positions.positions = {} end
if(!manolis.popcorn.positions.positionSpawns) then manolis.popcorn.positions.positionSpawns = {} end
manolis.popcorn.positions.SetPosition = function(v,pos,angles,callback)
	local a = v
	MySQLite.query('INSERT INTO manolis_popcorn_positions(name,map,x,y,z,ax,ay,az) VALUES('..MySQLite.SQLStr(a.name)..","..MySQLite.SQLStr(game.GetMap())..','..MySQLite.SQLStr(pos.x)..','..MySQLite.SQLStr(pos.y)..','..MySQLite.SQLStr(pos.z)..','..MySQLite.SQLStr(angles.x)..','..MySQLite.SQLStr(angles.y)..','..MySQLite.SQLStr(angles.z)..') ON DUPLICATE KEY UPDATE x='..MySQLite.SQLStr(pos.x)..', y='..MySQLite.SQLStr(pos.y)..',z='..MySQLite.SQLStr(pos.z)..',ax='..MySQLite.SQLStr(angles.x)..',ay='..MySQLite.SQLStr(angles.y)..',az='..MySQLite.SQLStr(angles.z),function() 
		if(callback) then callback() end	
	end)
end


local haveRefreshed = false
hook.Add("PlayerInitialSpawn", "SpawnPlayerStuff", function()
	if(!haveRefreshed) then
		MySQLite.query('SELECT name,x,y,z,ax,ay,az FROM manolis_popcorn_positions WHERE map = '..MySQLite.SQLStr(game.GetMap()), function(data)
			for k,v in pairs(data or {}) do
				for a,b in pairs(manolis.popcorn.positions.positions) do
					if(v.name == b.name) then
						local ent = ents.Create(b.ent)
						if(IsValid(ent)) then
							ent:SetPos(Vector(v.x,v.y,v.z))
							ent:SetAngles(Angle(v.ax,v.ay,v.az))
							ent:Spawn()

							manolis.popcorn.positions.positionSpawns[v.name] = ent

							hook.Call("PositionEntitiesSpawned", DarkRP.hooks)
						end
					end
				end
			end
		end)
		haveRefreshed = true
	end
end)


concommand.Add('ManolisPopcornSetPosition', function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args[1]) then return end
	if(manolis.popcorn.config.canEditServer(ply)) then
		for k,v in pairs(manolis.popcorn.positions.positions) do
			if(manolis.popcorn.config.hashFunc(v.name)==args[1]) then
				manolis.popcorn.positions.SetPosition(v,ply:GetPos(),ply:GetAngles(), function()
					DarkRP.notify(ply,0,4,'Position for '..v.name..' successfully set')

					if(manolis.popcorn.positions.positionSpawns[v.name]) then
						manolis.popcorn.positions.positionSpawns[v.name]:Remove()
					end

					local ent = ents.Create(v.ent)
					ent:SetPos(ply:GetPos())
					ent:SetAngles(ply:GetAngles())
					ent:Spawn()

					manolis.popcorn.positions.positionSpawns[v.name] = ent
					hook.Call("PositionEntitiesSpawned", DarkRP.hooks)
				end)

				return
			end
		end
	end
end)