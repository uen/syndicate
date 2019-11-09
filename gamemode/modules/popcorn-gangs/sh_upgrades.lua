if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.gangs) then manolis.popcorn.gangs = {} end
if(!manolis.popcorn.gangs.upgrades) then manolis.popcorn.gangs.upgrades = {} end
if(!manolis.popcorn.gangs.upgrades.upgrades) then manolis.popcorn.gangs.upgrades.upgrades = {} end

manolis.popcorn.gangs.upgrades.AddUpgrade = function(upgrade)
	local n = {}
	n.name = upgrade.name or "Unknown"
	n.icon = upgrade.icon or ""
	n.prices = upgrade.prices or 1000
	n.description = upgrade.description or "Unknown upgrade"
	n.uiq = upgrade.uiq or "unknown"
	n.effect = upgrade.effect or {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
	n.effectStr = upgrade.effectStr or "% Unknown"
	manolis.popcorn.gangs.upgrades.upgrades[n.uiq] = n
end

