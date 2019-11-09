if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.quests) then manolis.popcorn.quests = {} end
if(!manolis.popcorn.quests.radioDialogue) then manolis.popcorn.quests.radioDialogue = {} end

local base = 'syndicate/gamemode/quests/'
for k,v in pairs(file.Find(base.."*.lua", "LUA")) do
	include(base..v)
end

local questFrame
net.Receive('ManolisPopcornQuestOpen', function()
	local npc = net.ReadString()
	local quests = net.ReadTable() or {}
	local deals = net.ReadTable() or {}

	if(questFrame and IsValid(questFrame))then return end
	questFrame = vgui.Create("ManolisFrame")
	questFrame:SetRealSize(650,450)
	questFrame:SetTitle(manolis.popcorn.quests.GetNPCName(npc))
	questFrame:Center()
	questFrame:SetBackgroundBlur(true)
	questFrame:MakePopup()

	local q = vgui.Create("Panel", questFrame)
	q:SetSize(650,450-40)
	q:SetPos(0,40)

	local tabs = vgui.Create("ManolisTabs", q)
	tabs:SetPos(0,0)
	tabs:SetSize(650,450-40)



	local questList = vgui.Create("ManolisScrollPanel")

	questList:SetSize(650-10, 355)



	for k,v in pairs(quests) do
		local quest = manolis.popcorn.quests.GetQuestByUiq(v)
		local a = vgui.Create("ManolisItemPanel")
		a:Go(quest.uiq,quest.name..' ('..quest.type..' Quest)','manolis/popcorn/npcs/icons/'..quest.npc..'.png',DarkRP.formatMoney(manolis.popcorn.quests.GetQuestCost(LocalPlayer())),'Start Quest', function()
			RunConsoleCommand('ManolisPopcornAcceptQuest',quest.uiq)
			questFrame:Close()
		end)

		a:SetDescriptionColor((((LocalPlayer():getDarkRPVar('money') or 0) >= manolis.popcorn.quests.GetQuestCost(LocalPlayer())) and Color(0,255,0) or Color(255,0,0)))

		questList:Add(a)
	end

	if(#quests==0) then
		local noQuests = vgui.Create('DLabel')
		noQuests:SetContentAlignment(5)
		noQuests:SetWide(650)
		noQuests:SetTall(100)
		noQuests:SetFont('manolisTradeMoneyName')
		noQuests:SetText('No quests available!')
		questList:Add(noQuests)
	end

	tabs:AddTab("Quests", questList)

	local dealList = vgui.Create("ManolisScrollPanel")
	dealList:SetSize(650-10,355)

	for k,v in pairs(deals) do
		local deal = manolis.popcorn.quests.deals.GetDealByUiq(v)
		local a = vgui.Create("ManolisItemPanel")
		a:Go(deal.uiq,deal.name,deal.icon, DarkRP.formatMoney(deal.price), 'Accept Deal',function()
			RunConsoleCommand('ManolisPopcornAcceptDeal',deal.uiq)
			questFrame:Close()
		end)
		a:SetDescriptionColor((((LocalPlayer():getDarkRPVar('money') or 0) >= deal.price) and Color(0,255,0) or Color(255,0,0)))

		dealList:Add(a)
	end

	if(#deals==0) then
		local noDeals = vgui.Create('DLabel')
		noDeals:SetContentAlignment(5)
		noDeals:SetWide(650)
		noDeals:SetTall(100)
		noDeals:SetFont('manolisTradeMoneyName')
		noDeals:SetText('No deals available!')
		dealList:Add(noDeals)
	end

	tabs:AddTab("Deals", dealList)

		questList:SetPos(5,50)
		dealList:SetPos(5,50)


end)

manolis.popcorn.quests.npcMaterials = {
	bob = Material('manolis/popcorn/npcs/bob.png'),
	wendy = Material('manolis/popcorn/npcs/wendy.png'),
	michael = Material('manolis/popcorn/npcs/michael.png'),
	simon = Material('manolis/popcorn/npcs/simon.png'),
	turkish = Material('manolis/popcorn/npcs/turkish.png'),
	radio = Material('manolis/popcorn/npcs/radio.png')
}

local fade = Material('manolis/popcorn/fade.png')
local rot = 0
local rotDir = false
local playAnim = true
local animPosY = -400
local animPosX = 0
local animPosXTarget = 0
local animPosYTarget = 600
local hasCloseAnimPlayed = true
local headPos = 0
local isInRadio = false
manolis.popcorn.quests.resetAnimation = function()
	manolis.popcorn.quests.playAnim = true
	animPosY = -400
	animPosX = 0
	animPosXTarget = 0
	animPosYTarget = 600
	headPos = 0
	hasCloseAnimPlayed = true
end

local turnHUDBack = false
hook.Add("HUDPaint", "manolis:QuestDialogue", function()
    if(manolis.popcorn.quests.playAnim or !hasCloseAnimPlayed) then
    	if(manolis.popcorn.quests.dialogue or !hasCloseAnimPlayed) then
    		manolis.popcorn.hud.shouldDraw = false
    		turnHUDBack = true

    		surface.SetDrawColor(Color(255,255,255,255))

    		local frac = FrameTime()*15

			if(!hasCloseAnimPlayed and !manolis.popcorn.quests.playAnim) then
				animPosYTarget = -500

				frac = 0.03
				if(headPos==0) then
					headPos = animPosY
				end

				if(animPosY<=0) then
					hasCloseAnimPlayed = true
				end
			end

	        animPosX = math.Clamp(Lerp(frac, animPosX,animPosXTarget),-300,ScrW()/2)
	        animPosY = math.Clamp(Lerp(frac, animPosY, animPosYTarget),-600,600)

			surface.SetMaterial(fade)
		    surface.SetDrawColor(Color(255,255,255,255))
		    surface.DrawTexturedRectUV(0,ScrH() - animPosY,ScrW(),600,0,0,1,1)

		   	surface.SetFont('manolisQuestFont')
		    local str = manolis.popcorn.quests.dialogue
		    local x,y = surface.GetTextSize(str)
		    x=x-(300)

		    if(x>ScrW()) then
		    	str = '...'
		    end

		    animPosXTarget = ScrW()/2-(x/2)-300/2

		    surface.SetDrawColor(255,255,255)
		    surface.SetMaterial(manolis.popcorn.quests.npcMaterials[manolis.popcorn.quests.useNPC])

		    draw.DrawText(str, 'manolisQuestFont', ScrW()/2 - (x/2),ScrH()-animPosY+485 - (y/2)-20)

		   	local y = hasCloseAnimPlayed and ScrH()-ScrH()/4+75 or ScrH()-ScrH()/4+75-(animPosY-headPos)
	
		   	if(!((animPosYTarget!=-500) or (animPosY>0 or !hasCloseAnimPlayed))) then return end
		  
		   	surface.DrawTexturedRectRotated(animPosX,y,300,425,rot)  
		  
		    rot = rot + (rotDir and 0.2 or -0.2)


			if(rot>10) then rotDir = false end
			if(rot<-10) then rotDir = true end

		end
    elseif(turnHUDBack) then
    	turnHUDBack = false
    	manolis.popcorn.hud.shouldDraw = true
    end
end)

hook.Add("RenderScreenspaceEffects", "VignettePopcornNPC", function()
	if(manolis.popcorn.quests.playAnim) then
    	if(manolis.popcorn.quests.dialogue) then
        DrawMaterialOverlay( "manolis/popcorn/overlays/vignette01", 10 )
       DrawMaterialOverlay( "manolis/popcorn/overlays/vignette01", 10 )
       DrawMaterialOverlay( "manolis/popcorn/overlays/vignette01", 10 )
       end
      end
end)

net.Receive('ManolisPopcornStartDialogue', function()
	local npc = net.ReadString()
	local dialogue = net.ReadString()
	if(!manolis.popcorn.quests.npcMaterials[npc]) then return end

	manolis.popcorn.quests.doQuestDialogue(npc,dialogue)	
end)

net.Receive('ManolisPopcornStartRadioDialogue', function()
	local dialogue = net.ReadTable()
	manolis.popcorn.quests.radioDialogue = dialogue

	surface.PlaySound( "ambient/levels/prison/radio_random2.wav" )

	manolis.popcorn.quests.doQuestDialogue('radio', dialogue[1])

	isInRadio = 1

end)

hook.Add('PlayerBindPress', 'manolis:radioDialogue', function(ply,bind,pressed)

	if(pressed and bind=='+use') then
		if(isInRadio) then
			if(!manolis.popcorn.quests.radioDialogue[isInRadio+1]) then
				manolis.popcorn.quests.playAnim = false
				hasCloseAnimPlayed = false
				isInRadio = false
				surface.PlaySound( "ambient/levels/prison/radio_random2.wav" )
			else
				manolis.popcorn.quests.dialogue = manolis.popcorn.quests.radioDialogue[isInRadio+1]
				isInRadio = isInRadio + 1
			end
		end
	end
end)

net.Receive('ManolisPopcornNextDialogue', function()
	local dialogue = net.ReadString()
	if(dialogue=='') then
		manolis.popcorn.quests.playAnim = false
		hasCloseAnimPlayed = false
	else
		manolis.popcorn.quests.playAnim = true
		animPosY=-400
		headPos = 0
		manolis.popcorn.quests.dialogue = dialogue
	end
end)

manolis.popcorn.quests.doQuestDialogue = function(npc, text)
	manolis.popcorn.quests.dialogue = text
	manolis.popcorn.quests.useNPC = npc
	manolis.popcorn.quests.resetAnimation()
end