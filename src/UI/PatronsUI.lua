-- PeaversCommons PatronsUI Module
local PeaversCommons = _G.PeaversCommons
local PatronsUI = {}
PeaversCommons.PatronsUI = PatronsUI

-- Reference to other modules
local Patrons = PeaversCommons.Patrons
local Utils = PeaversCommons.Utils

-- Constants for UI
local PADDING = 16
local TITLE_OFFSET_Y = -20
local LINE_HEIGHT = 18
local PATRONS_PER_ROW = 4  -- Increased from 3 to 4
local PATRON_SPACING = 10
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
    patronsFrame:SetHeight(200)  -- Initial height, will be adjusted later
    
    -- Patrons title
    local titleText = patronsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    titleText:SetPoint("TOP", 0, 0)
    titleText:SetText("Special Thanks To Our Patrons")
    titleText:SetTextColor(1, 0.82, 0)  -- Gold-ish color
    
    -- Container for patron names
    local patronsContainer = CreateFrame("Frame", nil, patronsFrame)
    patronsContainer:SetPoint("TOP", titleText, "BOTTOM", 0, -SECTION_SPACING)
    patronsContainer:SetPoint("LEFT", 0, 0)
    patronsContainer:SetPoint("RIGHT", 0, 0)
    patronsContainer:SetHeight(LINE_HEIGHT)  -- Initial height, will be adjusted
    
    -- Store text objects for patrons
    patronsFrame.patronTexts = {}
    patronsFrame.patronsContainer = patronsContainer
    patronsFrame.titleText = titleText
    
    -- Method to update patron display
    function patronsFrame:UpdatePatrons(forced)
        -- Get the container width - ensure it's valid before proceeding
        local containerWidth = self.patronsContainer:GetWidth()
        
        -- Check if we have a valid width to use
        if containerWidth <= 10 and not forced then
            -- Schedule another attempt with a longer delay
            C_Timer.After(0.5, function()
                self:UpdatePatrons(true)  -- Force update next time
            end)
            return
        end
        
        -- Get all patrons
        local allPatrons = Patrons:GetAll()
        
        -- Sort patrons alphabetically
        table.sort(allPatrons, function(a, b) 
            return a.name < b.name
        end)
        
        -- Clear existing patron names
        for _, textObj in ipairs(self.patronTexts) do
            textObj:Hide()
            textObj:SetText("")
        end
        
        -- Hide the frame if no patrons
        if #allPatrons == 0 then
            self:Hide()
            return
        else
            self:Show()
        end
        
        -- Make sure we have a valid width to use
        local maxWidth = containerWidth > 200 and containerWidth or 200  -- Use at least 200px width
        local colWidth = math.floor(maxWidth / PATRONS_PER_ROW)
        
        -- Width calculations ready
        
        -- Create a layout table first before applying it
        local layoutData = {}
        local row = 0
        local col = 0
        
        for i, patron in ipairs(allPatrons) do
            -- Calculate position
            local xPos = col * colWidth + PATRON_SPACING
            local yPos = -row * LINE_HEIGHT
            
            -- Store data for layout
            table.insert(layoutData, {
                index = i,
                name = patron.name,
                xPos = xPos,
                yPos = yPos
            })
            
            -- Update row and column for next patron
            col = col + 1
            if col >= PATRONS_PER_ROW then
                col = 0
                row = row + 1
            end
        end
        
        -- Now apply the layout to the actual UI elements
        for i, data in ipairs(layoutData) do
            -- Create or reuse text object
            local patronText
            if i <= #self.patronTexts then
                patronText = self.patronTexts[i]
                patronText:Show()
            else
                patronText = self.patronsContainer:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                table.insert(self.patronTexts, patronText)
            end
            
            -- Set text
            patronText:SetText(data.name)
            patronText:SetTextColor(1, 1, 1)  -- White text
            
            -- Set position
            patronText:ClearAllPoints()
            patronText:SetPoint("TOPLEFT", self.patronsContainer, "TOPLEFT", data.xPos, data.yPos)
        end
        
        -- Update container height based on number of rows
        local rows = math.ceil(#allPatrons / PATRONS_PER_ROW)
        local containerHeight = rows * LINE_HEIGHT
        if containerHeight < 1 then containerHeight = 1 end
        self.patronsContainer:SetHeight(containerHeight)
        
        -- Update total frame height
        self:SetHeight(self.titleText:GetHeight() + math.abs(TITLE_OFFSET_Y) + 
                       SECTION_SPACING + self.patronsContainer:GetHeight())
        
        -- Patrons display updated successfully
    end
    
    -- Store a reference to force a refresh when panel is shown
    patronsFrame.ForceUpdate = function()
        -- Explicit delay to allow frame to be fully rendered
        C_Timer.After(0.2, function()
            -- Cache size before first layout
            local width = patronsFrame.patronsContainer:GetWidth()
            
            if width <= 10 then
                -- Not visible yet, try with longer delay
                C_Timer.After(0.5, function()
                    patronsFrame:UpdatePatrons(true)
                end)
            else
                patronsFrame:UpdatePatrons(true)
            end
        end)
    end
    
    -- Initial update with multiple attempts to ensure proper layout
    C_Timer.After(0.1, function()
        patronsFrame:UpdatePatrons()
        
        -- Schedule additional updates to catch sizing issues
        C_Timer.After(0.5, function() 
            patronsFrame:UpdatePatrons(true)
        end)
        
        -- Final update with a longer delay
        C_Timer.After(1.0, function() 
            patronsFrame:UpdatePatrons(true)
        end)
    end)
    
    return patronsFrame
end

-- Function to add patron display to an addon's support UI
function PatronsUI:AddToSupportPanel(addon)
    -- Check for needed addon support panel
    if not addon then
        return false
    end
    
    -- For the direct approach used in PeaversDynamicStats, check for the direct panel
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
    end
    
    return true
end

-- Function to initialize patrons display for all registered addons
function PatronsUI:InitializeForAllAddons()
    if not PeaversCommons.SupportUI then
        return false
    end
    
    -- Access registered addons from SupportUI module
    local registeredAddons = PeaversCommons.SupportUI.GetRegisteredAddons and PeaversCommons.SupportUI:GetRegisteredAddons()
    
    if not registeredAddons or type(registeredAddons) ~= "table" then
        return false
    end
    
    -- Check for specific addons and register them if they exist
    for _, addonName in ipairs({"PeaversDynamicStats", "PeaversAlwaysSquare", "PeaversActionPerMinute", 
                                "PeaversItemLevel", "PeaversRemembersYou", "PeaversSafeList", 
                                "PeaversTalents", "PeaversTalentsData"}) do
        -- If the addon exists globally and hasn't been registered yet
        if _G[addonName] and not registeredAddons[addonName] then
            -- Direct patrons initialization for PeaversAlwaysSquare
            if addonName == "PeaversAlwaysSquare" and _G[addonName].directPanel then
                _G[addonName].supportPanel = _G[addonName].directPanel
                self:AddToSupportPanel(_G[addonName])
            end
            
            -- Register with SupportUI
            if PeaversCommons.SupportUI and PeaversCommons.SupportUI.RegisterAddon then
                PeaversCommons.SupportUI:RegisterAddon(_G[addonName])
            end
        end
    end
    
    -- Refresh registered addons list
    registeredAddons = PeaversCommons.SupportUI.GetRegisteredAddons and PeaversCommons.SupportUI:GetRegisteredAddons() or {}
    
    -- Add patrons display to each addon's support panel
    for addonName, addon in pairs(registeredAddons) do
        -- Wait for addon's support panel to be created
        if addon.supportPanel then
            self:AddToSupportPanel(addon)
        else
            -- Check for direct panel from custom UI setup
            if addon.directPanel then
                addon.supportPanel = addon.directPanel
                self:AddToSupportPanel(addon)
            else 
                -- Wait and try again later
                C_Timer.After(1, function()
                    if addon.supportPanel then
                        self:AddToSupportPanel(addon)
                    elseif addon.directPanel then
                        addon.supportPanel = addon.directPanel
                        self:AddToSupportPanel(addon)
                    end
                end)
            end
        end
    end
    
    return true
end

-- Return the module
return PatronsUI