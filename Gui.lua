local StdUi = LibStub("StdUi")

function DraduxAutoMarking:ToggleInterface()
    ViragDevTool_AddData(DraduxAutoMarking, "Toggle interface called")

    if not DraduxAutoMarking.window then
        DraduxAutoMarking:InitializeWindow()
    end

    if DraduxAutoMarking.window:IsShown() then
        DraduxAutoMarking.window:Hide()
    else
        DraduxAutoMarking.window:Show()
    end
end

function DraduxAutoMarking:InitializeWindow()
    local width = 950
    local height = 650

    local window = StdUi:Window(UIParent, "Dradux Auto Marking", width, height)
    window:SetPoint("CENTER")

    local scrollPanel, scrollFrame, scrollChild, scrollBar = StdUi:ScrollFrame(window, 660, height - 80)
    window.content = {
        panel = scrollPanel,
        frame = scrollFrame,
        child = scrollChild,
        bar = scrollBar,
        children = {}
    }
    StdUi:GlueTop(scrollPanel, window, 260, -40, "LEFT")
    scrollPanel:Hide()

    local textFrame = StdUi:TextFrame(window, 660, height - 80)
    window.textFrame = textFrame
    StdUi:GlueTop(textFrame, window, 260, -40, "LEFT")
    textFrame:Hide()

    local wizardFrame = StdUi:WizardFrame(window)
    window.wizardFrame = wizardFrame
    StdUi:GlueTop(wizardFrame, window, 260, -40, "LEFT")
    wizardFrame:Hide()

    window:Hide()
    DraduxAutoMarking.window = window

    local options_dropdown = CreateFrame("Frame", "PullButtonsOptionsDropDown", nil, "L_UIDropDownMenuTemplate")
    DraduxAutoMarking.options_dropdown = options_dropdown
end

function DraduxAutoMarking:AddMenuEntry(name, texture, module, dbModule)
    print("Adding menu entry", name, texture, module, dbModule)

    local actions = {
        click = function()
            module:ShowConfiguration()
        end,
        wizard = function()
            DraduxAutoMarking:Wizard(module, dbModule)
        end,
        reset = function()
            dbModule:SetDB(module:GetName(), nil)
            module:ShowConfiguration()
        end,
        share = function()
            print("DraduxAutoMarking - Share: Not implemented yet. Sorry")
        end,
        export = function()
            DraduxAutoMarking:Export(module:GetName(), dbModule:GetDB(module:GetName()))
        end,
        import = function()
            DraduxAutoMarking:Import(module:GetName(),
                function(db)
                    dbModule:SetDB(module:GetName(), db)
                end,
                function()
                    module:ShowConfiguration()
                end
            )
        end
    }

    local button = StdUi:ModuleButton(DraduxAutoMarking.window, name, texture, actions)

    if not DraduxAutoMarking.menu or table.getn(DraduxAutoMarking.menu) == 0 then
        DraduxAutoMarking.menu = {}
        StdUi:GlueTop(button, DraduxAutoMarking.window, 10, -40, "LEFT")
    else
        local lastButton = DraduxAutoMarking.menu[table.getn(DraduxAutoMarking.menu)]
        StdUi:GlueBelow(button, lastButton, 0, -2)
    end

    table.insert(DraduxAutoMarking.menu, button)
end

function DraduxAutoMarking:ClearContent()
    local window = DraduxAutoMarking.window

    for _, frame in ipairs(window.content.children) do
        frame:Hide()
    end

    window.content.children = {}
end

function DraduxAutoMarking:SortContent(compare)
    local window = DraduxAutoMarking.window
    table.sort(window.content.children, compare)

    local sorted = window.content.children
    DraduxAutoMarking:ClearContent()

    for index, frame in ipairs(sorted) do
        DraduxAutoMarking:AddContentFrame(frame)
    end
end

function DraduxAutoMarking:AddContentFrame(frame)
    local window = DraduxAutoMarking.window

    if not frame:IsShown() then
        frame:Show()
    end

    frame:ClearAllPoints()
    if table.getn(window.content.children) == 0 then
        StdUi:GlueTop(frame, window.content.child, 0, 0, "LEFT")
    else
        local lastChild = window.content.children[table.getn(window.content.children)]
        StdUi:GlueBelow(frame, lastChild, 0, -2)
    end

    table.insert(window.content.children, frame)
end

function DraduxAutoMarking:AddEnemyConfiguration(id, name, info, extraConfiguration, dbGetter)
    local window = DraduxAutoMarking.window

    local frame = StdUi:EnemyConfigurationFrame(window.content.child, id, name, info, extraConfiguration, dbGetter)
    DraduxAutoMarking:AddContentFrame(frame)

    return frame
end

function DraduxAutoMarking:GetOptionsDropdown()
    return DraduxAutoMarking.options_dropdown
end

function DraduxAutoMarking:ShowConfiguration(enemies, add)
    local window = DraduxAutoMarking.window
    window.textFrame:Hide()
    window.wizardFrame:Hide()
    window.content.panel:Show()

    DraduxAutoMarking:ClearContent()

    for id, entry in pairs(enemies) do
        local extraConfiguration
        if entry.specials then
            extraConfiguration = {}
            for _, specialData in pairs(entry.specials) do
                table.insert(extraConfiguration, {
                    gui = specialData.gui,
                    load = specialData.load,
                    save = specialData.save
                })
            end
        end

        add(entry.id, entry.name, entry.hideInfo, extraConfiguration)
    end

    DraduxAutoMarking:SortContent(function(a, b)
        return a:GetName() < b:GetName()
    end)
end

function DraduxAutoMarking:ShowTextFrame(text, okayAction)
    local window = DraduxAutoMarking.window
    window.content.panel:Hide()
    window.wizardFrame:Hide()

    window.textFrame:SetText(text)
    window.textFrame:SetOkay(okayAction)

    window.textFrame:Show()
end

function DraduxAutoMarking:ShowWizard(module, dbModule)
    local window = DraduxAutoMarking.window
    window.content.panel:Hide()
    window.textFrame:Hide()

    window.wizardFrame:SetModule(module)
    window.wizardFrame:SetDatabaseModule(dbModule)
    window.wizardFrame:SetEnemies(module.enemies)
    window.wizardFrame:Show()
end