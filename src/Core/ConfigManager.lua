local PeaversCommons = _G.PeaversCommons
local ConfigManager = {}
PeaversCommons.ConfigManager = ConfigManager

local Utils = PeaversCommons.Utils

function ConfigManager:New(addon, defaultSettings, options)
    local config = {}
    
    if type(defaultSettings) == "table" and defaultSettings.savedVariablesName then
        options = defaultSettings
        defaultSettings = {}
    end
    
    options = options or {}
    
    config.addon = addon
    config.defaults = defaultSettings or {}
    
    local addonName
    if type(addon) == "string" then
        addonName = addon
    elseif type(addon) == "table" and addon.name then
        addonName = addon.name
    else
        error("ConfigManager:New - Invalid addon argument. Must be a string or table with name field")
    end
    
    config.dbName = options.savedVariablesName or (addonName .. "DB")
    config.settingsKey = options.settingsKey
    config.DEBUG_ENABLED = false
    
    for k, v in pairs(config.defaults) do
        config[k] = v
    end
    
    function config:Save()
        if not _G[self.dbName] then
            _G[self.dbName] = {}
        end
        
        local targetTable
        if self.settingsKey then
            if not _G[self.dbName][self.settingsKey] then
                _G[self.dbName][self.settingsKey] = {}
            end
            targetTable = _G[self.dbName][self.settingsKey]
        else
            targetTable = _G[self.dbName]
        end
        
        for k, v in pairs(self) do
            if type(v) ~= "function" and k ~= "addon" and k ~= "dbName" and 
               k ~= "defaults" and k ~= "settingsKey" then
                targetTable[k] = v
            end
        end
        
        return true
    end
    
    function config:Load()
        if not _G[self.dbName] then
            _G[self.dbName] = {}
            return false
        end
        
        local sourceTable
        if self.settingsKey then
            if not _G[self.dbName][self.settingsKey] then
                _G[self.dbName][self.settingsKey] = {}
                return false
            end
            sourceTable = _G[self.dbName][self.settingsKey]
        else
            sourceTable = _G[self.dbName]
        end
        
        for k, v in pairs(sourceTable) do
            self[k] = v
        end
        
        return true
    end
    
    function config:Reset()
        for k, v in pairs(self.defaults) do
            self[k] = v
        end
        
        self:Save()
        
        return true
    end
    
    function config:Initialize()
        self:Load()
        
        for k, v in pairs(self.defaults) do
            if self[k] == nil then
                self[k] = v
            end
        end
        
        self:Save()
        
        return true
    end
    
    function config:UpdateSetting(key, value)
        if key then
            self[key] = value
            self:Save()
            return true
        end
        
        return false
    end
    
    function config:GetSetting(key, default)
        if self[key] ~= nil then
            return self[key]
        else
            return default
        end
    end
    
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

function ConfigManager:NewProfileBased(addon, defaultSettings, options)
    if type(defaultSettings) == "table" and defaultSettings.savedVariablesName then
        options = defaultSettings
        defaultSettings = {}
    end
    
    options = options or {}
    
    local config = self:New(addon, defaultSettings, options)
    
    config.currentProfile = "Default"
    config.profiles = config.profiles or {}
    
    local originalSave = config.Save
    function config:Save()
        if not _G[self.dbName] then
            _G[self.dbName] = {
                profiles = {},
                currentProfile = self.currentProfile
            }
        end
        
        if not _G[self.dbName].profiles then
            _G[self.dbName].profiles = {}
        end
        
        if not _G[self.dbName].profiles[self.currentProfile] then
            _G[self.dbName].profiles[self.currentProfile] = {}
        end
        
        _G[self.dbName].currentProfile = self.currentProfile
        
        for k, v in pairs(self) do
            if type(v) ~= "function" and k ~= "addon" and k ~= "dbName" and k ~= "defaults" 
               and k ~= "profiles" and k ~= "currentProfile" then
                _G[self.dbName].profiles[self.currentProfile][k] = v
            end
        end
        
        return true
    end
    
    local originalLoad = config.Load
    function config:Load()
        if not _G[self.dbName] then
            return false
        end
        
        self.currentProfile = _G[self.dbName].currentProfile or "Default"
        
        if not _G[self.dbName].profiles or not _G[self.dbName].profiles[self.currentProfile] then
            if not _G[self.dbName].profiles then
                _G[self.dbName].profiles = {}
            end
            
            _G[self.dbName].profiles[self.currentProfile] = {}
            
            return false
        end
        
        for k, v in pairs(_G[self.dbName].profiles[self.currentProfile]) do
            self[k] = v
        end
        
        self.profiles = Utils.TableKeys(_G[self.dbName].profiles)
        
        return true
    end
    
    function config:SwitchProfile(profileName)
        if not profileName or profileName == "" then
            return false
        end
        
        self:Save()
        self.currentProfile = profileName
        self:Load()
        
        if not _G[self.dbName].profiles[profileName] then
            for k, v in pairs(self.defaults) do
                self[k] = v
            end
            
            self:Save()
        end
        
        return true
    end
    
    function config:CreateProfile(profileName)
        if not profileName or profileName == "" then
            return false
        end
        
        self:Save()
        self.currentProfile = profileName
        
        for k, v in pairs(self.defaults) do
            self[k] = v
        end
        
        self:Save()
        
        self.profiles = self.profiles or {}
        if not Utils.TableContains(self.profiles, profileName) then
            table.insert(self.profiles, profileName)
        end
        
        return true
    end
    
    function config:DeleteProfile(profileName)
        if not profileName or profileName == "" or profileName == "Default" then
            return false
        end
        
        if profileName == self.currentProfile then
            return false
        end
        
        if not _G[self.dbName] or not _G[self.dbName].profiles then
            return false
        end
        
        _G[self.dbName].profiles[profileName] = nil
        self.profiles = Utils.TableKeys(_G[self.dbName].profiles)
        
        return true
    end
    
    return config
end

return ConfigManager