local STATE_FREE = "FREE"
local STATE_USED = "USED"
local STATE_LOCKED = "LOCKED"

function DraduxAutoMarking:InitializeMarking()
    DraduxAutoMarking.units = {}
    DraduxAutoMarking.markers = {}
end

function DraduxAutoMarking:StripMarkers(markers)
    local remaining = {}

    for _, marker in ipairs(markers) do
        if marker.allowed then
            table.insert(remaining, marker)
        end
    end

    table.sort(remaining, function(a, b)
        if a.priority == b.priority then
            return a.index > b.index
        end

        return a.priority > b.priority
    end)

    return remaining
end

function DraduxAutoMarking:RequestMarker(unit, range_check, markers, actions)
    if not DraduxAutoMarking.inCharge then
        -- I am not allowed to mark
        return
    end

    -- Store unit request
    DraduxAutoMarking.units[unit] = {
        unit = unit,
        range_check = range_check,
        markers = markers,
        actions = actions
    }

    local actual_marker = GetRaidTargetIndex(unit)
    if actual_marker then
        local config = DraduxAutoMarking:GetMarker(actual_marker)
        if UnitGUID(unit) == config.target.guid then
            config.target.unit = unit
            return
        end
    end

    local potential_markers = DraduxAutoMarking:StripMarkers(markers)
    for _, potential_marker in ipairs(potential_markers) do
        local marker = DraduxAutoMarking:GetMarker(potential_marker.index)
        if marker.data.state == STATE_FREE then
            local minRange, maxRange = DraduxAutoMarking:GetRange(unit)
            -- ToDo: Replace range check by configurable value
            if not range_check or (range_check and (maxRange <= 25)) then
                DraduxAutoMarking:SetMarker(potential_marker.index, STATE_USED, unit, potential_marker.priority, actions)
            end
            return
        elseif marker.data.state == STATE_USED and potential_marker.priority > marker.data.priority then
            local minRange, maxRange = DraduxAutoMarking:GetRange(unit)
            -- ToDo: Replace range check by configurable value
            if not range_check or (range_check and (maxRange <= 25)) then
                DraduxAutoMarking:SetMarker(potential_marker.index, STATE_USED, unit, potential_marker.priority, actions)
            end
            return
        end
    end
end

function DraduxAutoMarking:GetMarker(marker)
    if not DraduxAutoMarking.markers[marker] then
        DraduxAutoMarking.markers[marker] = {
            target = {
                ["name"] = "",
                ["guid"] = "",
                ["unit"] = "",
            },
            data = {
                ["state"] = STATE_FREE,
                ["priority"] = 0,
                ["lastDamageTaken"] = 0,
            },
            actions = {
                onMarkerSet = "NONE",
                onMarkerIsMissing = "NONE",
                onDamageTaken = "NONE",
                onNoDamageTaken = "NONE",
                onUnitDied = "NONE",
                onUnitDoesNotExists = "NONE"
            }
        }
    end

    return DraduxAutoMarking.markers[marker]
end

function DraduxAutoMarking:SetMarker(marker, state, unit, priority, actions)
    DraduxAutoMarking.markers[marker] = {
        target = {
            ["name"] = UnitName(unit),
            ["guid"] = UnitGUID(unit),
            ["unit"] = unit,
        },
        data = {
            ["state"] = state,
            ["priority"] = priority,
            ["lastDamageTaken"] = 0,
        },
        actions = actions
    }

    local actual_marker = GetRaidTargetIndex(unit)
    if not actual_marker or actual_marker ~= marker then
        SetRaidTarget(unit, marker)
    end

    DraduxAutoMarking:UpdateMonitor()
    DraduxAutoMarking:OnMarkerSet(marker)
end

function DraduxAutoMarking:ReleaseMarker(marker)
    local config = DraduxAutoMarking:GetMarker(marker)

    -- Release unit
    if config.target.unit ~= "" then
        DraduxAutoMarking.units[config.target.unit] = nil
    end

    -- Release marker
    DraduxAutoMarking.markers[marker] = nil

    DraduxAutoMarking:UpdateMonitor()
end

function DraduxAutoMarking:LockMarker(marker)
    local config = DraduxAutoMarking:GetMarker(marker)
    if config.data.state == STATE_USED then
        config.data.state = STATE_LOCKED
        DraduxAutoMarking:UpdateMonitor()
    end
end

function DraduxAutoMarking:UnlockMarker(marker)
    local config = DraduxAutoMarking:GetMarker(marker)
    if config.data.state == STATE_LOCKED then
        config.data.state = STATE_USED
        DraduxAutoMarking:UpdateMonitor()
    end
end

function DraduxAutoMarking:HasMarkerRequested(unit, marker)
    local request = DraduxAutoMarking.units[unit]
    for _, entry in ipairs(request.markers) do
        if entry.index == marker and entry.allowed then
            return true
        end
    end

    return false
end

function DraduxAutoMarking:GetUnitsForAvailableMarkers()
    local units = {}

    for marker=8, 1, -1 do
        local entry = DraduxAutoMarking:GetMarker(marker)
        if entry.data.state == STATE_FREE or entry.data.state == STATE_USED then
            for unit, _ in pairs(DraduxAutoMarking.units) do
                local actual_marker = GetRaidTargetIndex(unit)
                if not actual_marker and DraduxAutoMarking:HasMarkerRequested(unit, marker) then
                    units[unit] = DraduxAutoMarking.units[unit]
                end
            end
        end
    end

    return units
end

function DraduxAutoMarking:GetNextUnitForMarker(marker)
    local next_unit
    local next_priority = 0

    for unit, request in pairs(DraduxAutoMarking.units) do
        if UnitExists(unit) then
            local actual_marker = GetRaidTargetIndex(unit)
            if not actual_marker then
                local priority = DraduxAutoMarking:GetUnitMarkerPriority(unit, marker)
                if (priority or 0) > next_priority then
                    next_unit = unit
                    next_priority = priority
                end
            end
        else
            DraduxAutoMarking.units[unit] = nil
        end
    end

    return next_unit
end

function DraduxAutoMarking:GetUnitMarkerPriority(unit, marker)
    local request = DraduxAutoMarking.units[unit]

    for _, entry in ipairs(request.markers) do
        if entry.index == marker then
            if not entry.allowed then
                return
            end

            return entry.priority
        end
    end

    return nil
end

function DraduxAutoMarking:GetMarkerByGUID(guid)
    for marker=1, 8 do
        local config = DraduxAutoMarking:GetMarker(marker)
        if config.target.guid == guid then
            return marker
        end
    end
end

function DraduxAutoMarking:HasMarkerState(marker, state)
    local config = DraduxAutoMarking:GetMarker(marker)
    if config then
        return (config.data.state == state)
    end
end

function DraduxAutoMarking:IsMarkerFree(marker)
   return DraduxAutoMarking:HasMarkerState(marker, STATE_FREE)
end

function DraduxAutoMarking:IsMarkerUsed(marker)
    return DraduxAutoMarking:HasMarkerState(marker, STATE_USED)
end

function DraduxAutoMarking:IsMarkerLocked(marker)
    return DraduxAutoMarking:HasMarkerState(marker, STATE_LOCKED)
end

function DraduxAutoMarking:GetMarkerUnitName(marker)
    local config = DraduxAutoMarking:GetMarker(marker)
    if config then
        return config.target.name
    end
end

