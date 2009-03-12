--[[

	Filter

	Author:		Fleetfoot
	Mail:		blomma@gmail.com

	Credits:	Rothar and rFilter2

	This is pretty much a recode of rFilter2, in the process i removed some of the options, like testmode and setting
	framestrata, anchor, fontSize. It also depends soley on omniCC to set timeleft on the icons.
--]]

Filter = CreateFrame("Frame")
Filter:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, ...) end end)
Filter:RegisterEvent("PLAYER_LOGIN")

local print = function(a) ChatFrame1:AddMessage("|cff33ff99Filter:|r "..tostring(a)) end

local playerName, _ = UnitName("player")
local _, playerClass = UnitClass("player")
local spellList
local GetTime = GetTime

if playerName == "Fleetfoot" and playerClass == "HUNTER" then
	spellList = {
		auras = {
			{ name = "Aspect of the Viper", unit = "player", size = 50, posx = -380, posy = -60 },
			{ name = "Lock and Load", unit = "player", size = 45, posx = -180, posy = -158 },
		},
		cooldowns = {
			{ name = "Kill Command", unit = "player", size = 40, posx = -550, posy = -60 },
			{ name = "Call of the Wild", unit = "player", size = 40, posx = -550, posy = -110 },
			{ name = "Rapid Fire", unit = "player", size = 40, posx = -550, posy = -160 },
		},
	}
end

local aurasCount = #spellList.auras
local cooldownsCount = #spellList.cooldowns

local totalelapsed = 0
local onUpdate = function(self, elapsed)
	totalelapsed = totalelapsed + elapsed
	if totalelapsed < 1 then return end
	if GetTime() >= self.expire then
		self.visible = nil
		self:Hide()
	end
	totalelapsed = 0
end

local CreateIcon = function(spellName, unit, size, posX, posY, type )
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

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetAllPoints(button)
	
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

local UpdateAura = function(name, unit, button)
	local name, rank, texture, count, debuffType, duration, expirationTime, isMine, isStealable = UnitAura(unit, name)

	if duration then
		if(duration > 0) then
			button.cd:SetCooldown(expirationTime - duration, duration)
			button.cd:Show()
		else
			button.cd:Hide()
		end

		button.icon:SetTexture(texture)
		button.icon:SetTexCoord(.07, .93, .07, .93)
		button.count:SetText((count > 1 and count))

		button.visible = true
		button:Show()
	else
		button.visible = nil
		button:Hide()
	end
end

local UpdateCooldown = function(name, button)
	local start, duration, enable = GetSpellCooldown(name)
	
	if enable == 1 then return end
	if duration and duration > 1.5 then
		local _, _, icon, _, _, _, _, _, _ = GetSpellInfo(name)
		button.cd:SetCooldown(start, duration)
		button.expire = start + duration
		button.icon:SetTexture(icon)
		button.icon:SetTexCoord(.07, .93, .07, .93)

		button.visible = true
		button:Show()
	end
end

function Filter:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")
	for i=1, aurasCount do
		local value = spellList.auras[i]
	--for _,value in ipairs(spellList.auras) do
		value.button = CreateIcon(value.name, value.unit, value.size, value.posx, value.posy, "aura" )
	end
	for i=1, cooldownsCount do
		local value = spellList.cooldowns[i]
	--for _,value in ipairs(spellList.cooldowns) do
		value.button = CreateIcon(value.name,  value.unit, value.size, value.posx, value.posy, "cooldown" )
	end
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Filter:UNIT_AURA(unit)
	if unit ~= "player" then return end

	for i=1, aurasCount do
		local value = spellList.auras[i]
	--for _,value in ipairs(spellList.auras) do
		if value.unit == unit then
			UpdateAura(value.name, value.unit, value.button)
		end
	end
end

function Filter:SPELL_UPDATE_COOLDOWN()
	for i=1, cooldownsCount do
		local value = spellList.cooldowns[i]
	--for _,value in ipairs(spellList.cooldowns) do
		UpdateCooldown(value.name, value.button)
	end
end

function Filter:PLAYER_ENTERING_WORLD()
	for i=1, aurasCount do
		local value = spellList.auras[i]
	--for _,value in ipairs(spellList.auras) do
		UpdateAura(value.name, value.unit, value.button)
	end

	for i=1, cooldownsCount do
		local value = spellList.cooldowns[i]
	--for _,value in ipairs(spellList.cooldowns) do
		UpdateCooldown(value.name, value.button)
	end
end