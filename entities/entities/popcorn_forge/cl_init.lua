include("shared.lua")

ENT.DisplayTextColor = Color( 255, 0, 0, 255 )
ENT.DisplayBarColor = Color( 0, 255, 0, 255 )
ENT.DisplayBarBGColor = Color( 20, 20, 20, 200 )
ENT.displayTimer = 0

local material = Material( "cable/physbeam" )
ENT.OldProg = 0
ENT.Bars = {}

function ENT:Draw()
	self:DrawModel()

	local newAngle = self:GetAngles()
	newAngle:RotateAroundAxis( newAngle:Forward(), 90 )
	newAngle:RotateAroundAxis( newAngle:Right(), 90 )

	local x,y,z = self:GetForward() * 5.7, self:GetRight() * -8.70, self:GetUp()

	for i = 1, 7 do
		self.Bars[i] = Lerp( 0.5, self.Bars[i] or 0, self.Bars[i] or 0 + math.random( -3, 3 ) )
	end

	self.OldProg = Lerp( 0.1, self.OldProg, 93 * self.displayTimer / self:GetTime() )
	cam.Start3D2D( self:GetPos() + x + y + z, newAngle, 0.2 )
		surface.SetDrawColor( self.DisplayBarBGColor )
		for i = 1, 7 do
			surface.DrawRect( -3, -55 + ( 5 * i ) + ( 2 * i ), 93, 5 )
		end
		if( self:GetHasPower() > 0 ) then
			if( self:GetMaterialsStored() < self:GetMaxMaterials() ) then
				surface.SetDrawColor( self.DisplayBarColor )
				for i = 1, 7 do
					surface.DrawRect( 90, -55 + ( 5 * i ) + ( 2 * i ), math.Clamp( -self.OldProg + self.Bars[i], -93, 0 ), 5 )
				end
			else
				self.OldProg = 0
			end
		else
			if(self.OldProg > 0 ) then
				self.OldProg = 0
			end
		end
	cam.End3D2D()

	local socket = Entity( self:GetHasPower() )
	if( IsValid( socket ) ) then
		render.SetMaterial( material )
		render.DrawBeam( self:GetPos(), socket:GetPos(), 3, 0, 0, Color(50,50,255))
	end
end

function ENT:DrawDisplay()
	local pos = self:GetPos()
	pos.z = pos.z + 10
	pos = pos:ToScreen()

	local owner = 'Unknown'
	if( IsValid( self:Getowning_ent() ) ) then
		owner = self:Getowning_ent():Name()
	end

	local name = self:GetNameX() or DarkRP.getPhrase( 'material_forge' )

	local mats = ''
	if(self:GetMaterialsStored() > 0) then
		mats = DarkRP.getPhrase( 'material_storing', self:GetMaterialsStored() )..( ( tonumber( self:GetMaterialsStored()) > 1 ) and 's' or '')
	end

	local str = owner..'\'s\n'..name..'\n'..mats
	if( self:GetHasPower() == 0 ) then
		draw.DrawText( DarkRP.getPhrase('no_power'), 'manolisItemNopeD', pos.x+2, pos.y-25+2, Color(0, 0, 0, 200 ), TEXT_ALIGN_CENTER )
		draw.DrawText( DarkRP.getPhrase('no_power'), 'manolisItemNopeD', pos.x, pos.y-25, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER )
	else
		draw.DrawText( DarkRP.getPhrase('powered'), 'manolisItemNopeD', pos.x+2, pos.y-25+2, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER )
		draw.DrawText( DarkRP.getPhrase('powered'), 'manolisItemNopeD', pos.x, pos.y-25, Color( 0,255,0,255 ), TEXT_ALIGN_CENTER )
	end

	draw.DrawText( str, "manolisItemNopeC", pos.x+2, pos.y+2, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER )
	draw.DrawText( str, "manolisItemNopeC", pos.x, pos.y, manolis.popcorn.config.promColor, TEXT_ALIGN_CENTER )
end

ENT.oldTime = 0
function ENT:Think()
	self.displayTimer = self.displayTimer + RealFrameTime()
	if( ( self:GetMaterialsStored() < self:GetMaxMaterials() ) ) then
		if(self:GetTime() != self.oldTime) then
			self.displayTimer = 0
			self.oldTime = self:GetTime()
		end
	end
end