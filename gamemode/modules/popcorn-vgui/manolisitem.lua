local function pointinrectangle( px, py, x, y, width, height )
	return px >= x and
	py >= y and
	px < x + width and
	py < y + height
end

local PANEL = {}
function PANEL:Init()
	self:SetSize(77,77)
	self:SetVisible(true)
	self.Save = {x=0, y=0}
	self.Dragging = {0,0}
	self.Moving = false

	self:GetParent().item = self

	self.icon = vgui.Create("ManolisImage", self)
	self.icon:SetImage('manolis/popcorn/icons/unknown.png')
	self.icon:SetSize(77,77)

	self.quantity = vgui.Create("DLabel", self)
	self.quantity:SetFont("ManolisItemQuantity")
	self.quantity:SetTextColor(Color(255,255,255,255))
	self.quantity:SetText("")
	self.quantity:SetSize(68,69)
	self.quantity:SetPos(2,3)
	self.quantity:SetContentAlignment(3)

	self.quantity:SetZPos(1000)


	self.rem = self.Remove
	self.Remove = function()
		if(self.info) then self.info:Remove() end
		self:rem()
	end
end

function PANEL:Go()
	if(!self.t) then
		ErrorNoHalt('Go called without initialising t in ManolisItem')
		return
	end

	local useModel = false
	if(!file.Exists("materials/manolis/popcorn/icons/"..self.t.icon, 'GAME')) then
		if(self.t.json and self.t.json.model) then
			self.icon:Remove()
			self.icon = vgui.Create("SpawnIcon", self)
			self.icon:SetSize(60,60)
			self.icon:SetModel(self.t.json.model)
			self.icon:SetPos(((77-60)/2),((77-60)/2))
			self.icon.Paint = function(self,w,h)
				return
			end

			self.icon.PaintOver = function()
				return
			end

			self.icon:SetTooltip(false)

			self.icon.OnMousePressed = function(s, key)
				self:OnMousePressed(key)
				return false
			end

			self.icon.OnMouseReleased = function(s, key)
				self:OnMouseReleased(key)
				return false
			end

			self.icon.PerformLayout = function(self)
				self.Icon:StretchToParent(0,0,0,0)
				return
			end

			self.icon.OnCursorEntered =  function()
				self:OnCursorEntered()
			end

			self.icon.OnCursorExited =  function()
				self:OnCursorExited()
			end

			useModel = true
		end
	end

	if(!useModel) then
		self.icon:SetImage('manolis/popcorn/icons/'..self.t.icon, 'manolis/popcorn/icons/unknown.png')
	end

	if(self.t.quantity and tonumber(self.t.quantity)>1) then
		self.quantity:SetText(self.t.quantity)
	end
end

function PANEL:SetQuantity(q)
	self.t.quantity = q
	self.quantity:SetText(q)
end

local lastPressed = 0
local mouseIsDown = false
function PANEL:OnMousePressed(key)
	if(self:GetParent()) then
		if(self:GetParent():GetParent()) then
			if(self:GetParent():GetParent().DeselectAll) then
				self:GetParent():GetParent():DeselectAll()
			end
		end
	end
	if(self.disabled) then return end
	if(key!=MOUSE_LEFT) then return end

	if(mouseIsDown) then return end
	if(IsValid(self.previousParent)) then return end
	mouseIsDown = true

	lastPressed = CurTime()

	localX, localY = self:ScreenToLocal(gui.MouseX(),gui.MouseY())
	self.Dragging = {localX, localY}
	self.Moving = true


	self.previousParent = self:GetParent()

	self:SetParent(nil)
	self:SetZPos(32766)

	local mouseX, mouseY = gui.MouseX(), gui.MouseY()
	local PosX = math.Clamp(mouseX-self.Dragging[1], 1, ScrW()-1)
	local PosY = math.Clamp(mouseY-self.Dragging[2], 1, ScrH()-1)

	self:SetPos(PosX, PosY)
	HideInfo(self)
end

function PANEL:Clear()
	self:SetPos(self.Save.x,self.Save.y)
end

function PANEL:Return()
	if(!self.previousParent) then return end
	self:SetParent(self.previousParent)
	HideInfo(self)
	self:Clear()

	if(self.Hovered) then
		ShowInfo(self)
	end
end

function PANEL:OnRemove()
	if(self.info) then
		self.info:Remove()
	end
end

function PANEL:OnMouseReleased(key)
	if(key!=MOUSE_LEFT) then return end
	mouseIsDown = false
	if(lastPressed+.1 > CurTime()) then
		if(self.previousParent) then
			if(self.previousParent.OnSelected) then self.previousParent:OnSelected(self) end
		end
	end

	self.Dragging = {0,0}
	self.Moving = false

	local newPanel = self.previousParent and self.previousParent.ItemDropped and self.previousParent:ItemDropped(self, self.previousParent) 
	if(newPanel) then
		if((newPanel:GetParent() and newPanel:GetParent():GetName()=='mainInventory') and (self.previousParent:GetParent() and self.previousParent:GetParent():GetName()=='mainInventory')) then			
			if(newPanel.item) then
				if(self.t.type=='upgrade') then
					if(newPanel.item.t) then
						if(newPanel.item.t.json) then
							if(newPanel.item.t.json.type=='weapon' or newPanel.item.t.type=='armor') then
								if(newPanel.item.t.json.type==self.t.json.type) then
									Manolis_Query(DarkRP.getPhrase('confirm_upg'), DarkRP.getPhrase('upg_do'), DarkRP.getPhrase('cancel'), function() end, DarkRP.getPhrase('upg_upg'), function()
										RunConsoleCommand("ManolisPopcornUpgradeItem", self.t.id, newPanel.item.t.id)
										newPanel = false
									end)
								end
							end
						end
					end
				elseif(self.t.type=='material') then
					if(newPanel.item and newPanel.item.t) then
						if(newPanel.item.t.type=='material') then
							if(self.t.name == newPanel.item.t.name) then
								local words = {}
								for word in self.t.name:gmatch("%w+") do
									table.insert(words, word)
								end
								if(#words>0) then
									local mat = manolis.popcorn.crafting.FindMaterial(words[1])
									if(mat) then
										if((self.t.quantity + newPanel.item.t.quantity) < mat.maxStack) then
											newPanel.item:SetQuantity((self.t.quantity + newPanel.item.t.quantity))
											RunConsoleCommand("ManolisPopcornStackItem", self.t.id, newPanel.item.t.id)
											self.previousParent.item = nil
											self.previousParent = nil
											self:Remove()
										end
									end
								end
							end
						elseif(newPanel.item.t.type=='armor' or newPanel.item.t.type=='primary' or newPanel.item.t.type=='side') then
							if(self.t.name==DarkRP.getPhrase('crystal',DarkRP.getPhrase('rein_stone'))) then
								Manolis_Query(DarkRP.getPhrase('reinforce_confirm'), DarkRP.getPhrase('reinforce_reinforce'), DarkRP.getPhrase('cancel'), function() end, DarkRP.getPhrase('reinforce_reinforce'), function()
									RunConsoleCommand("ManolisPopcornReinforceItem", self.t.id, newPanel.item.t.id)
									newPanel = false
								end)
							end
						end
					end
				elseif(self.t.type=='credit_item') then
					if(newPanel.item and newPanel.item.t) then
						if(newPanel.item.t.type=='primary' or newPanel.item.t.type=='side') then
							if(self.t.json.aid=='tablet') then
								Manolis_StringRequest("Name your item", "Please enter the items new name", "", "Confirm", function(val)
									if(!val or val=="") then return end
									RunConsoleCommand("ManolisPopcornRenameItem", self.t.id, newPanel.item.t.id, val)
									newPanel = false
								end)
							end
						end


						if(newPanel.item.t.type=='primary' or newPanel.item.t.type=='side' or newPanel.item.t.type=='armor') then
							if(((self.t.json.aid=='takedown' and newPanel.item.t.type=='primary') or (self.t.json.aid=='takedown' and newPanel.item.t.type=='side')) or (self.t.json.aid=='takedownarmor' and newPanel.item.t.type=='armor')) then
								Manolis_Query("Are you sure you wish to lower the level of this item?", "Confirm", DarkRP.getPhrase('cancel'), function() end, "Takedown", function()
									RunConsoleCommand("ManolisPopcornTakedownItem", self.t.id, newPanel.item.t.id)
									newPanel = false
								end)
								

							elseif(((self.t.json.aid=='reset' and newPanel.item.t.type=='primary') or (self.t.json.aid=='reset' and newPanel.item.t.type=='side')) or (self.t.json.aid=='resetarmor' and newPanel.item.t.type=='armor')) then
								Manolis_Query("Are you sure you wish to remove the upgrades from this item?", "Confirm", DarkRP.getPhrase('cancel'), function() end, "Confirm", function()
									RunConsoleCommand("ManolisPopcornResetItem", self.t.id, newPanel.item.t.id)
									newPanel = false
								end)
							end
						end
					end
				end
			end
		end
	end

	if not(newPanel) or (newPanel.item) then
		self:Return()
	else
		if(newPanel.Disabled) then return self:Return() end
		local res = newPanel:DroppedInto(self.t, self.previousParent)
		if(res==1) then
			self.previousParent.item = nil
			self.previousParent = nil

			self:Remove()
		elseif(res) then
			if(manolis.popcorn.keys[IN_SPEED]) then
				if(self.previousParent:GetParent():GetName()=='mainInventory' and self.previousParent:GetParent() == newPanel:GetParent()) then
					if(self.t.type=='material' and self.t.quantity>1) then
						Manolis_StringRequest(DarkRP.getPhrase('split'), DarkRP.getPhrase('split_am'), "1", DarkRP.getPhrase('split_split'), function(d)
							RunConsoleCommand("ManolisPopcornSplitItem", self.t.id, d, newPanel.pos, self.t.page)
						end)
						self:Return()
						return
					end
				end
			end

			self:SetParent(newPanel)
			newPanel.item = self
			if(newPanel:GetParent() and newPanel:GetParent().isSlots) then
				table.insert(newPanel:GetParent().items, self)
			end

			self.previousParent.Selected = false

			self.previousParent.item = nil
			if(self.previousParent:GetParent() and self.previousParent:GetParent().isSlots) then
				for k,v in pairs(self.previousParent:GetParent().items) do
					if(v.t) then
						if(v.t.id==self.t.id) then
							table.remove(self.previousParent:GetParent().items, k)
						end
					end
				end
			end
			self:SetPos(0,0)
			self.previousParent = nil
		else
			self:Return()
		end

	end

	self.previousParent = nil
end

function HideInfo(p)
	if(p.info and IsValid(p.info)) then
		p.info:SetVisible(false)
	end
end

function ShowInfo(p)
	if(!p.info or !IsValid(p.info)) then
		if(!IsValid(p.info) and p.info) then p.info = nil end
		p.info = vgui.Create("ManolisItemInfo")
		p.info.t = p.t
		p.info:SetZPos(32760)
		p.info:Initiate()
	end

	local x,y = p:LocalToScreen(0,0)
	p.info:SetPos(80+x,y)
	p.info:SetVisible(true)
end

function PANEL:OnCursorEntered()
	if(!self.Moving) then
		ShowInfo(self)
	end
end

function PANEL:OnCursorExited()
	if(!self.info) then return false end 
	HideInfo(self)
end


local i = 0
function PANEL:Paint(w,h)

	if(self.Selected) then
		draw.RoundedBox(4,1,1,w-2,h-2,Color(255,255,255,255))
	end

	surface.SetDrawColor(255,255,255,255)
	surface.SetMaterial(manolis.popcorn.materialCache['item-bg'])

	surface.DrawTexturedRect(0,0,w,h)

	local mouseX, mouseY = gui.MouseX(), gui.MouseY()
	if(self.Moving) then
		
		local PosX = math.Clamp(mouseX-self.Dragging[1], 1, ScrW()-1)
		local PosY = math.Clamp(mouseY-self.Dragging[2], 1, ScrH()-1)
		if(self.Selected) then
			self.Selected = false
			self:GetParent().Selected = false
		end
		self:SetPos(PosX or 0, PosY or 0)
		if(i>=10) then
			table.sort(manolis.popcorn.inventory.itemDrops, function(a,b) return (a.GetParentZPos and a:GetParentZPos() or 0) > (b.GetParentZPos and b:GetParentZPos() or 0) end)

			for k,v in pairs(manolis.popcorn.inventory.itemDrops or {}) do
				if(IsValid(v)) then
					local localX, localY = v:ScreenToLocal(mouseX, mouseY)
					if(pointinrectangle(localX,localY,0,0,v:GetWide(), v:GetTall())) then
						v.Hovered = true
					else
						v.Hovered = false
					end
				end
			end
			i=0
		end
		i = i + 1
	end

	local localX, localY = self:ScreenToLocal(mouseX, mouseY)
	if(!pointinrectangle(localX, localY,0,0,self:GetWide(), self:GetTall())) then
		if(self.info and IsValid(self.info)) then
			self.info:SetVisible(false)
		end

		if(!input.IsMouseDown(MOUSE_LEFT)) then
			if(mouseIsDown) then
				self:OnMouseReleased(MOUSE_LEFT)
			end
		end
	end
end

vgui.Register("ManolisItem", PANEL, "Panel")