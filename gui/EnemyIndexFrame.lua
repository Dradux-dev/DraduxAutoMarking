-- Spells\AURARUNE8

local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("EnemyIndexFrame", function(self, parent, index)
    local width = 364
    local height = 75

    local frame = CreateFrame("Frame", nil, parent)
    self:InitWidget(frame)
    self:SetObjSize(frame, width, height)
    frame:SetBackdrop({bgFile = [[Interface\Buttons\WHITE8X8]],
                        edgeFile = [[Interface\Buttons\WHITE8X8]],
                        tile = true, tileSize = 16, edgeSize = 1,
                        insets = { left = 0, right = 0, top = 0, bottom = 0 }});
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0)
    frame:SetBackdropBorderColor(0, 0, 0, 0)

    frame.number = index
    frame.enemies = {}

    local indexIcon = frame:CreateTexture(nil, "BACKGROUND")
    frame.indexIcon = indexIcon
    indexIcon:SetTexture("Spells\\AURARUNE8")
    indexIcon:SetBlendMode("ADD")
    indexIcon:SetVertexColor(1, 0.509, 0.058, 1)
    indexIcon:SetWidth(48)
    indexIcon:SetHeight(48)
    StdUi:GlueTop(indexIcon, frame, 2, -2, "LEFT")

    local indexText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title = indexText
    indexText:SetJustifyH("CENTER")
    indexText:SetJustifyV("CENTER")
    indexText:SetTextColor(1, 1, 1, 1)
    indexText:SetText(index)
    indexText:SetPoint("CENTER", indexIcon, "CENTER")

    local bottomBorder = frame:CreateTexture(nil, "BACKGROUND")
    frame.bottomBorder = bottomBorder
    bottomBorder:SetTexture("Interface\\Buttons\\WHITE8X8")
    bottomBorder:SetBlendMode("ADD")
    bottomBorder:SetVertexColor(0.25, 0.25, 0.25, 1)
    bottomBorder:SetHeight(2)
    bottomBorder:SetWidth(width)
    StdUi:GlueBottom(bottomBorder, frame, 0, 0)

    function frame:HighlightNormal()
        local color = frame.originalBackdropBorderColor
        if color then
            frame:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
        end
    end

    function frame:HighlightMouseover()
        local r, g, b, a = frame:GetBackdropBorderColor()
        frame.originalBackdropBorderColor = {
            r = r,
            g = g,
            b = b,
            a = a
        }
        frame:SetBackdropBorderColor(1, 0.509, 0.058, 1)
    end

    function frame:FindEnemy(enemyFrame)
        for index, enemy in ipairs(frame.enemies) do
            if enemy == enemyFrame then
                return index
            end
        end
    end

    function frame:AddEnemy(enemyFrame)
        local found = frame:FindEnemy(enemyFrame)
        if not found then
            table.insert(frame.enemies, enemyFrame)
            table.sort(frame.enemies, function(a, b)
                if a:GetName() == b:GetName() then
                    return a:GetID() < b:GetID()
                end

                return a:GetName() < b:GetName()
            end)

            enemyFrame:SetParent(frame)
            frame:RearrangeEnemyFrames()
        end
    end

    function frame:RemoveEnemy(enemyFrame)
        local position = frame:FindEnemy(enemyFrame)
        if position then
            table.remove(frame.enemies, position)
            frame:RearrangeEnemyFrames()
        end
    end

    function frame:RearrangeEnemyFrames()
        local enemyCount = table.getn(frame.enemies)
        for index, enemyFrame in ipairs(frame.enemies) do
            local x = 60 + ((index + 1) % 2) * 152
            local row = math.floor((index / 2) - 0.5)
            local y = -(2 + row * 62)
            StdUi:GlueTop(enemyFrame, frame, x, y, "LEFT")
        end

        local rows = math.floor((enemyCount / 2) + 0.5)
        local height = math.max(75, 75 + (rows - 1) * 62)
        frame:SetHeight(height)
    end

    function frame:HasEnemy(enemyID)
        for index, enemyFrame in ipairs(frame.enemies) do
            if enemyFrame:GetID() == enemyID then
                 return true
            end
        end

        return false
    end

    function frame:GetCurrentMarker()
        return parent:GetCurrentMarker()
    end

    return frame
end)