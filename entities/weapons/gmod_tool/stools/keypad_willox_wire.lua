if (SERVER) then
	-- CreateConVar('sbox_maxkeypads', 10) -- Handled by keypad_willox.lua
end

TOOL.Category = "Construction"
TOOL.Name = "Keypad - Wire"
TOOL.Command = nil

TOOL.ClientConVar['weld'] = '1'
TOOL.ClientConVar['freeze'] = '1'

TOOL.ClientConVar['password'] = '1234'
TOOL.ClientConVar['secure'] = '0'

TOOL.ClientConVar['repeats_granted'] = '0'
TOOL.ClientConVar['repeats_denied'] = '0'

TOOL.ClientConVar['length_granted'] = '0.1'
TOOL.ClientConVar['length_denied'] = '0.1'

TOOL.ClientConVar['delay_granted'] = '0'
TOOL.ClientConVar['delay_denied'] = '0'

TOOL.ClientConVar['init_delay_granted'] = '0'
TOOL.ClientConVar['init_delay_denied'] = '0'

TOOL.ClientConVar['output_on'] = '1'
TOOL.ClientConVar['output_off'] = '0'

-- cleanup.Register("keypads") -- Handled by keypad_willox.lua

if CLIENT then
	language.Add("tool.keypad_willox_wire.name", "Keypad - Wire")
	language.Add("tool.keypad_willox_wire.0", "Left Click: Create, Right Click: Update")
	language.Add("tool.keypad_willox_wire.desc", "Creates Keypads for secure access")

	--[[
        language.Add("Undone_Keypad", "Undone Keypad")
    	language.Add("Cleanup_keypads", "Keypads")
    	language.Add("Cleaned_keypads", "Cleaned up all Keypads")

    	language.Add("SBoxLimit_keypads", "You've hit the Keypad limit!")
    ]] -- Handled by keypad_willox.lua
end

function TOOL:SetupKeypad(ent, pass)
	local data = {
		Password = pass,

		RepeatsGranted = self:GetClientNumber("repeats_granted"),
		RepeatsDenied = self:GetClientNumber("repeats_denied"),

		LengthGranted = self:GetClientNumber("length_granted"),
		LengthDenied = self:GetClientNumber("length_denied"),

		DelayGranted = self:GetClientNumber("delay_granted"),
		DelayDenied = self:GetClientNumber("delay_denied"),

		InitDelayGranted = self:GetClientNumber("init_delay_granted"),
		InitDelayDenied = self:GetClientNumber("init_delay_denied"),

		OutputOn = self:GetClientNumber("output_on"),
		OutputOff = self:GetClientNumber("output_off"),

		Secure = util.tobool(self:GetClientNumber("secure")),

		Owner = self:GetOwner()
	}

	ent:SetData(data)
end

function TOOL:RightClick(tr)
    if not WireLib then return false end
	if not IsValid(tr.Entity) or not tr.Entity:GetClass():lower() == "keypad_wire" then return false end

	if CLIENT then return true end

	local ply = self:GetOwner()
	local password = tonumber(ply:GetInfo("keypad_willox_wire_password"))

	local spawn_pos = tr.HitPos
	local trace_ent = tr.Entity

	if password == nil or (string.len(tostring(password)) > 4) or (string.find(tostring(password), "0")) then
		ply:PrintMessage(3, "Invalid password!")
		return false
	end

	if trace_ent.KeypadData.Owner == ply then
		self:SetupKeypad(trace_ent, password)

		return true
	end
end

function TOOL:LeftClick(tr)
    if not WireLib then return false end
	if IsValid(tr.Entity) and tr.Entity:GetClass() == "player" then return false end

	if CLIENT then return true end

	local ply = self:GetOwner()
	local password = self:GetClientNumber("password")

	local spawn_pos = tr.HitPos + tr.HitNormal
	local trace_ent = tr.Entity

	if password == nil or (string.len(tostring(password)) > 4) or (string.find(tostring(password), "0")) then
		ply:PrintMessage(3, "Invalid password!")
		return false
	end

	if not self:GetWeapon():CheckLimit("keypads") then return false end

	local ent = ents.Create("keypad_wire")
	ent:SetPos(spawn_pos)
	ent:SetAngles(tr.HitNormal:Angle())
	ent:Spawn()

	ent:SetPlayer(ply)

	local freeze = util.tobool(self:GetClientNumber("freeze"))
	local weld = util.tobool(self:GetClientNumber("weld"))

	if freeze or weld then
		local phys = ent:GetPhysicsObject() 

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	if weld then
		local weld = constraint.Weld(ent, trace_ent, 0, 0, 0, true, false)
	end

	self:SetupKeypad(ent, password)

	undo.Create("Keypad")
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
	undo.Finish()

	ply:AddCount("keypads", ent)
	ply:AddCleanup("keypads", ent)

	return true
end


if CLIENT then
	local function ResetSettings(ply)
		ply:ConCommand("keypad_willox_wire_repeats_granted 0")
		ply:ConCommand("keypad_willox_wire_repeats_denied 0")
		ply:ConCommand("keypad_willox_wire_length_granted 0.1")
		ply:ConCommand("keypad_willox_wire_length_denied 0.1")
		ply:ConCommand("keypad_willox_wire_delay_granted 0")
		ply:ConCommand("keypad_willox_wire_delay_denied 0")
		ply:ConCommand("keypad_willox_wire_init_delay_granted 0")
		ply:ConCommand("keypad_willox_wire_init_delay_denied 0")
        ply:ConCommand("keypad_willox_wire_output_on 1")
        ply:ConCommand("keypad_willox_wire_output_off 0")
	end

	concommand.Add("keypad_willox_wire_reset", ResetSettings)

	function TOOL.BuildCPanel(CPanel)
        if not WireLib then 
            CPanel:Help("This tool requires Wiremod to function")
            CPanel:Help("http://wiremod.com/")
            CPanel:Help("Workshop Addon #160250458")
        else
    		local r, l = CPanel:TextEntry("Access Password", "keypad_willox_wire_password")
    		r:SetTall(22)

    		CPanel:ControlHelp("Max Length: 4\nAllowed Digits: 1-9")

    		CPanel:CheckBox("Secure Mode", "keypad_willox_wire_secure")
    		CPanel:CheckBox("Weld", "keypad_willox_wire_weld")
    		CPanel:CheckBox("Freeze", "keypad_willox_wire_freeze")

            CPanel:NumSlider("Output On:", "keypad_willox_wire_output_on", -10, 10, 0)
            CPanel:NumSlider("Output Off:", "keypad_willox_wire_output_off", -10, 10, 0)

    		local granted = vgui.Create("DForm")
    			granted:SetName("Access Granted Settings")

	    		granted:NumSlider("Hold Length", "keypad_willox_wire_length_granted", 0.1, 10, 2)
	    		granted:NumSlider("Initial Delay", "keypad_willox_wire_init_delay_granted", 0, 10, 2)
	    		granted:NumSlider("Multiple Press Delay", "keypad_willox_wire_delay_granted", 0, 10, 2)
	    		granted:NumSlider("Additional Repeats", "keypad_willox_wire_repeats_granted", 0, 5, 0)
    		CPanel:AddItem(granted)
    		
    		local denied = vgui.Create("DForm")
    			denied:SetName("Access Denied Settings")

	    		denied:NumSlider("Hold Length", "keypad_willox_wire_length_denied", 0.1, 10, 2)
	    		denied:NumSlider("Initial Delay", "keypad_willox_wire_init_delay_denied", 0, 10, 2)
	    		denied:NumSlider("Multiple Press Delay", "keypad_willox_wire_delay_denied", 0, 10, 2)
	    		denied:NumSlider("Additional Repeats", "keypad_willox_wire_repeats_denied", 0, 5, 0)
    		CPanel:AddItem(denied)

			CPanel:Button("Default Settings", "keypad_willox_wire_reset")

			CPanel:Help("")

			local faq = CPanel:Help("Information")
				faq:SetFont("GModWorldtip")

			CPanel:Help("You can enter your password with your numpad when numlock is enabled!")

			CPanel:Help("")

			CPanel:Help("Created by Willox ( http://steamcommunity.com/id/wiox )")
        end
	end
end