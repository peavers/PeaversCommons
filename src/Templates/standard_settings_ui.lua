-- STANDARDIZED SETTINGS UI TEMPLATE
-- This function creates a standardized settings UI for all Peavers addons
-- With a support page as the landing page and settings as a subcategory
--
-- Usage:
-- 1. Copy this code to each addon's initialization function
-- 2. Replace the addon variables as needed
-- 3. Update the addon description and commands for each addon

function CreateStandardSettingsUI(addonRef, addonName, addonTitle, addonDescription, slashCommands)
    -- Create the main panel (Support UI as landing page)
    local mainPanel = CreateFrame("Frame")
    mainPanel.name = addonName
    
    -- Required callbacks
    mainPanel.OnRefresh = function() end
    mainPanel.OnCommit = function() end
    mainPanel.OnDefault = function() end
    
    -- Get addon version
    local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "1.0.0"
    
    -- Add background image
    local ICON_ALPHA = 0.1
    local iconPath = "Interface\\AddOns\\" .. addonName .. "\\src\\Media\\Icon"
    local largeIcon = mainPanel:CreateTexture(nil, "BACKGROUND")
    largeIcon:SetTexture(iconPath)
    largeIcon:SetPoint("TOPLEFT", mainPanel, "TOPLEFT", 0, 0)
    largeIcon:SetPoint("BOTTOMRIGHT", mainPanel, "BOTTOMRIGHT", 0, 0)
    largeIcon:SetAlpha(ICON_ALPHA)
    
    -- Create header and description
    local titleText = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    titleText:SetPoint("TOPLEFT", 16, -16)
    titleText:SetText(addonTitle)
    titleText:SetTextColor(1, 0.84, 0)  -- Gold color for title
    
    -- Version information
    local versionText = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    versionText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -8)
    versionText:SetText("Version: " .. version)
    
    -- Support information
    local supportInfo = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    supportInfo:SetPoint("TOPLEFT", 16, -70)
    supportInfo:SetPoint("TOPRIGHT", -16, -70)
    supportInfo:SetJustifyH("LEFT")
    supportInfo:SetText(addonDescription .. " If you enjoy this addon and would like to support its development, or if you need help, stop by the website.")
    supportInfo:SetSpacing(2)
    
    -- Website URL
    local websiteLabel = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    websiteLabel:SetPoint("TOPLEFT", 16, -120)
    websiteLabel:SetText("Website:")
    
    local websiteURL = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    websiteURL:SetPoint("TOPLEFT", websiteLabel, "TOPLEFT", 70, 0)
    websiteURL:SetText("https://peavers.io")
    websiteURL:SetTextColor(0.3, 0.6, 1.0)
    
    -- Additional info
    local additionalInfo = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    additionalInfo:SetPoint("BOTTOMRIGHT", -16, 16)
    additionalInfo:SetJustifyH("RIGHT")
    additionalInfo:SetText("Thank you for using Peavers Addons!")
    
    -- Now create/prepare the settings panel
    local settingsPanel
    
    if addonRef.ConfigUI and addonRef.ConfigUI.panel then
        -- Use existing ConfigUI panel
        settingsPanel = addonRef.ConfigUI.panel
    else
        -- Create a simple settings panel with commands
        settingsPanel = CreateFrame("Frame")
        settingsPanel.name = "Settings"
        
        -- Required callbacks
        settingsPanel.OnRefresh = function() end
        settingsPanel.OnCommit = function() end
        settingsPanel.OnDefault = function() end
        
        -- Add content
        local settingsTitle = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        settingsTitle:SetPoint("TOPLEFT", 16, -16)
        settingsTitle:SetText("Settings")
        
        -- Add commands if provided
        if slashCommands and #slashCommands > 0 then
            local commandsTitle = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            commandsTitle:SetPoint("TOPLEFT", settingsTitle, "BOTTOMLEFT", 0, -16)
            commandsTitle:SetText("Available Commands:")
            
            local commandsList = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            commandsList:SetPoint("TOPLEFT", commandsTitle, "BOTTOMLEFT", 10, -8)
            commandsList:SetJustifyH("LEFT")
            commandsList:SetText(table.concat(slashCommands, "\n"))
        end
    end
    
    -- Register with the Settings API
    if Settings then
        -- Register main category
        local category = Settings.RegisterCanvasLayoutCategory(mainPanel, mainPanel.name)
        
        -- This is the CRITICAL line to make it appear in Options > Addons
        Settings.RegisterAddOnCategory(category)
        
        -- Store the category
        addonRef.directCategory = category
        addonRef.directPanel = mainPanel
        
        -- Register settings panel as subcategory
        if settingsPanel then
            local settingsCategory = Settings.RegisterCanvasLayoutSubcategory(category, settingsPanel, settingsPanel.name)
            addonRef.directSettingsCategory = settingsCategory
        end
        
        -- Debug output if available
        if addonRef.Debug or (PeaversCommons and PeaversCommons.Utils and PeaversCommons.Utils.Debug) then
            local debugFunc = addonRef.Debug or function(msg) PeaversCommons.Utils.Debug(addonRef, msg) end
            debugFunc("Direct registration complete")
        end
        
        return true
    end
    
    return false
end

-- Example usage:
--[[
C_Timer.After(0.5, function()
    CreateStandardSettingsUI(
        myAddon,             -- Addon reference (eg. PryAddon, PAPM, etc.)
        "MyAddonName",       -- Full addon name (eg. "PeaversRemembersYou")
        "My Addon Title",    -- Title displayed in UI (eg. "Peavers Remembers You")
        "Description of what the addon does.",  -- Short description
        {                    -- Slash commands list (each line as a separate entry)
            "/cmd - Main command",
            "/cmd help - Show help",
            "/cmd reset - Reset data"
        }
    )
end)
--]]