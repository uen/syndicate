if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.positions) then manolis.popcorn.positions = {} end
if(!manolis.popcorn.positions.positions) then manolis.popcorn.positions.positions = {} end

manolis.popcorn.positions.Add = function(name,ent,model)
	manolis.popcorn.positions.positions[name] = {position=Vector(0,0,0),name=name, ent=ent, model=model}
end

manolis.popcorn.positions.Add('The Don', 'npc_don', 'models/gman_high.mdl')
manolis.popcorn.positions.Add('Blacksmith', 'npc_blacksmith', 'models/Barney.mdl')
manolis.popcorn.positions.Add('Refiner', 'npc_refine', 'models/Kleiner.mdl')
manolis.popcorn.positions.Add('Bank', 'npc_bank', 'models/breen.mdl')
manolis.popcorn.positions.Add('Bomb', 'popcorn_bomb', 'models/props_wasteland/laundry_washer001a.mdl')

manolis.popcorn.positions.Add('Wendy (Quest NPC)', 'npc_wendy', 'models/player/mossman.mdl')
manolis.popcorn.positions.Add('Bob (Quest NPC)', 'npc_bob', 'models/player/odessa.mdl')
manolis.popcorn.positions.Add('Michael Sterling (Quest NPC)', 'npc_michael', 'models/manolis/player.mdl')
manolis.popcorn.positions.Add('Simon Escobar (Quest NPC)', 'npc_simon', 'models/player/group02/male_02.mdl')
manolis.popcorn.positions.Add('Turkish (Quest NPC)', 'npc_turkish', 'models/Humans/Group03/male_02.mdl')