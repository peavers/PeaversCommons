-- PeaversCommons PatronsUI Module
local PeaversCommons = _G.PeaversCommons
local PatronsUI = {}
PeaversCommons.PatronsUI = PatronsUI

-- Reference to other modules
local Patrons = PeaversCommons.Patrons
local Utils = PeaversCommons.Utils

-- Constants for UI
local PADDING = 16
local LINE_HEIGHT = 18
local SECTION_SPACING = 15

-- Create a frame to display patron information
function PatronsUI:CreatePatronsFrame(parentFrame)
    -- Safety check
    if not parentFrame then
        return nil
    end
    
    -- Container frame
    local patronsFrame = CreateFrame("Frame", nil, parentFrame)
    patronsFrame:SetPoint("TOP", 0, -150)  -- Position below other support UI elements
    patronsFrame:SetPoint("LEFT", PADDING, 0)
    patronsFrame:SetPoint("RIGHT", -PADDING, 0)
    patronsFrame:SetHeight(200)  -- Initial height, will be adjusted as needed
    
    -- Patrons title
    local titleText = patronsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    titleText:SetPoint("TOP", 0, 0)
    titleText:SetText("Special Thanks To Our Patrons")
    titleText:SetTextColor(1, 0.82, 0)  -- Gold-ish color
    
    -- Create a simple centered list for patrons
    local patronsList = patronsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    patronsList:SetPoint("TOP", titleText, "BOTTOM", 0, -SECTION_SPACING)
    patronsList:SetPoint("LEFT", patronsFrame, "LEFT", PADDING, 0)
    patronsList:SetPoint("RIGHT", patronsFrame, "RIGHT", -PADDING, 0)
    patronsList:SetJustifyH("CENTER")
    patronsList:SetSpacing(5)  -- Add some spacing between lines if text wraps
    
    -- Store references to UI elements
    patronsFrame.titleText = titleText
    patronsFrame.patronsList = patronsList
    
    -- Immediately load and display patron list
    function patronsFrame:UpdatePatrons()
        -- Get all patrons
        local allPatrons = Patrons:GetAll()
        
        -- Hide the frame if no patrons
        if #allPatrons == 0 then
            self:Hide()
            return
        else
            self:Show()
        end
        
        -- Sort patrons alphabetically
        table.sort(allPatrons, function(a, b) 
            return a.name < b.name
        end)
        
        -- Create patron names string with bullet point separators
        local patronNames = {}
        for _, patron in ipairs(allPatrons) do
            table.insert(patronNames, patron.name)
        end
        
        -- Join with bullet points and display
        self.patronsList:SetText(table.concat(patronNames, " • "))
        
        -- Set height based on text height
        self.patronsList:SetHeight(self.patronsList:GetStringHeight() + PADDING)
        
        -- Update total frame height
        self:SetHeight(self.titleText:GetHeight() + SECTION_SPACING + self.patronsList:GetHeight() + PADDING)
        
        -- Flag as updated
        self.isUpdated = true
    end
    
    -- Force update function (simplified)
    patronsFrame.ForceUpdate = function()
        patronsFrame:UpdatePatrons()
    end
    
    -- Do the initial update immediately
    patronsFrame:UpdatePatrons()
    
    return patronsFrame
end

-- Function to add patron display to an addon's support UI
function PatronsUI:AddToSupportPanel(addon)
    -- Check for needed addon support panel
    if not addon then
        return false
    end
    
    -- For the direct approach used in addons, check for the direct panel
    if not addon.supportPanel and addon.directPanel then
        addon.supportPanel = addon.directPanel
    end
    
    if not addon.supportPanel then
        -- Create a support panel for the addon if needed
        if addon.name and addon.mainCategory then
            addon.supportPanel = CreateFrame("Frame")
            addon.supportPanel.name = "Support"
        else
            return false
        end
    end
    
    -- Create patrons frame if it doesn't exist
    if not addon.patronsFrame then
        addon.patronsFrame = self:CreatePatronsFrame(addon.supportPanel)
        
        -- Hook the panel's OnShow to update patrons
        if addon.patronsFrame and addon.supportPanel.SetScript then
            local originalOnShow = addon.supportPanel:GetScript("OnShow")
            addon.supportPanel:SetScript("OnShow", function(panel, ...)
                -- Call original OnShow if it exists
                if originalOnShow then
                    originalOnShow(panel, ...)
                end
                
                -- Update patrons display using the ForceUpdate function
                if addon.patronsFrame and addon.patronsFrame.ForceUpdate then
                    addon.patronsFrame.ForceUpdate()
                end
            end)
        end
        
        -- Try again after a delay in case panel isn't fully initialized
        C_Timer.After(1, function()
            if not addon.patronsFrame.isUpdated and addon.patronsFrame.ForceUpdate then
                addon.patronsFrame.ForceUpdate()
            end
        end)
    end
    
    return true
end

-- Function to initialize patrons display for all registered addons
function PatronsUI:InitializeForAllAddons()
    -- Check all major sources of addon registrations
    local registeredAddons = {}
    
    -- Check SettingsUI first (newer system)
    if PeaversCommons.SettingsUI and PeaversCommons.SettingsUI.GetRegisteredAddons then
        local settingsAddons = PeaversCommons.SettingsUI:GetRegisteredAddons()
        if settingsAddons then
            for addonName, addon in pairs(settingsAddons) do
                registeredAddons[addonName] = addon
            end
        end
    end
    
    -- Check SupportUI second (older system)
    if PeaversCommons.SupportUI and PeaversCommons.SupportUI.GetRegisteredAddons then
        local supportAddons = PeaversCommons.SupportUI:GetRegisteredAddons()
        if supportAddons then
            for addonName, addon in pairs(supportAddons) do
                if not registeredAddons[addonName] then
                    registeredAddons[addonName] = addon
                end
            end
        end
    end
    
    -- Check specific known addons
    local knownAddons = {
        "PeaversDynamicStats", "PeaversAlwaysSquare", "PeaversActionPerMinute",
        "PeaversItemLevel", "PeaversRemembersYou", "PeaversSafeList",
        "PeaversTalents", "PeaversTalentsData"
    }
    
    for _, addonName in ipairs(knownAddons) do
        if _G[addonName] and not registeredAddons[addonName] then
            registeredAddons[addonName] = _G[addonName]
        end
    end
    
    -- Add patrons display to each addon
    for addonName, addon in pairs(registeredAddons) do
        -- Try existing panel first
        if addon.supportPanel or addon.directPanel then
            if not addon.supportPanel and addon.directPanel then
                addon.supportPanel = addon.directPanel
            end
            self:AddToSupportPanel(addon)
        else
            -- Try again after a delay
            C_Timer.After(1, function()
                if addon.supportPanel or addon.directPanel then
                    if not addon.supportPanel and addon.directPanel then
                        addon.supportPanel = addon.directPanel
                    end
                    self:AddToSupportPanel(addon)
                end
            end)
        end
    end
    
    return true
end

-- Return the module
return PatronsUI