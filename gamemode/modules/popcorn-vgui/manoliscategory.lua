local PANEL = {}

local minimise = Material('manolis/popcorn/expand-button.png')
local expand = Material('manolis/popcorn/minimise-button.png')
function PANEL:Init()
	self:SetSize(650-25,36)

	local tab = vgui.Create("DLabel", self)
	tab:SetText("Misc")
	tab:SetPos(10,0)
	tab:SetFont("manolisF4ItemTab")
	tab:SizeToContents()
	tab:SetTall(35)
	tab:SetContentAlignment(4)
	
	

	self.matToUse = expand
	local expandButton = vgui.Create('DImageButton', self)
	expandButton.OnMousePressed = function(self,mousecode)
		DButton.OnMousePressed( self, mousecode )
		return
	end
	expandButton:SetMaterial(expand)
	expandButton:SetPos(self:GetWide()-23,13)
	expandButton:SetSize(10,10)
	self.expandButton = expandButton
	self.tab = tab

end

function PANEL:ToggleButton()
	if(self.matToUse==expand) then 
		self.matToUse = minimise 
	else
		self.matToUse = expand
	end

	self.expandButton:SetMaterial(self.matToUse)
end

function PANEL:Go(name)
	self.tab:SetText(name)
	self.tab:SizeToContents()
	self.tab:SetTall(35)
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(35,40,48,255)
	surface.DrawRect(0,0,w,h)
end



vgui.Register("ManolisCategory", PANEL, "Panel")