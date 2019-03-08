-- Module Button
local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("ModuleButton", function(self, parent, text, texture, actions)
    local width = 220
    local height = 48

    local button = CreateFrame("Button", nil, parent, UIPanelButtonTemplate)
    self:InitWidget(button)
    self:SetObjSize(button, width, height)

    button:SetBackdrop({bgFile = [[Interface\Buttons\WHITE8X8]],
                        edgeFile = [[Interface\Buttons\WHITE8X8]],
                        tile = true, tileSize = 16, edgeSize = 1,
                        insets = { left = 0, right = 0, top = 0, bottom = 0 }});
    button:SetBackdropColor(0.05, 0.05, 0.05, 1)
    button:SetBackdropBorderColor(0, 0, 0, 1)
    button:RegisterForClicks("AnyUp")

    local background = button:CreateTexture(nil, "BACKGROUND")
    button.background = background
    background:SetTexture(texture)
    background:SetBlendMode("ADD")
    background:SetPoint("TOP", button, "TOP")
    background:SetPoint("BOTTOM", button, "BOTTOM")
    background:SetPoint("LEFT", button, "LEFT")
    background:SetPoint("RIGHT", button, "RIGHT")

    local title = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.title = title
    title:SetHeight(height)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("CENTER")
    title:SetPoint("TOP", button, "TOP")
    title:SetPoint("LEFT", button, "LEFT", 5, 0)
    title:SetPoint("RIGHT", button, "RIGHT")
    title:SetPoint("BOTTOM", button, "BOTTOM")
    title:SetText(text)

    button:SetScript("OnEnter", function(button)
        button:SetBackdropBorderColor(1, 0.509, 0.058, 1)
    end)

    button:SetScript("OnLeave", function(button)
        button:SetBackdropBorderColor(0, 0, 0, 1)
    end)

    local menu = {}
    if actions then
        table.insert(menu, {
            text = "Wizard",
            notCheckable = 1,
            func = actions.wizard
        })

        table.insert(menu, {
            text = "Reset to defaults",
            notCheckable = 1,
            func = actions.reset
        })

        table.insert(menu, {
            text = " ",
            notClickable = 1,
            notCheckable = 1,
            func = nil
        })

        table.insert(menu, {
            text = "Share",
            notCheckable = 1,
            func = actions.share
        })

        table.insert(menu, {
            text = " ",
            notClickable = 1,
            notCheckable = 1,
            func = nil
        })

        table.insert(menu, {
            text = "Import",
            notCheckable = 1,
            func = actions.import
        })

        table.insert(menu, {
            text = "Export",
            notCheckable = 1,
            func = actions.export
        })

        table.insert(menu, {
            text = " ",
            notClickable = 1,
            notCheckable = 1,
            func = nil
        })

        table.insert(menu, {
            text = "Close",
            notCheckable = 1,
            func = function()
                DraduxAutoMarking:GetOptionsDropdown():Hide()
            end
        })
    end

    button:SetScript("OnClick", function(button, mouseButton)
        if mouseButton == "RightButton" and table.getn(menu) > 0 then
            L_EasyMenu(menu, DraduxAutoMarking:GetOptionsDropdown(), "cursor", 0, -15, "MENU")
            return
        end

        if actions.click then
            actions.click(button, mouseButton)
        end
    end)

    return button
end)