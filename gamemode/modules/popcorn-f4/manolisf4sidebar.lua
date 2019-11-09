local PANEL = {}
AddCSLuaFile()

local tabs = {}
local textTransparency = 150
function PANEL:Init()
	self:SetSize(200, 580)
	self.tabs = vgui.Create("Panel", self)
	self.tabs:SetSize(200,480)
	self.tabs:SetPos(0,75)
	self.tabs.Paint = function(self, w,h)
		surface.SetDrawColor(35, 40, 48, 255)
		surface.DrawRect(0,0,w,h)
	end

	self.heading = vgui.Create("DImage", self)
	self.heading:SetPos(0,0)
	self.heading:SetSize(200,75)

/*	self.heading.Paint = function(self,w,h)
		surface.SetDrawColor(Color( 52, 152, 219,255 ))
		surface.DrawRect(0,0,w,h)
	end
*/	
	self.heading:SetImage("manolis/popcorn/logo-sm.png")

end
 
function PANEL:RemoveAll()
	for k,v in pairs(tabs) do
		v:Remove()
	end

	tabs = {}
end

function PANEL:AddTab(name)
	local tab = vgui.Create("ManolisF4Button", self.tabs)
	tab.F4 = true
	tab:SetSize(200, 50)
	tab:SetPos(0,(#tabs*50))
	tab:SetText(string.upper(name))
	tab:SetFont("manolisF4ButtonFont")
	table.insert(tabs,tab)

	return tab
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	surface.DrawRect(0,0, w, h)
end


vgui.Register("ManolisF4Sidebar", PANEL, "Panel")