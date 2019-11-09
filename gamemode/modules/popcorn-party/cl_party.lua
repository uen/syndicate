if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.party) then manolis.popcorn.party = {} end
if(!manolis.popcorn.party.currentParty) then manolis.popcorn.party.currentParty = {} end

local partyPanel

manolis.popcorn.party.initiateParty = function()
	if(partyPanel) then partyPanel:Remove() end

	partyPanel = vgui.Create('ManolisPanel')
	partyPanel:SetSize(260,ScrH()-450)
	partyPanel:SetPos(5,250)
	partyPanel:SetVisible(true)

	for k,v in pairs(manolis.popcorn.party.currentParty.players) do
		local party = vgui.Create("ManolisPartyItem")
		party:SetPlayer(v)
		partyPanel:Add(party)
	end

	manolis.popcorn.party.panel = partyPanel
end

net.Receive("ManolisPopcornPartyUpdate", function()
	local party = net.ReadTable()
	if(!party or !party.players) then
		manolis.popcorn.party.currentParty = {}
		if(manolis.popcorn.party.panel and IsValid(manolis.popcorn.party.panel)) then
			manolis.popcorn.party.panel:Remove()
		end
	else
		manolis.popcorn.party.currentParty = party
		manolis.popcorn.party.initiateParty()
	end
end)

local partyChat = function(ply)
	return manolis.popcorn.party.isInParty[ply] or false
end

DarkRP.addChatReceiver("/p", "", partyChat)
DarkRP.addChatReceiver("/party", "", partyChat)


local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(250,50)
	self:SetText("")

	self.avatar = vgui.Create("AvatarImage", self)
	self.avatar:SetSize(40,40)
	self.avatar:SetPos(5,5)
	self.avatar:SetPlayer(LocalPlayer(),64)

	self.text = vgui.Create("DLabel", self)
	self.text:SetFont("manolisPartyNameBold")
	self.text:SetText(LocalPlayer():Name())
	self.text:SetPos(50, 15)
	self.text:SizeToContents()

	self.level = vgui.Create("DLabel", self)
	self.level:SetFont("manolisPartyNameBoldSmall")
	self.level:SetText("Level 1")
	self.level:SetPos(50,15+self.text:GetTall()-3)
	self.level:SizeToContents()

	self:SetZPos(9999)
end

function PANEL:SetPlayer(t)
	self.text:SetText(t:Nick())
	self.level:SetText("Level "..manolis.popcorn.levels.GetLevel(t))
	self.avatar:SetPlayer(t,64)
	self.text:SizeToContents()
	self.level:SizeToContents()
	self.player = t
end

function PANEL:Paint(w,h)
	if(!IsValid(self.player)) then self:Remove() end

	surface.SetDrawColor(35, 40, 48, 255)
	surface.DrawRect(0,0, w, h)
	
	surface.SetDrawColor(0,0,0,100)
	surface.DrawRect(50,5,(w-55),11)

	health = (self.player:Health() or 100) / (self.player:getDarkRPVar('maxhealth') or 100)
	
	surface.SetDrawColor(0,170,0,255)
	surface.DrawRect(50,5,(w-55)*health,11)
end

local options = {
	{
		label = DarkRP.getPhrase('kick'),
		callback = function(pl)
			RunConsoleCommand("ManolisPopcornKickParty", pl:Name())
		end
	},
	{
		label = DarkRP.getPhrase('start_trade'),
		callback = function(pl)
			RunConsoleCommand("ManolisPopcornStartTrade", pl:Name())
		end
	}
}

local selfOptions = {
	{
		label = DarkRP.getPhrase('leave_party'),
		callback = function(pl)
			RunConsoleCommand("ManolisPopcornLeaveParty")
		end
	}
}

function PANEL:OnMousePressed()
	self.Menu = ManolisMenu()
	self.Menu:SetPos(gui.MousePos())
	if(self.player == LocalPlayer()) then
		for k,v in pairs(selfOptions) do
			self.Menu:AddOption(v.label, function() v.callback(self.player) end)
		end
	else
		for k,v in pairs(options) do
			self.Menu:AddOption(v.label, function() v.callback(self.player) end)
		end	
	end
end

vgui.Register("ManolisPartyItem", PANEL, "ManolisButton")