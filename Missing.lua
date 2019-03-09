function DraduxAutoMarking:AddMissingEnemy(id, name)
    local db = DraduxAutoMarking:GetDB()

    if not db.missing then
        db.missing = {}
    end

    if db.missing[id] then
        -- Don't search for an enemy that is already missing
        return
    end

    if not DraduxAutoMarking:KnowsEnemy(id) then
        db.missing[id] = name
    end
end

function DraduxAutoMarking:KnowsEnemy(id)
    for _, module in pairs(DraduxAutoMarking.modules) do
        if module and module["KnowsEnemy"] and module:KnowsEnemy(id) then
            return true
        end
    end

    return false
end

function DraduxAutoMarking:GetSortedMissingEnemies()
    local db = DraduxAutoMarking:GetDB()

    if not db.missing then
        db.missing = {}
    end

    local t = {}
    for id, name in pairs(db.missing) do
        table.insert(t, {
            id = id,
            name = name
        })
    end

    table.sort(t, function(a, b)
        if a.name == b.name then
            return a.id < b.id
        end

        return a.name < b.name
    end)

    return t
end

function DraduxAutoMarking:PrintMissingEnemies()
    local t = DraduxAutoMarking:GetSortedMissingEnemies()
    for _, entry in ipairs(t) do
        print(t.id, t.name)
    end
end

function DraduxAutoMarking:ShowMissingEnemies()
    local text = ""
    local t = DraduxAutoMarking:GetSortedMissingEnemies()

    for _, entry in ipairs(t) do
        text = text .. string.format("%d,\"%s\"\n", entry.id, entry.name)
    end

    DraduxAutoMarking:ShowTextFrame(text, function()
        DraduxAutoMarking:ClearMissingEnemies()
        DraduxAutoMarking.window.textFrame:Hide()
    end)
end

function DraduxAutoMarking:ClearMissingEnemies()
    local db = DraduxAutoMarking:GetDB()
    db.missing = {}
end