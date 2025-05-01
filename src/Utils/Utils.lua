-- PeaversCommons Utils Module
local PeaversCommons = _G.PeaversCommons
local Utils = PeaversCommons.Utils

-- Debug printing (only when debug is enabled)
function Utils.Debug(addon, ...)
    if addon and addon.Config and addon.Config.DEBUG_ENABLED then
        print("|cFF00FFFF[" .. addon.name .. " Debug]|r", ...)
    end
end

-- User-facing print
function Utils.Print(addon, ...)
    if addon and addon.name then
        print("|cFF00FF00[" .. addon.name .. "]|r", ...)
    else
        print(...)
    end
end

-- Table functions
function Utils.DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Utils.DeepCopy(orig_key)] = Utils.DeepCopy(orig_value)
        end
        setmetatable(copy, Utils.DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function Utils.MergeDefaults(target, defaults)
    if type(target) ~= "table" then target = {} end
    if type(defaults) ~= "table" then return target end
    
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            target[k] = Utils.MergeDefaults(target[k], v)
        elseif target[k] == nil then
            target[k] = v
        end
    end
    
    return target
end

-- Format numbers with commas
function Utils.FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

-- Check if player is in combat
function Utils.IsInCombat()
    return InCombatLockdown() or UnitAffectingCombat("player")
end

-- Get player info
function Utils.GetPlayerInfo()
    local name = UnitName("player")
    local realm = GetRealmName()
    local fullName = name .. "-" .. realm
    local class = select(2, UnitClass("player"))
    local level = UnitLevel("player")
    
    return {
        name = name,
        realm = realm, 
        fullName = fullName,
        class = class,
        level = level
    }
end

return Utils