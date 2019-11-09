if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.dermaBlurDrawn) then manolis.popcorn.dermaBlurDrawn = 0 end
if(!manolis.popcorn.activePopups) then manolis.popcorn.activePopups = 0 end
include('manolisframe.lua')
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisheader.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisclosebutton.lua")

include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisbutton.lua")

include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisf4button.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisslots.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisslot.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisimageslot.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolissmallslot.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisrivalpanel.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisslotsitem.lua")

include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisiteminfo.lua")

include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisitem.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolispagebutton.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisindicator.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolistabs.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisscrollpanel.lua")

include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolistextentry.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisgangshoppanel.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisgangupgradepanel.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisshoppanel.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisjobpanel.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisplayerpanel.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolischeckbox.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolistooltip.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisimage.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolispanel.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manoliscategory.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisadvancedpanel.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisgangmemberpanel.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisitempanel.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisclearpanel.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manoliscombobox.lua")

include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisdmenu.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolismenuoption.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisachievementpanel.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolischaracter.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manoliscolorpalette.lua")
include(GM.FolderName.."/gamemode/modules/popcorn-vgui/manolisavatar.lua")


manolis.popcorn.enableClicker = function(val)
	if(val) then
		gui.EnableScreenClicker(val)
		manolis.popcorn.activePopups = manolis.popcorn.activePopups + 1
	else
		manolis.popcorn.activePopups = math.max(manolis.popcorn.activePopups-1,0)
		if(manolis.popcorn.activePopups<=0) then
			gui.EnableScreenClicker(false)
		end
	end
end


function ManolisMenu(parent)
	if(!parentmenu) then CloseDermaMenus() end
	local menu = vgui.Create("ManolisDMenu")
	menu:MakePopup()
	return menu
end

function Manolis_PlayerSelect(title, desc, button, callback)

	local selected

	local frame = vgui.Create("ManolisFrame")
    frame:SetRealSize(300+10+10,175)
    frame:Center()
    frame:SetText(title)
    frame:MakePopup()
    frame:SetBackgroundBlur(true)
    frame:SetZPos(30000)
    frame:SetBackgroundBlurOverride(true)


    local p = vgui.Create("DLabel", frame)
   	p:SetText(desc)
    p:SetFont("manolisItemInfoName")
    p:SizeToContents()
    p:SetPos(10, 45+5)

    local bSelect = vgui.Create("ManolisComboBox", frame)
    bSelect:SetPos(10, 45+5+p:GetTall()+10)
    bSelect:SetSize(300,35)

    local plMiL = player.GetAll()
    for k,v in pairs(plMiL) do
    	if(v==LocalPlayer()) then
    		table.remove(plMiL, k)
    	end
    end

    for k,v in pairs(plMiL) do
       	bSelect:AddChoice(v:Name())
    end


    bSelect.OnSelect = function(panel,index,value)
        selected = plMiL[index] or nil
    end

    local saveButton = vgui.Create("ManolisButton", frame)
    saveButton:SetPos(10,45+5+p:GetTall()+10+bSelect:GetTall()+10)
    saveButton:SetWide(300)
    saveButton:SetText(button)
    saveButton.DoClick = function() if(selected) then callback(selected) end frame:Close() end

end

function Manolis_StringRequest(title, desc, def, button, callback)
local selected

	local frame = vgui.Create("ManolisFrame")
    frame:SetRealSize(300+10+10,175)
    frame:Center()
    frame:SetText(title)
    frame:MakePopup()
    frame:SetBackgroundBlur(true)
    frame:SetBackgroundBlurOverride(true)
    frame:SetZPos(30000)


    local p = vgui.Create("DLabel", frame)
   	p:SetText(desc)
    p:SetFont("manolisItemInfoName")
    p:SizeToContents()
    p:SetWide(300)
    p:SetPos(10, 45+5)

    local saveButton

	local bInput = vgui.Create("ManolisTextEntry", frame)
	bInput:SetPos(10,45+5+p:GetTall()+10)
	bInput:SetSize(300,35)
	bInput:SetValue(def)
	bInput.OnEnter = function(s)
		saveButton.DoClick()
	end

	bInput:RequestFocus()


    saveButton = vgui.Create("ManolisButton", frame)
    saveButton:SetPos(10,45+5+p:GetTall()+10+bInput:GetTall()+10)
    saveButton:SetWide(300)
    saveButton:SetText(button)
    saveButton.DoClick = function() callback(bInput:GetValue() or '') frame:Close() end

end

function Manolis_Query( strText, strTitle, ... )

	local Window = vgui.Create( "ManolisFrame" )
		Window:SetText( strTitle or "Message Title (First Parameter)" )
		Window:SetDraggable( false )
		Window:ShowCloseButton( false )
		Window:SetBackgroundBlur( true )
		Window:SetZPos(32767)
		Window:MakePopup()
		Window:SetBackgroundBlurOverride(true)
		
	local InnerPanel = vgui.Create( "DPanel", Window )
		InnerPanel:SetPaintBackground( false )
	
	local Text = vgui.Create( "DLabel", InnerPanel )
		Text:SetText( strText or "Message Text (Second Parameter)" )

		Text:SetContentAlignment( 5 )
		Text:SetTextColor( color_white )
		Text:SetFont("manolisItemInfoName")
		Text:SizeToContents()

		Text:SetTall(40)
	

	local ButtonPanel = vgui.Create( "DPanel", Window )
		ButtonPanel:SetTall( 47 )
		ButtonPanel:SetPaintBackground( false )

	-- Loop through all the options and create buttons for them.
	local NumOptions = 0
	local x = 10

	for k=1, 8, 2 do
		
		local Text = select( k, ... )
		if Text == nil then break end
		
		local Func = select( k+1, ... ) or function() end
	
		local Button = vgui.Create( "ManolisButton", ButtonPanel )
			Button:SetText( Text )
			Button:SizeToContents()

			surface.SetFont("manolisButtonFont")
			local w,h = surface.GetTextSize(Text)
			Button:SetWide( math.max(101, w + 20 ) )

			Button:SetTall(40)

			Button.DoClick = function() Window:Close(); Func() end
			Button:SetPos( x, 5 )
			
		x = x + Button:GetWide()+10
			
		ButtonPanel:SetWide( x ) 
		NumOptions = NumOptions + 1
	
	end

	
	local w, h = Text:GetSize()
	w = math.max( w+60, ButtonPanel:GetWide() )

	Window:SetRealSize( w, h + 25 + 45 +50  )
	Window:Center()
	
	InnerPanel:StretchToParent( 5, 25, 5, 45 )
	
	Text:StretchToParent( 5, 5, 5, 5 )	
	
	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )
	
	Window:MakePopup()
	Window:DoModal()
	
	if ( NumOptions == 0 ) then
	
		Window:Close()
		Error( "Manolis_Query: Created Query with no Options!?" )
		return nil
	
	end
	
	return Window

end

local matBlurScreen = Material( "pp/blurscreen" )
local blurDrawn = -1

hook.Add("HUDPaint", "manolis:DrawBlur", function()
	if(blurDrawn>0) then
		surface.SetMaterial( matBlurScreen )
		surface.SetDrawColor( 255, 255, 255, 255 )

		local Fraction = 1
		local x,y = 0,0
		for i=0.33, 1, 0.33 do
			matBlurScreen:SetFloat( "$blur", Fraction * 5 * i )
			matBlurScreen:Recompute()
			if ( render ) then render.UpdateScreenEffectTexture() end -- Todo: Make this available to menu Lua
			surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
		end

		surface.SetDrawColor( 10, 10, 10, 200 * Fraction )
		surface.DrawRect( x * -1, y * -1, ScrW(), ScrH() )
	end
end)

function Manolis_DrawBackgroundBlur( panel, starttime )
	blurDrawn = 2
end


function Manolis_DrawBackgroundBlurOverride( panel, starttime )


		local Fraction = 1

		if ( starttime ) then
			Fraction = math.Clamp( (SysTime() - starttime) / 1, 0, 1 )
		end

		local x, y = panel:LocalToScreen( 0, 0 )

		DisableClipping( true )

		surface.SetMaterial( matBlurScreen )
		surface.SetDrawColor( 255, 255, 255, 255 )

		for i=0.33, 1, 0.33 do
			matBlurScreen:SetFloat( "$blur", Fraction * 5 * i )
			matBlurScreen:Recompute()
			if ( render ) then render.UpdateScreenEffectTexture() end -- Todo: Make this available to menu Lua
			surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
		end

		surface.SetDrawColor( 10, 10, 10, 200 * Fraction )
		surface.DrawRect( x * -1, y * -1, ScrW(), ScrH() )

		DisableClipping( false )
end

hook.Add("Think", "manolis:blurDraw", function()
	if(blurDrawn>0) then
		blurDrawn = blurDrawn-1
	end
end)

manolis.popcorn.dermaScrollCSS = [[
	::-webkit-scrollbar {
	    width: 10px;
	}
	::-webkit-scrollbar-track {
	   background-color: rgb(35,40,48)
	}

	::-webkit-scrollbar-thumb {
	   background-color: rgb(53,58,69);
	}

	::-webkit-scrollbar-button {
	     display:none;
	}
]]

local baseFont = 'Open Sans'

surface.CreateFont("manolisHUD", {
	font = 'Helsinki',
	size = 25,
	antialias = true,
	
})

surface.CreateFont("manolisHUDX", {
	font = 'Bolts SF',
	size = 14,
	antialias = true,
	
})

surface.CreateFont("manolisHUD2", {
	font = 'Helsinki',
	size = 14,
	antialias = true,
	
})

surface.CreateFont("manolisHUD3", {
	font = 'Roboto Bold',
	size = 20,
	antialias = true,
	
})



surface.CreateFont("manolisLocationLarge", {
	font = 'Helsinki',
	size = 64,
	shadow=true,
	antialias = true,
	
})


surface.CreateFont("manolisLocationSmall", {
	font = 'Helsinki',
	size = 32,
	shadow=true,
	antialias = true,
	
})


surface.CreateFont("manolisHUDSmall", {
	font = 'Roboto Bold',
	size = 14,
	
	antialias = true,
	
})


surface.CreateFont("manolisItemInfoName", {
	font = baseFont,
	size = 18,
	antialias = true,
	weight=400,
	height = 18,
})


surface.CreateFont( "manolisNotifyGang", {
	font	= baseFont,
	size	= 18,
	weight	= 1000
} )



surface.CreateFont("manolisTerritory", {
	font = 'Helsinki',
	size = 28,
	antialias = true,
	weight=400,
	height = 18,
})

surface.CreateFont("ManolisXPFontGang", {
	font = baseFont,
	size = 15,
	antialias = true,
	weight=400,
	height = 18,
})


surface.CreateFont("ManolisXPText", {
	font = 'Roboto Bold',
	size = 14,
	antialias = true,
	weight=200,

	height = 18,
})


surface.CreateFont("ManolisGangLog", {
	font = baseFont,
	size = 18,
	height=14,
	antialias = true,
	weight=400,
})


surface.CreateFont("manolisItemFont", {
	font = "Calibri",
	size = 18,
})

surface.CreateFont("manolisItemFontB", {
	font = "Calibri",
	shadow = true,
	size = 18,
})



surface.CreateFont("manolisDrawDisplay", {
	font = baseFont,
	size = 25,
	antialias = true,
	weight=400,
	height = 18,
})
surface.CreateFont("manolisDrawDisplaySmall", {
	font = baseFont,
	size = 25,
	antialias = true,
	weight=400,
	height = 12,
})

surface.CreateFont("manolisF4ItemTab", {
	font = baseFont,
	size = 19,
	antialias = true,
	weight = 400,
	height = 23,
})

surface.CreateFont("manolisGangName", {
	font = baseFont,
	size = 32,
	antialias = true,
	weight = 700,
})

surface.CreateFont("ManolisScoreboardFont", {
	font = "Tahoma",
	size = 16,
	weight = 1000
})

surface.CreateFont("manolisGangPoints", {
	font = baseFont,
	size = 25,
	antialias = true,
	weight = 300,
})
surface.CreateFont("manolisGangInfo", {
	font = baseFont,
	size = 18,
	antialias = true,
	weight = 300,
})

surface.CreateFont('ManolisItemQuantity', {
	font = baseFont,
	size=18,
	antialias = true,
	weight=800,
	height=25
})

surface.CreateFont("manolisItemInfoNameBold", {
	font = baseFont,
	size = 18,
	antialias = true,
	weight=600,
	height = 18,
})

surface.CreateFont("manolisPartyNameBold", {
	font = baseFont,
	size = 18,
	weight = 700
})

surface.CreateFont("manolisName", {
	font = baseFont,
	size = 35,
	weight = 200
})

surface.CreateFont("manolisNameSmall", {
	font = baseFont,
	size = 18,
	weight = 200
})


surface.CreateFont("manolisAction", {
	font = baseFont,
	size = 26,
	weight = 200
})
surface.CreateFont("manolisAction2", {
	font = baseFont,
	size = 19,
	weight = 200
})


surface.CreateFont("manolisInfoLeft", {
	font = baseFont,
	size = 22,
	weight = 700
})

surface.CreateFont("manolisInfoRight", {
	font = baseFont,
	size = 22,
	weight = 300
})


surface.CreateFont("manolisItemNope", {
	font = baseFont,
	size = 21,
	weight = 700,
	outline = false
})

surface.CreateFont("manolisItemNopeF", {
	font = baseFont,
	size = 19,
	weight = 700,
	outline = false
})

surface.CreateFont("manolisItemNopeB", {
	font = baseFont,
	size = 27,
	weight = 700,
	outline = false
})

surface.CreateFont("manolisItemNopeC", {
	font = baseFont,
	size = 24,
	weight = 700,
	outline = false
})

surface.CreateFont("manolisItemAchievement", {
	font = baseFont,
	size = 20,
	weight = 500,
	outline = false
})


surface.CreateFont("manolisItemAchievementName", {
	font = baseFont,
	size = 18,
	weight = 500,
	outline = false
})

surface.CreateFont("manolisItemAchievementDesc", {
	font = baseFont,
	size = 18,
	weight = 500,
	outline = false
})

surface.CreateFont("manolisItemNopeD", {
	font = baseFont,
	size = 22,
	weight = 700,
	outline = false
})

surface.CreateFont("manolisItemNopeDO", {
	font = baseFont,
	size = 22,
	weight = 700,
	outline = false
})

surface.CreateFont("manolisItemNopeE", {
	font = baseFont,
	size = 20,
	weight = 600,
	outline = false
})

surface.CreateFont("manolisAlertFont", {
	font = 'Helsinki',
	size = 22,
	weight = 600,
	outline = false
})

surface.CreateFont("manolisDoorDisplayFont", {
	font = baseFont,
	size = 20,
	weight = 700,
	outline = false
})

surface.CreateFont("manolisRentFont", {
	font = 'Helsinki',
	size = 24,
	weight = 600,
	outline = false
})

surface.CreateFont("manolisDoorFont", {
	font = 'Helsinki',
	size = 36,
	weight = 600,
	outline = false
})



surface.CreateFont("manolisQuestFont", {
	font = 'Helsinki',
	size = 40,
	weight = 600,
	outline = false
})


surface.CreateFont("manolisPartyNameBoldSmall", {
	font=baseFont,
	size = 15
})

surface.CreateFont("manolisGhostTextFont", {
	font = baseFont,
	size = 24,
	antialias = true,
	weight=600,
	height = 18,
})

surface.CreateFont("manolisButtonFont", {
	font = "Tahoma",
	size = 13,
	antialias = true,
	weight=500,
	height = 16,
})

surface.CreateFont("manolisButtonFontAlt", {
	font = baseFont,
	size = 16,
	antialias = true,
	weight=300,

})

surface.CreateFont("manolisF4ButtonFont", {
	font = baseFont,
	size = 17,
	antialias = true,
	weight=750,
})


surface.CreateFont("manolisF4Name", {
	font = baseFont,
	size = 20,
	antialias = true,
	weight=400,
	height = 18,
})
surface.CreateFont("manolisF4Header", {
	font = baseFont,
	size = 36,
	antialias = true,
	weight=400,
	height = 18,
})

surface.CreateFont("manolisF4Button", {
	font = baseFont,
	size = 18,
	antialias = true,
	weight = 600,
	height = 22
})

surface.CreateFont("manolisTradeMoneyName", {
	font = baseFont,
	size = 20,
	antialias = true,
	weight=400,
})


surface.CreateFont("manolisItemInfoLevel", {
	font = baseFont,
	size = 15,
	antialias = true,
	weight=200,
})
surface.CreateFont("manolisBigC", {
	font = baseFont,
	size = 35,
	antialias = true,
	weight=200,
})
surface.CreateFont("manolisC", {
	font = baseFont,
	size = 20,
	antialias = true,
	weight=200,
})

surface.CreateFont( "manolisTimerFont", {
    font = "Helsinki",
    size = 64,
    weight = 600
})

surface.CreateFont( "manolisTimerFontSM", {
    font = "Helsinki",
    size = 25,
    weight = 600
})


surface.CreateFont("manolisAffectsTitle", {
	font = baseFont,
	size = 23,
	weight = 700
})

surface.CreateFont('manolisItemCreditDescription', {
	font = baseFont,
	size = 18,
	weight = 300,
	outline = false,
	height=25
})

surface.CreateFont('manolisItemCreditDesc', {
	font = baseFont,
	size = 18,
	weight = 300,
	outline = false,
	height=25
})