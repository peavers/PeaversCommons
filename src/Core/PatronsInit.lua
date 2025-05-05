local PeaversCommons = _G.PeaversCommons
local Patrons = PeaversCommons.Patrons

local function InitializePatrons()
    if not Patrons or not Patrons.AddPatrons then
        return false
    end

    Patrons:AddPatrons({
        "Kyrshiro - Kel'Thuzad",
        "Plunger - Kel'Thuzad",
    })

    return true
end

InitializePatrons()

return InitializePatrons