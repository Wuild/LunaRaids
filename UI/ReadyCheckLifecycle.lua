local _, Raid = ...
local ReadyCheck = Raid:GetModule("ReadyCheck")
function Raid:HandleReadyCheckStarted(_, initiator, timeout)
    for _, menu in ipairs({
        self.selectionMenu,
        self.roleMenu,
        self.raidPlayerMenu,
    }) do
        if menu then menu:Hide() end
    end
    self:RaiseBlizzardReadyCheckDialog()
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            Raid:RaiseBlizzardReadyCheckDialog()
        end)
    end
    self.readyCheckActiveUntil =
        GetTime() + (tonumber(timeout) or 35)
    self:BroadcastReadyCheckStatus()
    local caller
    if not (issecretvalue and issecretvalue(initiator))
        and type(initiator) == "string" and initiator ~= ""
    then
        for _, player in ipairs(self.roster or {}) do
            if player.guid == initiator then
                caller = player.name
                break
            end
        end
        if not caller and UnitExists and UnitExists(initiator) then
            caller = GetUnitName(initiator, true) or UnitName(initiator)
        elseif not caller and not initiator:find("^Player%-") then
            caller = initiator
        end
    end
    caller = caller or self.pendingReadyCheckCaller
    self.pendingReadyCheckCaller = nil
    self:ShowReadyCheckWindow(timeout or 35, false, caller)
end

function Raid:HandleReadyCheckConfirm(_, unit, response)
    local popupShown = self.readyCheckWindow
        and self.readyCheckWindow:IsShown()
    local embeddedShown = self.raidStatusView
        and self.raidStatusView:IsShown()
    if not popupShown and not embeddedShown then return end
    if issecretvalue and issecretvalue(unit) then return end
    local name = UnitName(unit) or unit
    if not name then return end
    local shortName = name:match("^[^-]+") or name
    for _, player in ipairs(self.roster or {}) do
        local playerShort = player.name:match("^[^-]+") or player.name
        if player.name == name or playerShort == shortName then
            self.readyCheckStatus[player.name] = response == true
            break
        end
    end
    self:ScheduleReadyCheckRefresh()
end

function Raid:HandleReadyCheckFinished()
    self.readyCheckActiveUntil = nil
    local frame = self.readyCheckWindow
    if self.raidStatusView and self.raidStatusView:IsShown() then
        self:RefreshReadyCheckWindow(self.raidStatusView)
    end
    if not frame or not frame:IsShown() then return end
    frame.endTime = nil
    frame.Title:SetText(Raid.L.READY_CHECK_COMPLETE)
    self:RefreshReadyCheckWindow()
    if frame.dismissPinned then return end
    frame.dismissPending = true
    frame.dismissHovered = frame:IsMouseOver() or nil
    frame.dismissAt = GetTime()
        + (self.db.readyCheck.holdDuration or 15)
end

function Raid:HandleReadyCheckAuraUpdate(_, unit)
    local windowShown = self.readyCheckWindow
        and self.readyCheckWindow:IsShown()
    local embeddedShown = self.raidStatusView
        and self.raidStatusView:IsShown()
    local peerCheckActive = self.readyCheckActiveUntil
        and self.readyCheckActiveUntil > GetTime()
    if not windowShown and not embeddedShown and not peerCheckActive
    then
        return
    end
    if unit == "player" then
        local now = GetTime()
        if now - (self.lastReadyCheckBroadcast or -10) >= 1 then
            self.lastReadyCheckBroadcast = now
            self:BroadcastReadyCheckStatus()
        end
    end
    if unit then self:GetReadyCheckAuras(unit, true) end
    if windowShown or embeddedShown then
        self:ScheduleReadyCheckRefresh()
    end
end

function Raid:HandleDurabilityChanged()
    if self.durabilityBroadcastPending then return end
    self.durabilityBroadcastPending = true
    local function Refresh()
        Raid.durabilityBroadcastPending = nil
        Raid:RequestGroupDurability()
        Raid:ScheduleReadyCheckRefresh()
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(.35, Refresh)
    else
        Refresh()
    end
end

local function Forward(method)
    return function(event, ...)
        Raid[method](Raid, event, ...)
    end
end

function ReadyCheck:OnEnable()
    self:RegisterEvent("READY_CHECK", Forward("HandleReadyCheckStarted"))
    self:RegisterEvent(
        "READY_CHECK_CONFIRM", Forward("HandleReadyCheckConfirm"))
    self:RegisterEvent(
        "READY_CHECK_FINISHED", Forward("HandleReadyCheckFinished"))
    self:RegisterEvent("UNIT_AURA", Forward("HandleReadyCheckAuraUpdate"))
    self:RegisterEvent(
        "UNIT_INVENTORY_CHANGED",
        Forward("HandleReadyCheckAuraUpdate"))
    self:RegisterEvent(
        "UPDATE_INVENTORY_DURABILITY",
        Forward("HandleDurabilityChanged"))
    self:RegisterEvent("MERCHANT_CLOSED", Forward("HandleDurabilityChanged"))
    Raid:InitializeLibDurability()
end

function ReadyCheck:OnDisable()
    self:UnregisterAllEvents()
end

