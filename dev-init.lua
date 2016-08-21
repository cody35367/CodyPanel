-- This makes addon dev easier. 
-- run /console scriptErrors 0 in game to turn on lua errors
 -- For quicker reloading
SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI
-- For quicker acces to frame stack
SLASH_FRAMESTK1 = "/fs"
SlashCmdList.FRAMESTK = function()
  LoadAddOn('Blizzard_DebugTools')
  FrameStackTooltip_Toggle()
end
-- to be able to user the left and right arrows in the edit box
-- without rotating your character!
for i = 1, NUM_CHAT_WINDOWS do
  _G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false)
end
