function DraduxAutoMarking:Import(moduleName, setter, post)
    DraduxAutoMarking:ShowTextFrame("", function()
        local textFrame = DraduxAutoMarking.window.textFrame

        local str = textFrame:GetText()
        local t = DraduxAutoMarking:StringToTable(str)
        if not t then
            return
        end

        if not t.moduleName then
            return
        end

        if t.moduleName ~= moduleName then
            return
        end

        setter(t.db or {})
        textFrame:Hide()

        if post then
            post()
        end
    end)
end