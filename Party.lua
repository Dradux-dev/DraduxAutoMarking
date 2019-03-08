local Party = DraduxAutoMarking:NewModule("Party", "AceEvent-3.0")

function Party:OnEnable()
    Party.units = {}
    DraduxAutoMarking:AddScannerCallback("Party:Scan", function()
        Party:Scan()
    end)

    DraduxAutoMarking:StartScanner("Party")
end

function Party:OnDisable()

    DraduxAutoMarking:StopScanner("Party")
    DraduxAutoMarking:RemoveScannerCallback("Party:Scan")
end

function Party:Scan()
    for unit in DraduxAutoMarking:IterateGroupMembers() do
        local actual_marker = GetRaidTargetIndex(unit)
        if actual_marker and actual_marker ~= Party.units[unit] then
            DraduxAutoMarking:RequestMarker(unit, false,
                {
                    {
                        index = actual_marker,
                        priority = 20000,
                        allowed = true
                    }
                },
                {
                    onMarkerSet = "LOCK",
                    onMarkerIsMissing = "RELEASE",
                    onDamageTaken = "NONE",
                    onNoDamageTaken = "NONE",
                    onUnitDied = "NONE",
                    onUnitDoesNotExists = "RELEASE"
                }
            )

            -- Avoid requesting the same marker multiple times
            Party.units[unit] = actual_marker
        end
    end
end