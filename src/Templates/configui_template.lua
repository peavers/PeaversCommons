local addonName, ADDON_NAMESPACE = ...

local ConfigUI = {}
ADDON_NAMESPACE.ConfigUI = ConfigUI

-- Create the options panel for this addon
function ConfigUI:InitializeOptions()
    -- No need to manually create the main panel anymore
    -- PeaversCommons SupportUI will handle this automatically
    
    -- Add any specific configuration options for this addon here
    -- For example, you could add options to toggle features, adjust settings, etc.
    
    return nil
end

function ConfigUI:Initialize()
    self:InitializeOptions()
end