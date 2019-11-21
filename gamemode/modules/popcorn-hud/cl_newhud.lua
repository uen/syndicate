if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.hud) then manolis.popcorn.hud = {} end
if(!manolis.popcorn.equipment) then manolis.popcorn.equipment = {} end
if(!manolis.popcorn.f4) then manolis.popcorn.f4 = {} end
if(!manolis.popcorn.f1) then manolis.popcorn.f1 = {} end
if(!manolis.popcorn.hud.frameTime) then manolis.popcorn.hud.frameTime = 0 end
if(!manolis.popcorn.hud.actions) then manolis.popcorn.hud.actions = {} end

manolis.popcorn.hud.shouldDraw = true

local actionBarBackground = Material('manolis/popcorn/hud/actionbarbackground.png','smooth mips')

local outline = Material('manolis/popcorn/hud/2/outline.png')
local bg = Material('manolis/popcorn/hud/2/bg.png')
local buttonMaterial = Material('manolis/popcorn/hud/2/button.png')
local armor = Material('manolis/popcorn/hud/2/right.png')
local health = Material('manolis/popcorn/hud/2/left.png')


local drawDisplay = {
	popcorn_printer							= true,
	popcorn_forge							= true,
	ent_cooler								= true,
	spawned_entity							= true,
	spawned_weapon							= true,
	gang_territory							= true,
	capture_point							= true,
	building_plug							= true,
	spawned_shipment						= true,
	gang_printer							= true,
	popcorn_generator						= true,
	popcorn_fuel							= true,
	popcorn_enricher						= true,
	popcorn_rod								= true,
	popcorn_bomb							= true,
	popcorn_cash							= true,
	popcorn_blueprint_infuser				= true,
	popcorn_blueprint_infuser_card			= true
}

local buttons = {}
buttons[1] = {DoClick = function() manolis.popcorn.equipment.toggle() end, material = Material('manolis/popcorn/hud/2/character.png')}
buttons[2] = {DoClick = function() manolis.popcorn.inventory.toggle() end, material = Material('manolis/popcorn/hud/2/fist.png')}
buttons[3] = {DoClick = function() manolis.popcorn.f4.toggleF4Menu() end, material = Material('manolis/popcorn/hud/2/star.png')}

for k,v in pairs(buttons) do
	table.insert(manolis.popcorn.hud.actions, v)
end

local materials = {}
materials.healthArmor = Material('manolis/popcorn/health.fw.png')
materials.armorGradient = Material('manolis/popcorn/armor-gradient.fw.png', 'noclamp')
materials.healthGradient = Material('manolis/popcorn/hud/6/xp_fill.png', 'smooth mips noclamp')
materials.stats = Material('manolis/popcorn/stats.fw.png')


local JobText = ''
local MoneyText = ''
local MaxHealth = 100
local MaxArmor = 0 
local OldHealth = 0
local oldY = 0
local yTarget = 0
local slotTarget = 0
local oldSlotY = 0
local OldArmor = 0
local OldTime = CurTime()
local oldOffset = Vector(0,0,0)

hook.Add("DarkRPVarChanged", "manolis:popcorn:hud:DarkRPVarChanged", function(ply, var, _, new)
    if ply ~= LocalPlayer() then return end


    if var == "job" then
    	JobText = DarkRP.getPhrase("job", var == "job" and new or LocalPlayer():getDarkRPVar("job") or "")
    end

    if(var=='money') then
    	MoneyText = var == "money" and DarkRP.formatMoney(new) or DarkRP.formatMoney(LocalPlayer():getDarkRPVar("money"))
    end

    if(var=='maxhealth') then
        MaxHealth = var == "maxhealth" and new or LocalPlayer():getDarkRPVar("maxhealth")
    end

    if(var=='maxarmor') then
        MaxArmor = var == "maxarmor" and new or LocalPlayer():getDarkRPVar("maxarmor")
    end
end)



local gangLogos = {}

local meta = FindMetaTable('Player')
meta.drawPlayerInfo = function(self)
	local pos = self:EyePos()

    pos.z = pos.z + 10 -- The position we want is a bit above the position of the eyes
    pos = pos:ToScreen()
    if not self:getDarkRPVar("wanted") then
        -- Move the text up a few pixels to compensate for the height of the text
        pos.y = pos.y - 50
    end

    if GAMEMODE.Config.showname then
        local nick, plyTeam = self:Nick(), self:Team()
        draw.DrawNonParsedText(nick, "DarkRPHUD2", pos.x + 1, pos.y + 1, Color(0,0,0), 1)
        draw.DrawNonParsedText(nick, "DarkRPHUD2", pos.x, pos.y, RPExtraTeams[plyTeam] and RPExtraTeams[plyTeam].color or team.GetColor(plyTeam) , 1)
    end


    local level = self:getDarkRPVar("level") or 1
    draw.DrawNonParsedText('Level '..level, "DarkRPHUD2", pos.x + 1, pos.y + 21,  Color(0,0,0,255), 1)
    draw.DrawNonParsedText('Level '..level, "DarkRPHUD2", pos.x, pos.y + 20, Color(255,255,255), 1)

    local teamname = self:getDarkRPVar("job") or team.GetName(self:Team())
    draw.DrawNonParsedText(teamname, "DarkRPHUD2", pos.x + 1, pos.y + 41,  Color(0,0,0,255), 1)
    draw.DrawNonParsedText(teamname, "DarkRPHUD2", pos.x, pos.y + 40, Color(255,255,255), 1)


	local pos = self:EyePos()
	pos.z = pos.z + 25
	pos = pos:ToScreen()
	


	local distance = self:GetPos():Distance(LocalPlayer():GetPos())
	local size = 65//64-math.Clamp((distance/1500)*50,0,50)


	if((self:getDarkRPVar('gang') or 0>0) and (self:getDarkRPVar('gangdata')) and (self:getDarkRPVar('gangdata')).logo) then
		if(!gangLogos[self:getDarkRPVar('gang')]) then
	        gangLogos[self:getDarkRPVar('gang')] = Material('manolis/popcorn/icons/gangs/'..self:getDarkRPVar('gangdata').logo..'.png')
	    end
	    
	    local c1 = Color(255,255,255)
	    local c2 = Color(255,255,255)
	    if(self:getDarkRPVar('gangdata').color and self:getDarkRPVar('gangdata').secondcolor) then
	    	local c1x = split(self:getDarkRPVar('gangdata').color, ',')
	    	local c2x = split(self:getDarkRPVar('gangdata').secondcolor, ',')

	    	c1 = Color(c1x[1],c1x[2],c1x[3])
	    	c2 = Color(c2x[1],c2x[2],c2x[3])
	    end


		surface.SetMaterial(gangLogos[self:getDarkRPVar('gang')])
		surface.SetDrawColor(c1)
		surface.DrawTexturedRect(pos.x -(size/2)-2,pos.y-12-(size/2)-2,size,size)

		surface.SetMaterial(gangLogos[self:getDarkRPVar('gang')])
		surface.SetDrawColor(c2)
		surface.DrawTexturedRect(pos.x-(size/2),pos.y-12-(size/2),size,size)

	end


end

meta.drawRivalInfo = function(self)
	local pos = self:EyePos()
	pos.z = pos.z + 25
	pos = pos:ToScreen()
	
	    if((self:getDarkRPVar('gang') or 0)>0 and manolis.popcorn.gangs.gang and manolis.popcorn.gangs.gang.rivals) then
	        if(manolis.popcorn.gangs.gang.rivals[self:getDarkRPVar('gang')]) then

	            local distance = self:GetPos():Distance(LocalPlayer():GetPos())
	            local size = 65//64-math.Clamp((distance/1500)*50,0,50)



	            if(!gangLogos[self:getDarkRPVar('gang')]) then
	                gangLogos[self:getDarkRPVar('gang')] = Material('manolis/popcorn/icons/gangs/'..manolis.popcorn.gangs.gang.rivals[self:getDarkRPVar('gang')].logo..'.png')
	            end


	        	draw.DrawNonParsedText('Rival', "DarkRPHUD2", pos.x + 1, pos.y + 61,  Color(0,0,0,255), 1)
	        	draw.DrawNonParsedText('Rival', "DarkRPHUD2", pos.x, pos.y + 60, Color(255,0,0), 1) 


			    local c1 = Color(255,255,255)
			    local c2 = Color(255,255,255)
			    if(self:getDarkRPVar('gangdata').color and self:getDarkRPVar('gangdata').secondcolor) then
			    	local c1x = split(self:getDarkRPVar('gangdata').color, ',')
			    	local c2x = split(self:getDarkRPVar('gangdata').secondcolor, ',')

			    	c1 = Color(c1x[1],c1x[2],c1x[3])
			    	c2 = Color(c2x[1],c2x[2],c2x[3])
			    end
	    

	            surface.SetMaterial(gangLogos[self:getDarkRPVar('gang')])
	            surface.SetDrawColor(c1)
	            surface.DrawTexturedRect(pos.x -(size/2)-2,pos.y-12-(size/2)-2,size,size)

	            surface.SetMaterial(gangLogos[self:getDarkRPVar('gang')])
	            surface.SetDrawColor(c2)
	            surface.DrawTexturedRect(pos.x-(size/2),pos.y-12-(size/2),size,size)



	        end
	    
	end
end

concommand.Add('x', function()
	hook.Run('InitPostEntity')
end)
hook.Add('InitPostEntity', 'manolis:buyIcons', function()



	if(manolis.popcorn.config.hud.actionBar) then
	    local hudContainer = vgui.Create('Panel')
	    hudContainer:SetSize(1024,128)
	    hudContainer:SetPos(ScrW()/2 - (1024/2), ScrH()-128+3)    

	    local bgPanel = vgui.Create('DImage', hudContainer)
	    bgPanel:SetMaterial(bg)
	    bgPanel:SetSize(hudContainer:GetSize())


	    local barWidth = 176
	    local healthPanel = vgui.Create('Panel',hudContainer)
	    healthPanel:SetSize(barWidth,13)
	    healthPanel:SetPos(143,72)
	    healthPanel.Paint = function(self,w,h)
		    local maxHealth = LocalPlayer():getDarkRPVar('maxhealth') or 100
		    OldHealth = Lerp(0.05, OldHealth, LocalPlayer():Health())
		    local healthLevel = OldHealth / maxHealth

		    surface.SetDrawColor(Color(255,255,255,255))
		    surface.DrawRect(13,0,w-13,13)
		    
		    surface.SetMaterial(materials.healthGradient)
		    surface.DrawTexturedRectUV(13,0,w-13,13,0,0,1,1)


		    surface.SetMaterial(health)
		    surface.DrawTexturedRect(0,0,13,13)
		    surface.SetDrawColor(manolis.popcorn.config.promColor)
		    surface.DrawRect(w-(w*healthLevel)+13,0,w-13,13)
		    surface.DrawTexturedRect(w-(w*healthLevel),0,13,13)


		    surface.SetDrawColor(manolis.popcorn.config.promColor)
		    surface.SetMaterial(materials.healthGradient)
		    surface.DrawTexturedRectUV(w-(w*healthLevel)+13,0,w-13,13,0,0,1,1)


		    draw.DrawText(math.Round(OldHealth)..'/'..math.floor(maxHealth),'manolisHUDX', w/2+1,.3, Color(0,0,0,255), TEXT_ALIGN_CENTER)
		   
		end





		local healthText = vgui.Create('Panel',hudContainer)
		healthText:SetPos(-20,91)
		healthText:SetSize(300,90)
		healthText.Paint = function(self,w,h)
			draw.DrawText(DarkRP.formatMoney(LocalPlayer():getDarkRPVar('money') or 0),'manolisHUDX', w/2+16, 0, manolis.popcorn.config.promColor, TEXT_ALIGN_LEFT)
			draw.DrawText(LocalPlayer():getDarkRPVar('job') or '','manolisHUDX', w/2, 18, Color(255,255,255,255), TEXT_ALIGN_LEFT)
		end



		local armorPanel = vgui.Create('Panel',hudContainer)
		armorPanel:SetSize(barWidth,13)
		armorPanel:SetPos(703,72)
		armorPanel.Paint = function(self,w,h)
		    local maxArmor = LocalPlayer():getDarkRPVar('maxarmor') or 100
		    OldArmor = Lerp(0.05, OldArmor, LocalPlayer():Armor())
		    local armorLevel = OldArmor / maxArmor

		    local col = Color(10,195,245)
		    surface.SetDrawColor(Color(255,255,255,255))

		    surface.SetMaterial(armor)
		    surface.DrawTexturedRect(w-10,0,13,13)

		    surface.SetMaterial(materials.healthGradient)
		    surface.DrawTexturedRectUV(0,0,w-10,13,0,0,1,1)


		    surface.SetDrawColor(col)
		    surface.SetMaterial(armor)
		    surface.DrawTexturedRect((w*armorLevel)-9,0,13,13)


			surface.SetDrawColor(col)
		    surface.SetMaterial(materials.healthGradient)
		    surface.DrawTexturedRectUV(0,0,w*armorLevel-9,13,0,0,1,1)

		    draw.DrawText(math.floor(LocalPlayer():Armor())..'/'..(math.floor(maxArmor)),'manolisHUDX', w/2+1,.3, Color(0,0,0,255), TEXT_ALIGN_CENTER)
	    end



		local size = 53
		local spacing = 2
		local yMod = 10
		local slots = vgui.Create('Panel')
		slots:SetPos(ScrW()/2 - (((7*size)+(7*spacing))/2), ScrH()-79+yMod)
		slots:SetSize(((7*size)+(7*spacing)), size)
		manolis.popcorn.hud.slots = {}
		manolis.popcorn.hud.slots.slots = {}
		for i=0,7 do
		    local slot = vgui.Create("ManolisSmallSlot", slots)
		    slot:SetSize(size,size)
		    slot:SetPos((i*size)+(i*spacing),0)

		    local DoClick = function()
		    	manolis.popcorn.hud.OpenItemSelect(i)
			end

			slot.icon.DoClick = DoClick
			slot.DoClick = DoClick

			table.insert(manolis.popcorn.hud.slots.slots, slot)
		end

		manolis.popcorn.hud.slotsManager = function(y)
			local b = slots.curY or 0
			if(b!=y) then
			    local x,ya = slots:GetPos()
			    slots.curY = y
			    slots:SetPos(x,ScrH()-y)
			end
		end


		manolis.popcorn.hud.slots.update = function(items)

			for k,v in pairs(items) do
				
				if(manolis.popcorn.hud.slots.slots[k]) then
					
					local s = manolis.popcorn.hud.slots.slots[k]
					if(type(v)!='table') then
						s.icon:SetHidden(true)
						local DoClick = function()
		    				manolis.popcorn.hud.OpenItemSelect(k-1)
						end

						s.icon.DoClick = DoClick
						s.DoClick = DoClick

						s.icon:SetModel('')
						s:SetTooltip(DarkRP.getPhrase("assign_quickbuy"))
						
						continue
					end

					local DoClick = function()
						LocalPlayer():ConCommand('DarkRP '..v.command)
					end
					s.icon.DoClick = DoClick
					s.DoClick = DoClick
					
					local DoRightClick = function()
						RunConsoleCommand("ManolisRemoveQuickBuy", k)
					end
					s.icon.DoRightClick = DoRightClick
					s.DoRightClick = DoRightClick

					s:SetModel(v.mdl)
					s.icon.strTooltipText = nil
					s.strTooltipText = nil
					s.icon:SetHidden(false)

				end
			end
		end

		net.Receive("ManolisPopcornQuickBuy", function()

			local slots = net.ReadTable()

			manolis.popcorn.hud.slots.update(slots)
		end)



		local outlinePanel = vgui.Create('DImage',hudContainer)
		outlinePanel:SetMaterial(outline)
		outlinePanel:SetSize(hudContainer:GetSize())







		local spacing = 0

		local buttonContainer = vgui.Create('Panel', hudContainer)
		buttonContainer:SetPos(805 - (((#manolis.popcorn.hud.actions*38)+(4*spacing))/2),88)
		buttonContainer:SetTall(38)
		buttonContainer:SetWide(38*(#manolis.popcorn.hud.actions+1)+(4*spacing))
	 

		for k,v in pairs(manolis.popcorn.hud.actions) do
		    local button = vgui.Create("DImageButton",buttonContainer)
		    button:SetMaterial(buttonMaterial)
		    button:SetSize(38,38)
		    button:SetPos(((k-1)*38)+((k-1)*spacing),0)
		
		    button.DoClick = v.DoClick


			local icon = vgui.Create("DImage", button)
			icon:SetSize(button:GetSize())
			icon:SetPos(0,0)
			icon:SetMaterial(v.material)
		end
	end

	manolis.popcorn.hud.manager = function(y)
		if(!hudContainer) then return end
		local b = hudContainer.curY or 0
		if(b!=y) then
			local x,ya = hudContainer:GetPos()
			hudContainer.curY = y
			hudContainer:SetPos(x,ScrH()-y)
		end
	end
end)

local OldTime = 0

hook.Add("HUDPaint", "manolis:MainHUDPaint", function()
    manolis.popcorn.hud.frameTime = SysTime()-OldTime
    OldTime = SysTime()

    local tickTime = 0
    if(OldTime<=0) then
        tickTime = SysTime()-OldTime
    end
    OldTime = SysTime()


	if(manolis.popcorn.hud.shouldDraw) then
		slotTarget = 75
		yTarget = 128
	else		
		yTarget = 0
		slotTarget = -20
	end
	local trace = LocalPlayer():GetEyeTrace()    
	local shootPos = LocalPlayer():GetShootPos()
	local aimVec = LocalPlayer():GetAimVector()




	oldY = Lerp(0.05, oldY, yTarget)
	oldSlotY = Lerp(0.03, oldSlotY or 0, slotTarget)
	if(manolis.popcorn.hud.manager) then manolis.popcorn.hud.manager(oldY) end
	if(manolis.popcorn.hud.slotsManager) then manolis.popcorn.hud.slotsManager(oldSlotY) end










	if(manolis.popcorn.hud.shouldDraw) then

		local ya = 17

		local h = 10
		local widthOfCompass = 500



		surface.SetDrawColor(0,0,0)

		local pTa = LocalPlayer():GetAimVector():GetNormalized()
		local drawPta = LerpVector(FrameTime()*40, oldOffset, pTa)
		oldOffset = drawPta

		local av = drawPta
		local cross = av:Cross(Vector(0, 0, 1))
		if(manolis.popcorn.config.hud.compass) then
			render.SetScissorRect(ScrW()/2-(widthOfCompass/2),-20+ya+5-15+1,ScrW()/2+(widthOfCompass/2), ya+5-15+1+15+2+100, true)


			for k,v in pairs(player.GetAll()) do
				if(v!=LocalPlayer() and v:GetPos():Distance(LocalPlayer():GetPos())<500 and LocalPlayer():getDarkRPVar('gang') or 0>0) then
					if(v:getDarkRPVar('gang')==LocalPlayer():getDarkRPVar('gang')) then
						local wOfP = 4
						local ang = cross:Dot( ( v:GetPos() - LocalPlayer():GetPos() ):GetNormalized() )
						local drawAng = ang


						surface.SetDrawColor(0,0,0)




						if(drawAng<-0.95 or drawAng>.95) then continue end
						local p = v:GetPos():ToScreen().x
						if(p>(ScrW())) or p<-ScrW() then continue end


						local pos = ((ang/.9)/2*670+ScrW()/2)

						surface.SetDrawColor(0,0,0)
						surface.DrawRect(pos,ya+20+1,wOfP+5,wOfP+5)
						surface.DrawRect(pos,ya+3,wOfP,15+5)


						surface.SetDrawColor(0,200,0)
						surface.DrawRect(pos-1,ya+20,wOfP+5,wOfP+5)
						surface.DrawRect(pos-1,ya+2,wOfP,15+5)
					end



				end
			end



			for k,v in pairs(manolis.popcorn.alerts.alerts) do
				if(v.timeLeft<=0) then
					manolis.popcorn.alerts.removeAlert(k)
				else
					v.timeLeft = v.timeLeft - tickTime
				end

				local wOfP = 4


				local ang = cross:DotProduct((v.location - LocalPlayer():GetPos()):GetNormalized())
				local p = v.location:ToScreen().x

				local pos = ((ang/.9)/2*670+ScrW()/2)
				pos = math.Clamp(pos,  ScrW()/2-(widthOfCompass/2)+9, ScrW()/2+(widthOfCompass/2)-9)


				if(((p>(ScrW())) or p<-(ScrW()+wOfP))) then
					surface.SetDrawColor(0,255,0)

					if(p>(ScrW())) then
						pos = ScrW()/2+(widthOfCompass/2)-9     
					else
						pos = ScrW()/2-(widthOfCompass/2)+9
					end

				end

				surface.SetDrawColor(Color(0,0,0,255))
				surface.DrawRect(pos,ya+20+1,wOfP+5,wOfP+5)

				surface.DrawRect(pos,ya+3,wOfP,15+5)

				surface.SetDrawColor(manolis.popcorn.config.promColor)
				surface.DrawRect(pos-1,ya+20,wOfP+5,wOfP+5)

				surface.DrawRect(pos-1,ya+2,wOfP,15+5)



			end


			surface.SetDrawColor(Color(0,0,0))






			surface.SetFont('manolisHUD')
			surface.SetTextColor(manolis.popcorn.config.promColor)
			if(pTa.y > 0) then
				local w,h = surface.GetTextSize('W')
				surface.DrawRect(ScrW()/2 + (300*-drawPta.x)+(w/4+2), ya+4,3,10)
				surface.SetTextPos(ScrW()/2 + (300*-drawPta.x),ya+13)

				surface.DrawText('W')
			else
				local w,h = surface.GetTextSize('E')
				surface.DrawRect(ScrW()/2 + (300*drawPta.x)+(w/4+2), ya+4,3,10)
				surface.SetTextPos(ScrW()/2 + (300*drawPta.x),ya+13)

				surface.DrawText('E')

			end

			if(pTa.x>0) then
				local w,h = surface.GetTextSize('N')

				surface.DrawRect(ScrW()/2 + (300*drawPta.y)-(w/4-2), ya+4,3,10)
				surface.SetTextPos(ScrW()/2 + (300*drawPta.y)-(w/2),ya+13)

				surface.DrawText('N')
			else
				local w,h = surface.GetTextSize('S')
				surface.DrawRect(ScrW()/2 + (300*-drawPta.y)+(w/4+2), ya+4,3,10)
				surface.SetTextPos(ScrW()/2 + (300*-drawPta.y),ya+13)

				surface.DrawText('S')
			end




			render.SetScissorRect(0,0,0,0,false)
		end
	end

	//Player info
	for k,v in pairs(player.GetAll()) do
		if(v and v!=LocalPlayer() and v:Alive()) then
			local hitPos = v:GetShootPos()
			local pos = hitPos - shootPos
			local unitPos = pos:GetNormalized()
			if(hitPos:DistToSqr(shootPos) < 160000) then 
				if(!(v:GetPos():Distance(LocalPlayer():GetPos())>150)) then 
					if(unitPos:Dot(aimVec) > 0.9) then
						local trace = util.QuickTrace(shootPos, pos, LocalPlayer())
						if(trace.Hit and trace.Entity != v) then continue end
						v:drawPlayerInfo() 
					end
				end
			end

			if(hitPos:DistToSqr(shootPos) < 1600000) then
				if(unitPos:Dot(aimVec) > 0.6) then
					local trace = util.QuickTrace(shootPos, pos, LocalPlayer())
					if(trace.Hit and trace.Entity != v) then continue end
					v:drawRivalInfo() 
				end
			end
		end
	end

	//Entity Display
	for k,v in pairs(ents.GetAll()) do
		if(drawDisplay[v:GetClass()] or v.isManolisNPC or (trace.Entity.isKeysOwnable and trace.Entity:isKeysOwnable())) then
			if(v:GetPos():Distance(LocalPlayer():GetPos())>125) then continue end
			local hitPos = v:GetPos()
			if(!hitPos or !shootPos) then continue end
			local pos = hitPos - shootPos
			local unitPos = pos:GetNormalized()
			if(hitPos:DistToSqr(shootPos) < 160000) then 
				local trace = util.QuickTrace(shootPos, pos, LocalPlayer())
				local t2 = LocalPlayer():GetEyeTrace()
				if((t2.Hit and t2.Entity == v) or (unitPos:Dot(aimVec) > 0.98)) then

					if(trace.Hit and IsValid(trace.Entity) and trace.Entity != v) then continue end
					if(!LocalPlayer():IsLineOfSightClear(v)) then continue end
					if(IsValid(trace.Entity) and trace.Entity:isKeysOwnable()) then trace.Entity:drawOwnableInfo() elseif(v.DrawDisplay) then v:DrawDisplay() end

				end
			end   
		end
	end


	surface.SetMaterial(actionBarBackground)

	if(manolis.popcorn.config.territoryInfo) then

		if(manolis.popcorn.gangs.ShowInfo) then
			local tToDisplay = (manolis.popcorn.gangs.ShowInfo.numCaptured or 0)==#manolis.popcorn.gangs.ShowInfo.locations and "Friendly Territory" or "Enemy Territory"
			if(manolis.popcorn.gangs.ShowInfo.numCaptured>0 and #manolis.popcorn.gangs.ShowInfo.locations>manolis.popcorn.gangs.ShowInfo.numCaptured) then tToDisplay = "Disputed Territory" end

			surface.SetFont('manolisTerritory')
			local yMod = 60
			local boxW = math.max(surface.GetTextSize(tToDisplay), surface.GetTextSize(manolis.popcorn.gangs.ShowInfo.name))
			draw.DrawText(manolis.popcorn.gangs.ShowInfo.name, "manolisTerritory", 120+2, 60+2+yMod, Color(0,0,0), TEXT_ALIGN_LEFT)
			draw.DrawText(manolis.popcorn.gangs.ShowInfo.name, "manolisTerritory", 120, 60+yMod, manolis.popcorn.config.promColor, TEXT_ALIGN_LEFT)

			draw.DrawText(tToDisplay .. ' - ('..(manolis.popcorn.gangs.ShowInfo.numCaptured or 0) .. " / ".. #manolis.popcorn.gangs.ShowInfo.locations..')', "manolisTerritory", 120+2, 85+2+yMod, Color(0,0,0), TEXT_ALIGN_LEFT)
			draw.DrawText(tToDisplay .. ' - ('..(manolis.popcorn.gangs.ShowInfo.numCaptured or 0) .. " / ".. #manolis.popcorn.gangs.ShowInfo.locations..')', "manolisTerritory", 120, 85+yMod, Color(255,255,255,255), TEXT_ALIGN_LEFT)

			surface.SetDrawColor(0,0,0,150)
			
		end
	end
end)

local function DisplayNotify(msg)
    local txt = msg:ReadString()
    manolis.popcorn.notify.notify(txt, msg:ReadShort(), msg:ReadLong())
    surface.PlaySound("buttons/lightswitch2.wav")

    -- Log to client console
    MsgC(Color(255, 20, 20, 255), "[Syndicate] ", Color(200, 200, 200, 255), txt, "\n")
end
usermessage.Hook("_Notify", DisplayNotify)

local function DisplayGangNotify(msg)
    local txt = msg:ReadString()
    manolis.popcorn.notify.gang(txt, msg:ReadShort(), msg:ReadLong())
    surface.PlaySound("buttons/lightswitch2.wav")

    -- Log to client console
    MsgC(Color(255, 20, 20, 255), "[Gang] ", Color(200, 200, 200, 255), txt, "\n")
end
usermessage.Hook("_GangNotify", DisplayGangNotify)

hook.Add("HUDShouldDraw", function()
	return false
end)

net.Receive("ManolisPopcornGangStartCapturing",		 function()
    local timeLeft = manolis.popcorn.config.capPoleTime
    local isCapturing = net.ReadBool()

    if(isCapturing) then
        hook.Add("HUDPaint", "manolis:DrawGangCapturing", function()

            local w,h = 400, 30
            local yMod = 80
            surface.SetDrawColor(0,0,0,100)
            surface.DrawRect(ScrW()/2-(w/2), ScrH()-(h*2)-yMod,w,h)

            surface.SetDrawColor(0,0,0)
            surface.DrawRect(ScrW()/2-(w/2), ScrH()-(h*2)-yMod,w* (1-math.min((timeLeft/manolis.popcorn.config.capPoleTime),1)),h)
            draw.DrawText("Capturing Territory...", "manolisItemFont", (ScrW()/2), ScrH()-(h*2)+5-yMod, Color(0,0,0,255), TEXT_ALIGN_CENTER)

            draw.DrawText("Capturing Territory...", "manolisItemFontB", (ScrW()/2)-1, ScrH()-(h*2)+5-1-yMod, Color(255,255,255,255), TEXT_ALIGN_CENTER)


            timeLeft = timeLeft - manolis.popcorn.hud.frameTime

        end)
    else
        hook.Remove("HUDPaint", "manolis:DrawGangCapturing")
    end
end)

manolis.popcorn.isInContext = false

concommand.Add("+menu_context", function()
	manolis.popcorn.isInContext = true
	gui.EnableScreenClicker(true)

	hook.Call( "OnContextMenuOpen", GAMEMODE)
end)

concommand.Add('-menu_context', function()
	if ( input.IsKeyTrapping() ) then return end
	manolis.popcorn.isInContext = false
	gui.EnableScreenClicker(false)
	hook.Call( "OnContextMenuClose", GAMEMODE)
end)


manolis.popcorn.thirdPersonState = 0
local rightClickBuffer = false
hook.Add("Think", "manolis:TP", function()


	if(manolis.popcorn.isInContext) then

		if(input.IsMouseDown(MOUSE_RIGHT) and !rightClickBuffer) then
			local x, y = gui.MousePos()
			if (y>100) and y<(ScrH()-100)then
				manolis.popcorn.thirdPersonState = (manolis.popcorn.thirdPersonState+1) % 3
			end
			
			rightClickBuffer = true
			return
		end

		if(!input.IsMouseDown(MOUSE_RIGHT) and rightClickBuffer) then
			rightClickBuffer = false
		end
	end
end)

hook.Add("CalcView", "manolis:TP:Calc", function(ply, pos, _, fov)
	if(manolis.popcorn.thirdPersonState>0) then
		local distanceFromBack = 30
		if manolis.popcorn.thirdPersonState == 2 then distanceFromBack = 100 end

		local aim = LocalPlayer():GetAimVector()

		local trace = {}
		trace.start = pos
		trace.endpos = pos-(aim*distanceFromBack)
		trace.filter = LocalPlayer()
		local traceLine = util.TraceLine(trace)
		if(trace.HitNonWorld or trace.HitWorld) then
		   trace.endpos = trace.HitPos + aim * 15
		end
		
		if(manolis.popcorn.thirdPersonState == 1) then
			trace.endpos = (trace.endpos-aim:Angle():Right()*15)
		end
		
		local view = {}
		view.origin = trace.endpos
		view.angles = LocalPlayer():EyeAngles()
		view.fov = fov
	 
		return view
	end
end)
 
hook.Add("ShouldDrawLocalPlayer", "manolis:thirdPersonCheck",function(ply)
	return (manolis.popcorn.thirdPersonState>0)
end)

function GM:HUDDrawTargetID()
end