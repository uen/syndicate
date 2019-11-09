if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.alerts) then manolis.popcorn.alerts = {} end
if(!manolis.popcorn.alerts.alerts) then manolis.popcorn.alerts.alerts = {} end

local OldTime = SysTime()
local timerTime = 0
local timerName

manolis.popcorn.alerts.removeAlert = function(a)
	table.remove(manolis.popcorn.alerts.alerts, a)
end

manolis.popcorn.alerts.addAlert = function(a)
	for k,v in pairs(manolis.popcorn.alerts.alerts) do
		if(v.id == a.id) then
			table.remove(manolis.popcorn.alerts.alerts,k)
		end
	end
	table.insert(manolis.popcorn.alerts.alerts,a)
end

local oldPos = {0,0}
hook.Add('HUDPaint', 'manolis:popcorn:DrawAlerts', function()
	local tickTime = 0
	if(OldTime<=0) then
		tickTime = SysTime()-OldTime
	end
	OldTime = SysTime()

	for k,v in pairs(manolis.popcorn.alerts.alerts) do

		if(v.timeLeft<=0) then
			manolis.popcorn.alerts.removeAlert(k)
		else
			v.timeLeft = v.timeLeft - tickTime
		end

		if(LocalPlayer():GetPos():Distance(v.location) < 100) then
			manolis.popcorn.alerts.removeAlert(k)
		end

		local pos = v.location:ToScreen()

		surface.SetFont('manolisAlertFont')
		local a,b = surface.GetTextSize(v.name)

		local tPadding = 10

		if(pos.x > ScrW()) then
			oldPos[1] = Lerp(0.1,oldPos[1],math.Clamp(ScrH()/2 + (pos.y/10),ScrH()/4,ScrH()/4*3))

			surface.SetDrawColor(255,255,255,255)
			surface.SetMaterial(manolis.popcorn.materialCache['alert-circle'])
			surface.SetDrawColor(Color(0,0,0))
			surface.DrawTexturedRect( ( ScrW()-64)+2+32, oldPos[1]+2, 64, 64)

			surface.SetDrawColor(manolis.popcorn.config.promColor)
			surface.DrawTexturedRect( ( ScrW()-64)+32,  oldPos[1], 64, 64)

			draw.SimpleText(v.name, 'manolisAlertFont',ScrW()-a-32-tPadding,  oldPos[1]+2+(b/2)+8, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(v.name, 'manolisAlertFont',ScrW()-a-32-tPadding, oldPos[1]+(b/2)+8, manolis.popcorn.config.promColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)				
		elseif(pos.x < 0) then
			oldPos[2] = Lerp(0.1,oldPos[2],math.Clamp(ScrH()/2 + (pos.y/10),ScrH()/4,ScrH()/4*3))
				
			surface.SetDrawColor(255,255,255,255)
			surface.SetMaterial(manolis.popcorn.materialCache['alert-circle'])
			surface.SetDrawColor(Color(0,0,0))
			surface.DrawTexturedRect(-32+2, oldPos[2]+2, 64, 64 )

			surface.SetDrawColor(manolis.popcorn.config.promColor)
			surface.DrawTexturedRect(-32,  oldPos[2], 64, 64 )

			draw.SimpleText(v.name, 'manolisAlertFont',a+32+tPadding,  oldPos[2]+2+(b/2)+8, Color(0,0,0,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
			draw.SimpleText(v.name, 'manolisAlertFont',a+32+tPadding, oldPos[2]+(b/2)+8, manolis.popcorn.config.promColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)				
		else
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(manolis.popcorn.materialCache['alert-circle'])
			surface.SetDrawColor(Color(0,0,0))
			surface.DrawTexturedRect( ( pos.x ) - 32+2, pos.y-32+2, 64, 64 )

			surface.SetDrawColor(manolis.popcorn.config.promColor)
			surface.DrawTexturedRect( ( pos.x ) - 32, pos.y-32, 64, 64 )

			pos.y = pos.y + 37

			draw.DrawText(v.name, 'manolisAlertFont',pos.x+2,pos.y+2,Color(0,0,0,225), TEXT_ALIGN_CENTER)
			draw.DrawText(v.name, 'manolisAlertFont',pos.x,pos.y,manolis.popcorn.config.promColor,TEXT_ALIGN_CENTER)
		end
	end


	if(timerTime>0) then
		local v,miliseconds = math.modf(timerTime)
		local str = string.format("%02d:%02d", timerTime/(60), timerTime%60)

		local pos = {x=230,y=20}

		local color = Color(255,255,255)
		if(timerTime<=10) then
			color = Color(255,0,0)
		end

		draw.SimpleText(str, 'manolisLocationLarge', pos.x+2, pos.y +2, Color(0,0,0,255))
		draw.SimpleText(str, 'manolisLocationLarge', pos.x, pos.y, color)
		
		pos.y = pos.y + 60
		draw.SimpleText(timerName, 'manolisLocationSmall', pos.x+1+2, pos.y+2, Color(0,0,0,255))
		draw.SimpleText(timerName, 'manolisLocationSmall', pos.x+1, pos.y, manolis.popcorn.config.promColor)
			
		timerTime = timerTime - FrameTime()	
	end
end)

net.Receive('ManolisPopcornAlert', function()
	local t = {}
	t.id = net.ReadString()
	t.name = net.ReadString()
	t.location = net.ReadVector() + Vector(0,0,55)
	t.timeLeft = net.ReadInt(32)

	manolis.popcorn.alerts.addAlert(t)
end)

net.Receive('ManolisPopcornAlertRemove', function()
	local id = net.ReadString()
	for k,v in pairs(manolis.popcorn.alerts.alerts) do
		if(v.id==id) then
			manolis.popcorn.alerts.removeAlert(k)
			return
		end
	end
end)

net.Receive('ManolisPopcornAlertTime', function()
	timerTime = net.ReadInt(32)
	timerName = net.ReadString()
end)

net.Receive('ManolisPopcornAlertRemoveTime', function()
	timerTime = 0
end)