local function DrawCircle( x, y, radius, seg ) // Thanks whoever wrote this
    local cir = {}
    table.insert( cir, { x = x, y = y } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius } )
    end
    local a = math.rad( 0 )
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius } )
    surface.DrawPoly( cir )
end

local PANEL = {}

function PANEL:Init()
    self.avatar = vgui.Create( "AvatarImage", self )
    self.avatar:SetPaintedManually( true )
end

function PANEL:PerformLayout()
    self.avatar:SetSize( self:GetWide(), self:GetTall() )
end

function PANEL:SetPlayer( ply, size )
    self.avatar:SetPlayer( ply, size )
end

function PANEL:Paint( w, h )
    render.ClearStencil()
    render.SetStencilEnable( true )

    render.SetStencilWriteMask( 1 )
    render.SetStencilTestMask( 1 )

    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
    render.SetStencilPassOperation( STENCILOPERATION_ZERO )
    render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
    render.SetStencilReferenceValue( 1 )

    draw.NoTexture()
    surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
    DrawCircle( w/2, h/2, h/2, math.max(w,h)/2 )

    render.SetStencilFailOperation( STENCILOPERATION_ZERO )
    render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
    render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
    render.SetStencilReferenceValue( 1 )

    self.avatar:PaintManual()

    render.SetStencilEnable( false )
    render.ClearStencil()
    
end
 
vgui.Register( "ManolisAvatar", PANEL )