# PeaversCommons

Common library for Peavers addons.

## Features

- Standardized event handling
- Consistent slash command registration
- Utility functions
- Common UI components

## Usage

1. Add this addon as a dependency in your .toc file:

```
## Dependencies: PeaversCommons
```

2. Access the library in your addon code:

```lua
-- In your Main.lua or other core files
local addonName, MyAddon = ...
local PeaversCommons = _G.PeaversCommons

-- Register slash commands
PeaversCommons.SlashCommands:Register(addonName, "myslash", {
    default = function()
        -- Your default command handler
    end,
    config = function()
        -- Open configuration
    end
})

-- Initialize addon
PeaversCommons.Events:Init(addonName, function()
    -- Initialize your addon components
    
    -- Register events
    PeaversCommons.Events:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        -- Your event handler
    end)
    
    -- Set up update timers
    PeaversCommons.Events:RegisterOnUpdate(0.5, function(elapsed)
        -- Do something periodically
    end, "MyAddon_Update")
end)
```

## Event Handling

```lua
-- Register an event
PeaversCommons.Events:RegisterEvent("EVENT_NAME", function(event, ...)
    -- Handle event
end)

-- Unregister an event
PeaversCommons.Events:UnregisterEvent("EVENT_NAME")

-- Register OnUpdate handler
PeaversCommons.Events:RegisterOnUpdate(interval, handler, "unique_key")

-- Unregister OnUpdate handler
PeaversCommons.Events:UnregisterOnUpdate("unique_key")
```

## Slash Commands

```lua
-- Register slash commands
PeaversCommons.SlashCommands:Register(addonName, "cmd", {
    default = function()
        -- Default command with no args
    end,
    config = function()
        -- Called when user types "/cmd config"
    end,
    help = function()
        -- Called when user types "/cmd help"
        -- Also called when an unrecognized subcommand is used
    end
})

-- Add a new command handler later
PeaversCommons.SlashCommands:AddCommand("cmd", "newcmd", function()
    -- This will be called when user types "/cmd newcmd"
end)
```

## Utility Functions

```lua
-- Debug messages (only shown if addon.Config.DEBUG_ENABLED is true)
PeaversCommons.Utils.Debug(addon, "Debug message")

-- User-facing messages
PeaversCommons.Utils.Print(addon, "User message")

-- Data manipulation
local copy = PeaversCommons.Utils.DeepCopy(table)
local merged = PeaversCommons.Utils.MergeDefaults(target, defaults)

-- Number formatting (adds K, M suffixes)
local formatted = PeaversCommons.Utils.FormatNumber(1234567) -- "1.2M"

-- Player information
local playerInfo = PeaversCommons.Utils.GetPlayerInfo()
-- Returns name, realm, fullName, class, level
```