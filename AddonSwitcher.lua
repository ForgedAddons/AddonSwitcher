local _G = getfenv(0)
local event = CreateFrame("Frame")
event:RegisterEvent"ADDON_LOADED"
event:SetScript("OnEvent", function(self, event, addon)
	if addon ~= "AddonSwitcher" then return end
	if(not _G.asDB) then
		_G.asDB = {}
	end
end)

local function pr(text)
	print("|cffabd473AddonSwitcher|r: "..text)
end

local function profileSave(profile_name)
	local dba = {}
	for i = 1, GetNumAddOns(), 1 do
		local name, _, _, enabled = GetAddOnInfo(i)
		dba[name] = enabled and "1" or "0"
	end
	_G.asDB[profile_name] = dba
	pr("Profile '"..profile_name.."' saved.")
end

local function profileLoad(profile_name, do_reload)
	local dba = _G.asDB[profile_name]
	if dba ~= nil then
		for n, e in pairs(dba) do
			if e == "1" then
				EnableAddOn(n)
			elseif e == "0" then
				DisableAddOn(n)
			else
				pr("Unknown state "..e.." for addon "..n..", skipping.")
			end
		end
		if do_reload then
			ReloadUI()
		else
			pr("Profile '"..profile_name.."' loaded. Reload your UI (e.g. with '/reload') to apply...")
		end
	else
		pr("Unknown profile '"..profile_name.."'!")
	end
end

local function profileDelete(profile_name)
	local dba = _G.asDB[profile_name]
	if dba ~= nil then
		_G.asDB[profile_name] = nil
		pr("Profile '"..profile_name.."' deleted.")
	else
		pr("Unknown profile '"..profile_name.."'! Check existing profiles with '/as list'.")
	end
end

local function listProfiles()
	if next(_G.asDB) then
		local empty = true
		for proname, prdata in pairs(_G.asDB) do
			if empty then
				pr("Profiles:")
				empty = false
			end
			print("* "..proname)
		end
		if empty then pr("No profiles!") end
	else
		pr("No profiles!")
	end
end

SLASH_ADDONSWITCHER1 = "/addonswitcher"
SLASH_ADDONSWITCHER2 = "/as"
SlashCmdList["ADDONSWITCHER"] = function(msg)
	local command, profile = msg:match("^(%S*)%s*(.-)$")
	command = string.lower(command)
	if command == "save" then
		profileSave(profile or "default")
	elseif command == "load" or command == "switch" then
		profileLoad(profile or "default", command == "switch")
	elseif command == "list" then
		listProfiles()
	elseif command == "delete" then
		profileDelete(profile or "default")
	else
		pr("Drauer's Addon Switcher, available commands (you can use /as or /addonswitcher if you like):")
		print("/as switch <profile name> - Enable (and disable) AddOns from named profile AND RELOAD UI. The 'default' profile is taken if not specified.")
		print("/as load <profile name> - Enable (and disable) AddOns from named profile without reloading UI. The 'default' profile is taken if not specified.")
		print("/as save <profile name> - Save currently enabled and disbled AddOns as profile. The 'default' profile is taken if not specified.")
		print("/as delete <profile name> - Delete profile. The 'default' profile is taken if not specified.")
		print("/as list - Lists available profiles.")
		print("** WARNING ** Profile names are case-sensitive.")
	end
end
