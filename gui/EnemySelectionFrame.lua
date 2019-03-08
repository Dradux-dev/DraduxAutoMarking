local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("EnemySelectionFrame", function(self, parent, marker, markerName)
    local width = 660
    local height = 510

    local frame = CreateFrame("Frame", nil, parent)
    self:InitWidget(frame)
    self:SetObjSize(frame, width, height)

    frame.marker = marker
    frame.enemyFrames = {}
    frame.unassignedEnemies = {}
    frame.enemyIndexFrames = {}

    frame:SetBackdrop({ bgFile = [[Interface\Buttons\WHITE8X8]],
                        edgeFile = [[Interface\Buttons\WHITE8X8]],
                        tile = true, tileSize = 16, edgeSize = 1,
                        insets = { left = 0, right = 0, top = 0, bottom = 0 }});
    frame:SetBackdropColor(0.15, 0.15, 0.15, 0.7)
    frame:SetBackdropBorderColor(0, 0, 0, 1)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title = title
    title:SetJustifyH("LEFT")
    title:SetJustifyV("CENTER")
    title:SetTextColor(1, 1, 1, 1)
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
    title:SetText(markerName)

    local description = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.description = description
    description:SetJustifyH("LEFT")
    description:SetJustifyV("CENTER")
    description:SetTextColor(1, 1, 1, 1)
    description:SetText([[Select the marker you want to be allowed for this enemy. The higher the marker is, the higher
is the priority to use this marker for that enemy. It is possible to have a marker not selected in any row, to
completly disallow that marker for these enemies. It is also possible to select multiple markers in one row, if
all markers shall have the same priority.]])
    StdUi:GlueBelow(description, title, 0, -5, "LEFT")


    local indexPanel, indexFrame, indexChild, indexBar = StdUi:ScrollFrame(frame, 384, 400)
    frame.indexPanel = indexPanel
    frame.indexFrame = indexFrame
    frame.indexChild = indexChild
    frame.indexBar = indexBar
    StdUi:GlueTop(indexPanel, frame, 44, -100, "LEFT")

    local lastIndexFrame
    for i=1, 10 do
        local enemyIndexFrame = StdUi:EnemyIndexFrame(indexChild, i)
        table.insert(frame.enemyIndexFrames, enemyIndexFrame)
        if i == 1 then
            StdUi:GlueTop(enemyIndexFrame, indexChild, 0, 0, "LEFT")
        else
            StdUi:GlueBelow(enemyIndexFrame, lastIndexFrame, 0, -10)
        end

        lastIndexFrame = enemyIndexFrame
    end

    local enemyPanel, enemyFrame, enemyChild, enemyBar = StdUi:ScrollFrame(frame, 172, 400)
    frame.enemyPanel = enemyPanel
    frame.enemyFrame = enemyFrame
    frame.enemyChild = enemyChild
    frame.enemyBar = enemyBar
    StdUi:GlueTop(enemyPanel, frame, 444, -100, "LEFT")

    for i=1, 10 do
        local enemyBadge = StdUi:EnemyBadge(enemyChild, 1230 + i , "Test " .. i)
        table.insert(frame.enemyFrames, enemyBadge)
        table.insert(frame.unassignedEnemies, enemyBadge)
    end

    function frame:SetMarker(marker, markerName)
        frame.marker = marker
        frame.title:SetText(markerName)

        -- Setup selected markers per enemy
        table.foreach(frame.enemyFrames, function(index, enemyFrame)
            enemyFrame:SetMarkers(parent:GetMarkers(enemyFrame:GetID()))
        end)

        -- Move all enemies back to the right side (unassigned enemies)
        frame.unassignedEnemies = {}
        table.foreach(frame.enemyFrames, function(index, enemyFrame)
            if enemyFrame:IsMarkerSelected(marker) then
                table.insert(frame.unassignedEnemies, enemyFrame)
                enemyFrame:Show()
            else
                enemyFrame:Hide()
            end

            enemyFrame:SetParent(enemyChild)
        end)

        for _, enemyIndexFrame in ipairs(frame.enemyIndexFrames) do
            enemyIndexFrame.enemies = {}
            enemyIndexFrame:RearrangeEnemyFrames()
        end

        frame:RearrangeEnemyFrames()
    end

    function frame:RearrangeEnemyFrames()
        for index, enemyFrame in ipairs(frame.unassignedEnemies) do
            enemyFrame:ClearAllPoints()

            StdUi:GlueTop(enemyFrame, enemyChild, 0, -((index - 1) * ((enemyFrame:GetHeight() or 60) + 2)), "LEFT")
        end
    end

    function frame:FindEnemyFrame(button)
        for index, enemyFrame in ipairs(frame.unassignedEnemies) do
            if enemyFrame == button then
                return index
            end
        end
    end

    function frame:SetEnemies(sortedEnemies)
        frame.enemyCount = table.getn(sortedEnemies)
        if table.getn(frame.enemyIndexFrames) < frame.enemyCount then
            for i=1, frame.enemyCount - table.getn(frame.enemyIndexFrames) do
                local lastFrame = frame.enemyIndexFrames[table.getn(frame.enemyIndexFrames)]
                local enemyIndexFrame = StdUi:EnemyIndexFrame(frame.indexChild, table.getn(frame.enemyIndexFrames) + 1)
                StdUi:GlueBelow(enemyIndexFrame, lastFrame, 0, -10)
                table.insert(frame.enemyIndexFrames, enemyIndexFrame)
            end
        end

        if table.getn(frame.enemyFrames) < frame.enemyCount then
            for i=1, frame.enemyCount - table.getn(frame.enemyFrames) do
                local lastFrame = frame.enemyFrames[table.getn(frame.enemyFrames)]
                local enemyFrame = StdUi:EnemyBadge(frame.enemyChild, 1, "Dummy")
                StdUi:GlueBelow(enemyFrame, lastFrame, 0, -2)
                table.insert(frame.enemyFrames, enemyFrame)
                table.insert(frame.unassignedEnemies, enemyFrame)
            end
        end

        for index, data in ipairs(sortedEnemies) do
            local enemyFrame = frame.enemyFrames[index]
            enemyFrame:ClearMarkerText()
            enemyFrame:SetName(data.name)
            enemyFrame:SetID(data.id)

            -- Setting drop targets
            enemyFrame:AddDropTarget(frame.enemyChild)
            for i, enemyIndexFrame in ipairs(frame.enemyIndexFrames) do
                enemyFrame:AddDropTarget(enemyIndexFrame)
            end
        end

        frame:RearrangeEnemyFrames()
    end

    function frame:GetValue(enemyID)
        for index , enemyIndexFrame in ipairs(frame.enemyIndexFrames) do
            if enemyIndexFrame:IsShown() and enemyIndexFrame:HasEnemy(enemyID) then
                return (frame.enemyCount + 1) - index
            end
        end

        return 0
    end

    function frame:GetEnemyByID(enemyID)
        for _, enemy in ipairs(frame.unassignedEnemies) do
            if enemy:GetID() == enemyID then
                return enemy
            end
        end
    end

    function frame:SetEnemyIndex(enemyID, index)
        local enemyFrame = frame:GetEnemyByID(enemyID)
        local indexFrame = frame.enemyIndexFrames[index]
        if enemyFrame and indexFrame then
            enemyChild:RemoveEnemy(enemyFrame)
            indexFrame:AddEnemy(enemyFrame)
        end
    end

    function enemyChild:HighlightNormal()
        local color = enemyPanel.originalBackdropBorderColor
        if color then
            enemyPanel:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
        end
    end

    function enemyChild:HighlightMouseover()
        local r, g, b, a = enemyPanel:GetBackdropBorderColor()
        enemyPanel.originalBackdropBorderColor = {
            r = r,
            g = g,
            b = b,
            a = a
        }
        enemyPanel:SetBackdropBorderColor(1, 0.509, 0.058, 1)
    end

    function enemyChild:FindEnemy(enemyFrame)
        for index, enemy in ipairs(frame.unassignedEnemies) do
            if enemy == enemyFrame then
                return index
            end
        end
    end

    function enemyChild:AddEnemy(enemyFrame)
        local found = enemyChild:FindEnemy(enemyFrame)
        if not found then
            table.insert(frame.unassignedEnemies, enemyFrame)
            table.sort(frame.unassignedEnemies, function(a, b)
                if a:GetName() == b:GetName() then
                    return a:GetID() < b:GetID()
                end

                return a:GetName() < b:GetName()
            end)

            enemyFrame:SetParent(enemyChild)
            frame:RearrangeEnemyFrames()
        end
    end

    function enemyChild:RemoveEnemy(enemyFrame)
        local position = enemyChild:FindEnemy(enemyFrame)
        if position then
            table.remove(frame.unassignedEnemies, position)
            frame:RearrangeEnemyFrames()
        end
    end

    function enemyChild:RearrangeEnemyFrames()
        frame:RearrangeEnemyFrames()
    end

    function enemyChild:GetCurrentMarker()
        return frame.marker
    end

    function indexChild:GetCurrentMarker()
        return frame.marker
    end

    frame:RearrangeEnemyFrames()
    return frame
end)