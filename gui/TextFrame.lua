local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("TextFrame", function(self, parent, width, height)
    local frame = StdUi:Frame(parent, width, height)
    self:InitWidget(frame);
    self:SetObjSize(frame, width, height);

    local button = StdUi:Button(frame, 110, 40, "Okay")
    frame.button = button
    StdUi:GlueBottom(button, frame, 0, 20)

    local editBox = StdUi:SimpleEditBox(frame, 640, height - 80)
    frame.editBox = editBox
    editBox:SetMultiLine(true)
    --StdUi:GlueTop(editBox, scrollChild, 0, 0)

    local scrollPanel, scrollFrame, scrollChild, scrollBar = StdUi:ScrollFrame(frame, 660, height - 80, editBox)
    frame.scrollPanel = scrollPanel
    frame.scrollFrame = scrollFrame
    frame.scrollBar = scrollBar
    frame.scrollChild = scrollChild
    StdUi:GlueBottom(scrollPanel, frame, 0, 80)
    editBox:SetAllPoints()

    function frame:SetText(text)
        editBox:SetText(text)
    end

    function frame:GetText()
        return editBox:GetText()
    end

    function frame:SetOkay(func)
        button:SetScript("OnClick", func)
    end

    return frame
end)