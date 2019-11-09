local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(0,0)
	self.slot = {}
	self.items = {}
end

function PANEL:SetSlots(number)
	local y = 1

	local numX = math.max(4, number)
	local numY = math.ceil(number/4)

	local currentX = 1
	local currentY = 1
	for i=1,number do
		if(currentX>4) then
			currentX = 1
			currentY = currentY+1
		end

		local slot = vgui.Create("ManolisSlot", self)
		local size = 77
		slot:SetPos(((currentX)*(size+3))-80, (currentY*(size+3))-size)
		
		currentX = currentX + 1
		table.insert(self.slot, slot)
	end

	self:SetSize(80*numX, 80*numY)
end



vgui.Register("ManolisSlotsItem", PANEL, "ManolisSlots")