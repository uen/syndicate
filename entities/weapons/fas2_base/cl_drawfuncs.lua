local dst = draw.SimpleText

function draw.ShadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
	dst(text, font, x + dist, y + dist, colorshadow, xalign, yalign)
	dst(text, font, x, y, colortext, xalign, yalign)
end

local trans = {["MOUSE1"] = "LEFT MOUSE BUTTON",
	["MOUSE2"] = "RIGHT MOUSE BUTTON"}
	
local b, e

function SWEP:GetKeyBind(bind)
	b = input.LookupBinding(bind)
	e = trans[b]
	
	return b and ("[" .. (e and e or string.upper(b)) .. "]") or "[NOT BOUND, " .. bind .. "]"
end