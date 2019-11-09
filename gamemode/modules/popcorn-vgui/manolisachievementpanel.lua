local PANEL = {}


function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(625,90)

	local p = vgui.Create('Panel',self)
	p:SetPos(13,13)
	p:SetSize(64,64)

	self.icon = vgui.Create("DImage", p)
	self.icon:SetPos(4,4)
	self.icon:SetSize(56,56)

	
	local y = 14

	self.name = vgui.Create("DLabel", self)
	self.name:SetPos(13+5+64+3+5, y)
	self.name:SetFont('manolisItemInfoName')
	self.name:SetTextColor(Color(255, 255, 255, 255))
	self.name:SetText(DarkRP.getPhrase('vgui_unknown'))

	y=y+self.name:GetTall()-3
	self.description = vgui.Create("DLabel", self)
	self.description:SetPos(13+5+64+3+5,y)
	self.description:SetFont('manolisItemInfoName')
	self.description:SetText(DarkRP.formatMoney(0))

	y=y+self.description:GetTall()+2

	local achievementBar = vgui.Create("Panel", self)
	achievementBar:SetSize(625-13-13-64-13, 20)
	achievementBar:SetPos(13+5+64+3+5,y)
	achievementBar.progress = 0
	achievementBar.maxProgress = 1
	achievementBar.SetProgress = function(self, a)
		self.progress = a
		achievementBar.label:SetRealText(string.Comma(a).." / "..string.Comma(string.Comma(self.maxProgress)))
	end

	achievementBar.SetMaxProgress = function(self,a)
		self.maxProgress = a
		achievementBar.label:SetRealText(string.Comma(self.progress).." / "..string.Comma(a))
	end

	achievementBar.Paint = function(self,w,h)
		surface.SetDrawColor(43,48,59, 255)
		surface.DrawRect(0,0,w,h)
			
		surface.SetDrawColor(43+10,48+10,59+10, 255)

		surface.DrawRect(0,0,(self.progress/self.maxProgress) *w,h)
	end

	achievementBar.label = vgui.Create("DLabel", achievementBar)
	achievementBar.label:SetPos(0, 0)
	achievementBar.label:SetSize(625-13-13-64-13, 20)
	achievementBar.label.SetRealText = function(self,a)
		self:SetText(a)
	end

	achievementBar.label:SetRealText(string.Comma(achievementBar.progress).." / "..string.Comma(string.Comma(achievementBar.maxProgress)))
	achievementBar.label:SetFont("ManolisXPFontGang")
	achievementBar.label:SetTextColor(Color(255,255,255,255))
	achievementBar.label:SetContentAlignment(5)

	self.achievementBar = achievementBar
end

function PANEL:SetProgress(progress)
	self.achievementBar:SetProgress(progress)
end

function PANEL:Go(id, name, desc, aid, progress, maxprogress)
	self.aid = aid
	local nameStr = name

	self.achievementBar:SetProgress(progress)
	self.achievementBar:SetMaxProgress(maxprogress)
	
	self.icon:SetMaterial(Material('manolis/popcorn/icons/achievements/'..self.aid..'.png'))
	self.icon:SetTooltip(false)

	self.name:SetText(name)
	self.name:SizeToContents()

	self.description:SetText(desc or "")
	self.description:SizeToContents()
end


function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	if(self.Hovered) then
		surface.SetDrawColor(35+1,40+1,48+1,255)
	end
	surface.DrawRect(0,0,w,h)
end

vgui.Register("ManolisAchievementPanel", PANEL, "Panel")
