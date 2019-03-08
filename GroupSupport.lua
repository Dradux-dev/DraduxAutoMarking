DraduxAutoMarking.prefix = "DraduxAM_GROUP"
DraduxAutoMarking.inCharge = true

local charge

function DraduxAutoMarking:SetWhoIsInCharge()
    DraduxAutoMarking:Log(charge, "SetWhoIsInCharge() called")
    local name
    local roll

    for unitName, unitRoll in pairs(charge.rolls) do
        if not name and not roll then
            name = unitName
            roll = unitRoll
        elseif unitRoll > roll or (unitRoll == roll and unitName < name) then
            name = unitName
            roll = unitRoll
        end
    end
    DraduxAutoMarking:Log(name, "Has the max roll")
    DraduxAutoMarking:Log(roll, "Is the max roll")

    local playerName, playerRealm = UnitFullName("player")
    local fullName = string.format("%s-%s", playerName, playerRealm)
    DraduxAutoMarking:Log(fullName, "Player name")

    DraduxAutoMarking:Log(charge, "Getting rid of old charge data")
    charge = nil
    if name == fullName then
        DraduxAutoMarking.inCharge = true
        DraduxAutoMarking:Log(DraduxAutoMarking.inCharge, "I am in charge")
    else
        DraduxAutoMarking.inCharge = false
        DraduxAutoMarking:Log(DraduxAutoMarking.inCharge, "Some one else is in charge")
    end

    if name then
        DraduxAutoMarking:SetChargeName(name)
        print(string.format("%s: %s is now in charge of marking", DraduxAutoMarking:GetName(), name))
    end
end

function DraduxAutoMarking:GROUP_ROSTER_UPDATE(event, ...)
    DraduxAutoMarking:Log(event, "Group Rotster Update")
    if not IsInGroup() and not IsInRaid() then
        print(string.format("%s: %s is now in charge of marking", DraduxAutoMarking:GetName(), select(1, UnitName("player"))))
        DraduxAutoMarking.inCharge = true
        DraduxAutoMarking:SetChargeName(UnitName("player"))
        DraduxAutoMarking:Log(DraduxAutoMarking.inCharge, "I am in charge, because I am alone")
    else
        if charge and charge.timer then
            DraduxAutoMarking:Log(charge, "Cancelling old timer")
            charge.timer:Cancel()
        end

        charge = {
            timer = nil,
            rolls = {}
        }
        DraduxAutoMarking:Log(charge, "Setup new charge data")

        local channel = "PARTY"
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            channel = "INSTANCE_CHAT"
        elseif IsInRaid() then
            channel = "RAID"
        end
        DraduxAutoMarking:Log(channel, "Communication channel is")

        local bonus = 0
        if UnitIsGroupLeader("player") then
            bonus = 100
        end
        DraduxAutoMarking:Log(bonus, "Actual bonus for the charge roll")

        local roll = fastrandom(1, 100) + bonus
        DraduxAutoMarking:Log(roll, "Sending my charge roll")
        C_ChatInfo.RegisterAddonMessagePrefix(DraduxAutoMarking.prefix)
        C_ChatInfo.SendAddonMessage(
            DraduxAutoMarking.prefix,
            string.format("CHARGE_ROLL %d", roll),
            channel
        )

        charge.timer = C_Timer.NewTimer(5, function()
            DraduxAutoMarking:SetWhoIsInCharge()
        end)
        DraduxAutoMarking:Log(charge, "Timer started")
    end
end

function DraduxAutoMarking:CHAT_MSG_ADDON(event, prefix, message, distribution, sender)
    if prefix == DraduxAutoMarking.prefix then
        DraduxAutoMarking:Log(message, "Received addon message")
        DraduxAutoMarking:Log(sender, "Sender is")

        local splitted = DraduxAutoMarking:SplitString(message, " ")
        DraduxAutoMarking:Log(splitted, "Splitted Message")

        if charge and splitted and splitted[1] == "CHARGE_ROLL" then
            charge.rolls[sender] = tonumber(splitted[2])
            DraduxAutoMarking:Log(charge, "Entered sender with roll")
        end
    end
end
