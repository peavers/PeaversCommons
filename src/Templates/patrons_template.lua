-- Template file for adding patrons support to addons
local addonName, ADDON_NAMESPACE = ...

-- Initialize Patrons namespace
local Patrons = {}
ADDON_NAMESPACE.Patrons = Patrons

-- Function to initialize patrons support
function Patrons:Initialize()
    -- Ensure PeaversCommons is loaded
    if not _G.PeaversCommons or not _G.PeaversCommons.Patrons then
        -- PeaversCommons or its Patrons module not loaded
        return false
    end
    
    -- Add patrons display to this addon's support UI
    if ADDON_NAMESPACE.supportPanel and _G.PeaversCommons.PatronsUI then
        _G.PeaversCommons.PatronsUI:AddToSupportPanel(ADDON_NAMESPACE)
    end
    
    return true
end

-- Function to access shared patrons list
function Patrons:GetAll()
    if not _G.PeaversCommons or not _G.PeaversCommons.Patrons then
        return {}
    end
    
    return _G.PeaversCommons.Patrons:GetAll()
end

-- Function to get sorted patrons
function Patrons:GetSorted()
    if not _G.PeaversCommons or not _G.PeaversCommons.Patrons then
        return {}
    end
    
    return _G.PeaversCommons.Patrons:GetSorted()
end

-- Function to get patrons by tier
function Patrons:GetByTier(tier)
    if not _G.PeaversCommons or not _G.PeaversCommons.Patrons then
        return {}
    end
    
    return _G.PeaversCommons.Patrons:GetByTier(tier)
end

-- Return the module
return Patrons