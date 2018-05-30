-- initialize local varible for this script
local BASE_FRAME = {}
local UPDATE_INTERVAL = 0.5
local TIME_SINCE_LAST_UPDATE = 0
local STARTING_GOLD = 0
local STARTING_TIME = 0
local CURRENT_GOLD = 0

local function init_start_values()
  -- first time varible saves
  if (CodyPanelPrevNetGold == nil) then
    CodyPanelPrevNetGold = 0
  end
  if (CodyPanelPrevNetTime == nil) then
    CodyPanelPrevNetTime = 0
  end
  CURRENT_GOLD = GetMoney()
  STARTING_GOLD = CURRENT_GOLD
  STARTING_TIME = GetTime()
end

local function create_baseFrame()
  BASE_FRAME=CreateFrame("Frame","CodyPanelFrame",UIParent,"BasicFrameTemplate")
  --make panel moveable
  BASE_FRAME:EnableMouse(true)
  BASE_FRAME:SetMovable(true)
  BASE_FRAME:RegisterForDrag("LeftButton")
  BASE_FRAME:SetScript("OnDragStart", BASE_FRAME.StartMoving)
  BASE_FRAME:SetScript("OnDragStop", BASE_FRAME.StopMovingOrSizing)
  --set default size and position
  BASE_FRAME:SetSize(250,210) -- width, height
  BASE_FRAME:SetPoint("CENTER",UIParent,"CENTER") -- point, relativeFrame, relativePoint, xOffset, yOffset
  -- set title
  BASE_FRAME.title = BASE_FRAME:CreateFontString(nil,"OVERLAY")
  BASE_FRAME.title:SetFontObject("GameFontHighlight")
  BASE_FRAME.title:SetPoint("CENTER",BASE_FRAME.TitleBg) -- ,"LEFT",5,0 last 3 make a margin between left and text
  BASE_FRAME.title:SetText("Cody's panel")
  -- defaul to hiding my info pane. The below hide is before the event handle is added, so should not trigger below.
  BASE_FRAME:Hide()
end

local function loadUserWindowPref()
  if CodyPanelShowBool == nil then
    CodyPanelShowBool=false
  end
  if CodyPanelShowBool then
    BASE_FRAME:Show()
  end
end

local function update_money_val()
  CURRENT_GOLD = GetMoney()
end

local function save_session_vals()
  -- note, we are using CURRENT_GOLD here instead of GetMoney() because when this is called, the player's gold is gone and I need the last good value.
  CodyPanelPrevNetGold = (CURRENT_GOLD - STARTING_GOLD) + CodyPanelPrevNetGold
  CodyPanelPrevNetTime = (GetTime() - STARTING_TIME) + CodyPanelPrevNetTime
end

-- use /cody to open and close windows and it will update prefs
local function toggle_window()
  if BASE_FRAME:IsVisible() then
    BASE_FRAME:Hide()
  else
    BASE_FRAME:Show()
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
  STARTING_GOLD = CURRENT_GOLD
  STARTING_TIME = GetTime()
  CodyPanelPrevNetGold = 0
  CodyPanelPrevNetTime = 0
end

local function add_info()
  -- line calculation is -(15*n+15) where n is the line number and the output is the y offset
  -- 1st line
  BASE_FRAME.line1 = BASE_FRAME:CreateFontString(nil,"OVERLAY")
  BASE_FRAME.line1:SetFontObject("GameFontHighlight")
  BASE_FRAME.line1:SetPoint("CENTER",BASE_FRAME,"TOP",0,-30)
  BASE_FRAME.line1:SetText("speed")
  -- 2nd line
  BASE_FRAME.line2 = BASE_FRAME:CreateFontString(nil,"OVERLAY")
  BASE_FRAME.line2:SetFontObject("GameFontHighlight")
  BASE_FRAME.line2:SetPoint("CENTER",BASE_FRAME,"TOP",0,-45)
  BASE_FRAME.line2:SetText("mount speed")
  -- 3rd line
  BASE_FRAME.line3 = BASE_FRAME:CreateFontString(nil,"OVERLAY")
  BASE_FRAME.line3:SetFontObject("GameFontHighlight")
  BASE_FRAME.line3:SetPoint("CENTER",BASE_FRAME,"TOP",0,-60)
  BASE_FRAME.line3:SetText("net gold")
  -- 4th line
  BASE_FRAME.line4 = BASE_FRAME:CreateFontString(nil,"OVERLAY")
  BASE_FRAME.line4:SetFontObject("GameFontHighlight")
  BASE_FRAME.line4:SetPoint("CENTER",BASE_FRAME,"TOP",0,-75)
  BASE_FRAME.line4:SetText("session time")
  -- 10th line
  BASE_FRAME.line10 = BASE_FRAME:CreateFontString(nil,"OVERLAY")
  BASE_FRAME.line10:SetFontObject("GameFontHighlight")
  BASE_FRAME.line10:SetPoint("CENTER",BASE_FRAME,"TOP",0,-165)
  BASE_FRAME.line10:SetText("wow uptime")
  -- 11th line
  BASE_FRAME.line11 = BASE_FRAME:CreateFontString(nil,"OVERLAY")
  BASE_FRAME.line11:SetFontObject("GameFontHighlight")
  BASE_FRAME.line11:SetPoint("CENTER",BASE_FRAME,"TOP",0,-180)
  BASE_FRAME.line11:SetText("fps")
  -- 12th line
  BASE_FRAME.line12_1 = CreateFrame("Button",nil,BASE_FRAME,"GameMenuButtonTemplate")
  BASE_FRAME.line12_1:SetPoint("CENTER",BASE_FRAME,"TOP",-50,-195)
  BASE_FRAME.line12_1:SetText("Toggle Sound")
  BASE_FRAME.line12_1:SetScript("OnClick",toggle_sound)
  BASE_FRAME.line12_1:SetSize(100,15)
  BASE_FRAME.line12_2 = CreateFrame("Button",nil,BASE_FRAME,"GameMenuButtonTemplate")
  BASE_FRAME.line12_2:SetPoint("CENTER",BASE_FRAME,"TOP",50,-195)
  BASE_FRAME.line12_2:SetText("Reset Session")
  BASE_FRAME.line12_2:SetScript("OnClick",reset_session)
  BASE_FRAME.line12_2:SetSize(100,15)
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
    local net_gold = (CURRENT_GOLD - STARTING_GOLD) + CodyPanelPrevNetGold
    local net_time = (GetTime() - STARTING_TIME) + CodyPanelPrevNetTime
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
    BASE_FRAME.line1:SetText(speed.." y/s : "..percent_speed.."% speed")
    -- line 2
    if(IsMounted()) then
      BASE_FRAME.line2:SetText("Mounted : "..mount_speed.."% mount speed")
    else
      BASE_FRAME.line2:SetText("Not Mounted")
    end
    -- line 3
    BASE_FRAME.line3:SetText("Session net gold: "..net_gold)
    -- line 4
    BASE_FRAME.line4:SetText("Session time: "..net_time)
    -- line 10
    BASE_FRAME.line10:SetText("WoW Uptime : "..wow_uptime)
    -- line 11
    BASE_FRAME.line11:SetText(frame_rate.." fps")
end

-- update loop call on game refresh
local function OnUpdate(self, elapsed)
  TIME_SINCE_LAST_UPDATE = TIME_SINCE_LAST_UPDATE + elapsed
  if (TIME_SINCE_LAST_UPDATE > UPDATE_INTERVAL) then
    update_Info()
    TIME_SINCE_LAST_UPDATE = 0
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
  elseif event == "PLAYER_MONEY" then
    update_money_val()
  end
end

local function setupScripts()
  -- register client events and point to event switch
  BASE_FRAME:RegisterEvent("PLAYER_ENTERING_WORLD")
  BASE_FRAME:RegisterEvent("ADDON_LOADED")
  BASE_FRAME:RegisterEvent("PLAYER_LOGOUT")
  BASE_FRAME:RegisterEvent("PLAYER_MONEY")
  BASE_FRAME:SetScript("OnEvent",OnEvent)
  -- hide event
  BASE_FRAME:SetScript("OnHide",PanelHideEvent)
  -- register the update only after everything is setup
  -- this points to my OnUpdate function above. I named this the same but did not have to.
  BASE_FRAME:SetScript("OnUpdate",OnUpdate)
end

--- execute order starting here ---
create_baseFrame()
add_slash_cmds()
add_info()
setupScripts()
