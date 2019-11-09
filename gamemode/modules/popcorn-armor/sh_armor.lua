if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.armor) then manolis.popcorn.armor = {} end

local body,bottom,hands,head = 1,2,3,4
manolis.popcorn.armor.CanUpgrade = function(slot,upgrade)
	local allowed = {health={body=true,bottom=true},armor={body=true,bottom=true},healthboost={body=true,bottom=true},armorboost={body=true,bottom=true},speed={bottom=true},fireresist={body=true,bottom=true,hands=true,head=true},accuracyboost={hands=true}, basedamage={ring=true},iceresist={body=true,bottom=true,hands=true,head=true}}

	if(allowed[upgrade] and allowed[upgrade][slot]) then
		return true
	end
	return false
end