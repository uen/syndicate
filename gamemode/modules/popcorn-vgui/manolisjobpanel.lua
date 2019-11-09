local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(625,90)

	self.icon = vgui.Create("SpawnIcon", self)
	self.icon:SetPos(13,13)
	self.icon:SetSize(64,64)
	self.icon.PerformLayout = function(self)
		self.Icon:StretchToParent(0,0,0,0)
		return
	end

	self.icon.Paint = function()
		return
	end

	self.icon.PaintOver = function()
		return
	end

	self.icon:SetTooltip(false)

	local y = 7

	self.name = vgui.Create("DLabel", self)
	self.name:SetPos(13+5+64+3+5, 20+y)
	self.name:SetFont('manolisItemInfoName')
	self.name:SetTextColor(Color(255, 255, 255, 255))
	self.name:SetText(DarkRP.getPhrase('job_unknown'))
	self.name:SizeToContents()

	self.level = vgui.Create("DLabel", self)
	self.level:SetPos(13+10+64+3,20+17+y)
	self.level:SetFont('manolisItemInfoName')
	self.level:SetTextColor(Color(0,255,0,255))
	self.level:SetText(DarkRP.getPhrase('vgui_level2',0))
	self.level:SizeToContents()

	self.become = vgui.Create("ManolisButton", self)
	self.become.Alternate = true
	self.become:SetPos(625-110-20-10, (90/2)-(self.become:GetTall()/2))
	self.become:SetWide(25*5-5)
	self.become:SetText(DarkRP.getPhrase('vgui_error'))
end

function PANEL:Update(level)
	local levelColor = (level or 0 >= LocalPlayer():getDarkRPVar('level')) and Color(0,255,0,255) or Color(200,0,0,255)
	self.level:SetTextColor(levelColor)
end

function PANEL:Go(id, name, icon, level, cmd, vote)
	local nameStr = name
	self.name:SetText(nameStr)
	self.name:SizeToContents()

	local levelColor = manolis.popcorn.levels.HasLevel(LocalPlayer(), level) and Color(0,255,0,255) or Color(200,0,0,255)
	self.level:SetText(DarkRP.getPhrase('vgui_level2',level))
	self.level:SetTextColor(levelColor)
	self.level:SizeToContents()


	self.icon:SetModel(icon)
	self.icon:SetTooltip(false)


	if(vote) then
		self.become:SetText(DarkRP.getPhrase('create_vote'))
		self.become.DoClick = fn.Compose{manolis.popcorn.f4.closeF4Menu, fn.Partial(RunConsoleCommand, "DarkRP", "vote", cmd)}
	else
		self.become:SetText(DarkRP.getPhrase('change'))
		self.become.DoClick = fn.Compose{manolis.popcorn.f4.closeF4Menu, fn.Partial(RunConsoleCommand, "DarkRP", cmd)}

	end
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	
	if(self.Hovered) then
		surface.SetDrawColor(35+1,40+1,48+1,255)
	end

	surface.DrawRect(0,0,w,h)

end

vgui.Register("ManolisJobPanel", PANEL, "Panel")
