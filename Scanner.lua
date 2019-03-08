function DraduxAutoMarking:InitializeScanner()
    if not DraduxAutoMarking.scanner then
        DraduxAutoMarking.scanner = {
            modules = {},
            callbacks = {}
        }

        DraduxAutoMarking:AddScannerCallback("ScanMarkers", function()
            DraduxAutoMarking:ScanMarkers()
        end)

        DraduxAutoMarking:AddScannerCallback("ScanUnits", function()
            DraduxAutoMarking:ScanUnits()
        end)
    end
end

function DraduxAutoMarking:StartScanner(moduleName)
    if not DraduxAutoMarking.scanner.ticker then
        -- ToDo: Replace timer tick duration by configurable value
        DraduxAutoMarking.scanner.ticker = C_Timer.NewTicker(0.4, function()
            DraduxAutoMarking:ScannerCallback()
        end)
    end

    DraduxAutoMarking.scanner.modules[moduleName] = true
end

function DraduxAutoMarking:StopScanner(moduleName)
    DraduxAutoMarking.scanner.modules[moduleName] = nil

    local count = 0
    for _, _ in pairs(DraduxAutoMarking.scanner.modules) do
        count = count + 1
    end

    if count == 0 then
        DraduxAutoMarking.scanner.ticker:Cancel()
        DraduxAutoMarking.scanner.ticker = nil
    end

end

function DraduxAutoMarking:ScannerCallback()
    for _, entry in ipairs(DraduxAutoMarking.scanner.callbacks) do
        entry.callback()
    end
end

function DraduxAutoMarking:AddScannerCallback(name, callback)
    table.insert(DraduxAutoMarking.scanner.callbacks, {
        name = name,
        callback = callback
    })
end

function DraduxAutoMarking:RemoveScannerCallback(name)
    local pos = DraduxAutoMarking:FindScannerCallback(name)
    if pos then
        table.remove(DraduxAutoMarking.scanner.callbacks, pos)
    end
end

function DraduxAutoMarking:FindScannerCallback(name)
    for index, entry in ipairs(DraduxAutoMarking.scanner.callbacks) do
        if entry.name == name then
            return name
        end
    end
end

function DraduxAutoMarking:ScanMarkers()
    local now = GetTime()

    for marker, entry in pairs(DraduxAutoMarking.markers) do
        if UnitExists(entry.target.unit) then
            local actual_marker = GetRaidTargetIndex(entry.target.unit)
            if not actual_marker or actual_marker ~= marker then
                DraduxAutoMarking:OnMarkerIsMissing(marker)
            end

            -- ToDo: Replace the 60 seconds by a configurable value
            if now - entry.data.lastDamageTaken >  60 then
                DraduxAutoMarking:OnNoDamageTaken(marker)
            end
        else
            DraduxAutoMarking:OnUnitDoesNotExists(marker)
        end
    end
end



function DraduxAutoMarking:ScanUnits()
    -- get rid of none existent units
    for unit, _ in pairs(DraduxAutoMarking.units) do
        if not UnitExists(unit) then
            DraduxAutoMarking.units[unit] = nil
        end
    end

    -- request marking again
    for _, request in pairs(DraduxAutoMarking:GetUnitsForAvailableMarkers()) do
        DraduxAutoMarking:RequestMarker(request.unit, request.range_check, request.markers, request.actions)
    end
end