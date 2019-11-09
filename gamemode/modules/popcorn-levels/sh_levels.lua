if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.levels) then manolis.popcorn.levels = {} end

local meta = FindMetaTable("Player")

manolis.popcorn.levels.GetMaxXP = function(level)
	return 250 + ( (level or 1)^2 ) * 250
end

manolis.popcorn.levels.HasLevel = function(ply, level)
	if( !IsValid(ply) ) then
		return false
	else
		return ( ( manolis.popcorn.levels.GetLevel(ply) ) >= tonumber(level) )
	end
end

manolis.popcorn.levels.GetLevel = function(ply)
	if( !IsValid(ply) ) then
		return 1
	else
		return math.floor(tonumber(ply:getDarkRPVar('level') or 1)) or 1
	end
end

manolis.popcorn.levels.GetXP = function(ply)
	if( !IsValid(ply) ) then
		return 1
	else
		return math.floor(tonumber(ply:getDarkRPVar('xp') or 0)) or 0
	end	
end

meta.GetXPFrac = function(self)
	return self:GetXP() / manolis.popcorn.levels.GetMaxXP(self:GetLevel())
end

meta.GetLevel = function(self)
	return manolis.popcorn.levels.GetLevel(self)
end

meta.GetXP = function(self)
	return manolis.popcorn.levels.GetXP(self)
end