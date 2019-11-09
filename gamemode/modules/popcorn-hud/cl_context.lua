local PANEL = {}

AccessorFunc( PANEL, "m_bHangOpen", "HangOpen" )

function PANEL:Init()

	--
	-- This makes it so that when you're hovering over this panel
	-- you can `click` on the world. Your viewmodel will aim etc.
	--
	--self:SetWorldClicker( true )

	self.Canvas = vgui.Create( "DCategoryList", self )
	self.m_bHangOpen = false

	self:SetSize(ScrW(), ScrH()-200)

end

function PANEL:Open()

	self:SetHangOpen( false )

	-- If the spawn menu is open, try to close it..
	if ( g_SpawnMenu:IsVisible() ) then
		g_SpawnMenu:Close( true )
	end

	if ( self:IsVisible() ) then return end

	CloseDermaMenus()

	self:MakePopup()
	self:SetVisible( true )
	self:SetKeyboardInputEnabled( false )
	//self:SetMouseInputEnabled( true )

	RestoreCursorPosition()

	local bShouldShow = true

	-- TODO: Any situation in which we shouldn't show the tool menu on the context menu?

	-- Set up the active panel..
	if ( bShouldShow && IsValid( spawnmenu.ActiveControlPanel() ) ) then

		self.OldParent = spawnmenu.ActiveControlPanel():GetParent()
		self.OldPosX, self.OldPosY = spawnmenu.ActiveControlPanel():GetPos()
		spawnmenu.ActiveControlPanel():SetParent( self )
		self.Canvas:Clear()
		self.Canvas:AddItem( spawnmenu.ActiveControlPanel() )
		self.Canvas:Rebuild()
		self.Canvas:SetVisible( true )

	else

		self.Canvas:SetVisible( false )

	end

	self:InvalidateLayout( true )

end

function PANEL:Close( bSkipAnim )

	if ( self:GetHangOpen() ) then
		self:SetHangOpen( false )
		return
	end

	RememberCursorPosition()

	CloseDermaMenus()

	self:SetKeyboardInputEnabled( false )
	self:SetMouseInputEnabled( false )

	self:SetAlpha( 255 )
	self:SetVisible( false )
	self:RestoreControlPanel()

end

function PANEL:PerformLayout()

	if ( IsValid( spawnmenu.ActiveControlPanel() ) ) then

		spawnmenu.ActiveControlPanel():InvalidateLayout( true )

		local Tall = math.min( spawnmenu.ActiveControlPanel():GetTall() + 10, ScrH() * 0.8 )
		if ( self.Canvas:GetTall() != Tall ) then self.Canvas:SetTall( Tall ) end
		if ( self.Canvas:GetWide() != 320 ) then self.Canvas:SetWide( 320 ) end

		self.Canvas:SetPos( ScrW() - self.Canvas:GetWide() - 50, ScrH() - 50 - Tall )
		self.Canvas:InvalidateLayout( true )

	end

end

function PANEL:StartKeyFocus( pPanel )

	self:SetKeyboardInputEnabled( true )
	self:SetHangOpen( true )

end

function PANEL:EndKeyFocus( pPanel )

	self:SetKeyboardInputEnabled( false )

end

function PANEL:RestoreControlPanel()

	-- Restore the active panel
	if ( !spawnmenu.ActiveControlPanel() ) then return end
	if ( !self.OldParent ) then return end

	spawnmenu.ActiveControlPanel():SetParent( self.OldParent )
	spawnmenu.ActiveControlPanel():SetPos( self.OldPosX, self.OldPosY )

	self.OldParent = nil

end

--
-- Note here: EditablePanel is important! Child panels won't be able to get
-- keyboard input if it's a DPanel or a Panel. You need to either have an EditablePanel
-- or a DFrame (which is derived from EditablePanel) as your first panel attached to the system.
--
vgui.Register( "ContextMenu", PANEL, "EditablePanel" )