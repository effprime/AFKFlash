if AlertAFK == nil then
	AlertAFK = true
end

if AlertLogout == nil then
	AlertLogout = true
end

PPrint("Setting autoClearAFK CVar")
UpdateAutoClearAFKCVar()

PPrint("Creating frame")
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_FLAGS_CHANGED")
f:SetScript("OnEvent", OnFlagChange)

PPrint("Loaded!")