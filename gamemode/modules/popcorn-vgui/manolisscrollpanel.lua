local PANEL = {}

function PANEL:Init()
	self.disableOutline = true
	self:SetSize(355,500-40)
	self:SetVisible(true)

	self.items = {}
	self.pickingUp = false
	self.a = 0

	local scrollBar = self:GetVBar()
	scrollBar.btnDown:Remove() 
	scrollBar.btnUp:Remove()
	scrollBar:SetWide(10)
	scrollBar.PerformLayout = function(self)
		local Wide = self:GetWide()
		local Scroll = self:GetScroll() / self.CanvasSize
		local BarSize = math.max( self:BarScale() * (self:GetTall()), 10 )
		local Track = self:GetTall() - BarSize
		Track = Track + 1
		
		Scroll = Scroll * Track
		
		self.btnGrip:SetPos( 0, Scroll )
		self.btnGrip:SetSize( Wide, BarSize )
	end

	scrollBar.SetUp = function( self, _barsize_, _canvassize_ )
		self.BarSize 	= _barsize_
		self.CanvasSize = math.max( _canvassize_ - _barsize_, 1 )

		self:SetEnabled( true )


		self:InvalidateLayout()
	end

	scrollBar.OnCursorMoved = function(self,x,y)
		if ( !self.Enabled ) then return end
		if ( !self.Dragging ) then return end

		local x = 0
		local y = gui.MouseY()
		local x, y = self:ScreenToLocal( x, y )
		
		y = y - self.HoldPos
		
		local TrackSize = self:GetTall() - self.btnGrip:GetTall()
		
		y = y / TrackSize
		
		self:SetScroll( y * self.CanvasSize )	
	end

	scrollBar.SetScroll = function(self, scrll)

		if ( !self.Enabled ) then self.Scroll = 0 return end

		
		self.Scroll = math.Clamp( scrll, 0, self.CanvasSize-1)
		if(self.CanvasSize > self.BarSize) then
			self.Scroll = math.Clamp( scrll, 0, self.CanvasSize )
		end
		
		self:InvalidateLayout()
		
		local func = self:GetParent().OnVScroll
		if ( func ) then
		
			func( self:GetParent(), self:GetOffset() )
		
		else
		
			self:GetParent():InvalidateLayout()
		
		end
	end
end

function PANEL:GetItems()
	return self.items
end

function PANEL:GetAmountOfItems()
	return #self.items
end

function PANEL:PerformLayout()

	local Wide = self:GetWide()
	local YPos = 0
	
	self:Rebuild()
	
	self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall()+5 )
	YPos = self.VBar:GetOffset()
		
	if ( self.VBar.Enabled ) then Wide = Wide - self.VBar:GetWide() end

	self.pnlCanvas:SetPos( 0, YPos )
	self.pnlCanvas:SetWide( Wide )
	
	self:Rebuild()
end

function PANEL:ClearPanel()
	self:Clear()
	self.a = 0

	for i,v in pairs(self.items) do
		self.items[i] = nil
	end
end

function PANEL:HideLast()
	self.a = self.a - 1
	self:Rebuild()
end

function PANEL:Paint(x,y)
	local scrollBar = self:GetVBar()

	scrollBar.Paint = function(self,w,h)
		surface.SetDrawColor(35,40,48,255)

		surface.DrawRect(0,0,w,h)
	end

	scrollBar.btnGrip.Paint = function(self,w,h)
		surface.SetDrawColor(43+10,48+10,59+10, 255)

		if(self.Hovered) then
			surface.SetDrawColor(43+12,48+12,59+12, 255)
		end
		surface.DrawRect(0,0,w,h)
	end
end

function PANEL:Refresh()
	self.a = 0
	for k,v in pairs(self.items) do
		v:SetParent(self)
		v:SetPos(0,self.a)
		self.a = self.a + v:GetTall()+5
	end
end

function PANEL:Add(item)
	item:SetParent(self)
	item:SetPos(0,self.a)
	self.a = self.a + item:GetTall()+5

	table.insert(self.items, item)
end

vgui.Register("ManolisScrollPanel", PANEL, "DScrollPanel")