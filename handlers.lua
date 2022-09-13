local logoutTimer = nil

local function HandleBackFromAFK()
	if logoutTimer ~= nil and not logoutTimer:IsCancelled() then
		PPrint("Stopping logout timer alert")
		logoutTimer:Cancel()
	end
	if AlertReturn then
		WhisperMain("I am no longer AFK!")
	end
	StaticPopup_Hide ("AFK_ALERT")
end

local function HandleLogoutAlert()
	if logoutTimer ~= nil and not logoutTimer:IsCancelled() then
		logoutTimer:Cancel()
	end
	PPrint("Starting logout timer alert")
	logoutTimer = C_Timer.NewTimer(1200, function() 
		WhisperMain("I'll be logged out soon! (5-10 min)")
		FlashClientIcon()
	end)
end

local function HandleAFKAlert()
	WhisperMain("I'm afk! I will be logged out in 25-30 minutes!")
	FlashClientIcon()
end

function OnFlagChange(self, event, unitID)
	if unitID ~= "player" then
		return
	end

	if not UnitIsAFK("player") then
		HandleBackFromAFK()
		return
	end

	if AlertLogout then
		HandleLogoutAlert()
	end

	if AlertAFK then
		HandleAFKAlert()
	end
	StaticPopup_Show ("AFK_ALERT", date("%H:%M", time() + 1500) .. " - " .. date("%H:%M", time() + 1800))
end