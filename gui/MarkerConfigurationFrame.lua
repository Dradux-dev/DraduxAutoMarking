local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("MarkerConfigurationFrame", function(self, parent, marker)
    local width = 140
    local height = 22

    local frame = CreateFrame("Frame", nil, parent)
    self:InitWidget(frame)
    self:SetObjSize(frame, width, height)

    local icon = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.icon = icon
    icon:SetJustifyH("CENTER")
    icon:SetJustifyV("MIDDLE")
    icon:SetTextColor(1, 1, 1, 1)
    icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -2)
    icon:SetText("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. marker .. ":16\124t")

    local allowed = StdUi:Checkbox(frame, "", 15, 30)
    frame.allowed = allowed
    local oldClickHandler = allowed:GetScript("OnClick")
    allowed:SetScript("OnClick", function(frame)
        oldClickHandler(frame)
        parent:Changed()
    end)
    StdUi:GlueRight(allowed, icon, 5, 0)

    local priority = StdUi:NumericBox(frame, 100, 18, "0")
    frame.priority = priority
    priority:SetScript("OnEnterPressed", function(self)
        self:Validate()
        parent:Changed()
    end)
    local oldClickHandler = priority.button:GetScript("OnClick")
    priority.button:SetScript("OnClick", function(self)
        oldClickHandler(self)
        parent:Changed()
    end)
    StdUi:GlueRight(priority, allowed, 5, 0)

    return frame
end)