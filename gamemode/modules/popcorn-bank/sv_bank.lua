if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.bank) then manolis.popcorn.bank = {} end

manolis.popcorn.bank.changeItemSlot = function(ply,id,slot,callback)
	manolis.popcorn.bank.retrieveSingleItemData(ply, id, function(item)
		if(item) then
			manolis.popcorn.bank.isSlotFreeData(ply, slot, function(data)
				if(data) then
					manolis.popcorn.bank.ChangeSlotData(ply,id,slot,function(data)
						callback()
					end)
				else
					callback()
				end
			end)
		else
			callback()
		end
	end)
end

concommand.Add("ManolisPopcornChangeBankItemSlot", function(ply,cmd,args)
	if(ply.isCrafting) then return false end
	if(!args[1] or !args[2]) then return false end
	if(!tonumber(args[2])) then return false end
	if(!tonumber(args[1])) then return false end
	args[1] = math.floor(args[1])
	args[2] = math.floor(args[2])
	args[2] = math.Round(tonumber(args[2]))

	if(args[2]>(6*6) or args[2]<=0) then return false end
	ply.isCrafting = true

	manolis.popcorn.bank.changeItemSlot(ply,args[1], args[2], function()
		ply.isCrafting = false
	end)
end)


concommand.Add("ManolisPopcornMoveItemToBank", function(ply,c,args)
	if(ply.isCrafting) then
		ply:RefreshInventory()
		ply:RefreshBank()
		return
	end
	if(!args[1] or !args[2]) then return false end
	if(!tonumber(args[2])) then return false end
	if(!tonumber(args[1])) then return false end
	args[1] = math.floor(args[1])
	args[2] = math.floor(args[2])
	args[2] = math.Round(tonumber(args[2]))
	if(args[2]>(6*6) or args[2]<=0) then return false end

	ply.isCrafting = true

	manolis.popcorn.bank.AddItemToBank(ply,args[1],args[2],function()
		ply.isCrafting = false
		ply:RefreshBank()
	end)
end)	

concommand.Add("ManolisPopcornMoveItemToInventoryFromBank", function(ply,c,args)
	if(ply.isCrafting) then
		ply:RefreshInventory()
		ply:RefreshBank()
		return
	end
	if(!args[1] or !args[2] or !args[3]) then return false end
	if(!tonumber(args[2])) then return false end
	if(!tonumber(args[1])) then return false end
	if(!tonumber(args[3])) then return false end
	args[1] = math.floor(args[1])
	args[2] = math.floor(args[2])
	args[2] = math.Round(tonumber(args[2]))
	args[3] = math.Round(tonumber(args[3]))
	if(args[1]<0 or args[2]>4 or args[2]<1 or args[3]<1 or args[3]>(5*4)) then return false end

	ply.isCrafting = true
	manolis.popcorn.bank.AddItemToInventory(ply,args[1],args[2],args[3], function()
		ply.isCrafting = false
	end)
end)	


local function sendBankRefresh(ply, items)
	if(!(ply.lastBankRefresh>(CurTime()+.1))) then
		ply.lastBankRefresh = CurTime()
		net.Start('ManolisPopcornBankFullRefresh')
			net.WriteTable(items)
		net.Send(ply)
	end
end

hook.Add("PlayerInitialSpawn", "manolis:popcorn:InitialSpawnPly", function(ply)
	ply.lastBankRefresh = 0
	timer.Simple(.5, function()
		ply:RefreshBank()
	end)
end)

concommand.Add('refreshManolisPopcornBank', function(ply)
	if(!(ply.lastBankRefresh>(CurTime()+.1))) then
		ply:RefreshBank()
	end
end,nil,'Refreshes your bank')

local meta = FindMetaTable("Player")
function meta:RefreshBank()
	manolis.popcorn.bank.retrievePlayerItems(self, function(items)
		sendBankRefresh(self,items)
	end)
end