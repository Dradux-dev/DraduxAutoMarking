local StdUi = LibStub("StdUi")

local lut = {
    "star",
    "circle",
    "diamond",
    "triangle",
    "moon",
    "square",
    "cross",
    "skull"
}

local dummy_names = {
    "Emzen",
    "Dradux",
    "Arianna",
    "Cothar",
    "Nalta",
    "Dwarvin",
    "Brolarn",
    "Deadly Enemy"
}

StdUi:RegisterWidget("MarkerMonitor", function(self, parent)
    local width = 250
    local height = 250

    local window = StdUi:Window(UIParent, "Dradux Auto Marking - Monitor", width, height)
    function window:Selected()
        -- Ignore
    end

    for marker =8, 1, -1 do
        local t = {}
        local icon = StdUi:MarkerIcon(window, 24, 24, marker)
        t.icon = icon
        icon:SetScript("OnClick", nil)
        icon:Selected()
        StdUi:GlueTop(icon, window, 10, -(((8-marker) * 26) + 35), "LEFT")

        local text = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        t.text = text
        text:SetJustifyH("LEFT")
        text:SetJustifyV("CENTER")
        text:SetTextColor(1, 1, 1, 1)
        text:SetText(dummy_names[marker])
        StdUi:GlueRight(text, icon, 5, 0)


        local lock = window:CreateTexture(nil, "BACKGROUND")
        t.lock = lock
        lock:SetTexture("Interface\\Addons\\DraduxAutoMarking\\media\\lock")
        lock:SetBlendMode("ADD")
        lock:SetPoint("TOPLEFT", icon, "BOTTOMRIGHT", -10, 10)
        lock:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 6, -6)

        window[lut[marker]] = t
    end

    local chargeName = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    window.chargeName = chargeName
    chargeName:SetJustifyH("RIGHT")
    chargeName:SetJustifyV("CENTER")
    chargeName:SetTextColor(1, 1, 1, 1)
    chargeName:SetText("Bludux")
    StdUi:GlueBottom(chargeName, window, -5, 5, "RIGHT")

    local chargeLabel = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    window.chargeLabel = chargeLabel
    chargeLabel:SetJustifyH("RIGHT")
    chargeLabel:SetJustifyV("CENTER")
    chargeLabel:SetTextColor(1, 1, 1, 1)
    chargeLabel:SetText("Charge:")
    StdUi:GlueLeft(chargeLabel, chargeName, -2, 0)

    function window:Update()
        for marker=1, 8 do
            local t = window[lut[marker]]

            if DraduxAutoMarking:IsMarkerFree(marker) then
                t.lock:Hide()
                t.text:SetText("")
            else
                if DraduxAutoMarking:IsMarkerLocked(marker) then
                    t.lock:Show()
                else
                    t.lock:Hide()
                end

                t.text:SetText(DraduxAutoMarking:GetMarkerUnitName(marker))
            end
        end
    end

    function window:SetChargeName(name)
        window.chargeName:SetText(name)
    end

    window:SetScript("OnShow", function()
        window:Update()
    end)

    window:SetScript("OnHide", function()
        -- Save current position
        local db = DraduxAutoMarking:GetDB()
        local anchor, _, anchorTo, xOffset, yOffset = window:GetPoint("TOPLEFT")
        db.monitor = {
            anchor = anchor,
            anchorTo = anchorTo,
            xOffset = xOffset,
            yOffset = yOffset
        }
    end)

    return window
end)