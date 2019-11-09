FAdmin.PlayerIcon = {}
FAdmin.PlayerIcon.RightClickOptions = {}

function FAdmin.PlayerIcon.AddRightClickOption(name, func)
    FAdmin.PlayerIcon.RightClickOptions[name] = func
end

-- FAdminPanelList
local PANEL = {}

function PANEL:Init()
    self.Padding = 5
end

function PANEL:SizeToContents()
    local w, h = self:GetSize()

    -- Fix size of w to have the same size as the scoreboard
    w = math.Clamp(w, ScrW() * 0.9, ScrW() * 0.9)
    h = math.Min(h, ScrH() * 0.95)

    -- It fucks up when there's only one icon in
    if #self:GetChildren() == 1 then
        h = math.Max(0, 120)
    end

    self:SetSize(w, h)
    self:PerformLayout()
end

function PANEL:Paint()
end

derma.DefineControl("FAdminPanelList", "DPanellist adapted for FAdmin", PANEL, "DPanelList")

-- FAdminPlayerCatagoryHeader
local PANEL2 = {}

function PANEL2:PerformLayout()
    self:SetFont("Trebuchet24")
end

derma.DefineControl("FAdminPlayerCatagoryHeader", "DCatagoryCollapse header adapted for FAdmin", PANEL2, "DCategoryHeader")

-- FAdminPlayerCatagory
local PANEL3 = {}

function PANEL3:Init()
    if self.Header then
        self.Header:Remove() -- the old header is still there don't ask me why
    end
    self.Header = vgui.Create("FAdminPlayerCatagoryHeader", self)
    self.Header:SetSize(20, 25)
    self:SetPadding(5)
    self.Header:Dock( TOP )

    self:SetExpanded(true)
    self:SetMouseInputEnabled(true)

    self:SetAnimTime(0.2)
    self.animSlide = Derma_Anim("Anim", self, self.AnimSlide)

    self:SetPaintBackgroundEnabled(true)

end

function PANEL3:Paint()
    if self.CatagoryColor then
        draw.RoundedBox(4, 0, 0, self:GetWide(), self.Header:GetTall(), self.CatagoryColor)
    end
end

derma.DefineControl("FAdminPlayerCatagory", "DCatagoryCollapse adapted for FAdmin", PANEL3, "DCollapsibleCategory")

-- FAdmin player row (from the sandbox player row)
PANEL = {}

local PlayerRowSize = CreateClientConVar("FAdmin_PlayerRowSize", 30, true, false)
function PANEL:Init()
    self.Size = PlayerRowSize:GetInt()

    self.lblName    = vgui.Create("DLabel", self)
    self.lblFrags   = vgui.Create("DLabel", self)
    self.lblFrags:SetContentAlignment(5)
    self.lblTeam    = vgui.Create("DLabel", self)
    self.lblDeaths2  = vgui.Create("DLabel", self)
    self.lblDeaths  = vgui.Create("DLabel", self)

    self.lblPing    = vgui.Create("DLabel", self)
    self.lblPing:SetContentAlignment(5)
    self.lblWanted  = vgui.Create("DLabel", self)

    -- If you don't do this it'll block your clicks
    self.lblName:SetMouseInputEnabled(false)
    self.lblTeam:SetMouseInputEnabled(false)
    self.lblFrags:SetMouseInputEnabled(false)
    self.lblDeaths:SetMouseInputEnabled(false)
    self.lblDeaths2:SetMouseInputEnabled(false)
    self.lblPing:SetMouseInputEnabled(false)
    self.lblWanted:SetMouseInputEnabled(false)

    self.lblName:SetColor(Color(255,255,255,255))
    self.lblTeam:SetColor(Color(255,255,255,255))
    self.lblFrags:SetColor(Color(255,255,255,255))
    self.lblDeaths:SetColor(Color(255,255,255,255))
    self.lblDeaths2:SetColor(Color(255,255,255,255))
    self.lblPing:SetColor(Color(255,255,255,255))
    self.lblWanted:SetColor(Color(255,255,255,255))


    self.lblDeaths:SetTall(32)
    self.lblDeaths2:SetTall(32)
    self.lblFrags:SetTall(32)
    self.lblName:SetTall(32)
 
    self.lblPing:SetTall(32)
    self.imgAvatar = vgui.Create("AvatarImage", self)

    self:SetCursor("hand")
end

function PANEL:Paint()
    if not IsValid(self.Player) then return end

    self.Size = PlayerRowSize:GetInt()
    self.imgAvatar:SetSize(self.Size - 4, self.Size - 4)

    local color = Color(100, 150, 245, 255)



    color = team.GetColor(self.Player:Team())
  
    local hooks = hook.GetTable().FAdmin_PlayerRowColour
    if hooks then
        for k,v in pairs(hooks) do
            color = (v and v(self.Player, color)) or color
            break
        end
    end

    draw.RoundedBox(4, 0, 0, self:GetWide(), self.Size, color)

    surface.SetTexture(0)

    surface.DrawTexturedRect(0, 0, self:GetWide(), self.Size)
    return true
end

function PANEL:SetPlayer(ply)
    self.Player = ply

    self.imgAvatar:SetPlayer(ply)

    self:UpdatePlayerData()
end

function PANEL:UpdatePlayerData()
    if not self.Player then return end
    if not self.Player:IsValid() then return end

    self.lblName:SetText(DarkRP.deLocalise(self.Player:Nick()))
    self.lblTeam:SetText((self.Player.DarkRPVars and DarkRP.deLocalise(self.Player:getDarkRPVar("job") or "")) or team.GetName(self.Player:Team()))

    self.lblFrags:SetText(self.Player.DarkRPVars and DarkRP.deLocalise(self.Player:getDarkRPVar('level') or '') or 1)

    self.lblDeaths:SetText('')
    self.lblDeaths2:SetText('')

    if(self.Player:getDarkRPVar('gang') or 0>0) then
        self.Player.GangInfo = self.Player:getDarkRPVar('gangdata')
        if(self.Player.GangInfo and self.Player.GangInfo.name) then
            local c1 = {255,255,255}
            local c2 = {255,255,255}
            if(self.Player.GangInfo.color) then 
                c1 = split(self.Player.GangInfo.color, ',')
            end
            if(self.Player.GangInfo.secondcolor) then
                c2 = split(self.Player.GangInfo.secondcolor, ',')
            end
             
            self.lblDeaths:SetColor(Color(c1[1],c1[2],c1[3]))
            self.lblDeaths2:SetColor(Color(c2[1],c2[2],c2[3]))
       

            self.lblDeaths:SetText(self.Player.GangInfo.name!='' and self.Player.GangInfo.name or '')
            self.lblDeaths2:SetText(self.Player.GangInfo.name!='' and self.Player.GangInfo.name or '')

        end

    end

    self.lblPing:SetText(self.Player:Ping())
    self.lblWanted:SetText(self.Player:isWanted() and DarkRP.getPhrase("Wanted_text") or "")
end

function PANEL:ApplySchemeSettings()
    self.lblName:SetFont("ScoreboardPlayerNameBig")
    self.lblTeam:SetFont("ScoreboardPlayerNameBig")
    self.lblFrags:SetFont("ScoreboardPlayerName")
    self.lblDeaths:SetFont("ScoreboardPlayerName")
    self.lblDeaths2:SetFont("ScoreboardPlayerName")
    self.lblPing:SetFont("ScoreboardPlayerName")
    self.lblWanted:SetFont("ScoreboardPlayerNameBig")

    self.lblName:SetFGColor(color_white)
    self.lblTeam:SetFGColor(color_white)
    self.lblFrags:SetFGColor(color_white)
    self.lblDeaths:SetFGColor(color_white)
    self.lblPing:SetFGColor(color_white)
    self.lblWanted:SetFGColor(color_white)
end

function PANEL:DoClick(x, y)
    if not IsValid(self.Player) then self:Remove() return end
    FAdmin.ScoreBoard.ChangeView("Player", self.Player)
end

function PANEL:DoRightClick()
    if table.Count(FAdmin.PlayerIcon.RightClickOptions) < 1 then return end
    local menu = DermaMenu()

    menu:SetPos(gui.MouseX(), gui.MouseY())

    for Name, func in SortedPairs(FAdmin.PlayerIcon.RightClickOptions) do
        menu:AddOption(Name, function() if IsValid(self.Player) then func(self.Player, self) end end)
    end

    menu:Open()
end

function PANEL:Think()
    if not self.PlayerUpdate or self.PlayerUpdate < CurTime() then
        self.PlayerUpdate = CurTime() + 0.5
        self:UpdatePlayerData()
    end
end

function PANEL:PerformLayout()
    self.imgAvatar:SetPos(2, 2)
    self.imgAvatar:SetSize(32, 32)

    self:SetSize(self:GetWide(), self.Size+1)

    self.lblName:SizeToContents()
    self.lblName:SetPos(24, 2)
    self.lblName:MoveRightOf(self.imgAvatar, 8)
    self.lblName:SetWide(265)

    self.lblFrags:MoveRightOf(self.lblName,8)
    self.lblFrags:SetWide(85)

    self.lblDeaths:MoveRightOf(self.lblFrags,8)
    local w,h = self.lblDeaths:GetPos()
    self.lblDeaths2:SetPos(w+1,h+1)
    self.lblDeaths:SetWide(155)
    self.lblDeaths2:SetWide(155)

    self.lblTeam:MoveRightOf(self.lblDeaths,8)
    self.lblTeam:SetWide(154)
    self.lblTeam:SetTall(32)


    self.lblPing:MoveRightOf(self.lblTeam,8)



    self.lblWanted:SizeToContents()
    self.lblWanted:SetPos(math.floor(self:GetWide() / 4), 2)
end
vgui.Register("FadminPlayerRowMani", PANEL, "Button")

-- FAdminActionButton
local PANEL6 = {}

function PANEL6:Init()
    self:SetDrawBackground(false)
    self:SetDrawBorder(false)
    self:SetStretchToFit(false)
    self:SetSize(120, 40)

    self.TextLabel = vgui.Create("DLabel", self)
    self.TextLabel:SetColor(Color(200,200,200,200))
    self.TextLabel:SetFont("ChatFont")

    self.m_Image2 = vgui.Create("DImage", self)

    self.BorderColor = Color(190,40,0,255)
end

function PANEL6:SetText(text)
    self.TextLabel:SetText(text)
    self.TextLabel:SizeToContents()

    self:SetWide(self.TextLabel:GetWide() + 44)
end

function PANEL6:PerformLayout()
    self.m_Image:SetSize(32,32)
    self.m_Image:SetPos(4,4)

    self.m_Image2:SetSize(32, 32)
    self.m_Image2:SetPos(4,4)

    self.TextLabel:SetPos(38, 8)
end

function PANEL6:SetImage2(Mat, bckp)
    self.m_Image2:SetImage(Mat, bckp)
end

function PANEL6:SetBorderColor(Col)
    self.BorderColor = Col or Color(190,40,0,255)
end

function PANEL6:Paint()
    local BorderColor = self.BorderColor
    if self.Hovered then
        BorderColor = Color(math.Min(BorderColor.r + 40, 255), math.Min(BorderColor.g + 40, 255), math.Min(BorderColor.b + 40, 255), BorderColor.a)
    end
    if self.Depressed then
        BorderColor = Color(0,0,0,0)
    end
    draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), BorderColor)
    draw.RoundedBox(4, 2, 2, self:GetWide() - 4, self:GetTall() - 4, Color(40, 40, 40, 255))
end

function PANEL6:OnMousePressed(mouse)
    if self:GetDisabled() then return end

    self.m_Image:SetSize(24,24)
    self.m_Image:SetPos(8,8)
    self.Depressed = true
end

function PANEL6:OnMouseReleased(mouse)
    if self:GetDisabled() then return end

    self.m_Image:SetSize(32,32)
    self.m_Image:SetPos(4,4)
    self.Depressed = false
    self:DoClick()
end

derma.DefineControl("FAdminActionButton", "Button for doing actions", PANEL6, "DImageButton")
