-- The client cannot use simplerr.runLuaFile because of restrictions in GMod.
local doInclude = CLIENT and include or fc{simplerr.wrapError, simplerr.wrapLog, simplerr.runFile}

if file.Exists("darkrp_config/disabled_defaults.lua", "LUA") then
    if SERVER then AddCSLuaFile("darkrp_config/disabled_defaults.lua") end
    doInclude("darkrp_config/disabled_defaults.lua")
end

local fol = GM.FolderName .. "/gamemode/modules/"

local configFiles = {
    "config/settings.lua",
    "config/licenseweapons.lua",
}

for _, File in pairs(configFiles) do
    if not file.Exists(fol..File, "LUA") then continue end

    if SERVER then AddCSLuaFile(File) end
    doInclude(fol..File)
end


/*---------------------------------------------------------------------------
Modules
---------------------------------------------------------------------------*/


local function loadLanguages()
    local fol = fol.."language/"

    local files, _ = file.Find(fol .. "*", "LUA")
    for _, File in pairs(files) do
        if SERVER then AddCSLuaFile(fol .. File) end
        doInclude(fol .. File)
    end
end


local entsNoCollide = {spawned_weapon=true, ent_healthkit=true, ent_armorkit=true}

hook.Add("ShouldCollide", "manolis:selfEntityCollide", function(e,d)
    if(entsNoCollide[e:GetClass()] and entsNoCollide[d:GetClass()]) then
        return false
    end
end)