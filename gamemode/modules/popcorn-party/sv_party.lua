if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.party) then manolis.popcorn.party = {} end
if(!manolis.popcorn.party.parties) then manolis.popcorn.party.parties = {} end
if(!manolis.popcorn.party.isInParty) then manolis.popcorn.party.isInParty = {} end
if(!manolis.popcorn.party.hasInvite) then manolis.popcorn.party.hasInvite = {} end

local sendPartyUpdate = function(ply, party)
	net.Start("ManolisPopcornPartyUpdate")
		net.WriteTable(party)
	net.Send(ply)
end

local partyChat = function(ply,args)
	local DoSay = function(text)
		if(text=="") then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase("invalid_x", "argument", ""))
			return ""
		end

		local col = Color(0,240,20,255)
		local col2 = Color(255,255,255,255)

		if(manolis.popcorn.party.isInParty[ply]) then
			for p,l in pairs(manolis.popcorn.party.isInParty[ply].players) do
				DarkRP.talkToPerson(l,col, "("..DarkRP.getPhrase('party')..") "..ply:Name(), col2,text,ply)
			end
		else
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('you_not_in_party'))
		end

	end
	return args,DoSay
end

DarkRP.defineChatCommand('p', partyChat, true, 1.5)
DarkRP.defineChatCommand('party', partyChat, true, 1.5)

manolis.popcorn.party.AddToParty = function(ply,p2)
	if(!(IsValid(ply) or !IsValid(p2)) or ply==p2) then return false end

	if(manolis.popcorn.party.isInParty[ply]) then
		for k,v in pairs(manolis.popcorn.party.parties) do
			for a,b in pairs(v.players) do
				if(ply==b) then
					table.insert(v.players, p2)
					for z,x in pairs(v.players) do
						sendPartyUpdate(x, v)
					end

					manolis.popcorn.party.isInParty[p2] = v
					return
				end
			end
		end
	else
		local newParty = {}
		newParty.players = {}

		table.insert(newParty.players, ply)
		table.insert(newParty.players, p2)
		sendPartyUpdate(ply, newParty)
		sendPartyUpdate(p2, newParty)

		manolis.popcorn.party.isInParty[ply] = newParty
		manolis.popcorn.party.isInParty[p2] = newParty

		table.insert(manolis.popcorn.party.parties, newParty)
	end
end

local playerLeftParty = function(ply,cmd,args)
	if(!manolis.popcorn.party.isInParty[ply]) then
		if(cmd) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('you_not_in_party'))
		end
		return 
	else
		for k,v in pairs(manolis.popcorn.party.parties) do
			for a,b in ipairs(v.players) do
				if(b==ply) then
					manolis.popcorn.party.isInParty[ply] = false
					if(a==1) then
						if(#v.players>1) then
							table.remove(v.players, a)
							if(v.players[1] and IsValid(v.players[1])) then	
								DarkRP.notify(v.players[1],0,4,DarkRP.getPhrase('now_leader_of_party'))
							end
			
							for o,p in pairs(v.players) do
								sendPartyUpdate(ply, {})
							end		
						else	
							table.remove(manolis.popcorn.party.parties,k)
							for o,p in pairs(v.players) do
								sendPartyUpdate(ply, {})
							end		
						end
					else
						table.remove(v.players,a)
					end

					if(cmd) then
						DarkRP.notify(ply,0,4,DarkRP.getPhrase('you_left_party'))
						sendPartyUpdate(ply, {})
					end

					v.players[a] = nil

					for x,z in pairs(v.players) do
						sendPartyUpdate(z, v)
						DarkRP.notify(z, 0,4,DarkRP.getPhrase(has_left_party, ply:Nick()))
					end
					
					return
				end
			end
		end
	end
end

concommand.Add("ManolisPopcornLeaveParty", function(ply,cmd,args)
	playerLeftParty(ply,true)
end)

hook.Add("PlayerDisconnected", "manolisPartyDisconnectLeave", playerLeftParty)

concommand.Add("ManolisPopcornKickParty", function(ply,cmd,args)
	local player = DarkRP.findPlayer(args[1])
	if(player) then
		if(player==ply) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('cannot_kick_self'))
			return
		end

		if(manolis.popcorn.party.isInParty[ply] and manolis.popcorn.party.isInParty[player]) then
			local partyInLeader,partyInPlayer,ppId,pmId,partym,partyObj = 0,0,0,0,0

			for k,v in pairs(manolis.popcorn.party.parties) do
				for a,b in pairs(v.players) do
					if(ply==b) then
						if(a!=1) then
							DarkRP.notify(ply,1,4,DarkRP.getPhrase('only_leader_kick'))
							return
						end
						partyInLeader,ppId,partyObj = b,k,v
					end

					if(player==b) then
						partyInPlayer,partym,pmId = b,a,k
					end
				end
			end	

			if(pmId!=ppId) then
				return
			end

			DarkRP.notify(player,0,4,DarkRP.getPhrase('you_have_been_kicked_party', partyInLeader:Name()))

			sendPartyUpdate(player, {})
			partyObj.players[partym] = nil

			manolis.popcorn.party.isInParty[player] = false

			for k,v in pairs(partyObj.players) do
				sendPartyUpdate(v, partyObj)
				DarkRP.notify(v,0,4,DarkRP.getPhrase('has_been_kicked_party', player:Name(), partyInLeader:Name()))
			end		
		end
	end
end)

local addPartyPlayer = function(ply, newPlayer)
	if(ply==newPlayer) then
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('cannot_party_invite_self'))
		return
	end

	if(manolis.popcorn.party.isInParty[newPlayer]) then 
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('already_in_party', newPlayer:Nick()))
		return 
	end

	if(ply.isInParty) then
		for k,v in pairs(manolis.popcorn.party.parties) do
			for a,b in pairs(v.players) do
				if(ply==b) then
					if(a!=1) then
						DarkRP.notify(ply,1,4,DarkRP.getPhrase('only_party_leader_invite'))
						return
					end
				end
			end
		end
	end

	if(manolis.popcorn.party.hasInvite[newPlayer]) then
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('player_already_has_party_invite'))
		return
	end

	manolis.popcorn.party.hasInvite[newPlayer] = true
	DarkRP.notify(ply,0,4,DarkRP.getPhrase('invited_x_to_party', newPlayer:Name()))

	DarkRP.createQuestion(DarkRP.getPhrase('party_invite_question', ply:Name()), CurTime().."PartyRequest", newPlayer, 20, function(answer, ent, init, target, timeisup)
		manolis.popcorn.party.hasInvite[newPlayer] = false
		if(answer!=0) then
			manolis.popcorn.party.AddToParty(ply, newPlayer)
			DarkRP.notify(ply,0,4,DarkRP.getPhrase('party_invite_accepted', newPlayer:Name()))
			DarkRP.notify(newPlayer, 0,4,DarkRP.getPhrase('party_invite_join', ply:Name()))
		else
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('party_invite_decline', newPlayer:Name()))
		end
	end)
end

concommand.Add("ManolisPopcornAddParty", function(ply,cmd,args)
	if(!args[1]) then return false end
	local newPlayer = DarkRP.findPlayer(args[1])
	if(!IsValid(newPlayer) or !(newPlayer:IsPlayer() or newPlayer:IsBot())) then return false end
	addPartyPlayer(ply, newPlayer)
end)

DarkRP.defineChatCommand('partyinvite', function(ply, args)
	local tr = util.TraceLine(util.GetPlayerTrace(ply))
	if(!args[1]!='' and IsValid(tr.Entity) and tr.Entity:IsPlayer()) then
		addPartyPlayer(ply, tr.Entity)
		return ''
	else
		if(args[1]!='') then
   			local target = DarkRP.findPlayer(args[1])
   			if(target) then
   				addPartyPlayer(ply,target)
   				return ''
   			end
		end
	end

	DarkRP.notify(ply,1,4,DarkRP.getPhrase('player_notfound'))


	return ''
end, 1.5)