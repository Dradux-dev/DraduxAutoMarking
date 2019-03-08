local StdUi = LibStub("StdUi")

function DraduxAutoMarking:InitializeMonitor()
    DraduxAutoMarking.monitor = StdUi:MarkerMonitor(UIParent)
    DraduxAutoMarking.monitor:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, -200)
    DraduxAutoMarking.monitor:Hide()
end

function DraduxAutoMarking:ToggleMonitor()
    if not DraduxAutoMarking.monitor then
        print("Initializing monitor")
        DraduxAutoMarking:InitializeMonitor()
    end

    if DraduxAutoMarking.monitor:IsShown() then
        print("Hiding monitor")
        DraduxAutoMarking.monitor:Hide()
    else
        print("Showing monitor")
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