-- PeaversCommons FrameUtils Module
-- This provides frame utility functions for creating common UI elements
local PeaversCommons = _G.PeaversCommons
local FrameUtils = {}
PeaversCommons.FrameUtils = FrameUtils

-- Safely access global variables by name
function FrameUtils.GetGlobal(name)
    if name and type(name) == "string" then
        return _G[name]
    end
    return nil
end

-- Creates a section header with gold text
function FrameUtils.CreateSectionHeader(parent, text, x, y)
    local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", x, y)
    header:SetText(text)
    header:SetTextColor(1, 0.82, 0) -- Gold color only for headers
    header:SetWidth(400)
    header:SetJustifyH("LEFT") -- Explicitly set left alignment
    return header, y - 25 -- Return new y position
end

-- Creates a text label with optional font
function FrameUtils.CreateLabel(parent, text, x, y, fontObject)
    local label = parent:CreateFontString(nil, "ARTWORK", fontObject or "GameFontNormal")
    label:SetPoint("TOPLEFT", x, y)
    label:SetText(text)
    label:SetTextColor(1, 1, 1) -- Explicitly set white color for all labels
    return label, y - 20 -- Return new y position
end

-- Creates a checkbox with optional initial value and click handler
function FrameUtils.CreateCheckbox(parent, name, text, x, y, initialValue, textColor, onClick)
    local checkbox = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", x, y)

    local textObj = checkbox.Text
    if not textObj and checkbox:GetName() then
        textObj = FrameUtils.GetGlobal(checkbox:GetName() .. "Text")
    end

    if textObj then
        textObj:SetText(text)
        textObj:SetFontObject("GameFontNormal")
        if textColor then
            textObj:SetTextColor(textColor[1], textColor[2], textColor[3])
        end
    end

    if initialValue ~= nil then
        checkbox:SetChecked(initialValue)
    end

    if onClick then
        checkbox:SetScript("OnClick", onClick)
    end

    return checkbox, y - 25 -- Return new y position
end

-- Creates a slider with min/max values and step size
function FrameUtils.CreateSlider(parent, name, minVal, maxVal, step, x, y, initialValue, width)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetWidth(width or 400)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetValue(initialValue)

    local sliderName = slider:GetName()
    if sliderName then
        local lowText = FrameUtils.GetGlobal(sliderName .. "Low")
        local highText = FrameUtils.GetGlobal(sliderName .. "High")
        local valueText = FrameUtils.GetGlobal(sliderName .. "Text")

        if lowText then
            lowText:SetText("")
        end
        if highText then
            highText:SetText("")
        end
        if valueText then
            valueText:SetText("")
        end
    end

    return slider, y - 40 -- Return new y position
end

-- Creates a dropdown menu with optional initial text
function FrameUtils.CreateDropdown(parent, name, x, y, width, initialText)
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", x, y)
    UIDropDownMenu_SetWidth(dropdown, width or 360)

    if initialText then
        UIDropDownMenu_SetText(dropdown, initialText)
    end

    return dropdown, y - 40 -- Return new y position
end

-- Creates a scrollable frame with content child
function FrameUtils.CreateScrollFrame(parent)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -16)
    scrollFrame:SetPoint("BOTTOMRIGHT", -32, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(content)
    content:SetWidth(scrollFrame:GetWidth() - 16)
    content:SetHeight(1) -- Will be adjusted dynamically

    return scrollFrame, content
end

-- Creates a basic frame with optional size and backdrop
function FrameUtils.CreateFrame(name, parent, width, height, backdrop)
    local frame = CreateFrame("Frame", name, parent, backdrop and "BackdropTemplate" or nil)

    if width and height then
        frame:SetSize(width, height)
    end

    if backdrop then
        frame:SetBackdrop(backdrop)
    end

    return frame
end

-- Creates a button with optional size and click handler
function FrameUtils.CreateButton(parent, name, text, x, y, width, height, onClick)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", x, y)
    button:SetSize(width or 100, height or 22)
    button:SetText(text)

    if onClick then
        button:SetScript("OnClick", onClick)
    end

    return button, y - (height or 22) - 5
end

-- Creates a color picker button with optional label and change handler
function FrameUtils.CreateColorPicker(parent, name, label, x, y, initialColor, onChange)
    local colorFrame = CreateFrame("Button", name, parent, "BackdropTemplate")
    colorFrame:SetPoint("TOPLEFT", x, y)
    colorFrame:SetSize(16, 16)
    colorFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })

    if initialColor then
        colorFrame:SetBackdropColor(initialColor.r, initialColor.g, initialColor.b)
    else
        colorFrame:SetBackdropColor(1, 1, 1)
    end

    local colorLabel
    if label then
        colorLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        colorLabel:SetPoint("LEFT", colorFrame, "RIGHT", 5, 0)
        colorLabel:SetText(label)
    end

    colorFrame:SetScript("OnClick", function()
        local function ColorCallback(restore)
            local newR, newG, newB
            if restore then
                newR, newG, newB = unpack(restore)
            else
                -- Get color using the latest API
                newR, newG, newB = ColorPickerFrame.Content.ColorPicker:GetColorRGB()
            end

            colorFrame:SetBackdropColor(newR, newG, newB)

            if onChange then
                onChange(newR, newG, newB)
            end
        end

        local r, g, b = colorFrame:GetBackdropColor()

        -- Set both func and swatchFunc for compatibility with different API versions
        ColorPickerFrame.func = ColorCallback
        ColorPickerFrame.swatchFunc = ColorCallback
        ColorPickerFrame.cancelFunc = ColorCallback
        ColorPickerFrame.opacityFunc = nil
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame.previousValues = { r, g, b }

        -- Set color using the latest API
        ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)

        ColorPickerFrame:Hide() -- Hide first to trigger OnShow handler
        ColorPickerFrame:Show()
    end)

    return colorFrame, colorLabel, y - 25
end

-- Creates a horizontal separator line
function FrameUtils.CreateSeparator(parent, x, y, width)
    local separator = parent:CreateTexture(nil, "ARTWORK")
    separator:SetPoint("TOPLEFT", x, y)
    separator:SetSize(width or 450, 1)
    separator:SetColorTexture(0.5, 0.5, 0.5, 0.5) -- Semi-transparent gray line

    return separator, y - 15 -- Return new y position with spacing
end

-- Creates a tab for tabbed interfaces
function FrameUtils.CreateTab(dialog, id, text, tabPrefix)
    local tabName = (tabPrefix or "Tab") .. id
    local tab = CreateFrame("Button", tabName, dialog, "PanelTabButtonTemplate")
    tab:SetText(text)
    tab:SetID(id)

    if id == 1 then
        tab:SetPoint("BOTTOMLEFT", dialog, "BOTTOMLEFT", 5, -30)
    else
        tab:SetPoint("LEFT", dialog.Tabs[id - 1], "RIGHT", -16, 0)
    end

    tab:SetScript("OnClick", function()
        PanelTemplates_SetTab(dialog, id)
        for _, content in pairs(dialog.TabContents) do
            content:Hide()
        end
        dialog.TabContents[id]:Show()
    end)

    return tab
end

-- Creates content frame for a tab
function FrameUtils.CreateTabContent(dialog)
    local content = CreateFrame("Frame", nil, dialog)
    content:SetPoint("TOPLEFT", dialog, "TOPLEFT", 0, -25)
    content:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", 0, -30)
    content:Hide()
    return content
end

-- Creates a title background frame
function FrameUtils.CreateTitleBackground(dialog, height)
    local titleBg = CreateFrame("Frame", nil, dialog)
    titleBg:SetPoint("TOPLEFT", 0, 0)
    titleBg:SetPoint("TOPRIGHT", 0, 0)
    titleBg:SetHeight(height or 20)
    titleBg:SetFrameLevel(dialog:GetFrameLevel() + 1)
    return titleBg
end

-- Creates a close button in the top right corner
function FrameUtils.CreateCloseButton(dialog)
    local closeButton = CreateFrame("Button", nil, dialog, "UIPanelCloseButtonNoScripts")
    closeButton:SetPoint("TOPRIGHT", dialog, "TOPRIGHT", 0, 0)
    closeButton:SetFrameStrata("DIALOG")
    closeButton:SetFrameLevel(dialog:GetFrameLevel() + 1000)
    closeButton:Raise()
    closeButton:SetScript("OnClick", function()
        dialog:Hide()
    end)
    return closeButton
end

-- Create an input box
function FrameUtils.CreateInputBox(parent, name, width, height, x, y)
    local editBox = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    editBox:SetPoint("TOPLEFT", x, y)
    editBox:SetSize(width or 200, height or 20)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(255)
    
    return editBox, y - (height or 20) - 5
end

-- Create a simple tooltip for a frame
function FrameUtils.AddTooltip(frame, title, text)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if title then
            GameTooltip:SetText(title, 1, 1, 1)
        end
        if text then
            GameTooltip:AddLine(text, nil, nil, nil, true)
        end
        GameTooltip:Show()
    end)
    
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

return FrameUtils