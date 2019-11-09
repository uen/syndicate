include("shared.lua")
local crossicon = Material('gui/silkicons/check_off')
local tickicon = Material('gui/silkicons/check_on')
function ENT:Draw()
    self:DrawModel()
end

function ENT:Initialize()
	self.ShipName = CustomShipments[self:Getcontents()].name
end

function ENT:DrawDisplay()
    local position = self:GetPos()
    position = position:ToScreen()


    draw.DrawText("(Level "..self:GetMinLevel()..'+)', "manolisItemNopeC", position.x, position.y, Color(255,255,255,200), TEXT_ALIGN_CENTER)

    position.y = position.y+25
    draw.DrawText(self:Getcount()..'x '..self.ShipName, "manolisItemNopeC", position.x, position.y, Color(255,255,255,200), TEXT_ALIGN_CENTER)



end