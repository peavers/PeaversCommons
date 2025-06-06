local MAJOR, MINOR = "PeaversCommons-1.0", 3
local PeaversCommons = LibStub and LibStub(MAJOR) or {}

-- Initialize StatBar namespace
PeaversCommons.StatBar = {}
local StatBar = PeaversCommons.StatBar

-- Creates a new stat bar instance
function StatBar:New(parent, name, barType)
    local obj = {}
    setmetatable(obj, { __index = StatBar })

    obj.name = name
    obj.type = barType
    obj.value = 0
    obj.maxValue = 100
    obj.targetValue = 0
    obj.smoothing = true
    obj.yOffset = 0
    obj.frame = obj:CreateFrame(parent)

    -- Set default color
    obj:SetColor(0.8, 0.8, 0.8)

    obj:InitAnimationSystem()
    obj:InitChangeTextFadeAnimation()

    return obj
end

-- Creates the visual elements of the stat bar
function StatBar:CreateFrame(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(200, 20) -- Default size, will be updated

    local bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    bg:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = nil,
        tile = false,
        tileSize = 32,
        edgeSize = 0,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    bg:SetBackdropColor(0, 0, 0, 0.5)
    self.bg = bg

    local bar = CreateFrame("StatusBar", nil, frame)
    bar:SetAllPoints(frame)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetMinMaxValues(0, 100)
    bar:SetValue(0)
    self.bar = bar

    local text = bar:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    text:SetPoint("CENTER", bar, "CENTER", 0, 0)
    text:SetJustifyH("CENTER")
    text:SetTextColor(1, 1, 1, 1)
    self.text = text

    local changeText = bar:CreateFontString(nil, "OVERLAY")
    changeText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    changeText:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
    changeText:SetJustifyH("RIGHT")
    changeText:SetText("")
    changeText:SetAlpha(0)
    self.changeText = changeText

    return frame
end

-- Initialize animation for smooth bar updates
function StatBar:InitAnimationSystem()
    self.animTimer = nil
    self.animStartValue = 0
    self.animEndValue = 0
    self.animDuration = 0
    self.animElapsed = 0
end

-- Initialize change text fade animation
function StatBar:InitChangeTextFadeAnimation()
    self.changeTextAlpha = 0
    self.changeTextTimer = nil
end

-- Updates the stat bar value with optional animation
function StatBar:Update(value, maxValue, change)
    value = value or 0
    maxValue = maxValue or self.maxValue
    
    if maxValue ~= self.maxValue then
        self.maxValue = maxValue
        self.bar:SetMinMaxValues(0, maxValue)
    end

    self.targetValue = value

    -- Update text immediately
    self:UpdateText(value, maxValue)

    -- Show change text if there's a significant change
    if change and math.abs(change) > 0 then
        self:ShowChangeText(change)
    end

    -- Update bar value (with animation if enabled)
    if self.smoothing and self.frame:IsVisible() then
        self:AnimateToValue(value, 0.5) -- 0.5 second animation
    else
        self.value = value
        self.bar:SetValue(value)
    end
end

-- Animates the bar to a new value over time
function StatBar:AnimateToValue(targetValue, duration)
    -- If we're already animating to this value, don't restart
    if self.animTimer and self.animEndValue == targetValue then
        return
    end

    -- Cancel any existing animation
    if self.animTimer then
        self.animTimer:Cancel()
    end

    self.animStartValue = self.value
    self.animEndValue = targetValue
    self.animDuration = duration
    self.animElapsed = 0

    self.animTimer = C_Timer.NewTicker(0.02, function() -- ~50 FPS
        self.animElapsed = self.animElapsed + 0.02

        if self.animElapsed >= self.animDuration then
            -- Animation complete
            self.value = self.animEndValue
            self.bar:SetValue(self.value)
            self.animTimer:Cancel()
            self.animTimer = nil
        else
            -- Calculate eased position (simple ease-out)
            local progress = self.animElapsed / self.animDuration
            local easedProgress = 1 - math.pow(1 - progress, 3)
            
            local currentValue = self.animStartValue + (self.animEndValue - self.animStartValue) * easedProgress
            self.value = currentValue
            self.bar:SetValue(currentValue)
        end
    end)
end

-- Updates the text displayed on the bar
function StatBar:UpdateText(value, maxValue)
    if self.hideText then
        self.text:SetText("")
        return
    end

    local percentage = maxValue > 0 and (value / maxValue * 100) or 0
    local text = string.format("%d / %d (%.1f%%)", value, maxValue, percentage)
    self.text:SetText(text)
end

-- Shows temporary change text that fades out
function StatBar:ShowChangeText(change)
    local prefix = change > 0 and "+" or ""
    self.changeText:SetText(prefix .. tostring(math.floor(change)))
    
    if change > 0 then
        self.changeText:SetTextColor(0, 1, 0, 1) -- Green for positive
    else
        self.changeText:SetTextColor(1, 0, 0, 1) -- Red for negative
    end
    
    -- Cancel any existing fade timer
    if self.changeTextTimer then
        self.changeTextTimer:Cancel()
    end
    
    -- Reset alpha
    self.changeTextAlpha = 1
    self.changeText:SetAlpha(1)
    
    -- Start fade after 0.5 seconds
    local fadeDelay = 0.5
    local fadeDuration = 1.0
    
    self.changeTextTimer = C_Timer.NewTicker(0.02, function()
        fadeDelay = fadeDelay - 0.02
        
        if fadeDelay <= 0 then
            self.changeTextAlpha = self.changeTextAlpha - (0.02 / fadeDuration)
            
            if self.changeTextAlpha <= 0 then
                self.changeTextAlpha = 0
                self.changeText:SetAlpha(0)
                self.changeTextTimer:Cancel()
                self.changeTextTimer = nil
            else
                self.changeText:SetAlpha(self.changeTextAlpha)
            end
        end
    end)
end

-- Sets the color of the bar
function StatBar:SetColor(r, g, b)
    self.bar:SetStatusBarColor(r, g, b)
end

-- Updates the height of the bar
function StatBar:UpdateHeight(height)
    self.frame:SetHeight(height)
end

-- Updates the width of the bar
function StatBar:UpdateWidth(width)
    width = width or self.frame:GetParent():GetWidth()
    self.frame:SetWidth(width)
end

-- Updates the bar texture
function StatBar:UpdateTexture(texture)
    if texture then
        self.bar:SetStatusBarTexture(texture)
    end
end

-- Updates the font settings
function StatBar:UpdateFont(fontFace, fontSize, fontOutline)
    self.text:SetFont(fontFace, fontSize, fontOutline)
    self.changeText:SetFont(fontFace, fontSize - 2, fontOutline)
end

-- Updates background opacity
function StatBar:UpdateBackgroundOpacity(alpha)
    local r, g, b = self.bg:GetBackdropColor()
    self.bg:SetBackdropColor(r, g, b, alpha)
end

-- Sets the position of the bar
function StatBar:SetPosition(x, y)
    self.frame:ClearAllPoints()
    self.frame:SetPoint("TOP", self.frame:GetParent(), "TOP", x, y)
    self.yOffset = y
end

-- Shows/hides the bar
function StatBar:SetShown(show)
    if show then
        self.frame:Show()
    else
        self.frame:Hide()
    end
end

-- Clean up the bar
function StatBar:Destroy()
    if self.animTimer then
        self.animTimer:Cancel()
    end
    if self.changeTextTimer then
        self.changeTextTimer:Cancel()
    end
    self.frame:Hide()
    self.frame:SetParent(nil)
end

return StatBar