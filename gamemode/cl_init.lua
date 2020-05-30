GM.Version = "1.0.0"
GM.Name = "Syndicate RPG"
GM.Author = "Manolis Vrondakis"

local folderBase = 'syndicate'
hook.Add("DarkRPPreLoadModules", "manolisUpdateDefaults", function()
    include(folderBase .."/gamemode/config/disabled_defaults.lua")
end)

function GM:CustomObjFitsMap(obj)
    if not obj or not obj.maps then return true end

    local map = string.lower(game.GetMap())
    for _, v in pairs(obj.maps) do
        if string.lower(v) == map then return true end
    end
    return false
end

DeriveGamemode("darkrp")
DEFINE_BASECLASS("gamemode_darkrp")
GM.DarkRP = BaseClass

local customFiles = {
    "items/jobs.lua",

    "items/entities.lua",
    "items/vehicles.lua",

    "items/ammo.lua",
    "items/groupchats.lua",
    "items/categories.lua",
    "items/shipments.lua",
    "items/items.lua",
    "items/upgrades.lua",
    "items/achievements.lua",
    "items/gang-shop.lua",
    "items/gang-upgrades.lua",
    "items/agendas.lua", -- has to be run after jobs.lua
    "items/doorgroups.lua", -- has to be run after jobs.lua
    "items/demotegroups.lua", -- has to be run after jobs.lua

}     

include(folderBase .."/gamemode/config/config-default.lua")
include(folderBase .."/gamemode/config/config.lua")

include(folderBase .."/gamemode/config/settings.lua")

local fol = folderBase .. "/gamemode/languages/"
local files, folders = file.Find(fol.."*", "LUA")
for k,v in pairs(files) do
    if(string.GetExtensionFromFilename(v)!="lua") then continue end
    include(fol..v)

    AddCSLuaFile(fol..v)
end

local root = folderBase .. "/gamemode/modules/"
local _, folders = file.Find(root .. "*", "LUA")

for _, folder in SortedPairs(folders, true) do
    if DarkRP.disabledDefaults["modules"][folder] then continue end

    for _, File in SortedPairs(file.Find(root .. folder .. "/sh_*.lua", "LUA"), true) do
        if File == "sh_interface.lua" then continue end
    
        include(root .. folder .. "/" .. File)
    end
    for _, File in SortedPairs(file.Find(root .. folder .. "/cl_*.lua", "LUA"), true) do
        if File == "cl_interface.lua" then continue end
        include(root .. folder .. "/" .. File)
    end

end


for _, File in pairs(customFiles) do
    if not file.Exists(folderBase ..'/gamemode/'..File, "LUA") then continue end
    if SERVER then AddCSLuaFile(folderBase..'/gamemode/'..File) end
    include(folderBase..'/gamemode/'..File)
end


include(folderBase.."/gamemode/libraries/modificationloader.lua")
hook.Call("SyndicateFinishedLoading", DarkRP.hooks)
