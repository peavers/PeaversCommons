local addonName, ADDON_NAMESPACE = ...

local ConfigUI = {}
ADDON_NAMESPACE.ConfigUI = ConfigUI

function ConfigUI:InitializeOptions()
    return nil
end

function ConfigUI:Initialize()
    self:InitializeOptions()
end