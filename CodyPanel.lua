-- initialize local varible for this script
local baseFrame = {}
local UpdateInterval = 0.5
local TimeSinceLastUpdate = 0
local starting_gold = 0
local starting_time = 0
local current_gold = 0

local function init_start_values()
  -- first time varible saves
  if (CodyPanelPrevNetGold == nil) then
    CodyPanelPrevNetGold = 0
  end
  if (CodyPanelPrevNetTime == nil) then
    CodyPanelPrevNetTime = 0
  end
  starting_gold = GetMoney()
  current_gold = GetMoney()
  starting_time = GetTime()
end

local function create_baseFrame()
  baseFrame=CreateFrame("Frame","CodyPanelFrame",UIParent,"BasicFrameTemplate")
  --make panel moveable
  baseFrame:EnableMouse(true)
  baseFrame:SetMovable(true)
  baseFrame:RegisterForDrag("LeftButton")
  baseFrame:SetScript("OnDragStart", baseFrame.StartMoving)
  baseFrame:SetScript("OnDragStop", baseFrame.StopMovingOrSizing)
  --set default size and position
  baseFrame:SetSize(250,210) -- width, height
  baseFrame:SetPoint("CENTER",UIParent,"CENTER") -- point, relativeFrame, relativePoint, xOffset, yOffset
  -- set title
  baseFrame.title = baseFrame:CreateFontString(nil,"OVERLAY")
  baseFrame.title:SetFontObject("GameFontHighlight")
  baseFrame.title:SetPoint("CENTER",baseFrame.TitleBg) -- ,"LEFT",5,0 last 3 make a margin between left and text
  baseFrame.title:SetText("Cody's panel")
  -- defaul to hiding my info pane. The below hide is before the event handle is added, so should not trigger below.
  baseFrame:Hide()
end

local function loadUserWindowPref()
  if CodyPanelShowBool == nil then
    CodyPanelShowBool=false
  end
  if CodyPanelShowBool then
    baseFrame:Show()
  end
end

local function save_session_vals()
  -- note, we are using current_gold here instead of GetMoney() because when this is called, the player's gold is gone and I need the last good value.
  CodyPanelPrevNetGold = (current_gold - starting_gold) + CodyPanelPrevNetGold
  CodyPanelPrevNetTime = (GetTime() - starting_time) + CodyPanelPrevNetTime
end

-- use /cody to open and close windows and it will update prefs
local function toggle_window()
  if baseFrame:IsVisible() then
    baseFrame:Hide()
  else
    baseFrame:Show()
    CodyPanelShowBool=true
  end
end

-- update user prefs if user manually closes with X
local function PanelHideEvent()
  CodyPanelShowBool=false
  --print("Hide event!")
end

local function toggle_sound()
  SetCVar("Sound_EnableAllSound",GetCVar("Sound_EnableAllSound")=="0" and 1 or 0)
end

local function reset_session()
  starting_gold = GetMoney()
  starting_time = GetTime()
  CodyPanelPrevNetGold = 0
  CodyPanelPrevNetTime = 0
end

local function add_info()
  -- line calculation is -(15*n+15) where n is the line number and the output is the y offset
  -- 1st line
  baseFrame.line1 = baseFrame:CreateFontString(nil,"OVERLAY")
  baseFrame.line1:SetFontObject("GameFontHighlight")
  baseFrame.line1:SetPoint("CENTER",baseFrame,"TOP",0,-30)
  baseFrame.line1:SetText("speed")
  -- 2nd line
  baseFrame.line2 = baseFrame:CreateFontString(nil,"OVERLAY")
  baseFrame.line2:SetFontObject("GameFontHighlight")
  baseFrame.line2:SetPoint("CENTER",baseFrame,"TOP",0,-45)
  baseFrame.line2:SetText("mount speed")
  -- 3rd line
  baseFrame.line3 = baseFrame:CreateFontString(nil,"OVERLAY")
  baseFrame.line3:SetFontObject("GameFontHighlight")
  baseFrame.line3:SetPoint("CENTER",baseFrame,"TOP",0,-60)
  baseFrame.line3:SetText("net gold")
  -- 4th line
  baseFrame.line4 = baseFrame:CreateFontString(nil,"OVERLAY")
  baseFrame.line4:SetFontObject("GameFontHighlight")
  baseFrame.line4:SetPoint("CENTER",baseFrame,"TOP",0,-75)
  baseFrame.line4:SetText("session time")
  -- 10th line
  baseFrame.line10 = baseFrame:CreateFontString(nil,"OVERLAY")
  baseFrame.line10:SetFontObject("GameFontHighlight")
  baseFrame.line10:SetPoint("CENTER",baseFrame,"TOP",0,-165)
  baseFrame.line10:SetText("wow uptime")
  -- 11th line
  baseFrame.line11 = baseFrame:CreateFontString(nil,"OVERLAY")
  baseFrame.line11:SetFontObject("GameFontHighlight")
  baseFrame.line11:SetPoint("CENTER",baseFrame,"TOP",0,-180)
  baseFrame.line11:SetText("fps")
  -- 12th line
  baseFrame.line12_1 = CreateFrame("Button",nil,baseFrame,"GameMenuButtonTemplate")
  baseFrame.line12_1:SetPoint("CENTER",baseFrame,"TOP",-50,-195)
  baseFrame.line12_1:SetText("Toggle Sound")
  baseFrame.line12_1:SetScript("OnClick",toggle_sound)
  baseFrame.line12_1:SetSize(100,15)
  baseFrame.line12_2 = CreateFrame("Button",nil,baseFrame,"GameMenuButtonTemplate")
  baseFrame.line12_2:SetPoint("CENTER",baseFrame,"TOP",50,-195)
  baseFrame.line12_2:SetText("Reset Session")
  baseFrame.line12_2:SetScript("OnClick",reset_session)
  baseFrame.line12_2:SetSize(100,15)
end

local function add_slash_cmds()
  -- add slash command to show and hide panel
  SLASH_CodyPanel_SLASHCMD1='/cody'
  SlashCmdList["CodyPanel_SLASHCMD"] = toggle_window -- Note that I did not include '()' because I need to pass a refernce to my function and not call it
end

local function make_gold_str(gold_int)
  local copper=abs(gold_int)%100
  local silver=(abs(gold_int)/100)%100
  local gold=(gold_int/100)/100
  if (gold >= 0) then
    return string.format("%ig %is %ic",gold,silver,copper)
  else
    return string.format("- %ig %is %ic",gold/-1,silver,copper)
  end
end

local function update_Info()
    --get values
    local speed = GetUnitSpeed("player")
    local percent_speed = speed/BASE_MOVEMENT_SPEED*100
    local mount_speed = percent_speed - 100
    current_gold = GetMoney()
    local net_gold = (GetMoney() - starting_gold) + CodyPanelPrevNetGold
    local net_time = (GetTime() - starting_time) + CodyPanelPrevNetTime
    local wow_uptime = GetSessionTime()
    local frame_rate = GetFramerate()
    --fix strings
    speed = string.format("%.2f", speed)
    percent_speed = string.format("%.2f", percent_speed)
    mount_speed = string.format("%.2f", mount_speed)
    net_gold = make_gold_str(net_gold)
    --net_gold = GetCoinText(net_gold) -- cannot handle negitive values and print full name for each unit
    net_time = SecondsToTime(net_time)
    wow_uptime = SecondsToTime(wow_uptime)
    frame_rate = string.format("%.2f", frame_rate)
    --update values
    -- line 1
    baseFrame.line1:SetText(speed.." y/s : "..percent_speed.."% speed")
    -- line 2
    if(IsMounted()) then
      baseFrame.line2:SetText("Mounted : "..mount_speed.."% mount speed")
    else
      baseFrame.line2:SetText("Not Mounted")
    end
    -- line 3
    baseFrame.line3:SetText("Session net gold: "..net_gold)
    -- line 4
    baseFrame.line4:SetText("Session time: "..net_time)
    -- line 10
    baseFrame.line10:SetText("WoW Uptime : "..wow_uptime)
    -- line 11
    baseFrame.line11:SetText(frame_rate.." fps")
end

-- update loop call on game refresh
local function OnUpdate(self, elapsed)
  TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
  if (TimeSinceLastUpdate > UpdateInterval) then
    update_Info()
    TimeSinceLastUpdate = 0
  end
end

-- general Event handle switch
local function OnEvent(self, event, ...)
  if event == "PLAYER_ENTERING_WORLD" then
    init_start_values()
  elseif event == "ADDON_LOADED" and ... == "CodyPanel"  then
    loadUserWindowPref()
  elseif event == "PLAYER_LOGOUT" then
    save_session_vals()
  end
end

local function setupScripts()
  -- register client events and point to event switch
  baseFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  baseFrame:RegisterEvent("ADDON_LOADED")
  baseFrame:RegisterEvent("PLAYER_LOGOUT")
  baseFrame:SetScript("OnEvent",OnEvent)
  -- hide event
  baseFrame:SetScript("OnHide",PanelHideEvent)
  -- register the update only after everything is setup
  -- this points to my OnUpdate function above. I named this the same but did not have to.
  baseFrame:SetScript("OnUpdate",OnUpdate)
end

--- execute order starting here ---
create_baseFrame()
add_slash_cmds()
add_info()
setupScripts()
