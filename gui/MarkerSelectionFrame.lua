local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("MarkerSelectionFrame", function(self, parent, id, name)
    local width = 660
    local height = 450

    local frame = CreateFrame("Frame", nil, parent)
    self:InitWidget(frame)
    self:SetObjSize(frame, width, height)

    frame:SetBackdrop({ bgFile = [[Interface\Buttons\WHITE8X8]],
                        edgeFile = [[Interface\Buttons\WHITE8X8]],
                        tile = true, tileSize = 16, edgeSize = 1,
                        insets = { left = 0, right = 0, top = 0, bottom = 0 }});
    frame:SetBackdropColor(0.15, 0.15, 0.15, 0.7)
    frame:SetBackdropBorderColor(0, 0, 0, 1)
    frame.id = id

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title = title
    title:SetJustifyH("LEFT")
    title:SetJustifyV("CENTER")
    title:SetTextColor(1, 1, 1, 1)
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
    title:SetText(name)

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

    local lastElement
    frame.markerSelecttionRows = {}
    for i=1,8 do
        local selectionRow  = StdUi:MarkerSelectionRow(frame, 9 - i)
        table.insert(frame.markerSelecttionRows, selectionRow)
        if i == 1 then
            StdUi:GlueTop(selectionRow, frame, 100, -100, "LEFT")
        else
            StdUi:GlueBelow(selectionRow, lastElement, 0, -2)
        end

        lastElement = selectionRow
    end

    local model = CreateFrame("PlayerModel", nil, frame,"ModelWithControlsTemplate")
    frame.model = model
    model:SetSize(225, 300)
    model:SetDisplayInfo(39490)
    model:SetScript("OnEnter", nil)
    StdUi:GlueTop(model, frame, 400, -100, "LEFT")

    function frame:Selected(row, marker)
        for i=1, 8 do
            local selectionRow = frame.markerSelecttionRows[i]
            if row ~= selectionRow then
                selectionRow:Deselect(marker)
            end
        end
    end

    function frame:DeselectAll()
        for i=1, 8 do
            local selectionRow = frame.markerSelecttionRows[i]
            selectionRow:DeselectAll()
        end
    end

    function frame:SetName(name)
        title:SetText(name)
    end

    function frame:SetID(id)
        frame.id = id
    end

    function frame:SetDisplayID(displayID)
        frame.model:SetDisplayInfo(displayID or 39490)
        frame.model:SetFacing(-(math.pi / 6))
    end

    function frame:GetName()
        return title:GetText()
    end

    function frame:GetID()
        return frame.id
    end

    function frame:GetValue(marker)
        for i=1, 8 do
            local selectionRow = frame.markerSelecttionRows[i]
            if selectionRow:IsSelected(marker) then
                return selectionRow:GetValue()
            end
        end

        return 0
    end

    function frame:SetMarker(marker, row)
        local selectionRow = frame.markerSelecttionRows[row]
        if selectionRow then
            selectionRow:Select(marker)
        end
    end

    return frame
end)