local PANEL = {}

function PANEL:Init()
	self:SetVisible(true)
	self:SetSize(100,50)
	self.tabs = {}
end

function PANEL:Clear()
	for k,v in pairs(self.tabs) do
		v.button:Remove()
		v.sheet:Remove()
	end

	self.tabs = {}
end

function PANEL:AddTab(buttonText, sheet)
	local button = vgui.Create("ManolisButton", self)
	button:SetPos(#self.tabs*105+5,0)
	button:SetText(buttonText)
	sheet:SetParent(self)
	sheet:SetPos(0,45)
	button.DoClick = function()
		for k,v in pairs(self.tabs) do
			if(v.button:GetText()==buttonText) then
				v.sheet:SetVisible(true)
				v.button.depressed = true
			else
				v.button.depressed = false
				v.sheet:SetVisible(false)
			end
			
		end

		if(button.DoClickAlt) then
			button.DoClickAlt()
		end
	end
	sheet:SetVisible(false)
	table.insert(self.tabs, {button=button, sheet=sheet})

	if(#self.tabs==1) then
		self.tabs[1].sheet:SetVisible(true)
		self.tabs[1].button.depressed = true
	end

	return {button=button, sheet=sheet}
end

function PANEL:Alternate()
	self.Alt = true
end

function PANEL:Paint(w,h)
	if(self.Alt) then return end
	surface.SetDrawColor(28,31,38,255)
	
	surface.DrawRect(0,0,w,45)
end

vgui.Register("ManolisTabs", PANEL, "Panel")
