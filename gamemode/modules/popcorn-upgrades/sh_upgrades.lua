if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.upgrades) then manolis.popcorn.upgrades = {} end
if(!manolis.popcorn.upgrades.upgrades) then manolis.popcorn.upgrades.upgrades = {} end
if(!manolis.popcorn.crafting) then manolis.popcorn.crafting = {} end
if(!manolis.popcorn.crafting.blueprints) then manolis.popcorn.crafting.blueprints = {} end

manolis.popcorn.upgrades.add = function(upgrade)
	if(!manolis.popcorn.upgrades.upgrades[upgrade.type]) then manolis.popcorn.upgrades.upgrades[upgrade.type] = {} end
	manolis.popcorn.upgrades.upgrades[upgrade.type][upgrade.class] = upgrade
end

manolis.popcorn.upgrades.FindUpgrade = function(type, class, level)
	if(!manolis.popcorn.upgrades.upgrades[type]) then return false end
	local upgrade = manolis.popcorn.upgrades.upgrades[type][class]
	if(!upgrade) then return false end
	local u = {}
	u.name = 'Level '..level..' '..upgrade.name..' upgrade'
	u.icon = manolis.popcorn.upgrades.GetUpgradeIcon(upgrade.type, class,level)
	u.type = 'upgrade'
	u.value = level*10000
	u.entity = 'manolis_popcorn_upgrade'
	u.json = table.Copy(upgrade)
	u.json.levels = nil
	u.json.levelsString = nil
	u.json.level = level

	return u
end

manolis.popcorn.upgrades.GetUpgradeIcon = function(type, class,level)
	return "upgrades/"..type..'-'..class..'-'..level..'.png'
end