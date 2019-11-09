if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.don) then manolis.popcorn.don = {} end
if(!manolis.popcorn.don.gifts) then manolis.popcorn.don.gifts = {} end

manolis.popcorn.don.NewGift = function(name, price, description, slots, min, max)
	table.insert(manolis.popcorn.don.gifts, {name=name, price=price, description = description, slots = slots, min = min, max = max})
end

manolis.popcorn.don.GetGift = function(value)
	for k,v in ipairs(manolis.popcorn.don.gifts) do
		if (v.name == value) then
			return v
		end
	end
end

manolis.popcorn.don.GetGiftByKey = function(value)
	for k,v in ipairs(manolis.popcorn.don.gifts) do
		if (k == value) then
			return v
		end
	end
end

manolis.popcorn.don.CreateGiftHTML = function(t)
	local str = '<table class="itemTable">'
	for k,v in pairs(t) do
		local item = '<tr>'

		item = item..'<td>'
		item = item..'<img src="http://manolis.io/client/popcorn/icons/'..v.icon..'.png"></img>'
		item = item..'</td>'

		item = item..'<td class="padLeft">'
		item = item..v.quantity..'x '..v.name
		item = item..'</td>'

		item = item..'</tr>'

		str = str..item
	end

	str = str .. '</table>'
	return str
end

manolis.popcorn.don.NewGift(DarkRP.getPhrase('don_gift_beginners'), 0, DarkRP.getPhrase('don_gift_description')..manolis.popcorn.don.CreateGiftHTML({
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('rusty_mac10')), icon = "misc/blueprint", quantity = 1},
	{name = DarkRP.getPhrase('rein_stone'), icon = "materials/reinstone", quantity = 1},
	{name = DarkRP.getPhrase('crystal', DarkRP.getPhrase('obsidian')), icon = "materials/obsidian", quantity = 10},
	{name = DarkRP.getPhrase('crystal', DarkRP.getPhrase('amber')), icon = "materials/amber", quantity = 5},
	{name = DarkRP.getPhrase('crystal', DarkRP.getPhrase('bloodstone')), icon = "materials/bloodstone", quantity = 5},
}), 5,1,5)

manolis.popcorn.don.NewGift(DarkRP.getPhrase('don_gift_beginnerpack'), 0, DarkRP.getPhrase('don_gift_description')..manolis.popcorn.don.CreateGiftHTML({
	{name = DarkRP.getPhrase('rein_stone'), icon = "materials/reinstone", quantity = 5},
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('mac10')), icon = "misc/blueprint", quantity = 1},
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('mp5')), icon = "misc/blueprint", quantity = 1},
	{name = DarkRP.getPhrase('crystal', DarkRP.getPhrase('obsidian')), icon = "materials/obsidian", quantity = 10},
	{name = DarkRP.getPhrase('crystal', DarkRP.getPhrase('amber')), icon = "materials/amber", quantity = 5},
	{name = DarkRP.getPhrase('crystal', DarkRP.getPhrase('bloodstone')), icon = "materials/bloodstone", quantity = 5},
}),6,5,10)

manolis.popcorn.don.NewGift(DarkRP.getPhrase('don_gift_beginnersarmor'), 0, DarkRP.getPhrase('don_gift_description')..manolis.popcorn.don.CreateGiftHTML({
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('grey_beanie')), icon = "misc/blueprint", quantity = 1},
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('rebel_jacket')), icon = "misc/blueprint", quantity = 1},
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('rebel_pants')), icon = "misc/blueprint", quantity = 1},
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('combat_gloves')), icon = "misc/blueprint", quantity = 1},
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('m3')), icon = "misc/blueprint", quantity = 1},
	{name = DarkRP.getPhrase('rein_stone'), icon = "materials/reinstone", quantity = 5},
}),7,10,20)


manolis.popcorn.don.NewGift(DarkRP.getPhrase('don_gift_gang'), 0, DarkRP.getPhrase('don_gift_description')..manolis.popcorn.don.CreateGiftHTML({
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('famas')), icon = "misc/blueprint", quantity = 1},
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('cf05')), icon = "misc/blueprint", quantity = 1},
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('mp9')), icon = "misc/blueprint", quantity = 1},
	{name = DarkRP.getPhrase('rein_stone'), icon = "materials/reinstone", quantity = 5},
}),4,20,30)

manolis.popcorn.don.NewGift(DarkRP.getPhrase('don_gift_power'), 0, DarkRP.getPhrase('don_gift_description')..manolis.popcorn.don.CreateGiftHTML({
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('scout')), icon = "misc/blueprint", quantity = 1},
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('winchester')), icon = "misc/blueprint", quantity = 1},
	{name = DarkRP.getPhrase('rein_stone'), icon = "materials/reinstone", quantity = 5},
}),3,30,40)

manolis.popcorn.don.NewGift(DarkRP.getPhrase('don_gift_criminal'), 0, DarkRP.getPhrase('don_gift_description')..manolis.popcorn.don.CreateGiftHTML({
	{name = DarkRP.getPhrase('crystal', DarkRP.getPhrase('carbon_giga')), icon = "materials/carbon-giga", quantity = 2},
}),1,40,50)



manolis.popcorn.don.NewGift(DarkRP.getPhrase('don_gift_a', DarkRP.getPhrase('don_gift_basic'), DarkRP.getPhrase('upgrade_weapon')), 30000*5, DarkRP.getPhrase('don_gift_wupgrades', '5', '$30,000')..manolis.popcorn.don.CreateGiftHTML({
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('upgrade_b', DarkRP.getPhrase('upgrade_weapon'))), icon = "misc/blueprint", quantity = 5},
}),5,1,99)

manolis.popcorn.don.NewGift(DarkRP.getPhrase('don_gift_a', DarkRP.getPhrase('don_gift_advanced'), DarkRP.getPhrase('upgrade_weapon')), 50000*10, DarkRP.getPhrase('don_gift_wupgrades', 10, '$50,000')..manolis.popcorn.don.CreateGiftHTML({
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('upgrade_b', DarkRP.getPhrase('upgrade_weapon'))), icon = "misc/blueprint", quantity = 10},
}),10,20,99)


manolis.popcorn.don.NewGift(DarkRP.getPhrase('don_gift_a', DarkRP.getPhrase('don_gift_basic'), DarkRP.getPhrase('upgrade_armor')), 30000*5, DarkRP.getPhrase('don_gift_aupgrades', 5, '$30,000')..manolis.popcorn.don.CreateGiftHTML({
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('upgrade_b', DarkRP.getPhrase('upgrade_armor'))), icon = "misc/blueprint", quantity = 5},
}),5,1,99)

manolis.popcorn.don.NewGift(DarkRP.getPhrase('don_gift_a', DarkRP.getPhrase('don_gift_advanced'), DarkRP.getPhrase('upgrade_armor')), 50000*10, DarkRP.getPhrase('don_gift_aupgrades', 10, '$50,000')..manolis.popcorn.don.CreateGiftHTML({
	{name = DarkRP.getPhrase('blueprint', DarkRP.getPhrase('upgrade_b', DarkRP.getPhrase('upgrade_armor'))), icon = "misc/blueprint", quantity = 10},
}),10,20,99)


