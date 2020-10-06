if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.items) then manolis.popcorn.items = {} end
if(!manolis.popcorn.items.boosters) then manolis.popcorn.items.boosters = {} end

// Printer Boosters:
// 1 -> Cooler
// 2 -> Rate Increase
// 3 -> Amount increase

manolis.popcorn.items.CreatePrinterBooster = function(boost)
	local n = {}
	n.name = boost.name
	n.cmd = boost.cmd
	n.time = boost.time
	n.range = boost.range
	n.type = boost.type or 1
	n.rate = boost.rate or 1
	n.price = boost.price or 1000
	n.level = boost.level or 1

	DarkRP.createEntity(n.name, {
		ent = "ent_cooler",
		name = n.name,
		model = "models/weapons/w_c4_planted.mdl",
		category = 'Money Printer Accessories',
		price = n.price,
		level = n.level,
		max = n.max or manolis.popcorn.config.maxBoosters or 12,
		cmd = "popcorncooler"..n.cmd,
		pTable = n
	})
end

manolis.popcorn.items.CreateMoneyPrinter = function(printer)
	local n = {}
	n.name = printer.name or "Unknown Money Printer"
	n.type = printer.type or ''
	n.money = printer.money or 10
	n.color = printer.color or Color(0,0,0,255)
	n.model = printer.model or 'models/props_lab/reciever01b.mdl'
	n.level = printer.level or 1
	n.price = printer.price or 10000
	n.customCheck = printer.customCheck or function() return true end

	DarkRP.createEntity(n.name, {
		ent = "popcorn_printer",
		name = n.name,
		model = n.model,
		category = 'Money Printers',
		price = n.price,
		customCheck = n.customCheck,
		level = n.level,
		getMax = function(ply) 
			if(ply.syndicateCreditShop.printIncrease) then
				local credit = manolis.popcorn.creditShop.findItem('print')
				if(credit) then
					return manolis.popcorn.config.maxPrinters + credit.affectLevels[ply.syndicateCreditShop.printIncrease]
				end
			end

			return manolis.popcorn.config.maxPrinters
		end,
		cmd = "popcorn"..n.type,
		pTable = n
	})
end


manolis.popcorn.items.CreateMaterialForge = function(forge)
	local n = {}
	n.name = forge.name or "Unknown Material"
	n.maxMaterials = forge.maxMaterials or 1
	n.type = forge.type
	n.model = forge.model or 'models/Items/BoxMRounds.mdl'
	n.level = forge.level or 1
	n.price = forge.price or 10000

	DarkRP.createEntity(n.name, {
		ent = "popcorn_forge",
		name = n.name,
		model = n.model,
		category = 'Material Forges',
		price = n.price,
		level = n.level,
		getMax = function(ply) 
			if(ply.syndicateCreditShop.forgeMaster) then
				local credit = manolis.popcorn.creditShop.findItem('forge')
				if(credit) then
					return manolis.popcorn.config.maxForges + credit.affectLevels[ply.syndicateCreditShop.forgeMaster]
				end
			end

			return manolis.popcorn.config.maxForges
		end,
		cmd = "popcorn"..n.type,
		pTable = n
	})
end