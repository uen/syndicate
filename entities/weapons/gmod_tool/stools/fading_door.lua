--[[
	STool: Fading Doors
	Version: 2.1.1
	Author: http://www.steamcommunity.com/id/zapk

	Edited by ng-vrondakis
--]]

--[[
	New in 2.1.0:
	-	Fixed "No Effect" not working.
	-	Cleaned up code.
--]]

TOOL.Category = "Popcorn Tools"
TOOL.Name = "#tool.fading_door.name"

TOOL.ClientConVar["key"] = "5"
TOOL.ClientConVar["reversed"] = "0"
TOOL.ClientConVar["noeffect"] = "0"

-- create convar fading_door_nokeyboard (defualt 0)
local noKeyboard = CreateConVar("fading_door_nokeyboard", "0", FCVAR_ARCHIVE, "Set to 1 to disable using fading doors with the keyboard")

local function checkTrace(tr)
	-- edgy, yes, but easy to read

	return tr.Entity
		and tr.Entity:IsValid()
		and not (
			tr.Entity:IsPlayer()
			or tr.Entity:IsNPC()
			or tr.Entity:IsVehicle()
			or tr.HitWorld
		)
end

if CLIENT then
	-- handle languages
	language.Add( "tool.fading_door.name", "Fading Door" )
	language.Add( "tool.fading_door.desc", "Makes an object fade away when activated." )
	language.Add( "tool.fading_door.0", "Click on an object to make it a fading door." )
	language.Add( "Undone_fading_door", "Undone Fading Door" )

	-- handle tool panel
	function TOOL:BuildCPanel()
		self:AddControl( "Header", { Text = "#tool.fading_door.name", Description = "#tool.fading_door.desc" } )
		self:AddControl( "CheckBox", { Label = "Start Faded", Command = "fading_door_reversed" } )
		self:AddControl( "Numpad", { Label = "Fade", ButtonSize = "22", Command = "fading_door_key" } )
	end

	-- leftclick trace function
	TOOL.LeftClick = checkTrace

	return
end

local function fadeActivate(self)
	self.fadeActive = true

	self.fadeMaterial = self:GetMaterial()
	self.fadeColor = self:GetColor()

	self:SetMaterial("sprites/heatwave")

	self:DrawShadow(false)
	self:SetNotSolid(true)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		self.fadeMoveable = phys:IsMoveable()
		phys:EnableMotion(false)
	end

	if WireLib then
		Wire_TriggerOutput(self, "FadeActive", 1)
	end
end

local function fadeDeactivate(self)
	self.fadeActive = false

	self:SetMaterial(self.fadeMaterial or "")
	self:SetColor(self.fadeColor or color_white)

	self:DrawShadow(true)
	self:SetNotSolid(false)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:EnableMotion(self.fadeMoveable or false)
	end

	if WireLib then
		Wire_TriggerOutput(self, "FadeActive", 0)
	end
end

local function fadeToggleActive(self, ply)
	if noKeyboard:GetBool() and not numpad.FromButton() then
		ply:ChatPrint("You cannot use fading doors with the keyboard on this server.")
		ply:ChatPrint("Try using a button or keypad instead.")
		return
	end

	if self.fadeActive then
		self:fadeDeactivate()
	else
		self:fadeActivate()
	end
end

local function onUp(ply, ent)
	if not (ent:IsValid() and ent.fadeToggleActive and not ent.fadeToggle) then
		return
	end

	ent:fadeToggleActive(ply)
end

numpad.Register("Fading Door onUp", onUp)

local function onDown(ply, ent)
	if not (ent:IsValid() and ent.fadeToggleActive) then
		return
	end

	ent:fadeToggleActive(ply)
end

numpad.Register("Fading Door onDown", onDown)

-- I hate wire.
local function getWireInputs(ent)
	local inputs = ent.Inputs
	local names, types, descs = {}, {}, {}

	if inputs then
		local num
		for _, data in pairs(inputs) do
			num = data.Num
			names[num] = data.Name
			types[num] = data.Type
			descs[num] = data.Desc
		end
	end

	return names, types, descs
end

local function doWireInputs(ent)
	local inputs = ent.Inputs

	if not inputs then
		Wire_CreateInputs(ent, {"Fade"})
		return
	end

	local names, types, descs = {}, {}, {}
	local num

	for _, data in pairs(inputs) do
		num = data.Num
		names[num] = data.Name
		types[num] = data.Type
		descs[num] = data.Desc
	end

	table.insert(names, "Fade")

	WireLib.AdjustSpecialInputs(ent, names, types, descs)
end

local function doWireOutputs(ent)
	local outputs = ent.Outputs

	if not outputs then
		Wire_CreateOutputs(ent, {"FadeActive"})
		return;
	end

	local names, types, descs = {}, {}, {}
	local num

	for _, data in pairs(outputs) do
		num = data.Num
		names[num] = data.Name
		types[num] = data.Type
		descs[num] = data.Desc
	end

	table.insert(names, "FadeActive")

	WireLib.AdjustSpecialOutputs(ent, names, types, descs)
end

local function TriggerInput(self, name, value, ...)
	if name == "Fade" then
		if value == 0 and self.fadePrevWireOn then
			self.fadePrevWireOn = false

			if not self.fadeToggle then
				self:fadeToggleActive()
			end
		else
			if not self.fadePrevWireOn then
				self.fadePrevWireOn = true
				self:fadeToggleActive()
			end
		end
	elseif self.fadeTriggerInput then
		return self:fadeTriggerInput(name, value, ...)
	end
end

local function PreEntityCopy(self)
	local info = WireLib.BuildDupeInfo(self)

	if info then
		duplicator.StoreEntityModifier(self, "WireDupeInfo", info)
	end

	if self.fadePreEntityCopy then
		self:fadePreEntityCopy()
	end
end

local function PostEntityPaste(self, ply, ent, ents)
	if self.EntityMods and self.EntityMods.WireDupeInfo then
		WireLib.ApplyDupeInfo(ply, self, self.EntityMods.WireDupeInfo, function(id) return ents[id] end)
	end

	if self.fadePostEntityPaste then
		self:fadePostEntityPaste(ply, ent, ents)
	end
end


local function onRemove(self)
	numpad.Remove(self.fadeUpNum)
	numpad.Remove(self.fadeDownNum)
end

local function dooEet(ply, ent, stuff)
	if ent.isFadingDoor then
		ent:fadeDeactivate()
		onRemove(ent)
	else
		ent.isFadingDoor = true

		ent.fadeActivate = fadeActivate
		ent.fadeDeactivate = fadeDeactivate
		ent.fadeToggleActive = fadeToggleActive

		ent:CallOnRemove("Fading Door", onRemove)
	end

	ent.fadeUpNum = numpad.OnUp(ply, stuff.key, "Fading Door onUp", ent)
	ent.fadeDownNum = numpad.OnDown(ply, stuff.key, "Fading Door onDown", ent)
	ent.fadeToggle = stuff.toggle

	if stuff.reversed then
		ent:fadeActivate()
	end

	duplicator.StoreEntityModifier(ent, "Fading Door", stuff)

	return true
end

duplicator.RegisterEntityModifier("Fading Door", dooEet)

if not FadingDoor then
	local function legacy(ply, ent, data)
		return dooEet(ply, ent, {
			key      = data.Key,
			toggle   = data.Toggle,
			reversed = data.Inverse,
		})
	end

	duplicator.RegisterEntityModifier("FadingDoor", legacy)
end

local function doUndo(undoData, ent)
	if IsValid(ent) then
		onRemove(ent)
		ent:fadeDeactivate()

		ent.isFadingDoor = false

		if WireLib then
			ent.TriggerInput = ent.fadeTriggerInput

			if ent.Inputs then
				Wire_Link_Clear(ent, "Fade")
				ent.Inputs['Fade'] = nil
				WireLib._SetInputs(ent)
			end if ent.Outputs then
				local port = ent.Outputs['FadeActive']

				if port then
					for i,inp in ipairs(port.Connected) do
						if (inp.Entity:IsValid()) then
							Wire_Link_Clear(inp.Entity, inp.Name)
						end
					end
				end

				ent.Outputs['FadeActive'] = nil
				WireLib._SetOutputs(ent)
			end
		end
	end
end

function TOOL:LeftClick(tr)
	if not checkTrace(tr) then
		return false
	end

	local ent = tr.Entity
	local ply = self:GetOwner()

	dooEet(ply, ent, {
		key      = self:GetClientNumber("key"),
		toggle   = 1,
		reversed = self:GetClientNumber("reversed") == 1,
		noEffect = self:GetClientNumber("noeffect") == 1
	})

	undo.Create("Fading_Door")
		undo.AddFunction(doUndo, ent)
		undo.SetPlayer(ply)
	undo.Finish()

	return true
end