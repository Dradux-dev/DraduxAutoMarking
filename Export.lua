function DraduxAutoMarking:Export(moduleName, db)
    local t = {
        moduleName = moduleName,
        db = db
    }

    local str = DraduxAutoMarking:TableToString(t)
    DraduxAutoMarking:ShowTextFrame(str, function()
        DraduxAutoMarking.window.textFrame:Hide()
    end)
end
