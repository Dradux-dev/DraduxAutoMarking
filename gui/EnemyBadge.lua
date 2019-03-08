local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("EnemyBadge", function(self, parent, id, name)
    local width = 150
    local height = 60

    local button = CreateFrame("BUTTON", name, parent, "OptionsListButtonTemplate")
    self:InitWidget(button)
    self:SetObjSize(button, width, height)

    button.id = id
    button.marker = {}
    button.markerText = {}
    button.dropTargets = {}

    local title = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.title = title
    title:SetJustifyH("CENTER")
    title:SetJustifyV("CENTER")
    title:SetTextColor(1, 1, 1, 1)
    title:SetText(name)
    StdUi:GlueTop(title, button, 0, -10)

    local lastIcon
    for marker=8, 1, -1 do
        local icon = StdUi:MarkerIcon(button, 16, 16, marker)
        icon:SetScript("OnClick", nil)
        table.insert(button.marker, icon)

        if not lastIcon then
            StdUi:GlueBottom(icon, button, 11, 20, "LEFT")
        else
            StdUi:GlueRight(icon, lastIcon, 0, 0)
        end

        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        table.insert(button.markerText, text)
        text:SetJustifyH("CENTER")
        text:SetJustifyV("CENTER")
        text:SetTextColor(1, 1, 1, 1)
        text:SetPoint("TOP", icon, "BOTTOM")
        text:SetText("")

        lastIcon = icon
    end



    function button:SetMarkers(markers)
        local missing = {true, true, true, true, true, true, true, true}
        for position, marker in ipairs(markers) do
            button.marker[position]:SetMarker(marker)
            button.marker[position]:Selected()
            missing[marker] = false
        end

        local position = table.getn(markers) + 1
        for marker=8, 1, -1 do
            if position <= 8 then
                local state = missing[marker]
                if state then
                    button.marker[position]:SetMarker(marker)
                    button.marker[position]:Deselected()
                    position = position + 1
                end
            end
        end
    end

    function button:ClearMarkerText()
        table.foreach(button.markerText, function(k, v)
            v:SetText("")
        end)
    end

    function button:IsMarkerSelected(marker)
        for _, icon in ipairs(button.marker) do
            if icon:GetMarker() == marker and icon:IsSelected() then
                return true
            end
        end

        return false
    end

    function button:Selected(marker)
        -- IconMarker wants to inform me, that the icon
        -- has been selected, but I don't care
    end

    function button:GetName()
        return button.title:GetText()
    end

    function button:GetID()
        return button.id
    end

    function button:SetName(name)
        button.title:SetText(name)
    end

    function button:SetID(id)
        button.id = id
    end

    function button:Drag()
        local uiscale, scale = UIParent:GetScale(), button:GetEffectiveScale()
        local x, w = button:GetLeft(), button:GetWidth()
        local _, y = GetCursorPosition()

        button:SetMovable(true)
        button:StartMoving()
        button:ClearAllPoints()

        button.temp = {
            parent = button:GetParent(),
            strata = button:GetFrameStrata(),
            level = button:GetFrameLevel()
        }
        button:SetParent(UIParent)
        button:SetFrameStrata("TOOLTIP")
        button:SetFrameLevel(120)
        button:SetPoint("Center", UIParent, "BOTTOMLEFT", (x+w/2)*scale/uiscale, y/uiscale)

        button.dragTicker = C_Timer.NewTicker(0.25, function()
            table.foreach(button.dropTargets, function(index, dropTarget)
                dropTarget:HighlightNormal()
            end)

            local index, dropTarget = button:GetMouseoverDropTarget()
            if index and dropTarget then
                dropTarget:HighlightMouseover()
            end
        end)
    end

    function button:Drop()
        button:StopMovingOrSizing()
        button:SetScript("OnUpdate", nil)
        button:SetParent(button.temp.parent)
        button:SetFrameStrata(button.temp.strata)
        button:SetFrameLevel(button.temp.level)

        if button.dragTicker then
            button.dragTicker:Cancel()
            button.dragTicker = nil
        end

        table.foreach(button.dropTargets, function(index, dropTarget)
            dropTarget:HighlightNormal()
        end)


        local index, dropTarget = button:GetMouseoverDropTarget()
        if index then
            button:GetParent():RemoveEnemy(button)

            local currentMarker = dropTarget:GetCurrentMarker()
            print("Current Marker", currentMarker)
            if currentMarker then
                local iconIndex = button:FindMarkerIcon(currentMarker)
                if iconIndex then
                    print("Dropping on", dropTarget.number)
                    button.markerText[iconIndex]:SetText(dropTarget.number or "")
                end
            end
            dropTarget:AddEnemy(button)
        else
            parent:RearrangeEnemyFrames()
        end
    end

    function button:FindMarkerIcon(currentMarker)
        for index, icon in ipairs(button.marker) do
            print("Index", index, "icon", icon:GetMarker())
            if icon:GetMarker() == currentMarker then
                return index, icon
            end
        end
    end

    function button:FindDropTarget(dropTarget)
        for index, registeredDropTarget in ipairs(button.dropTargets) do
            if registeredDropTarget == dropTarget then
                return index
            end
        end
    end

    function button:AddDropTarget(dropTarget)
        -- Avoid having the same drop target multiple times in the list
        local found = button:FindDropTarget(dropTarget)
        if found then
            return
        end

        table.insert(button.dropTargets, dropTarget)
    end

    function button:RemoveDropTarget(dropTarget)
        local position = button:FindDropTarget(dropTarget)
        if position then
            table.remove(button.dropTargets, position)
        end
    end

    function button:GetMouseoverDropTarget()
        for index, dropTarget in ipairs(button.dropTargets) do
            if dropTarget:IsMouseOver() then
                return index, dropTarget
            end
        end
    end

    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function()
        button:Drag()
    end)

    button:SetScript("OnDragStop", function()
        button:Drop()
    end)

    button:SetScript("OnClick", function()
        -- Just do nothing, only avoid a Lua Error
        button:SetMarkers({8,7,2,1,4,3})
    end)

    return button
end)