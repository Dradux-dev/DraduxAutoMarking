local StdUi = LibStub("StdUi")

function DraduxAutoMarking:InitializeMonitor()
    local db = DraduxAutoMarking:GetDB()
    DraduxAutoMarking.monitor = StdUi:MarkerMonitor(UIParent)
    DraduxAutoMarking.monitor:SetPoint(db.monitor.anchor, UIParent, db.monitor.anchorTo, db.monitor.xOffset, db.monitor.yOffset)
    DraduxAutoMarking.monitor:Hide()
end

function DraduxAutoMarking:ToggleMonitor()
    if not DraduxAutoMarking.monitor then
        DraduxAutoMarking:InitializeMonitor()
    end

    if DraduxAutoMarking.monitor:IsShown() then
        DraduxAutoMarking.monitor:Hide()
    else
        DraduxAutoMarking.monitor:Show()
    end
end

function DraduxAutoMarking:UpdateMonitor()
    if DraduxAutoMarking.monitor then
        DraduxAutoMarking.monitor:Update()
    end
end

function DraduxAutoMarking:SetChargeName(name)
    if DraduxAutoMarking.monitor then
        DraduxAutoMarking.monitor:SetChargeName(name)
    end
end