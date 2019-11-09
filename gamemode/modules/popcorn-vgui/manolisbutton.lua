local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(101,40)

	self:SetFont("manolisButtonFont")
	self:SetTextColor(Color(100,100,100,255))
end

function PANEL:SetColor(c)
	self:SetTextColor(c)
end


PANEL.isDepressed = false
function PANEL:Paint(w,h)
	if(self.Alternate) then
		surface.SetDrawColor(43,48,59, 255)
		if(self.Hovered) then
			self:GetParent().Hovered = true
			surface.SetDrawColor(43+2,48+2,59+2,255)
		end

		if(self.depressed) then
			surface.SetDrawColor(43+2, 48+2, 59+2, 255)
		end

	elseif(self.F4) then
			surface.SetDrawColor(35, 40, 48, 255)
		if(self.Hovered) then
			self:GetParent().Hovered = true
			surface.SetDrawColor(35+3,40+3,48+3,255)
		end

	else
		surface.SetDrawColor(35, 40, 48, 255)
		if(self.Hovered) then
			self:GetParent().Hovered = true
			surface.SetDrawColor(35+2,40+2,48+2,255)
		end

		if(self.depressed) then
			surface.SetDrawColor(35+4, 40+4, 48+4, 255)
		end
	end

	if(self.depressed) then
		if(not self.isDepressed) then
			self.isDepressed = true
			self:SetDepressedC(true)
		end
	else
		if(self.isDepressed) then
			self.isDepressed = false
			self:SetDepressedC(false)
		end
	end


	surface.DrawRect(0,0, w, h)
end

function PANEL:SetDepressedC(v)
	if(v) then
		self:SetTextColor(Color(255,255,255,120))
	else
		self:SetTextColor(Color(100,100,100,255))	
	end

	
end
vgui.Register("ManolisButton", PANEL, "DButton")
