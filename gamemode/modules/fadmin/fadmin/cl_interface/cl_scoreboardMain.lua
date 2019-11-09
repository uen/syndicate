local Sorted, SortDown = CreateClientConVar("FAdmin_SortPlayerList", "Team", true), CreateClientConVar("FAdmin_SortPlayerListDown", 1, true)
local allowedSorts = {

}

function FAdmin.ScoreBoard.Main.Show()
    local Sort = {}
    local ScreenWidth, ScreenHeight = ScrW(), ScrH()

    FAdmin.ScoreBoard.X = ScrW()/2-400
    FAdmin.ScoreBoard.Y = ScreenHeight * 0.025
    FAdmin.ScoreBoard.Width = 800
    FAdmin.ScoreBoard.Height = ScreenHeight * 0.95

    FAdmin.ScoreBoard.ChangeView("Main")

    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList = FAdmin.ScoreBoard.Main.Controls.FAdminPanelList or vgui.Create("DPanelList")
    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:SetVisible(true)
    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:Clear(true)
    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList.Padding = 0
    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:EnableVerticalScrollbar(true)

 
    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:Clear(true)

    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:SetPos(FAdmin.ScoreBoard.X, FAdmin.ScoreBoard.Y + 88)
    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:SetSize(FAdmin.ScoreBoard.Width, FAdmin.ScoreBoard.Height - 90 - 30 - 20 - 20)



    Sort.Team = Sort.Team or vgui.Create("DLabel")
    Sort.Team:SetText("Level")
    Sort.Team:SetPos(FAdmin.ScoreBoard.X + FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:GetWide() - 459, FAdmin.ScoreBoard.Y + 67)
    Sort.Team.Type = "Level"
    Sort.Team:SetVisible(true)

    Sort.Frags = Sort.Frags or vgui.Create("DLabel")
    Sort.Frags:SetText("Gang")
    Sort.Frags:SetPos(FAdmin.ScoreBoard.X + FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:GetWide() - 394,  FAdmin.ScoreBoard.Y + 67)
    Sort.Frags.Type = "Gang"
    Sort.Frags:SetVisible(true)

    Sort.Deaths = Sort.Deaths or vgui.Create("DLabel")
    Sort.Deaths:SetText("Job")
    Sort.Deaths:SetPos(FAdmin.ScoreBoard.X + FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:GetWide() - 230, FAdmin.ScoreBoard.Y + 67)
    Sort.Deaths.Type = "Job"
    Sort.Deaths:SetVisible(true)

    Sort.Ping = Sort.Ping or vgui.Create("DLabel")
    Sort.Ping:SetText("Ping")
    Sort.Ping:SetPos(FAdmin.ScoreBoard.X + FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:GetWide() - 50, FAdmin.ScoreBoard.Y + 67)
    Sort.Ping.Type = "Ping"
    Sort.Ping:SetVisible(true)

    local sortBy = Sorted:GetString()
    sortBy = allowedSorts[sortBy] and sortBy or "Team"

    FAdmin.ScoreBoard.Main.PlayerListView(sortBy, SortDown:GetBool())

    for k,v in pairs(Sort) do
        v:SetFont("ManolisScoreboardFont")
        v:SizeToContents()

        local X, Y = v:GetPos()

        
        table.insert(FAdmin.ScoreBoard.Main.Controls, v) -- Add them to the table so they get removed when you close the scoreboard
        table.insert(FAdmin.ScoreBoard.Main.Controls, v.BtnSort)
    end
end

function FAdmin.ScoreBoard.Main.AddPlayerRightClick(Name, func)
    FAdmin.PlayerIcon.RightClickOptions[Name] = func
end

FAdmin.StartHooks["CopySteamID"] = function()
    FAdmin.ScoreBoard.Main.AddPlayerRightClick("Copy SteamID", function(ply) SetClipboardText(ply:SteamID()) end)
end
