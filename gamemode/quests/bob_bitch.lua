local quest = {}
quest.uiq = 'bob_bitch'
quest.name = 'Bob\'s bottom bitch'
quest.type = 'Errand'
quest.npc = 'bob'
quest.state = 0
quest.price = 5000
quest.target = quest.npc

quest.Start = function(self,ply)


	local dialogue = {
		'Hey man!!\nListen',
		'I just have to tell someone!\nI LOVE WENDY!',
		'But the fucking bitch won\'t reply to my /pm s',
		'Please man, deliver her this letter'
	}
	manolis.popcorn.quests.SendDialogue(ply,self.npc,dialogue, function()
		self.target = 'wendy'	

		local wendy = manolis.popcorn.quests.FindNPC(self.target)
		DarkRP.notify(ply,0,4,'Deliver the love letter to Wendy')
		manolis.popcorn.alerts.NewAlert(ply, 'bobs_bitch'..ply:UserID(), self.target, wendy:GetPos(), 1000)
		manolis.popcorn.alerts.NewTimeAlert(ply,200,'Meet your objectives', function()
			self:Fail(ply)
		end)
		self.state = 1

		timer.Simple(8, function()
			local dialogue = {
				'Wait man! Stop!',
				'I was wrong man, I don\'t love that fucking bitch!\n',
				'Bring me the letter back!'
			}

			if(IsValid(ply)) then
				manolis.popcorn.quests.SendRadioDialogue(ply, dialogue)

			end

			self.state = 2

			timer.Simple(1, function()
				if(IsValid(ply)) then
					self.target = 'bob'
					local bob = manolis.popcorn.quests.FindNPC(self.target)
					DarkRP.notify(ply,0,4,'Return the letter to Bob')

					manolis.popcorn.alerts.RemoveTimeAlert(ply)
					manolis.popcorn.alerts.RemoveAlert(ply,'bobs_bitch'..ply:UserID())

					manolis.popcorn.alerts.NewAlert(ply, 'bobs_bitch'..ply:UserID(), self.target, bob:GetPos(), 1000)
					manolis.popcorn.alerts.NewTimeAlert(ply,30,'Meet your objectives', function()
						self:Fail(ply)
					end)
				end
			end)
		end)
	end)

end

quest.Fail = function(self,ply)
	ply.quest = false
	manolis.popcorn.alerts.RemoveAlert(ply,'bobs_bitch'..ply:UserID())
	manolis.popcorn.quests.CompleteQuest(ply,true)
end

quest.Next = function(self,ply)
	if(self.state==2) then
		local dialogue = {
			'Man, thank fuck you didn\'t get to her in time!',
			'Thanks man, here\'s your reward'
		}

		manolis.popcorn.quests.SendDialogue(ply,self.target,dialogue, function()
			manolis.popcorn.quests.CompleteQuest(ply)
			manolis.popcorn.alerts.RemoveTimeAlert(ply)
			manolis.popcorn.alerts.RemoveAlert(ply,'bobs_bitch'..ply:UserID())	
		end)
	end
end

manolis.popcorn.quests.NewQuest(quest)