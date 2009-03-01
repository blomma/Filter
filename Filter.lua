Filter = CreateFrame("Frame")
Filter:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, ...) end end)
Filter:RegisterEvent("PLAYER_LOGIN")

local print = function(a) ChatFrame1:AddMessage("|cff33ff99Filter:|r "..tostring(a)) end

local playerName, _ = UnitName("player")
local _, playerClass = UnitClass("player")
local spellList

if playerName == "Fleetfoot" and playerClass == "HUNTER" then
	spellList = {
		auras = {
			{ name = "Aspect of the Viper", unit = "player", size = 50, posx = -380, posy = -60 },
			{ name = "Lock and Load", unit = "player", size = 50, posx = -300, posy = -60 },
		},
		cooldowns = {
			{ name = "Kill Command", unit = "player", size = 50, posx = -500, posy = -60 },
			{ name = "Rapid Fire", unit = "player", size = 50, posx = -500, posy = -60 },
		},
	}
end

local onUpdate = function(self, elapsed)
	local duration = self.duration + elapsed
	if duration >= self.expire then
		self.duration = nil
		self:Hide()
	else
		self.duration = duration
	end
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
	
	button.overlay = overlay

	button.icon = icon
	button.count = count
	button.cd = cd
	button:Hide()
	
	return button
end

local UpdateAura = function(name, unit, button)
	local name, rank, texture, count, debuffType, duration, expirationTime, isMine, isStealable = UnitAura(unit, name)

	if expirationTime then
		if(duration and duration > 0) then
			button.cd:SetCooldown(expirationTime - duration, duration)
		else
			button.cd:Hide()
		end

		button.icon:SetTexture(texture)
		button.icon:SetTexCoord(.07, .93, .07, .93)
		button.count:SetText((count > 1 and count))

		button:Show()
	else
		button:Hide()
	end
end

local CheckCooldown = function(name, button)
	if button.duration then return end

	local start, duration, _ = GetSpellCooldown(name);
	if duration > 0 then
		local _, _, icon, _, _, _, _, _, _ = GetSpellInfo(name)
		button.cd:SetCooldown(start, duration)
		button.expire = duration + start
		button.duration = start
		button.icon:SetTexture(icon)
		button.icon:SetTexCoord(.07, .93, .07, .93)
		button:Show()
	end
end

function Filter:PLAYER_LOGIN(delayed)
	self:UnregisterEvent("PLAYER_LOGIN")
	for _,value in ipairs(spellList.auras) do
		value.button = CreateIcon(value.name, value.unit, value.size, value.posx, value.posy, "aura" )
	end
	for _,value in ipairs(spellList.cooldowns) do
		value.button = CreateIcon(value.name,  value.unit, value.size, value.posx, value.posy, "cooldown" )
	end
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
end

function Filter:UNIT_AURA(unit)
	if unit ~= "player" then return end

	for _,value in ipairs(spellList.auras) do
		if value.unit == unit then
			UpdateAura(value.name, value.unit, value.button)
		end
	end
end

function Filter:SPELL_UPDATE_COOLDOWN(arg1)
	for _,value in ipairs(spellList.cooldowns) do
		CheckCooldown(value.name, value.button)
	end
end