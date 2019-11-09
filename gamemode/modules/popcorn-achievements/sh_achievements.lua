if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.achievements) then manolis.popcorn.achievements = {} end
if(!manolis.popcorn.achievements.achievements) then manolis.popcorn.achievements.achievements = {} end

manolis.popcorn.achievements.CreateAchievement = function(a)
	local n = {}
	n.name = a.name
	n.aid = a.aid
	a.description = a.description
	n.maxProgress = a.maxProgress
	n.rewardMoney = a.rewardMoney or 1000
	n.description = a.description or ''
	n.rewardXP = a.rewardXP or 100

	manolis.popcorn.achievements.achievements[n.aid] = n
end

manolis.popcorn.achievements.Find = function(aid)
	for k,v in pairs(manolis.popcorn.achievements.achievements) do
		if(v.aid == aid) then
			return v
		end
	end
end

hook.Add("manolis:PlayerLevelUp", "manolis:achievement:newbie", function(ply,level)
	if(level==10) then
		ply:AddAchievementProgress('newbie', 1)
	end
end)

//{{ user_id }}