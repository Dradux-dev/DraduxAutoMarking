-- Enemy Configuration Frame
local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("EnemyConfigurationFrame", function(self, parent, id, name, info, extraConfiguration, dbGetter)
    local width = 640
    local height = 115

    local frame = CreateFrame("Frame", nil, parent)
    self:InitWidget(frame)
    self:SetObjSize(frame, width, height)

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
    title:SetText(name)

    if not info.hide and MethodDungeonTools then
        local info = StdUi:MdtInfoButton(frame, id, info.mdtDungeon)
        StdUi:GlueRight(info, title, 5, 0)
    end

    local check = StdUi:IconButton(frame, 16, 16, "Interface\\Addons\\DraduxAutoMarking\\media\\check")
    frame.check = check
    check:SetScript("OnClick", function()
        frame:Save()
    end)
    check:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -22, -10)


    local dismiss = StdUi:IconButton(frame, 16, 16, "Interface\\Addons\\DraduxAutoMarking\\media\\cross")
    frame.dismiss = dismiss
    dismiss:SetScript("OnClick", function()
        frame:Load()
    end)
    StdUi:GlueLeft(dismiss, check, -4, 0)

    local skull = StdUi:MarkerConfigurationFrame(frame, 8)
    frame.skull = skull
    StdUi:GlueBelow(skull, title, 0, -10, "LEFT")

    local cross = StdUi:MarkerConfigurationFrame(frame, 7)
    frame.cross = cross
    StdUi:GlueRight(cross, skull, 15, 0)

    local square = StdUi:MarkerConfigurationFrame(frame, 6)
    frame.square = square
    StdUi:GlueRight(square, cross, 15, 0)

    local moon = StdUi:MarkerConfigurationFrame(frame, 5)
    frame.moon = moon
    StdUi:GlueRight(moon, square, 15, 0)

    local triangle = StdUi:MarkerConfigurationFrame(frame, 4)
    frame.triangle = triangle
    StdUi:GlueBelow(triangle, skull, 0, -5, "LEFT")

    local diamond = StdUi:MarkerConfigurationFrame(frame, 3)
    frame.diamond = diamond
    StdUi:GlueRight(diamond, triangle, 15, 0)

    local circle = StdUi:MarkerConfigurationFrame(frame, 2)
    frame.circle = circle
    StdUi:GlueRight(circle, diamond, 15, 0)

    local star = StdUi:MarkerConfigurationFrame(frame, 1)
    frame.star = star
    StdUi:GlueRight(star, circle, 15, 0)

    if extraConfiguration then
        for _, config in ipairs(extraConfiguration) do
            if config.gui then
                config.gui(frame)
            end
        end
    end

    local idtext = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.idtext = idtext
    idtext:SetJustifyH("RIGHT")
    idtext:SetJustifyV("CENTER")
    idtext:SetTextColor(1, 1, 1, 1)
    idtext:SetText("ID: "  .. id)
    idtext:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -22, 10)

    frame.id = id
    check:Hide()
    dismiss:Hide()

    local lut = {
        frame.star,
        frame.circle,
        frame.diamond,
        frame.triangle,
        frame.moon,
        frame.square,
        frame.cross,
        frame.skull
    }

    function frame:GetDB()
        return dbGetter()
    end

    function frame:Save()
        local db = frame:GetDB()

        check:Hide()
        dismiss:Hide()

        -- Save that suff!
        local npc = db[frame.id]
        npc.markers = {}
        for marker=1, 8 do
            local markerFrame = lut[marker]
            if markerFrame then
                table.insert(npc.markers, {
                    index = marker,
                    allowed = markerFrame.allowed:GetChecked(),
                    priority = markerFrame.priority:GetValue()
                })
            end
        end

        -- Call extraConfiguration save
        if extraConfiguration then
            for _, config in ipairs(extraConfiguration) do
                if config.save then
                    config.save(npc, frame)
                end
            end
        end
    end

    function frame:Load()
        local db = frame:GetDB()

        check:Hide()
        dismiss:Hide()

        -- Load that suff!
        local npc = db[frame.id]
        if npc and npc.markers then
            for _, marker in ipairs(npc.markers) do
                local markerFrame = lut[marker.index]
                if markerFrame then
                    markerFrame.allowed:SetChecked(marker.allowed)
                    markerFrame.priority:SetValue(marker.priority or 0)
                end
            end
        end

        -- Call extraConfiguration load
        if npc and extraConfiguration then
            for _, config in ipairs(extraConfiguration) do
                if config.save then
                    config.load(npc, frame)
                end
            end
        end
    end

    function frame:Changed()
        check:Show()
        dismiss:Show()
    end

    function frame:GetName()
        return name
    end

    return frame
end)