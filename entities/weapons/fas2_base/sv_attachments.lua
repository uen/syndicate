local group, att, wep, found, t, t2, CT

local function FAS2_Attach(ply, com, args)
	if not ply:Alive() then
		return
	end
	
	wep = ply:GetActiveWeapon()
	
	if not IsValid(wep) or not wep.IsFAS2Weapon then
		return
	end
	
	group, att = tonumber(args[1]), args[2]
	
	if not group or not att or not wep.Attachments or wep.dt.Status != FAS_STAT_CUSTOMIZE or wep.dt.Bipod or wep.NoAttachmentMenu or not table.HasValue(ply.FAS2Attachments, att) then
		return
	end
	
	t = wep.Attachments[group]
	
	if t then
		found = false
		
		for k, v in pairs(t.atts) do
			if v == att then
				found = true
			end
		end
		
		if t.lastdeattfunc then
			t.lastdeattfunc(ply, wep)
			t.lastdeattfunc = nil
		end
		
		if found then
			t.last = att
			
			t2 = FAS2_Attachments[att]
			
			if t2.attfunc then
				t2.attfunc(ply, wep)
			end
				
			if t2.deattfunc then
				t.lastdeattfunc = t2.deattfunc
			end
			
			umsg.Start("FAS2_ATTACH", ply)
				umsg.Short(group)
				umsg.String(att)
			umsg.End()
		end
	end
end

concommand.Add("fas2_attach", FAS2_Attach)

local function FAS2_Detach(ply, com, args)
	if not ply:Alive() then
		return
	end
	
	wep = ply:GetActiveWeapon()
	
	if not IsValid(wep) or not wep.IsFAS2Weapon then
		return
	end
	
	group = tonumber(args[1])
	
	if not group or not wep.Attachments or wep.dt.Status != FAS_STAT_CUSTOMIZE or wep.dt.Bipod or wep.NoAttachmentMenu then
		return
	end
	
	t = wep.Attachments[group]
	
	if t and t.last then
		if t.lastdeattfunc then
			t.lastdeattfunc(ply, wep)
		end
		
		t.lastdeattfunc = nil
		
		umsg.Start("FAS2_DETACH", ply)
			umsg.Short(group)
		umsg.End()
	end
end

concommand.Add("fas2_detach", FAS2_Detach)

local function FAS2_ToggleGunPimper(ply, com, args)
	if not ply:Alive() then
		return
	end
	
	wep = ply:GetActiveWeapon()
	
	if not IsValid(wep) or not wep.IsFAS2Weapon or wep.NoAttachmentMenu or wep.dt.Bipod then
		return
	end
	
	CT = CurTime()
	
	if CT < wep.ReloadWait then
		return
	end
	
	if wep.ReloadDelay and CT < wep.ReloadDelay then
		return
	end
	
	if wep.dt.Status != FAS_STAT_CUSTOMIZE then
		wep.dt.Status = FAS_STAT_CUSTOMIZE
	elseif wep.dt.Status == FAS_STAT_CUSTOMIZE then
		wep.dt.Status = FAS_STAT_IDLE
	end
end

concommand.Add("fas2_togglegunpimper", FAS2_ToggleGunPimper)