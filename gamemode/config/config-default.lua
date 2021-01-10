// Copy this file to config.lua so it is not overridden every time you update!

if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.config) then manolis.popcorn.config = {} end

// Gang settings
manolis.popcorn.config.gangRivalCooldown = 24*5 // How many hours until a gang can be rivaled once it has begged for mercy
manolis.popcorn.config.maxGangLevel = 10 
manolis.popcorn.config.initialGangMaxMembers = 4
manolis.popcorn.config.xpPerPole = 100 // How much gang XP per pole
manolis.popcorn.config.xpTerritoryExtra = 500 // Extra gang XP for owning all poles in a territory
manolis.popcorn.config.capPoleTime = 15 // How long a gang territory pole takes to capture with 1 member
manolis.popcorn.config.gangCreateCost = 1000000 // How much it costs to create a gang
manolis.popcorn.config.territoryPlayers = 10 // How many players have to be connected before territoires can be capped
manolis.popcorn.config.gangPoleTime = 210 // How long it takes for gangs to get XP from captured territories
manolis.popcorn.config.gangPrinters = 6 // Max amount of gang printers


// Building settings
manolis.popcorn.config.capBuildingTime = 90 // How long it takes to capture a building
manolis.popcorn.config.buildingUpgrades = { // How much building upgrades cost
	power = {1000, 5000, 12000, 20000},
	lockpick = {1000, 2000, 5000, 1000}
}
manolis.popcorn.config.defaultRent = 100 // The default rent on buildings
manolis.popcorn.config.propertyTaxTime = 260 // How often to collect rent

manolis.popcorn.config.powerBuildingUpgradeAmount = {2,4,5,7,8} // How many appliances can be connected to a socket, depending on what upgrade the building has. No upgrade is 2, 1 upgrade is 4, ect
manolis.popcorn.config.maxPlugDistance = 250 // Max distance a plug can reach


// Printer settings
manolis.popcorn.config.maxPrinters = 4
manolis.popcorn.config.maxForges = 4
manolis.popcorn.config.maxBoosters = 12 // Max printer boosters that can be bought of a type
manolis.popcorn.config.maxAvailablePrinters = 10 // How many printers can a player have (not buy)
manolis.popcorn.config.maxXPCollect = 1800 // Max XP collected from a printer
manolis.popcorn.config.stolenPrinterMult = 1.6 // Multiplier for stolen printer XP
manolis.popcorn.config.stolenPrinterCount = 4 // How many times must you collect from a stolen printer for it to become yours
manolis.popcorn.config.printerTime = 120 // How often a printer prints
manolis.popcorn.config.printerHigherLevelAmount = 5 // How many levels below a printers level can you be to collect from it. Eg level 10 cannot collect from level 16 printer (if the value is 5). Do not have this over 5 for balance
manolis.popcorn.config.maxPrints = 4 // How much a printer can print and not be collected before stopping (how much it can hold?)
manolis.popcorn.config.printerSound = false // Disable printer noises?

// Quests
manolis.popcorn.config.questTime = 120 // How long before quests are refreshed
manolis.popcorn.config.questPlayers = 1 // How many players have to be connected before quests appear
manolis.popcorn.config.baseDefenseValue = fp{math.random,10000,75000}
manolis.popcorn.config.baseDefenseSetup = 120 // How long players have to build defenses on base defense quests
manolis.popcorn.config.baseDefenseTime = 360 // How long the defend part of base defense quests last

// Police Settings
manolis.popcorn.config.cpEvidenceDeletionTime = fp{math.random,60,120} // How long it takes for evidence to be destroyed. Random amount of seconds between 60 and 120 in this example
// Forge settings
manolis.popcorn.config.forgeTime = fp{math.random,10,15} // How often forges create materials. Random amount of seconds from 1 to 10 in this example

// Misc settings
manolis.popcorn.config.useBlurspace = true // Enable that cool blur effect on spawn (recommended)
manolis.popcorn.config.bulletForceMult = 1
manolis.popcorn.config.killXPLevel = 10 // What level to start awarding players for kills
manolis.popcorn.config.killXPLevelAmount = 5 // Amount of XP for killing is other players level * <this setting>
manolis.popcorn.config.killMoneyAmount = function(level) return level^2 end // How much money to give on kill
manolis.popcorn.config.takeMoneyKilled = true // Take money if the player is above level manolis.popcorn.config.killXPLevel and gets killed by a player
manolis.popcorn.config.demoteOnKill = true // When CPs kill innocents, are they demoted?
manolis.popcorn.config.murderEvidenceDrop = true // Drop evidence on death (not rival kill)
manolis.popcorn.config.gigaLuck = 0.2 // How much extra luck you get from carbon giga crystals
manolis.popcorn.config.Swagbagitems = 1 // Swag bag max items
manolis.popcorn.config.SwagbagProItems = 4 // Pro swag bag max items
manolis.popcorn.config.XPMult = 1 // XP Multiplier. 2 will make leveling twice as easy, 0.5 will make it twice as hard
manolis.popcorn.config.propLimit = 30 // Base prop limit
manolis.popcorn.config.maxTakedown = 9 // Max amount of takedown orbs that can be used on a single item
manolis.popcorn.config.disableThirdPerson = false // Disable third person (c and right click to go third person)
manolis.popcorn.config.damageMultiplier = 1 // Multiply all damage done by weapons by this amount
manolis.popcorn.config.ghostTimeModifier = function(time) return math.Clamp(time,20,300) end

manolis.popcorn.config.donateUrl = "http://http://syndicate.manolis.io/doku.php?id=players" // Your donation URL ( https://www.gmodstore.com/scripts/view/3915/syndicate-rpg-credit-shop )
manolis.popcorn.config.autoConnectPrinters = false // Automatically connect printers to sockets (realism)

// Terrorist
manolis.popcorn.config.bombRods = 1 // How many cores are required to set off the bomb
manolis.popcorn.config.bombEnrichTime = fp{math.random,4,10} // How long it takes to enrich a rod 1%
manolis.popcorn.config.bombDefuseTime = 5 // How long it takes to defuse the bomb
manolis.popcorn.config.bombExplosionTime = 20 // How many seconds it takes the bomb to explode after it has been activated


// Thief
manolis.popcorn.config.keypadCrackTime = 5 // How long it takes to crack a keypad
manolis.popcorn.config.proKeypadCrackTime = 2 // How long it takes to crack a keypad with the pro cracker

// HUD Settings
manolis.popcorn.config.hud = {		// Change any of these to false to disable the element
	compass			= true,			// Compass
	territoryInfo	= true,			// Beach - Enemy Territory 0/4
	xpBar 			= true,			// XP bar
	actionBar		= true,			// Action bar
	buildingText    = true,			// The text on the top of your screen when you go near a building

} 

manolis.popcorn.config.promColor = Color(255,255,0,255)

// Job settings
manolis.popcorn.config.policeHealthBoost = 25 // How much extra % HP police get
manolis.popcorn.config.bannedBuildingPurchase = {TEAM_POLICE2, TEAM_POLICECHIEF} // Which teams are banned from purchasing buildings or capturing them
manolis.popcorn.config.bannedPrinterUse = {TEAM_POLICE2, TEAM_POLICECHIEF}

// Armor config (it is recommended that you leave thse values)
manolis.popcorn.config.maxhealthBase = 1500 
manolis.popcorn.config.maxarmorBase = 1000
manolis.popcorn.config.maxhealthboostBase = 15
manolis.popcorn.config.maxarmorboostBase = 10
manolis.popcorn.config.maxspeedBase = 10
manolis.popcorn.config.maxfireresistBase = 20
manolis.popcorn.config.maxiceresistBase = 20

manolis.popcorn.config.maxbasedamageBase = 20
manolis.popcorn.config.maxaccuracyboostBase = 20
manolis.popcorn.config.maxxpBase = 10


// Other
manolis.popcorn.config.changeSky = false // Change sky to painted. Makes old maps less gloomy :)
manolis.popcorn.config.canEditServer = function(ply) return ply:IsSuperAdmin() end // Function that decides who can edit server stuff, buildings, territories, ect


// Developer only config
manolis.popcorn.config.hashFunc = util.CRC
manolis.popcorn.config.maxGangUpgrade = 10
manolis.popcorn.config.inventoryAddAllowed = {spawned_entity=true, spawned_weapon=true, spawned_shipment=true} 
manolis.popcorn.config.SwagbagWhitelist = {popcorn_printer=true, popcorn_forge=true}

