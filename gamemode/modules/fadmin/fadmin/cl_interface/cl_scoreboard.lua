local OverrideScoreboard = CreateClientConVar("FAdmin_OverrideScoreboard", 0, true, false) -- Set if it's a scoreboard or not

function FAdmin.ScoreBoard.ChangeView(newView, ...)
    if FAdmin.ScoreBoard.CurrentView == newView or not FAdmin.ScoreBoard.Visible then return end

    for k,v in pairs(FAdmin.ScoreBoard[FAdmin.ScoreBoard.CurrentView].Controls) do
        v:SetVisible(false)
    end

    FAdmin.ScoreBoard.CurrentView = newView
    FAdmin.ScoreBoard[newView].Show(...)
    FAdmin.ScoreBoard.ChangeGmodLogo(FAdmin.ScoreBoard[newView].Logo)

    FAdmin.ScoreBoard.Controls.BackButton = FAdmin.ScoreBoard.Controls.BackButton or vgui.Create("DButton")
    FAdmin.ScoreBoard.Controls.BackButton:SetVisible(true)
    FAdmin.ScoreBoard.Controls.BackButton:SetPos(FAdmin.ScoreBoard.X, FAdmin.ScoreBoard.Y)
    FAdmin.ScoreBoard.Controls.BackButton:SetText("")
    FAdmin.ScoreBoard.Controls.BackButton:SetTooltip("Click me to go back!")
    FAdmin.ScoreBoard.Controls.BackButton:SetCursor("hand")
    FAdmin.ScoreBoard.Controls.BackButton:SetSize(100,90)
    FAdmin.ScoreBoard.Controls.BackButton:SetZPos(999)

    function FAdmin.ScoreBoard.Controls.BackButton:DoClick()
        FAdmin.ScoreBoard.ChangeView("Main")
    end
    FAdmin.ScoreBoard.Controls.BackButton.Paint = function() end
end

--"fadmin/back", gui/gmod_tool
local GmodLogo, TempGmodLogo, GmodLogoColor = surface.GetTextureID("gui/gmod_logo"), surface.GetTextureID("gui/gmod_logo"), Color(255, 255, 255, 255)
function FAdmin.ScoreBoard.ChangeGmodLogo(new)
    if surface.GetTextureID(new) == TempGmodLogo then return end
    TempGmodLogo = surface.GetTextureID(new)
    for i = 0, 0.5, 0.01 do
        timer.Simple(i, function() GmodLogoColor = Color(255,255,255,GmodLogoColor.a-5.1) end)
    end
    timer.Simple(0.5, function() GmodLogo = surface.GetTextureID(new) end)
    for i = 0.5, 1, 0.01 do
        timer.Simple(i, function()
            GmodLogoColor = Color(255, 255, 255, GmodLogoColor.a + 5.1)
        end)
    end
end

local header_ = Material('manolis/popcorn/hud/6/scoreboard.png', 'smooth')
local header_2 = Material('manolis/popcorn/hud/6/scoreboard2.png', 'smooth')
local sm = Material('manolis/popcorn/logo-sm.png', 'smooth')
function FAdmin.ScoreBoard.Background()
   surface.SetDrawColor(Color(255,255,255,255))
   surface.SetMaterial(header_)
   surface.DrawTexturedRect(FAdmin.ScoreBoard.X,FAdmin.ScoreBoard.Y,800,64)

   surface.SetDrawColor(manolis.popcorn.config.promColor)
   surface.SetMaterial(header_2)
   surface.DrawTexturedRect(FAdmin.ScoreBoard.X,FAdmin.ScoreBoard.Y,800,64)


    surface.SetMaterial(sm)
    surface.SetDrawColor(255,255,255,GmodLogoColor.a)
    surface.DrawTexturedRect(FAdmin.ScoreBoard.X-10, FAdmin.ScoreBoard.Y-5, 200, 75)

    surface.SetDrawColor(17,20,19,255)
    surface.DrawRect(FAdmin.ScoreBoard.X,FAdmin.ScoreBoard.Y+64,800,23)
end


function FAdmin.ScoreBoard.DrawScoreBoard()
    if (input.IsMouseDown(MOUSE_4) or input.IsKeyDown(KEY_BACKSPACE)) and not FAdmin.ScoreBoard.DontGoBack then
        FAdmin.ScoreBoard.ChangeView("Main")
    elseif FAdmin.ScoreBoard.DontGoBack then
        FAdmin.ScoreBoard.DontGoBack = input.IsMouseDown(MOUSE_4) or input.IsKeyDown(KEY_BACKSPACE)
    end
    FAdmin.ScoreBoard.Background()
end


function FAdmin.ScoreBoard.ShowScoreBoard()
    FAdmin.ScoreBoard.Visible = true
    FAdmin.ScoreBoard.DontGoBack = input.IsMouseDown(MOUSE_4) or input.IsKeyDown(KEY_BACKSPACE)

   FAdmin.ScoreBoard.Controls.Description2 = FAdmin.ScoreBoard.Controls.Description2 or vgui.Create("DLabel")
    FAdmin.ScoreBoard.Controls.Description2:SetText(DarkRP.deLocalise(GetHostName()))
    FAdmin.ScoreBoard.Controls.Description2:SetFont("ScoreboardSubtitle")
    FAdmin.ScoreBoard.Controls.Description2:SetColor(Color(255,255,255,255))
    FAdmin.ScoreBoard.Controls.Description2:SetPos(ScrW()/2+70+1, FAdmin.ScoreBoard.Y+20+1)
    FAdmin.ScoreBoard.Controls.Description2:SizeToContents()
    FAdmin.ScoreBoard.Controls.Description2:SetWide(310)

    FAdmin.ScoreBoard.Controls.Description2:SetVisible(true)


    FAdmin.ScoreBoard.Controls.Description = FAdmin.ScoreBoard.Controls.Description or vgui.Create("DLabel")
    FAdmin.ScoreBoard.Controls.Description:SetText(DarkRP.deLocalise(GetHostName()))
    FAdmin.ScoreBoard.Controls.Description:SetFont("ScoreboardSubtitle")
    FAdmin.ScoreBoard.Controls.Description:SetColor(Color(0,0,0,200))
    FAdmin.ScoreBoard.Controls.Description:SetPos(ScrW()/2+70, FAdmin.ScoreBoard.Y+20)
    FAdmin.ScoreBoard.Controls.Description:SizeToContents()
    FAdmin.ScoreBoard.Controls.Description:SetWide(310)

    FAdmin.ScoreBoard.Controls.Description:SetVisible(true)


 



    if FAdmin.ScoreBoard.Controls.BackButton then FAdmin.ScoreBoard.Controls.BackButton:SetVisible(true) end

    FAdmin.ScoreBoard[FAdmin.ScoreBoard.CurrentView].Show()

    gui.EnableScreenClicker(true)
    hook.Add("HUDPaint", "FAdmin_ScoreBoard", FAdmin.ScoreBoard.DrawScoreBoard)
    hook.Call("FAdmin_ShowFAdminMenu")
    return true
end
concommand.Add("+FAdmin_menu", FAdmin.ScoreBoard.ShowScoreBoard)

hook.Add("ScoreboardShow", "FAdmin_scoreboard", function()
    if FAdmin.GlobalSetting.FAdmin or OverrideScoreboard:GetBool() then -- Don't show scoreboard when FAdmin is not installed on server
        return FAdmin.ScoreBoard.ShowScoreBoard()
    end
end)

function FAdmin.ScoreBoard.HideScoreBoard()
    if not FAdmin.GlobalSetting.FAdmin then return end
    FAdmin.ScoreBoard.Visible = false
    CloseDermaMenus()

    gui.EnableScreenClicker(false)
    hook.Remove("HUDPaint", "FAdmin_ScoreBoard")

    for k,v in pairs(FAdmin.ScoreBoard[FAdmin.ScoreBoard.CurrentView].Controls) do
        v:SetVisible(false)
    end

    for k,v in pairs(FAdmin.ScoreBoard.Controls) do
        v:SetVisible(false)
    end
    return true
end
concommand.Add("-FAdmin_menu", FAdmin.ScoreBoard.HideScoreBoard)

hook.Add("ScoreboardHide", "FAdmin_scoreboard", function()
    if FAdmin.GlobalSetting.FAdmin or OverrideScoreboard:GetBool() then -- Don't show scoreboard when FAdmin is not installed on server
        return FAdmin.ScoreBoard.HideScoreBoard()
    end
end)
