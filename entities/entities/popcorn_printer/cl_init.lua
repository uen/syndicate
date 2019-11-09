include("shared.lua")

function ENT:Initialize()
	self:SetCustomCollisionCheck(true)
end

local material = Material("cable/physbeam")

function ENT:Draw()
	self:DrawModel()

	if(self:GetMoney()>0) then
		render.SetMaterial(manolis.popcorn.materialCache.glow)
		local scale = 5*((math.cos(SysTime()*4))/2)

		render.SetShadowColor(1,0,0)

		local ob = self:OBBMaxs()
		if(ob.x>20) then
			ob.x = ob.x
			scale = scale + ob.x
		end

		render.DrawQuadEasy(self:GetPos()+Vector(0,0,5), -LocalPlayer():GetAimVector(), 64 + scale,64 + scale, self:GetColor(), 0)
	end

	local socket = Entity(self:GetHasPower())
	if(IsValid(socket)) then
		render.SetMaterial(material)
		render.DrawBeam(self:GetPos(), socket:GetPos(), 3,0,0,Color(50,50,255))
	end
end

function ENT:DrawDisplay()
	local pos = self:GetPos()
	pos.z = pos.z + 10
	pos = pos:ToScreen()

	local owner = DarkRP.getPhrase('unknown')
	
	if(IsValid(self:Getowning_ent())) then
		owner = self:Getowning_ent():Name()
	end

	local name = self:GetMType()
	local str = owner..'\'s\n'..(self:Getinfused() and 'Infused ' or '')..name..'\n' .. DarkRP.formatMoney(self:GetMoney())
	if(self:GetHasPower()==0) then
		draw.DrawText(DarkRP.getPhrase('no_power'), 'manolisItemNopeD', pos.x+2, pos.y-25+2, Color(0,0,0,200), TEXT_ALIGN_CENTER)
		draw.DrawText(DarkRP.getPhrase('no_power'), 'manolisItemNopeD', pos.x, pos.y-25, Color(255,0,0,255), TEXT_ALIGN_CENTER)
	else
		draw.DrawText(DarkRP.getPhrase('powered'), 'manolisItemNopeD', pos.x+2, pos.y-25+2, Color(0,0,0,200), TEXT_ALIGN_CENTER)
		draw.DrawText(DarkRP.getPhrase('powered'), 'manolisItemNopeD', pos.x, pos.y-25, Color(0,255,0,255), TEXT_ALIGN_CENTER)
	end

	local y = pos.y

	draw.DrawText(str, "manolisItemNopeC", pos.x+2, y+2, Color(0,0,0,200), TEXT_ALIGN_CENTER)
	draw.DrawText(str, "manolisItemNopeC", pos.x, y, manolis.popcorn.config.promColor, TEXT_ALIGN_CENTER)
end