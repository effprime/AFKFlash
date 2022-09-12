function OnToggleAFKAlertCmd(...)
	local status = ""

	if AlertAFK == true then
		AlertAFK = false
		status = "disabled"
	else
		AlertAFK = true
		status = "enabled"
	end

	UpdateAutoClearAFKCVar()

	PPrint("AFK alerting " .. status)
end

function OnToggleLogoutAlertCmd(...)
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

function OnSetWhisperTargetCmd(msg)
	WhisperTarget = msg
	UpdateAutoClearAFKCVar()
	PPrint("Whisper target set to: " .. WhisperTarget)
end

function OnGetWhisperTargetCmd(msg)
	if WhisperTarget == nil or WhisperTarget == "" then
		PPrint("There is no whisper target currently set")
		return
	end
	PPrint("Current whisper target: " .. WhisperTarget)
end

function OnStatusCmd(...)
	PPrint("Current config state:")
	print("- AFK Alerts: " .. tostring(AlertAFK))
	print("- Logout Alerts: " .. tostring(AlertLogout))
	print("- Whisper target: " .. tostring(WhisperTarget))
end

Command = {callback = nil, description = nil, usage = nil}
function Command:new(callback, description, usage)
	return {
		callback = callback,
		description = description,
		usage = usage
	}
end

local cmdTable = {
	["toggle-afk-alert"] = Command:new(OnToggleAFKAlertCmd, "Toggles AFK alerting", nil),
	["toggle-logout-alert"] = Command:new(OnToggleLogoutAlertCmd, "Toggles logout alerting", nil),
	["set-whisper-target"] = Command:new(OnSetWhisperTargetCmd, "Sets the whisper target for when you go AFK (set to empty to disable)", "<character-name>"),
	["get-whisper-target"] = Command:new(OnGetWhisperTargetCmd, "Displays the current whisper target", nil),
	["status"] = Command:new(OnStatusCmd, "Gets the current config status", nil)
}
local order = {
	"toggle-afk-alert",
	"toggle-logout-alert",
	"set-whisper-target",
	"get-whisper-target",
	"status"
}

local function printCommands()
	PPrint("Commands")
	for _, k in ipairs(order) do
		v = cmdTable[k]
		if v ~= nil then
			local usage = ""
			if v.usage == nil then
				usage = ""
			else
				usage = " " .. v.usage
			end
			print(string.format(
				"- %s: %s", WrapTextInColorCode(string.format("/afkflash %s%s", k, usage), "ff00ff00"), v.description
			))
		end
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