-- PeaversCommons Events Module
local PeaversCommons = _G.PeaversCommons
local Events = PeaversCommons.Events

-- Get reference to Utils
local Utils = PeaversCommons.Utils

-- Create a frame for events
local eventFrame = CreateFrame("Frame")
local registeredEvents = {}
local eventHandlers = {}

-- Function to register an event
function Events:RegisterEvent(event, handler)
    if not registeredEvents[event] then
        registeredEvents[event] = true
        eventFrame:RegisterEvent(event)
    end
    
    if handler then
        if not eventHandlers[event] then
            eventHandlers[event] = {}
        end
        table.insert(eventHandlers[event], handler)
    end
end

-- Function to unregister an event
function Events:UnregisterEvent(event, handler)
    if handler and eventHandlers[event] then
        for i, registeredHandler in ipairs(eventHandlers[event]) do
            if registeredHandler == handler then
                table.remove(eventHandlers[event], i)
                break
            end
        end
        
        if #eventHandlers[event] == 0 then
            eventHandlers[event] = nil
            registeredEvents[event] = nil
            eventFrame:UnregisterEvent(event)
        end
    else
        eventHandlers[event] = nil
        registeredEvents[event] = nil
        eventFrame:UnregisterEvent(event)
    end
end

-- Event dispatcher
local function OnEvent(self, event, ...)
    if eventHandlers[event] then
        for _, handler in ipairs(eventHandlers[event]) do
            handler(event, ...)
        end
    end
end

-- Register the OnEvent handler
eventFrame:SetScript("OnEvent", OnEvent)

-- Setup OnUpdate functionality
local updateHandlers = {}
local updateTimers = {}

-- Function to register an update handler
function Events:RegisterOnUpdate(interval, handler, key)
    key = key or handler
    updateHandlers[key] = handler
    updateTimers[key] = {
        interval = interval,
        elapsed = 0
    }
    
    -- Start OnUpdate if it's not already running
    eventFrame:SetScript("OnUpdate", OnUpdate)
end

-- Function to unregister an update handler
function Events:UnregisterOnUpdate(key)
    updateHandlers[key] = nil
    updateTimers[key] = nil
    
    -- If no more handlers, stop OnUpdate
    if not next(updateTimers) then
        eventFrame:SetScript("OnUpdate", nil)
    end
end

-- OnUpdate handler
local function OnUpdate(self, elapsed)
    for key, timer in pairs(updateTimers) do
        timer.elapsed = timer.elapsed + elapsed
        if timer.elapsed >= timer.interval then
            if updateHandlers[key] then
                updateHandlers[key](timer.elapsed)
            end
            timer.elapsed = 0
        end
    end
end

-- Function to announce addon loaded
function Events:AnnounceLoaded(addon, customMessage)
    local Utils = PeaversCommons.Utils
    
    -- Default message if none provided
    local message = customMessage or "Addon loaded"
    
    -- Register for PLAYER_ENTERING_WORLD to announce addon loaded
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        Utils.Print(addon, message)
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end)
end

-- Function to register addon with the SupportUI system
function Events:RegisterAddonForSupport(addon)
    -- Create SupportUI table if it doesn't exist
    if not PeaversCommons.SupportUI then
        PeaversCommons.SupportUI = {}
    end
    
    -- Always use the pendingRegistrations approach to be safe
    if not PeaversCommons.SupportUI._pendingRegistrations then
        PeaversCommons.SupportUI._pendingRegistrations = {}
    end
    
    -- Add the addon to the pending registrations queue
    table.insert(PeaversCommons.SupportUI._pendingRegistrations, addon)
    return true
end

-- Setup initialization with automatic announcements and support UI
function Events:Init(addonName, initCallback, options)
    options = options or {}
    local announceMessage = options.announceMessage
    local suppressAnnouncement = options.suppressAnnouncement
    local suppressSupportUI = options.suppressSupportUI
    
    -- Track if this addon has been initialized already
    local addonInitialized = false
    
    -- Check if PeaversCommons itself is being initialized
    if addonName == "PeaversCommons" then
        -- Initialize Config module
        if PeaversCommons.Config and PeaversCommons.Config.Initialize then
            PeaversCommons.Config:Initialize()
        end
    end
    
    self:RegisterEvent("ADDON_LOADED", function(event, loadedAddon)
        if loadedAddon == addonName and not addonInitialized then
            addonInitialized = true
            
            -- Get the addon object - either from _G or create a basic one
            local addon = _G[addonName] or { name = addonName }
            
            -- Make sure addon has minimum properties needed
            if not addon.name then addon.name = addonName end
            
            -- Initialized
            
            -- Register with the SupportUI system if not suppressed
            if not suppressSupportUI then
                self:RegisterAddonForSupport(addon)
            end
            
            -- Call the addon's initialization callback
            if initCallback then
                initCallback()
            end
            
            -- Initialize SupportUI for this addon if enabled
            -- Note: We'll let the PLAYER_ENTERING_WORLD event handle this now
            -- to ensure all addons are registered before initialization
            
            -- Auto-announce the addon is loaded (unless suppressed)
            if not suppressAnnouncement then
                self:AnnounceLoaded(addon, ": " ..  announceMessage)
            end
            
            self:UnregisterEvent("ADDON_LOADED")
        end
    end)
    
    -- Register a handler to initialize all SupportUIs once during PLAYER_ENTERING_WORLD
    local initialized = false
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        if not initialized then
            -- Delay initialization to ensure all addons are loaded and Settings API is available
            C_Timer.After(0.5, function()
                -- Process any remaining addon registrations
                if PeaversCommons.SupportUI then
                    -- Use InitializeAll if available (should always be the case)
                    if type(PeaversCommons.SupportUI.InitializeAll) == "function" then
                        PeaversCommons.SupportUI:InitializeAll()
                        
                        -- Initialize PatronsUI for all addons after SupportUI is initialized
                        C_Timer.After(0.5, function()
                            if PeaversCommons.PatronsUI and PeaversCommons.PatronsUI.InitializeForAllAddons then
                                PeaversCommons.PatronsUI:InitializeForAllAddons()
                            end
                        end)
                    end
                end
            end)
            initialized = true
        end
    end)
end

return Events