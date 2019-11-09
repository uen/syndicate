if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.power) then manolis.popcorn.power = {} end

hook.Add("CanTool", "manolis:EnablePower:Two", function(ply,tr,class)
	if(tr and tr.Entity and IsValid(tr.Entity) and (tr.Entity.isPowered or tr.Entity.isGenerator)) then
		if(class=='manolis_power') then
			return true
		end
	end

	if(tr and tr.Entity and IsValid(tr.Entity) and tr.Entity:GetClass()=='building_plug') then
		if(class=='manolis_power') then
			return true
		else
			return false
		end
	end
end)