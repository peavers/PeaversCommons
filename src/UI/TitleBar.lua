local MAJOR, MINOR = "PeaversCommons-1.0", 3
local PeaversCommons = LibStub and LibStub(MAJOR) or {}

-- Initialize TitleBar namespace
PeaversCommons.TitleBar = {}
local TitleBar = PeaversCommons.TitleBar

-- Creates the title bar with text and version display
function TitleBar:Create(parent, config)
    local titleBar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    titleBar:SetHeight(20)
    titleBar:SetWidth(parent:GetWidth())
    titleBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    
    -- Set backdrop
    titleBar:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
    })
    
    if config.bgColor and config.bgAlpha then
        titleBar:SetBackdropColor(
            config.bgColor.r, 
            config.bgColor.g, 
            config.bgColor.b, 
            config.bgAlpha
        )
        titleBar:SetBackdropBorderColor(0, 0, 0, 1)
    else
        titleBar:SetBackdropColor(0, 0, 0, 0.8)
        titleBar:SetBackdropBorderColor(0, 0, 0, 1)
    end
    
    -- Title text
    local titleText = titleBar:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(config.fontFace or "Fonts\\FRIZQT__.TTF", 
                      config.fontSize or 12, 
                      config.fontOutline or "OUTLINE")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 5, 0)
    titleText:SetText(config.title or "Untitled")
    titleText:SetTextColor(1, 1, 1, 1)
    
    if config.fontShadow then
        titleText:SetShadowOffset(1, -1)
        titleText:SetShadowColor(0, 0, 0, 1)
    end
    
    titleBar.titleText = titleText
    
    -- Version text
    local versionText = titleBar:CreateFontString(nil, "OVERLAY")
    versionText:SetFont(config.fontFace or "Fonts\\FRIZQT__.TTF", 
                        (config.fontSize or 12) - 2, 
                        config.fontOutline or "OUTLINE")
    versionText:SetPoint("RIGHT", titleBar, "RIGHT", -5, 0)
    versionText:SetText("v" .. (config.version or "0.0.0"))
    versionText:SetTextColor(0.7, 0.7, 0.7, 1)
    
    if config.fontShadow then
        versionText:SetShadowOffset(1, -1)
        versionText:SetShadowColor(0, 0, 0, 1)
    end
    
    titleBar.versionText = versionText
    
    -- Set script for dragging
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton", "RightButton")
    titleBar:SetScript("OnDragStart", function(self, button)
        if button == "LeftButton" then
            parent:StartMoving()
        end
    end)
    titleBar:SetScript("OnDragStop", function()
        parent:StopMovingOrSizing()
        if parent.OnDragStop then
            parent:OnDragStop()
        end
    end)
    
    -- Store reference to parent
    titleBar.parent = parent
    
    -- Methods
    titleBar.UpdateTitle = function(self, newTitle)
        self.titleText:SetText(newTitle)
    end
    
    titleBar.UpdateVersion = function(self, newVersion)
        self.versionText:SetText("v" .. newVersion)
    end
    
    titleBar.SetColors = function(self, bgColor, bgAlpha)
        if bgColor and bgAlpha then
            self:SetBackdropColor(
                bgColor.r, 
                bgColor.g, 
                bgColor.b, 
                bgAlpha
            )
        end
    end
    
    titleBar.UpdateFont = function(self, fontFace, fontSize, fontOutline, fontShadow)
        self.titleText:SetFont(fontFace, fontSize, fontOutline)
        self.versionText:SetFont(fontFace, fontSize - 2, fontOutline)
        
        if fontShadow then
            self.titleText:SetShadowOffset(1, -1)
            self.titleText:SetShadowColor(0, 0, 0, 1)
            self.versionText:SetShadowOffset(1, -1)
            self.versionText:SetShadowColor(0, 0, 0, 1)
        else
            self.titleText:SetShadowOffset(0, 0)
            self.versionText:SetShadowOffset(0, 0)
        end
    end
    
    titleBar.UpdateWidth = function(self)
        self:SetWidth(self.parent:GetWidth())
    end
    
    return titleBar
end

return TitleBar