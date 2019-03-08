local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("MdtInfoButton", function(self, parent, npc_id, dungeon_id)
    local width = 16
    local height = 16

    local button = CreateFrame("Button", nil, parent, UIPanelButtonTemplate)
    self:InitWidget(button)
    self:SetObjSize(button, width, height)
    local background = button:CreateTexture(nil, "BACKGROUND")
    button.background = background
    background:SetTexture("Interface\\Addons\\DraduxAutoMarking\\media\\info")
    background:SetBlendMode("ADD")
    background:SetPoint("TOP", button, "TOP")
    background:SetPoint("BOTTOM", button, "BOTTOM")
    background:SetPoint("LEFT", button, "LEFT")
    background:SetPoint("RIGHT", button, "RIGHT")

    button:SetScript("OnClick", function()
        local function setSubLevel(key)
            MethodDungeonTools:SetCurrentSubLevel(key)
            MethodDungeonTools:UpdateMap()
            MethodDungeonTools:ZoomMap(1,true)
        end

        local function findBlip(dungeon_id, npc_id)
            MethodDungeonTools:ShowInterface()
            MethodDungeonTools:UpdateToDungeon(dungeon_id)

            local subLevels = MethodDungeonTools:GetDungeonSublevels()[dungeon_id]
            for index, name in ipairs(subLevels) do
                setSubLevel(index)
                local dungeonEnemyBlips = MethodDungeonTools:GetDungeonEnemyBlips()
                for index, blip in ipairs(dungeonEnemyBlips) do
                    local enemyID = MethodDungeonTools.dungeonEnemies[dungeon_id][blip.enemyIdx].id
                    if npc_id == enemyID then
                        return blip
                    end
                end
            end
        end

        local blip = findBlip(dungeon_id, npc_id)
        if blip then
            MethodDungeonTools:ShowEnemyInfoFrame(blip)
        else
            MethodDungeonTools:HideInterface()
        end
    end)

    return button
end)