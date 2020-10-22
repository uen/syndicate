if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.trade) then manolis.popcorn.trade = {} end

local tradeFrame

manolis.popcorn.trade.newTrade = function()
	if(tradeFrame and IsValid(tradeFrame)) then tradeFrame:Remove() end

	tradeFrame = vgui.Create('ManolisFrame')
	tradeFrame:SetRealSize(403,469)
	tradeFrame:Center()
	tradeFrame:SetVisible(true)
	tradeFrame:SetBackgroundBlur(true)
	tradeFrame:SetText("")
	manolis.popcorn.inventory.open(tradeFrame)

	local cancelButton = vgui.Create("ManolisButton", tradeFrame)
	cancelButton:SetPos(0,40)
	cancelButton:SetText("Cancel")
	cancelButton.DoClick = function()
		Manolis_Query(DarkRP.getPhrase('trade_cancel_question'), DarkRP.getPhrase('confirm'), DarkRP.getPhrase('cancel'), function()
			return true
		end,DarkRP.getPhrase('yes'), function()
			net.Start("ManolisPopcornCancelTrade")
			net.SendToServer()
		end)
	end

	local moneyButton = vgui.Create("ManolisButton", tradeFrame)
	moneyButton:SetPos(1*101,40)
	moneyButton:SetText(DarkRP.getPhrase('trade_set_money'))
	moneyButton.DoClick = function()
		Manolis_StringRequest(DarkRP.getPhrase('trade_set_money'), DarkRP.getPhrase('trade_set_money_t'),0,DarkRP.getPhrase('confirm'), function(t)
			if(!tonumber(t)) then 
				return
			end

			local money = t		
			if(tonumber(money)>1000000000) then return end
			net.Start("ManolisPopcornSetMoneyTrade")
				net.WriteInt(tonumber(math.Round(money)), 32)
			net.SendToServer()
		end)
	end

	local lockButton = vgui.Create("ManolisButton", tradeFrame)
	lockButton:SetPos(2*101,40)
	lockButton:SetText(DarkRP.getPhrase('trade_lock'))
	lockButton.DoClick = function()
		local lock = false
		if(manolis.popcorn.trade.panel.youLocked.active) then
			lock = false
		else
			lock = true
		end

		net.Start("ManolisPopcornLockTrade")
			net.WriteBool(lock)
		net.SendToServer()
	end

	local tradeButton = vgui.Create("ManolisButton", tradeFrame)
	tradeButton:SetPos(3*101,40)
	tradeButton:SetText(DarkRP.getPhrase('trade_trade'))
	tradeButton.DoClick = function()
		net.Start("ManolisPopcornDoTrade")
		net.SendToServer()
	end

	local yourSlots = vgui.Create("ManolisSlots", tradeFrame, 'mainTrade')
	yourSlots:SetPos(0,40+40)
	yourSlots:SetSlots(5,2)
	for k,v in pairs(yourSlots.slot) do
		v.DroppedInto = function(self,t,previousParent)
			if(previousParent:GetParent() and previousParent:GetParent():GetName()=='mainInventory') then
				net.Start("ManolisPopcornAddItemToTrade")
					net.WriteInt(t.id,32)
				net.SendToServer()
				return 1				
			end

		end
	end
	tradeFrame.yourSlots = yourSlots

	local yourMoney = vgui.Create("DLabel", tradeFrame)
	yourMoney:SetFont("manolisTradeMoneyName")
	yourMoney:SetPos(10,40+40+(80*2)+5+2)
	yourMoney:SetText("$0")
	yourMoney:SetWide(200)
	tradeFrame.yourMoney = yourMoney

	local youLocked = vgui.Create("ManolisIndicator", tradeFrame)
	youLocked:SetPos(403-90-90-3-3, 40+40+(2*80)+3)
	tradeFrame.youLocked = youLocked

	local youTrade = vgui.Create("ManolisIndicator", tradeFrame)
	youTrade:SetPos(403-90-3, 40+40+(2*80)+3)
	tradeFrame.youTrade = youTrade

	local theirSlots = vgui.Create("ManolisSlots", tradeFrame, 'theirTrade')
	theirSlots:SetPos(0,40+40+(2*80)+3+30)
	theirSlots:SetSlots(5,2)
	tradeFrame.theirSlots = theirSlots

	local theirLocked = vgui.Create("ManolisIndicator", tradeFrame)
	theirLocked:SetPos(403-90-90-3-3, 40+40+(4*80)+3+30+3)
	tradeFrame.theirLocked = theirLocked

	local theirTrade = vgui.Create("ManolisIndicator", tradeFrame)
	theirTrade:SetPos(403-90-3, 40+40+(4*80)+3+30+3)
	tradeFrame.theirTrade = theirTrade

	local theirMoney = vgui.Create("DLabel", tradeFrame)
	theirMoney:SetFont("manolisTradeMoneyName")
	theirMoney:SetPos(10,40+40+(4*80)+3+30+3+3)
	theirMoney:SetText("$0")
	theirMoney:SetWide(200)
	tradeFrame.theirMoney = theirMoney

	tradeFrame.header.closeButton:Remove()
	gui.EnableScreenClicker(true)
	manolis.popcorn.trade.panel = tradeFrame
end

net.Receive("ManolisPopcornSetMoneyTrade", function(len)
	local player = net.ReadEntity()
	local money = net.ReadInt(32)
	if(manolis.popcorn.trade.panel) then
		if(player==LocalPlayer()) then
			manolis.popcorn.trade.panel.yourMoney:SetText(DarkRP.formatMoney(money))
		else
			manolis.popcorn.trade.panel.theirMoney:SetText(DarkRP.formatMoney(money))
		end
	end
end)

net.Receive("ManolisPopcornLockTrade", function(len)
	local player = net.ReadEntity()
	local bool = net.ReadBool()
	if(manolis.popcorn.trade.panel) then
		if(player==LocalPlayer()) then
			manolis.popcorn.trade.panel.youLocked.active = bool
		else
			manolis.popcorn.trade.panel.theirLocked.active = bool
		end
	end
end)

net.Receive("ManolisPopcornConfirmTrade", function(len)
	local player = net.ReadEntity()
	if(manolis.popcorn.trade.panel) then
		if(player==LocalPlayer()) then
			manolis.popcorn.trade.panel.youTrade.active = true
		else
			manolis.popcorn.trade.panel.theirTrade.active = true
		end
	end
end)

net.Receive("ManolisPopcornTradeUpdate", function(len)
	local player = net.ReadEntity()
	local items = net.ReadTable()
	if(manolis.popcorn.trade.panel) then
		if(player==LocalPlayer()) then
			manolis.popcorn.trade.panel.yourSlots:SetItems(items)
		else
			manolis.popcorn.trade.panel.theirSlots:SetItems(items)
		end
	end
end)