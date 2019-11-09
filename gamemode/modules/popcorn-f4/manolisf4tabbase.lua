AddCSLuaFile()
local PANEL = {}

function PANEL:Init()
	self:SetSize(650,535)
	self.Paint = function(panel,w,h)
		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(0,0,w,h)
	end

	local jobs = vgui.Create("Panel", self)
	jobs:SetSize(650,535)

	local itemList = vgui.Create("ManolisScrollPanel", jobs)
	itemList:SetPos(5,5)
	itemList:SetSize(650-10, 535-5)

	table.sort(RPExtraTeams, function(a,b) return (a.level or 0) < (b.level or 0) end)

	local refreshJobs = function()
		itemList:ClearPanel()
		for k,v in ipairs(RPExtraTeams) do
			if((istable(v.allowed) and table.HasValue(v.allowed, LocalPlayer():Team())) or !istable(v.allowed)) then
				if((v.customCheck and v.customCheck(LocalPlayer())) or !v.customCheck) then
					if(LocalPlayer():Team()!=k) then
						local item = vgui.Create("ManolisJobPanel")
						item:Go(k, v.name, istable(v.model) and v.model[1] or v.model, v.level or 1, v.command or '', v.vote or false)
						itemList:Add(item)
					end
				end
			end
		end
	end

	refreshJobs()

	manolis.popcorn.f4.varCallbacks.add('level', function(new)
		for a,job in pairs(itemList:GetItems()) do
			job:Update(new)
		end
	end)

	manolis.popcorn.f4.varCallbacks.add('job', function(new)
		refreshJobs()
	end)
end
vgui.Register( "manolisF4TabBase", PANEL, "DPanel" )