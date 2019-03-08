local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("MarkerIcon", function(self, parent, width, height, marker)
    local button = CreateFrame('Button', nil, parent, UIPanelButtonTemplate);
    self:InitWidget(button);
    self:SetObjSize(button, width, height);

    button.selected = false
    button.marker = marker

    local icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon = icon
    icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. marker)
    icon:SetBlendMode("ADD")
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)

    function button:SetMarker(marker)
        button.marker = marker
        icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. marker)
    end

    function button:GetMarker()
        return button.marker
    end

    function button:Selected()
        button.selected = true
        SetDesaturation(button.icon, false)
        icon:SetVertexColor(1, 1, 1)

        parent:Selected(marker)
    end

    function button:Deselected()
        button.selected = false
        SetDesaturation(button.icon, true)
        icon:SetVertexColor(0.5, 0.5, 0.5)
    end

    function button:IsSelected()
        return button.selected
    end

    button:SetScript("OnClick", function()
        if button.selected then
            button:Deselected()
        else
            button:Selected()
        end

    end)

    button:Deselected()

    return button
end)