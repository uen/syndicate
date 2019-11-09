local PANEL = {}


function split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        if(!inputstr) then return '' end
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end


function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(625,90)

	self.secondIcon = vgui.Create("DImage", self)
	self.secondIcon:SetPos(13+2,13+2)
	self.secondIcon:SetSize(62,62)

	self.icon = vgui.Create("DImage", self)
	self.icon:SetPos(13,13)
	self.icon:SetSize(62,62)

	self.name = vgui.Create("DLabel", self)
	self.name:SetPos(13+5+64+3, 13)
	self.name:SetFont('manolisItemInfoName')
	self.name:SetTextColor(Color(255, 255, 255, 255))



	self.level = vgui.Create("DLabel", self)
	self.level:SetPos(13+5+64+3, 10+20)
	self.level:SetFont("manolisButtonFontAlt")
	self.level:SetTextColor(Color(255, 255, 0, 255))
	self.level:SizeToContents()

	local kills = vgui.Create('DLabel', self)
	kills:SetPos(13+5+64+3, 47)
	kills:SetFont("manolisButtonFontAlt")
	kills:SetText("Rival Gangmembers Killed")
	kills:SizeToContents()
	kills:SetTextColor(Color(255, 255, 255, 255))

	self.kills = vgui.Create("DLabel", self)
	self.kills:SetPos(13+5+64+3, 60+2)
	self.kills:SetFont("manolisButtonFontAlt")
	self.kills:SetTextColor(Color(255,255,255,255))

	local stashes = vgui.Create("DLabel", self)
	stashes:SetPos(325,47+2)
	stashes:SetFont("manolisButtonFontAlt")
	stashes:SetText("Rival Stashes Stolen")
	stashes:SizeToContents()
	stashes:SetTextColor(Color(255,255,255,255))

	self.stashesLabel = stashes
	self.killsLabel = kills

	self.stashes = vgui.Create("DLabel", self)
	self.stashes:SetPos(325,60+3)
	self.stashes:SetFont("manolisButtonFontAlt")
	self.stashes:SetTextColor(Color(255,255,255,255))
	
	local buttonSize = 110
	self.truceButton = vgui.Create('ManolisButton', self)
	self.truceButton.Alternate = true
	self.truceButton:SetPos(625-buttonSize-5, 5)
	self.truceButton:SetSize(buttonSize,38)
	self.truceButton:SetText("Request Truce")

	self.mercyButton = vgui.Create('ManolisButton', self)
	self.mercyButton.Alternate = true
	self.mercyButton:SetPos(625-buttonSize-5, 5+38+4)
	self.mercyButton:SetSize(buttonSize,38)
	self.mercyButton:SetText("Beg For Mercy")




end

function PANEL:Alternative()
	self.mercyButton:Remove()
	self.truceButton:Remove()
	self.stashes:Remove()
	self.kills:Remove()

	self.addRival = vgui.Create("ManolisButton", self)
	self.addRival.Alternate = true
	self.addRival:SetPos(625-110-5-10, (90/2)-(self.addRival:GetTall()/2))
	self.addRival:SetText("Add Rival")

	self.stashesLabel:Remove()
	self.killsLabel:Remove()

	self.name:SetPos(13+5+64+5, 15+10+2)
	self.level:SetPos(13+5+64+5,10+20+2+10+2)


end

function PANEL:Alternative2()
	self.mercyButton:Remove()
	self.truceButton:Remove()
	self.stashes:Remove()
	self.kills:Remove()

	self.createGang = vgui.Create("ManolisButton", self)
	self.createGang.Alternate = true
	self.createGang:SetWide(120)
	self.createGang:SetPos(640-self.createGang:GetWide()-25, (90/2)-(self.createGang:GetTall()/2))
	self.createGang:SetText("Create Gang")
	self:SetWide(640)

	self.name:SetText("Gang Name")
	self.name:SetWide(350)

	self.level:SetText("Level 1")
	self.level:SizeToContents()

	self.stashesLabel:Remove()
	self.killsLabel:Remove()

	self.name:SetPos(13+5+64+5, 15+10+2)
	self.level:SetPos(13+5+64+5,10+20+2+10+2)
end

function PANEL:Other()

end

function PANEL:Invite(id, name, level,logo,c1,c2)
	self:Go(id,name,logo,c1,c2,level)

	self:Alternative()
	self.addRival:SetText("Join Gang")

	self.decline = vgui.Create("ManolisButton", self)
	self.decline.Alternate = true
	self.decline:SetPos(625-110-5-110-5, (90/2)-(self.addRival:GetTall()/2))
	self.decline:SetText("Decline Invite")

	self.name:SetText(name)
	self.level:SetText("Level "..level)
	self.name:SizeToContents()
	self.level:SizeToContents()
end

function PANEL:SetLogo(icon)
	self.icon:SetImage("manolis/popcorn/icons/gangs/"..icon..'.png')
	self.secondIcon:SetImage("manolis/popcorn/icons/gangs/"..icon..'.png')
end

function PANEL:SetFirstColor(color1)
	self.icon:SetImageColor(color1)
end
function PANEL:SetSecondColor(color2)
	self.secondIcon:SetImageColor(color2)
end

function PANEL:Go(id, name, icon, col1, col2, level, kills, stashes, truced)
	if(type(col1)!='table') then
		local c1 = split(col1, ',')
		local c2 = split(col2, ',')
		color1 = Color(c1[1], c1[2], c1[3])
		color2 = Color(c2[1], c2[2], c2[3])
	else
		color1 = col1
		color2 = col2
	end
	

	if(!icon) then
		return
	end

	self:SetLogo(icon)

	self.icon:SetImageColor(color1)
	self.secondIcon:SetImageColor(color2)
	if(kills) then
		self.kills:SetText(kills)
		self.kills:SizeToContents()
	end
	if(level) then
		self.level:SetText(DarkRP.getPhrase('level_standard',level))
		self.level:SizeToContents()
	end
	if(stashes) then
		self.stashes:SetText(stashes)
		self.stashes:SizeToContents()
	end
	self.truceButton.DoClick = function()
		if(truced!=1) then
			Manolis_Query(DarkRP.getPhrase('gang_truce_confirm', name), DarkRP.getPhrase('gang_truce_request_s'), DarkRP.getPhrase('confirm'), function() RunConsoleCommand("ManolisPopcornTruceGang",id, 1) end, DarkRP.getPhrase('cancel'), function() end)
		elseif(truced==1) then
			Manolis_Query(DarkRP.getPhrase('gang_truce_cancel_confirm',name), DarkRP.getPhrase('gang_truce_cancel_s'), DarkRP.getPhrase('confirm'), function() RunConsoleCommand("ManolisPopcornTruceGang",id, 0) end, DarkRP.getPhrase('cancel'), function() end)
		end
	end

	if(truced==2) then
		self.truceButton:SetText(DarkRP.getPhrase('gang_truce_1'))
	elseif(truced==1) then
		self.truceButton:SetText(DarkRP.getPhrase('gang_truce_2'))
	else
		self.truceButton:SetText(DarkRP.getPhrase('gang_truce_3'))
	end

	self.mercyButton.DoClick = function()
		local points =  math.max(0, 10+(100*manolis.popcorn.gangs.gang.info.level-level))
		Manolis_Query(DarkRP.getPhrase('gang_mercy_ask' ,points), DarkRP.getPhrase('gang_mercy_ask_s'), DarkRP.getPhrase('confirm'), function() RunConsoleCommand("ManolisPopcornMercyGang", id) end, DarkRP.getPhrase('cancel'), function() end)
	end

	self.name:SetText(name)
	self.name:SizeToContents()
end


function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	
	if(self.Hovered) then
		surface.SetDrawColor(35-1,40-1,48-1,255)
	end

	surface.DrawRect(0,0,w,h)

end

vgui.Register("ManolisRivalPanel", PANEL, "Panel")