local PANEL = {}

function PANEL:Init()
	self:SetSize(650,535)
	self.Paint = function(panel,w,h)
		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(0,0,w,h)
	end

	local cars = vgui.Create("Panel", self)
	cars:SetSize(650,535)

	local itemList = vgui.Create("ManolisScrollPanel", cars)
	itemList:SetPos(5,5)
	itemList:SetSize(650-10, 535-5)
	local buttonText
	local buttonFunc

	local rPanel = function()
		itemList:ClearPanel()
		for k,v in pairs(manolis.popcorn.garage.myCars or {}) do
			local item = vgui.Create("ManolisItemPanel")
			buttonText = DarkRP.getPhrase('car_spawn')
			buttonFunc = fn.Compose{fn.Partial(RunConsoleCommand, 'ManolisPopcornSpawnVehicle', v.name), manolis.popcorn.f4.closeF4Menu}

			if(manolis.popcorn.garage.spawned and manolis.popcorn.garage.spawned.car and manolis.popcorn.garage.spawned.car==v.name) then
				buttonText = DarkRP.getPhrase('de_spawn')
				buttonFunc = function()
					Manolis_Query(DarkRP.getPhrase('car_remove'), DarkRP.getPhrase('confirm'), DarkRP.getPhrase('car_removed'), function() 
						fn.Partial(RunConsoleCommand, 'ManolisPopcornRemoveVehicle')()
					end, "Cancel")
				end
			end
			item:Go(k, v.name, 'manolis/popcorn/icons/cars/'..v.name, "Vehicle", buttonText, buttonFunc)

			itemList:Add(item)
		end


		if((#manolis.popcorn.garage.myCars or {})==0) then
			local noVehicles = vgui.Create('DLabel')
			noVehicles:SetContentAlignment(5)
			noVehicles:SetWide(650)
			noVehicles:SetTall(50)
			noVehicles:SetFont('manolisTradeMoneyName')
			noVehicles:SetText('No vehicles available!')
			itemList:Add(noVehicles)
		end

	end
	rPanel()

	hook.Add("manolis:GarageUpdate","manolis:RefreshGarage", function(cars)
		rPanel()
	end)

	hook.Add("manolis:GarageSpawnUpdate", "manolis:RefreshSpawnGarage", function(cars)
		rPanel()
	end)
end

vgui.Register( "manolisF4TabGarage", PANEL, "DPanel" )