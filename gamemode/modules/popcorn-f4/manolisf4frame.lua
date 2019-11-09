local PANEL = {}
AddCSLuaFile()
AccessorFunc( PANEL, "m_bBackgroundBlur", 		"BackgroundBlur", 	FORCE_BOOL )
function PANEL:Refresh()
	if(self.tabPanels) then
		for k,v in pairs(self.tabPanels) do
			v.tabButton:Remove()
			v:Remove()
		end

		self.sidebar:RemoveAll()
	end

	self.tabPanels = {}

	if(manolis.popcorn.config.canEditServer(LocalPlayer())) then
		table.insert(manolis.popcorn.f4.Settings.Tabs,{
			name = DarkRP.getPhrase("admin"),
			panel = "manolisF4TabAdmin"
		})
	end


	for k,v in pairs(manolis.popcorn.f4.Settings.Tabs) do
		local panel = vgui.Create(v.panel, self.tabBase)
		if(IsValid(panel)) then
			panel:SetVisible(false)		

			local button = self.sidebar:AddTab(v.name)
			button.DoClick = function(b)
				button.active = true
				for k,v in pairs(self.tabPanels) do
					if(v==panel) then
						v:SetVisible(true)
						v.tabButton.active = true
						v.tabButton.depressed = true // Poor button :(
						v.tabButton:SetColor(Color(200,200,200,255))
					else
						if(v:IsVisible()) then
							v:SetVisible(false)
							v.tabButton.active = false
							v.tabButton.depressed = false
							v.tabButton:SetColor(Color(100,100,100,255))
						end
					end
				end
			end

			panel.tabButton = button

			table.insert(self.tabPanels, panel)
			if(#self.tabPanels == 1) then
				panel:SetVisible(true)
				button.depressed = true
				button.active = true
				button:SetColor(Color(200,200,200,255))
			end
		else
			ErrorNoHalt('ManolisF4: Tried to create panel of type `'..v.panel..'` but it does not exist\n')
		end
	end

end

function PANEL:Init()
	self:SetSize(200+650, 580)
	self:Center()

	self.header = vgui.Create("ManolisHeader", self)
	self.header:SetText(DarkRP.getPhrase('action_menu'))
	self.header:SetPos(0,0)
	self.header:Change()
	self.header.Base = self

	self.header.closeButton.DoClick = function()
		manolis.popcorn.f4.closeF4Menu()
	end


	self.sidebar = vgui.Create("ManolisF4Sidebar", self)
	self.sidebar:SetPos(0,40)

	self.tabBase = vgui.Create("Panel", self)
	self.tabBase:SetPos(200,40)
	self.tabBase:SetSize(650,580)

	self:Refresh()

	self:SetBackgroundBlur( true )
end

function PANEL:OnKeyCodePressed(code)
	if(code==95) then
		self.header.closeButton:DoClick()
	end
end

function PANEL:SetText(text)
	self.header:SetText(text)
end


function PANEL:Paint(w,h)

	if ( self.m_bBackgroundBlur and (FrameNumber() > manolis.popcorn.dermaBlurDrawn)) then
		manolis.popcorn.dermaBlurDrawn = FrameNumber()
		Manolis_DrawBackgroundBlur( self, self.m_fCreateTime )
	end

	surface.SetDrawColor(43,48,59, 255)
	surface.DrawRect(0,0, w, h)
end


vgui.Register("ManolisF4Frame", PANEL, "EditablePanel")