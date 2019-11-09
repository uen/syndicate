AddCSLuaFile "cl_init.lua"
AddCSLuaFile "cl_maths.lua"
AddCSLuaFile "cl_panel.lua"
AddCSLuaFile "sh_init.lua"

include "sh_init.lua"

util.AddNetworkString("Keypad")


net.Receive("Keypad", function(_, ply)
	local ent = net.ReadEntity()

	if not IsValid(ply) or not IsValid(ent) or not ent:GetClass():lower() == "keypad" then
		return
	end

	if ent:GetStatus() ~= ent.Status_None then
		return
	end

	if ply:EyePos():Distance(ent:GetPos()) >= 120 then
		return
	end

	local command = net.ReadUInt(4)

	if command == ent.Command_Enter then
		local val = tonumber(ent:GetValue() .. net.ReadUInt(8))

		if val and val > 0 and val <= 9999 then
			ent:SetValue(tostring(val))
			ent:EmitSound("buttons/button15.wav")
		end
	elseif command == ent.Command_Abort then
		ent:SetValue("")
	elseif command == ent.Command_Accept then
		if ent:GetValue() == ent:GetPassword() then
			ent:Process(true)
		else
			ent:Process(false)
		end
	end
end)

function ENT:SetValue(val)
	self.Value = val

	if self:GetSecure() then
		self:SetText(string.rep("*", #val))
	else
		self:SetText(val)
	end
end

function ENT:GetValue()
	return self.Value
end

function ENT:Process(granted)
	local length, repeats, delay, initdelay, owner, key

	if(granted) then
		self:SetStatus(self.Status_Granted)

		length = self.KeypadData.LengthGranted
		repeats = math.min(self.KeypadData.RepeatsGranted, 50)
		delay = self.KeypadData.DelayGranted
		initdelay = self.KeypadData.InitDelayGranted
		owner = self.KeypadData.Owner
		key = tonumber(self.KeypadData.KeyGranted) or 0
	else
		self:SetStatus(self.Status_Denied)

		length = self.KeypadData.LengthDenied
		repeats = math.min(self.KeypadData.RepeatsDenied, 50)
		delay = self.KeypadData.DelayDenied
		initdelay = self.KeypadData.InitDelayDenied
		owner = self.KeypadData.Owner
		key = tonumber(self.KeypadData.KeyDenied) or 0
	end

	timer.Simple(math.max(initdelay + length * (repeats + 1) + delay * repeats + 0.25, 2), function() -- 0.25 after last timer
		if(IsValid(self)) then
			self:Reset()
		end
	end)

	timer.Simple(initdelay, function()
		if(IsValid(self)) then
			for i = 0, repeats do
				timer.Simple(length * i + delay * i, function()
					if(IsValid(self) and IsValid(owner)) then
						numpad.Activate(owner, key, true)
					end
				end)

				timer.Simple(length * (i + 1) + delay * i, function()
					if(IsValid(self) and IsValid(owner)) then
						numpad.Deactivate(owner, key, true)
					end
				end)
			end
		end
	end)

	if(granted) then
		self:EmitSound("buttons/button9.wav")
	else
		self:EmitSound("buttons/button11.wav")
	end
end

function ENT:SetData(data)
	self.KeypadData = data

	self:SetPassword(data.Password or "1337")
	self:Reset()
end

function ENT:GetData()
	return self.KeypadData
end

function ENT:Reset()
	self:SetValue("")
	self:SetStatus(self.Status_None)
	self:SetSecure(self.KeypadData.Secure)
end