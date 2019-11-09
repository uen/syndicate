local quest = {}
quest.uiq = 'simon_base'
quest.name = 'Simon\'s Cash'
quest.type = 'Base Defence'
quest.npc = 'simon'
quest.state = 0
quest.price = 5000
quest.target = quest.npc


quest.Start = function(self,ply)
	local dialogue = {
	'Hey! '..ply:Name()..'!',
	'I made all this cash from selling weed\nBut have nowhere to store it!',
	'Hold it for me?'
	}

	manolis.popcorn.quests.SendDialogue(ply,self.npc,dialogue, function()


		local building,door,pos = manolis.popcorn.buildings.findFreeBuilding()
		if(!building) then
			DarkRP.notify(ply,1,4,'All buildings are in use. Mission canceled')
			ply.quest = nil
			return
		end
		self.building = building


		manolis.popcorn.buildings.buyPlayer(ply,building)

		self.state = 1
		DarkRP.notify(ply,0,4,'Go to the '..building.name..' building')

		manolis.popcorn.alerts.NewAlert(ply, 'simon_base'..ply:UserID(), building.name, pos, 1000, function()
			self.state = 2
			self:Next(ply)
		end)

		manolis.popcorn.alerts.NewTimeAlert(ply,200,'Go to the building', function()
			self:Fail(ply)
		end)
	end)

end

quest.Fail = function(self,ply)
	ply.quest = false
end

quest.Next = function(self,ply)
	if(self.state==1) then
		local dialogue = {
			'Hurry up man!'
		}

		manolis.popcorn.quests.SendDialogue(ply,self.npc,dialogue)
	elseif(self.state==2) then
		local dialogue = {
			'Setup some defences bro!',
		}

		manolis.popcorn.quests.SendRadioDialogue(ply, dialogue)


		DarkRP.notify(ply,0,4,'Setup your defences')
		self.target = nil
		manolis.popcorn.alerts.NewTimeAlert(ply,manolis.popcorn.config.baseDefenseSetup,'Setup defences', function()
			self.state = 3
			self:Next(ply)
		end)
	elseif(self.state==3) then
		local dialogue = {
			'Okay man, hold that cash! I\'ll collect it soon!'
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
					'For FUCK sake! MY CASH!!'
				}

				self.failed = true
				
				manolis.popcorn.alerts.RemoveTimeAlert(ply)

				manolis.popcorn.alerts.RemoveAlertAll('simon_base'..ply:UserID())

				timer.Simple(math.random(2,7), function()
					if(IsValid(ply)) then
						manolis.popcorn.quests.CompleteQuest(ply,true)
						manolis.popcorn.quests.SendRadioDialogue(ply,dialogue)
					end
				end)
			end
		end

		self.cash = cash

		manolis.popcorn.alerts.NewAlertAll('simon_base'..ply:UserID(), 'Cash Stash', cash:GetPos(), manolis.popcorn.config.baseDefenseTime)
		manolis.popcorn.alerts.NewTimeAlert(ply,manolis.popcorn.config.baseDefenseTime,'Defend the cash', function()
			if(!self.failed) then
				self.state = 4
				self:Next(ply)
			end
		end)

	elseif(self.state==4) then
		local dialogue = {
			'Awesome! \nI\'ve sent you your reward',
			'Thanks again!'
		}

		if(IsValid(self.cash)) then self.cash:Remove() end

		manolis.popcorn.quests.SendRadioDialogue(ply,dialogue)
		manolis.popcorn.quests.CompleteQuest(ply)
		manolis.popcorn.alerts.RemoveAlertAll('simon_base'..ply:UserID())
	end
end

manolis.popcorn.quests.NewQuest(quest)