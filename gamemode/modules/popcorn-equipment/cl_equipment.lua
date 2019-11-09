if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.equipment) then manolis.popcorn.equipment = {} end
if(!manolis.popcorn.equipment.items) then manolis.popcorn.equipment.items = {} end

local equipmentFrame = nil

local equipItem = function(self, item, previousParent)
	if(previousParent:GetParent() and previousParent:GetParent():GetName()=='mainInventory') then		
		RunConsoleCommand("ManolisPopcornEquipItem", self.type, item.id)
		return true
	end
end

local refreshMat = Material('manolis/popcorn/refresh.png')
local lastOpen = 0
local toggleEquipment = function()
	if not (LocalPlayer():Alive()) then return end
	if(CurTime() < lastOpen+.5) then return end
	lastOpen = CurTime()



	if ((not equipmentFrame) or (not IsValid(equipmentFrame))) then
		equipmentFrame = vgui.Create('ManolisFrame')
		equipmentFrame:SetRealSize(271,398)
		equipmentFrame:Center()
		equipmentFrame:SetVisible(true)
		equipmentFrame:SetBackgroundBlur(true)
		equipmentFrame:SetText(DarkRP.getPhrase('equipment'))
		manolis.popcorn.inventory.open(equipmentFrame)

		local refreshButton = vgui.Create("Button", equipmentFrame)
		refreshButton:SetPos(0,48-(10*3.5)-2)
		refreshButton:SetSize(20,20)
		refreshButton:MoveRightOf(equipmentFrame.header.title, 	5)
		
		refreshButton.Paint = function(self,w,h)
			return
		end

		refreshButton:SetText("")
		
		refreshButton.DoClick = function()
			RunConsoleCommand("manolisRefreshEquipment")
		end	

		local rIcon = vgui.Create("DImage", refreshButton)
		rIcon:SetMaterial(refreshMat)
		rIcon:SetSize(20,20)


		local character = vgui.Create("ManolisCharacter", equipmentFrame)
		character:SetSize(271,475)
		character:SetPos(0,40)

		local slots = vgui.Create("Panel", equipmentFrame, "mainEquipment")
		slots:SetSize(300,475)
		slots:SetPos(0,40)
		slots.slots = {}

		local y = 10

		local headSlot = vgui.Create("ManolisImageSlot", slots)
		headSlot:SetPos(271/2-(80/2), y)
		headSlot:SetImage(Material('manolis/popcorn/hud/character/head.png', 'smooth mips'))
		headSlot.type = 'head'
		headSlot.DroppedInto = equipItem
		table.insert(slots.slots, headSlot)

		y = y + 77 + 10

		local bodySlot = vgui.Create("ManolisImageSlot", slots)
		bodySlot:SetImage(Material('manolis/popcorn/hud/character/chest.png', 'smooth mips'))
		bodySlot:SetPos(271/2-(80/2), y)
		bodySlot.type = 'body'
		bodySlot.DroppedInto = equipItem
		table.insert(slots.slots, bodySlot)		

		local handSlot = vgui.Create("ManolisImageSlot", slots)
		handSlot:SetImage(Material('manolis/popcorn/hud/character/hand.png', 'smooth mips'))
		handSlot:SetPos(10, y)
		handSlot.type = 'hands'
		handSlot.DroppedInto = equipItem
		table.insert(slots.slots, handSlot)


		local ringSlot = vgui.Create("ManolisImageSlot", slots)
		ringSlot:SetPos(271-77-10, y)
		ringSlot.type = 'ring'
		ringSlot:SetImage(Material('manolis/popcorn/hud/character/ring.png', 'smooth mips'))
		ringSlot.DroppedInto = equipItem
		table.insert(slots.slots, ringSlot)

		y = y + 77 + 10

		local bottomSlot = vgui.Create("ManolisImageSlot", slots)
		bottomSlot:SetImage(Material('manolis/popcorn/hud/character/bottom.png', 'smooth mips'))
		bottomSlot:SetPos(271/2-(80/2), y)
		bottomSlot.type = 'bottom'
		bottomSlot.DroppedInto = equipItem
		table.insert(slots.slots, bottomSlot)

		y = y + 77 + 10

		local wepSlot = vgui.Create("ManolisImageSlot", slots)
		wepSlot:SetPos(271-77-10,y)
		wepSlot:SetImage(Material('manolis/popcorn/hud/character/primary.png', 'smooth mips'))
		wepSlot.type = 'primary'
		wepSlot.DroppedInto = equipItem
		table.insert(slots.slots, wepSlot)		

		local sideSlot = vgui.Create("ManolisImageSlot", slots)
		sideSlot:SetPos(10,y)
		sideSlot:SetImage(Material('manolis/popcorn/hud/character/deagle.png'))
		sideSlot.type = 'side'
		sideSlot.DroppedInto = equipItem
		table.insert(slots.slots, sideSlot)		

		y = y + 77 + 10

		equipmentFrame.slots = slots

		equipmentFrame.refresh = function()
			for k,v in pairs(equipmentFrame.slots.slots) do
				if(v.item) then
					if(v.item.Remove) then
						v.item:Remove()
					end
					v.item = nil
				end
			end

			for k,v in pairs(manolis.popcorn.equipment.items) do
				for k2,v2 in pairs(equipmentFrame.slots.slots) do
					if(v.slot==v2.type) then
						local item = vgui.Create("ManolisItem", v2)
						item:SetPos(0,0)
						item.t = v
						item:Go()
					end
				end
			end
		end

		equipmentFrame.header.closeButton.DoClick = function()
			equipmentFrame:Close()
			manolis.popcorn.enableClicker(false)
		end

		manolis.popcorn.enableClicker(true)
		equipmentFrame.refresh()
		manolis.popcorn.equipment.panel = equipmentFrame

	elseif(equipmentFrame and equipmentFrame:IsVisible()) then
		manolis.popcorn.enableClicker(false)
		manolis.popcorn.inventory.close(equipmentFrame)
	else
		equipmentFrame:SetVisible(true)
		manolis.popcorn.inventory.open(equipmentFrame)
		manolis.popcorn.enableClicker(true)
	end
end

concommand.Add("equipment", toggleEquipment)
manolis.popcorn.equipment.toggle = toggleEquipment