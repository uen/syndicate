local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)

	self:SetFont("manolisItemInfoName")
	self:SetDrawBackground(false)
	self:SetTextColor(Color(255,255,255,255))
	self:SetTall(35)

end

function PANEL:Paint(w,h)
	surface.SetDrawColor(35, 40, 48, 255)
	surface.DrawRect(0,0,w,h)
	return false
end

function PANEL:OpenMenu( pControlOpener )

	if ( pControlOpener ) then
		if ( pControlOpener == self.TextEntry ) then
			return
		end
	end

	-- Don't do anything if there aren't any options..
	if ( #self.Choices == 0 ) then return end

	-- If the menu still exists and hasn't been deleted
	-- then just close it and don't open a new one.
	if ( IsValid( self.Menu ) ) then
		self.Menu:Remove()
		self.Menu = nil
	end

	self.Menu = ManolisMenu()

	local sorted = {}
	for k, v in pairs( self.Choices ) do table.insert( sorted, { id = k, data = v } ) end
	for k, v in SortedPairsByMemberValue( sorted, "data" ) do
		self.Menu:AddOption( v.data, function() self:ChooseOption( v.data, v.id ) end )
	end

	local x, y = self:LocalToScreen( 0, self:GetTall() )

	self.Menu:SetMinimumWidth( self:GetWide() )
	self.Menu:Open( x, y, false, self )

end

vgui.Register("ManolisComboBox", PANEL, "DComboBox")
