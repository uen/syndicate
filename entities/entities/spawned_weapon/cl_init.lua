include("shared.lua")
local crossicon = Material('gui/silkicons/check_off')
local tickicon = Material('gui/silkicons/check_on')
function ENT:DrawDisplay()
    local position = self:GetPos()
    position = position:ToScreen()
    if(self:GetNameOfItem()) then
        draw.DrawText(self:GetNameOfItem(), "manolisItemNopeC", position.x + 1, position.y + 1, Color(0, 0, 0, 200), TEXT_ALIGN_CENTER)
    end

    local level = self.GetMinLevel and self:GetMinLevel() or 0 
    surface.SetDrawColor(255,0,0,255)
    if(!manolis.popcorn.levels.HasLevel(LocalPlayer(), level)) then
        surface.SetFont("manolisItemNopeE")
        local w,h = surface.GetTextSize(DarkRP.getPhrase('level_high',level))

        surface.SetMaterial(crossicon)
        surface.DrawTexturedRect(position.x-22 -(w/2), position.y-1, 16,16)

        draw.DrawText(DarkRP.getPhrase('level_high',level), 'manolisItemNopeE', position.x+2,position.y+2-5, Color(0,0,0,200), TEXT_ALIGN_CENTER)
        draw.DrawText(DarkRP.getPhrase('level_high',level), 'manolisItemNopeE', position.x,position.y-5, Color(255,0,0,255), TEXT_ALIGN_CENTER)
       
    else
        surface.SetDrawColor(0,255,0,255)
        surface.SetMaterial(tickicon)
        surface.DrawTexturedRect(position.x-16, position.y+4, 16,16)
    end
end

function ENT:Draw()
    local cd = hook.Call("onDrawSpawnedWeapon", nil, self)
    if cd != nil then return end
    self:DrawModel()

end
