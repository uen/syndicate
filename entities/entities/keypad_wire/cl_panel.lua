surface.CreateFont("KeypadAbort", {font = "Roboto", size = 45, weight = 900})
surface.CreateFont("KeypadOK", {font = "Roboto", size = 60, weight = 900})
surface.CreateFont("KeypadNumber", {font = "Roboto", size = 70, weight = 600})
surface.CreateFont("KeypadEntry", {font = "Roboto", size = 120, weight = 900})
surface.CreateFont("KeypadStatus", {font = "Roboto", size = 60, weight = 900})

local COLOR_GREEN = Color(0, 255, 0)
local COLOR_RED = 	Color(255, 0, 0)

local function DrawLines(lines, x, y)
	local text = table.concat(lines, "\n")
	local total_w, total_h = surface.GetTextSize(text)

	local y_off = 0

	for k, v in ipairs(lines) do
		local w, h = surface.GetTextSize(v)

		surface.SetTextPos(x - w / 2, y - total_h / 2 + y_off)
		surface.DrawText(v)

		y_off = y_off + h
	end	
end

local elements = {
	{ -- Screen
		x = 0.075,
		y = 0.04,
		w = 0.85,
		h = 0.25,
		color = Color(50, 75, 50, 255),
		render = function(self, x, y)
			local status = self:GetStatus()

			if status == self.Status_None then
				surface.SetFont("KeypadEntry")

				local text = self:GetText()

				local textw, texth = surface.GetTextSize(text)			

				surface.SetTextColor(color_white)
				surface.SetTextPos(x - textw / 2, y - texth / 2)
				surface.DrawText(text)
			elseif status == self.Status_Denied then
				surface.SetFont("KeypadStatus")
				surface.SetTextColor(COLOR_RED)

				if self:GetText() == "1337" then
					DrawLines({"ACC355", "D3N13D"}, x, y)
				else
					DrawLines({"ACCESS", "DENIED"}, x, y)
				end
			elseif status == self.Status_Granted then
				surface.SetFont("KeypadStatus")
				surface.SetTextColor(COLOR_GREEN)

				if self:GetText() == "1337" then
					DrawLines({"ACC355", "GRAN73D"}, x, y)
				else
					DrawLines({"ACCESS", "GRANTED"}, x, y)
				end
			end
		end,
	},
	{ -- ABORT
		x = 0.075,
		y = 0.04 + 0.25 + 0.03,
		w = 0.85 / 2 - 0.04 / 2 + 0.05,
		h = 0.125,
		color = Color(120, 25, 25),
		hovercolor = Color(180, 25, 25),
		text = "ABORT",
		font = "KeypadAbort",
		click = function(self)
			self:SendCommand(self.Command_Abort)
		end
	},
	{ -- OK
		x = 0.5 + 0.04 / 2 + 0.05,
		y = 0.04 + 0.25 + 0.03,
		w = 0.85 / 2 - 0.04 / 2 - 0.05,
		h = 0.125,
		color = Color(25, 120, 25),
		hovercolor = Color(25, 180, 25),
		text = "OK",
		font = "KeypadOK",
		click = function(self)
			self:SendCommand(self.Command_Accept)
		end
	}
}

do -- Create numbers
	for i = 1, 9 do
		local column = (i - 1) % 3

		local row = math.floor((i - 1) / 3)
		
		local element = {
			x = 0.075 + (0.3 * column),
			y = 0.175 + 0.25 + 0.05 + ((0.5 / 3) * row),
			w = 0.25,
			h = 0.13,
			color = Color(120, 120, 120),
			hovercolor = Color(180, 180, 180),
			text = tostring(i),
			click = function(self)
				self:SendCommand(self.Command_Enter, i)
			end
		}

		table.insert(elements, element)
	end
end


function ENT:Paint(w, h, x, y)
	local hovered = self:GetHoveredElement()

	for k, element in ipairs(elements) do
		surface.SetDrawColor(element.color)

		local element_x = w * element.x
		local element_y = h * element.y
		local element_w = w * element.w
		local element_h = h * element.h

		if element == hovered and element.hovercolor then
			surface.SetDrawColor(element.hovercolor)
		end

		surface.DrawRect(
			element_x, 
			element_y,
			element_w,
			element_h
		)

		local cx = element_x + element_w / 2
		local cy = element_y + element_h / 2

		if element.text then
			surface.SetFont(element.font or "KeypadNumber")

			local textw, texth = surface.GetTextSize(element.text)

			surface.SetTextColor(color_black)
			surface.SetTextPos(cx - textw / 2, cy - texth / 2)
			surface.DrawText(element.text)
		end

		if element.render then
			element.render(self, cx, cy)
		end

	end
end

function ENT:GetHoveredElement()
	local scale = self.Scale

	local w, h = self.Width2D, self.Height2D
	local x, y = self:CalculateCursorPos()

	for _, element in ipairs(elements) do
		local element_x = w * element.x
		local element_y = h * element.y
		local element_w = w * element.w
		local element_h = h * element.h

		if 	element_x < x and element_x + element_w > x and
			element_y < y and element_y + element_h > y 
		then
			return element
		end
	end
end