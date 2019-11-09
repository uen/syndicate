local quest = {}
quest.uiq = 'wendy_errand_basic'
quest.name = 'Wendy\'s Kush'
quest.type = 'Errand'
quest.npc = 'wendy'
quest.state = 0
quest.price = 5000
quest.target = quest.npc

quest.Start = function(self,ply)


	local dialogue = {'Hey, you!\nYou\'ve got to help me!','I had a shipment of Snoop Dogg master kush\nComing in from California.','I had a guy that was supposed to pick it up,\nbut he\'s not contacted me!','Please, it\'s been a week.\nThere\'s a big reward in it for you','His name is Simon Escobar!.\nHurry!'}
	manolis.popcorn.quests.SendDialogue(ply,self.npc,dialogue, function()
		self.target = 'simon'	

		local simon = manolis.popcorn.quests.FindNPC(self.target)
		DarkRP.notify(ply,0,4,'Go and see Simon about the kush')
		manolis.popcorn.alerts.NewAlert(ply, 'wendy_errand_basic'..ply:UserID(), self.target, simon:GetPos(), 1000)
		manolis.popcorn.alerts.NewTimeAlert(ply,200,'Meet your objectives', function()
			self:Fail(ply)
		end)
		self.state = 1
	end)

end

quest.Fail = function(self,ply)
	ply.quest = false
	manolis.popcorn.alerts.RemoveAlert(ply,'wendy_errand_basic'..ply:UserID())
	manolis.popcorn.quests.CompleteQuest(ply,true)
end

quest.Next = function(self,ply)
	if(self.state==1) then
		local dialogue = {
			'Yeeaahh what\'s up bro?',
			'Shiiit man I got real distacted\nI got Bob to pick it up!',
			'Try him bro', 
		}
		manolis.popcorn.quests.SendDialogue(ply,self.target,dialogue, function()
			self.state = 2
			self.target = 'bob'
		
			local bob = manolis.popcorn.quests.FindNPC(self.target)
			manolis.popcorn.alerts.NewAlert(ply, 'wendy_errand_basic'..ply:UserID(), "Bob", bob:GetPos(), 1000)

			DarkRP.notify(ply,0,4,'Ask Bob about the missing kush')
		end)

	elseif(self.state==2) then
		
		local dialogue = {
			'Hey bro!\nWhat\'s up?',
			'Snoop Dogg Master Kush? Hmmm.\nI don\'t think so..',
			'...',
			'All right, all right. Here you go. \nTreat her nice won\'t you?!',
		}
		manolis.popcorn.quests.SendDialogue(ply,self.target,dialogue, function()
			self.state = 3
			self.target = 'wendy'

			local wendy = manolis.popcorn.quests.FindNPC(self.target)
			manolis.popcorn.alerts.NewAlert(ply, 'wendy_errand_basic'..ply:UserID(), "Wendy", wendy:GetPos(), 1000)
			

			DarkRP.notify(ply,0,4,'Deliver the kush to Wendy')
		end)



	elseif(self.state==3) then
		local dialogue = {
			'Oh '..ply:Name()..'!\nYou got it for me!',
			'I can\'t thank you enough!\nHere, take this!',
			'It\'s not much but I hope you\'ll like it'
		}
		manolis.popcorn.quests.SendDialogue(ply,self.target,dialogue, function()
			manolis.popcorn.quests.CompleteQuest(ply)
			manolis.popcorn.alerts.RemoveTimeAlert(ply)
			manolis.popcorn.alerts.RemoveAlert(ply,'wendy_errand_basic'..ply:UserID())	
		end)
	end
end

manolis.popcorn.quests.NewQuest(quest)