if(!manolis) then manolis = {} end
if(!manolis.f1) then manolis.f1 = {} end



local f1Frame
manolis.f1.openF1Menu = function()
	if(IsValid(f1Frame)) then
		f1Frame:Show()
		f1Frame:InvalidateLayout()
	else
		f1Frame = vgui.Create("ManolisFrame")
		f1Frame:MakePopup()
		f1Frame:SetRealSize(ScrW()-100, ScrH()-100)
		f1Frame:SetBackgroundBlur( true )
		f1Frame:Center()

		f1Frame:SetText(DarkRP.getPhrase("server_menu"))
		f1Frame.header.closeButton:SetVisible(false)

		local tabs = vgui.Create("ManolisTabs", f1Frame)
		tabs:SetPos(0,40)
		tabs:SetSize(f1Frame:GetWide(),f1Frame:GetTall()-40)

		local rules = vgui.Create("Panel")
			rules:SetSize(f1Frame:GetWide(), tabs:GetTall()-50)
			local r = vgui.Create("DHTML", rules)
			r:SetPos(0,0)
			r:Dock(FILL)
			r:OpenURL("http://syndicate.manolis.io/doku.php?id=players")
		

			local sub = vgui.Create("ManolisButton", rules)
			sub:SetPos(f1Frame:GetWide()/2-100, tabs:GetTall()-125)
			sub:SetText(DarkRP.getPhrase("accept_rules"))
			sub:SetSize(200,50)
			sub:SetZPos(9)
			sub.DoClick = function( button )
				f1Frame.header.closeButton.DoClick()
			end

			sub:SetColor(Color(255,255,255,150))

			f1Frame.header.closeButton.DoClick = function()
				f1Frame:Close()
				gui.EnableScreenClicker(false)

				manolis.popcorn.ShowBlurspace()
			end

		local closeButtonVisible = function(a)
			f1Frame.header.closeButton:SetVisible(a)


		end

		tabs:AddTab(DarkRP.getPhrase("rules"), rules).button.DoClickAlt = function() closeButtonVisible(false) end

		//local guide = vgui.Create("Panel")
		//tabs:AddTab(DarkRP.getPhrase("guide"), guide).button.DoClickAlt = function() closeButtonVisible(true) end

		local forum = vgui.Create("Panel")
		tabs:AddTab(DarkRP.getPhrase("forums"), forum).button.DoClickAlt = function() closeButtonVisible(true) end

		//local changelog = vgui.Create("Panel")
		//tabs:AddTab(DarkRP.getPhrase("changelog"), changelog).button.DoClickAlt = function() closeButtonVisible(true) end
	end
end

manolis.f1.closeF1Menu = function()
	if(IsValid(f1Frame)) then
		f1Frame:Close()
	end
end

manolis.f1.toggleF1Menu = function()
	if not IsValid(f1Frame) or not f1Frame:IsVisible() then
		manolis.f1.openF1Menu()
		gui.EnableScreenClicker(true)
	else
		manolis.f1.closeF1Menu()
		gui.EnableScreenClicker(false)
	end
end

GM.ShowHelp = manolis.f1.toggleF1Menu

function manolis.f1.getF1MenuPanel()
	return f1Frame
end

net.Receive("ManolisPopcornShowF1", function()
	manolis.f1.openF1Menu()
end)
