local addonName, ADDON_NAMESPACE = ...

-- Initialize SupportUI namespace - empty placeholder to preserve compatibility
local SupportUI = {}
ADDON_NAMESPACE.SupportUI = SupportUI

-- No initialization needed - PeaversCommons now handles this automatically
function SupportUI:Initialize()
    -- This function is left as a placeholder for backward compatibility
    -- PeaversCommons Events module now handles SupportUI initialization
end

-- This function is left as a placeholder for backward compatibility
function SupportUI:InitializeOptions()
    return nil
end