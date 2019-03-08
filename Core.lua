local DraduxAutoMarking = LibStub("AceAddon-3.0"):NewAddon("DraduxAutoMarking", "AceConsole-3.0", "AceEvent-3.0")
_G["DraduxAutoMarking"] = DraduxAutoMarking

DraduxAutoMarking.version = {
    major = 0,
    minor = 1,
    hotfix = 0
}

function DraduxAutoMarking:GetVersionString()
    local version = DraduxAutoMarking.version
    return string.format("%d.%d.%d", version.major)
end