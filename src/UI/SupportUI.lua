-- PeaversCommons SupportUI Module
local PeaversCommons = _G.PeaversCommons
local SupportUI = PeaversCommons.SupportUI or {}
PeaversCommons.SupportUI = SupportUI

-- Get Utils module for debugging
local Utils = PeaversCommons.Utils or {}

-- Local constants
local ICON_ALPHA = 0.1

-- Tables to track registered addons and initialized support categories
local registeredAddons = {}
local initializedAddons = {}

-- Ensure _pendingRegistrations exists
SupportUI._pendingRegistrations = SupportUI._pendingRegistrations or {}

-- Process any pending registrations that happened before this module was loaded
for _, addon in ipairs(SupportUI._pendingRegistrations) do
    if addon and addon.name then
        registeredAddons[addon.name] = addon
    end
end

-- Keep the pending registrations array (don't set to nil)
-- Just clear it so it can be reused
while #SupportUI._pendingRegistrations > 0 do
    table.remove(SupportUI._pendingRegistrations)
end

-- Function to register an addon with the SupportUI system
function SupportUI:RegisterAddon(addon)
    if not addon or not addon.name then
        error("SupportUI:RegisterAddon - addon table with name field is required")
        return false
    end
    
    -- Store the addon reference
    registeredAddons[addon.name] = addon
    
    return true
end

-- Create a standardized support panel for an addon
local function CreateSupportPanel(addon)
    local addonName = addon.name
    local version = addon.version or "Unknown"
    local iconPath = addon.iconPath or "Interface\\AddOns\\" .. addonName .. "\\src\\Media\\Icon"
    
    -- Create the panel
    local panel = CreateFrame("Frame")
    panel.name = "Support"
    
    -- Add background image if the file exists
    local largeIcon = panel:CreateTexture(nil, "BACKGROUND")
    largeIcon:SetTexture(iconPath)
    largeIcon:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    largeIcon:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
    largeIcon:SetAlpha(ICON_ALPHA)
    
    -- Create header and description
    local titleText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    titleText:SetPoint("TOPLEFT", 16, -16)
    titleText:SetText("Support " .. addonName)
    
    -- Show addon version
    local versionText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    versionText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -8)
    versionText:SetText("Version: " .. version)
    
    -- Support information
    local supportInfo = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    supportInfo:SetPoint("TOPLEFT", 16, -70)
    supportInfo:SetPoint("TOPRIGHT", -16, -70)
    supportInfo:SetJustifyH("LEFT")
    supportInfo:SetText("If you enjoy " .. addonName .. " and would like to support its development, or if you need help or want to request new features, stop by the website.")
    supportInfo:SetSpacing(2)
    
    -- Website URL as text
    local websiteLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    websiteLabel:SetPoint("TOPLEFT", 16, -120)
    websiteLabel:SetText("Website:")
    
    local websiteURL = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    websiteURL:SetPoint("TOPLEFT", websiteLabel, "TOPLEFT", 70, 0)
    websiteURL:SetText("https://peavers.io")
    websiteURL:SetTextColor(0.3, 0.6, 1.0)
    
    -- Additional info at bottom
    local additionalInfo = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    additionalInfo:SetPoint("BOTTOMRIGHT", -16, 16)
    additionalInfo:SetJustifyH("RIGHT")
    additionalInfo:SetText("Thank you for using Peavers Addons!")
    
    -- Required callbacks
    panel.OnRefresh = function() end
    panel.OnCommit = function() end
    panel.OnDefault = function() end
    
    return panel
end

-- Function to initialize the support UI for an addon
function SupportUI:InitializeAddonSupport(addon)
    if not addon or not addon.name then
        error("SupportUI:InitializeAddonSupport - addon object with name is required")
        return false
    end
    
    -- Skip if already initialized
    if initializedAddons[addon.name] then
        return true
    end
    
    -- Create the main settings panel if it doesn't exist
    if not addon.mainCategory then
        -- First, check if the addon has already registered its own settings panel
        local category = nil
        
        -- Check if Settings API is available
        if Settings and Settings.GetCategoryCount and Settings.GetCategoryInfo then
            local categoryCount = Settings.GetCategoryCount()
            if categoryCount and type(categoryCount) == "number" then
                for i = 1, categoryCount do
                    local id = Settings.GetCategoryInfo(i)
                    if id then
                        -- Try to match by name if ID doesn't match exactly
                        local name = Settings.GetCategoryInfo(id)
                        if id == addon.name or name == addon.name then
                            category = id
                            break
                        end
                    end
                end
            end
        end
        
        if category then
            -- Use the existing category
            addon.mainCategory = category
        else
            -- Create a new settings panel
            local mainPanel = CreateFrame("Frame")
            mainPanel.name = addon.name
            
            mainPanel.layoutIndex = 1
            mainPanel.OnShow = function(self) return true end
            
            -- Register with Settings UI
            -- Create the category and make sure it's visible in Options > Addons
            local category = Settings.RegisterCanvasLayoutCategory(mainPanel, mainPanel.name)
            if category then
                addon.mainCategory = category
                addon.mainCategory.ID = mainPanel.name
                
                -- This is the CRITICAL call to make the addon appear in Options > Addons
                Settings.RegisterAddOnCategory(addon.mainCategory)
                
                -- Successfully registered
            else
                -- If registration fails, try a direct approach
                
                -- Create the category directly
                local categoryData = Settings.CreateCategory(mainPanel.name, mainPanel.name, mainPanel.name)
                if categoryData then
                    addon.mainCategory = categoryData
                    addon.mainCategory.ID = mainPanel.name
                    Settings.RegisterAddOnCategory(categoryData)
                else
                    -- Last resort fallback
                    addon.mainCategory = mainPanel.name
                end
            end
            
            -- Required callbacks
            mainPanel.OnRefresh = function() end
            mainPanel.OnCommit = function() end
            mainPanel.OnDefault = function() end
        end
    end
    
    -- Skip creating support panel if it already exists
    if not addon.supportCategory then
        -- Create and register the support panel
        local supportPanel = CreateSupportPanel(addon)
        
        -- Get the mainCategory - might be a string ID or a category object
        local mainCategory = addon.mainCategory
        if type(mainCategory) == "string" then
            -- Try to find the category by ID
            for i = 1, Settings.GetCategoryCount() do
                local id = Settings.GetCategoryInfo(i)
                if id == mainCategory then
                    mainCategory = id
                    break
                end
            end
        end
        
        -- Make sure mainCategory is valid for registration
        if type(mainCategory) ~= "table" or not mainCategory.AddSubcategory then
            -- Try to get the actual category object if it's a string ID
            if type(mainCategory) == "string" then
                for i = 1, Settings.GetCategoryCount() do
                    local id = Settings.GetCategoryInfo(i)
                    if id == mainCategory then
                        mainCategory = id
                        break
                    end
                end
            end
        end
        
        -- Only register if we have a valid category
        if type(mainCategory) == "table" and mainCategory.AddSubcategory then
            local supportCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, supportPanel, supportPanel.name)
            if supportCategory then
                addon.supportCategory = supportCategory
                addon.supportCategory.ID = supportPanel.name
            end
        end
    end
    
    -- If the addon has a ConfigUI panel, register it as a subcategory
    if addon.ConfigUI and addon.ConfigUI.panel then
        -- Register the addon's config panel as the first subcategory
        local configPanel = addon.ConfigUI.panel
        if not addon.configCategory and addon.mainCategory then
            local mainCategory = addon.mainCategory
            
            -- Make sure mainCategory is valid for registration
            if type(mainCategory) ~= "table" or not mainCategory.AddSubcategory then
                -- Try to get the actual category object if it's a string ID
                if type(mainCategory) == "string" then
                    for i = 1, Settings.GetCategoryCount() do
                        local id = Settings.GetCategoryInfo(i)
                        if id == mainCategory then
                            mainCategory = id
                            break
                        end
                    end
                end
            end
            
            -- Only register if we have a valid category
            if type(mainCategory) == "table" and mainCategory.AddSubcategory then
                local configCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, configPanel, configPanel.name or "Settings")
                if configCategory then
                    addon.configCategory = configCategory
                    addon.configCategory.ID = configPanel.name or "Settings"
                end
            end
        end
    end
    
    -- If the addon has a SupportUI panel but it hasn't been registered yet, do it now
    if addon.supportPanel and not addon.supportCategory and addon.mainCategory then
        local mainCategory = addon.mainCategory
        
        -- Make sure mainCategory is valid for registration
        if type(mainCategory) ~= "table" or not mainCategory.AddSubcategory then
            -- Try to get the actual category object if it's a string ID
            if type(mainCategory) == "string" then
                for i = 1, Settings.GetCategoryCount() do
                    local id = Settings.GetCategoryInfo(i)
                    if id == mainCategory then
                        mainCategory = id
                        break
                    end
                end
            end
        end
        
        -- Only register if we have a valid category
        if type(mainCategory) == "table" and mainCategory.AddSubcategory then
            local supportCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, addon.supportPanel, addon.supportPanel.name or "Support")
            if supportCategory then
                addon.supportCategory = supportCategory
                addon.supportCategory.ID = addon.supportPanel.name or "Support"
            end
        end
    end
    
    -- Mark as initialized
    initializedAddons[addon.name] = true
    
    return true
end

-- Track if all addons have been initialized
local allInitialized = false

-- Method to get all registered addons
function SupportUI:GetRegisteredAddons()
    return registeredAddons
end

-- Try a direct approach to register an addon with the Settings UI
function SupportUI:DirectRegisterAddon(addon)
    if not addon or not addon.name then return false end
    
    -- Check if Settings API is available
    if not Settings then 
        -- Try again later
        C_Timer.After(1, function() self:DirectRegisterAddon(addon) end)
        return false
    end
    
    -- Use the most direct and straightforward approach
    
    -- Step 1: Create a panel frame
    local panel = CreateFrame("Frame")
    panel.name = addon.name
    
    -- Step 2: Set required callbacks
    panel.OnRefresh = function() end
    panel.OnCommit = function() end
    panel.OnDefault = function() end
    
    -- Step 3: Register with Settings UI
    if not Settings.RegisterCanvasLayoutCategory or not Settings.RegisterAddOnCategory then
        C_Timer.After(1, function() self:DirectRegisterAddon(addon) end)
        return false
    end
    
    -- Register the panel and get the category
    local category = Settings.RegisterCanvasLayoutCategory(panel, addon.name)
    if not category then
        return false
    end
    
    -- Step 4: Make it visible in Options > Addons
    Settings.RegisterAddOnCategory(category)
    
    -- Store the category in the addon
    addon.mainCategory = category
    addon.mainPanel = panel
    
    -- Attempt to register any existing config panel as subcategory
    if addon.ConfigUI and addon.ConfigUI.panel then
        local configPanel = addon.ConfigUI.panel
        
        local configCategory = Settings.RegisterCanvasLayoutSubcategory(category, configPanel, configPanel.name or "Settings")
        if configCategory then
            addon.configCategory = configCategory
        end
    end
    
    -- Attempt to register any existing support panel as subcategory
    if addon.SupportUI then
        -- If we have a pre-made support panel
        if addon.supportPanel then
            local supportCategory = Settings.RegisterCanvasLayoutSubcategory(category, addon.supportPanel, addon.supportPanel.name or "Support")
            if supportCategory then
                addon.supportCategory = supportCategory
            end
        else
            -- Create a support panel if none exists
            -- Directly create a simple support panel since CreateSupportPanel might not be defined
            local supportPanel = CreateFrame("Frame")
            supportPanel.name = "Support"
            
            -- Add background 
            local largeIcon = supportPanel:CreateTexture(nil, "BACKGROUND")
            largeIcon:SetTexture("Interface\\AddOns\\" .. addon.name .. "\\src\\Media\\Icon")
            largeIcon:SetPoint("TOPLEFT", supportPanel, "TOPLEFT", 0, 0)
            largeIcon:SetPoint("BOTTOMRIGHT", supportPanel, "BOTTOMRIGHT", 0, 0)
            largeIcon:SetAlpha(ICON_ALPHA)
            
            -- Add title
            local titleText = supportPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
            titleText:SetPoint("TOPLEFT", 16, -16)
            titleText:SetText("Support " .. addon.name)
            
            -- Required callbacks
            supportPanel.OnRefresh = function() end
            supportPanel.OnCommit = function() end
            supportPanel.OnDefault = function() end
            
            -- Register as subcategory
            local supportCategory = Settings.RegisterCanvasLayoutSubcategory(category, supportPanel, "Support")
            if supportCategory then
                addon.supportCategory = supportCategory
                addon.supportPanel = supportPanel
            end
        end
    end
    
    return true
end

-- Initialize all registered addons' support UIs
function SupportUI:InitializeAll()
    -- Only run once
    if allInitialized then
        return
    end
    
    -- Skip normal initialization and use direct approach for all addons
    -- This provides the most reliable way to register with Settings
    C_Timer.After(0.5, function()
        for addonName, addon in pairs(registeredAddons) do
            self:DirectRegisterAddon(addon)
        end
    end)
    
    allInitialized = true
end

return SupportUI