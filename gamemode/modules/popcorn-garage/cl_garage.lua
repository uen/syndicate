if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.garage) then manolis.popcorn.garage = {} end
if(!manolis.popcorn.garage.cars) then manolis.popcorn.garage.cars = {} end
if(!manolis.popcorn.garage.myCars) then manolis.popcorn.garage.myCars = {} end
if(!manolis.popcorn.garage.spawned) then manolis.popcorn.garage.spawned = {} end

net.Receive("ManolisPopcornGarageUpdate", function()
	manolis.popcorn.garage.myCars = net.ReadTable()
	hook.Call("manolis:GarageUpdate", DarkRP.hooks, manolis.popcorn.garage.myCars)
end)

net.Receive("ManolisPopcornGarageSpawnUpdate", function()
	manolis.popcorn.garage.spawned = net.ReadTable()
	hook.Call("manolis:GarageSpawnUpdate", DarkRP.hooks, manolis.popcorn.garage.spawned)
end)