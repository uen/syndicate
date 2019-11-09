if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.hud) then manolis.popcorn.hud = {} end

if(!manolis.popcorn.hud.quickBuyCache) then manolis.popcorn.hud.quickBuyCache = {} end

hook.Add("PlayerInitialSpawn", "manolis:SpawnFManis", function(ply)
	manolis.popcorn.hud.quickBuyCache[ply:UniqueID()] = {}
	MySQLite.query("SELECT slot,cmd,mdl FROM manolis_popcorn_quickbuy WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()), function(data)
		if(data) then
			local t = {}
			for k,v in pairs(data) do
				t[v.slot] = {command=v.cmd, mdl=v.mdl}
			end
			manolis.popcorn.hud.quickBuyCache[ply:UniqueID()] = t
			timer.Simple(5, function()
				net.Start('ManolisPopcornQuickBuy')
					net.WriteTable(t)
				net.Send(ply)
			end)
		end
	end)
end)

concommand.Add("ManolisRemoveQuickBuy", function(ply,cmd,args)
	if(ply.lastQuick+1>CurTime()) then return false end
	ply.lastQuick = CurTime()
	if(IsValid(ply)) then
		local slot = tonumber(args[1])
		if(slot and slot>0 and slot <= 7) then 
			manolis.popcorn.hud.quickBuyCache[ply:UniqueID()][slot] = false
			net.Start('ManolisPopcornQuickBuy')
				net.WriteTable(manolis.popcorn.hud.quickBuyCache[ply:UniqueID()])
			net.Send(ply)
			MySQLite.query("DELETE FROM manolis_popcorn_quickbuy WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()).." AND slot = "..MySQLite.SQLStr(slot))
		end
	end
end)

local meta = FindMetaTable('Player')
meta.lastQuick = 0
concommand.Add("ManolisAddQuickBuy",function(ply,cmd,args)
	if(ply.lastQuick+1>CurTime()) then return false end
	ply.lastQuick = CurTime()
	local model = args[1]
	local slot = args[2]
	local cmd = args[3]
	if(!tonumber(slot) or (tonumber(slot)>7) or (tonumber(slot)<0)) then return end
	slot = math.Round(slot) + 1
	if(!cmd or !model) then return end
	manolis.popcorn.hud.quickBuyCache[ply:UniqueID()][slot] = {command=cmd,mdl=model}
	MySQLite.query("INSERT INTO manolis_popcorn_quickbuy(uid,slot,cmd,mdl) VALUES("..MySQLite.SQLStr(ply:SteamID64())..","..MySQLite.SQLStr(slot)..","..MySQLite.SQLStr(cmd)..","..MySQLite.SQLStr(model)..")")
	net.Start('ManolisPopcornQuickBuy')
		net.WriteTable(manolis.popcorn.hud.quickBuyCache[ply:UniqueID()])
	net.Send(ply)
end)

