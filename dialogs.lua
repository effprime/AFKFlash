StaticPopupDialogs["AFK_ALERT"] = {
	text = "AFK Alert! Estimated logout time: %s",
	button1 = "I'm back!",
	button2 = "Stay AFK",
	OnAccept = function()
		SendChatMessage("", "AFK", "Common", WhisperTarget);
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}