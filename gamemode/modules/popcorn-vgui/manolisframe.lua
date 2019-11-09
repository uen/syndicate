local PANEL = {}
AddCSLuaFile()
include('manolisheader.lua')

AccessorFunc( PANEL, "m_bBackgroundBlur", 		"BackgroundBlur", 	FORCE_BOOL )
AccessorFunc( PANEL, "m_bBackgroundBlurOverride", 		"BackgroundBlurOverride", 	FORCE_BOOL )

manolis.popcorn.zStack = 0
function PANEL:Init()
	self:Center()
	self:SetSize(620, 500)
	self.header = vgui.Create("ManolisHeader", self)
	self.header:SetText("")
	self.header:SetPos(0,0)
	self.header.Base = self

	self.header.closeButton.DoClick = function()
		self:Close()
		gui.EnableScreenClicker(false)
	end
	manolis.popcorn.zStack = manolis.popcorn.zStack + 1
	self:SetZPos(manolis.popcorn.zStack)
end

function PANEL:SetDraggable(x)
	self.header:SetDraggable(x)
end

function PANEL:ShowCloseButton(x)
	if(!x) then
		self.header.closeButton:Remove()
	end
end

function PANEL:SetTitle(text)
	self:SetText(text)
end

function PANEL:Close()
	self:SetVisible(false)
	self:Remove()
end

function PANEL:SetRealSize(w,h)
	self.header:SetRealSize(w,h)
	self:SetSize(w,h)
end


function PANEL:SetText(text)
	self.header:SetText(text)
end

function PANEL:Paint(w,h,x,y)
	if ((self.m_bBackgroundBlur and (FrameNumber() > manolis.popcorn.dermaBlurDrawn)) or (self.m_bBackgroundBlurOverride)) then
		if(!self.m_bBackgroundBlurOverride) then manolis.popcorn.dermaBlurDrawn = FrameNumber() end
		Manolis_DrawBackgroundBlur( self, self.m_fCreateTime )

		if(self.m_bBackgroundBlur) then
			Manolis_DrawBackgroundBlurOverride( self, self.m_fCreateTime )
		end
	end

	surface.SetDrawColor(35, 40, 48, 200)
	surface.DrawRect(0,0,w,h)

	surface.SetDrawColor(43,48,59, 255)
	surface.DrawRect(1,1, w-2, h-2)
end

vgui.Register("ManolisFrame", PANEL, "EditablePanel")