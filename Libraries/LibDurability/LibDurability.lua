-- LibDurability by Funkeh, embedded for group durability interoperability.
local LD = LibStub:NewLibrary("LibDurability", 4)
if not LD then return end

LD.throttleTable = LD.throttleTable or {
    RAID = 0, PARTY = 0, INSTANCE_CHAT = 0,
}
LD.throttleSendTable = LD.throttleSendTable or {
    RAID = 0, PARTY = 0, INSTANCE_CHAT = 0,
}
LD.callbackMap = LD.callbackMap or {}
LD.frame = LD.frame or CreateFrame("Frame")

local throttleTable = LD.throttleTable
local throttleSendTable = LD.throttleSendTable
local callbackMap = LD.callbackMap
local frame = LD.frame
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local playerName = UnitNameUnmodified("player")

local function GetDurability()
    local currentTotal, maximumTotal, broken = 0, 0, 0
    for slot = 1, 18 do
        local current, maximum = GetInventoryItemDurability(slot)
        if current and maximum then
            currentTotal = currentTotal + current
            maximumTotal = maximumTotal + maximum
            if maximum > 0 and current == 0 then
                broken = broken + 1
            end
        end
    end
    if maximumTotal == 0 then return 0, 0 end
    return currentTotal / maximumTotal * 100, broken
end
LD.GetDurability = GetDurability

C_ChatInfo.RegisterAddonMessagePrefix("LibDRBLT")
local IsSecret = issecretvalue or function() return false end
frame:SetScript("OnEvent", function(_, event, prefix, message, channel, sender)
    if event == "READY_CHECK" then
        local percent, broken = GetDurability()
        SendAddonMessage(
            "LibDRBLT", string.format("%d,%d", percent, broken),
            IsInGroup(2) and "INSTANCE_CHAT"
                or IsInRaid() and "RAID" or "PARTY")
    elseif not IsSecret(message) and prefix == "LibDRBLT"
        and throttleTable[channel]
    then
        if message == "R" then
            local now = GetTime()
            if now - throttleTable[channel] > 4 then
                throttleTable[channel] = now
                local percent, broken = GetDurability()
                SendAddonMessage(
                    "LibDRBLT", string.format("%d,%d", percent, broken),
                    channel)
            end
            return
        end
        local percent, broken = message:match("^(%d+),(%d+)$")
        percent, broken = tonumber(percent), tonumber(broken)
        if percent and broken then
            for _, callback in next, callbackMap do
                callback(
                    percent, broken, Ambiguate(sender, "none"), channel)
            end
        end
    end
end)
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("READY_CHECK")

function LD:RequestDurability(channel)
    if channel and not throttleSendTable[channel] then
        error("LibDurability: Incorrect channel type for :RequestDurability.")
    end
    if not channel and IsInGroup() then
        channel = IsInGroup(2) and "INSTANCE_CHAT"
            or IsInRaid() and "RAID" or "PARTY"
    end
    local percent, broken = GetDurability()
    for _, callback in next, callbackMap do
        callback(percent, broken, playerName, channel)
    end
    if channel then
        local now = GetTime()
        if now - throttleSendTable[channel] > 4 then
            throttleSendTable[channel] = now
            SendAddonMessage("LibDRBLT", "R", channel)
        end
    end
end

function LD:Register(addon, callback)
    if not addon or addon == LD then
        error("LibDurability: You must pass your own addon name or object.")
    end
    if type(callback) == "string" then
        callbackMap[addon] = function(...)
            addon[callback](addon, ...)
        end
    elseif type(callback) == "function" then
        callbackMap[addon] = callback
    else
        error("LibDurability: Incorrect function type for :Register.")
    end
end

function LD:Unregister(addon)
    if not addon or addon == LD then
        error("LibDurability: You must pass your own addon name or object.")
    end
    callbackMap[addon] = nil
end
