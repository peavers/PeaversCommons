-- PeaversCommons Core
local MAJOR, MINOR = "PeaversCommons-1.0", 1
local PeaversCommons = LibStub and LibStub:NewLibrary(MAJOR, MINOR) or {}

if not PeaversCommons then return end -- Already loaded and no upgrade necessary

-- Initialize the addon
PeaversCommons.name = "PeaversCommons"
PeaversCommons.version = MAJOR .. "." .. MINOR

-- Initialize modules
PeaversCommons.Events = {}
PeaversCommons.SlashCommands = {}
PeaversCommons.Utils = {}
PeaversCommons.SupportUI = {}
PeaversCommons.Patrons = {}
PeaversCommons.PatronsUI = {}

-- Make the addon global
_G.PeaversCommons = PeaversCommons

-- Return the addon
return PeaversCommons