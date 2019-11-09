DarkRP.declareChatCommand{
    command = "buyammo",
    description = "Purchase ammo",
    delay = 0.1,
    condition = fn.Compose{fn.Not, fn.Curry(fn.GetValue, 2)("noguns"), fn.Curry(fn.GetValue, 2)("Config"), gmod.GetGamemode}
}

DarkRP.declareChatCommand{
    command = "buyshipment",
    description = "Buy a shipment",
    delay = .5
}