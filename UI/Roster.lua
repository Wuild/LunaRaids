local _, Raid = ...
local UI = Raid.UI
local ICONS = UI.ICONS
local THEME = UI.THEME

local ROW_HEIGHT = UI.ROW_HEIGHT
local FRAME_WIDTH, FRAME_HEIGHT = UI.FRAME_WIDTH, UI.FRAME_HEIGHT
local ROSTER_WIDTH, ROSTER_ROW_WIDTH = UI.ROSTER_WIDTH, UI.ROSTER_ROW_WIDTH
local ASSIGNMENT_ROW_WIDTH = UI.ASSIGNMENT_ROW_WIDTH
local BOSS_RAIL_WIDTH, BOSS_BUTTON_SIZE = UI.BOSS_RAIL_WIDTH, UI.BOSS_BUTTON_SIZE
local NAV_RAIL_WIDTH, BOSS_RAIL_GAP = UI.NAV_RAIL_WIDTH, UI.BOSS_RAIL_GAP
local ACCENT, BORDER, MUTED, WHITE = UI.ACCENT, UI.BORDER, UI.MUTED, UI.WHITE
local ROLE_TEXTURE, ROLE_COORDS = UI.ROLE_TEXTURE, UI.ROLE_COORDS
local READY_CHECK_COLUMNS = UI.READY_CHECK_COLUMNS
local READY_CHECK_BY_SPELL = UI.READY_CHECK_BY_SPELL
local READY_CHECK_FOOD_MATCHES = UI.READY_CHECK_FOOD_MATCHES
local READY_CHECK_GRID_START = UI.READY_CHECK_GRID_START
local READY_CHECK_COLUMN_WIDTH = UI.READY_CHECK_COLUMN_WIDTH
local GEAR_INSPECT_SLOTS = UI.GEAR_INSPECT_SLOTS
local Pixel, PixelForRegion = UI.Pixel, UI.PixelForRegion
local PhysicalPixels = UI.PhysicalPixels
local SetPixelHeight, SetPixelWidth = UI.SetPixelHeight, UI.SetPixelWidth
local PixelSetSize, FitAndClampToScreen = UI.PixelSetSize, UI.FitAndClampToScreen
local SnapAnchors, SnapTree = UI.SnapAnchors, UI.SnapTree
local BackdropFrame, Font = UI.BackdropFrame, UI.Font
local InstallPixelBorder, Button = UI.InstallPixelBorder, UI.Button
local StyleButton, AddButtonIcon = UI.StyleButton, UI.AddButtonIcon
local AddDropdownArrow, AddButtonTooltip = UI.AddDropdownArrow, UI.AddButtonTooltip
local Panel, SectionHeader, EditField = UI.Panel, UI.SectionHeader, UI.EditField
local ShowSelectionMenu = UI.ShowSelectionMenu
local ShowMultiSelectionMenu = UI.ShowMultiSelectionMenu
local CurrentGuildRankEntries = UI.CurrentGuildRankEntries
local SetClassText, GetClassRowColor = UI.SetClassText, UI.GetClassRowColor
local CreateScrollArea = UI.CreateScrollArea

local function UseRowSeparator(frame)
    if not frame.PixelBorders then return end
    frame.PixelBorders[1]:Hide()
    frame.PixelBorders[3]:Hide()
    frame.PixelBorders[4]:Hide()
end
function Raid:ShowRoleMenu(player, anchor)
    if not self.roleMenu then
        local dismiss = CreateFrame("Button", nil, UIParent)
        dismiss:SetAllPoints(UIParent)
        dismiss:SetFrameStrata("FULLSCREEN_DIALOG")
        dismiss:SetFrameLevel(90)
        dismiss:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        dismiss:SetScript("OnClick", function(self)
            self:Hide()
            if Raid.roleMenu then
                Raid.roleMenu:Hide()
            end
        end)
        dismiss:Hide()
        local menu = Panel(UIParent)
        PixelSetSize(menu, 144, 114)
        menu:SetFrameStrata("FULLSCREEN_DIALOG")
        menu:SetFrameLevel(91)
        menu:SetClampedToScreen(true)
        menu.buttons = {}
        local roles = {
            { Raid.L.TANK, "TANK" },
            { Raid.L.HEALER, "HEALER" },
            { Raid.L.DAMAGE, "DAMAGER" },
            { Raid.L.CLEAR_ROLE, "AUTO" },
            { Raid.L.START_ROLE_CHECK, "POLL" },
            { Raid.L.REMOVE_PLANNED, "REMOVE" },
        }
        for index, entry in ipairs(roles) do
            local choice = Button(menu, entry[1], 140, 21)
            choice:SetPoint("TOPLEFT", 2, -2 - ((index - 1) * 22))
            choice.Text:ClearAllPoints()
            choice.Text:SetPoint("LEFT", 30, 0)
            choice.Icon = choice:CreateTexture(nil, "ARTWORK")
            PixelSetSize(choice.Icon, 18, 18)
            choice.Icon:SetPoint("LEFT", 7, 0)
            local coords = ROLE_COORDS[entry[2]]
            if coords then
                choice.Icon:SetTexture(ROLE_TEXTURE)
                choice.Icon:SetTexCoord(unpack(coords))
            else
                choice.Icon:SetTexture(
                    "Interface\\Buttons\\UI-RefreshButton")
                choice.Icon:SetTexCoord(0, 1, 0, 1)
            end
            choice.role = entry[2]
            choice:SetScript("OnClick", function(self)
                if self.role == "POLL" then
                    Raid:StartRoleCheck()
                elseif self.role == "REMOVE" then
                    Raid:RemoveManualPlayer(menu.player.name)
                else
                    Raid:SetPlayerRole(menu.player, self.role)
                end
                menu:Hide()
            end)
            menu.buttons[index] = choice
        end
        menu.Dismiss = dismiss
        menu:SetScript("OnHide", function()
            dismiss:Hide()
        end)
        self.roleMenu = menu
    end
    if self.raidPlayerMenu then
        self.raidPlayerMenu:Hide()
    end
    self.roleMenu.player = player
    self.roleMenu:SetHeight(player.manual and 136 or 114)
    local overridden =
        self.db.roleOverrides[player.guid or player.name]
    for _, choice in ipairs(self.roleMenu.buttons) do
        choice:SetShown(choice.role ~= "REMOVE" or player.manual)
        local selectedRole = overridden
            or player.role ~= "NONE" and player.role
            or "AUTO"
        local selected = choice.role == selectedRole
        choice.baseBorder = selected
            and { unpack(ACCENT) } or { unpack(BORDER) }
        choice:SetBackdropBorderColor(unpack(choice.baseBorder))
    end
    self.roleMenu:ClearAllPoints()
    self.roleMenu:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 4, 0)
    self.roleMenu.Dismiss:Show()
    self.roleMenu:Show()
end

function Raid:ShowRaidPlayerMenu(player, anchor)
    if not player then return end
    if self.roleMenu then
        self.roleMenu:Hide()
    end
    if not self.raidPlayerMenu then
        local dismiss = CreateFrame("Button", nil, UIParent)
        dismiss:SetAllPoints(UIParent)
        dismiss:SetFrameStrata("FULLSCREEN_DIALOG")
        dismiss:SetFrameLevel(90)
        dismiss:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        dismiss:SetScript("OnClick", function(self)
            self:Hide()
            if Raid.raidPlayerMenu then
                Raid.raidPlayerMenu:Hide()
            end
        end)
        dismiss:Hide()
        local menu = Panel(UIParent)
        menu:SetWidth(190)
        menu:SetFrameStrata("FULLSCREEN_DIALOG")
        menu:SetFrameLevel(91)
        menu:SetClampedToScreen(true)
        menu.Title = Font(menu, 10, "accent", "")
        menu.Title:SetPoint("TOPLEFT", 10, -9)
        menu.Title:SetPoint("TOPRIGHT", -10, -9)
        menu.Title:SetJustifyH("LEFT")
        menu.rows = {}
        local actions = {
            {
                key = "WHISPER", label = Raid.L.WHISPER_TITLE,
                run = function(subject)
                    if ChatFrame_SendTell then
                        ChatFrame_SendTell(subject.name)
                    end
                end,
            },
            {
                key = "TARGET", label = Raid.L.TARGET,
                live = true,
                run = function(subject)
                    if subject.unit and TargetUnit then
                        pcall(TargetUnit, subject.unit)
                    end
                end,
            },
            {
                key = "INSPECT", label = Raid.L.INSPECT,
                live = true,
                run = function(subject)
                    if subject.unit and InspectUnit then
                        pcall(InspectUnit, subject.unit)
                    end
                end,
            },
            {
                key = "ROLE", label = Raid.L.CHANGE_ROLE,
                editor = true,
                run = function(subject, source)
                    Raid:ShowRoleMenu(subject, source)
                end,
            },
            {
                key = "PROMOTE", label = Raid.L.PROMOTE_ASSISTANT,
                leader = true,
                run = function(subject)
                    Raid:PromoteRosterPlayer(subject)
                end,
            },
            {
                key = "DEMOTE", label = Raid.L.DEMOTE_ASSISTANT,
                leader = true,
                assistant = true,
                run = function(subject)
                    Raid:DemoteRosterPlayer(subject)
                end,
            },
            {
                key = "LEADER", label = Raid.L.MAKE_RAID_LEADER,
                leader = true,
                run = function(subject)
                    Raid:TransferRaidLeader(subject)
                end,
            },
            {
                key = "MASTER_LOOTER", label = Raid.L.SET_MASTER_LOOTER,
                leader = true,
                run = function(subject)
                    Raid:SetMasterLooterPlayer(subject)
                end,
            },
            {
                key = "REMOVE", label = Raid.L.REMOVE_FROM_RAID,
                editor = true,
                destructive = true,
                run = function(subject)
                    if subject.manual then
                        Raid:RemoveManualPlayer(subject.name)
                    else
                        StaticPopup_Show(
                            "LUNARAIDS_REMOVE_RAID_PLAYER",
                            subject.name, nil, subject)
                    end
                end,
            },
        }
        for _, action in ipairs(actions) do
            local row = Button(menu, action.label, 186, 23)
            row.Text:ClearAllPoints()
            row.Text:SetPoint("LEFT", 9, 0)
            row.Text:SetPoint("RIGHT", -7, 0)
            row.Text:SetJustifyH("LEFT")
            if action.destructive then StyleButton(row, "danger") end
            row.action = action
            row:SetScript("OnClick", function(self)
                local subject = menu.player
                menu:Hide()
                self.action.run(subject, menu.anchor)
            end)
            menu.rows[#menu.rows + 1] = row
        end
        menu:Hide()
        menu:SetScript("OnHide", function()
            dismiss:Hide()
        end)
        menu.Dismiss = dismiss
        self.raidPlayerMenu = menu
    end

    local menu = self.raidPlayerMenu
    menu.player, menu.anchor = player, anchor
    SetClassText(menu.Title, player.name, player.class)
    local isLive = player.unit and not player.manual
        and not player.simulated
    local isSelf = self:IsRosterPlayerSelf(player)
    local isLeader = self:IsActualRaidLeader()
    local canEdit = self:CanEditRaidGroups()
    local y, visible = -28, 0
    for _, row in ipairs(menu.rows) do
        local action = row.action
        local show = true
        if action.live and not isLive then show = false end
        if action.editor and not canEdit then show = false end
        if action.leader and (
            not isLeader or not isLive
                or (isSelf and action.key ~= "MASTER_LOOTER"))
        then
            show = false
        end
        if action.key == "PROMOTE"
            and (player.assistant or player.leader)
        then
            show = false
        elseif action.assistant and not player.assistant then
            show = false
        elseif action.key == "LEADER" and player.leader then
            show = false
        elseif action.key == "MASTER_LOOTER"
            and player.online == false
        then
            show = false
        elseif action.key == "REMOVE"
            and (isSelf or player.simulated)
        then
            show = false
        end
        row:SetShown(show)
        if show then
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 2, y)
            y = y - 24
            visible = visible + 1
            if action.key == "REMOVE" and player.manual then
                row.Text:SetText(self.L.REMOVE_PLANNED_PLAYER)
            else
                row.Text:SetText(action.label)
            end
        end
    end
    menu:SetHeight(32 + (visible * 24))
    menu:ClearAllPoints()
    menu:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 4, 0)
    menu.Dismiss:Show()
    menu:Show()
end

function Raid:CreateManualPlayerPanel()
    if self.manualPlayerPanel then return self.manualPlayerPanel end
    local panel = Panel(self.frame)
    PixelSetSize(panel, 420, 355)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("HIGH")
    panel:SetFrameLevel(self.frame:GetFrameLevel() + 30)
    panel.Title = Font(panel, 14, "accent", Raid.L.ADD_PLANNED_PLAYER:upper())
    panel.Title:SetPoint("TOPLEFT", 16, -16)
    panel.Close = CreateFrame(
        "Button", nil, panel, "UIPanelCloseButton")
    panel.Close:SetPoint("TOPRIGHT", -3, -3)
    panel.Close:SetScript("OnClick", function() panel:Hide() end)
    local nameLabel = Font(panel, 9, "muted", Raid.L.CHARACTER_NAME)
    nameLabel:SetPoint("TOPLEFT", 18, -54)
    panel.NameInput =
        CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    PixelSetSize(panel.NameInput, 184, 27)
    panel.NameInput:SetPoint("TOPLEFT", 18, -70)
    panel.NameInput:SetAutoFocus(false)
    local specLabel = Font(panel, 9, "muted", "SPEC (OPTIONAL)")
    specLabel:SetPoint("TOPLEFT", 220, -54)
    panel.SpecInput =
        CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    PixelSetSize(panel.SpecInput, 180, 27)
    panel.SpecInput:SetPoint("TOPLEFT", 220, -70)
    panel.SpecInput:SetAutoFocus(false)
    local classLabel = Font(panel, 9, "muted", Raid.L.CLASS_UPPER)
    classLabel:SetPoint("TOPLEFT", 18, -112)
    panel.ClassButtons = {}
    local classes = {
        { "WARRIOR", "Warrior" }, { "PALADIN", "Paladin" },
        { "HUNTER", "Hunter" }, { "ROGUE", "Rogue" },
        { "PRIEST", "Priest" }, { "SHAMAN", "Shaman" },
        { "MAGE", "Mage" }, { "WARLOCK", "Warlock" },
        { "DRUID", "Druid" },
    }
    for index, entry in ipairs(classes) do
        local button = Button(panel, entry[2], 120, 25)
        local column = (index - 1) % 3
        local row = math.floor((index - 1) / 3)
        button:SetPoint(
            "TOPLEFT", 18 + (column * 128), -129 - (row * 29))
        button.class = entry[1]
        button:SetScript("OnClick", function(self)
            panel.selectedClass = self.class
            Raid:RefreshManualPlayerPanel()
        end)
        button:HookScript(
            "OnLeave", function() Raid:RefreshManualPlayerPanel() end)
        panel.ClassButtons[index] = button
    end
    local roleLabel = Font(panel, 9, "muted", Raid.L.ROLE)
    roleLabel:SetPoint("TOPLEFT", 18, -224)
    panel.RoleButtons = {}
    for index, entry in ipairs({
        { "TANK", Raid.L.TANK }, { "HEALER", Raid.L.HEALER },
        { "DAMAGER", Raid.L.DAMAGE },
    }) do
        local button = Button(panel, entry[2], 120, 27)
        button:SetPoint("TOPLEFT", 18 + ((index - 1) * 128), -241)
        button.role = entry[1]
        button:SetScript("OnClick", function(self)
            panel.selectedRole = self.role
            Raid:RefreshManualPlayerPanel()
        end)
        button:HookScript(
            "OnLeave", function() Raid:RefreshManualPlayerPanel() end)
        panel.RoleButtons[index] = button
    end
    panel.Add = Button(panel, Raid.L.ADD_TO_ROSTER, 150, 30)
    StyleButton(panel.Add, "primary")
    panel.Add:SetPoint("BOTTOMRIGHT", -16, 14)
    panel.Add:SetScript("OnClick", function()
        Raid:AddManualPlayer(
            panel.NameInput:GetText(), panel.selectedClass,
            panel.selectedRole, panel.SpecInput:GetText())
        if strtrim(panel.NameInput:GetText() or "") ~= "" then
            panel:Hide()
        end
    end)
    panel.NameInput:SetScript(
        "OnEnterPressed", function() panel.Add:Click() end)
    panel:Hide()
    self.manualPlayerPanel = panel
    return panel
end

function Raid:RefreshManualPlayerPanel()
    local panel = self.manualPlayerPanel
    if not panel then return end
    for _, button in ipairs(panel.ClassButtons) do
        button.baseBorder = button.class == panel.selectedClass
            and { unpack(ACCENT) } or { unpack(BORDER) }
        button:SetBackdropBorderColor(unpack(button.baseBorder))
    end
    for _, button in ipairs(panel.RoleButtons) do
        button.baseBorder = button.role == panel.selectedRole
            and { unpack(ACCENT) } or { unpack(BORDER) }
        button:SetBackdropBorderColor(unpack(button.baseBorder))
    end
end

function Raid:ShowManualPlayerPanel()
    local panel = self:CreateManualPlayerPanel()
    panel.selectedClass = "WARRIOR"
    panel.selectedRole = "DAMAGER"
    panel.NameInput:SetText("")
    panel.SpecInput:SetText("")
    panel:Show()
    panel.NameInput:SetFocus()
    self:RefreshManualPlayerPanel()
end

function Raid:CreateDragGhost()
    if self.dragGhost then return self.dragGhost end
    local ghost = BackdropFrame("Frame", nil, UIParent)
    PixelSetSize(ghost, 190, 30)
    ghost:SetFrameStrata("TOOLTIP")
    ghost:SetClampedToScreen(true)
    ghost:EnableMouse(false)
    ghost:SetBackdrop({
        bgFile = WHITE,
        edgeFile = WHITE,
        edgeSize = Pixel(1),
    })
    InstallPixelBorder(ghost)
    ghost:SetBackdropColor(unpack(THEME.surfaceRaised))
    ghost:SetBackdropBorderColor(unpack(ACCENT))
    ghost.Role = ghost:CreateTexture(nil, "ARTWORK")
    ghost.Role:SetTexture(ROLE_TEXTURE)
    PixelSetSize(ghost.Role, 19, 19)
    ghost.Role:SetPoint("LEFT", 8, 0)
    ghost.Name = Font(ghost, 11, "text", "")
    ghost.Name:SetPoint("LEFT", ghost.Role, "RIGHT", 7, 0)
    ghost.Name:SetPoint("RIGHT", -9, 0)
    ghost.Name:SetJustifyH("LEFT")
    ghost.Glow = ghost:CreateTexture(nil, "BACKGROUND")
    ghost.Glow:SetTexture(WHITE)
    ghost.Glow:SetPoint("TOPLEFT", -3, 3)
    ghost.Glow:SetPoint("BOTTOMRIGHT", 3, -3)
    ghost.Glow:SetVertexColor(
        THEME.accent[1], THEME.accent[2], THEME.accent[3], .13)
    ghost.Pulse = ghost.Glow:CreateAnimationGroup()
    ghost.Pulse:SetLooping("BOUNCE")
    local pulse = ghost.Pulse:CreateAnimation("Alpha")
    pulse:SetFromAlpha(.25)
    pulse:SetToAlpha(.8)
    pulse:SetDuration(.45)
    ghost:SetScript("OnUpdate", function(self)
        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT",
            (x / scale) + 18, (y / scale) - 12)
    end)
    ghost:Hide()
    self.dragGhost = ghost
    return ghost
end

function Raid:ShowDragGhost(player)
    if not player then return end
    local ghost = self:CreateDragGhost()
    local roleCoords = ROLE_COORDS[player.role]
    if roleCoords then
        ghost.Role:SetTexCoord(unpack(roleCoords))
        ghost.Role:Show()
        ghost.Name:ClearAllPoints()
        ghost.Name:SetPoint("LEFT", ghost.Role, "RIGHT", 7, 0)
    else
        ghost.Role:Hide()
        ghost.Name:ClearAllPoints()
        ghost.Name:SetPoint("LEFT", 9, 0)
    end
    ghost.Name:SetPoint("RIGHT", -9, 0)
    SetClassText(ghost.Name, player.name, player.class)
    ghost:Show()
    ghost.Pulse:Play()
end

function Raid:HideDragGhost()
    if self.dragGhost then
        self.dragGhost.Pulse:Stop()
        self.dragGhost:Hide()
    end
end

local function ShortPlayerName(name)
    local short = tostring(name or ""):match("^[^-]+")
    return (short or ""):lower()
end

UI.ShortPlayerName = ShortPlayerName

function Raid:GetPersonalAssignmentEntries(raid, encounterIndex)
    if not self.db.raidLocked then return {} end
    local playerName = UnitName and UnitName("player")
    if not playerName then return {} end
    local ownName = ShortPlayerName(playerName)
    raid = raid or self:GetRaid()
    encounterIndex = tonumber(encounterIndex)
        or self:GetCurrentBossIndex(raid)
    if not encounterIndex then return {} end
    local encounter = raid.encounters[encounterIndex]
    if not encounter then return {} end
    local plans = self.simulation.enabled
        and self.simulation.plans or self.db.plans
    local plan = plans[raid.key]
        and plans[raid.key][encounterIndex] or {}
    local entries = {}
    local encounterTargets = encounter.targets
        and #encounter.targets > 0 and encounter.targets
        or { encounter.name }
    local function TargetKind(targetName)
        if not targetName then return nil end
        for targetIndex, candidate in ipairs(encounterTargets) do
            if candidate == targetName then
                return targetIndex == 1 and "BOSS" or "ADD"
            end
        end
        return nil
    end
    local function RosterTargetInfo(targetName, fallbackClass, fallbackRole)
        for _, player in ipairs(self.roster or {}) do
            if ShortPlayerName(player.name) == ShortPlayerName(targetName) then
                return player.class or fallbackClass,
                    player.role and player.role ~= "NONE"
                        and player.role or fallbackRole
            end
        end
        return fallbackClass, fallbackRole
    end
    local function GetTargetMarkerToken(text, targetName)
        if targetName then
            for targetIndex, candidate in ipairs(encounterTargets) do
                if candidate == targetName then
                    return self:GetMarkerChatToken(
                        self:GetMarkerAssignment(
                            targetIndex, plan, encounter))
                end
            end
        end
        local lower = tostring(text or ""):lower()
        local words = {}
        for word in lower:gmatch("[%a']+") do words[word] = true end
        for markerIndex, marker in ipairs(self.markers or {}) do
            local markerName = marker.name and marker.name:lower()
            if markerName and (words[markerName]
                or markerName == "cross" and words.x)
            then
                return self:GetMarkerChatToken(markerIndex)
            end
        end
        for targetIndex, candidate in ipairs(encounterTargets) do
            if lower:find(candidate:lower(), 1, true) then
                return self:GetMarkerChatToken(
                    self:GetMarkerAssignment(
                        targetIndex, plan, encounter))
            end
        end
        return ""
    end
    for groupIndex, group in ipairs(self:GetEncounterGroups(
        encounter, raid.key, encounterIndex)) do
        for slotIndex, slot in ipairs(
            self:GetEncounterGroupSlots(
                groupIndex, encounter, raid.key, encounterIndex)) do
            local key = slot.id and ("S:" .. slot.id)
                or ("S:group.%d.slot.%d"):format(
                    groupIndex, slotIndex)
            local assignment = plan[key]
            if assignment and ShortPlayerName(assignment.name) == ownName then
                local label = self:GetSlotLabel(slot)
                local targetName
                if (slot.role or group.role) == self.Role.TANK then
                    local lowerLabel = label:lower()
                    for _, candidate in ipairs(encounterTargets) do
                        if lowerLabel:find(
                            candidate:lower(), 1, true)
                        then
                            targetName = candidate
                            break
                        end
                    end
                    if not targetName and #encounterTargets == 1 then
                        targetName = encounterTargets[1]
                    elseif not targetName
                        and lowerLabel:find("main tank", 1, true)
                    then
                        targetName = encounterTargets[1]
                    end
                end
                entries[#entries + 1] = {
                    label = label,
                    targetName = targetName,
                    targetRole = TargetKind(targetName),
                    markerToken =
                        GetTargetMarkerToken(label, targetName),
                }
            end
        end
    end
    local healingTargets = {}
    for groupIndex, group in ipairs(self:GetEncounterGroups(
        encounter, raid.key, encounterIndex)) do
        if group.name == "Tanks" then
            for slotIndex, slot in ipairs(self:GetEncounterGroupSlots(
                groupIndex, encounter, raid.key, encounterIndex)) do
                healingTargets[#healingTargets + 1] = {
                    name = self:GetSlotLabel(slot),
                    groupIndex = groupIndex,
                    slotIndex = slotIndex,
                }
            end
            break
        end
    end
    healingTargets[#healingTargets + 1] = { name = "Raid" }
    local override = self:GetBossOverride(
        false, raid.key, encounterIndex)
    local healerCount = override and tonumber(override.healers)
    if not healerCount then
        for _, group in ipairs(encounter.groups or {}) do
            if group.role == self.Role.HEALER then
                healerCount = #group.slots
                break
            end
        end
    end
    healerCount = healerCount
        or self:GetRaidComposition(raid.key).healers
    for index = 1, healerCount do
        local assignment = plan[self:HealingPlayerKey(index)]
        if assignment and ShortPlayerName(assignment.name) == ownName then
            local targetIndex = math.max(
                1, math.min(
                    tonumber(plan[self:HealingTargetKey(index)])
                        or #healingTargets,
                    #healingTargets))
            local target = healingTargets[targetIndex]
            local targetName
            if target and target.groupIndex and target.slotIndex then
                local targetSlots = self:GetEncounterGroupSlots(
                    target.groupIndex, encounter, raid.key, encounterIndex)
                local targetSlot = targetSlots[target.slotIndex]
                local targetKey = targetSlot and targetSlot.id
                    and ("S:" .. targetSlot.id)
                    or ("S:group.%d.slot.%d"):format(
                        target.groupIndex, target.slotIndex)
                local tank = plan[targetKey]
                targetName = tank and tank.name
                if tank then
                    target.class, target.role = RosterTargetInfo(
                        tank.name, tank.class, "TANK")
                end
            end
            entries[#entries + 1] = {
                label = self.L.HEALING_PREFIX
                    .. (targetName
                        and ("%s (%s)"):format(target.name, targetName)
                        or target and target.name or "Unknown target"),
                targetName = targetName,
                targetClass = target and target.class,
                targetRole = target and (
                    target.role
                    or target.name == "Raid" and "RAID"),
                markerToken = target and target.groupIndex
                    and GetTargetMarkerToken(target.name, nil)
                    or "",
            }
        end
    end
    return entries
end

function Raid:CreatePersonalAssignmentFrame()
    if self.personalAssignmentFrame then
        return self.personalAssignmentFrame
    end
    local saved = self.db.assignmentInfo
    local frame = Panel(UIParent)
    frame:SetScale(self:GetHUDScale())
    local savedWidth = math.max(
        320, math.min(720, tonumber(saved.width) or 360))
    PixelSetSize(frame, savedWidth, 76)
    local savedPoint = saved.point or "CENTER"
    local savedX, savedY = saved.x or 300, saved.y or 40
    local migrateResizeAnchor = savedPoint == "TOPLEFT" and savedY > 0
    frame:SetPoint(
        savedPoint, UIParent,
        migrateResizeAnchor and "BOTTOMLEFT" or savedPoint,
        savedX, savedY)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(320, 76, 720, 600)
    elseif frame.SetMinResize then
        frame:SetMinResize(320, 76)
        if frame.SetMaxResize then frame:SetMaxResize(720, 600) end
    end
    frame:EnableMouse(true)
    local function SaveAssignmentCenterPosition()
        local centerX, centerY = frame:GetCenter()
        local parentX, parentY = UIParent:GetCenter()
        if not centerX or not centerY or not parentX or not parentY then
            return
        end
        local x, y = centerX - parentX, centerY - parentY
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
        saved.point = "CENTER"
        saved.x, saved.y = x, y
    end
    if migrateResizeAnchor then SaveAssignmentCenterPosition() end
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveAssignmentCenterPosition()
    end)
    frame.Header = frame:CreateTexture(nil, "ARTWORK")
    frame.Header:SetTexture(WHITE)
    frame.Header:SetPoint("TOPLEFT", 1, -1)
    frame.Header:SetPoint("TOPRIGHT", -1, -1)
    frame.Header:SetHeight(29)
    frame.Header:SetVertexColor(unpack(THEME.header))
    frame.HeaderLine = frame:CreateTexture(nil, "OVERLAY")
    frame.HeaderLine:SetTexture(WHITE)
    frame.HeaderLine:SetPoint("TOPLEFT", 1, -29)
    frame.HeaderLine:SetPoint("TOPRIGHT", -1, -29)
    SetPixelHeight(frame.HeaderLine, 1)
    frame.HeaderLine:SetVertexColor(unpack(THEME.dividerStrong))
    frame.HeaderIcon = frame:CreateTexture(nil, "OVERLAY")
    frame.HeaderIcon:SetTexture(ICONS.ASSIGNMENTS)
    PixelSetSize(frame.HeaderIcon, 18, 18)
    frame.HeaderIcon:SetPoint("TOPLEFT", 8, -6)
    frame.Title = Font(frame, 12, "accent", self.L.YOUR_ASSIGNMENTS)
    frame.Title:SetPoint("LEFT", frame.HeaderIcon, "RIGHT", 7, 0)
    frame.Encounter = Font(frame, 10, "muted", "")
    frame.Encounter:SetPoint("TOPRIGHT", -10, -9)
    frame.ResizeGrip = CreateFrame("Button", nil, frame)
    PixelSetSize(frame.ResizeGrip, 16, 16)
    frame.ResizeGrip:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.ResizeGrip:SetFrameLevel(frame:GetFrameLevel() + 10)
    frame.ResizeGrip:SetNormalTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    frame.ResizeGrip:SetHighlightTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    frame.ResizeGrip:SetPushedTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    frame.ResizeGrip:SetScript("OnMouseDown", function(grip, button)
        if button == "LeftButton" then
            local cursorX = GetCursorPosition()
            local scale = frame:GetEffectiveScale()
            grip.resizeStartX = cursorX / scale
            grip.resizeStartWidth = frame:GetWidth()
            local left, top = frame:GetLeft(), frame:GetTop()
            frame:ClearAllPoints()
            frame:SetPoint(
                "TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
            grip:SetScript("OnUpdate", function(self)
                local currentX = GetCursorPosition()
                currentX = currentX / scale
                frame:SetWidth(math.max(320, math.min(720,
                    self.resizeStartWidth
                        + currentX - self.resizeStartX)))
            end)
        end
    end)
    frame.ResizeGrip:SetScript("OnMouseUp", function(grip)
        grip:SetScript("OnUpdate", nil)
        grip.resizeStartX, grip.resizeStartWidth = nil, nil
        local width = math.max(
            320, math.min(720, frame:GetWidth() or 360))
        width = PixelForRegion(frame, width)
        frame:SetWidth(width)
        saved.width = math.floor(width + .5)
        SaveAssignmentCenterPosition()
    end)
    AddButtonTooltip(
        frame.ResizeGrip, "Resize Assignments",
        "Drag horizontally to change the width of this panel.")
    frame.Rows = {}
    frame:Hide()
    self.personalAssignmentFrame = frame
    return frame
end

local function PersonalAssignmentPresentation(raid, entry)
    local markerToken = entry.markerToken or ""
    local marker = raid:FormatMarkerTokensForLocalDisplay(markerToken)
    local text = (marker ~= "" and marker .. "  " or "")
        .. entry.label
    local metadata = {}
    if entry.targetName then
        metadata[#metadata + 1] = "TARGET: " .. entry.targetName
    end
    if entry.targetRole then
        metadata[#metadata + 1] = tostring(entry.targetRole)
    end
    if entry.targetClass then
        local classColor = RAID_CLASS_COLORS
            and RAID_CLASS_COLORS[entry.targetClass]
        local className = LOCALIZED_CLASS_NAMES_MALE
            and LOCALIZED_CLASS_NAMES_MALE[entry.targetClass]
            or entry.targetClass
        if classColor then
            className = ("|cff%02x%02x%02x%s|r"):format(
                math.floor(classColor.r * 255 + .5),
                math.floor(classColor.g * 255 + .5),
                math.floor(classColor.b * 255 + .5),
                className)
        end
        metadata[#metadata + 1] = className
    end
    return text, table.concat(metadata, "  ·  ")
end

local function EnsurePersonalAssignmentRow(frame, index)
    local row = frame.Rows[index]
    if row then return row end
    row = Button(frame, "", 340, 32)
    row.Text:ClearAllPoints()
    row.Text:SetPoint("TOPLEFT", 9, -4)
    row.Text:SetPoint("TOPRIGHT", -9, -4)
    row.Text:SetJustifyH("LEFT")
    row.Meta = Font(row, 9, "muted", "")
    row.Meta:SetPoint("BOTTOMLEFT", 9, 4)
    row.Meta:SetPoint("BOTTOMRIGHT", -9, 4)
    row.Meta:SetJustifyH("LEFT")
    row.baseColor = { unpack(THEME.surfaceAlt) }
    row.baseBorder = { unpack(THEME.borderSoft) }
    row:SetBackdropColor(unpack(row.baseColor))
    row:SetBackdropBorderColor(unpack(row.baseBorder))
    row:EnableMouse(false)
    frame.Rows[index] = row
    return row
end

function Raid:RefreshPersonalAssignmentPresentationInCombat()
    local frame = self.personalAssignmentFrame
    if not frame then return end
    local raid = self:GetRaid()
    local encounterIndex = self:GetCurrentBossIndex(raid)
    local encounter = encounterIndex and raid.encounters[encounterIndex]
    frame.Encounter:SetText(
        encounter and encounter.name:upper() or "")
    frame.currentRaidKey = raid.key
    frame.currentEncounterIndex = encounterIndex
    local entries = self:GetPersonalAssignmentEntries(raid, encounterIndex)
    if self.db.assignmentInfo.hide or #entries == 0 then
        frame:Hide()
        return
    end
    frame:SetAlpha(self:GetHUDOpacity())
    for index, entry in ipairs(entries) do
        local row = EnsurePersonalAssignmentRow(frame, index)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 10, -31 - ((index - 1) * 34))
        row:SetPoint("TOPRIGHT", -10, -31 - ((index - 1) * 34))
        local text, metadata = PersonalAssignmentPresentation(self, entry)
        row.Text:SetText(text)
        row.Meta:SetText(metadata)
        row:SetAlpha(1)
        row:Show()
    end
    for index = #entries + 1, #frame.Rows do
        frame.Rows[index]:Hide()
    end
    frame:SetHeight(48 + (#entries * 34))
    frame:Show()
end

function Raid:RefreshPersonalAssignments()
    if not IsInGroup or not IsInGroup() then
        self.personalAssignmentsRefreshPending =
            InCombatLockdown and InCombatLockdown() or nil
        if self.personalAssignmentFrame then
            if InCombatLockdown and InCombatLockdown() then
                self.personalAssignmentFrame:SetAlpha(0)
                self.personalAssignmentFrame:EnableMouse(false)
            else
                self.personalAssignmentFrame:Hide()
                self.personalAssignmentFrame:SetAlpha(1)
                self.personalAssignmentFrame:EnableMouse(true)
            end
        end
        return
    end
    if InCombatLockdown and InCombatLockdown() then
        self.personalAssignmentsRefreshPending = true
        self:RefreshPersonalAssignmentPresentationInCombat()
        return
    end
    if self.receivingSnapshots
        and next(self.receivingSnapshots) ~= nil
    then
        self.personalAssignmentsRefreshPending = true
        return
    end
    self.personalAssignmentsRefreshPending = nil
    local frame = self:CreatePersonalAssignmentFrame()
    frame:SetAlpha(self:GetHUDOpacity())
    frame:EnableMouse(true)
    local raid = self:GetRaid()
    local encounterIndex = self:GetCurrentBossIndex(raid)
    local entries = self:GetPersonalAssignmentEntries(raid, encounterIndex)
    if self.db.assignmentInfo.hide or #entries == 0 then
        frame:Hide()
        return
    end
    local encounter = encounterIndex and raid.encounters[encounterIndex]
    frame.Encounter:SetText(
        encounter and encounter.name:upper() or "")
    frame.currentRaidKey = raid.key
    frame.currentEncounterIndex = encounterIndex
    for index, entry in ipairs(entries) do
        local row = EnsurePersonalAssignmentRow(frame, index)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 10, -31 - ((index - 1) * 34))
        row:SetPoint("TOPRIGHT", -10, -31 - ((index - 1) * 34))
        local text, metadata = PersonalAssignmentPresentation(
            self, entry)
        row.Text:SetText(text)
        row.Meta:SetText(metadata)
        row:SetAlpha(1)
        row:Show()
    end
    for index = #entries + 1, #frame.Rows do
        frame.Rows[index]:Hide()
    end
    frame:SetHeight(48 + (#entries * 34))
    frame:Show()
end

function Raid:HandleCombatStateChanged()
    if self.RefreshQuickActionBar then
        self:RefreshQuickActionBar()
    end
    if not InCombatLockdown or not InCombatLockdown() then
        self:RefreshPersonalAssignments()
    end
end

function Raid:CreateRosterButton(index)
    local button = Button(
        self.rosterContent, "",
        math.max(1, self.rosterContent:GetWidth() or ROSTER_ROW_WIDTH), 34)
    UseRowSeparator(button)
    local rowHeight = button:GetHeight()
    self.rosterRowHeight = rowHeight
    button:SetPoint("TOPLEFT", 0, -((index - 1) * rowHeight))
    button.ClassDot = button:CreateTexture(nil, "OVERLAY")
    button.ClassDot:SetTexture(WHITE)
    PixelSetSize(button.ClassDot, 4, 20)
    button.ClassDot:SetPoint("LEFT", 5, 0)
    button.Text:ClearAllPoints()
    button.Text:SetPoint("LEFT", 15, 0)
    button.Text:SetWidth(88)
    button.Text:SetJustifyH("LEFT")
    button.Role = button:CreateTexture(nil, "ARTWORK")
    button.Role:SetTexture(ROLE_TEXTURE)
    PixelSetSize(button.Role, 17, 17)
    button.Role:SetPoint("LEFT", 108, 0)
    button.Spec = Font(button, 9, "muted", "")
    button.Spec:SetPoint("LEFT", 135, 0)
    button.Spec:SetWidth(70)
    button.Spec:SetJustifyH("LEFT")
    button.GearScore = Font(button, 9, "muted", "")
    button.GearScore:SetPoint("RIGHT", -10, 0)
    button.GearScore:SetWidth(34)
    button.GearScore:SetJustifyH("RIGHT")
    button.Delete = Button(button, "X", 22, 22)
    button.Delete:SetPoint("RIGHT", -5, 0)
    button.Delete:SetFrameLevel(button:GetFrameLevel() + 4)
    StyleButton(button.Delete, "danger")
    button.Delete:SetScript("OnClick", function(self)
        if not Raid:IsLocalRaidEditor() then return end
        local row = self:GetParent()
        if row.player and row.player.manual then
            Raid:RemoveManualPlayer(row.player.name)
        end
    end)
    AddButtonTooltip(
        button.Delete, "Remove Planned Player",
        "Remove this character from the planned roster and assignments.")
    button.Delete:Hide()
    button.SelectedBar = button:CreateTexture(nil, "OVERLAY")
    button.SelectedBar:SetTexture(WHITE)
    button.SelectedBar:SetPoint("TOPLEFT", 1, -1)
    button.SelectedBar:SetPoint("BOTTOMLEFT", 1, 1)
    SetPixelWidth(button.SelectedBar, 4)
    button.SelectedBar:SetVertexColor(unpack(ACCENT))
    button.SelectedBar:Hide()
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnClick", function(self, mouseButton)
        if not Raid:IsLocalRaidEditor() then return end
        if mouseButton == "RightButton" then
            Raid:ShowRoleMenu(self.player, self)
            return
        end
        if Raid.roleMenu then Raid.roleMenu:Hide() end
        Raid.selectedPlayer =
            Raid.selectedPlayer == self.player and nil or self.player
        Raid:RefreshRoster()
    end)
    button:SetScript("OnDragStart", function(self)
        if not Raid:IsLocalRaidEditor() then return end
        Raid.dragPlayer = self.player
        Raid.selectedPlayer = self.player
        Raid:ShowDragGhost(self.player)
        Raid:RefreshRoster()
    end)
    button:SetScript("OnDragStop", function()
        ResetCursor()
        Raid:HideDragGhost()
        Raid.dragPlayer = nil
    end)
    button:HookScript("OnEnter", function(self)
        if not self.player then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.player.name, 1, 1, 1)
        GameTooltip:AddDoubleLine(
            "Class",
            self.player.className or self.player.class or "Unknown",
            .65, .65, .65, 1, 1, 1)
        GameTooltip:AddDoubleLine(
            "Race", self.player.race or "Unknown",
            .65, .65, .65, 1, 1, 1)
        GameTooltip:AddDoubleLine(
            "Role",
            self.player.role == "NONE"
                and "Unassigned" or self.player.role or "Unassigned",
            .65, .65, .65, 1, 1, 1)
        if self.player.spec then
            GameTooltip:AddDoubleLine(
                "Specialization", self.player.spec,
                .65, .65, .65, .35, .72, 1)
            local intel = Raid:GetCharacterIntel(self.player)
            if intel then
                GameTooltip:AddDoubleLine(
                    "Character data", intel.source or "Cached",
                    .65, .65, .65, .75, .75, .75)
            end
        end
        local roleKey = self.player.guid or self.player.name
        if self.player.raidAssignment == "MAINTANK" then
            GameTooltip:AddDoubleLine(
                "Role source", "Blizzard Main Tank",
                .65, .65, .65, .25, .75, 1)
        elseif roleKey and Raid.db.roleOverrides[roleKey] then
            GameTooltip:AddDoubleLine(
                "Role source", "LunaRaids override",
                .65, .65, .65, .35, .72, 1)
        else
            GameTooltip:AddDoubleLine(
                "Role source", "Blizzard group role",
                .65, .65, .65, .75, .75, .75)
        end
        GameTooltip:AddLine(
            "Right-click to change role.",
            .75, .60, .25)
        GameTooltip:AddDoubleLine(
            "Raid group", tostring(self.player.subgroup or 1),
            .65, .65, .65, 1, 1, 1)
        if self.player.gearScore then
            GameTooltip:AddDoubleLine(
                "GearScore (TacoTip)",
                tostring(self.player.gearScore),
                .65, .65, .65, 1, .82, .20)
            if self.player.itemLevel and self.player.itemLevel > 0 then
                GameTooltip:AddDoubleLine(
                    "Average item level",
                    tostring(self.player.itemLevel),
                    .65, .65, .65, 1, 1, 1)
            end
        elseif _G.TT_GS and not self.player.simulated then
            GameTooltip:AddDoubleLine(
                "GearScore (TacoTip)", "Not cached",
                .65, .65, .65, .55, .55, .55)
        end
        if self.player.leader then
            GameTooltip:AddLine(
                Raid.L.RAID_LEADER, ACCENT[1], ACCENT[2], ACCENT[3])
        end
        if self.player.simulated then
            GameTooltip:AddLine(Raid.L.SIMULATED_PLAYER, .75, .60, .25)
        elseif self.player.manual then
            GameTooltip:AddLine(
                "Planned player - not currently in the raid",
                .75, .60, .25)
        end
        GameTooltip:Show()
    end)
    button:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    return button
end

function Raid:RefreshRoster()
    if not self.rosterContent then return end
    self:SortRosterByRole()
    self.rosterButtons = self.rosterButtons or {}
    for index, player in ipairs(self.roster) do
        local button = self.rosterButtons[index]
        if not button then
            button = self:CreateRosterButton(index)
            self.rosterButtons[index] = button
        end
        button.player = player
        button:SetWidth(math.max(
            1, self.rosterContent:GetWidth() or ROSTER_ROW_WIDTH))
        local intel = self:GetCharacterIntel(player)
        if intel then
            player.spec = intel.spec
            player.intelSource = intel.source
            if (not player.role or player.role == "NONE")
                and intel.role and intel.role ~= "NONE"
            then
                player.role = intel.role
            end
        end
        SetClassText(button.Text, player.name, player.class)
        local classColor = player.class and RAID_CLASS_COLORS
            and RAID_CLASS_COLORS[player.class]
        button.ClassDot:SetVertexColor(
            classColor and classColor.r or .55,
            classColor and classColor.g or .62,
            classColor and classColor.b or .69, 1)
        local roleCoords = ROLE_COORDS[player.role]
        if roleCoords then
            button.Role:SetTexCoord(unpack(roleCoords))
            button.Role:Show()
        else
            button.Role:Hide()
        end
        local unavailable = player.online == false
        button.Spec:SetText(
            unavailable
                and (player.manual and "PLANNED" or "OFFLINE")
                or player.spec and player.spec ~= "Unknown"
                    and player.spec or "")
        button.Spec:SetTextColor(
            unavailable and 1 or MUTED[1],
            unavailable and .32 or MUTED[2],
            unavailable and .32 or MUTED[3],
            1)
        button.GearScore:SetText(
            player.gearScore and tostring(player.gearScore) or "")
        button.Delete:SetShown(
            player.manual and self:IsLocalRaidEditor())
        button.GearScore:SetShown(not player.manual)
        if player.gearScore and _G.TT_GS
            and type(_G.TT_GS.GetQuality) == "function"
        then
            local ok, red, green, blue = pcall(
                _G.TT_GS.GetQuality, _G.TT_GS, player.gearScore)
            if ok and red then
                button.GearScore:SetTextColor(red, green, blue)
            else
                button.GearScore:SetTextColor(unpack(MUTED))
            end
        else
            button.GearScore:SetTextColor(unpack(MUTED))
        end
        if self.selectedPlayer
            and self.selectedPlayer.name == player.name
        then
            button.baseColor = { unpack(THEME.surfaceSelected) }
            button.baseBorder = { unpack(ACCENT) }
            button:SetBackdropColor(unpack(button.baseColor))
            button:SetBackdropBorderColor(unpack(ACCENT))
            button.SelectedBar:Show()
        else
            button.baseColor = index % 2 == 0
                and { unpack(THEME.surfaceAlt) }
                or { unpack(THEME.surface) }
            button.baseBorder = { unpack(BORDER) }
            button:SetBackdropColor(unpack(button.baseColor))
            button:SetBackdropBorderColor(unpack(button.baseBorder))
            button.SelectedBar:Hide()
        end
        button:SetAlpha(
            player.online == false and (player.manual and .72 or .48) or 1)
        button:Show()
    end
    for index = #self.roster + 1, #self.rosterButtons do
        self.rosterButtons[index]:Hide()
    end
    self.rosterContent:SetHeight(math.max(
        1, #self.roster * (self.rosterRowHeight or ROW_HEIGHT)))
    self.rosterCount:SetText(
        self.simulation.enabled
            and ("%d simulated"):format(#self.roster)
            or ("%d players"):format(#self.roster))
    if self.frame and self.frame.Title then
        self.frame.Title:SetText("LUNA RAIDS")
        if self.frame.Subtitle then
            local raidName = self:GetRaid().name:upper()
            self.frame.Subtitle:SetText(
                self.simulation.enabled
                    and ("%s  ·  SIMULATION %d"):format(
                        raidName, self.simulation.size)
                    or raidName .. (
                        self:IsLocalRaidEditor()
                            and "  ·  ACTIVE PLAN"
                            or "  ·  VIEW ONLY"))
        end
    end
end

