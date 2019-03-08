local StdUi = LibStub("StdUi")

local function CountEnemies(enemies)
    local count = 0

    for k, v in pairs(enemies) do
        count = count + 1
    end

    return count
end

local function GetSortedEnemies(enemies)
    local sortedEnemies = {}
    for id, enemy in pairs(enemies) do
        table.insert(sortedEnemies, {
            id = enemy.id,
            name = enemy.name,
            displayID = enemy.displayID
        })
    end

    table.sort(sortedEnemies, function(a, b)
        if a.name == b.name then
            return a.id < b.id
        end

        return a.name < b.name
    end)

    return sortedEnemies
end

local markers = {
    "Star",
    "Circle",
    "Diamond",
    "Triangle",
    "Moon",
    "Square",
    "Cross",
    "Skull"
}

StdUi:RegisterWidget("WizardFrame", function(self, parent)
    local width = 660
    local height = 570

    local frame = CreateFrame("Frame", nil, parent)
    self:InitWidget(frame)
    self:SetObjSize(frame, width, height)
    frame.step = 1
    frame.maxSteps = 10

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title = title
    title:SetJustifyH("CENTER")
    title:SetJustifyV("CENTER")
    title:SetTextColor(1, 1, 1, 1)
    StdUi:GlueTop(title, frame, 0, 0)

    local next = StdUi:Button(frame, 80, 32, "Continue")
    frame.next = next
    next:SetScript("OnClick", function()
        frame:Next()
    end)
    StdUi:GlueBottom(next, frame, 0, 0, "RIGHT")

    local finish = StdUi:Button(frame, 80, 32, "Finish")
    frame.finish = finish
    finish:SetScript("OnClick", function()
        frame:Finish()
    end)
    StdUi:GlueBottom(finish, frame, 0, 0, "RIGHT")
    finish:Hide()

    local previous = StdUi:Button(frame, 80, 32, "Back")
    frame.previous = previous
    previous:SetScript("OnClick", function()
        frame:Back()
    end)
    StdUi:GlueBottom(previous, frame, 0, 0, "LEFT")

    local markerSelection = StdUi:MarkerSelectionFrame(frame, 123, "Test NPC")
    frame.markerSelection = markerSelection
    markerSelection:SetHeight(height - 60)
    StdUi:GlueTop(markerSelection, frame, 0, -20, "LEFT")
    markerSelection:Hide()

    local enemySelection = StdUi:EnemySelectionFrame(frame, 8, "Skull")
    frame.enemySelection = enemySelection
    enemySelection:SetHeight(height - 60)
    StdUi:GlueTop(enemySelection, frame, 0, -20, "LEFT")

    function frame:UpdateTitle()
        title:SetText(frame.step .. " / " .. frame.maxSteps)
    end

    function frame:SetModule(module)
        frame.module = module
    end

    function frame:SetDatabaseModule(dbModule)
        frame.dbModule = dbModule
    end

    function frame:SetEnemies(enemies)
        local enemyCount = CountEnemies(enemies)
        frame.step = 1
        frame.maxSteps = enemyCount + 8
        frame.previous:Hide()

        frame.enemies = enemies

        frame.steps = {}
        local sortedEnemies = GetSortedEnemies(enemies)
        for index, entry in ipairs(sortedEnemies) do
            table.insert(frame.steps, {
                show = function()
                    frame:SetupMarkerSelection(entry.id, entry.name, entry.displayID)
                    frame:LoadMarkerSelection()
                    frame:ShowMarkerSelection()
                end,
                hide = function()
                    frame:SaveMarkerSelection()
                end,
                data = {
                    id = entry.id
                }
            })
        end

        for i=8, 1, -1 do
            table.insert(frame.steps, {
                show = function()
                    frame:SetupEnemySelection(i)
                    frame:LoadEnemySelection()
                    frame:ShowEnemySelection()
                end,
                hide = function()
                    frame:SaveEnemySelection()
                end,
                data = {
                    marker = i
                }
            })
        end

        frame.enemySelection:SetEnemies(sortedEnemies)
        frame:UpdateTitle()
        frame.finish:Hide()
        frame.next:Show()
        frame.steps[1].show()
    end

    function frame:Next()
        frame.steps[frame.step].hide()
        frame.step = math.min(frame.maxSteps, frame.step + 1)

        if not frame.previous:IsShown() then
            frame.previous:Show()
        end

        if frame.step == frame.maxSteps then
            frame.next:Hide()
            frame.finish:Show()
        end

        frame:UpdateTitle()
        frame.steps[frame.step].show()
    end

    function frame:Back()
        frame.steps[frame.step].hide()
        frame.step = math.max(1, frame.step - 1)

        if not frame.next:IsShown() then
            frame.next:Show()
        end

        if frame.finish:IsShown() then
            frame.finish:Hide()
        end

        if frame.step == 1 then
            frame.previous:Hide()
        end

        frame:UpdateTitle()
        frame.steps[frame.step].show()
    end

    function frame:Finish()
        local result = {}


        -- Save last data
        frame.steps[frame.maxSteps].hide()

        -- calculate the final score for every enemy
        for i=1, frame.maxSteps do
            local data = frame.steps[i].data
            if data then
                if data.id then
                    -- It's a marker selection
                    if not result[data.id] then
                        result[data.id] = {}
                    end

                    for i=1, 8 do
                        result[data.id][i] = (result[data.id][i] or 1) * (data.markers[i] * 10)
                    end
                elseif data.marker then
                    -- It's an enemy selection
                    for enemyID, value in pairs(data.enemies) do
                        if not result[enemyID] then
                            result[enemyID] = {}
                        end

                        result[enemyID][data.marker] = (result[enemyID][data.marker] or 1) * (value * 10)
                    end
                end
            end
        end

        -- Store in the db
        local db = frame.dbModule:GetDB(frame.module:GetName())
        for enemyID, markers in pairs(result) do
            if not db[enemyID] then
                db[enemyID] = {}
            end

            db[enemyID].markers = {}
            for marker, priority in ipairs(markers) do
                table.insert(db[enemyID].markers, {
                    index = marker,
                    allowed = (priority > 0),
                    priority = priority
                })
            end
        end

        frame.module:ShowConfiguration()
    end

    function frame:SetupMarkerSelection(id, name, displayID)
        frame.markerSelection:DeselectAll()
        frame.markerSelection:SetID(id)
        frame.markerSelection:SetName(name)
        frame.markerSelection:SetDisplayID(displayID)
    end

    function frame:LoadMarkerSelection()
        local data = frame.steps[frame.step].data
        if data and data.markers then
            for i=1, 8 do
                frame.markerSelection:SetMarker(i, 9 - data.markers[i])
            end
        end
    end

    function frame:SaveMarkerSelection()
        local data = frame.steps[frame.step].data
        data.markers = {}
        for i=1, 8 do
            table.insert(data.markers, frame.markerSelection:GetValue(i))
        end
    end

    function frame:GetMarkers(enemyID)
        for step=1, frame.maxSteps do
            local data = frame.steps[step].data
            if data and data.id and data.id == enemyID then
                local markers = {}
                for i=1, 8 do
                    if (data.markers[i] or 0) > 0 then
                        table.insert(markers, {
                            marker = i,
                            value = (data.markers[i] or 0)
                        })
                    end
                end

                table.sort(markers, function(a, b)
                    if a.value == b.value then
                        return a.marker > b.marker
                    end

                    return a.value > b.value
                end)

                local sorted = {}
                for _, entry in ipairs(markers) do
                    table.insert(sorted, entry.marker)
                end

                return sorted
            end
        end

        return {}
    end

    function frame:ShowMarkerSelection()
        frame.enemySelection:Hide()
        frame.markerSelection:Show()
    end

    function frame:SetupEnemySelection(marker)
        local markerName = markers[marker]
        frame.enemySelection:SetMarker(marker, markerName)
    end

    function frame:LoadEnemySelection()
        local data = frame.steps[frame.step].data
        if data and data.enemies then
            for enemyID, value in pairs(data.enemies) do
                frame.enemySelection:SetEnemyIndex(enemyID, (frame.enemySelection.enemyCount + 1) - value)
            end
        end
    end

    function frame:SaveEnemySelection()
        local data = frame.steps[frame.step].data
        data.enemies = {}
        for enemyID, _ in pairs(frame.enemies) do
            local value = frame.enemySelection:GetValue(enemyID)
            data.enemies[enemyID] = value
        end
    end

    function frame:ShowEnemySelection()
        frame.markerSelection:Hide()
        frame.enemySelection:Show()
    end

    frame:UpdateTitle()
    return frame
end)