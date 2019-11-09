local quest = {}
quest.uiq = 'simon_errand_cash'
quest.name = 'Simon\'s Errand'
quest.type = 'Errand & Base Defence'
quest.npc = 'simon'
quest.state = 0
quest.price = 500
quest.target = quest.npc

quest.Start = function(self,ply)

	local dialogue = {'What\'s up OG '..ply:Name(),'Listen I\'ve got a task for you\nAnd it won\'t be easy', 'You need to go pickup a shipment of cash \nfrom my homie Michael...','And then hold it for me,\nThen bring it back','There\'s a reward in it for you!'}
	manolis.popcorn.quests.SendDialogue(ply,self.npc,dialogue, function()
		self.target = 'michael'	
		local michael = manolis.popcorn.quests.FindNPC(self.target)
		DarkRP.notify(ply,0,4,'Go and see Michael Sterling')
		manolis.popcorn.alerts.NewAlert(ply, self.uiq..ply:UserID(), "Michael Sterling", michael:GetPos(), 1000)
		manolis.popcorn.alerts.NewTimeAlert(ply,200,'Meet your objectives', function()
			self:Fail(ply)
		end)
		self.state = 1
	end)

end

quest.Next = function(self,ply)
	if(self.state==1) then
		self.state = 69
		local dialogue = {'Hey bro, I\'ve got the cash right here\nDon\'t spend it all in the same place!\nHahah!'}
		manolis.popcorn.quests.SendDialogue(ply,self.target, dialogue, function()
			timer.Simple(math.random(1,3), function()
				local building,door,pos = manolis.popcorn.buildings.findFreeBuilding()
				if(!building) then
					DarkRP.notify(ply,1,4,'All buildings are in use. Mission canceled') 
					return
				end
				self.building = building

				local dialogue = {'Nice job homie!\nNow go to the \n'..building.name..' building and hold it'}
				manolis.popcorn.quests.SendRadioDialogue(ply, dialogue)

				DarkRP.notify(ply,0,4,'Go to the '..building.name..' building')
				manolis.popcorn.buildings.buyPlayer(ply,building)


				manolis.popcorn.alerts.NewAlert(ply, self.uiq..ply:UserID(), building.name, pos, 1000, function()
					self.state = 3
					self:Next(ply)
				end)

				manolis.popcorn.alerts.NewTimeAlert(ply,200,'Go to the building', function()
					self:Fail(ply)
				end)
			end)
		end)
	elseif(self.state==3) then
		local dialogue = {
			'Nice bro! Don\'t fucking lose it!\nSet up some defenses'
		}
		manolis.popcorn.quests.SendRadioDialogue(ply,dialogue)

		DarkRP.notify(ply,0,4,'Setup your defences')
		self.target = nil
		manolis.popcorn.alerts.NewTimeAlert(ply,manolis.popcorn.config.baseDefenseSetup,'Setup defences', function()
			self.state = 9
			self:Next(ply)
		end)
	elseif(self.state==9) then

		local dialogue = {
			'Okay bro! You shouldn\'t have to keep it too long.','Don\'t let anyone get it!'
		}
		manolis.popcorn.quests.SendRadioDialogue(ply,dialogue)
		
		DarkRP.notify(ply,0,4,'Defend the cash')


		local cash = ents.Create('popcorn_cash')
		cash:SetPos(manolis.popcorn.buildings.buildingCash[self.building.id].pos)
		cash:SetAngles(manolis.popcorn.buildings.buildingCash[self.building.id].ang)
		cash:SetcashOwner(ply)
		cash:Setvalue(manolis.popcorn.config.baseDefenseValue())
		cash:Spawn()

		cash.OnTake = function()
			if(IsValid(ply)) then
				local dialogue = {
					'Well fucking done idiot!\nYou owe me big time'
				}

				self.failed = true
				manolis.popcorn.alerts.RemoveTimeAlert(ply)

				manolis.popcorn.alerts.RemoveAlertAll(self.uiq..ply:UserID())

				timer.Simple(math.random(2,7), function()
					if(IsValid(ply)) then
						self:Fail(ply)
						manolis.popcorn.quests.SendRadioDialogue(ply,dialogue)
					end
				end)
			end
		end

		if(IsValid(ply)) then
			self.cash = cash

			manolis.popcorn.alerts.NewAlertAll(self.uiq..ply:UserID(), 'Cash Stash', cash:GetPos(), manolis.popcorn.config.baseDefenseTime)
			manolis.popcorn.alerts.NewTimeAlert(ply,manolis.popcorn.config.baseDefenseTime,'Defend the cash', function()
				if(!self.failed) then
					self.state = 4
					self:Next(ply)
				end
			end)
		end

	elseif(self.state==4) then
		if(IsValid(ply)) then
			local dialogue = {
				'Knew you could handle it!\nYou can bring it back now'
			}

			self.state = 12

			if(IsValid(self.cash)) then self.cash:Remove() end
			manolis.popcorn.quests.SendRadioDialogue(ply,dialogue)

			DarkRP.notify(ply,0,4,'Deliver the money to Simon')
			self.target = 'simon'
			local michael = manolis.popcorn.quests.FindNPC(self.target)
			manolis.popcorn.alerts.NewAlert(ply, self.uiq..ply:UserID(), "Simon Escobar", michael:GetPos(), 1000)
			manolis.popcorn.alerts.NewTimeAlert(ply,100,'Meet your objectives', function()
				if(IsValid(ply)) then
					self:Fail(ply)
				end
			end)
		end
	elseif(self.state==12) then
		local dialogue = {
			ply:Name()..'...\nYou\'re a fucking lifesaver!!',
			'Here\'s your reward bro!'
		}
		manolis.popcorn.quests.SendDialogue(ply,self.target,dialogue, function()
			if(IsValid(ply)) then
			manolis.popcorn.quests.CompleteQuest(ply)
			manolis.popcorn.alerts.RemoveTimeAlert(ply)
			manolis.popcorn.alerts.RemoveAlert(ply,self.uiq..ply:UserID())	
			end
		end)
	end
end

quest.Fail = function(self,ply)
	ply.quest = false
	manolis.popcorn.alerts.RemoveAlert(ply,self.uiq..ply:UserID())
	manolis.popcorn.quests.CompleteQuest(ply,true)
end

manolis.popcorn.quests.NewQuest(quest)