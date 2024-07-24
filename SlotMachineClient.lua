local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

-- frame:SetColorTexture unavailable
local function SetColorTexture(texture, red, green, blue, alpha)
    texture.Green = green; texture.Red = red; texture.Blue = blue; texture.Alpha = alpha
end

local ADDON_NAME = "AIOSlotMachine"

local SlotMachine = {}
local SM = SlotMachine
local SlotMachineHandlers = {}
AIO.AddHandlers(ADDON_NAME, SlotMachineHandlers)
local SMHandlers = SlotMachineHandlers

SM.Wheels  = { -- Physical Wheels that are visible to the player
    [1] = { -- virtual: 1C 16, 2C 13, 3C 6, BG 1, XC 36
    "1C", "2C", "3C"
        -- "1C", "2C", "3C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        -- "1C", "1C", "1C", "1C", "1C", "1C",
        -- "2C", "2C", "1C", "2C", "2C", "2C", "2C", "2C", "2C", "2C",
        -- "2C", "2C", "2C",
        -- "3C", "3C", "1C", "3C", "3C", "3C",
        -- "BG", "BG",
    },
    [2] = { -- virtual: 1C 18, 2C 7, 3C 4, BG 1, XC 42
        "3C", "1C", "2C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "2C", "2C", "1C", "2C", "2C", "2C", "2C",
        "1C", "3C", "3C", "3C",
        "BG", "BG",
    },
    [3] = { -- virtual: 1C 20, 2C 4, 3C 3, BG 1, XC 44
        "1C", "BG", "2C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "2C", "2C", "1C", "2C",
        "3C", "3C", "3C",
        "BG", "1C",
    },
}

-- baseframe: create
-- FrameTest = CreateFrame("Frame", "FrameTest", UIParent, "UIPanelDialogTemplate")
-- local frame = CreateFrame("Frame", "SlotMachineFrame", UIParent, "BasicFrameTemplateWithInset")
local frame = CreateFrame("Frame", "SlotMachineFrame", UIParent)
frame:SetSize(500, 400)
frame:SetPoint("CENTER")
frame:SetToplevel(true)
frame:SetClampedToScreen(true)

-- baseframe: Enable dragging
frame:RegisterForDrag("LeftButton")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnHide", frame.StopMovingOrSizing)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- baseframe: Title
frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontNormalMed3")
frame.title:SetPoint("TOP", 0, -10)
frame.title:SetText("Slot Machine")

-- baseframe: Close button
frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
frame.closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
frame.closeButton:SetScript("OnClick", function(self)
    frame:Hide()
end)

-- baseframe: Border
frame:SetBackdrop({
    bgFile = "Interface/GLUES/MODELS/UI_MAINMENU/AeriePeak01",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Gold-Border",  -- Path to the golden border texture
    tile = false,
    tileSize = 0,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropBorderColor(1, 0.84, 0, 1)  -- RGBA for golden color

-- Payout blinking lights
SM.Lights = {}
for i = 1, 5 do
    local light = frame:CreateTexture(nil, "OVERLAY")
    light:SetTexture("Interface/Buttons/WHITE8X8")
    light:SetSize(20, 20)
    light:SetPoint("LEFT", frame, "LEFT", 10, (i - 2) * 30 + 00)
    SetColorTexture(light, 1, 1, 0, 1)
    SM.Lights[i] = light
end

for i = 1, 5 do
    local light = frame:CreateTexture(nil, "OVERLAY", frame)
    light:SetTexture("Interface/Buttons/WHITE8X8")
    light:SetSize(20, 20)
    light:SetPoint("RIGHT", frame, "RIGHT", -10, (i - 2) * 30 + 00)
    SetColorTexture(light, 1, 1, 0, 1)  -- Corrected method call
    light:SetAlpha(1)  -- Ensure the initial state
    SM.Lights[#SM.Lights + 1] = light
end

-- Blink function for payout lights
local function BlinkLights()
    print("Blink")
    for _, light in pairs(SM.Lights) do
        local alpha = light:GetAlpha()
        if alpha == 1 then
            light:SetAlpha(0)
        else
            light:SetAlpha(1)
        end
    end
end

-- Timer using OnUpdate
local elapsed = 0
local wheel = 1
local count = 0
frame:SetScript("OnUpdate", function(self, dt)
    elapsed = elapsed + dt
    if elapsed >= 1000000  then
        elapsed = 0
        count = count + 1
        if count >= 30 then
            wheel = (wheel + 1) % 3 + 1
        end
        Step(wheel)
        UpdateSlotTextures()
    end
end)

-- Slots
SM.SlotTextures = {
    ["BG"] = "Interface/ICONS/inv_sword_39", -- thunderfury
    ["3C"] = "Interface/ICONS/inv_sword_61", -- gressil
    ["2C"] = "Interface/ICONS/inv_sword_49", -- maladath
    ["1C"] = "Interface/ICONS/inv_sword_43", -- dal'rend
    ["XC"] = "Interface/Buttons/WHITE8X8" -- blank
}
SM.Slots = {}
-- slotFrames: init
for i = 1, 3 do
    local slotFrame = CreateFrame("Frame", nil, frame)

    slotFrame:SetPoint("CENTER", frame, "CENTER", (i - 2) * 120, 40)
    slotFrame:SetSize(80, 240)

    -- slotFrame: Border
    slotFrame:SetBackdrop({
        bgFile = nil,
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Gold-Border",  -- Path to the golden border texture
        tile = false,
        tileSize = 0,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    slotFrame:SetBackdropBorderColor(1, 0.84, 0, 1)  -- RGBA for golden color

    SM.Slots[i] = slotFrame

--   Create a mask for clipping
    local mask = CreateFrame("Frame", nil, slotFrame)
    mask:SetSize(80, 240)
    mask:SetPoint("CENTER")
    mask:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    mask:SetBackdropColor(0, 0, 0, 0.8)
 -- Create a mask texture
end

local function GetTextureForPosition(i, n)
    -- assume positions are valid
    assert(1 <= n and n <= #SM.Wheels[n])
    print("GetTextureForPosition")
    print(n)
    print(SM.Wheels[i][n])
    return SM.SlotTextures[SM.Wheels[i][n]]
end

SM.WheelPosition = {
    [1] = 1,
    [2] = 1,
    [3] = 1,
}

local function GetNextPosition(i, n)
    local position = n + 1
    if position > #SM.Wheels[i] then
        position = 1
    end
    return position
end

local function GetPreviousPosition(i, n)
    local position = n - 1
    if position < 1 then
        position = #SM.Wheels[i]
    end
    return position
end

local function GetPosition(i, n)
    local position = SM.WheelPosition[i]
    if n == nil or n == 0 then
        print("GetCurrent")
        print(position)
        return position
    end
    if n > 0 then
        for _ = 1,n do
            print("GetNext")
            position = GetNextPosition(i, position)
            print(position)
        end
    else
        for _ = 1,(n*-1) do
            print("GetPrevious")
            position = GetPreviousPosition(i, position)
            print(position)
        end
    end
    return position
end

function Step(i, n)
    if n == nil then
        n = 1
    end
    local position = SM.WheelPosition[i]
    for _ = 1,n do
        position = GetNextPosition(i, SM.WheelPosition[i])
    end
    SM.WheelPosition[i] = position
end

-- baseFrame: Payline
local payLine = frame:CreateTexture(nil, "OVERLAY", frame)
payLine:SetTexture("Interface/MailFrame/UI-MailFrame-InvoiceLine")
payLine:SetPoint("CENTER", frame, "CENTER", 0, 40)
payLine:SetSize(400, 20)

SM.SlotFaces = {
    [1] = {},
    [2] = {},
    [3] = {},
}

local function InitSlotTextures()
    for i = 1, 1 do
        local slotFrame = SM.Slots[i]
        for j = 1, 3 do
            local offset = 0
            local icon = slotFrame:CreateTexture(nil, "ARTWORK", slotFrame)
            local wheelPosition = GetPosition(i, j-2)
            local texture = GetTextureForPosition(i, wheelPosition)
            icon:SetTexture(texture)
            -- icon:SetPoint("CENTER", slotFrame, "TOP", 0, -(j - 1) * (60+25) - 35 + offset)
            icon:SetPoint("CENTER", slotFrame, "TOP", 0, -(3-j) * (60+25) - 35 + offset)
            icon:SetSize(60, 60)
            icon:SetDrawLayer("ARTWORK", 0)
            SM.SlotFaces[i][j] = icon
        end
    end
end
InitSlotTextures()

function UpdateSlotTextures()
    for i = 1, 1 do
        local slotFaces = SM.SlotFaces[i]
        for j = 1, 3 do
            local wheelPosition = GetPosition(i, j-2)
            local texture = GetTextureForPosition(i, wheelPosition)
            local icon = slotFaces[j]
            icon:SetTexture(texture)
        end
    end
end

UpdateSlotTextures()

-- This enables saving of the position of the frame over reload of the UI or restarting game
AIO.SavePosition(frame)

-- Balance
frame.balanceText = frame:CreateFontString(nil, "OVERLAY")
frame.balanceText:SetFontObject("GameFontNormal")
frame.balanceText:SetPoint("TOPLEFT", 10, -10)
frame.balanceText:SetText("Balance: 1000")

-- Spin button
local spinButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
spinButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 60)
spinButton:SetSize(100, 50)
spinButton:SetText("Play")
spinButton:SetNormalFontObject("GameFontNormalLarge")
spinButton:SetHighlightFontObject("GameFontHighlightLarge")

-- Auto Spin button
local autoSpinButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
autoSpinButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
autoSpinButton:SetSize(100, 50)
autoSpinButton:SetText("Auto Spin")
autoSpinButton:SetNormalFontObject("GameFontNormalLarge")
autoSpinButton:SetHighlightFontObject("GameFontHighlightLarge")

----------------------------------------------------------------
-- Start bet
----------------------------------------------------------------
local betIncrement = CreateFrame("Button", nil, frame)
betIncrement:SetNormalTexture("Interface/ChatFrame/UI-ChatIcon-ScrollUp-Up")
betIncrement:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
betIncrement:SetPushedTexture("Interface/ChatFrame/UI-ChatIcon-ScrollUp-Down")
betIncrement:SetDisabledTexture("Interface/ChatFrame/UI-ChatIcon-ScrollUp-Disabled")
betIncrement:SetPoint("BOTTOM", frame, "BOTTOM", -85, 20)
betIncrement:SetSize(25, 25)

local betBox = CreateFrame("EditBox", "BidBox", frame, "InputBoxTemplate")
betBox:SetAutoFocus(false)
betBox:SetNumeric(true)
betBox:SetMaxLetters(7)
betBox:SetTextInsets(0, 13, 0, 0)
betBox:SetJustifyH("CENTER")
betBox:SetPoint("RIGHT", betIncrement, "LEFT", 2, 0)
betBox:SetSize(75, 25)

local betMinBox = CreateFrame("EditBox", "BidBox", frame, "InputBoxTemplate")
betMinBox:SetAutoFocus(false)
betMinBox:SetNumeric(true)
betMinBox:SetMaxLetters(7)
betMinBox:SetTextInsets(0, 13, 0, 0)
betMinBox:SetJustifyH("CENTER")
betMinBox:SetPoint("RIGHT", deleteButton, "LEFT", 2, 0)
betMinBox:SetSize(75, 25)

local betMin = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
betMin:SetText("Min")
betMin:SetNormalFontObject("GameFontNormalSmall")
betMin:SetHighlightFontObject("GameFontNormalSmall")
betMin:SetPoint("RIGHT", betBox, "LEFT", -5, 0)
betMin:SetPushedTextOffset(0, 0)
betMin:SetSize(32, 20)

local enterBidText = betBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
enterBidText:SetPoint("BOTTOMLEFT", betBox, "TOPLEFT", -2, -3)
enterBidText:SetJustifyH("LEFT")
enterBidText:SetHeight(14)

local enterMinBidText = betMinBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
enterMinBidText:SetPoint("BOTTOMLEFT", betMinBox, "TOPLEFT", -2, -3)
enterMinBidText:SetJustifyH("LEFT")
enterMinBidText:SetHeight(14)

local betBoxGold = betBox:CreateTexture(nil, "OVERLAY")
betBoxGold:SetTexture("Interface/MoneyFrame/UI-GoldIcon")
betBoxGold:SetPoint("RIGHT", -6, 0)
betBoxGold:SetSize(13, 13)

local betText = frame:CreateFontString(nil, "OVERLAY")
betText:SetFontObject("GameFontNormal")
betText:SetPoint("BOTTOM", frame, "BOTTOM", -140, 50)
betText:SetText("Bet")
----------------------------------------------------------------
-- End bet
----------------------------------------------------------------

-- Start min
local spinsPlus = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
spinsPlus:SetPoint("BOTTOM", frame, "BOTTOM", 180, 20)
spinsPlus:SetText("+")
spinsPlus:SetHighlightFontObject("GameFontNormalSmall")
spinsPlus:SetSize(25, 25)

local spinsBox = CreateFrame("EditBox", "SpinBox", frame, "InputBoxTemplate")
spinsBox:SetAutoFocus(false)
spinsBox:SetNumeric(true)
spinsBox:SetMaxLetters(3)
spinsBox:SetTextInsets(0, 13, 0, 0)
spinsBox:SetJustifyH("CENTER")
spinsBox:SetPoint("RIGHT", spinsPlus, "LEFT", 2, 0)
spinsBox:SetSize(50, 25)

local spinsMinBox = CreateFrame("EditBox", "SpinsBox", frame, "InputBoxTemplate")
spinsMinBox:SetAutoFocus(false)
spinsMinBox:SetNumeric(true)
spinsMinBox:SetMaxLetters(7)
spinsMinBox:SetTextInsets(0, 13, 0, 0)
spinsMinBox:SetJustifyH("CENTER")
spinsMinBox:SetPoint("RIGHT", deleteButton, "LEFT", 2, 0)
spinsMinBox:SetSize(75, 25)

local spinsMin = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
spinsMin:SetPoint("RIGHT", spinsBox, "LEFT", -5, 0)
spinsMin:SetText("-")
spinsMin:SetHighlightFontObject("GameFontNormalSmall")
spinsMin:SetSize(25, 25)

local enterSpinsText = spinsBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
enterSpinsText:SetPoint("BOTTOMLEFT", spinsBox, "TOPLEFT", -2, -3)
enterSpinsText:SetJustifyH("LEFT")
enterSpinsText:SetHeight(14)

local enterMinSpinsText = spinsMinBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
enterMinSpinsText:SetPoint("BOTTOMLEFT", spinsMinBox, "TOPLEFT", -2, -3)
enterMinSpinsText:SetJustifyH("LEFT")
enterMinSpinsText:SetHeight(14)

local spinsText = frame:CreateFontString(nil, "OVERLAY")
spinsText:SetFontObject("GameFontNormal")
spinsText:SetPoint("BOTTOM", frame, "BOTTOM", 140, 50)
spinsText:SetText("Spins")
-- spins end

-- Win text
frame.winText = frame:CreateFontString(nil, "OVERLAY")
frame.winText:SetFontObject("GameFontNormal")
frame.winText:SetPoint("BOTTOM", frame, "BOTTOM", 0, 110)
frame.winText:SetText("Win: 100")

-- OnClick event for spinButton
spinButton:SetScript("OnClick", function()
    -- Add your slot machine logic here
    -- BlinkLights()  -- Call BlinkLights when a payout happens
    Step(1)
    UpdateSlotTextures()
end)

-- OnClick event for autoSpinButton
autoSpinButton:SetScript("OnClick", function()
    -- Add your auto spin logic here
end)

-- OnClick events for bet and spins selectors
betMin:SetScript("OnClick", function()
    -- Decrease bet value
end)

betIncrement:SetScript("OnClick", function()
    -- Increase bet value
end)

spinsMin:SetScript("OnClick", function()
    -- Decrease spins value
end)

spinsPlus:SetScript("OnClick", function()
    -- Increase spins value
end)

-- You can do a lot of things on client side events.
-- You can find all events for different frame types here: http://wowwiki.wikia.com/Widget_handlers
-- Here I send a message to the server that executes the print handler
-- See the ExampleServer.lua file for the server side print handler.
local function OnClickButton(btn)
    -- AIO.Handle(ADDON_NAME, "Print", btn:GetName(), input:GetText(), slider:GetValue())
    AIO.Handle(ADDON_NAME, "Print", "HELLO WORLD!")
end
-- button:SetScript("OnClick", OnClickButton)

-- A handler triggered by using AIO.Handle(player, "AIOExample", "ShowFrame")
-- on server side.
function SMHandlers.ShowFrame(player)
    frame:Show()
end
