DraduxAutoMarking.logging = true

function DraduxAutoMarking:Log(var, message)
    if DraduxAutoMarking.logging and ViragDevTool_AddData then
        if not message then
            message = var
            var = nil
        end

        ViragDevTool_AddData(var, message)
    end
end