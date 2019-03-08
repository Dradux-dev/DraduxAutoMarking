SLASH_DRADUXAUTOMARKING1 = "/dam"


function SlashCmdList.DRADUXAUTOMARKING(cmd, editbox)
    DraduxAutoMarking:ToggleInterface()
end

-- Init
function DraduxAutoMarking:OnInitialize()
    self:RegisterEvent("ADDON_LOADED")
end

function DraduxAutoMarking:ADDON_LOADED(event, addonName)
    if event == "ADDON_LOADED" and addonName == "DraduxAutoMarking" then
        DraduxAutoMarking:InitializeScanner()
        DraduxAutoMarking:InitializeMarking()
        DraduxAutoMarking:InitializeWindow()

        self:UnregisterEvent("ADDON_LOADED")

        self:RegisterEvent("CHAT_MSG_ADDON")
        self:RegisterEvent("GROUP_ROSTER_UPDATE")
    end
end

function DraduxAutoMarking:EnableModule(name)
    local module = DraduxAutoMarking:GetModule(name)
    if module then
        module:Enable()
    end
end

function DraduxAutoMarking:DisableModule(name)
    local module = DraduxAutoMarking:GetModule(name)
    if module then
        module:Disable()
    end
end

function DraduxAutoMarking:CountMarkingModules()
    local count = 0

    for name, module in pairs(DraduxAutoMarking.modules) do
        if module["IsMarking"] and module:IsMarking() then
            count = count + 1
        end
    end

    return count
end

