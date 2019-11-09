ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.Model = Model("models/props_lab/keypad.mdl")

ENT.Spawnable = true

ENT.Scale = 0.02
ENT.Value = ""

ENT.Status_None = 0
ENT.Status_Granted = 1
ENT.Status_Denied = 2

ENT.Command_Enter = 0
ENT.Command_Accept = 1
ENT.Command_Abort = 2

ENT.IsKeypad = true

AccessorFunc(ENT, "m_Password", "Password", FORCE_STRING)

function ENT:Initialize()
	self:SetModel(self.Model)

	if CLIENT then
		self.Mins = self:OBBMins()
		self.Maxs = self:OBBMaxs()

		self.Width2D, self.Height2D = (self.Maxs.y - self.Mins.y) / self.Scale , (self.Maxs.z - self.Mins.z) / self.Scale
	end

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
		end

		self:SetValue("")
		self:SetPassword("1337")

		if(not self.KeypadData) then
			self:SetData({
				Password = 1337,

				RepeatsGranted = 0,
				RepeatsDenied = 0,

				LengthGranted = 0,
				LengthDenied = 0,

				DelayGranted = 0,
				DelayDenied = 0,

				InitDelayGranted = 0,
				InitDelayDenied = 0,

				KeyGranted = 0,
				KeyDenied = 0,

				Secure = false,
				Owner = NULL
			})
		end

		self:Reset()
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "Text" )

	self:NetworkVar( "Int", 0, "Status" )

	self:NetworkVar( "Bool", 0, "Secure" )
end