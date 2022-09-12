function PPrint(msg)
	print(WrapTextInColorCode("[AFKFlash] ", "ff00ff00") .. msg)
end

function WhisperMain(msg)
	if WhisperTarget == nil then
		return
	end
	SendChatMessage("(AFKFlash) " .. msg, "WHISPER", "Common", WhisperTarget)
end

function UpdateAutoClearAFKCVar()
	-- whispers sent when AFK remove the AFK flag,
	-- so autoClearAFK must be disabled whenever there is a whisper target
	if WhisperTarget ~= nil then
		SetCVar("autoClearAFK", 0)
	else
		SetCVar("autoClearAFK", 1)
	end
end