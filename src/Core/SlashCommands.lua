-- PeaversCommons SlashCommands Module
local PeaversCommons = _G.PeaversCommons
local SlashCommands = PeaversCommons.SlashCommands

-- Table to store all command handlers
local commandHandlers = {}

-- Register slash commands for an addon
function SlashCommands:Register(addonName, commandPrefix, handlers)
    -- Create a global slash command list entry
    local slashName = string.upper(commandPrefix)
    
    -- Register the slash command
    _G["SLASH_" .. slashName .. "1"] = "/" .. string.lower(commandPrefix)
    
    -- Store handlers for this command
    commandHandlers[slashName] = handlers or {}
    
    -- Set default handlers if not provided
    if not commandHandlers[slashName].config then
        commandHandlers[slashName].config = function()
            if Settings and Settings.OpenToCategory then
                Settings.OpenToCategory(addonName)
            elseif InterfaceOptionsFrame_OpenToCategory then
                InterfaceOptionsFrame_OpenToCategory(addonName)
            end
        end
    end
    
    if not commandHandlers[slashName].help then
        commandHandlers[slashName].help = function()
            print("|cFF00FF00" .. addonName .. " Commands:|r")
            print("  |cFFFFFF00/", string.lower(commandPrefix), "config|r - Open configuration")
            
            for cmd, _ in pairs(commandHandlers[slashName]) do
                if cmd ~= "config" and cmd ~= "help" then
                    print("  |cFFFFFF00/", string.lower(commandPrefix), cmd, "|r")
                end
            end
        end
    end
    
    -- Create the slash command handler
    SlashCmdList[slashName] = function(msg)
        local command, rest = msg:match("^(%S*)%s*(.-)$")
        command = command:lower()
        
        if commandHandlers[slashName][command] then
            commandHandlers[slashName][command](rest)
        elseif command == "" and commandHandlers[slashName].default then
            commandHandlers[slashName].default()
        else
            commandHandlers[slashName].help()
        end
    end
end

-- Add a new command handler
function SlashCommands:AddCommand(slashName, command, handler)
    slashName = string.upper(slashName)
    if commandHandlers[slashName] then
        commandHandlers[slashName][command:lower()] = handler
    end
end

return SlashCommands