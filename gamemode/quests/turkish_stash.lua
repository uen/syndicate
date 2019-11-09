local quest = {}
quest.uiq = 'turkish_stash'
quest.name = 'Too stoned'
quest.type = 'Errand'
quest.npc = 'turkish'
quest.state = 0
quest.price = 2500
quest.target = quest.npc

quest.Start = function(self,ply)


	local dialogue = {'Wassup my G\nyou got weed bro?', 'fuck man i\'m all out \nbut i\'m too fucking stoned\nto get more','listen ill give you a reward if you go \npickup for me.\nYou know Wendy,right?'}
	manolis.popcorn.quests.SendDialogue(ply,self.npc,dialogue, function()
		self.target = 'wendy'	

		local wendy = manolis.popcorn.quests.FindNPC(self.target)
		DarkRP.notify(ply,0,4,'Go and buy weed from Wendy')
		manolis.popcorn.alerts.NewAlert(ply, 'turkish_stash'..ply:UserID(), "Wendy", wendy:GetPos(), 1000)
		manolis.popcorn.alerts.NewTimeAlert(ply,200,'Meet your objectives', function()
			self:Fail(ply)
		end)
		self.state = 1
	end)

end

quest.Fail = function(self,ply)
	ply.quest = false
	manolis.popcorn.alerts.RemoveAlert(ply,'turkish_stash'..ply:UserID())
	manolis.popcorn.quests.CompleteQuest(ply,true)
end

quest.Next = function(self,ply)
	if(self.state==1) then
		local dialogue = {
			'Hey!',
			'Always nice to see you! What\'ll it be?',
			'A 20? No problem!'
		}

		if(ply:canAfford(20)) then
			ply:addMoney(-20)
			DarkRP.notify(ply,0,4,'You bought $20 worth of weed')
		end

		manolis.popcorn.quests.SendDialogue(ply,self.target,dialogue, function()
			self.state = 2
			self.target = 'turkish'
		
			local turkish = manolis.popcorn.quests.FindNPC(self.target)
			manolis.popcorn.alerts.NewAlert(ply, 'turkish_stash'..ply:UserID(), "Turkish", turkish:GetPos(), 1000)

			DarkRP.notify(ply,0,4,'Deliver the weed to Turkish')
		end)

	elseif(self.state==2) then
		local dialogue = {
			'Man you were gone for fucking ages!\nI\'m sobering up!',
			'Thanks bro, this is some good shit\nHere is your reward'
		}

		manolis.popcorn.quests.SendDialogue(ply,self.target,dialogue, function()
			manolis.popcorn.quests.CompleteQuest(ply)
			manolis.popcorn.alerts.RemoveTimeAlert(ply)
			manolis.popcorn.alerts.RemoveAlert(ply,'turkish_stash'..ply:UserID())	
		end)
	end
end

manolis.popcorn.quests.NewQuest(quest)