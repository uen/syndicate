if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.keys) then manolis.popcorn.keys = {} end
if(!manolis.popcorn.temp) then manolis.popcorn.temp = {} end
if(!manolis.popcorn.player) then manolis.popcorn.player = {} end
if(!manolis.popcorn.materialCache) then manolis.popcorn.materialCache = {} end

local add = function(k,v)
    manolis.popcorn.materialCache[k] = Material(v, 'smooth mips')
end

add('alert-circle', 'manolis/popcorn/icons/circle.png')
add('item-bg', 'manolis/popcorn/icons/bg.png')
add('glow', 'manolis/popcorn/glow.png')