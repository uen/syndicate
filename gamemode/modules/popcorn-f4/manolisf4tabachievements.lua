AddCSLuaFile()
local PANEL = {}

function PANEL:Init()
	self:SetSize(650,535)
	self.Paint = function(panel,w,h)
		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(0,0,w,h)
	end

	local achievements = vgui.Create("Panel", self)
	achievements:SetSize(650,535)

	local itemList = vgui.Create("ManolisScrollPanel", achievements)
	itemList:SetPos(5,5)
	itemList:SetSize(650-10, 535-5)

	table.sort(manolis.popcorn.achievements.achievements, function(a,b) return (a.progress or 0) < (b.progress or 0) end)
	for k,v in pairs(manolis.popcorn.achievements.achievements) do
		local item = vgui.Create("ManolisAchievementPanel")
		item:Go(k, v.name, v.description, v.aid, v.progress or 0, v.maxProgress)
		itemList:Add(item)
	end

	hook.Add("manolis:AchievementUpdate", "manolis:UpdateAchievement", function(ply,id,progress)
		for k,v in pairs(itemList:GetItems()) do
			if(v.aid == id) then
				v:SetProgress(progress)
			end
		end
	end)
end
vgui.Register( "manolisF4TabAchievements", PANEL, "DPanel" )