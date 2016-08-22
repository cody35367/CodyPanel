-- initialize local varible for this script
local baseFrame = {}
local UpdateInterval = 0.5
local TimeSinceLastUpdate = 0
local starting_gold = 0
local starting_time = 0

local function init_start_values()
  starting_gold = GetMoney()
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
  baseFrame.line12 = CreateFrame("Button",nil,baseFrame,"GameMenuButtonTemplate")
  baseFrame.line12:SetPoint("CENTER",baseFrame,"TOP",0,-195)
  baseFrame.line12:SetText("Toggle sound")
  baseFrame.line12:SetScript("OnClick",toggle_sound)
  baseFrame.line12:SetSize(100,15)
end

local function add_slash_cmds()
  -- add slash command to show and hide panel
  SLASH_CodyPanel_SLASHCMD1='/cody'
  SlashCmdList["CodyPanel_SLASHCMD"] = toggle_window -- Note that I did not include '()' because I need to pass a refernce to my function and not call it
end

local function update_Info()
    --get values
    local speed = GetUnitSpeed("player")
    local percent_speed = speed/BASE_MOVEMENT_SPEED*100
    local mount_speed = percent_speed - 100
    local net_gold =  GetMoney() - starting_gold
    local net_time = GetTime() - starting_time
    local wow_uptime = GetSessionTime()
    local frame_rate = GetFramerate()
    --fix strings
    speed = string.format("%.2f", speed)
    percent_speed = string.format("%.2f", percent_speed)
    mount_speed = string.format("%.2f", mount_speed)
    net_gold = string.format("%dg %ds %dc",net_gold / 100 / 100, (net_gold / 100) % 100, net_gold % 100)
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
  end
end

local function setupScripts()
  -- register client events and point to event switch
  baseFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  baseFrame:RegisterEvent("ADDON_LOADED")
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
