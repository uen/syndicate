local meta = FindMetaTable("Player")
local Swagbag = {}
local frame
local reload

--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
function meta:getSwagbagItems()
    if self ~= LocalPlayer() then return nil end

    return Swagbag
end

function DarkRP.openSwagbagMenu()
  
end

local function retrieveSwagbag()
    Swagbag = net.ReadTable()
end
net.Receive("DarkRP_Swagbag", retrieveSwagbag)
