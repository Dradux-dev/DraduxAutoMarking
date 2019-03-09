SLASH_DRADUXAUTOMARKING1 = "/dam"

local commands = {
    missing = {
        desc = "Shows all enemies that were found during marking sessions, which are not known by any marking module.",
        func = function()
            DraduxAutoMarking:ShowMissingEnemies()
        end
    },
    affixes = {
        desc = "Shows a list of all available affixes with it's corresponding affix id's.",
        func = function()
            local affixes = DraduxAutoMarking:GetModule("Affixes")
            if affixes then
                affixes:Dump()
            end
        end
    },
    monitor = {
        desc = "Shows a monitor, where you can examine which markers are used and for what they are used.",
        func = function()
            DraduxAutoMarking:ToggleMonitor()
        end
    },
    marking = {
        desc = "Shows a list of all modules, that are currently actively marking.",
        func = function()
            DraduxAutoMarking:PrintMarkingModules()
        end
    },
    help = {
        desc = "Shows this help.",
        func = function()
            DraduxAutoMarking:PrintHelp()
        end
    }
}


function SlashCmdList.DRADUXAUTOMARKING(cmd, editbox)
    local argList = DraduxAutoMarking:SplitString(cmd, " ")
    local request = argList[1]
    table.remove(argList, 1)

    if commands[request] then
        commands[request].func(argList)
    else
        DraduxAutoMarking:ToggleInterface()
    end

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

function DraduxAutoMarking:PrintMarkingModules()
    for name, module in pairs(DraduxAutoMarking.modules) do
        if module["IsMarking"] and module:IsMarking() then
            print(name)
        end
    end
end

function DraduxAutoMarking:GetDB()
    if not DraduxAutoMarking.db then
        DraduxAutoMarking.db = LibStub("AceDB-3.0"):New("DraduxAutoMarkingDB", DraduxAutoMarking.defaultVars)
    end

    return DraduxAutoMarking.db.profile
end

function DraduxAutoMarking:PrintHelp()
    local orange = "|cFFFF820F"
    local green = "|cFF5FEC82"
    local white = "|cFFFFFFFF"
    print(string.format("%s%s%s: %s", orange, SLASH_DRADUXAUTOMARKING1, white, "Toggles the interface"))
    for command, info in pairs(commands) do
        print(string.format("%s%s %s%s%s: %s", orange, SLASH_DRADUXAUTOMARKING1, green, command, white, info.desc))
    end
end