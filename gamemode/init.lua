GM.Version = "1.0.0"
GM.Name = "Syndicate RPG"
GM.Author = "Manolis Vrondakis"

if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end

include("config/mysql.lua")

local folderBase = GM.FolderName
include(folderBase.."/gamemode/libraries/mysqlite/mysqlite.lua")

local customFiles = {
    "items/jobs.lua",
    "items/entities.lua",
    "items/vehicles.lua",
    "items/ammo.lua",
    "items/groupchats.lua",
    "items/categories.lua",


    "items/shipments.lua",
    "items/items.lua",
    "items/achievements.lua",
    "items/armor.lua",
    "items/weapons.lua",
    "items/gang-shop.lua",
    "items/gang-upgrades.lua",
    "items/upgrades.lua",
    "items/agendas.lua", -- has to be run after jobs.lua
    "items/doorgroups.lua", -- has to be run after jobs.lua
    "items/demotegroups.lua", -- has to be run after jobs.lua
}

local function loadCustomManolisItems()
    for _, File in pairs(customFiles) do
        local File = folderBase.."/gamemode/"..File
        if not file.Exists(File, "LUA") then continue end
        if SERVER then AddCSLuaFile(File) end
        include(File)
    end
end


hook.Add("DarkRPPreLoadModules", "manolisUpdateDefaults", function()
    include(folderBase .."/gamemode/config/disabled_defaults.lua")
end)


DeriveGamemode("darkrp")

DEFINE_BASECLASS("gamemode_darkrp")

GM.DarkRP = BaseClass

resource.AddWorkshop("736915963")


/*---------------------------------------------------------------------------
Config
---------------------------------------------------------------------------*/

AddCSLuaFile(folderBase .."/gamemode/config/settings.lua")
AddCSLuaFile(folderBase .."/gamemode/config/config-default.lua")
AddCSLuaFile(folderBase .."/gamemode/config/config.lua")

AddCSLuaFile(folderBase .."/gamemode/config/disabled_defaults.lua")
AddCSLuaFile(folderBase .."/gamemode/libraries/purchasing.lua")
GM.Config = GM.Config or {}

include("config/settings.lua")
include("config/config-default.lua")
include("config/config.lua")


include("libraries/purchasing.lua")

manolis.popcorn.matchFunc = function(d)
    return util.CRC(util.CRC(d.source:match('gamemode%/modules%/.*-(.*)')))
end


local fol = folderBase .. "/gamemode/languages/"
local files, folders = file.Find(fol.."*", "LUA")
for k,v in pairs(files) do
    if(string.GetExtensionFromFilename(v)!="lua") then continue end
    include(fol..v)

    AddCSLuaFile(fol..v)
end

fol = folderBase .. "/gamemode/modules/"



local files, folders = file.Find(fol .. "*", "LUA")

for k, v in pairs(files) do
    if string.GetExtensionFromFilename(v) ~= "lua" then continue end
    include(fol .. v)
end

for _, folder in SortedPairs(folders, true) do
    if folder == "." or folder == ".." then continue end

    for _, File in SortedPairs(file.Find(fol .. folder .. "/sh_*.lua", "LUA"), true) do
        AddCSLuaFile(fol .. folder .. "/" .. File)
        if File == "sh_interface.lua" then continue end
        include(fol .. folder .. "/" .. File)
    end

    for _, File in SortedPairs(file.Find(fol .. folder .. "/sv_*.lua", "LUA"), true) do
        if File == "sv_interface.lua" then continue end
        include(fol .. folder .. "/" .. File)
    end

    for _, File in SortedPairs(file.Find(fol .. folder .. "/cl_*.lua", "LUA"), true) do
        if File == "cl_interface.lua" then continue end
        AddCSLuaFile(fol .. folder .. "/" .. File)
    end

    MsgC(Color(0,255,0), 'Module '..folder..' successfully loaded\n')
end


AddCSLuaFile(folderBase.."/gamemode/libraries/modificationloader.lua")
include(folderBase.."/gamemode/libraries/modificationloader.lua")
hook.Call("SyndicateFinishedLoading", DarkRP.hooks)

loadCustomManolisItems()
GM.DefaultTeam = TEAM_HOBO
