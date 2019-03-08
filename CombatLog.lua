function DraduxAutoMarking:TrackCombatLog()
    local markingModules = DraduxAutoMarking:CountMarkingModules()
    if markingModules >= 1 then
        DraduxAutoMarking:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(event)
            DraduxAutoMarking:COMBAT_LOG_EVENT_UNFILTERED(event, CombatLogGetCurrentEventInfo())
        end)
    end
end

function DraduxAutoMarking:UntrackCombatLog()
    local markingModules = DraduxAutoMarking:CountMarkingModules()
    if markingModules == 0 then
        DraduxAutoMarking:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end

function DraduxAutoMarking:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
    local combatEvent = select(2, ...)

    if combatEvent == "UNIT_DIED" then
        local destGUID = select(8, ...)
        local marker = DraduxAutoMarking:GetMarkerByGUID(destGUID)
        if marker then
            DraduxAutoMarking:OnUnitDied(marker)
        end
    elseif combatEvent == "SPELL_DAMAGE" or combatEvent == "SWING_DAMAGE" or combatEvent == "RANGE_DAMAGE" then
        local destGUID = select(8, ...)
        local marker = DraduxAutoMarking:GetMarkerByGUID(destGUID)
        if marker then
            DraduxAutoMarking:OnDamageTaken(marker)
        end
    end
end