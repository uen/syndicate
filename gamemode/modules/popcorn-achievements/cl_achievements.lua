if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.achievements) then manolis.popcorn.achievements = {} end
if(!manolis.popcorn.achievements.achievements) then manolis.popcorn.achievements.achievements = {} end

manolis.popcorn.achievements.newGUI = function(achievement)
	local panel = vgui.Create('Panel')
	panel:SetSize(250, 80)
	panel.Paint = function(self,w,h)
		surface.SetDrawColor(manolis.popcorn.config.promColor)
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(2,2,w-4,h-4)
	end		
	panel.Created = CurTime()
	panel:SetPos(5)
	panel.target = 5
	panel.curY = -panel:GetTall()
	panel.Think = function(self)
		local x,y = self:GetPos()
		if(self.curY!=self.target) then
			self.curY = Lerp(0.05, self.curY, self.target)
		end

		if(panel.Created+3<CurTime()) then
			self.target = -self:GetTall()
			if(panel.curY==self:GetTall()) then
				self:Remove()
			end
		end

		self:SetPos(x,self.curY)
	end

	panel:SetZPos(30000)
	local icon = vgui.Create('DImage', panel)
	icon:SetPos(8,8)
	icon:SetSize(64,64)
	icon:SetMaterial(Material('manolis/popcorn/icons/achievements/'..achievement.aid..'.png'))
	panel.icon = panel

	local title = vgui.Create('DLabel', panel)
	title:SetTextColor(manolis.popcorn.config.promColor)
	title:SetFont('manolisItemAchievement')
	title:SetText('Achievement Unlocked!')
	title:SizeToContents()
	title:SetPos(80,7)
	panel.title = title

	local name = vgui.Create('DLabel', panel)
	name:SetTextColor(Color(255,255,255))
	name:SetFont('manolisItemAchievementName')
	name:SetText(achievement.name)
	name:SizeToContents()
	name:SetPos(80,7+title:GetTall())

	local desc = vgui.Create('DLabel', panel)
	desc:SetWrap(true)
	desc:SetFont('manolisItemAchievementDesc')
	desc:SetContentAlignment(7)
	desc:SetText(achievement.description)
	desc:SetPos(80,7+title:GetTall()+name:GetTall()-7+5) // //{{ user_id }}
	desc:SetSize(250-70,0)
	desc:SetAutoStretchVertical(true)
end

net.Receive("ManolisPopcornAchievementUpdate", function()
	local a = net.ReadTable()
	local progress = a.progress
	local id = a.aid

	hook.Call("manolis:AchievementUpdate", DarkRP.hooks, ply, id, progress)	
end)

net.Receive("ManolisPopcornAchievementWin", function()
	local a = net.ReadTable()
	local progress = a.progress
	local id = a.aid

	local ach = manolis.popcorn.achievements.Find(id)
	if(ach) then

		manolis.popcorn.achievements.newGUI(ach)
		if(IsValid(LocalPlayer())) then
			LocalPlayer():EmitSound('friends/friend_join.wav')
		end
	end

	hook.Call("manolis:AchievementWin", DarkRP.hooks, ply, id)	
	hook.Call("manolis:AchievementUpdate", DarkRP.hooks, ply, id, progress)	
end)
hook.Add("manolis:AchievementWin", "manolis:AchievementWin", function(ply, id)

end)

net.Receive("ManolisPopcornAchievementPacket", function()
	local a = net.ReadTable()
	for k,v in pairs(a) do
		for a,b in pairs(manolis.popcorn.achievements.achievements) do
			if(v.aid == b.aid) then
				b.progress = v.progress
			end
		end
	end
end)