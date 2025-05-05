-- PeaversCommons Config Manager Module
local PeaversCommons = _G.PeaversCommons
local ConfigManager = {}
PeaversCommons.ConfigManager = ConfigManager

-- Reference to other modules
local Utils = PeaversCommons.Utils

-- Create a new config manager for an addon
function ConfigManager:New(addon, defaultSettings, options)
    local config = {}
    
    -- Fix parameter order confusion - this handles the case where addon configs may
    -- have passed options as the defaultSettings parameter
    if type(defaultSettings) == "table" and defaultSettings.savedVariablesName then
        -- It looks like defaultSettings is actually options
        options = defaultSettings
        defaultSettings = {}
    end
    
    -- Ensure options is a table
    options = options or {}
    
    -- Store references
    config.addon = addon
    config.defaults = defaultSettings or {}
    
    -- Determine database name
    local addonName
    if type(addon) == "string" then
        addonName = addon
    elseif type(addon) == "table" and addon.name then
        addonName = addon.name
    else
        error("ConfigManager:New - Invalid addon argument. Must be a string or table with name field")
    end
    
    -- Set the database name
    config.dbName = options.savedVariablesName or (addonName .. "DB")
    config.settingsKey = options.settingsKey -- Optional settings key for backward compatibility
    config.DEBUG_ENABLED = false
    
    -- Initialize with defaults
    for k, v in pairs(config.defaults) do
        config[k] = v
    end
    
    -- Save configuration to SavedVariables
    function config:Save()
        -- Initialize the database if it doesn't exist
        if not _G[self.dbName] then
            _G[self.dbName] = {}
        end
        
        -- Determine where to save settings
        local targetTable
        if self.settingsKey then
            -- Save to a specific key (for backward compatibility)
            if not _G[self.dbName][self.settingsKey] then
                _G[self.dbName][self.settingsKey] = {}
            end
            targetTable = _G[self.dbName][self.settingsKey]
        else
            -- Save directly to the DB
            targetTable = _G[self.dbName]
        end
        
        -- Save all settings
        for k, v in pairs(self) do
            -- Only save actual settings (skip functions and internal properties)
            if type(v) ~= "function" and k ~= "addon" and k ~= "dbName" and 
               k ~= "defaults" and k ~= "settingsKey" then
                targetTable[k] = v
            end
        end
        
        return true
    end
    
    -- Load configuration from SavedVariables
    function config:Load()
        -- If database doesn't exist, initialize it
        if not _G[self.dbName] then
            _G[self.dbName] = {}
            return false
        end
        
        -- Determine where to load settings from
        local sourceTable
        if self.settingsKey then
            -- Load from a specific key (for backward compatibility)
            if not _G[self.dbName][self.settingsKey] then
                _G[self.dbName][self.settingsKey] = {}
                return false
            end
            sourceTable = _G[self.dbName][self.settingsKey]
        else
            -- Load directly from the DB
            sourceTable = _G[self.dbName]
        end
        
        -- Load all settings
        for k, v in pairs(sourceTable) do
            self[k] = v
        end
        
        return true
    end
    
    -- Reset to defaults
    function config:Reset()
        -- Reset to defaults
        for k, v in pairs(self.defaults) do
            self[k] = v
        end
        
        -- Save to database
        self:Save()
        
        return true
    end
    
    -- Initialize the configuration
    function config:Initialize()
        -- Load existing settings
        self:Load()
        
        -- Ensure all defaults exist (for new settings)
        for k, v in pairs(self.defaults) do
            if self[k] == nil then
                self[k] = v
            end
        end
        
        -- Save to ensure any new defaults are saved
        self:Save()
        
        return true
    end
    
    -- Update a specific setting
    function config:UpdateSetting(key, value)
        if key then
            -- Update the setting
            self[key] = value
            
            -- Save the changes
            self:Save()
            
            return true
        end
        
        return false
    end
    
    -- Get a setting with default fallback
    function config:GetSetting(key, default)
        if self[key] ~= nil then
            return self[key]
        else
            return default
        end
    end
    
    -- Toggle a boolean setting
    function config:ToggleSetting(key)
        if key and type(self[key]) == "boolean" then
            self[key] = not self[key]
            self:Save()
            return self[key]
        end
        
        return nil
    end
    
    return config
end

-- Create a profile-based config manager
function ConfigManager:NewProfileBased(addon, defaultSettings, options)
    -- Fix parameter order confusion
    if type(defaultSettings) == "table" and defaultSettings.savedVariablesName then
        -- It looks like defaultSettings is actually options
        options = defaultSettings
        defaultSettings = {}
    end
    
    -- Ensure options is a table
    options = options or {}
    
    local config = self:New(addon, defaultSettings, options)
    
    -- Add profile support
    config.currentProfile = "Default"
    config.profiles = config.profiles or {}
    
    -- Override the Save function to save by profile
    local originalSave = config.Save
    function config:Save()
        -- Initialize the database if it doesn't exist
        if not _G[self.dbName] then
            _G[self.dbName] = {
                profiles = {},
                currentProfile = self.currentProfile
            }
        end
        
        -- Ensure profiles container exists
        if not _G[self.dbName].profiles then
            _G[self.dbName].profiles = {}
        end
        
        -- Initialize current profile if needed
        if not _G[self.dbName].profiles[self.currentProfile] then
            _G[self.dbName].profiles[self.currentProfile] = {}
        end
        
        -- Save profile selection
        _G[self.dbName].currentProfile = self.currentProfile
        
        -- Save all settings to the current profile
        for k, v in pairs(self) do
            -- Only save actual settings (skip functions and internal properties)
            if type(v) ~= "function" and k ~= "addon" and k ~= "dbName" and k ~= "defaults" 
               and k ~= "profiles" and k ~= "currentProfile" then
                _G[self.dbName].profiles[self.currentProfile][k] = v
            end
        end
        
        return true
    end
    
    -- Override the Load function to load by profile
    local originalLoad = config.Load
    function config:Load()
        -- If database doesn't exist, return
        if not _G[self.dbName] then
            return false
        end
        
        -- Get the current profile name
        self.currentProfile = _G[self.dbName].currentProfile or "Default"
        
        -- If the profile doesn't exist, create it
        if not _G[self.dbName].profiles or not _G[self.dbName].profiles[self.currentProfile] then
            -- Initialize profiles container if needed
            if not _G[self.dbName].profiles then
                _G[self.dbName].profiles = {}
            end
            
            -- Create the profile
            _G[self.dbName].profiles[self.currentProfile] = {}
            
            -- Return false to indicate profile didn't exist
            return false
        end
        
        -- Load all settings from the current profile
        for k, v in pairs(_G[self.dbName].profiles[self.currentProfile]) do
            self[k] = v
        end
        
        -- Store available profiles
        self.profiles = Utils.TableKeys(_G[self.dbName].profiles)
        
        return true
    end
    
    -- Add profile management functions
    
    -- Switch to a different profile
    function config:SwitchProfile(profileName)
        if not profileName or profileName == "" then
            return false
        end
        
        -- Save current profile
        self:Save()
        
        -- Switch to the new profile
        self.currentProfile = profileName
        
        -- Load the new profile (or create it if it doesn't exist)
        self:Load()
        
        -- If the profile didn't exist, apply defaults and save
        if not _G[self.dbName].profiles[profileName] then
            for k, v in pairs(self.defaults) do
                self[k] = v
            end
            
            self:Save()
        end
        
        return true
    end
    
    -- Create a new profile
    function config:CreateProfile(profileName)
        if not profileName or profileName == "" then
            return false
        end
        
        -- Save current profile
        self:Save()
        
        -- Create the new profile with defaults
        self.currentProfile = profileName
        
        -- Reset to defaults
        for k, v in pairs(self.defaults) do
            self[k] = v
        end
        
        -- Save the new profile
        self:Save()
        
        -- Update profiles list
        self.profiles = self.profiles or {}
        if not Utils.TableContains(self.profiles, profileName) then
            table.insert(self.profiles, profileName)
        end
        
        return true
    end
    
    -- Delete a profile
    function config:DeleteProfile(profileName)
        if not profileName or profileName == "" or profileName == "Default" then
            return false
        end
        
        -- Cannot delete the current profile
        if profileName == self.currentProfile then
            return false
        end
        
        -- If database doesn't exist, return
        if not _G[self.dbName] or not _G[self.dbName].profiles then
            return false
        end
        
        -- Remove the profile
        _G[self.dbName].profiles[profileName] = nil
        
        -- Update profiles list
        self.profiles = Utils.TableKeys(_G[self.dbName].profiles)
        
        return true
    end
    
    -- Return the config manager
    return config
end

return ConfigManager