if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.keys) then manolis.popcorn.keys = {} end
if(!manolis.popcorn.temp) then manolis.popcorn.temp = {} end
if(!manolis.popcorn.player) then manolis.popcorn.player = {} end
if(!manolis.popcorn.materialCache) then manolis.popcorn.materialCache = {} end

local keys = {}

hook.Add('KeyPress', 'popcorn:manolisKeyPressed', function(ply,key)
	manolis.popcorn.keys[key] = true
end)

hook.Add('KeyRelease', 'popcorn:manolisKeyRelease', function(ply,key)
	manolis.popcorn.keys[key] = false
end)

local logo = Material('manolis/popcorn/logo.png')
local blur = Material('pp/blurscreen')
local tip = Material('manolis/popcorn/nav.png', 'smooth')

local blurCount = 0
local blurSteps = 25
local showLogo = false
local noFade = 4
local doFade = 1
local startFade = 1
local logoAlpha = 255
local firstLogoShown = false

hook.Add('RenderScreenspaceEffects', 'VignetteNLRPopcorn', function()
	if(LocalPlayer():getDarkRPVar('PopcornGhost')) then
		DrawMaterialOverlay( 'manolis/popcorn/overlays/vignette01', 10 )
		DrawMaterialOverlay( 'manolis/popcorn/overlays/vignette01', 10 )
		DrawMaterialOverlay( 'manolis/popcorn/overlays/vignette01', 10 )
	end
end)

local blurSpawnShown = false
hook.Add('HUDPaint', 'CreditsDrawPopcorn', function()
	local death = DarkRP.getPhrase('nlr')
	if(LocalPlayer():getDarkRPVar('PopcornGhost')) then
		
		if(!blurSpawnShown) then
			blurSpawnShown = true
			manolis.popcorn.ShowBlurspace()
		end

		surface.SetFont('manolisGhostTextFont')

		surface.SetDrawColor(0,0,0,100)
		local w,h = surface.GetTextSize(death)
		surface.DrawRect(ScrW()/2-(w/2)-10,ScrH()/5-(h/2)-5,w+20,h+10)
		surface.SetTextColor(255,255,255,175)
		surface.SetTextPos( (ScrW()/2) - (w/2), ScrH()/5-(h/2) )
		surface.DrawText( death )
	else
		if(blurSpawnShown) then
			blurSpawnShown = false
		end
	end

	if(showLogo) then
		blurCount = blurCount + 0.5
		if(0 < noFade and blurSteps > 0) then
			if((blurCount/12)==math.floor(blurCount/12)) then
				blurSteps = blurSteps - 1
			end
			noFade = noFade - FrameTime()
		else
			if(0 < doFade) then
				logoAlpha = 255*(doFade/startFade)
				doFade = doFade - FrameTime()
			else
				showLogo = false
				firstLogoShown = true

				noFade = 4
				blurSteps = 20
				blurCount = 0
			end
		end

		render.SetMaterial(blur)
		for a=1,blurSteps do
			blur:SetFloat('$blur', 1)
			blur:Recompute()
			render.UpdateScreenEffectTexture()
			render.DrawScreenQuad() 
		end
		if(!firstLogoShown) then
			surface.SetDrawColor(Color(255,255,255,logoAlpha))
			surface.SetMaterial(logo)
			surface.DrawTexturedRect(ScrW()/2-(512/2),ScrH()/2-(256/2),512,256)

			surface.SetMaterial(tip)
			surface.DrawTexturedRect(ScrW()/2, ScrH()-150-80, 310, 150)
		end
	end

	manolis.popcorn.player.Aim = LocalPlayer():GetAimVector():GetNormalized()
			

end)

local blurShown = false
manolis.popcorn.ShowBlurspace = function()
	if(blurShown) then return end
	blurStepshown = true
	if(manolis.popcorn.config.useBlurspace) then
		showLogo = true
	end
end

hook.Add( 'RenderScreenspaceEffects', 'manolis:client:SunBeams', function()
	local sun = util.GetSunInfo()
	if (!sun) then return end
		
	local sunpos = EyePos() + sun.direction * 100
	local screenPosition = sunpos:ToScreen()
 
	local dot = (sun.direction:Dot( EyeVector() ) - 0.8) * 5
	if (dot <= 0) then return end
	
	DrawSunbeams(0,	0.1*(sun.direction:Dot(EyeVector())-0.8)*5,3,screenPosition.x/ScrW(),screenPosition.y/ScrH())

end)

concommand.Add("SyndicateGamemodeInfo",function()
	// I kindly request that you do not remove/change this 
	local panel = vgui.Create('ManolisFrame')
	panel:SetRealSize(450, 350)
	panel:Center()
	panel:SetText("Gamemode information")
	panel:SetBackgroundBlur(true)
	panel:SetBackgroundBlurOverride(true)
	panel:MakePopup()

	local scrollPanel = vgui.Create("ManolisScrollPanel", panel)
	scrollPanel:SetSize(450-10-5, 500-10)
	scrollPanel:SetPos(10,45)

	local title = vgui.Create('DLabel')
	title:SetWide(450-10-10,20)
	title:SetText("Syndicate RPG - Version 3.0.0")
	title:SetFont("manolisAffectsTitle")
	scrollPanel:Add(title)

	local desc = vgui.Create('DLabel')
	desc:SetSize(450-10-10, 0)
	desc:SetWrap(true)
	desc:SetContentAlignment(7)
	desc:SetAutoStretchVertical(true)
	desc:SetFont("manolisItemCreditDescription")
	desc:SetText([[
		Copyright (c) 2016 by Manolis Vrondakis http://manolisvrondakis.com. Thanks to the testers that made this gamemode a reality. 

		Please report bugs to the Syndicate RPG Github.

		This gamemode can be downloaded at: https://github.com/vrondakis/syndicate - Redistribution is not permitted.
	]])
	scrollPanel:Add(desc,15)
end)