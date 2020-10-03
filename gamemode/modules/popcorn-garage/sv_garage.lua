if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.garage) then manolis.popcorn.achievements = {} end
if(!manolis.popcorn.garage.cars) then manolis.popcorn.garage.cars = {} end
if(!manolis.popcorn.garage.spawnedCars) then manolis.popcorn.garage.spawnedCars = {} end

manolis.popcorn.garage.sendCars = function(ply, cars) 
	net.Start("ManolisPopcornGarageUpdate")
		net.WriteTable(cars)
	net.Send(ply)
end

concommand.Add("ManolisPopcornSpawnVehicle", function(ply,cmd,args)
	if(!args[1]) then return false end
	local carMeta = manolis.popcorn.garage.Find(args[1])
	if(carMeta) then
		manolis.popcorn.garage.GetCar(ply,args[1], function(a)
			if(a) then
				if(manolis.popcorn.garage.spawnedCars[ply]) then
					if(manolis.popcorn.garage.spawnedCars[ply]) then
						DarkRP.notify(ply,1,4,DarkRP.getPhrase('car_already_spawned'))
						return false 
					end
				end

				local mCar = manolis.popcorn.garage.Find(a.name)
				if(!mCar) then
					DarkRP.notify(ply,1,4,DarkRP.getPhrase('error_spawning_garage'))
					return
				end

				local vehicle = list.Get('Vehicles')[mCar.ent]

				local trace = {}
			    trace.start = ply:EyePos()
			    trace.endpos = trace.start + ply:GetAimVector() * 250
			    trace.filter = ply
			    local tr = util.TraceLine(trace)

			    local spawned = ents.Create(vehicle.Class)
			    spawned:SetModel(vehicle.Model)
			    spawned:SetPos(tr.HitPos)

				for k,v in pairs(vehicle.KeyValues) do
					spawned:SetKeyValue(k,v)
				end

			    spawned:Spawn()
			    spawned:Activate()
			    spawned:SetCollisionGroup(COLLISION_GROUP_VEHICLE)
			    spawned:keysOwn(ply)
				spawned.Owner = ply
				spawned.SID = ply.SID
				spawned:Fire('lock', '', 0)

				hook.Call('playerBoughtVehicle', DarkRP.hooks, ply, spawned, 0)

				if(!manolis.popcorn.garage.spawnedCars[ply]) then manolis.popcorn.garage.spawnedCars[ply] = {} end
				manolis.popcorn.garage.spawnedCars[ply] = {ent=spawned, car=mCar}

				net.Start("ManolisPopcornGarageSpawnUpdate")
					net.WriteTable({car=carMeta.name})
				net.Send(ply)

				DarkRP.notify(ply,0,4,DarkRP.getPhrase('spawned_car', mCar.name))
			end
		end)
	end
end)

concommand.Add("ManolisPopcornRemoveVehicle", function(ply,cmd,args)
	if(manolis.popcorn.garage.spawnedCars[ply]) then
		if(IsValid(manolis.popcorn.garage.spawnedCars[ply].ent)) then
			manolis.popcorn.garage.spawnedCars[ply].ent:Remove()
		end

		net.Start("ManolisPopcornGarageSpawnUpdate")
			net.WriteTable({car=false})
		net.Send(ply)

		DarkRP.notify(ply,0,4,DarkRP.getPhrase('remove_car'))
		manolis.popcorn.garage.spawnedCars[ply] = nil
	end
end)

concommand.Add("ManolisPopcornPurchaseVehicle", function(ply,cmd,args)
	if(!args[1]) then return false end
	local car = manolis.popcorn.garage.Find(args[1])
	if(car) then
		if(car.canBuy) then
			if(IsValid(ply) and ply:canAfford(car.price)) then
				local blueprint = manolis.popcorn.crafting.FindBlueprint(car.name)
				if(blueprint) then
					ply:addMoney(-car.price)
					local data = manolis.popcorn.crafting.CreateBlueprintData(blueprint)
					manolis.popcorn.inventory.addItem(ply,data, function(da)
						DarkRP.notify(ply,0,4,DarkRP.getPhrase('car_buy_success', car.name))
					end)
				end
			else
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('car_buy_afford'))
			end
		else
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('car_buy_othererror'))
		end 
	end
end)

hook.Add("PlayerDisconnect", "manolis:garage:RemoveVehicles", function(ply)
	if(manolis.popcorn.garage.spawnedCars[ply]) then
		manolis.popcorn.garage.spawnedCars[ply].ent:Remove()
		manolis.popcorn.garage.spawnedCars[ply] = nil
	end
end)

hook.Add("PlayerInitialSpawn", "manolis:popcorn:garage:GetCars", function(ply)
	ply:RefreshGarage()
end)

local meta = FindMetaTable('Player')
meta.RefreshGarage = function(ply)
	manolis.popcorn.garage.retrievePlayerCars(ply, function(a)
		if(a) then
			manolis.popcorn.garage.sendCars(ply,a or {})
		end
	end)
end
