if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.party) then manolis.popcorn.party = {} end
if(!manolis.popcorn.party.parties) then manolis.popcorn.party.parties = {} end
if(!manolis.popcorn.party.isInParty) then manolis.popcorn.party.isInParty = {} end

DarkRP.declareChatCommand{
    command = 'p',
    description = "Speak to your party members",
    delay = .3
}

DarkRP.declareChatCommand{
    command = 'party',
    description = "Speak to your party members",
    delay = .3
}

DarkRP.declareChatCommand{
    command = 'partyinvite',
    description = "Invite someone to your party",
    delay = .3
}