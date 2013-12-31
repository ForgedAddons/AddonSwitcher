-- is ampere here?
local findAmpere = function()
   local kids = { InterfaceOptionsFramePanelContainer:GetChildren() };
   for _, child in ipairs(kids) do
      if child.name == "Ampere" then return child end
   end
   return nil
end
local ampere_config_frame = findAmpere()
if ampere_config_frame == nil then return end

-- thanks Tekkub for this (ripped from Ampere itself hehe)
local MakeButton = function(parent)
	local butt = CreateFrame("Button", nil, parent)
	butt:SetWidth(60) butt:SetHeight(22)

	butt:SetHighlightFontObject(GameFontHighlightSmall)
	butt:SetNormalFontObject(GameFontNormalSmall)

	butt:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	butt:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	butt:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	butt:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
	butt:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetDisabledTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetHighlightTexture():SetBlendMode("ADD")

	return butt
end
	
-- load menu
local InvokeLoadMenu = function(addon, ...)
	local menu = { { text = "Load profile:", isTitle = true} }
	
	for profile, _ in pairs(_G.asDB) do
		table.insert(menu, { text = profile, func = function() SlashCmdList["ADDONSWITCHER"]("load "..profile) end })
	end
	
	local menuFrame = CreateFrame("Frame", "ExampleMenuFrame", UIParent, "UIDropDownMenuTemplate")
	EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU")
end

-- save as
local currentName
StaticPopupDialogs["AddonSwitcherPluginAmpereSaveAs"] = {
	text = "Enter new profile's name:",
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function(self)
		local text = self.editBox:GetText();
		SlashCmdList["ADDONSWITCHER"]("save "..text)
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetParent().editBox:GetText();
		SlashCmdList["ADDONSWITCHER"]("save "..text)
		self:GetParent():Hide();
	end,
	OnShow = function(self)
		self.editBox:SetText("");
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		self.editBox:SetText("");
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	maxLetters = 1024,
} 

local InvokeSaveMenu = function(addon, ...)
	local menu = {
		{ text = "Save as:", isTitle = true},
		{ text = "New profile...",func = function()
			currentName = "default"
			StaticPopup_Show("AddonSwitcherPluginAmpereSaveAs")
		end }
	}
	
	for profile, _ in pairs(_G.asDB) do
		table.insert(menu, { text = profile, func = function() SlashCmdList["ADDONSWITCHER"]("save "..profile) end })
	end
	
	local menuFrame = CreateFrame("Frame", "ExampleMenuFrame", UIParent, "UIDropDownMenuTemplate")
	EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU")
end

-- inject new buttons into Ampere! screen
local load = MakeButton(ampere_config_frame)
load:SetFrameStrata("HIGH")
load:SetPoint("BOTTOMLEFT", ampere_config_frame, "BOTTOMLEFT", 184, 16)
load:SetText("Load")
load:SetScript("OnClick", InvokeLoadMenu)

local save = MakeButton(ampere_config_frame)
save:SetFrameStrata("HIGH")
save:SetPoint("LEFT", load, "RIGHT", 4, 0)
save:SetText("Save")
save:SetScript("OnClick", InvokeSaveMenu)

-- small Bonus: open ampere with /amp or /ampere
SLASH_SHOWAMPERE1 = "/ampere"
SLASH_SHOWAMPERE2 = "/amp"
SlashCmdList["SHOWAMPERE"] = function()
	InterfaceOptionsFrame_OpenToCategory(ampere_config_frame)
end