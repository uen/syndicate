if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.levels) then manolis.popcorn.levels = {} end
if(!manolis.popcorn.hud) then manolis.popcorn.hud = {} end
local OldXP = 0
local OldXPStore = 0

local OldXPPercent = 0

local xp = Material('manolis/popcorn/hud/6/xp.png', 'smooth')
local xp_fill = Material('manolis/popcorn/hud/6/xp_fill.png', 'smooth mips noclamp')

surface.CreateFont( "Default", {
	 font = "Tahoma",
	 size = 13,
	 weight = 500,
	 blursize = 0,
	 scanlines = 0,
} )

local XPText = {}
local XPChanged = function(old, new)
	local a = {}
	a.x = ScrW()/2 + math.random(-250,250)
	a.y = 30
	a.a = 255
	a.val = new-old

	table.insert(XPText, a)
end

local barExp = 0
local barExpTime = 0
local updateXPText = function()
	for k,v in pairs(XPText) do
		v.y = v.y + FrameTime() * 2
		v.a = math.floor(v.a-FrameTime())
		if(v.a<=0) then
			table.remove(XPText, k)
		end
		draw.DrawText("+"..string.Comma(v.val).." xp", "HUDHintTextLarge", v.x,v.y,Color(255,255,255,v.a))

		if(barExpTime+1>CurTime()) then
			barExp = 120 - 120 * (math.sin((CurTime()-barExpTime)*2))
		end
	end
end


hook.Add("HUDPaint", "manolis:popcorn:levels:HUDPaint", function()
	if(manolis.popcorn.config.hud.xpBar) then
		if(manolis.popcorn.hud.shouldDraw) then
			local PlayerLevel = manolis.popcorn.levels.GetLevel and manolis.popcorn.levels.GetLevel( LocalPlayer() ) or 1
			local PlayerXP = manolis.popcorn.levels.GetXP( LocalPlayer() ) or 0

			local percent = ( PlayerXP / manolis.popcorn.levels.GetMaxXP(PlayerLevel) )

			OldXPPercent = Lerp(FrameTime()*4, OldXPPercent, percent)
			local drawXP = Lerp(FrameTime()*4,OldXP,percent)
			OldXP = drawXP


			draw.RoundedBox(0, (ScrW()/2)-276, 0,538, 19, Color(0,0,0,200))

			surface.SetDrawColor(manolis.popcorn.config.promColor)
			surface.SetMaterial(xp_fill)
			surface.DrawTexturedRectUV(ScrW()/2-(276),2,math.Clamp(538*drawXP,0,538), 19, 0, 0, 1,1)

			draw.RoundedBox(0, (ScrW()/2) - 276, 0,math.Clamp(538*drawXP,0,538), 19, Color(255,255,255,barExp))

			draw.SimpleText(DarkRP.getPhrase('vgui_level3', PlayerLevel .. ' - ' ..math.floor(OldXPPercent*100)..'%'), 'manolisHUDX', ScrW()/2+1, 3+1, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(DarkRP.getPhrase('vgui_level3', PlayerLevel .. ' - ' ..math.floor(OldXPPercent*100)..'%'), 'manolisHUDX', ScrW()/2, 3, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			surface.SetMaterial(xp)
			surface.SetDrawColor(255,255,255,255)
			surface.DrawTexturedRect(ScrW()/2-(711/2),-1,711,23)

			if(OldXPStore != PlayerXP) then
				XPChanged(OldXPStore, PlayerXP)
				OldXPStore = PlayerXP
				barExpTime = CurTime()
			end

			updateXPText()

			

			
		end
	end

end)



hook.Add("HUDShouldDraw", "manolis:popcorn:disableDefaultHUD", function(name)
	if ( name == "CHudHealth" or name == "CHudBattery" ) then
         return false
    end
end)