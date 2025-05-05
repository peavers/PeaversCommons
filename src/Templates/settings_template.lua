-- SETTINGS TEMPLATE FOR ADDONS
-- This file shows how to use the new centralized SettingsUI system

-- Example implementation for an addon's Main.lua initialization section:

-- Inside addon's initialization function (Events:Init)
PeaversCommons.Events:Init(addonName, function()
    -- Initialize core addon functionality
    YourAddon:Initialize()
    
    -- Other initialization steps...
    
    -- Use the centralized SettingsUI system from PeaversCommons
    C_Timer.After(0.5, function()
        -- Create standardized settings pages
        PeaversCommons.SettingsUI:CreateSettingsPages(
            YourAddon,               -- Addon reference
            "YourAddonName",         -- Addon name (as it appears in .toc)
            "Your Addon Title",      -- Display title
            "Description of what your addon does.", -- Short description
            {   -- Slash commands (each as a separate string)
                "/cmd - Main command",
                "/cmd option - Do something",
                "/cmd help - Show help"
            }
        )
    end)
end, {
    announceMessage = "Your addon loaded message here"
})

-- BENEFITS:
-- 1. Eliminates duplicate UI code
-- 2. Automatically integrates with Patrons system
-- 3. Consistent look and feel
-- 4. Centralized maintenance

-- IMPORTANT:
-- You no longer need to include Patrons.lua or initiate the Patrons module
-- The centralized system handles all patron integration automatically