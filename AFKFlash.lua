-------------------------------------------
-- Util -----------------------------------
-------------------------------------------

local function PPrint(msg)
	print("AFKFlash: " .. msg)
end

-------------------------------------------
-- Handlers -------------------------------
-------------------------------------------

local function OnFlagChange(...)
	if not Enabled then
		return
	end

	if not UnitIsAFK("player") then
		return
	end

	if MainAlertName ~= nil then 
		SendChatMessage("I'm afk!", "WHISPER", "Common", MainAlertName);
	end

	StaticPopup_Show ("NOTIFY")
	FlashClientIcon()
end

local function OnToggleCmd(...)
	if Enabled == true then
		Enabled = false
		SetCVar("autoClearAFK", "on")
		PPrint("Alerting disabled")
	else
		Enabled = true
		SetCVar("autoClearAFK", "off")
		PPrint("Alerting enabled")
	end
	ReloadUI()
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

StaticPopupDialogs["NOTIFY"] = {
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

if Enabled then
	SetCVar("autoClearAFK", "off")
end

PPrint("Creating frame")
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_FLAGS_CHANGED")
f:SetScript("OnEvent", OnFlagChange)

PPrint("Loaded!")