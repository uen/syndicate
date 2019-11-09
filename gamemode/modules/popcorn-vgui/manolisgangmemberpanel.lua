local PANEL = {}


function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(625,90)

	self.icon = vgui.Create("AvatarImage", self)
	self.icon:SetPos(13,13)
	self.icon:SetSize(64,64)

	self.icon.Paint = function()
		return
	end

	self.icon.PaintOver = function()
		return
	end

	self.icon.PerformLayout = function(self)

		return
	end


	local y = 7

	self.name = vgui.Create("DLabel", self)
	self.name:SetPos(13+64+13, 20+y)
	self.name:SetFont('manolisItemInfoName')
	self.name:SetTextColor(Color(255, 255, 255, 255))
	self.name:SetText('')

	self.rank = vgui.Create("DLabel", self)
	self.rank:SetPos(13+64+13,20+17+y)
	self.rank:SetFont('manolisItemInfoName')
	self.rank:SetTextColor(Color(0,255,0,255))
	self.rank:SetText('$0')


	self.purchase = vgui.Create("ManolisButton", self)
	self.purchase.Alternate = true
	self.purchase:SetPos(625-110-20-10, (90/2)-(self.purchase:GetTall()/2))
	self.purchase:SetWide(25*5-5)
	self.purchase:SetText(DarkRP.getPhrase('actions'))

	self.pMenu = nil
end


function PANEL:Go(name, uid, rank, cmd)
	local nameStr = name

	self.name:SetText(nameStr or '')
	self.name:SizeToContents()

	self.rank:SetText(rank or '')
	self.rank:SizeToContents()

	self.icon:SetSteamID(uid,184)
	self.steam = uid

	if(self.pMenu) then self.pMenu:Remove() end

	self.purchase.DoClick = function()
		self.pMenu = ManolisMenu()
		local x,y = gui.MousePos()
		self.pMenu:SetPos(x,y)

		local ranks = {
			{id = 1, name = DarkRP.getPhrase("leader")},
			{id = 2, name = DarkRP.getPhrase("coleader")},
			{id = 3, name = DarkRP.getPhrase("captain")},
			{id = 4, name= DarkRP.getPhrase("soldier")},
			{id = 5, name = DarkRP.getPhrase("recruit")}
		}

		for k,v in pairs(ranks) do
			self.pMenu:AddOption(DarkRP.getPhrase('set_to', v.name), function() RunConsoleCommand("ManolisPopcornGangPromote", uid, v.id) end)
		end
		
		self.pMenu:AddSpacer()
		self.pMenu:AddOption('Kick from Gang', function() 
			Manolis_Query(DarkRP.getPhrase('gang_kick_confirm', name), DarkRP.getPhrase('confirm'), DarkRP.getPhrase('gang_kick_kick'), function() RunConsoleCommand("ManolisPopcornGangKick", uid) end, DarkRP.getPhrase('cancel'))
		end)
	end
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	
	if(self.Hovered) then
		surface.SetDrawColor(35+1,40+1,48+1,255)
	end

	surface.DrawRect(0,0,w,h)
end

vgui.Register("ManolisGangMemberPanel", PANEL, "Panel")