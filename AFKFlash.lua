-------------------------------------------
-- Util -----------------------------------
-------------------------------------------

local function PPrint(msg)
	print("AFKFlash: " .. msg)
end

-------------------------------------------
-- Handlers -------------------------------
-------------------------------------------

local logoutTimer = nil

local function OnFollowUp()
	if MainAlertName ~= nil then 
		SendChatMessage("I'll be logged out in 5 minutes!", "WHISPER", "Common", MainAlertName)
	end
	FlashClientIcon()
end

local function OnFlagChange(...)
	if not UnitIsAFK("player") then
		if logoutTimer ~= nil and not logoutTimer:IsCancelled() then
			PPrint("Stopping logout timer alert")
			logoutTimer:Cancel()
		end
		return
	end

	if AlertLogout then
		logoutTimer = C_Timer.NewTimer(1500, OnFollowUp)
	end

	if AlertAFK then
		if MainAlertName ~= nil then 
			SendChatMessage("I'm afk!", "WHISPER", "Common", MainAlertName);
			PPrint("Starting logout timer alert")
		end

		StaticPopup_Show ("AFK_ALERT")
		FlashClientIcon()
	end
end

local function OnToggleAFKAlertCmd(...)
	local status = ""

	if AlertAFK == true then
		AlertAFK = false
		SetCVar("autoClearAFK", 1)
		status = "disabled"
	else
		AlertAFK = true
		SetCVar("autoClearAFK", 0)
		status = "enabled"
	end

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
	text = "AFK Alert!",
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

PPrint("Creating frame")
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_FLAGS_CHANGED")
f:SetScript("OnEvent", OnFlagChange)

PPrint("Loaded!")