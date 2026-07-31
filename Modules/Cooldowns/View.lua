local _, Raid = ...
local Cooldowns = Raid:GetModule("Cooldowns")
local View = Cooldowns.View
local DEFINITIONS = View.definitions
local Frame, Label = View.Frame, View.Label
local ShortName, CompactName = View.ShortName, View.CompactName
local TimeText, CooldownLength = View.TimeText, View.CooldownLength
local CurrentTime = View.CurrentTime
local WHITE = "Interface\\Buttons\\WHITE8X8"
local ACCENT = { .12, .72, 1, 1 }
local MUTED = { .55, .66, .72, 1 }
local function SetLabelSize(label, size)
    label:SetFontObject(
        Raid.UI.GetFontObject(size, "MONOCHROMEOUTLINE"))
end
local function FitBarText(label, playerName, suffix, maximumWidth)
    local name = ShortName(playerName)
    suffix = suffix or ""
    label:SetText(name .. suffix)
    if label:GetStringWidth() <= maximumWidth then return end
    local function BestName(trailingText)
        local best, characters = "", 0
        for length = 1, #name do
            local candidate = CompactName(name, length)
            label:SetText(candidate .. trailingText)
            if label:GetStringWidth() > maximumWidth then break end
            best, characters = candidate, length
        end
        return best, characters
    end
    local best, characters = BestName(suffix)
    if suffix ~= "" and characters < math.min(3, #name) then
        best = BestName("")
        suffix = ""
    end
    label:SetText(best .. suffix)
end
function Raid:CreateRaidCooldownFrame()
    if self.raidCooldownFrame then return self.raidCooldownFrame end
    local settings = self:GetRaidCooldownSettings()
    local frame = Frame(UIParent)
    frame:SetSize(430, 80)
    frame:SetBackdropColor(.008, .018, .025, .72)
    frame:SetBackdropBorderColor(.08, .20, .27, .72)
    frame:SetPoint(settings.point or "CENTER", UIParent,
        settings.point or "CENTER", settings.x or -330, settings.y or 20)
    frame:SetFrameStrata("MEDIUM")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        if settings.locked then return end
        frame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        local point, _, _, x, y = frame:GetPoint(1)
        settings.point, settings.x, settings.y = point, x, y
    end)
    frame.Grip = CreateFrame("Button", nil, frame)
    frame.Grip:SetSize(16, 16)
    frame.Grip:SetPoint("TOPLEFT", 0, -1)
    frame.Grip:RegisterForDrag("LeftButton")
    frame.Grip.Dots = {}
    for index = 1, 3 do
        local dot = frame.Grip:CreateTexture(nil, "ARTWORK")
        dot:SetTexture(WHITE)
        dot:SetSize(2, 2)
        dot:SetPoint("CENTER", -4 + ((index - 1) * 4), 0)
        dot:SetVertexColor(.35, .66, .78, .58)
        frame.Grip.Dots[index] = dot
    end
    frame.Grip:SetScript("OnDragStart", function()
        if Raid:GetRaidCooldownSettings().locked then return end
        frame:StartMoving()
    end)
    frame.Grip:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        local point, _, _, x, y = frame:GetPoint(1)
        settings.point, settings.x, settings.y = point, x, y
    end)
    frame.Grip:SetScript("OnEnter", function(self)
        for _, dot in ipairs(self.Dots) do
            dot:SetVertexColor(.15, .75, 1, 1)
        end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Drag to move")
        GameTooltip:Show()
    end)
    frame.Grip:SetScript("OnLeave", function(self)
        for _, dot in ipairs(self.Dots) do
            dot:SetVertexColor(.35, .66, .78, .58)
        end
        GameTooltip:Hide()
    end)
    frame.Header = frame:CreateTexture(nil, "BACKGROUND")
    frame.Header:SetTexture(WHITE)
    frame.Header:SetPoint("TOPLEFT", 1, -1)
    frame.Header:SetPoint("TOPRIGHT", -1, -1)
    frame.Header:SetHeight(18)
    frame.Header:SetVertexColor(.025, .10, .14, .72)
    frame.Line = frame:CreateTexture(nil, "ARTWORK")
    frame.Line:SetTexture(WHITE)
    frame.Line:SetPoint("TOPLEFT", 1, -18)
    frame.Line:SetPoint("TOPRIGHT", -1, -18)
    frame.Line:SetHeight(1)
    frame.Line:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], .7)
    frame.Title = Label(frame, 9, "RAID COOLDOWNS", ACCENT)
    frame.Title:SetPoint("TOPLEFT", 9, -8)
    frame.Count = Label(frame, 8, "", MUTED)
    frame.Count:SetPoint("LEFT", frame.Title, "RIGHT", 8, 0)
    frame.Style = Frame(frame, "Button")
    frame.Style:SetSize(62, 19)
    frame.Style:SetPoint("TOPRIGHT", -30, -4)
    frame.Style:SetBackdropColor(.02, .05, .065, .55)
    frame.Style:SetBackdropBorderColor(.09, .22, .29, .65)
    frame.Style.Text = Label(frame.Style, 8, "", MUTED)
    frame.Style.Text:SetPoint("CENTER")
    frame.Style:SetScript("OnClick", function()
        local nextStyle = {
            CARDS = "COMPACT", COMPACT = "MINIMAL", MINIMAL = "CARDS",
        }
        settings.style = nextStyle[settings.style] or "CARDS"
        Raid:RefreshRaidCooldowns()
    end)
    frame.Style:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Change cooldown style")
        GameTooltip:Show()
    end)
    frame.Style:SetScript("OnLeave", function() GameTooltip:Hide() end)
    frame.Config = CreateFrame("Button", nil, frame)
    frame.Config:SetSize(22, 22)
    frame.Config:SetPoint("TOPRIGHT", -4, -3)
    frame.Config.Icon = frame.Config:CreateTexture(nil, "ARTWORK")
    frame.Config.Icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
    frame.Config.Icon:SetSize(14, 14)
    frame.Config.Icon:SetPoint("CENTER")
    frame.Config:SetScript(
        "OnClick", function() Raid:OpenRaidCooldownSettings() end)
    frame.Config:SetScript("OnEnter", function(self)
        self:SetAlpha(1)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Cooldown settings")
        GameTooltip:Show()
    end)
    frame.Config:SetScript("OnLeave", function(self)
        if Raid:GetRaidCooldownSettings().style == "MINIMAL" then
            self:SetAlpha(.48)
        end
        GameTooltip:Hide()
    end)
    frame.Nav = CreateFrame("Frame", nil, frame)
    frame.Nav:SetHeight(17)
    frame.Nav:SetPoint("BOTTOMLEFT", 2, 1)
    frame.Nav:SetPoint("BOTTOMRIGHT", -2, 1)
    frame.Nav.Previous = CreateFrame("Button", nil, frame.Nav)
    frame.Nav.Previous:SetSize(22, 16)
    frame.Nav.Previous:SetPoint("RIGHT", frame.Nav, "CENTER", -25, 0)
    frame.Nav.Previous.Text = Label(
        frame.Nav.Previous, 9, "<", MUTED)
    frame.Nav.Previous.Text:SetPoint("CENTER")
    frame.Nav.Previous:SetScript(
        "OnClick", function() Raid:ChangeRaidCooldownPage(-1) end)
    frame.Nav.Page = Label(frame.Nav, 8, "", MUTED)
    frame.Nav.Page:SetPoint("CENTER")
    frame.Nav.Next = CreateFrame("Button", nil, frame.Nav)
    frame.Nav.Next:SetSize(22, 16)
    frame.Nav.Next:SetPoint("LEFT", frame.Nav, "CENTER", 25, 0)
    frame.Nav.Next.Text = Label(frame.Nav.Next, 9, ">", MUTED)
    frame.Nav.Next.Text:SetPoint("CENTER")
    frame.Nav.Next:SetScript(
        "OnClick", function() Raid:ChangeRaidCooldownPage(1) end)
    frame.Nav:Hide()
    frame.Rows = {}
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= .2 then
            self.elapsed = 0
            Raid:RefreshRaidCooldowns()
        end
    end)
    frame:Hide()
    self.raidCooldownFrame = frame
    return frame
end

function Raid:CreateRaidCooldownRow(index)
    local owner = self:CreateRaidCooldownFrame()
    local row = Frame(owner)
    row:EnableMouse(true)
    row:RegisterForDrag("LeftButton")
    row:SetScript("OnDragStart", function()
        if Raid:GetRaidCooldownSettings().locked then return end
        row.wasDragged = true
        owner:StartMoving()
    end)
    row:SetScript("OnDragStop", function()
        owner:StopMovingOrSizing()
        local settings = Raid:GetRaidCooldownSettings()
        local point, _, _, x, y = owner:GetPoint(1)
        settings.point, settings.x, settings.y = point, x, y
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function() row.wasDragged = nil end)
        else
            row.wasDragged = nil
        end
    end)
    row:EnableMouseWheel(true)
    row:SetScript("OnMouseWheel", function(_, delta)
        Raid:ChangeRaidCooldownPage(delta < 0 and 1 or -1)
    end)
    row.Icon = row:CreateTexture(nil, "ARTWORK")
    row.Icon:SetPoint("LEFT", 7, 0)
    row.IconHit = CreateFrame("Button", nil, row)
    row.IconHit:SetAllPoints(row.Icon)
    row.IconHit:SetScript("OnEnter", function()
        if not row.definition then return end
        GameTooltip:SetOwner(row.IconHit, "ANCHOR_TOP")
        GameTooltip:SetText(row.definition[2])
        GameTooltip:AddDoubleLine(
            "Base cooldown",
            CooldownLength(row.definition[5]),
            .62, .72, .78, .95, .82, .35)
        GameTooltip:Show()
    end)
    row.IconHit:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row.Name = Label(row, 9, "")
    row.Name:SetPoint("LEFT", row.Icon, "RIGHT", 8, 5)
    row.Detail = Label(row, 8, "", MUTED)
    row.Detail:SetPoint("LEFT", row.Icon, "RIGHT", 8, -8)
    row.Chips = {}
    owner.Rows[index] = row
    return row
end

function Raid:WhisperRaidCooldown(playerName, definition)
    if not playerName or not definition then return end
    if not self:GetRaidCooldownSettings().whisperEnabled then return end
    if not IsInGroup or not IsInGroup() then
        self:Print("Join a group before sending cooldown requests.")
        return
    end
    local spell = definition[2]
    local spellID = definition[4]
    if C_Spell and C_Spell.GetSpellLink then
        local ok, link = pcall(C_Spell.GetSpellLink, spellID)
        if ok and type(link) == "string" and link ~= "" then
            spell = link
        end
    elseif GetSpellLink then
        local ok, link = pcall(GetSpellLink, spellID)
        if ok and type(link) == "string" and link ~= "" then
            spell = link
        end
    end
    self:QueueMessage(
        "WHISPER", playerName, "Cast " .. spell .. ".", true)
    self:StartMessageQueue()
end

function Raid:CreateRaidCooldownChip(row, index)
    local chip = Frame(row, "Button")
    chip.Fill = chip:CreateTexture(nil, "BACKGROUND", nil, 1)
    chip.Fill:SetTexture(WHITE)
    chip.Fill:SetPoint("TOPLEFT", 1, -1)
    chip.Fill:SetPoint("BOTTOMLEFT", 1, 1)
    chip.Text = Label(chip, 8, "")
    chip.Text:SetPoint("CENTER")
    chip.Icon = chip:CreateTexture(nil, "ARTWORK")
    chip.Icon:SetSize(17, 17)
    chip.Icon:SetPoint("LEFT", 1, 0)
    chip.Icon:Hide()
    chip.IconHit = CreateFrame("Button", nil, chip)
    chip.IconHit:SetAllPoints(chip.Icon)
    chip.IconHit:Hide()
    chip.IconHit:SetScript("OnEnter", function()
        if not chip.definition then return end
        GameTooltip:SetOwner(chip.IconHit, "ANCHOR_TOP")
        GameTooltip:SetText(chip.definition[2])
        GameTooltip:AddDoubleLine(
            "Base cooldown",
            CooldownLength(chip.definition[5]),
            .62, .72, .78, .95, .82, .35)
        GameTooltip:Show()
    end)
    chip.IconHit:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    chip.IconHit:SetScript("OnClick", function()
        if chip.playerOnline and chip.playerName and chip.definition then
            Raid:WhisperRaidCooldown(
                chip.playerName, chip.definition)
        end
    end)
    chip.Status = Label(chip, 8, "", MUTED)
    chip.Status:SetPoint("RIGHT", -4, 0)
    chip.Status:Hide()
    chip:EnableMouse(true)
    chip:RegisterForClicks("LeftButtonUp")
    chip:RegisterForDrag("LeftButton")
    chip:SetScript("OnEnter", function(self)
        if not self.definition then return end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(self.definition[2])
        GameTooltip:AddLine(
            ShortName(self.playerName) .. " - " .. (self.statusText or ""),
            .78, .86, .90, true)
        GameTooltip:Show()
    end)
    chip:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    chip:SetScript("OnClick", function(self)
        if self.wasDragged then return end
        if self.playerOnline and self.playerName and self.definition then
            Raid:WhisperRaidCooldown(
                self.playerName, self.definition)
        end
    end)
    chip:SetScript("OnDragStart", function(self)
        local settings = Raid:GetRaidCooldownSettings()
        if settings.locked then return end
        self.wasDragged = true
        Raid:CreateRaidCooldownFrame():StartMoving()
    end)
    chip:SetScript("OnDragStop", function(self)
        local owner = Raid:CreateRaidCooldownFrame()
        owner:StopMovingOrSizing()
        local settings = Raid:GetRaidCooldownSettings()
        local point, _, _, x, y = owner:GetPoint(1)
        settings.point, settings.x, settings.y = point, x, y
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function() self.wasDragged = nil end)
        else
            self.wasDragged = nil
        end
    end)
    row.Chips[index] = chip
    return chip
end

function Raid:RefreshRaidCooldowns()
    if not self.db then return end
    local settings = self:GetRaidCooldownSettings()
    local frame = self:CreateRaidCooldownFrame()
    frame:SetScale(
        (settings.scale or 1) * self:GetHUDScale())
    frame:SetAlpha(1)
    local simulated = self.simulation and self.simulation.enabled
    local visibility = settings.visibility or "GROUP"
    local inGroup = IsInGroup and IsInGroup()
    local inRaid = IsInRaid and IsInRaid()
    local visibilityAllows = visibility == "ALWAYS"
        or visibility == "GROUP" and inGroup
        or visibility == "RAID" and inRaid
    if not settings.enabled
        or (not simulated and not visibilityAllows)
    then
        frame:Hide()
        if self.raidCooldownConfig then self.raidCooldownConfig:Hide() end
        return
    end
    local style = settings.style
    local columnWidth = style == "CARDS" and 142
        or style == "COMPACT" and 112 or 72
    local rowGap = settings.rowSpacing or 1
    local columnGap = settings.columnSpacing or 1
    local columnHeader = style == "CARDS" and 38
        or style == "COMPACT" and 30 or 23
    local chipHeight = style == "CARDS" and 20
        or style == "COMPACT" and 18 or 17
    local rowLayout = settings.layout == "ROWS"
    local listLayout = settings.layout == "LIST"
    local visible, now = 0, CurrentTime()
    local maxColumns = #DEFINITIONS
    local bandTop, bandTallest, usedWidth = 0, 0, 0
    local orderedDefinitions = {}
    for index, definition in ipairs(DEFINITIONS) do
        orderedDefinitions[index] = definition
    end
    if settings.sortMode == "CLASS" then
        table.sort(orderedDefinitions, function(left, right)
            if left[3] ~= right[3] then return left[3] < right[3] end
            return left[2] < right[2]
        end)
    elseif settings.sortMode == "NAME" then
        table.sort(orderedDefinitions, function(left, right)
            return left[2] < right[2]
        end)
    end
    local totalCards = 0
    for _, definition in ipairs(orderedDefinitions) do
        if settings.spells[definition[1]] ~= false then
            for _, player in ipairs(self.roster or {}) do
                if self:IsRaidCooldownPlayerEligible(player, definition) then
                    totalCards = totalCards + 1
                    break
                end
            end
        end
    end
    local pageCount = 1
    settings.page = 1
    local pageStart = 1
    local pageEnd = totalCards
    local cardIndex = 0
    local minimal = style == "MINIMAL"
    local showChrome = false
    frame:SetBackdropColor(
        .008, .018, .025, minimal and (
            showChrome and .70 or 0) or .72)
    frame:SetBackdropBorderColor(
        .08, .20, .27, minimal and 0 or .72)
    frame.Header:SetVertexColor(
        .025, .10, .14, minimal and (
            showChrome and .82 or 0) or .72)
    frame.Line:SetVertexColor(
        ACCENT[1], ACCENT[2], ACCENT[3], minimal and 0 or .7)
    frame.Title:SetShown(not minimal or showChrome)
    if minimal then frame.Title:SetText("RAID COOLDOWNS") end
    frame.Count:SetShown(not minimal)
    frame.Style:SetShown(not minimal)
    frame.Grip:SetShown(false)
    frame.Config:SetSize(minimal and 18 or 22, minimal and 18 or 22)
    frame.Config.Icon:SetSize(minimal and 12 or 14, minimal and 12 or 14)
    frame.Config:ClearAllPoints()
    if minimal then
        frame.Config:SetShown(showChrome)
        frame.Config:ClearAllPoints()
        frame.Config:SetPoint("TOPRIGHT", -3, -2)
        frame.Config:SetAlpha(1)
    else
        frame.Config:Show()
        frame.Config:SetPoint("TOPRIGHT", -3, -3)
        frame.Config:SetAlpha(1)
    end
    for _, definition in ipairs(orderedDefinitions) do
        local players = {}
        if settings.spells[definition[1]] ~= false then
            for _, player in ipairs(self.roster or {}) do
                if self:IsRaidCooldownPlayerEligible(player, definition) then
                    players[#players + 1] = player
                end
            end
        end
        if #players > 0 then
            cardIndex = cardIndex + 1
        end
        if #players > 0
            and cardIndex >= pageStart and cardIndex <= pageEnd
        then
            local displayPlayers, readyNames = players, {}
            local readyCount, onlineCount = 0, 0
            for _, player in ipairs(players) do
                if player.online ~= false then
                    onlineCount = onlineCount + 1
                    local state =
                        self:GetRaidCooldownState(definition, player)
                    local remaining = state and state.expires - now or 0
                    if remaining <= 0 then
                        readyCount = readyCount + 1
                        readyNames[#readyNames + 1] =
                            ShortName(player.name)
                    end
                end
            end
            visible = visible + 1
            local row = frame.Rows[visible]
                or self:CreateRaidCooldownRow(visible)
            row.definition = definition
            row.readyNames = readyNames
            local lanes = listLayout and 1
                or rowLayout and #displayPlayers
                or 1
            local playerRows = rowLayout and 1
                or math.ceil(#displayPlayers / lanes)
            local rowLeadWidth = settings.showAbilityName
                    and (settings.showAbilityTotal and 148 or 120)
                or settings.showAbilityTotal and 48 or 24
            local activeColumnWidth = listLayout
                    and (204 + ((columnGap - 1) * 2))
                or rowLayout
                    and (rowLeadWidth + (#displayPlayers * 62)
                        + (math.max(0, #displayPlayers - 1) * columnGap))
                    or columnWidth
            local columnHeight = listLayout
                    and ((#displayPlayers * 18)
                        + (math.max(0, #displayPlayers - 1) * rowGap))
                or rowLayout and 18
                or columnHeader + (playerRows * chipHeight)
                    + (math.max(0, playerRows - 1) * rowGap) + 3
            local layoutColumns =
                (rowLayout or listLayout) and 1 or maxColumns
            local columnInBand = ((visible - 1) % layoutColumns) + 1
            if columnInBand == 1 and visible > 1 then
                bandTop = bandTop + bandTallest + rowGap
                bandTallest = 0
            end
            bandTallest = math.max(bandTallest, columnHeight)
            usedWidth = math.max(
                usedWidth,
                (columnInBand * activeColumnWidth)
                    + ((columnInBand - 1) * columnGap))
            row:ClearAllPoints()
            row:SetPoint(
                "TOPLEFT", (minimal and 2 or 5)
                    + ((columnInBand - 1)
                        * (activeColumnWidth + columnGap)),
                (minimal and -20 or -32) - bandTop)
            row:SetSize(activeColumnWidth, columnHeight)
            row:SetBackdropColor(
                .015, .035, .047, minimal and 0 or .58)
            local collapseRowBorder = rowLayout and rowGap == 0
                or not rowLayout and columnGap == 0
            row:SetBackdropBorderColor(
                .07, .17, .22,
                (minimal or collapseRowBorder) and 0 or .62)
            row.Icon:ClearAllPoints()
            row.Icon:SetTexture(
                GetSpellTexture and GetSpellTexture(definition[4])
                    or definition[4])
            row.Icon:SetShown(not listLayout)
            row.IconHit:SetShown(not listLayout)
            local iconSize = style == "MINIMAL" and 16
                or style == "COMPACT" and 19 or 22
            row.Icon:SetSize(
                rowLayout and 17 or iconSize,
                rowLayout and 17 or iconSize)
            row.Icon:SetPoint(
                rowLayout and "LEFT"
                    or minimal and "TOP" or "TOPLEFT",
                rowLayout and 4 or minimal and 0 or 5,
                rowLayout and 0 or -5)
            row.Name:ClearAllPoints()
            if rowLayout then
                row.Name:SetPoint("LEFT", row.Icon, "RIGHT", 5, 0)
                row.Name:SetPoint("RIGHT", row, "LEFT", 116, 0)
            else
                row.Name:SetPoint(
                    "TOPLEFT", row.Icon, "TOPRIGHT", 5, -1)
                row.Name:SetPoint("RIGHT", -3, 0)
            end
            row.Name:SetJustifyH("LEFT")
            row.Name:SetShown(
                not listLayout
                    and (not rowLayout or settings.showAbilityName))
            row.Name:SetText(
                rowLayout and definition[2]
                    or minimal and "" or definition[2])
            row.Detail:ClearAllPoints()
            row.Detail:SetShown(
                not listLayout
                    and (not rowLayout or settings.showAbilityTotal))
            if rowLayout then
                row.Detail:SetPoint(
                    "RIGHT", row, "LEFT",
                    settings.showAbilityName and 143 or 44, 0)
                row.Detail:SetJustifyH("RIGHT")
            elseif minimal then
                row.Detail:SetPoint("TOP", row.Icon, "BOTTOM", 0, -2)
                row.Detail:SetJustifyH("CENTER")
            else
                row.Detail:SetPoint(
                    "TOPLEFT", row.Icon, "TOPRIGHT", 5, -15)
                row.Detail:SetPoint("RIGHT", -3, 0)
                row.Detail:SetJustifyH("LEFT")
            end
            row.Detail:SetText(
                rowLayout and (readyCount .. "/" .. onlineCount)
                    or minimal and ""
                    or style == "CARDS"
                        and (readyCount .. "/" .. onlineCount .. " ready")
                    or (readyCount .. "/" .. onlineCount))
            local chipWidth = listLayout and activeColumnWidth
                or rowLayout and 62 or math.floor(
                (activeColumnWidth - 8
                    - ((lanes - 1) * columnGap)) / lanes)
            for index, player in ipairs(displayPlayers) do
                local chip = row.Chips[index]
                    or self:CreateRaidCooldownChip(row, index)
                chip:ClearAllPoints()
                local lane = (index - 1) % lanes
                local playerRow = listLayout and 0
                    or math.floor((index - 1) / lanes)
                chip:SetPoint("TOPLEFT",
                    (listLayout and 0 or rowLayout and rowLeadWidth or 4)
                        + (lane * (chipWidth + columnGap)),
                    (listLayout and -((index - 1) * (18 + rowGap))
                        or rowLayout and 0 or -columnHeader)
                        - (playerRow * (chipHeight + rowGap)))
                chip:SetSize(chipWidth, listLayout and 18 or chipHeight)
                SetLabelSize(chip.Text, settings.textSize)
                SetLabelSize(chip.Status, settings.textSize)
                local state = self:GetRaidCooldownState(definition, player)
                local remaining = state and state.expires - now or 0
                local effect = self:GetRaidCooldownEffect(
                    definition, player)
                local effectRemaining = effect
                    and effect.expires - now or 0
                local offline = player.online == false
                local ready = not offline and remaining <= 0
                local activeEffect = not offline and effectRemaining > 0
                local displayRemaining = activeEffect
                    and effectRemaining or remaining
                local color = RAID_CLASS_COLORS
                    and RAID_CLASS_COLORS[player.class]
                    or { r = .3, g = .7, b = 1 }
                local readyColor = settings.classColors and {
                        r = color.r * .72,
                        g = color.g * .72,
                        b = color.b * .72,
                    } or {
                        r = settings.readyColor[1],
                        g = settings.readyColor[2],
                        b = settings.readyColor[3],
                    }
                local cooldownColor = {
                    r = settings.cooldownColor[1],
                    g = settings.cooldownColor[2],
                    b = settings.cooldownColor[3],
                }
                local effectColor = { r = .08, g = .52, b = .72 }
                local barColor = activeEffect and effectColor
                    or ready and readyColor or cooldownColor
                local collapseChipBorder = listLayout and rowGap == 0
                    or rowLayout and columnGap == 0
                    or not listLayout and not rowLayout
                        and (rowGap == 0 or columnGap == 0)
                chip:SetBackdropColor(
                    .02, .045, .058,
                    offline and .24 or minimal and .46 or .64)
                chip:SetBackdropBorderColor(
                    offline and .25
                        or barColor.r,
                    offline and .28
                        or barColor.g,
                    offline and .30
                        or barColor.b,
                    collapseChipBorder and 0
                        or listLayout and .42 or minimal and 0 or .76)
                local progress = offline and 0
                    or activeEffect and math.max(
                        0, math.min(1,
                            effectRemaining / math.max(
                                1, tonumber(effect.duration)
                                    or tonumber(definition[9]) or 1)))
                    or listLayout and ready and 0
                    or ready and 1 or math.max(
                    0, math.min(1, remaining / definition[5]))
                local horizontalInset = columnGap == 0 and 0 or 1
                local verticalInset = rowGap == 0 and 0 or 1
                chip.Fill:ClearAllPoints()
                chip.Fill:SetPoint(
                    "TOPLEFT", horizontalInset, -verticalInset)
                chip.Fill:SetPoint(
                    "BOTTOMLEFT", horizontalInset, verticalInset)
                chip.Fill:SetWidth(math.max(
                    1, (chipWidth - (horizontalInset * 2)) * progress))
                chip.Fill:SetVertexColor(
                    barColor.r, barColor.g, barColor.b,
                    1)
                chip.Fill:SetAlpha(settings.hudOpacity)
                chip.Icon:SetShown(listLayout)
                chip.IconHit:SetShown(listLayout)
                chip.definition = definition
                chip.Status:SetShown(listLayout)
                chip.Text:ClearAllPoints()
                if listLayout then
                    chip.Icon:SetTexture(
                        GetSpellTexture
                            and GetSpellTexture(definition[4])
                            or definition[4])
                    chip.Text:SetPoint(
                        "LEFT", chip.Icon, "RIGHT", columnGap, 0)
                    chip.Text:SetPoint(
                        "RIGHT", chip.Status, "LEFT", -columnGap, 0)
                    chip.Text:SetJustifyH("LEFT")
                    chip.Status:SetText(
                        offline and "Offline"
                            or activeEffect and TimeText(effectRemaining)
                            or ready and "Ready" or TimeText(remaining))
                    chip.Status:SetTextColor(
                        offline and .42
                            or barColor.r,
                        offline and .46
                            or barColor.g,
                        offline and .49
                            or barColor.b, 1)
                    FitBarText(
                        chip.Text, player.name, "",
                        math.max(1, chipWidth - 29
                            - chip.Status:GetStringWidth()
                            - (columnGap * 2)))
                else
                    chip.Text:SetPoint("CENTER")
                    chip.Text:SetJustifyH("CENTER")
                    local suffix = offline and " |cff737b80OFFLINE|r"
                        or activeEffect and (
                            " |cff43bff5" .. TimeText(effectRemaining) .. "|r")
                        or not ready and (
                            " |cffff8a70" .. TimeText(displayRemaining) .. "|r")
                        or ""
                    FitBarText(
                        chip.Text, player.name, suffix,
                        math.max(1, chipWidth - 6))
                end
                if listLayout then
                    chip.Text:SetTextColor(
                        offline and .45 or .88,
                        offline and .48 or .90,
                        offline and .50 or .92, 1)
                else
                    chip.Text:SetTextColor(
                        offline and .45 or .92,
                        offline and .48 or .94,
                        offline and .50 or .96, 1)
                end
                chip.playerName = player.name
                chip.playerOnline = not offline
                chip.statusText = offline and "Offline"
                    or activeEffect and (
                        definition[2] .. " active"
                            .. (effect.targetName and (
                                " on " .. ShortName(effect.targetName)) or "")
                            .. ": " .. TimeText(effectRemaining)
                            .. " remaining")
                    or ready and "Ready"
                    or ((state and state.exact and "Synced: " or "Cooldown: ")
                        .. TimeText(remaining) .. " remaining")
                chip:Show()
            end
            for index = #displayPlayers + 1, #row.Chips do
                row.Chips[index]:Hide()
            end
            row:Show()
        end
    end
    for index = visible + 1, #frame.Rows do frame.Rows[index]:Hide() end
    frame.Style.Text:SetText(style)
    frame.Count:SetText(
        visible > 0 and (visible .. " CARDS") or "SELECT COOLDOWNS")
    frame.Nav:Hide()
    frame.Nav.Page:SetText(settings.page .. "/" .. pageCount)
    frame.Nav.Previous:SetEnabled(settings.page > 1)
    frame.Nav.Next:SetEnabled(settings.page < pageCount)
    frame.Nav.Previous:SetAlpha(settings.page > 1 and 1 or .3)
    frame.Nav.Next:SetAlpha(settings.page < pageCount and 1 or .3)
    local navigationHeight = pageCount > 1 and 18 or 0
    frame:SetWidth(math.max(
        minimal and 100 or 300,
        (minimal and 4 or 10) + usedWidth))
    local previousTop = rowLayout and frame:GetTop()
    local targetHeight =
        minimal and math.max(
            36, 20 + bandTop + bandTallest + 2 + navigationHeight)
            or math.max(
                34, 36 + bandTop + bandTallest + navigationHeight)
    frame:SetHeight(targetHeight)
    if previousTop then
        local currentTop = frame:GetTop()
        if currentTop and math.abs(currentTop - previousTop) > .01 then
            local point, relativeTo, relativePoint, x, y =
                frame:GetPoint(1)
            frame:ClearAllPoints()
            frame:SetPoint(
                point, relativeTo, relativePoint,
                x, y + previousTop - currentTop)
            settings.point, settings.x, settings.y =
                point, x, y + previousTop - currentTop
        end
    end
    frame:Show()
end

function Raid:ChangeRaidCooldownPage(direction)
    local settings = self:GetRaidCooldownSettings()
    settings.page = math.max(
        1, (tonumber(settings.page) or 1) + (tonumber(direction) or 0))
    self:RefreshRaidCooldowns()
end

function Raid:ClearSimulatedRaidCooldowns()
    local settings = self:GetRaidCooldownSettings()
    for _, states in pairs(settings.active or {}) do
        for owner, state in pairs(states) do
            if state.simulated then states[owner] = nil end
        end
    end
    self.raidCooldownState = settings.active
end

function Raid:SeedSimulatedRaidCooldowns()
    self:ClearSimulatedRaidCooldowns()
    local settings = self:GetRaidCooldownSettings()
    local now = CurrentTime()
    for definitionIndex, definition in ipairs(DEFINITIONS) do
        if settings.spells[definition[1]] ~= false then
            local eligibleIndex = 0
            for _, player in ipairs(self.roster or {}) do
                if self:IsRaidCooldownPlayerEligible(player, definition) then
                    eligibleIndex = eligibleIndex + 1
                    if (eligibleIndex + definitionIndex) % 3 == 0 then
                        local key = "SIM:" .. definition[1]
                            .. ":" .. tostring(player.name)
                        settings.active[definition[1]] =
                            settings.active[definition[1]] or {}
                        settings.active[definition[1]][key] = {
                            name = player.name,
                            simulated = true,
                            expires = now + math.max(
                                8, math.floor(definition[5]
                                    * (.25 + ((eligibleIndex % 3) * .2)))),
                        }
                    end
                end
            end
        end
    end
    self.raidCooldownState = settings.active
    self:RefreshRaidCooldowns()
end

function Raid:CreateRaidCooldownConfig()
    if self.raidCooldownConfig then return self.raidCooldownConfig end
    local owner = self:CreateRaidCooldownFrame()
    local panel = Frame(UIParent)
    panel:SetSize(330, 53 + (#DEFINITIONS * 27))
    panel:SetPoint("TOPLEFT", owner, "TOPRIGHT", 6, 0)
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel.Title = Label(panel, 11, "COOLDOWN DECK", ACCENT)
    panel.Title:SetPoint("TOPLEFT", 11, -11)
    panel.Help = Label(
        panel, 8, "Choose which abilities become cards.", MUTED)
    panel.Help:SetPoint("TOPLEFT", 11, -28)
    panel.Close = CreateFrame("Button", nil, panel)
    panel.Close:SetSize(24, 24)
    panel.Close:SetPoint("TOPRIGHT", -5, -5)
    panel.Close.Text = Label(panel.Close, 10, "X", MUTED)
    panel.Close.Text:SetPoint("CENTER")
    panel.Close:SetScript("OnClick", function() panel:Hide() end)
    panel.Rows = {}
    for index, definition in ipairs(DEFINITIONS) do
        local definitionForRow = definition
        local row = CreateFrame("Button", nil, panel)
        row:SetPoint("TOPLEFT", 8, -48 - ((index - 1) * 27))
        row:SetPoint("TOPRIGHT", -8, -48 - ((index - 1) * 27))
        row:SetHeight(24)
        row.Icon = row:CreateTexture(nil, "ARTWORK")
        row.Icon:SetSize(19, 19)
        row.Icon:SetPoint("LEFT", 3, 0)
        row.Icon:SetTexture(
            GetSpellTexture and GetSpellTexture(definition[4])
                or definition[4])
        row.Name = Label(row, 9, definition[2])
        row.Name:SetPoint("LEFT", row.Icon, "RIGHT", 7, 0)
        row.State = Label(row, 8, "", ACCENT)
        row.State:SetPoint("RIGHT", -4, 0)
        row.definition = definitionForRow
        row:SetScript("OnClick", function()
            local settings = Raid:GetRaidCooldownSettings()
            settings.spells[definitionForRow[1]] =
                not settings.spells[definitionForRow[1]]
            Raid:RefreshRaidCooldownConfig()
            Raid:RefreshRaidCooldowns()
        end)
        panel.Rows[index] = row
    end
    panel:Hide()
    self.raidCooldownConfig = panel
    return panel
end

function Raid:RefreshRaidCooldownConfig()
    local panel = self:CreateRaidCooldownConfig()
    local settings = self:GetRaidCooldownSettings()
    for _, row in ipairs(panel.Rows) do
        local enabled = settings.spells[row.definition[1]] ~= false
        row.State:SetText(enabled and "ON" or "OFF")
        row.State:SetTextColor(
            enabled and .18 or .75, enabled and .9 or .25,
            enabled and .55 or .25, 1)
    end
end

function Raid:ToggleRaidCooldownConfig()
    local panel = self:CreateRaidCooldownConfig()
    if panel:IsShown() then
        panel:Hide()
    else
        self:RefreshRaidCooldownConfig()
        panel:Show()
    end
end

function Raid:ToggleRaidCooldowns()
    local settings = self:GetRaidCooldownSettings()
    settings.enabled = not settings.enabled
    self:RefreshRaidCooldowns()
    self:Print("Raid cooldowns "
        .. (settings.enabled and "enabled." or "hidden."))
end

function Raid:OpenRaidCooldownSettings()
    self.settingsTab = "COOLDOWNS"
    self:ShowSettingsView()
end

function Raid:OpenRaidCooldownColorPicker(key)
    local settings = self:GetRaidCooldownSettings()
    local color = settings[key]
    if not color or not ColorPickerFrame then return end
    local original = { color[1], color[2], color[3] }
    local function apply()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        color[1], color[2], color[3] = r, g, b
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end
    local function cancel()
        color[1], color[2], color[3] =
            original[1], original[2], original[3]
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end
    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = color[1], g = color[2], b = color[3],
            swatchFunc = apply,
            cancelFunc = cancel,
        })
    else
        ColorPickerFrame.func = apply
        ColorPickerFrame.cancelFunc = cancel
        ColorPickerFrame:SetColorRGB(color[1], color[2], color[3])
        ColorPickerFrame:Show()
    end
end

