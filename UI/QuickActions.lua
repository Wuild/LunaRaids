local _, Raid = ...
local UI = Raid.UI
local ICONS = UI.ICONS
local L = Raid.L
local THEME = UI.THEME

local MUTED, WHITE = UI.MUTED, UI.WHITE
local SetPixelHeight = UI.SetPixelHeight
local PixelSetSize = UI.PixelSetSize
local Font = UI.Font
local Button = UI.Button
local AddButtonIcon = UI.AddButtonIcon
local AddButtonTooltip = UI.AddButtonTooltip
local Panel = UI.Panel
local ShowSelectionMenu = UI.ShowSelectionMenu

local function StyleQuickButton(button)
    button.borderless = true
    button.baseColor = { unpack(THEME.surface) }
    button.baseBorder = { 0, 0, 0, 0 }
    button:SetBackdropColor(unpack(button.baseColor))
    button:SetBackdropBorderColor(0, 0, 0, 0)
    button.Text:SetTextColor(unpack(THEME.text))
end

function Raid:CreateQuickActionBar()
    if self.quickActionBar then return self.quickActionBar end
    local saved = self.db.quickBar
    local bar = Panel(UIParent)
    PixelSetSize(bar, 430, 42)
    bar:SetPoint(
        saved.point or "CENTER", UIParent,
        saved.point or "CENTER", saved.x or 0, saved.y or 0)
    bar:SetFrameStrata("MEDIUM")
    bar:SetScale(self:GetHUDScale())
    bar:SetClampedToScreen(true)
    bar:SetMovable(true)
    bar:EnableMouse(true)

    bar.HandleBackground = bar:CreateTexture(nil, "ARTWORK")
    bar.HandleBackground:SetTexture(WHITE)
    bar.HandleBackground:SetPoint("TOPLEFT", 1, -1)
    bar.HandleBackground:SetPoint("BOTTOMLEFT", 1, 1)
    bar.HandleBackground:SetWidth(88)
    bar.HandleBackground:SetVertexColor(unpack(THEME.header))
    bar.Handle = CreateFrame("Frame", nil, bar)
    bar.Handle:SetPoint("TOPLEFT", 1, -1)
    bar.Handle:SetPoint("BOTTOMLEFT", 1, 1)
    bar.Handle:SetWidth(88)
    bar.Handle:EnableMouse(true)
    bar.Handle:RegisterForDrag("LeftButton")
    bar.Handle:SetScript(
        "OnDragStart", function() bar:StartMoving() end)
    bar.Handle:SetScript("OnDragStop", function()
        bar:StopMovingOrSizing()
        local point, _, _, x, y = bar:GetPoint(1)
        Raid.db.quickBar.point = point
        Raid.db.quickBar.x, Raid.db.quickBar.y = x, y
    end)
    bar.Handle:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            bar:ClearAllPoints()
            bar:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            Raid.db.quickBar.point = "CENTER"
            Raid.db.quickBar.x, Raid.db.quickBar.y = 0, 0
        end
    end)
    bar.Handle:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(L.RAID_TOOLS)
        GameTooltip:AddLine(
            L.DRAG_RESET_POSITION,
            MUTED[1], MUTED[2], MUTED[3], true)
        GameTooltip:Show()
    end)
    bar.Handle:HookScript(
        "OnLeave", function() GameTooltip:Hide() end)
    bar.Handle.Icon = bar.Handle:CreateTexture(nil, "ARTWORK")
    bar.Handle.Icon:SetTexture(ICONS.BRAND)
    PixelSetSize(bar.Handle.Icon, 22, 22)
    bar.Handle.Icon:SetPoint("LEFT", 8, 0)
    bar.Handle.Title = Font(bar.Handle, 9, "accent", L.RAID_TOOLS_COMPACT)
    bar.Handle.Title:SetPoint("LEFT", bar.Handle.Icon, "RIGHT", 6, 0)

    local actions = {
        {
            label = L.ACTION_READY,
            icon = ICONS.READY,
            title = L.READY_CHECK,
            detail = L.READY_CHECK_DESC,
            action = function() Raid:StartReadyCheck() end,
            rightAction = function()
                Raid:ShowPinnedReadyCheckWindow()
            end,
        },
        {
            label = L.ACTION_ROLES,
            icon = ICONS.ROLES,
            title = L.ROLE_CHECK,
            detail = L.ROLE_CHECK_DESC,
            action = function() Raid:StartRoleCheck() end,
        },
        {
            label = L.ACTION_PULL_10,
            icon = ICONS.COOLDOWNS,
            title = L.PULL_TIMER,
            detail = L.PULL_TIMER_DESC,
            action = function() Raid:StartPullCountdown(10) end,
        },
        {
            label = L.ACTION_BREAK_5,
            icon = ICONS.BREAK,
            title = L.BREAK_TIMER,
            detail = L.BREAK_TIMER_DESC,
            action = function() Raid:StartBreakTimer(5) end,
            rightAction = function(button)
                ShowSelectionMenu(
                    button,
                    {
                        { 5, L.MINUTES_5 },
                        { 10, L.MINUTES_10 },
                        { 15, L.MINUTES_15 },
                    },
                    5,
                    function(minutes)
                        Raid:StartBreakTimer(minutes)
                    end,
                    156)
            end,
            rightDetail = L.RIGHT_CLICK_BREAK,
        },
        {
            label = L.ANNOUNCE,
            icon = ICONS.ANNOUNCE,
            title = L.ANNOUNCE_ASSIGNMENTS,
            detail = L.ANNOUNCE_ASSIGNMENTS_DESC,
            action = function() Raid:AnnounceAssignments() end,
            rightAction = function(button)
                Raid:ShowAnnouncementChannelMenu(button, function(channel)
                    Raid:AnnounceAssignments(channel)
                end)
            end,
            rightDetail = L.ANNOUNCE_CHANNEL_PICKER_DESC,
        },
        {
            label = L.ACTION_ASSIGN,
            icon = ICONS.ASSIGNMENTS,
            title = L.RAID_ASSIGNMENTS,
            detail = L.RAID_ASSIGNMENTS_DESC,
            action = function()
                Raid:CreateUI()
                if Raid.settingsView and Raid.settingsView:IsShown() then
                    Raid:ExitSettingsView()
                end
                Raid.frame:Show()
                Raid:SetWorkspaceMode("ASSIGNMENTS")
            end,
        },
    }
    bar.Actions = {}
    local previous
    for index, entry in ipairs(actions) do
        local button = Button(bar, entry.label, 106, 30)
        local action, rightAction =
            entry.action, entry.rightAction
        if previous then
            button:SetPoint("LEFT", previous, "RIGHT", 4, 0)
        else
            button:SetPoint("LEFT", bar.Handle, "RIGHT", 2, 0)
        end
        AddButtonIcon(button, entry.icon, 16)
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        button:SetScript("OnClick", function(_, mouseButton)
            if mouseButton == "RightButton" and rightAction then
                rightAction(button)
            else
                action()
            end
        end)
        button.tooltipAnchorFrame = bar
        AddButtonTooltip(
            button, entry.title,
            entry.detail .. (
                entry.rightDetail
                or rightAction
                    and L.RIGHT_CLICK_PIN_RESULTS
                or ""))
        StyleQuickButton(button)
        bar.Actions[index] = button
        previous = button
    end
    bar.BossNav = CreateFrame("Frame", nil, bar)
    bar.BossNav:SetPoint("TOPLEFT", bar, "TOPLEFT", 4, -40)
    bar.BossNav:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -4, 4)
    bar.BossNav.Background =
        bar.BossNav:CreateTexture(nil, "BACKGROUND")
    bar.BossNav.Background:SetTexture(WHITE)
    bar.BossNav.Background:SetAllPoints()
    bar.BossNav.Background:SetVertexColor(unpack(THEME.footer))
    bar.BossNav.TopLine = bar.BossNav:CreateTexture(nil, "ARTWORK")
    bar.BossNav.TopLine:SetTexture(WHITE)
    bar.BossNav.TopLine:SetPoint("TOPLEFT")
    bar.BossNav.TopLine:SetPoint("TOPRIGHT")
    SetPixelHeight(bar.BossNav.TopLine, 1)
    bar.BossNav.TopLine:SetVertexColor(unpack(THEME.border))
    bar.BossNav.Previous = Button(bar.BossNav, "", 28, 24)
    StyleQuickButton(bar.BossNav.Previous)
    bar.BossNav.Previous:SetPoint("LEFT", 4, -1)
    bar.BossNav.Previous.Icon =
        bar.BossNav.Previous:CreateTexture(nil, "ARTWORK")
    bar.BossNav.Previous.Icon:SetTexture(
        ICONS.PREVIOUS)
    PixelSetSize(bar.BossNav.Previous.Icon, 16, 16)
    bar.BossNav.Previous.Icon:SetPoint("CENTER")
    bar.BossNav.Previous:SetScript(
        "OnClick", function() Raid:NavigateBoss(-1) end)
    bar.BossNav.Previous.tooltipAnchorFrame = bar
    AddButtonTooltip(
        bar.BossNav.Previous, L.PREVIOUS_BOSS,
        L.PREVIOUS_BOSS_DESC)
    bar.BossNav.Next = Button(bar.BossNav, "", 28, 24)
    StyleQuickButton(bar.BossNav.Next)
    bar.BossNav.Next:SetPoint("RIGHT", -4, -1)
    bar.BossNav.Next.Icon =
        bar.BossNav.Next:CreateTexture(nil, "ARTWORK")
    bar.BossNav.Next.Icon:SetTexture(
        ICONS.NEXT)
    PixelSetSize(bar.BossNav.Next.Icon, 16, 16)
    bar.BossNav.Next.Icon:SetPoint("CENTER")
    bar.BossNav.Next:SetScript(
        "OnClick", function() Raid:NavigateBoss(1) end)
    bar.BossNav.Next.tooltipAnchorFrame = bar
    AddButtonTooltip(
        bar.BossNav.Next, L.NEXT_BOSS,
        L.NEXT_BOSS_DESC)
    bar.BossNav.Announce = Button(bar.BossNav, "", 28, 24)
    bar.BossNav.Announce:SetPoint(
        "RIGHT", bar.BossNav.Next, "LEFT", -4, 0)
    StyleQuickButton(bar.BossNav.Announce)
    AddButtonIcon(bar.BossNav.Announce, ICONS.ANNOUNCE, 15)
    bar.BossNav.Announce.ActionIcon:ClearAllPoints()
    bar.BossNav.Announce.ActionIcon:SetPoint("CENTER")
    bar.BossNav.Announce:RegisterForClicks(
        "LeftButtonUp", "RightButtonUp")
    bar.BossNav.Announce:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            Raid:ShowAnnouncementChannelMenu(self, function(channel)
                Raid:AnnounceAssignments(channel)
            end)
            return
        end
        Raid:AnnounceAssignments()
    end)
    bar.BossNav.Announce.tooltipAnchorFrame = bar
    AddButtonTooltip(
        bar.BossNav.Announce, L.ANNOUNCE_ASSIGNMENTS,
        L.ANNOUNCE_ASSIGNMENTS_DESC .. L.ANNOUNCE_CHANNEL_PICKER_DESC)
    bar.BossNav.BossIcon = bar.BossNav:CreateTexture(nil, "ARTWORK")
    PixelSetSize(bar.BossNav.BossIcon, 22, 22)
    bar.BossNav.BossIcon:SetPoint(
        "LEFT", bar.BossNav.Previous, "RIGHT", 7, -1)
    bar.BossNav.Killed = bar.BossNav:CreateTexture(nil, "OVERLAY")
    bar.BossNav.Killed:SetTexture(ICONS.CHECK)
    PixelSetSize(bar.BossNav.Killed, 14, 14)
    bar.BossNav.Killed:SetPoint(
        "BOTTOMRIGHT", bar.BossNav.BossIcon, "BOTTOMRIGHT", 3, -3)
    bar.BossNav.Killed:SetVertexColor(.22, .9, .55, 1)
    bar.BossNav.Killed:Hide()
    bar.BossNav.Name = Font(bar.BossNav, 9, "accent", "")
    bar.BossNav.Name:SetPoint(
        "LEFT", bar.BossNav.BossIcon, "RIGHT", 6, -1)
    bar.BossNav.Name:SetPoint(
        "RIGHT", bar.BossNav.Announce, "LEFT", -8, -1)
    bar.BossNav.Name:SetJustifyH("CENTER")
    self.quickActionBar = bar
    return bar
end

function Raid:RefreshQuickActionBar()
    local bar = self:CreateQuickActionBar()
    local settings = self.db.quickBar
    bar:SetAlpha(self:GetHUDOpacity())
    local iconOnly = settings.iconOnly
    local buttonWidth = iconOnly and 38 or 106
    local actionCount = #(bar.Actions or {})
    bar:SetWidth(
        92 + (actionCount * buttonWidth)
            + (math.max(0, actionCount - 1) * 4) + 4)
    for _, button in ipairs(bar.Actions or {}) do
        button:SetWidth(buttonWidth)
        button.ActionIcon:ClearAllPoints()
        if iconOnly then
            button.ActionIcon:SetPoint("CENTER")
            button.Text:Hide()
        else
            button.ActionIcon:SetPoint("LEFT", 8, 0)
            button.Text:Show()
            button.Text:ClearAllPoints()
            button.Text:SetPoint("LEFT", 31, 0)
            button.Text:SetPoint("RIGHT", -8, 0)
            button.Text:SetJustifyH("LEFT")
        end
    end
    local raid = self.db.raidLocked and self:GetRaid() or nil
    local encounterIndex = raid and (
        self:GetCurrentBossIndex(raid)
            or tonumber(self.db.activeEncounter)) or nil
    local encounter = encounterIndex and encounterIndex >= 2
        and raid.encounters[encounterIndex] or nil
    local isSimulated = self:IsSimulating()
    local raidGroup = self:IsInLiveRaid()
    local showBossNav = encounter
        and self:IsLocalRaidEditor() or false
    bar:SetHeight(showBossNav and 76 or 42)
    bar.Handle:ClearAllPoints()
    bar.Handle:SetPoint("TOPLEFT", 1, -1)
    bar.Handle:SetPoint(
        "BOTTOMLEFT", 1, showBossNav and 35 or 1)
    bar.HandleBackground:ClearAllPoints()
    bar.HandleBackground:SetPoint("TOPLEFT", 1, -1)
    bar.HandleBackground:SetPoint(
        "BOTTOMLEFT", 1, showBossNav and 35 or 1)
    bar.BossNav:SetShown(showBossNav)
    if showBossNav then
        bar.BossNav.BossIcon:SetTexture(
            encounter.icon or raid.icon or "Interface\\Icons\\INV_Sword_27")
        bar.BossNav.Name:SetText(encounter.name:upper())
        bar.BossNav.Killed:SetShown(self:IsBossKilled(encounterIndex))
        local hasPrevious = encounterIndex > 2
        local hasNext = encounterIndex < #raid.encounters
        bar.BossNav.Previous:SetEnabled(hasPrevious)
        bar.BossNav.Next:SetEnabled(hasNext)
        bar.BossNav.Previous:SetAlpha(hasPrevious and 1 or .35)
        bar.BossNav.Next:SetAlpha(hasNext and 1 or .35)
    end
    local authorized = self:CanUseRaidControls()
    local visibility = settings.visibility or "GROUP"
    local allowed = visibility == "ALWAYS"
        or visibility == "GROUP" and authorized
        or visibility == "RAID" and (raidGroup or isSimulated) and authorized
    if settings.hideInCombat
        and InCombatLockdown and InCombatLockdown()
    then
        allowed = false
    end
    bar:SetShown(not settings.hide and allowed or false)
end

