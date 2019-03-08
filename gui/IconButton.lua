local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("IconButton", function(self, parent, width, height, texture)
    local button = CreateFrame('Button', nil, parent, UIPanelButtonTemplate);
    self:InitWidget(button);
    self:SetObjSize(button, width, height);

    StdUi:ApplyBackdrop(button);
    StdUi:HookDisabledBackdrop(button);
    StdUi:HookHoverBorder(button);

    local background = button:CreateTexture(nil, "BACKGROUND")
    button.background = background
    background:SetTexture(texture)
    background:SetBlendMode("ADD")
    background:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    background:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)


    return button
end)