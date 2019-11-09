surface.CreateFont("manolisHeaderFont", {
	font = "Calibri",
	size = 18,
	weight = 200,
})

include('manolisclosebutton.lua')
local PANEL = {}

function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 40)

	self.title = vgui.Create("DLabel", self)
	self.title:SetFont("manolisHeaderFont")
	self.title:SetPos(15,0)
	self.title:SetSize(self:GetWide()-40, 40)

	self.title:SetTextColor(Color(255,255,255,255))

	self.closeButton = vgui.Create("ManolisCloseButton", self)
	self.Dragging = nil
	self.closeButton:SetPos(self:GetWide()-40, 48-(16*2)-1)

	self.Draggable = true
end

function PANEL:Change()
	self.closeButton:SetPos(self:GetWide()-self.closeButton:GetWide()-10, 48-(16*2))
end

function PANEL:SetDraggable(x)
	self.Draggable = x
end

function PANEL:SetRealSize(w,h)
	self:SetSize(w,40)
	self.title:SetSize(w-40,40)
	self.closeButton:SetPos(w-30,48-(16*2))
end

function PANEL:OnMousePressed()
	self.Dragging = { gui.MouseX() - self.Base.x, gui.MouseY() - self.Base.y }
	self:MouseCapture( true )
	manolis.popcorn.zStack = manolis.popcorn.zStack + 1
	self.Base:SetZPos(manolis.popcorn.zStack+1)
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(28,31,38,255)
	surface.DrawRect(0,0,w,h)
end

function PANEL:OnMouseReleased()
	self.Dragging = nil
	self:MouseCapture( false )
end

function PANEL:Think()

	local mousex = math.Clamp( gui.MouseX(), 1, ScrW()-1 )
	local mousey = math.Clamp( gui.MouseY(), 1, ScrH()-1 )

	if ( self.Dragging ) then
		if(!self.Draggable) then return end

		local x = mousex - self.Dragging[1]
		local y = mousey - self.Dragging[2]

		x = math.Clamp( x, 0, ScrW() - self.Base:GetWide() )
		y = math.Clamp( y, 0, ScrH() - self.Base:GetTall() )


		self.Base:SetPos( x, y )

	end
end

function PANEL:SetText(text)
	self.title:SetText(text)


	surface.SetFont("manolisHeaderFont")
	local w,h = surface.GetTextSize(text)
	self.title:SetWide(w)


	self.title:SetTextColor(Color(255,255,255,255))
end
vgui.Register("ManolisHeader", PANEL, "Panel")