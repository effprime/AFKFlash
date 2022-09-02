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

local function OnFlagChange(...)
	if not Enabled then
		return
	end

	if not UnitIsAFK("player") then
		if logoutTimer ~= nil and not logoutTimer:IsCancelled() then
			PPrint("Stopping logout timer alert")
			logoutTimer:Cancel()
		end
		return
	end

	if MainAlertName ~= nil then 
		SendChatMessage("I'm afk!", "WHISPER", "Common", MainAlertName);
		PPrint("Starting logout timer alert")
		logoutTimer = C_Timer.NewTimer(1500, function() SendChatMessage("I'll be logged out in 5 minutes!", "WHISPER", "Common", MainAlertName); FlashClientIcon() end)
	end

	StaticPopup_Show ("AFK_ALERT")
	FlashClientIcon()
end

local function OnToggleCmd(...)
	local status = ""

	if Enabled == true then
		Enabled = false
		SetCVar("autoClearAFK", 1)
		status = "disabled"
	else
		Enabled = true
		SetCVar("autoClearAFK", 0)
		status = "enabled"
	end

	PPrint("Alerting " .. status)
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
	["toggle"] = Command:new(OnToggleCmd, "Toggles alerting"),
	["set-whisper-target"] = Command:new(OnSetWhisperTargetCmd, "Sets the whisper target for when you go AFK (set to empty to disable)"),
	["get-whisper-target"] = Command:new(OnGetWhisperTargetCmd, "Displays the current whisper target")
}

local function printCommands()
	for k, v in pairs(cmdTable) do
		print(k .. ": " .. v["description"])
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

if Enabled == nil then
	Enabled = true
end

PPrint("Creating frame")
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_FLAGS_CHANGED")
f:SetScript("OnEvent", OnFlagChange)

PPrint("Loaded!")