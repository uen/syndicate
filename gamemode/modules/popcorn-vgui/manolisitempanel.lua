local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(625,90)

	self.icon = vgui.Create("DImage", self)
	self.icon:SetPos(13,13)
	self.icon:SetSize(64,64)

	local y = 7

	self.name = vgui.Create("DLabel", self)
	self.name:SetPos(13+5+64+3+5, 20+y)
	self.name:SetFont('manolisItemInfoName')
	self.name:SetTextColor(Color(255, 255, 255, 255))
	self.name:SetText(DarkRP.getPhrase('vgui_unknown'))

	self.sText = vgui.Create("DLabel", self)
	self.sText:SetPos(13+5+64+3+5,20+17+y)
	self.sText:SetFont('manolisItemInfoName')
	self.sText:SetText('$0')


	self.doButton = vgui.Create("ManolisButton", self)
	self.doButton.Alternate = true
	self.doButton:SetPos(625-110-20-10, (90/2)-(self.doButton:GetTall()/2))
	self.doButton:SetWide(25*5-5)
	self.doButton:SetText("")

	self.buttons = {}
end

function PANEL:SetDescriptionColor(color)
	self.sText:SetColor(color)
end

function PANEL:SetModel(model)
	self.icon:Remove()

	self.icon = vgui.Create("SpawnIcon", self)
	self.icon:SetPos(13,13)
	self.icon:SetSize(64,64)

	self.icon.Paint = function(self,w,h)
		return
	end

	self.icon.PaintOver = function()
		return
	end

	self.icon.PerformLayout = function(self)
		self.Icon:StretchToParent(0,0,0,0)
		return
	end

	self.icon:SetTooltip(false)
	self.icon:SetModel(model)
end


function PANEL:Go(id, name, icon, sText, buttonText,bF)
	local nameStr = name

	self.name:SetText(nameStr)
	self.name:SizeToContents()

	self.sText:SetText(sText)
	self.sText:SizeToContents()

	self.icon:SetMaterial(icon)
	self.icon:SetTooltip(false)

	if(type(buttonText)=='table') then
		self.doButton:Remove()
		for k,v in pairs(buttonText) do
			surface.SetFont('manolisButtonFont')
			local w,h = surface.GetTextSize(v.label)

			local button = vgui.Create("ManolisButton", self)
			button.Alternate = true
			button:SetWide(math.max(101, w+15))
			button:SetPos(625-10 - (k*button:GetWide())-(k*10), (90/2)-(button:GetTall()/2))
			button:SetText(v.label)
			button.DoClick = v.DoClick

			table.insert(self.buttons, button)
		end
	else

		self.doButton:SetText(buttonText)

		self.doButton.DoClick = bF 
	end
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	
	if(self.Hovered) then
		surface.SetDrawColor(35+1,40+1,48+1,255)
	end
	
	surface.DrawRect(0,0,w,h)
end

vgui.Register("ManolisItemPanel", PANEL, "Panel")
