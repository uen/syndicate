if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.f4) then manolis.popcorn.f4 = {} end
if(!manolis.popcorn.f4.Settings) then manolis.popcorn.f4.Settings = {} end
if(!manolis.popcorn.f4.varCallbacks) then manolis.popcorn.f4.varCallbacks = {} end
if(!manolis.popcorn.f4.varCallbacks.doV) then manolis.popcorn.f4.varCallbacks.doV = {} end
if(!manolis.popcorn.f4.varCallbacks.toChange) then manolis.popcorn.f4.varCallbacks.toChange = {} end

include(GM.FolderName..'/gamemode/modules/popcorn-f4/manolisf4frame.lua')
include(GM.FolderName..'/gamemode/modules/popcorn-f4/manolisf4sidebar.lua')
include(GM.FolderName..'/gamemode/modules/popcorn-f4/manolisf4tab.lua')
include(GM.FolderName..'/gamemode/modules/popcorn-f4/manolisf4tabbase.lua')
include(GM.FolderName..'/gamemode/modules/popcorn-f4/manolisf4tabentities.lua')
include(GM.FolderName..'/gamemode/modules/popcorn-f4/manolisf4tabwebsite.lua')
include(GM.FolderName..'/gamemode/modules/popcorn-f4/manolisf4tabgangs.lua')
include(GM.FolderName..'/gamemode/modules/popcorn-f4/manolisf4tabgarage.lua')
include(GM.FolderName..'/gamemode/modules/popcorn-f4/manolisf4tabcharacter.lua')
include(GM.FolderName..'/gamemode/modules/popcorn-f4/manolisf4tabadmin.lua')
include(GM.FolderName..'/gamemode/modules/popcorn-f4/manolisf4tabachievements.lua')

local f4Frame
function manolis.popcorn.f4.openF4Menu()
	if(IsValid(f4Frame)) then
		f4Frame:Show()
		f4Frame:InvalidateLayout()
		f4Frame:MakePopup()
		for k,v in pairs(manolis.popcorn.f4.varCallbacks.toChange) do
			manolis.popcorn.f4.varCallbacks.change(k,v)
			manolis.popcorn.f4.varCallbacks.toChange[k] = nil
		end

	else
		f4Frame = vgui.Create("ManolisF4Frame")
		f4Frame:MakePopup()
	end
end

function manolis.popcorn.f4.preLoad()
	timer.Create("manolisPreloadF4",1,0, function()
		if(LocalPlayer and LocalPlayer().Team) then
			if(!IsValid(f4Frame)) then
				manolis.popcorn.f4.openF4Menu()
				f4Frame:Hide()
			end	

			timer.Remove("manolisPreloadF4")
		end
	end)
end

function manolis.popcorn.f4.closeF4Menu()
	if(IsValid(f4Frame)) then
		f4Frame:Hide()
		manolis.popcorn.enableClicker(false)
	end
end

function manolis.popcorn.f4.toggleF4Menu()
	if not IsValid(f4Frame) or not f4Frame:IsVisible() then
		manolis.popcorn.f4.openF4Menu()
		manolis.popcorn.enableClicker(true)
	else
		manolis.popcorn.f4.closeF4Menu()
		manolis.popcorn.enableClicker(false)
	end
end

GM.ShowSpare2 = manolis.popcorn.f4.toggleF4Menu

function manolis.popcorn.f4.getF4MenuPanel()
	return f4Frame
end

manolis.popcorn.f4.varCallbacks.change = function(var, new)
	if(manolis.popcorn.f4.varCallbacks.doV[var]) then
		for k,v in pairs(manolis.popcorn.f4.varCallbacks.doV[var]) do
			v(new)
		end
	end
end

manolis.popcorn.f4.varCallbacks.add = function(var, callback)
	if(type(var)=='table') then
		for k,v in pairs(var) do
			manolis.popcorn.f4.varCallbacks.add(v,callback)
		end
	end
	if(!manolis.popcorn.f4.varCallbacks.doV[var]) then manolis.popcorn.f4.varCallbacks.doV[var] = {} end
	table.insert(manolis.popcorn.f4.varCallbacks.doV[var], callback)
end


hook.Add("DarkRPVarChanged", "manolisPopcornUpdateF4", function(ply,var,old,new)
	if(old!=new) then
		if(IsValid(f4Frame) and f4Frame:IsVisible()) then
			manolis.popcorn.f4.varCallbacks.change(var,new)
		elseif(IsValid(f4Frame)) then
			manolis.popcorn.f4.varCallbacks.toChange[var] = new
		end
	end
end)

manolis.popcorn.f4.Settings.Tabs = {
	{
		name = DarkRP.getPhrase("character"),
		panel = "manolisF4TabCharacter"
	},
	{ 
		name = DarkRP.getPhrase("jobs"),
		panel = "manolisF4TabBase"
	},
	{
		name = DarkRP.getPhrase("shop"),
		panel = "manolisF4TabEntities"
	},
	{
		name = DarkRP.getPhrase("garage"),
		panel = "manolisF4TabGarage"
	},
	{
		name = DarkRP.getPhrase("gangs"),
		panel = "manolisF4TabGangs"
	},
	{
		name = DarkRP.getPhrase("achievements"),
		panel = "manolisF4TabAchievements"
	},


}


hook.Add("Initialize", "manolisPopcornPreloadF4", manolis.popcorn.f4.preLoad)