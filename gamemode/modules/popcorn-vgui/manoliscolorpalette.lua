local PANEL = {}

local function AddButton( panel, color, size, id )

	local button = vgui.Create( "ManolisColorButton", panel )
	button:SetSize( size or 10, size or 10 )
	button:SetID( id )

	button:SetDrawBorder(false)

	--
	-- If the cookie value exists, then use it
	--
	local col_saved = panel:GetCookie( "col." .. id, nil )
	if ( col_saved != nil ) then
		color = col_saved:ToColor()
	end

	button:SetColor( color or color_Error )

	button.DoClick = function( self )
		local col = self:GetColor() or color_Error
		panel:OnValueChanged( col )
		panel:UpdateConVars( col )
		panel:DoClick( col, button )
	end

	button.DoRightClick = function( self )
		panel:OnRightClickButton( self )
	end

	return button

end

local function CreateColorTable( rows )

	local rows = 4
	local index = 0
	local ColorTable = {}

	for i = 0, rows * 2 - 1 do -- HSV
		local col = math.Round( math.min( i * ( 360 / ( rows * 2 ) ), 359 ) )
		index = index + 1
		ColorTable[index] = HSVToColor( 360 - col, 1, 1 )
	end

	for i = 0, rows - 1 do -- HSV dark
		local col = math.Round( math.min( i * ( 360 / rows ), 359 ) )
		index = index + 1
		ColorTable[index] = HSVToColor( 360 - col, 1, 0.5 )
	end

	for i = 0, rows - 1 do -- HSV grey
		local col = math.Round( math.min( i * ( 360 / rows ), 359 ) )
		index = index + 1
		ColorTable[index] = HSVToColor( 360 - col, 0.5, 0.5 )
	end

	for i = 0, rows - 1 do -- HSV bright
		local col = math.min( i * ( 360 / rows ), 359 )
		index = index + 1
		ColorTable[index] = HSVToColor( 360 - col, 0.5, 1 )
	end

	for i = 0, rows - 1 do -- Greyscale
		local white = 255 - math.Round( math.min( i * ( 256 / ( rows - 1 ) ), 255 ) )
		index = index + 1
		ColorTable[index] = Color( white, white, white )
	end

	return ColorTable

end

function PANEL:Init()
	self:SetSize( 80, 120 )
	self:SetNumRows( 8 )
	self:Reset()
	self:SetCookieName( "palette" )

	self:SetButtonSize( 10 )
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(39,44,56,255)
	surface.DrawRect(0,0,w,h)
end

function PANEL:Reset()
	self:SetColorButtons( CreateColorTable( self:GetNumRows() ) )
	return
end

function PANEL:SetColorButtons( tab )

	self:Clear()

	for i, color in pairs( tab or {} ) do

		local index = tonumber( i )
		if ( !index ) then break end

		AddButton( self, color, self.m_buttonsize, i )

	end

	self:InvalidateLayout()

	return

end

vgui.Register("ManolisColorPalette", PANEL, "DColorPalette")

local PANEL = {}
function PANEL:Paint( w, h )


	surface.SetDrawColor( self.m_Color )
	self:DrawFilledRect()

	return false
end

vgui.Register("ManolisColorButton", PANEL, "DColorButton")