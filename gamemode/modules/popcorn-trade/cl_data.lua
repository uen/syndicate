if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.trade) then manolis.popcorn.trade = {} end

net.Receive("ManolisPopcornNewTrade", function(data)
	local ply = net.ReadEntity()
	local p2 = net.ReadEntity()

	local otherPlayer = (ply==LocalPlayer() and p2 or ply)

	manolis.popcorn.trade.newTrade()
	if(manolis.popcorn.trade.panel) then
		manolis.popcorn.trade.panel:SetText(DarkRP.getPhrase('trade_title',otherPlayer:Name()))
	end
end)

net.Receive("ManolisPopcornStopTrade", function(data)
	if(manolis.popcorn.trade.panel) then
		manolis.popcorn.trade.panel:Remove()
		manolis.popcorn.trade.panel = nil
	end
end)