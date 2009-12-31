--[[
	Filter

	Author:		Fleetfoot
	Mail:		blomma@gmail.com

	Credits:	Rothar and rFilter2

	This is pretty much a recode of rFilter2, in the process i removed some of the options, like testmode and setting
	framestrata, anchor, fontSize. It also depends soley on omniCC to set timeleft on the icons.
	
	I've also optimized it heavily based on what i wanted it to do
--]]

Filter = CreateFrame("Frame")
Filter:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, ...) end end)
Filter:RegisterEvent("PLAYER_LOGIN")

local print = function(a) ChatFrame1:AddMessage("|cff33ff99Filter:|r "..tostring(a)) end

local playerName, _ = UnitName("player")
local _, playerClass = UnitClass("player")
local auras, cooldowns
local GetTime = GetTime

if playerName == "Fleetfoot" and playerClass == "HUNTER" then
	auras = {
		{ name = "Aspect of the Viper", size = 50, posx = -380, posy = -60 },
		{ name = "Aspect of the Dragonhawk", size = 50, posx = -380, posy = -60 },
		{ name = "Aspect of the Beast", size = 50, posx = -380, posy = -60 },
		{ name = "Aspect of the Cheetah", size = 50, posx = -380, posy = -60 },
		{ name = "Aspect of the Pack", size = 50, posx = -380, posy = -60 },
		{ name = "Aspect of the Wild", size = 50, posx = -380, posy = -60 },
		{ name = "Lock and Load", size = 45, posx = -180, posy = -158 },
	}
	cooldowns = {
		{ name = "Kill Command", size = 40, posx = -550, posy = -60 },
		{ name = "Call of the Wild", size = 40, posx = -550, posy = -110 },
		{ name = "Rapid Fire", size = 40, posx = -550, posy = -160 },
		{ name = "Feign Death", size = 40, posx = -550, posy = -210 },
		{ name = "Intimidation", size = 40, posx = -550, posy = -260 },
		{ name = "Explosive Shot", size = 35, posx = 160, posy = 60 },
		{ name = "Kill Shot", size = 35, posx = 160, posy = 15 },
		{ name = "Black Arrow", size = 35, posx = 160, posy = -30 },
	}
end

local aurasCount = #auras
local cooldownsCount = #cooldowns

local function onUpdate(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed < 0.1 then return end
	if GetTime() >= self.expire then
		self.visible = nil
		self:Hide()
	end
	self.elapsed = 0
end

local function CreateIcon(spellName, size, posX, posY, type )
	local button = CreateFrame("Frame", nil, UIParent)

	if type == "cooldown" then
		button:SetScript("OnUpdate", onUpdate)
	end

	button:SetWidth(size)
	button:SetHeight(size)
	button:SetPoint("CENTER", posX, posY)

	local cd = CreateFrame("Cooldown", nil, button)
	cd:SetAllPoints(button)
	cd:SetAlpha(0)
	cd:SetReverse()

	local _, _, texture, _, _, _, _, _, _ = GetSpellInfo(spellName)
	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetAllPoints(button)
	icon:SetTexture(texture)
	icon:SetTexCoord(.07, .93, .07, .93)


	local count = button:CreateFontString(nil, "OVERLAY")
	count:SetFontObject(NumberFontNormal)
	count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 0)

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetPoint("TOPLEFT", -2.2, 2.2)
	overlay:SetPoint("BOTTOMRIGHT", 2.5, -2.5)
	overlay:SetTexture("Interface\\AddOns\\Filter\\textures\\border")
	overlay:SetVertexColor(.31,.41,.53)
	overlay:SetBlendMode("BLEND")

	button.name = spellName
	button.cd = cd
	button.icon = icon
	button.count = count
	button.overlay = overlay
	button:Hide()

	return button
end

local function UpdateAura(name, unit, button)
	local _, _, _, count, _, duration, expirationTime, _, _ = UnitAura(unit, name)
	if duration then
		if duration > 0 then
			button.cd:SetCooldown(expirationTime - duration, duration)
			button.cd:Show()
		else
			button.cd:Hide()
		end

		button.count:SetText((count > 1 and count))

		button.visible = true
		button:Show()
	else
		button.visible = nil
		button:Hide()
	end
end

local function UpdateCooldown(name, button)
	local start, duration, enable = GetSpellCooldown(name)
	if button.visible and enable == 1 then return end

	if duration and duration > 1.5 then
		button.cd:SetCooldown(start, duration)
		button.expire = start + duration

		button.elapsed = 0
		button.visible = true
		button:Show()
	end
end

-- Event handling
function Filter:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")

	for i = 1, aurasCount do
		local value = auras[i]
		value.button = CreateIcon(value.name, value.size, value.posx, value.posy, "aura")
	end

	for i = 1, cooldownsCount do
		local value = cooldowns[i]
		value.button = CreateIcon(value.name, value.size, value.posx, value.posy, "cooldown")
	end

	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Filter:UNIT_AURA(unit)
	if unit ~= "player" then return end

	for i = 1, aurasCount do
		local value = auras[i]
		UpdateAura(value.name, unit, value.button)
	end
end

function Filter:SPELL_UPDATE_COOLDOWN()
	for i = 1, cooldownsCount do
		local value = cooldowns[i]
		UpdateCooldown(value.name, value.button)
	end
end

function Filter:PLAYER_ENTERING_WORLD()
	for i = 1, aurasCount do
		local value = auras[i]
		UpdateAura(value.name, "player", value.button)
	end

	for i = 1, cooldownsCount do
		local value = cooldowns[i]
		UpdateCooldown(value.name, value.button)
	end
end