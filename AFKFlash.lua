-------------------------------------------
-- Util -----------------------------------
-------------------------------------------

local function PPrint(msg)
	print("AFKFlash: " .. msg)
end

local function initAutoClearAFKCVar()
	if AlertAFK == true then
		SetCVar("autoClearAFK", 0)
	else
		SetCVar("autoClearAFK", 1)
	end
end

-------------------------------------------
-- Handlers -------------------------------
-------------------------------------------

local logoutTimer = nil

local function OnFlagChange(...)
	if not UnitIsAFK("player") then
		if logoutTimer ~= nil and not logoutTimer:IsCancelled() then
			PPrint("Stopping logout timer alert")
			logoutTimer:Cancel()
			StaticPopup_Hide ("AFK_ALERT")
		end
		return
	end

	if AlertLogout then
		if logoutTimer ~= nil and not logoutTimer:IsCancelled() then
			logoutTimer:Cancel()
		end
		logoutTimer = C_Timer.NewTimer(1200, function() 
			if MainAlertName ~= nil then 
				SendChatMessage("I'll be logged out soon! (5-10 min)", "WHISPER", "Common", MainAlertName)
			end
			FlashClientIcon()
		end)
	end

	if AlertAFK then
		if MainAlertName ~= nil then 
			SendChatMessage("I'm afk!", "WHISPER", "Common", MainAlertName);
			PPrint("Starting logout timer alert")
		end
		FlashClientIcon()
	end
	StaticPopup_Show ("AFK_ALERT", date("%H:%M", time() + 1500) .. " - " .. date("%H:%M", time() + 1800))
end

local function OnToggleAFKAlertCmd(...)
	local status = ""

	if AlertAFK == true then
		AlertAFK = false
		status = "disabled"
	else
		AlertAFK = true
		status = "enabled"
	end

	initAutoClearAFKCVar()

	PPrint("AFK alerting " .. status)
end

local function OnToggleLogoutAlertCmd(...)
	local status = ""

	if AlertLogout == true then
		AlertLogout = false
		status = "disabled"
	else
		AlertLogout = true
		status = "enabled"
	end

	PPrint("Logout alerting " .. status)
end

local function OnSetWhisperTargetCmd(msg)
	MainAlertName = msg
	PPrint("Whisper target set to: " .. MainAlertName)
end

local function OnGetWhisperTargetCmd(msg)
	if MainAlertName == nil or MainAlertName == "" then
		PPrint("There is no whisper target currently set")
		return
	end
	PPrint("Current whisper target: " .. MainAlertName)
end

local function OnStatusCmd(...)
	PPrint("Current config state:")
	print("- AFK Alerts: " .. tostring(AlertAFK))
	print("- Logout Alerts: " .. tostring(AlertLogout))
	print("- Whisper target: " .. tostring(MainAlertName))
end

-------------------------------------------
-- Slash commands -------------------------
-------------------------------------------

Command = {callback = nil, description = nil}
function Command:new(callback, description)
	return {
		callback = callback,
		description = description
	}
end

local cmdTable = {
	["toggle-afk-alert"] = Command:new(OnToggleAFKAlertCmd, "Toggles AFK alerting"),
	["toggle-logout-alert"] = Command:new(OnToggleLogoutAlertCmd, "Toggles logout alerting"),
	["set-whisper-target"] = Command:new(OnSetWhisperTargetCmd, "Sets the whisper target for when you go AFK (set to empty to disable)"),
	["get-whisper-target"] = Command:new(OnGetWhisperTargetCmd, "Displays the current whisper target"),
	["status"] = Command:new(OnStatusCmd, "Gets the current config status")
}

local function printCommands()
	PPrint("Commands:")
	for k, v in pairs(cmdTable) do
		print("- " .. k .. ": " .. v["description"])
	end
end

SLASH_ENTRYPOINT1 = "/afkflash"
SlashCmdList.ENTRYPOINT = function(msg, ...)
	local cmd, msg = strsplit(" ", msg, 2)

	if cmd == nil or cmd == "" then
		printCommands()
		return
	end

	fn = cmdTable[cmd]
	if fn == nil then
		PPrint("Unknown command: " .. cmd)
		return
	end
	fn.callback(msg)
end

-------------------------------------------

StaticPopupDialogs["AFK_ALERT"] = {
	text = "AFK Alert! Estimated logout time: %s",
	button1 = "I'm back!",
	button2 = "Stay AFK",
	OnAccept = function()
		SendChatMessage("", "AFK", "Common", MainAlertName);
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

if AlertAFK == nil then
	AlertAFK = true
end

if AlertLogout == nil then
	AlertLogout = true
end

PPrint("Setting autoClearAFK CVar")
initAutoClearAFKCVar()

PPrint("Creating frame")
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_FLAGS_CHANGED")
f:SetScript("OnEvent", OnFlagChange)

PPrint("Loaded!")