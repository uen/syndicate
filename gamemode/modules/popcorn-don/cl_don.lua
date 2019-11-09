if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.don) then manolis.popcorn.don = {} end

local donFrame = nil
local lastOpen = 0

local function toggleDon()
	if not (LocalPlayer():Alive()) then return end
	if(CurTime() < lastOpen+.5) then return end
	lastOpen = CurTime()
	if(manolis.popcorn.don.panel and manolis.popcorn.don.panel:IsVisible()) then
		return
	end
	
	donFrame = vgui.Create('ManolisFrame', nil)
	donFrame:SetRealSize(650,450)
	donFrame:Center()
	donFrame:SetVisible(true)
	donFrame:SetBackgroundBlur(true)
	donFrame:SetText(DarkRP.getPhrase('the_don'))

	local content = vgui.Create("HTML", donFrame)
	content:SetSize(650-230-10,410-50-10-5)
	content:SetPos(235,45)

	local giftList = vgui.Create("ManolisScrollPanel", donFrame)
	giftList:SetPos(5,45)
	giftList:SetSize(230,400)

	local gift = 0
	for k,v in pairs(manolis.popcorn.don.gifts) do
		local a = vgui.Create("ManolisButton", giftList)
		a:SetText(v.name)

		a:SetWide(215)
		
		a.DoClick = function()
			content.Update(v)
			gift = k
			for k,v in pairs(giftList:GetItems()) do
				v.depressed = false
			end

			a.depressed = true
		end
		giftList:Add(a)
	end

	content:SetHTML([[
		<!doctype html>
		<html>
			<head>
				<link href='https://fonts.googleapis.com/css?family=Open+Sans:400,300,600' rel='stylesheet' type='text/css'>
			</head>
			<body style="font-family: 'Open Sans', sans-serif; font-size: 19px; font-weight:bold; color:#FFFFFF">
				<h2 style="padding:0; margin:0; margin-bottom:10px;">]]..DarkRP.getPhrase('the_don')..[[</h2>
			</body>
		</html>
	]])

	content.Update = function(gift)
		local html = [[
			<!doctype html>
			<html>
			<head>
				<link href='https://fonts.googleapis.com/css?family=Open+Sans:400,300,600' rel='stylesheet' type='text/css'>
			</head>
			<body>

			<style>
				table,body,p{
					font-size:12px;
					font-weight:600;
					font-family: 'Open Sans', sans-serif;
					color:#fff;
				}
				.manolisItem{
					display:block;
					margin-bottom:5px;
				}

				.manolisItem h3{
					display:inline-block;

					margin:0;
				}

				.manolisItem img{
					display:inline-block;
				}

				.itemTable{
					padding:4px;
					border-spacing:0;
					border:0;
					margin-top:5px;
				}

				.padLeft{
					padding-left:10px;
				}
				
				]]..manolis.popcorn.dermaScrollCSS..[[
			</style>
		]]	
		
		local levelColor = (manolis.popcorn.levels.HasLevel(LocalPlayer(), gift.min) and ((manolis.popcorn.levels.GetLevel(LocalPlayer()))<gift.max)) and 'rgba(0,255,0,1)' or 'rgba(255,0,0,1)'
		local price = gift.price==0 and DarkRP.getPhrase('free_gift') or DarkRP.formatMoney(gift.price)
		html = html .. "<h2 style='margin-bottom:0; color:rgb(255,255,255)'>" .. gift.name .. "</b></h2>"
		html = html .. "<h4 style='margin-top:0; margin-bottom:0; color:"..levelColor.."'>"..DarkRP.getPhrase("don_level_range",gift.min,gift.max).."</h2>"
		html = html .. "<h4 style='margin-top:0; margin-bottom:7px;'>"..DarkRP.getPhrase("don_price")..": "..price.."</h3>"
		html = html .. "<p>"..gift.description.."</p>"

		content:SetHTML(html)
	end

	local ok = vgui.Create("ManolisButton",donFrame)
	ok:SetPos(650-101-10-10-101,400)
	ok.DoClick = function()
		RunConsoleCommand("ManolisPopcornDoDon", gift)
		gui.EnableScreenClicker(false)
		donFrame:Remove()
		donFrame = nil
	end
	ok:SetText(DarkRP.getPhrase('accept_don'))

	local cancel = vgui.Create("ManolisButton", donFrame)
	cancel:SetPos(650-101-10,400)
	cancel:SetText(DarkRP.getPhrase('close_don'))
	cancel.DoClick = function()
		gui.EnableScreenClicker(false)
		donFrame:Remove()
		donFrame = nil
	end

	gui.EnableScreenClicker(true)
	donFrame.header.closeButton:Remove()
	manolis.popcorn.don.panel = donFrame
end

net.Receive("ManolisPopcornDonOpen", function(len)
	toggleDon()
end)

manolis.popcorn.don.toggle = toggleDon