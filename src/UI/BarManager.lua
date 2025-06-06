local MAJOR, MINOR = "PeaversCommons-1.0", 3
local PeaversCommons = LibStub and LibStub(MAJOR) or {}

-- Initialize BarManager namespace
PeaversCommons.BarManager = {}
local BarManager = PeaversCommons.BarManager

-- Collection to store all created bars
BarManager.bars = {}

-- Creates or recreates all stat bars based on current configuration
function BarManager:CreateBars(parent, barDefinitions, config)
    -- Clear existing bars
    for _, bar in ipairs(self.bars) do
        bar.frame:Hide()
    end
    self.bars = {}

    local yOffset = 0
    for _, barDef in ipairs(barDefinitions) do
        if barDef.show ~= false then  -- Default to showing if not specified
            local bar = PeaversCommons.StatBar:New(parent, barDef.name, barDef.type)
            bar:SetPosition(0, yOffset)
            bar:Update(barDef.value or 0, barDef.maxValue or 100)
            
            -- Apply custom color if provided
            if barDef.color then
                bar:SetColor(barDef.color.r, barDef.color.g, barDef.color.b)
            end

            table.insert(self.bars, bar)

            -- Position bars based on spacing config
            if config.barSpacing == 0 then
                yOffset = yOffset - config.barHeight
            else
                yOffset = yOffset - (config.barHeight + config.barSpacing)
            end
        end
    end

    return math.abs(yOffset)
end

-- Updates all stat bars with latest values
function BarManager:UpdateAllBars(updates)
    for _, bar in ipairs(self.bars) do
        local update = updates[bar.type]
        if update then
            bar:Update(update.value, update.maxValue, update.change)
        end
    end
end

-- Update specific bar by type
function BarManager:UpdateBar(barType, value, maxValue, change)
    local bar = self:GetBar(barType)
    if bar then
        bar:Update(value, maxValue, change)
    end
end

-- Resizes all bars based on current configuration
function BarManager:ResizeBars(config)
    for _, bar in ipairs(self.bars) do
        bar:UpdateHeight(config.barHeight)
        bar:UpdateWidth()
        bar:UpdateTexture(config.barTexture)
        bar:UpdateFont(config.fontFace, config.fontSize, config.fontOutline)
        bar:UpdateBackgroundOpacity(config.barBgAlpha)
    end

    -- Return the total height of all bars for frame adjustment
    local totalHeight = #self.bars * config.barHeight
    if config.barSpacing > 0 then
        totalHeight = totalHeight + (#self.bars - 1) * config.barSpacing
    end

    return totalHeight
end

-- Adjusts the frame height based on number of bars and title bar visibility
function BarManager:AdjustFrameHeight(frame, contentFrame, titleBarVisible, config)
    local barCount = #self.bars
    local contentHeight

    -- Calculate content height based on bar spacing
    if config.barSpacing == 0 then
        contentHeight = barCount * config.barHeight
    else
        contentHeight = barCount * (config.barHeight + config.barSpacing) - config.barSpacing
    end

    if contentHeight == 0 then
        if titleBarVisible then
            frame:SetHeight(20) -- Just title bar
        else
            frame:SetHeight(10) -- Minimal height
        end
    else
        if titleBarVisible then
            frame:SetHeight(contentHeight + 20) -- Add title bar height
        else
            frame:SetHeight(contentHeight) -- Just content
        end
    end
end

-- Gets a bar by its type
function BarManager:GetBar(barType)
    for _, bar in ipairs(self.bars) do
        if bar.type == barType then
            return bar
        end
    end
    return nil
end

-- Gets the number of visible bars
function BarManager:GetBarCount()
    return #self.bars
end

-- Clean up all bars
function BarManager:Destroy()
    for _, bar in ipairs(self.bars) do
        bar:Destroy()
    end
    self.bars = {}
end

return BarManager