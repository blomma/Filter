Filter = CreateFrame("Frame")
Filter:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, ...) end end)
Filter:RegisterEvent("PLAYER_LOGIN")

local print = function(a) ChatFrame1:AddMessage("|cff33ff99Filter:|r "..tostring(a)) end

local _G = getfenv(0)
local playerName, _ = UnitName("player")
local _, playerClass = UnitClass("player")
local spellList

if playerName == "Fleetfoot" and playerClass == "HUNTER" then
	spellList = {
		{ name = "Aspect of the Viper",  unit = "player", size = 50, posx = -380, posy = -60 },
		{ name = "Lock and Load", unit = "player", size = 50, posx = -300, posy = -60 },
	}
end

local CreateIcon = function(spellName, frameName, unit, size, posX, posY )
	local button = CreateFrame("Frame", frameName, UIParent)
	button:SetWidth(size)
	button:SetHeight(size)
	button:SetPoint("CENTER", posX, posY)
	
	local cd = CreateFrame("Cooldown", nil, button)
	cd:SetAllPoints(button)
	cd:SetAlpha(0)

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
end

local formatTimeLeft = function(time)
	if time >= 60 then
		return floor((time/60)+1).."m"
	elseif time <= 1.5 then
		return floor(time*10)/10
	else
		return floor(time+0.5)
	end
end

local UpdateAura = function(spellName, unit)
	local name, rank, texture, count, debuffType, duration, expirationTime, isMine, isStealable = UnitAura(unit, spellName)

	local button = _G["filter_"..spellName]
	if expirationTime then
		if(duration and duration > 0) then
			button.cd:SetCooldown(expirationTime - duration, duration)
			button.cd:Show()
		else
			button.cd:Hide()
		end

		button:Show()
		button.icon:SetTexture(texture)
		button.icon:SetTexCoord(.07, .93, .07, .93)
		button.count:SetText((count > 1 and count))
	else
		button:Hide()
	end
end

function Filter:PLAYER_LOGIN(delayed)
	self:UnregisterEvent("PLAYER_LOGIN")
	for _,value in ipairs(spellList) do
		CreateIcon(value.name, "filter_"..value.name, value.unit, value.size, value.posx, value.posy )
	end
	self:RegisterEvent("UNIT_AURA")
end

function Filter:UNIT_AURA(unit)
	if unit ~= "player" then return end

	for _,value in ipairs(spellList) do
		if value.unit == unit then
			UpdateAura(value.name, value.unit)
		end
	end
end