DraduxAutoMarking.actions = {
    none = "NONE",
    lock = "LOCK",
    unlock = "UNLOCK",
    release = "RELEASE"
}

function DraduxAutoMarking:OnMarkerSet(marker)
    local config = DraduxAutoMarking:GetMarker(marker)

    if config.actions.onMarkerSet == "LOCK" then
        DraduxAutoMarking:LockMarker(marker)
    end
end

function DraduxAutoMarking:OnMarkerIsMissing(marker)
    local config = DraduxAutoMarking:GetMarker(marker)

    if config.actions.onMarkerIsMissing == "UNLOCK" then
        DraduxAutoMarking:UnlockMarker(marker)
    elseif config.actions.onMarkerIsMissing == "RELEASE" then
        DraduxAutoMarking:ReleaseMarker(marker)
    end
end

function DraduxAutoMarking:OnDamageTaken(marker)
    local config = DraduxAutoMarking:GetMarker(marker)
    config.data.lastDamageTaken = GetTime()

    if config.actions.onDamageTaken == "LOCK" then
        DraduxAutoMarking:LockMarker(marker)
    end
end

function DraduxAutoMarking:OnNoDamageTaken(marker)
    local config = DraduxAutoMarking:GetMarker(marker)

    if config.actions.onNoDamageTaken == "UNLOCK" then
        DraduxAutoMarking:UnlockMarker(marker)
    elseif config.actions.onNoDamageTaken == "RELEASE" then
        DraduxAutoMarking.ReleaseMarker(marker)
    end
end

function DraduxAutoMarking:OnUnitDied(marker)
    local config = DraduxAutoMarking:GetMarker(marker)

    if config.actions.onUnitDied == "UNLOCK" then
        DraduxAutoMarking:UnlockMarker(marker)
    elseif config.actions.onUnitDied == "RELEASE" then
        DraduxAutoMarking:ReleaseMarker(marker)
    end
end

function DraduxAutoMarking:OnUnitDoesNotExists(marker)
    local config = DraduxAutoMarking:GetMarker(marker)

    if config.actions.onUnitDoesNotExists == "UNLOCK" then
        DraduxAutoMarking:UnlockMarker(marker)
    elseif config.actions.onUnitDoesNotExists == "RELEASE" then
        DraduxAutoMarking:ReleaseMarker(marker)
    end
end