local _, Raid = ...

local ROW_HEIGHT = 38
local FRAME_WIDTH, FRAME_HEIGHT = 980, 760
local ROSTER_WIDTH, ROSTER_ROW_WIDTH = 260, 248
local ASSIGNMENT_ROW_WIDTH = 674
local BOSS_RAIL_WIDTH, BOSS_BUTTON_SIZE = 48, 38
local NAV_RAIL_WIDTH = 48
local BOSS_RAIL_GAP = 5
local ACCENT = { .18, .70, 1.00, 1 }
local BORDER = { .16, .22, .28, 1 }
local MUTED = { .55, .62, .69, 1 }
local WHITE = "Interface\\Buttons\\WHITE8X8"
local ROLE_TEXTURE =
    "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"
local ROLE_COORDS = {
    TANK = { 0, 19 / 64, 22 / 64, 41 / 64 },
    HEALER = { 20 / 64, 39 / 64, 1 / 64, 20 / 64 },
    DAMAGER = { 20 / 64, 39 / 64, 22 / 64, 41 / 64 },
}

local READY_CHECK_FOOD = {
    [33257] = true, [35272] = true, [45245] = true,
    [33254] = true, [33268] = true, [33263] = true,
    [33259] = true, [33261] = true, [33256] = true,
    [43764] = true, [43722] = true, [33265] = true,
    [45619] = true, [46682] = true, [44104] = true,
    [44098] = true, [44101] = true, [44099] = true,
    [44102] = true, [44106] = true, [44105] = true,
    [44097] = true, [44100] = true, [43771] = true,
    [33272] = true, [19705] = true, [19710] = true,
    [19706] = true, [19708] = true, [46899] = true,
    [19709] = true, [25941] = true, [40323] = true,
    [42293] = true, [25694] = true, [19711] = true,
    [24870] = true,
}

local READY_CHECK_FLASK = {
    -- Original Classic flasks and elixirs still commonly used in TBC.
    [17629] = true, [17627] = true, [17628] = true,
    [17626] = true, [17538] = true, [11474] = true,
    [17539] = true, [26276] = true, [21920] = true,
    [17535] = true, [11348] = true, [11371] = true,
    [24382] = true, [24417] = true, [24383] = true,
    [10669] = true, [10692] = true, [10693] = true,
    [10668] = true, [24363] = true, [3593] = true,
    [24361] = true, [16323] = true, [11405] = true,
    [16329] = true, [17038] = true, [16326] = true,
    [16325] = true, [15233] = true, [15279] = true,
    [5665] = true, [17549] = true, [17543] = true,
    [17544] = true, [17546] = true, [17548] = true,
    [17545] = true, [17537] = true, [11334] = true,
    [28518] = true, [28540] = true, [28520] = true,
    [28521] = true, [28519] = true, [42735] = true,
    [41609] = true, [46837] = true, [41608] = true,
    [46839] = true, [41610] = true, [41611] = true,
    [40572] = true, [40576] = true, [40567] = true,
    [40568] = true, [40573] = true, [40575] = true,
    [28503] = true, [38954] = true, [28497] = true,
    [28501] = true, [28493] = true, [28491] = true,
    [33726] = true, [28490] = true, [33721] = true,
    [33720] = true, [28514] = true, [28509] = true,
    [28502] = true, [39628] = true, [39627] = true,
    [39626] = true, [39625] = true, [28496] = true,
    [11406] = true, [28489] = true, [28515] = true, [38910] = true,
    [38927] = true, [28511] = true, [28537] = true,
    [28513] = true, [28512] = true, [28536] = true,
    [28538] = true,
}

local READY_CHECK_COLUMNS = {
    { key = "food", label = "Food", icon = 136000,
        spells = READY_CHECK_FOOD, foodIcon = true },
    { key = "flask", label = "Flask / Elixir", icon = 134877,
        spells = READY_CHECK_FLASK },
    { key = "scroll", label = "Scroll", icon = 134943,
        spells = {
            [33077] = true, [33082] = true, [33079] = true,
            [33078] = true, [33080] = true, [33081] = true,
            [12174] = true, [12179] = true, [12176] = true,
            [12178] = true, [12177] = true, [12175] = true,
        } },
    { key = "motw", label = "Mark of the Wild", icon = 136078,
        spells = {
            [26991] = true, [21850] = true, [21849] = true,
            [1126] = true, [5232] = true, [5234] = true,
            [6756] = true, [8907] = true, [9884] = true,
            [9885] = true, [26990] = true,
        } },
    { key = "int", label = "Arcane Intellect", icon = 135932,
        spells = {
            [27126] = true, [10157] = true, [10156] = true,
            [1461] = true, [1460] = true, [1459] = true,
            [23028] = true, [27127] = true,
        } },
    { key = "fort", label = "Power Word: Fortitude", icon = 135987,
        spells = {
            [1243] = true, [21562] = true, [21564] = true,
            [25392] = true, [1244] = true, [1245] = true,
            [2791] = true, [10937] = true, [10938] = true,
            [25389] = true,
        } },
    { key = "spirit", label = "Divine Spirit", icon = 135946,
        spells = {
            [27681] = true, [32999] = true, [14752] = true,
            [14818] = true, [14819] = true, [27841] = true,
            [25312] = true,
        } },
    { key = "ap", label = "Battle Shout", icon = 132333,
        spells = {
            [6673] = true, [5242] = true, [6192] = true,
            [11549] = true, [11550] = true, [11551] = true,
            [25289] = true, [2048] = true,
        } },
    { key = "armor", label = "Inner Fire", icon = 135926,
        spells = {
            [588] = true, [7128] = true, [602] = true,
            [1006] = true, [10951] = true, [10952] = true,
            [25431] = true,
        } },
    { key = "shadow", label = "Shadow Protection", icon = 136121,
        spells = {
            [25433] = true, [10958] = true, [976] = true,
            [10957] = true, [27683] = true, [39374] = true,
        } },
    { key = "kings", label = "Blessing of Kings", icon = 135993,
        spells = {
            [20217] = true, [25898] = true,
        } },
    { key = "might", label = "Blessing of Might", icon = 135908,
        spells = {
            [19740] = true, [19834] = true, [19835] = true,
            [19836] = true, [19837] = true, [19838] = true,
            [25291] = true, [27140] = true, [25782] = true,
            [25916] = true, [27141] = true,
        } },
    { key = "wisdom", label = "Blessing of Wisdom", icon = 135970,
        spells = {
            [19742] = true, [19850] = true, [19852] = true,
            [19853] = true, [19854] = true, [25290] = true,
            [27142] = true, [25894] = true, [25918] = true,
            [27143] = true,
        } },
    { key = "salvation", label = "Blessing of Salvation", icon = 135967,
        spells = {
            [1038] = true, [25895] = true,
        } },
    { key = "light", label = "Blessing of Light",
        icon = "Interface\\Icons\\Spell_Holy_GreaterBlessingofLight",
        spells = {
            [19977] = true, [19978] = true, [19979] = true,
            [27144] = true, [25890] = true, [27145] = true,
        } },
    { key = "weapon", label = "Weapon Enhancement", icon = 135249,
        spells = {} },
    { key = "durability", label = "Average durability", icon = 132281,
        spells = {} },
}
local READY_CHECK_GRID_START = 198
local READY_CHECK_COLUMN_WIDTH = 32
local GEAR_INSPECT_SLOTS = {
    { id = 1, token = "HeadSlot", label = "Head" },
    { id = 2, token = "NeckSlot", label = "Neck" },
    { id = 3, token = "ShoulderSlot", label = "Shoulder" },
    { id = 15, token = "BackSlot", label = "Back" },
    { id = 5, token = "ChestSlot", label = "Chest" },
    { id = 9, token = "WristSlot", label = "Wrist" },
    { id = 10, token = "HandsSlot", label = "Hands" },
    { id = 6, token = "WaistSlot", label = "Waist" },
    { id = 7, token = "LegsSlot", label = "Legs" },
    { id = 8, token = "FeetSlot", label = "Feet" },
    { id = 11, token = "Finger0Slot", label = "Ring 1" },
    { id = 12, token = "Finger1Slot", label = "Ring 2" },
    { id = 13, token = "Trinket0Slot", label = "Trinket 1" },
    { id = 14, token = "Trinket1Slot", label = "Trinket 2" },
    { id = 16, token = "MainHandSlot", label = "Main Hand" },
    { id = 17, token = "SecondaryHandSlot", label = "Off Hand" },
    { id = 18, token = "RangedSlot", label = "Ranged" },
}
local READY_CHECK_BY_SPELL = {}
for _, column in ipairs(READY_CHECK_COLUMNS) do
    for spellID in pairs(column.spells) do
        local matches = READY_CHECK_BY_SPELL[spellID] or {}
        matches[#matches + 1] = column
        READY_CHECK_BY_SPELL[spellID] = matches
    end
end
local READY_CHECK_FOOD_MATCHES = { READY_CHECK_COLUMNS[1] }

local function Pixel(value)
    local scale = UIParent and UIParent:GetEffectiveScale() or 1
    if not scale or scale <= 0 then scale = 1 end
    return math.floor((value * scale) + .5) / scale
end

local function PixelForRegion(region, value)
    local scale = region and region.GetEffectiveScale
        and region:GetEffectiveScale()
        or UIParent and UIParent:GetEffectiveScale()
        or 1
    if not scale or scale <= 0 then scale = 1 end
    return math.floor(((value or 0) * scale) + .5) / scale
end

local function PhysicalPixels(region, count)
    local scale = region and region.GetEffectiveScale
        and region:GetEffectiveScale()
        or UIParent and UIParent:GetEffectiveScale()
        or 1
    if not scale or scale <= 0 then scale = 1 end
    return (count or 1) / scale
end

local function SetPixelHeight(region, count)
    region.LunaPixelHeight = count or 1
    region:SetHeight(PhysicalPixels(region, region.LunaPixelHeight))
end

local function SetPixelWidth(region, count)
    region.LunaPixelWidth = count or 1
    region:SetWidth(PhysicalPixels(region, region.LunaPixelWidth))
end

local function PixelSetSize(region, width, height)
    if PixelUtil and type(PixelUtil.SetSize) == "function" then
        local ok = pcall(PixelUtil.SetSize, region, width, height)
        if ok then return end
    end
    region:SetSize(Pixel(width), Pixel(height))
end

local function FitAndClampToScreen(frame, extraRight, extraLeft)
    if not frame or not UIParent then return end
    extraRight = extraRight or 0
    extraLeft = extraLeft or 0
    local screenWidth = UIParent:GetWidth() or 0
    local screenHeight = UIParent:GetHeight() or 0
    local width = (frame:GetWidth() or 1) + extraRight + extraLeft
    local height = frame:GetHeight() or 1
    if screenWidth <= 0 or screenHeight <= 0 then return end
    local scale = math.max(.05, math.min(
        1,
        (screenWidth - 24) / width,
        (screenHeight - 24) / height))
    frame:SetScale(scale)
    if not frame:IsShown() then return end
    local left, right = frame:GetLeft(), frame:GetRight()
    local top, bottom = frame:GetTop(), frame:GetBottom()
    local outside = not left or not right or not top or not bottom
        or left - (extraLeft * scale) < 8
        or right + (extraRight * scale) > screenWidth - 8
        or bottom < 8
        or top > screenHeight - 8
    if outside then
        frame:ClearAllPoints()
        frame:SetPoint(
            "CENTER", UIParent, "CENTER",
            (extraLeft - extraRight) / 2, 0)
    elseif frame.ClampToScreen then
        pcall(frame.ClampToScreen, frame)
    end
end

local function SnapAnchors(region)
    if not region or not region.GetNumPoints
        or region.IsProtected and region:IsProtected()
    then
        return
    end
    local points = {}
    for index = 1, region:GetNumPoints() do
        local point, relative, relativePoint, x, y =
            region:GetPoint(index)
        points[index] = {
            point, relative, relativePoint,
            PixelForRegion(region, x),
            PixelForRegion(region, y),
        }
    end
    if #points > 0 then
        region:ClearAllPoints()
        for _, point in ipairs(points) do
            region:SetPoint(unpack(point))
        end
    end
    local objectType = region.GetObjectType and region:GetObjectType()
    if #points == 1 and objectType ~= "FontString"
        and region.GetWidth and region.GetHeight and region.SetSize
    then
        local width, height = region:GetWidth(), region:GetHeight()
        if width and height and width > 0 and height > 0 then
            region:SetSize(
                PixelForRegion(region, width),
                PixelForRegion(region, height))
        end
    end
    if objectType == "Texture" then
        if region.SetSnapToPixelGrid then
            pcall(region.SetSnapToPixelGrid, region, false)
        end
        if region.SetTexelSnappingBias then
            pcall(region.SetTexelSnappingBias, region, 0)
        end
    end
    if region.LunaPixelHeight then
        region:SetHeight(
            PhysicalPixels(region, region.LunaPixelHeight))
    end
    if region.LunaPixelWidth then
        region:SetWidth(
            PhysicalPixels(region, region.LunaPixelWidth))
    end
end

local function SnapTree(frame, visited)
    if not frame or visited[frame] then return end
    visited[frame] = true
    SnapAnchors(frame)
    if frame.GetRegions then
        for _, region in ipairs({ frame:GetRegions() }) do
            SnapAnchors(region)
        end
    end
    if frame.GetChildren then
        for _, child in ipairs({ frame:GetChildren() }) do
            SnapTree(child, visited)
        end
    end
end

local function BackdropFrame(frameType, name, parent, extraTemplate)
    local template = extraTemplate
    if BackdropTemplateMixin then
        template = template
            and (template .. ",BackdropTemplate")
            or "BackdropTemplate"
    end
    return CreateFrame(frameType, name, parent, template)
end

local function Font(parent, size, color, text)
    local font = parent:CreateFontString(
        nil, "OVERLAY",
        size and size <= 9 and "GameFontHighlightSmall"
            or "GameFontHighlight")
    local fontFile, _, fontFlags = font:GetFont()
    if fontFile and size then
        font:SetFont(fontFile, Pixel(size), fontFlags or "")
    end
    font:SetShadowOffset(Pixel(1), Pixel(-1))
    font:SetShadowColor(0, 0, 0, .85)
    if color == "accent" then
        font:SetTextColor(unpack(ACCENT))
    elseif color == "muted" then
        font:SetTextColor(unpack(MUTED))
    else
        font:SetTextColor(.90, .90, .90, 1)
    end
    font:SetText(text or "")
    return font
end

local function InstallPixelBorder(frame)
    frame.PixelBorders = {}
    local edges = {
        { "TOPLEFT", "TOPRIGHT", "HEIGHT" },
        { "BOTTOMLEFT", "BOTTOMRIGHT", "HEIGHT" },
        { "TOPLEFT", "BOTTOMLEFT", "WIDTH" },
        { "TOPRIGHT", "BOTTOMRIGHT", "WIDTH" },
    }
    for _, definition in ipairs(edges) do
        local edge = frame:CreateTexture(nil, "OVERLAY", nil, 7)
        edge:SetTexture(WHITE)
        edge:SetPoint(definition[1], 0, 0)
        edge:SetPoint(definition[2], 0, 0)
        if definition[3] == "HEIGHT" then
            SetPixelHeight(edge, 1)
        else
            SetPixelWidth(edge, 1)
        end
        frame.PixelBorders[#frame.PixelBorders + 1] = edge
    end
    frame.NativeSetBackdropBorderColor =
        frame.SetBackdropBorderColor
    frame.SetBackdropBorderColor = function(
        self, red, green, blue, alpha)
        self:NativeSetBackdropBorderColor(0, 0, 0, 0)
        for _, edge in ipairs(self.PixelBorders) do
            edge:SetVertexColor(red, green, blue, alpha or 1)
        end
    end
end

local function Button(parent, text, width, height, template)
    local button = BackdropFrame("Button", nil, parent, template)
    PixelSetSize(button, width, height)
    button:SetBackdrop({
        bgFile = WHITE,
        edgeFile = WHITE,
        edgeSize = Pixel(1),
    })
    InstallPixelBorder(button)
    button.baseColor = { .055, .075, .10, .96 }
    button.baseBorder = { unpack(BORDER) }
    button:SetBackdropColor(unpack(button.baseColor))
    button:SetBackdropBorderColor(unpack(button.baseBorder))
    button.Text = Font(button, 10, "text", text)
    button.Text:SetPoint("CENTER")
    button.HoverGlow = button:CreateTexture(nil, "ARTWORK")
    button.HoverGlow:SetTexture(WHITE)
    button.HoverGlow:SetPoint("TOPLEFT", 1, -1)
    button.HoverGlow:SetPoint("BOTTOMRIGHT", -1, 1)
    button.HoverGlow:SetVertexColor(.18, .70, 1, .16)
    button.HoverGlow:SetAlpha(0)
    button.HoverIn = button.HoverGlow:CreateAnimationGroup()
    local fadeIn = button.HoverIn:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(.12)
    button.HoverIn:SetScript("OnFinished", function()
        -- Alpha animations return to the texture's base alpha when they
        -- finish. Keep the hover state visible until OnLeave starts.
        button.HoverGlow:SetAlpha(1)
    end)
    button.HoverOut = button.HoverGlow:CreateAnimationGroup()
    local fadeOut = button.HoverOut:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(.18)
    button.HoverOut:SetScript("OnFinished", function()
        button.HoverGlow:SetAlpha(0)
    end)
    button:HookScript("OnEnter", function(self)
        self.HoverOut:Stop()
        self.HoverGlow:SetAlpha(0)
        self.HoverIn:Play()
        self:SetBackdropColor(.075, .15, .21, .98)
        self:SetBackdropBorderColor(.22, .66, .92, 1)
    end)
    button:HookScript("OnLeave", function(self)
        self.HoverIn:Stop()
        self.HoverGlow:SetAlpha(1)
        self.HoverOut:Play()
        self:SetBackdropColor(unpack(self.baseColor))
        self:SetBackdropBorderColor(unpack(self.baseBorder))
    end)
    return button
end

local function StyleButton(button, style)
    if style == "primary" then
        button.baseColor = { .035, .25, .39, .98 }
        button.baseBorder = { .18, .70, 1, 1 }
        button.Text:SetTextColor(.92, .98, 1, 1)
    elseif style == "positive" then
        button.baseColor = { .045, .22, .15, .98 }
        button.baseBorder = { .20, .65, .42, 1 }
    elseif style == "danger" then
        button.baseColor = { .22, .065, .075, .96 }
        button.baseBorder = { .68, .20, .24, 1 }
    else
        button.baseColor = { .055, .075, .10, .96 }
        button.baseBorder = { unpack(BORDER) }
        button.Text:SetTextColor(.90, .90, .90, 1)
    end
    button:SetBackdropColor(unpack(button.baseColor))
    button:SetBackdropBorderColor(unpack(button.baseBorder))
end

local function AddButtonIcon(button, texture, size)
    size = size or 18
    local left = size <= 16 and 8 or 10
    button.ActionIcon = button:CreateTexture(nil, "OVERLAY")
    button.ActionIcon:SetTexture(texture)
    PixelSetSize(button.ActionIcon, size, size)
    button.ActionIcon:SetPoint("LEFT", left, 0)
    button.Text:ClearAllPoints()
    button.Text:SetPoint("LEFT", left + size + 7, 0)
    button.Text:SetPoint("RIGHT", -8, 0)
    button.Text:SetJustifyH("LEFT")
end

local function AddDropdownArrow(button)
    button.DropdownArrow = button:CreateTexture(nil, "OVERLAY")
    button.DropdownArrow:SetTexture(
        "Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
    PixelSetSize(button.DropdownArrow, 18, 18)
    button.DropdownArrow:SetPoint("RIGHT", -6, 0)
    button.Text:ClearAllPoints()
    button.Text:SetPoint("LEFT", 9, 0)
    button.Text:SetPoint("RIGHT", button.DropdownArrow, "LEFT", -4, 0)
    button.Text:SetJustifyH("LEFT")
end

local function AddButtonTooltip(button, title, description)
    button:HookScript("OnEnter", function(self)
        local anchorFrame = self.tooltipAnchorFrame
        if anchorFrame then
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:ClearAllPoints()
            local screenHeight = UIParent and UIParent:GetHeight() or 0
            local frameTop = anchorFrame:GetTop() or 0
            if screenHeight > 0 and frameTop > screenHeight * .72 then
                GameTooltip:SetPoint(
                    "TOP", anchorFrame, "BOTTOM", 0, -8)
            else
                GameTooltip:SetPoint(
                    "BOTTOM", anchorFrame, "TOP", 0, 8)
            end
        else
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
        end
        GameTooltip:SetText(title, 1, 1, 1)
        GameTooltip:AddLine(
            description, MUTED[1], MUTED[2], MUTED[3], true)
        GameTooltip:Show()
    end)
    button:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function Panel(parent)
    local panel = BackdropFrame("Frame", nil, parent)
    panel:SetBackdrop({
        bgFile = WHITE,
        edgeFile = WHITE,
        edgeSize = Pixel(1),
    })
    InstallPixelBorder(panel)
    panel:SetBackdropColor(.035, .05, .07, .96)
    panel:SetBackdropBorderColor(.13, .19, .24, 1)
    panel.InnerGlow = panel:CreateTexture(nil, "BACKGROUND")
    panel.InnerGlow:SetTexture(WHITE)
    panel.InnerGlow:SetPoint("TOPLEFT", 1, -1)
    panel.InnerGlow:SetPoint("TOPRIGHT", -1, -1)
    panel.InnerGlow:SetHeight(42)
    panel.InnerGlow:SetVertexColor(.08, .18, .25, .22)
    panel.TopLine = panel:CreateTexture(nil, "ARTWORK")
    panel.TopLine:SetTexture(WHITE)
    panel.TopLine:SetPoint("TOPLEFT", 1, -1)
    panel.TopLine:SetPoint("TOPRIGHT", -1, -1)
    SetPixelHeight(panel.TopLine, 1)
    panel.TopLine:SetVertexColor(.18, .70, 1, .32)
    return panel
end

local function SectionHeader(panel, title, subtitle, rightInset)
    panel.SectionHeader = panel:CreateTexture(nil, "ARTWORK")
    panel.SectionHeader:SetTexture(WHITE)
    panel.SectionHeader:SetPoint("TOPLEFT", 1, -1)
    panel.SectionHeader:SetPoint("TOPRIGHT", -1, -1)
    panel.SectionHeader:SetHeight(31)
    panel.SectionHeader:SetVertexColor(.025, .065, .09, .98)
    panel.SectionAccent = panel:CreateTexture(nil, "OVERLAY")
    panel.SectionAccent:SetTexture(WHITE)
    panel.SectionAccent:SetPoint("TOPLEFT", 1, -1)
    panel.SectionAccent:SetPoint(
        "BOTTOMLEFT", panel.SectionHeader, "BOTTOMLEFT", 0, 0)
    SetPixelWidth(panel.SectionAccent, 3)
    panel.SectionAccent:SetVertexColor(unpack(ACCENT))
    panel.SectionDivider = panel:CreateTexture(nil, "OVERLAY")
    panel.SectionDivider:SetTexture(WHITE)
    panel.SectionDivider:SetPoint(
        "BOTTOMLEFT", panel.SectionHeader, "BOTTOMLEFT", 0, 0)
    panel.SectionDivider:SetPoint(
        "BOTTOMRIGHT", panel.SectionHeader, "BOTTOMRIGHT", 0, 0)
    SetPixelHeight(panel.SectionDivider, 1)
    panel.SectionDivider:SetVertexColor(.16, .34, .45, .85)
    panel.Title = Font(panel, 10, "accent", title)
    panel.Title:SetPoint("LEFT", panel.SectionHeader, "LEFT", 13, 0)
    if subtitle then
        panel.Subtitle = Font(panel, 9, "muted", subtitle)
        panel.Subtitle:SetPoint("LEFT", panel.Title, "RIGHT", 16, 0)
        panel.Subtitle:SetPoint(
            "RIGHT", panel.SectionHeader, "RIGHT", -(rightInset or 12), 0)
        panel.Subtitle:SetJustifyH("LEFT")
    end
    return panel.Title
end

local function EditField(parent, width, placeholder)
    local field = BackdropFrame("EditBox", nil, parent)
    PixelSetSize(field, width, 28)
    field:SetBackdrop({
        bgFile = WHITE, edgeFile = WHITE, edgeSize = Pixel(1),
    })
    InstallPixelBorder(field)
    field:SetBackdropColor(.025, .04, .055, .98)
    field:SetBackdropBorderColor(unpack(BORDER))
    field:SetAutoFocus(false)
    field:SetFontObject(GameFontHighlightSmall)
    field:SetTextInsets(9, 9, 0, 0)
    field:SetMaxLetters(240)
    field.Placeholder = Font(field, 9, "muted", placeholder or "")
    field.Placeholder:SetPoint("LEFT", 9, 0)
    field:SetScript("OnEditFocusGained", function(self)
        self:SetBackdropBorderColor(unpack(ACCENT))
    end)
    field:SetScript("OnEditFocusLost", function(self)
        self:SetBackdropBorderColor(unpack(BORDER))
    end)
    field:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    field:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    field:SetScript("OnTextChanged", function(self)
        self.Placeholder:SetShown(self:GetText() == "")
    end)
    return field
end

local function ShowSelectionMenu(
    owner, entries, selected, onSelect, requestedWidth)
    if Raid.selectionMenu then Raid.selectionMenu:Hide() end
    local menuWidth = math.max(
        owner:GetWidth(), tonumber(requestedWidth) or 0)
    local dismiss = CreateFrame("Button", nil, UIParent)
    dismiss:SetAllPoints(UIParent)
    dismiss:SetFrameStrata("FULLSCREEN_DIALOG")
    dismiss:SetFrameLevel(1)
    dismiss:EnableMouse(true)
    dismiss:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local menu = Panel(UIParent)
    PixelSetSize(menu, menuWidth, (#entries * 27) + 4)
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetFrameLevel(dismiss:GetFrameLevel() + 10)
    menu:SetClampedToScreen(true)
    menu:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -3)
    menu.Owner = owner
    menu.Dismiss = dismiss
    dismiss:SetScript("OnClick", function() menu:Hide() end)
    menu:SetScript("OnUpdate", function(self)
        if not self.Owner:IsShown() then self:Hide() end
    end)
    for index, entry in ipairs(entries) do
        local value, label = entry[1], entry[2]
        local choice = Button(
            menu, (value == selected and ">  " or "   ") .. label,
            menuWidth - 4, 25)
        choice:SetPoint("TOPLEFT", 2, -2 - ((index - 1) * 27))
        choice.Text:ClearAllPoints()
        choice.Text:SetPoint("LEFT", 8, 0)
        choice.Text:SetJustifyH("LEFT")
        if value == selected then StyleButton(choice, "primary") end
        choice:SetScript("OnClick", function()
            onSelect(value)
            menu:Hide()
        end)
    end
    menu:SetScript("OnHide", function()
        dismiss:Hide()
        if Raid.selectionMenu == menu then Raid.selectionMenu = nil end
    end)
    Raid.selectionMenu = menu
    menu:Show()
end

local function ShowMultiSelectionMenu(
    owner, entries, selected, onToggle)
    if Raid.selectionMenu then Raid.selectionMenu:Hide() end
    selected = selected or {}
    local dismiss = CreateFrame("Button", nil, UIParent)
    dismiss:SetAllPoints(UIParent)
    dismiss:SetFrameStrata("FULLSCREEN_DIALOG")
    dismiss:SetFrameLevel(1)
    dismiss:EnableMouse(true)
    dismiss:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local menu = Panel(UIParent)
    PixelSetSize(menu, owner:GetWidth(), (#entries * 27) + 4)
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetFrameLevel(dismiss:GetFrameLevel() + 10)
    menu:SetClampedToScreen(true)
    menu:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -3)
    menu.Owner, menu.Dismiss = owner, dismiss
    dismiss:SetScript("OnClick", function() menu:Hide() end)
    menu:SetScript("OnUpdate", function(self)
        if not self.Owner:IsShown() then self:Hide() end
    end)
    for index, entry in ipairs(entries) do
        local value, label = entry[1], entry[2]
        local choice = Button(
            menu, "", owner:GetWidth() - 4, 25)
        choice:SetPoint("TOPLEFT", 2, -2 - ((index - 1) * 27))
        choice.Text:ClearAllPoints()
        choice.Text:SetPoint("LEFT", 8, 0)
        choice.Text:SetJustifyH("LEFT")
        local function RefreshChoice()
            local checked = selected[value] == true
            choice.Text:SetText(
                (checked and "[x]  " or "[ ]  ") .. label)
            StyleButton(choice, checked and "primary" or nil)
        end
        choice:SetScript("OnClick", function()
            selected[value] = not selected[value] or nil
            onToggle(value, selected[value] == true)
            RefreshChoice()
        end)
        RefreshChoice()
    end
    menu:SetScript("OnHide", function()
        dismiss:Hide()
        if Raid.selectionMenu == menu then Raid.selectionMenu = nil end
    end)
    Raid.selectionMenu = menu
    menu:Show()
end

local function CurrentGuildRankEntries()
    local ranks = {}
    local count = GuildControlGetNumRanks
        and GuildControlGetNumRanks() or 0
    for rankIndex = 0, count - 1 do
        local name = GuildControlGetRankName
            and GuildControlGetRankName(rankIndex + 1)
        if name and name ~= "" then ranks[rankIndex] = name end
    end
    local memberCount = GetNumGuildMembers
        and GetNumGuildMembers() or 0
    if GetGuildRosterInfo then
        for memberIndex = 1, memberCount do
            local _, rankName, rankIndex =
                GetGuildRosterInfo(memberIndex)
            rankIndex = tonumber(rankIndex)
            if rankName and rankIndex then
                ranks[rankIndex] = rankName
            end
        end
    end
    local entries = {}
    for rankIndex, name in pairs(ranks) do
        entries[#entries + 1] = { rankIndex, name }
    end
    table.sort(entries, function(left, right)
        return left[1] < right[1]
    end)
    return entries
end

local function SetClassText(font, name, class)
    local color = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
    local red, green, blue = 1, 1, 1
    if color then red, green, blue = color.r, color.g, color.b end
    font:SetText(name or "")
    font:SetTextColor(red, green, blue)
end

local function GetClassRowColor(class, alternate)
    local color = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
    if not color then
        return alternate and .035 or .028,
            alternate and .052 or .043,
            alternate and .066 or .057, .96
    end
    local strength = alternate and .18 or .145
    return .014 + (color.r * strength),
        .019 + (color.g * strength),
        .023 + (color.b * strength), .96
end

local function CreateScrollArea(parent)
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll:EnableMouseWheel(true)
    local content = CreateFrame("Frame", nil, scroll)
    PixelSetSize(content, 1, 1)
    scroll:SetScrollChild(content)

    local track = CreateFrame("Frame", nil, scroll)
    track:SetFrameLevel(scroll:GetFrameLevel() + 10)
    track:SetPoint("TOPRIGHT", -2, -3)
    track:SetPoint("BOTTOMRIGHT", -2, 3)
    track:SetWidth(7)
    track.Background = track:CreateTexture(nil, "BACKGROUND")
    track.Background:SetAllPoints()
    track.Background:SetTexture(WHITE)
    track.Background:SetVertexColor(.025, .045, .06, .92)

    local thumb = CreateFrame("Button", nil, track)
    thumb:SetFrameLevel(track:GetFrameLevel() + 1)
    thumb:SetPoint("TOP", 0, 0)
    thumb:SetWidth(5)
    thumb:SetHeight(32)
    thumb.Texture = thumb:CreateTexture(nil, "ARTWORK")
    thumb.Texture:SetAllPoints()
    thumb.Texture:SetTexture(WHITE)
    thumb.Texture:SetVertexColor(.18, .70, 1, .88)
    thumb:RegisterForDrag("LeftButton")
    scroll.Scrollbar = track
    scroll.ScrollThumb = thumb

    local function UpdateScrollbar()
        local viewport = math.max(1, scroll:GetHeight())
        local contentHeight = math.max(1, content:GetHeight())
        local trackHeight = math.max(1, track:GetHeight())
        local maximum = math.max(0, contentHeight - viewport)
        -- Anchored regions frequently differ by a fraction of one physical
        -- pixel while the window is resolving a resize. That is not real
        -- overflow and must not make the scrollbar flash into view.
        local tolerance = PhysicalPixels(scroll, 1) + .001
        local needed = maximum > tolerance
        track:SetShown(needed)
        if not needed then
            if scroll:GetVerticalScroll() ~= 0 then
                scroll:SetVerticalScroll(0)
            end
            return
        end
        local currentScroll = math.max(
            0, math.min(maximum, scroll:GetVerticalScroll()))
        if math.abs(currentScroll - scroll:GetVerticalScroll()) > .001 then
            scroll:SetVerticalScroll(currentScroll)
        end
        local thumbHeight
        thumbHeight = math.max(
            30, trackHeight * viewport / contentHeight)
        thumb:SetAlpha(1)
        thumbHeight = math.min(trackHeight, thumbHeight)
        thumb:SetHeight(thumbHeight)
        local travel = math.max(0, trackHeight - thumbHeight)
        local offset = maximum > 0
            and travel * currentScroll / maximum or 0
        thumb:ClearAllPoints()
        thumb:SetPoint("TOP", track, "TOP", 0, -offset)
    end

    local resizeUpdateToken = 0
    local function QueueResizeUpdate()
        UpdateScrollbar()
        if not (C_Timer and C_Timer.After) then return end
        resizeUpdateToken = resizeUpdateToken + 1
        local token = resizeUpdateToken
        C_Timer.After(0, function()
            if token == resizeUpdateToken then
                UpdateScrollbar()
            end
        end)
    end

    thumb:SetScript("OnEnter", function(self)
        self.Texture:SetVertexColor(.42, .82, 1, 1)
    end)
    thumb:SetScript("OnLeave", function(self)
        if not self.dragging then
            self.Texture:SetVertexColor(.18, .70, 1, .88)
        end
    end)
    thumb:SetScript("OnDragStart", function(self)
        local _, cursorY = GetCursorPosition()
        self.dragging = true
        self.dragStartY = cursorY / scroll:GetEffectiveScale()
        self.dragStartScroll = scroll:GetVerticalScroll()
        self:SetScript("OnUpdate", function(dragger)
            local _, currentY = GetCursorPosition()
            currentY = currentY / scroll:GetEffectiveScale()
            local maximum = math.max(
                0, content:GetHeight() - scroll:GetHeight())
            local travel = math.max(
                1, track:GetHeight() - dragger:GetHeight())
            scroll:SetVerticalScroll(math.max(
                0, math.min(
                    maximum,
                    dragger.dragStartScroll
                        + (dragger.dragStartY - currentY)
                            * maximum / travel)))
            UpdateScrollbar()
        end)
    end)
    thumb:SetScript("OnDragStop", function(self)
        self.dragging = nil
        self:SetScript("OnUpdate", nil)
        self.Texture:SetVertexColor(.18, .70, 1, .88)
        UpdateScrollbar()
    end)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local maximum = math.max(
            0, content:GetHeight() - self:GetHeight())
        self:SetVerticalScroll(math.max(
            0, math.min(maximum,
                self:GetVerticalScroll() - (delta * ROW_HEIGHT * 2))))
        UpdateScrollbar()
    end)
    scroll:SetScript("OnVerticalScroll", UpdateScrollbar)
    scroll:SetScript("OnSizeChanged", QueueResizeUpdate)
    content:SetScript("OnSizeChanged", QueueResizeUpdate)
    scroll.UpdateScrollbar = UpdateScrollbar
    return scroll, content
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
            { "Tank", "TANK" },
            { "Healer", "HEALER" },
            { "Damage", "DAMAGER" },
            { "Clear Role", "AUTO" },
            { "Start Role Check", "POLL" },
            { "Remove Planned", "REMOVE" },
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
                key = "WHISPER", label = "Whisper",
                run = function(subject)
                    if ChatFrame_SendTell then
                        ChatFrame_SendTell(subject.name)
                    end
                end,
            },
            {
                key = "TARGET", label = "Target",
                live = true,
                run = function(subject)
                    if subject.unit and TargetUnit then
                        pcall(TargetUnit, subject.unit)
                    end
                end,
            },
            {
                key = "INSPECT", label = "Inspect",
                live = true,
                run = function(subject)
                    if subject.unit and InspectUnit then
                        pcall(InspectUnit, subject.unit)
                    end
                end,
            },
            {
                key = "ROLE", label = "Change Role",
                editor = true,
                run = function(subject, source)
                    Raid:ShowRoleMenu(subject, source)
                end,
            },
            {
                key = "PROMOTE", label = "Promote to Assistant",
                leader = true,
                run = function(subject)
                    Raid:PromoteRosterPlayer(subject)
                end,
            },
            {
                key = "DEMOTE", label = "Demote Assistant",
                leader = true,
                assistant = true,
                run = function(subject)
                    Raid:DemoteRosterPlayer(subject)
                end,
            },
            {
                key = "LEADER", label = "Make Raid Leader",
                leader = true,
                run = function(subject)
                    Raid:TransferRaidLeader(subject)
                end,
            },
            {
                key = "MASTER_LOOTER", label = "Set Master Looter",
                leader = true,
                run = function(subject)
                    Raid:SetMasterLooterPlayer(subject)
                end,
            },
            {
                key = "REMOVE", label = "Remove from Raid",
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
                row.Text:SetText("Remove Planned Player")
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
    panel.Title = Font(panel, 14, "accent", "ADD PLANNED PLAYER")
    panel.Title:SetPoint("TOPLEFT", 16, -16)
    panel.Close = CreateFrame(
        "Button", nil, panel, "UIPanelCloseButton")
    panel.Close:SetPoint("TOPRIGHT", -3, -3)
    panel.Close:SetScript("OnClick", function() panel:Hide() end)
    local nameLabel = Font(panel, 9, "muted", "CHARACTER NAME")
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
    local classLabel = Font(panel, 9, "muted", "CLASS")
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
    local roleLabel = Font(panel, 9, "muted", "ROLE")
    roleLabel:SetPoint("TOPLEFT", 18, -224)
    panel.RoleButtons = {}
    for index, entry in ipairs({
        { "TANK", "Tank" }, { "HEALER", "Healer" },
        { "DAMAGER", "Damage" },
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
    panel.Add = Button(panel, "ADD TO ROSTER", 150, 30)
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
    ghost:SetBackdropColor(.07, .07, .07, .94)
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
    ghost.Glow:SetVertexColor(.20, .72, 1, .13)
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

function Raid:GetPersonalAssignmentEntries()
    if not self.db.raidLocked then return {} end
    local playerName = UnitName and UnitName("player")
    if not playerName then return {} end
    local ownName = ShortPlayerName(playerName)
    local raid = self:GetRaid()
    local encounterIndex = self:GetCurrentBossIndex(raid)
    if not encounterIndex then return {} end
    local encounter = raid.encounters[encounterIndex]
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
        for targetIndex, candidate in ipairs(encounterTargets) do
            if lower:find(candidate:lower(), 1, true) then
                return self:GetMarkerChatToken(
                    self:GetMarkerAssignment(
                        targetIndex, plan, encounter))
            end
        end
        return ""
    end
    for groupIndex, group in ipairs(encounter.groups or {}) do
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
    for groupIndex, group in ipairs(encounter.groups or {}) do
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
                label = "Healing: "
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

function Raid:FindLiveUnitByName(name)
    local wanted = ShortPlayerName(name)
    if wanted == "" then return nil end
    for _, unit in ipairs({
        "player", "target", "focus", "mouseover",
        "boss1", "boss2", "boss3", "boss4", "boss5",
    }) do
        if UnitExists(unit)
            and ShortPlayerName(UnitName(unit)) == wanted
        then
            return unit
        end
    end
    local count = IsInRaid and IsInRaid()
        and (GetNumGroupMembers and GetNumGroupMembers() or 0) or 0
    for index = 1, count do
        local unit = "raid" .. index
        if ShortPlayerName(UnitName(unit)) == wanted then return unit end
    end
    for index = 1, 40 do
        local unit = "nameplate" .. index
        if UnitExists(unit)
            and ShortPlayerName(UnitName(unit)) == wanted
        then
            return unit
        end
    end
    return nil
end

function Raid:CreatePersonalAssignmentFrame()
    if self.personalAssignmentFrame then
        return self.personalAssignmentFrame
    end
    local saved = self.db.assignmentInfo
    local frame = Panel(UIParent)
    local savedWidth = math.max(
        320, math.min(720, tonumber(saved.width) or 360))
    PixelSetSize(frame, savedWidth, 76)
    frame:SetPoint(
        saved.point or "CENTER", UIParent,
        saved.point or "CENTER", saved.x or 300, saved.y or 40)
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
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint(1)
        saved.point, saved.x, saved.y = point, x, y
    end)
    frame.Title = Font(frame, 11, "accent", "YOUR ASSIGNMENTS")
    frame.Title:SetPoint("TOPLEFT", 10, -9)
    frame.Encounter = Font(frame, 9, "muted", "")
    frame.Encounter:SetPoint("TOPRIGHT", -10, -10)
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
    frame.ResizeGrip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            frame:StartSizing("RIGHT")
        end
    end)
    frame.ResizeGrip:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        local width = math.max(
            320, math.min(720, frame:GetWidth() or 360))
        width = PixelForRegion(frame, width)
        frame:SetWidth(width)
        saved.width = math.floor(width + .5)
    end)
    AddButtonTooltip(
        frame.ResizeGrip, "Resize Assignments",
        "Drag horizontally to change the width of this panel.")
    frame.Rows = {}
    frame:Hide()
    self.personalAssignmentFrame = frame
    return frame
end

function Raid:RefreshPersonalAssignments()
    -- Personal duties are live raid information. A saved plan may remain
    -- open after leaving the group, but its assignment panel must not.
    if not IsInGroup or not IsInGroup() then
        self.personalAssignmentsRefreshPending =
            InCombatLockdown and InCombatLockdown() or nil
        if self.personalAssignmentFrame then
            if InCombatLockdown and InCombatLockdown() then
                -- Secure target rows cannot be hidden after combat locks.
                -- Make the parent visually and interactively absent, then
                -- perform the real Hide on PLAYER_REGEN_ENABLED.
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
    frame:SetAlpha(1)
    frame:EnableMouse(true)
    local entries = self:GetPersonalAssignmentEntries()
    if self.db.assignmentInfo.hide or #entries == 0 then
        frame:Hide()
        return
    end
    local raid = self:GetRaid()
    local encounterIndex = self:GetCurrentBossIndex(raid)
    frame.Encounter:SetText(
        encounterIndex and raid.encounters[encounterIndex].name:upper()
            or "")
    for index, entry in ipairs(entries) do
        local row = frame.Rows[index]
        if not row then
            row = Button(
                frame, "", 340, 32, "SecureUnitButtonTemplate")
            row.Text:ClearAllPoints()
            row.Text:SetPoint("TOPLEFT", 9, -4)
            row.Text:SetPoint("TOPRIGHT", -9, -4)
            row.Text:SetJustifyH("LEFT")
            row.Meta = Font(row, 9, "muted", "")
            row.Meta:SetPoint("BOTTOMLEFT", 9, 4)
            row.Meta:SetPoint("BOTTOMRIGHT", -9, 4)
            row.Meta:SetJustifyH("LEFT")
            row:RegisterForClicks("AnyUp")
            frame.Rows[index] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 10, -31 - ((index - 1) * 34))
        row:SetPoint("TOPRIGHT", -10, -31 - ((index - 1) * 34))
        row.targetName = entry.targetName
        local targetUnit = entry.targetName
            and self:FindLiveUnitByName(entry.targetName)
        local canTargetByName = entry.targetName
            and (entry.targetRole == "BOSS"
                or entry.targetRole == "ADD")
        local targetMacro
        if canTargetByName then
            local safeTargetName = tostring(entry.targetName)
                :gsub("[\r\n]", " ")
            targetMacro = "/targetexact " .. safeTargetName
        end
        local canUpdateSecureTarget =
            not InCombatLockdown or not InCombatLockdown()
        if canUpdateSecureTarget then
            row:SetAttribute("type", nil)
            row:SetAttribute(
                "type1",
                targetUnit and "target"
                    or targetMacro and "macro"
                    or nil)
            row:SetAttribute("macrotext1", targetMacro)
            row:SetAttribute("unit", targetUnit)
            row:SetAttribute("toggleForVehicle", false)
            -- Blizzard unit-frame and click-casting code also reads the
            -- public unit field when resolving [@mouseover].
            row.unit = targetUnit
            row.secureTargetName =
                (targetUnit or targetMacro) and entry.targetName or nil
        end
        local targetReady = (targetUnit or targetMacro)
            and row.secureTargetName == entry.targetName
        local markerToken = entry.markerToken or ""
        if targetUnit and GetRaidTargetIndex then
            local liveMarker = GetRaidTargetIndex(targetUnit)
            if liveMarker then
                markerToken = self:GetMarkerChatToken(liveMarker)
            end
        end
        local marker =
            self:FormatMarkerTokensForLocalDisplay(markerToken)
        row.Text:SetText(
            (marker ~= "" and marker .. "  " or "")
                .. entry.label
                .. (entry.targetName
                    and "  |cff55bbff[Target]|r" or ""))
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
        row.Meta:SetText(table.concat(metadata, "  ·  "))
        row:SetEnabled(targetReady and true or false)
        row:SetAlpha(targetReady and 1 or .82)
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
    local button = Button(self.rosterContent, "", ROSTER_ROW_WIDTH, 34)
    button:SetPoint("TOPLEFT", 0, -((index - 1) * ROW_HEIGHT))
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
            GameTooltip:AddLine("Raid Leader", .20, .72, 1)
        end
        if self.player.simulated then
            GameTooltip:AddLine("Simulated player", .75, .60, .25)
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
    self.rosterButtons = self.rosterButtons or {}
    for index, player in ipairs(self.roster) do
        local button = self.rosterButtons[index]
        if not button then
            button = self:CreateRosterButton(index)
            self.rosterButtons[index] = button
        end
        button.player = player
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
            button.baseColor = { .055, .16, .23, .98 }
            button.baseBorder = { unpack(ACCENT) }
            button:SetBackdropColor(unpack(button.baseColor))
            button:SetBackdropBorderColor(unpack(ACCENT))
            button.SelectedBar:Show()
        else
            button.baseColor = index % 2 == 0
                and { .045, .065, .085, .96 }
                or { .035, .052, .07, .96 }
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
        1, #self.roster * ROW_HEIGHT))
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

function Raid:CreateAssignmentSlot(index)
    local slot = Button(
        self.assignmentContent, "",
        self.assignmentRowWidth or ASSIGNMENT_ROW_WIDTH, 34)
    slot.RoleIcon = slot:CreateTexture(nil, "ARTWORK")
    slot.RoleIcon:SetTexture(ROLE_TEXTURE)
    PixelSetSize(slot.RoleIcon, 19, 19)
    slot.RoleIcon:SetPoint("LEFT", 10, 0)
    slot.Label = Font(slot, 10, "muted", "")
    slot.Label:SetPoint("LEFT", 38, 0)
    slot.Label:SetWidth(292)
    slot.Label:SetJustifyH("LEFT")
    slot.Player = Font(slot, 10, "text", "Drop player here")
    slot.Player:SetPoint("LEFT", 344, 0)
    slot.Player:SetPoint("RIGHT", -12, 0)
    slot.Player:SetJustifyH("LEFT")
    -- Keep the target picker clear of the assignee column. The old 330px
    -- width overlapped the player text that begins at x=344.
    slot.HealingTarget = Button(slot, "", 296, 32)
    slot.HealingTarget:SetPoint("LEFT", 34, 0)
    -- The outer assignment card already supplies the outline.
    for _, edge in ipairs(slot.HealingTarget.PixelBorders or {}) do
        edge:Hide()
    end
    slot.HealingTarget:SetBackdropBorderColor(0, 0, 0, 0)
    slot.HealingTarget.SetBackdropBorderColor = function() end
    slot.HealingTarget.Text:ClearAllPoints()
    slot.HealingTarget.Text:SetPoint("LEFT", 6, 0)
    slot.HealingTarget.Text:SetPoint("RIGHT", -5, 0)
    slot.HealingTarget.Text:SetJustifyH("LEFT")
    slot.HealingTarget:SetFrameLevel(slot:GetFrameLevel() + 2)
    slot.HealingTarget:SetScript("OnClick", function()
        if slot.healingSlotIndex then
            Raid:CycleHealingTarget(slot.healingSlotIndex)
        end
    end)
    slot.HealingTarget:SetScript("OnEnter", function(self)
        self:SetBackdropColor(.18, .18, .18, .95)
        self:SetBackdropBorderColor(unpack(ACCENT))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Healing target")
        GameTooltip:AddLine(
            "Click to cycle between tanks and raid healing.",
            unpack(MUTED))
        GameTooltip:Show()
    end)
    slot.HealingTarget:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(self.baseColor))
        self:SetBackdropBorderColor(unpack(self.baseBorder))
        GameTooltip:Hide()
    end)
    slot.HealingTarget:Hide()
    slot.FilledBar = slot:CreateTexture(nil, "OVERLAY")
    slot.FilledBar:SetTexture(WHITE)
    slot.FilledBar:SetPoint("TOPLEFT", 1, -1)
    slot.FilledBar:SetPoint("BOTTOMLEFT", 1, 1)
    SetPixelWidth(slot.FilledBar, 4)
    slot.FilledBar:SetVertexColor(.25, .85, .45, .95)
    slot.FilledBar:Hide()
    slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    slot:RegisterForDrag("LeftButton")
    slot:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            if self.healingSlotIndex then
                Raid:SetHealingAssignment(
                    self.healingSlotIndex, nil)
            else
                Raid:SetAssignment(
                    self.groupIndex, self.slotIndex, nil)
            end
        elseif Raid.selectedPlayer then
            local selectedPlayer = Raid.selectedPlayer
            if self.healingSlotIndex then
                Raid:SetHealingAssignment(
                    self.healingSlotIndex, selectedPlayer)
            else
                Raid:SetAssignment(
                    self.groupIndex,
                    self.slotIndex, selectedPlayer)
            end
            Raid.selectedPlayer = nil
            Raid:RefreshRoster()
        else
            local assignment = self.healingSlotIndex
                and Raid:GetHealingAssignment(self.healingSlotIndex)
                or Raid:GetAssignment(self.groupIndex, self.slotIndex)
            if not assignment then
                Raid:SuggestAssignment(
                    self.groupIndex, self.slotIndex, self.healingSlotIndex)
            end
        end
    end)
    slot:SetScript("OnReceiveDrag", function(self)
        local player = Raid.dragPlayer or Raid.selectedPlayer
        if player then
            if self.healingSlotIndex then
                Raid:SetHealingAssignment(
                    self.healingSlotIndex, player)
            else
                Raid:SetAssignment(
                    self.groupIndex, self.slotIndex, player)
            end
        end
        ResetCursor()
        Raid:HideDragGhost()
        Raid.dragPlayer = nil
        Raid.selectedPlayer = nil
        Raid:RefreshRoster()
    end)
    slot:SetScript("OnEnter", function(self)
        if Raid.dragPlayer then
            self:SetBackdropBorderColor(unpack(ACCENT))
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Assign player")
        GameTooltip:AddLine(
            "Drag a roster player here, or select a player and click.",
            unpack(MUTED))
        GameTooltip:AddLine(
            "With no player selected, click to choose the best role and GearScore match.",
            .35, .72, 1, true)
        GameTooltip:AddLine("Right-click to clear this slot.", unpack(MUTED))
        GameTooltip:Show()
    end)
    slot:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(self.baseBorder))
        GameTooltip:Hide()
    end)
    return slot
end

function Raid:CreateMarkerRow(index)
    local row = Button(
        self.assignmentContent, "",
        self.assignmentRowWidth or ASSIGNMENT_ROW_WIDTH, 27)
    row.Label = Font(row, 10, "muted", "")
    row.Label:SetPoint("LEFT", 7, 0)
    row.Label:SetPoint("RIGHT", -145, 0)
    row.Label:SetJustifyH("LEFT")
    row.MarkerIcon = row:CreateTexture(nil, "ARTWORK")
    PixelSetSize(row.MarkerIcon, 18, 18)
    row.MarkerIcon:SetPoint("RIGHT", -105, 0)
    row.MarkerText = Font(row, 10, "text", "No marker")
    row.MarkerText:SetPoint("RIGHT", -9, 0)
    row.MarkerText:SetWidth(88)
    row.MarkerText:SetJustifyH("LEFT")
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            Raid:SetMarkerAssignment(self.targetIndex, nil)
        else
            Raid:CycleMarkerAssignment(self.targetIndex)
        end
    end)
    row:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(ACCENT))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Raid marker")
        GameTooltip:AddLine(
            "Left-click to choose the next unused marker. "
            .. "Right-click to clear.",
            unpack(MUTED))
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(BORDER))
        GameTooltip:Hide()
    end)
    return row
end

local function SetMarkerTexture(texture, markerIndex)
    local marker = markerIndex and Raid.markers[markerIndex]
    if not marker then
        texture:Hide()
        return
    end
    texture:SetTexture(
        "Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    if SetRaidTargetIconTexture then
        SetRaidTargetIconTexture(texture, marker.icon)
    else
        local column = (marker.icon - 1) % 4
        local row = math.floor((marker.icon - 1) / 4)
        texture:SetTexCoord(
            column / 4, (column + 1) / 4,
            row / 2, (row + 1) / 2)
    end
    texture:Show()
end

function Raid:SetBossTab(tab)
    self.activeBossTab = tab
    if self.assignmentScroll then
        self.assignmentScroll:SetVerticalScroll(0)
    end
    self:RedrawWorkspace()
end

function Raid:SetWorkspaceMode(mode)
    if mode == "SETTINGS" then
        self:ShowSettingsView()
        return
    end
    if self.settingsView and self.settingsView:IsShown() then
        self.settingsView:Hide()
        self:SetRaidWorkspaceVisible(true)
    end
    if self.raidPickerActive or not self.db.raidLocked then
        if mode == "GROUPS" or mode == "STATUS" or mode == "GEAR"
            or mode == "ABOUT"
        then
            if self.newRaidWizard then
                self.newRaidWizard:Hide()
            end
            self:SetRaidPickerMode(false)
            self.workspaceMode = mode
            self.selectedPlayer = nil
            self.dragPlayer = nil
            self:HideDragGhost()
            self:RedrawWorkspace()
        else
            self.workspaceMode = "ASSIGNMENTS"
            if not self:CanStartRaid() then
                if self.newRaidWizard then
                    self.newRaidWizard:Hide()
                end
                self:SetRaidPickerMode(false)
                self:SetRaidWorkspaceVisible(true)
                self:RefreshWorkspaceNavigation()
                self:UpdateWindowLayout()
                self:Print(
                    "Only the raid leader can create a new raid plan.")
                return
            end
            self:SetRaidWorkspaceVisible(true)
            self:SetRaidPickerMode(true)
            if self.newRaidWizard then
                self.newRaidWizard:Show()
                self:RefreshNewRaidWizard()
            end
            self:RefreshWorkspaceNavigation()
            self:UpdateWindowLayout()
        end
        return
    end
    if self.newRaidWizard and self.newRaidWizard:IsShown() then
        self.newRaidWizard:Hide()
    end
    self.workspaceMode = mode == "GROUPS" and "GROUPS"
        or mode == "STATUS" and "STATUS"
        or mode == "GEAR" and "GEAR"
        or mode == "ABOUT" and "ABOUT"
        or "ASSIGNMENTS"
    self.selectedPlayer = nil
    self.dragPlayer = nil
    self:HideDragGhost()
    if self.bossSettingsPanel then self.bossSettingsPanel:Hide() end
    self:RedrawWorkspace()
end

function Raid:SetRaidPickerMode(enabled)
    enabled = enabled and true or false
    self.raidPickerActive = enabled

    for _, button in ipairs(self.bossButtons or {}) do
        button:Hide()
    end

    if self.assignmentRaidIcon then
        self.assignmentRaidIcon:SetShown(not enabled)
    end
    if self.assignmentRaidTitle then
        self.assignmentRaidTitle:SetShown(not enabled)
    end
    if self.assignmentTitle then
        self.assignmentTitle:SetShown(not enabled)
    end
    if self.assignmentScroll then
        self.assignmentScroll:SetShown(not enabled)
    end
    if self.bossSettingsButton then
        self.bossSettingsButton:SetShown(not enabled)
    end
    if self.bossSettingsPanel then
        self.bossSettingsPanel:Hide()
    end
    for _, tab in pairs(self.bossTabs or {}) do
        tab:SetShown(not enabled)
    end
    if self.assignmentPanel and self.assignmentPanel.ProgressTrack then
        self.assignmentPanel.ProgressTrack:SetShown(not enabled)
        self.assignmentPanel.ProgressFill:SetShown(not enabled)
    end
    if self.bossRail then
        self.bossRail:Show()
    end
    if enabled then
        for _, button in ipairs(self.footerActionButtons or {}) do
            button:Hide()
        end
    end
end

function Raid:RefreshFooterLayout()
    if not self.frame or not self.rosterPanel
        or not self.assignmentPanel
    then
        return
    end
    local previous
    for _, button in ipairs(self.footerLeftButtons or {}) do
        button:ClearAllPoints()
        if button:IsShown() then
            if previous then
                button:SetPoint("LEFT", previous, "RIGHT", 5, 0)
            else
                button:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 12, 14)
            end
            previous = button
        end
    end
    previous = nil
    for _, button in ipairs(self.footerRightButtons or {}) do
        button:ClearAllPoints()
        if button:IsShown() then
            if previous then
                button:SetPoint("RIGHT", previous, "LEFT", -5, 0)
            else
                button:SetPoint(
                    "BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -24, 14)
            end
            previous = button
        end
    end
    local hasFooter
    for _, button in ipairs(self.footerActionButtons or {}) do
        if button:IsShown() then
            hasFooter = true
            break
        end
    end
    local bottomInset = hasFooter and 58 or 1
    self.rosterPanel:ClearAllPoints()
    self.rosterPanel:SetPoint("TOPLEFT", 1, -46)
    self.rosterPanel:SetPoint("BOTTOMLEFT", 1, bottomInset)
    self.rosterPanel:SetWidth(ROSTER_WIDTH)

    local fullWidth = self.raidPickerActive
        or self.workspaceMode == "GROUPS"
        or self.workspaceMode == "STATUS"
        or self.workspaceMode == "GEAR"
        or self.workspaceMode == "ABOUT"
    self.assignmentPanel:ClearAllPoints()
    if fullWidth then
        self.assignmentPanel:SetPoint("TOPLEFT", 1, -46)
    else
        self.assignmentPanel:SetPoint(
            "TOPLEFT", self.rosterPanel, "TOPRIGHT", 0, 0)
    end
    self.assignmentPanel:SetPoint(
        "BOTTOMRIGHT", -1, bottomInset)
    self.assignmentPanel:SetBackdropColor(0, 0, 0, 0)
    self.assignmentPanel:SetBackdropBorderColor(0, 0, 0, 0)
    if self.assignmentPanel.InnerGlow then
        self.assignmentPanel.InnerGlow:Hide()
    end
    if self.assignmentPanel.TopLine then
        self.assignmentPanel.TopLine:Hide()
    end
    if self.assignmentPanel.Watermark then
        self.assignmentPanel.Watermark:Hide()
    end
    self.rosterPanel:SetBackdropColor(.018, .033, .047, .98)
    self.rosterPanel:SetBackdropBorderColor(0, 0, 0, 0)
    if self.rosterPanel.InnerGlow then
        self.rosterPanel.InnerGlow:Hide()
    end
    if self.rosterPanel.TopLine then
        self.rosterPanel.TopLine:Hide()
    end
    if self.rosterPanel.Divider then
        self.rosterPanel.Divider:SetShown(not fullWidth)
    end

    if self.frame.DarkInset then
        self.frame.DarkInset:ClearAllPoints()
        self.frame.DarkInset:SetPoint("TOPLEFT", 1, -46)
        self.frame.DarkInset:SetPoint(
            "BOTTOMRIGHT", -1, hasFooter and 58 or 1)
    end
    if self.frame.StatusBg then
        self.frame.StatusBg:SetShown(hasFooter or false)
    end
end

function Raid:RefreshWorkspaceNavigation()
    local groups = self.workspaceMode == "GROUPS"
    local status = self.workspaceMode == "STATUS"
    local gear = self.workspaceMode == "GEAR"
    local about = self.workspaceMode == "ABOUT"
    local settings = self.workspaceMode == "SETTINGS"
    local picker = self.raidPickerActive
    local workspaceVisible = self.assignmentPanel
        and self.assignmentPanel:IsShown()
    local canEdit = self:IsLocalRaidEditor()
    local showRaidIdentity =
        not picker and not groups and not status and not gear
            and not about and not settings
    if self.assignmentRaidIcon then
        self.assignmentRaidIcon:SetShown(showRaidIdentity)
    end
    if self.assignmentRaidTitle then
        self.assignmentRaidTitle:SetShown(showRaidIdentity)
    end
    if self.assignmentTitle then
        self.assignmentTitle:SetShown(showRaidIdentity)
    end
    if self.assignmentHint then
        self.assignmentHint:SetShown(showRaidIdentity)
    end
    if self.setCurrentBossButton then
        self.setCurrentBossButton:SetShown(
            showRaidIdentity and workspaceVisible and canEdit
                and self.db.activeEncounter > 1)
    end
    if not picker and self.frame and self.frame.Title then
        if groups then
            self.frame.Title:SetText("RAID GROUPS")
            self.frame.Subtitle:SetText(
                "ARRANGE PLAYERS ACROSS THE LIVE RAID")
        elseif status then
            self.frame.Title:SetText("RAID STATUS")
            self.frame.Subtitle:SetText(
                "READINESS, BUFFS, AND CONSUMABLES")
        elseif gear then
            self.frame.Title:SetText("GEAR INSPECT")
            self.frame.Subtitle:SetText(
                "LIVE RAID EQUIPMENT AND ITEM LEVELS")
        elseif about then
            self.frame.Title:SetText("ABOUT LUNARAIDS")
            self.frame.Subtitle:SetText(
                "PROJECT, CONTRIBUTORS, AND SUPPORT")
        elseif settings then
            self.frame.Title:SetText("SETTINGS")
            self.frame.Subtitle:SetText(
                "INTERFACE, COMMUNICATION, AND RAID ADMINISTRATION")
        else
            local raid = self:GetRaid()
            self.frame.Title:SetText("LUNA RAIDS")
            self.frame.Subtitle:SetText(
                raid.name:upper() .. "  ·  ACTIVE PLAN")
        end
    end
    for key, button in pairs(self.workspaceButtons or {}) do
        local selected = key == (
            status and "STATUS"
            or gear and "GEAR"
            or groups and "GROUPS"
            or about and "ABOUT"
            or settings and "SETTINGS"
            or "ASSIGNMENTS")
        button.baseColor = selected
            and { .035, .18, .27, .98 }
            or { .035, .06, .08, .98 }
        button.baseBorder = selected
            and { unpack(ACCENT) }
            or { unpack(BORDER) }
        button:SetBackdropColor(unpack(button.baseColor))
        button:SetBackdropBorderColor(unpack(button.baseBorder))
        button.ActiveBar:SetShown(selected)
        button:SetEnabled(true)
        button:SetAlpha(1)
    end
    if self.bossRail then
        self.bossRail:SetShown(
            not picker and (not groups and not status and not gear
                and not about and not settings
                and self.assignmentPanel
                and self.assignmentPanel:IsShown()))
    end
    for _, tab in pairs(self.bossTabs or {}) do
        tab:SetShown(
            not picker and not groups and not status and not gear
                and not about and not settings)
    end
    for _, button in ipairs(self.assignmentActionButtons or {}) do
        button:SetShown(
            not picker
                and not groups and not status
                and not gear and not about and not settings
                and workspaceVisible
                and canEdit)
    end
    for index, button in ipairs(
        self.generalFooterActionButtons or {}) do
        button:SetShown(
            not picker
                and not groups
                and not status
                and not gear
                and not about
                and not settings
                and workspaceVisible
                and canEdit
                and (index ~= 1 or self:CanStartRaid()))
    end
    if self.raidGroupQuickActions then
        local hasGroupRoster = (IsInRaid and IsInRaid())
            or (self.simulation and self.simulation.enabled)
        self.raidGroupQuickActions:SetShown(
            not picker and groups and workspaceVisible
                and hasGroupRoster)
    end
    if self.raidStatusView and self.raidStatusView.ActionBar then
        self.raidStatusView.ActionBar:SetShown(
            not picker and status and workspaceVisible)
    end
    if self.assignmentScroll then
        self.assignmentScroll:ClearAllPoints()
        self.assignmentScroll:SetPoint(
            "TOPLEFT", 6,
            (groups or status or gear or about) and -8 or -84)
        self.assignmentScroll:SetPoint("BOTTOMRIGHT", -6, 8)
    end
    if self.raidStatusView then
        self.raidStatusView:ClearAllPoints()
        self.raidStatusView:SetPoint("TOPLEFT", 0, 0)
        self.raidStatusView:SetPoint("BOTTOMRIGHT", 0, 0)
    end
    if not picker and not groups and not status and not gear and not about
        and self.LayoutAssignmentToolbar
    then
        self:LayoutAssignmentToolbar()
    end
    local showRoster =
        not picker and not groups and not status and not gear
            and not about and not settings and workspaceVisible
    if self.rosterPanel then
        self.rosterPanel:SetShown(showRoster)
    end
    if self.rosterScroll then
        self.rosterScroll:SetShown(showRoster)
    end
    self:RefreshFooterLayout()
end

function Raid:CreateBossSettingsPanel()
    if self.bossSettingsPanel then return self.bossSettingsPanel end
    local panel = Panel(self.assignmentPanel)
    PixelSetSize(panel, 330, 180)
    panel:SetFrameStrata("HIGH")
    panel:SetFrameLevel(self.assignmentPanel:GetFrameLevel() + 20)
    panel:SetPoint(
        "TOPRIGHT", self.bossSettingsButton, "BOTTOMRIGHT", 0, -5)
    panel.Title = Font(panel, 11, "accent", "BOSS ASSIGNMENT SETUP")
    panel.Title:SetPoint("TOPLEFT", 10, -10)
    panel.Rows = {}
    panel.PresetPrevious = Button(panel, "<", 27, 23)
    panel.PresetPrevious:SetPoint("TOPLEFT", 8, -31)
    panel.PresetPrevious:SetScript("OnClick", function()
        Raid:CycleBossPreset(-1)
    end)
    panel.PresetName = Button(panel, "NO SAVED PRESETS", 252, 23)
    panel.PresetName:SetPoint(
        "LEFT", panel.PresetPrevious, "RIGHT", 4, 0)
    panel.PresetName:SetScript("OnClick", function()
        Raid:CycleBossPreset(1)
    end)
    panel.PresetNext = Button(panel, ">", 27, 23)
    panel.PresetNext:SetPoint("LEFT", panel.PresetName, "RIGHT", 4, 0)
    panel.PresetNext:SetScript("OnClick", function()
        Raid:CycleBossPreset(1)
    end)
    panel.Save = Button(panel, "SAVE NEW", 70, 24)
    StyleButton(panel.Save, "primary")
    panel.Save:SetPoint("BOTTOMLEFT", 8, 8)
    panel.Save:SetScript("OnClick", function()
        Raid:PromptSaveBossPreset()
    end)
    panel.Load = Button(panel, "APPLY", 70, 24)
    StyleButton(panel.Load, "positive")
    panel.Load:SetPoint("LEFT", panel.Save, "RIGHT", 5, 0)
    panel.Load:SetScript("OnClick", function()
        Raid:LoadBossPreset()
        Raid:RefreshBossSettingsPanel()
    end)
    panel.Delete = Button(panel, "DELETE", 70, 24)
    StyleButton(panel.Delete, "danger")
    panel.Delete:SetPoint("LEFT", panel.Load, "RIGHT", 5, 0)
    panel.Delete:SetScript("OnClick", function()
        Raid:PromptDeleteBossPreset()
    end)
    panel.Reset = Button(panel, "DEFAULT", 82, 24)
    panel.Reset:SetPoint("LEFT", panel.Delete, "RIGHT", 5, 0)
    panel.Reset:SetScript("OnClick", function()
        Raid:ResetBossOverride()
        Raid:RefreshBossSettingsPanel()
    end)
    panel:Hide()
    self.bossSettingsPanel = panel
    return panel
end

function Raid:PromptSaveBossPreset()
    if StaticPopup_Show then
        local popup = StaticPopup_Show("LUNARAIDS_SAVE_BOSS_PRESET")
        local editBox = self:GetPopupEditBox(popup)
        if editBox then
            editBox:SetText(self:GetEncounter().name .. " Setup")
            editBox:HighlightText()
        end
    else
        self:SaveBossPreset(self:GetEncounter().name .. " Setup")
    end
end

function Raid:PromptDeleteBossPreset()
    local preset = self:GetSelectedBossPreset()
    if not preset then return end
    self.pendingDeleteBossPresetID = preset.id
    if StaticPopup_Show then
        StaticPopup_Show(
            "LUNARAIDS_DELETE_BOSS_PRESET", preset.name, nil, preset.id)
    else
        self:DeleteBossPreset(preset.id)
    end
end

function Raid:RefreshBossSettingsPanel()
    local panel = self:CreateBossSettingsPanel()
    if not panel:IsShown() then return end
    local raid, encounter = self:GetRaid(), self:GetEncounter()
    local presets = self:GetBossPresets()
    local selected = self:GetSelectedBossPreset()
    local hasPreset = selected ~= nil
    panel.Title:SetText("BOSS ASSIGNMENT SETUP  -  "
        .. #presets .. (#presets == 1 and " PRESET" or " PRESETS"))
    panel.PresetName.Text:SetText(
        selected and selected.name:upper() or "NO SAVED PRESETS")
    panel.PresetPrevious:SetEnabled(#presets > 1)
    panel.PresetPrevious:SetAlpha(#presets > 1 and 1 or .42)
    panel.PresetNext:SetEnabled(#presets > 1)
    panel.PresetNext:SetAlpha(#presets > 1 and 1 or .42)
    panel.Load:SetEnabled(hasPreset)
    panel.Load:SetAlpha(hasPreset and 1 or .42)
    panel.Delete:SetEnabled(hasPreset)
    panel.Delete:SetAlpha(hasPreset and 1 or .42)
    local entries = {
        {
            label = "Healer Assignments",
            value = self:GetHealingSlotCount(),
            adjust = function(delta)
                Raid:SetBossHealerCount(
                    Raid:GetHealingSlotCount() + delta)
            end,
        },
    }
    for groupIndex, group in ipairs(encounter.groups or {}) do
        if group.name ~= "Healing" then
            local index = groupIndex
            entries[#entries + 1] = {
                label = group.name,
                value = #self:GetEncounterGroupSlots(index, encounter),
                adjust = function(delta)
                    Raid:SetBossGroupCount(
                        index,
                        #Raid:GetEncounterGroupSlots(index, encounter)
                            + delta)
                end,
            }
        end
    end
    for index, entry in ipairs(entries) do
        local row = panel.Rows[index]
        if not row then
            row = CreateFrame("Frame", nil, panel)
            PixelSetSize(row, 310, 27)
            row.Label = Font(row, 10, "text", "")
            row.Label:SetPoint("LEFT", 3, 0)
            row.Label:SetWidth(205)
            row.Label:SetJustifyH("LEFT")
            row.Minus = Button(row, "-", 25, 23)
            row.Minus:SetPoint("RIGHT", -65, 0)
            row.Value = Font(row, 10, "accent", "0")
            row.Value:SetPoint("RIGHT", -34, 0)
            row.Value:SetWidth(28)
            row.Value:SetJustifyH("CENTER")
            row.Plus = Button(row, "+", 25, 23)
            row.Plus:SetPoint("RIGHT", -2, 0)
            panel.Rows[index] = row
        end
        row:SetPoint("TOPLEFT", 8, -65 - ((index - 1) * 29))
        row.Label:SetText(entry.label)
        row.Value:SetText(entry.value)
        row.adjust = entry.adjust
        row.Minus:SetScript("OnClick", function()
            row.adjust(-1)
            Raid:RefreshBossSettingsPanel()
        end)
        row.Plus:SetScript("OnClick", function()
            row.adjust(1)
            Raid:RefreshBossSettingsPanel()
        end)
        row:Show()
    end
    for index = #entries + 1, #panel.Rows do
        panel.Rows[index]:Hide()
    end
    panel:SetHeight(math.max(150, 105 + (#entries * 29)))
end

function Raid:ToggleBossSettings()
    local panel = self:CreateBossSettingsPanel()
    panel:SetShown(not panel:IsShown())
    self:RefreshBossSettingsPanel()
end

function Raid:RefreshBossTabs()
    if not self.bossTabs then return end
    local active = self.activeBossTab or "ASSIGNMENTS"
    for key, button in pairs(self.bossTabs) do
        local selected = key == active
        button:SetBackdropColor(
            selected and .035 or .035,
            selected and .18 or .06,
            selected and .27 or .08, .98)
        button.baseColor = selected
            and { .035, .18, .27, .98 }
            or { .035, .06, .08, .98 }
        button.baseBorder = selected
            and { unpack(ACCENT) }
            or { unpack(BORDER) }
        button:SetBackdropBorderColor(unpack(button.baseBorder))
        button.Text:SetTextColor(
            selected and ACCENT[1] or .68,
            selected and ACCENT[2] or .68,
            selected and ACCENT[3] or .68, 1)
        button.ActiveLine:SetShown(selected)
    end
end

function Raid:GetMechanicsGuide()
    local encounter = self:GetEncounter()
    return encounter and encounter.mechanics
end

function Raid:RefreshMechanics()
    local encounter = self:GetEncounter()
    self.mechanicLines = self.mechanicLines or {}
    local guide = self:GetMechanicsGuide()
    local lines = {}
    if encounter.name == "Raid Overview" then
        lines = {
            "Select a boss from the rail to open its quick guide.",
            "Use Markers to prepare boss and add marks.",
            "Use Assignments to place tanks, healers, and utility players.",
        }
    elseif guide then
        for _, line in ipairs(guide) do
            lines[#lines + 1] = line
        end
    else
        lines[#lines + 1] =
            "Confirm positioning, pull order, and phase transitions before the pull."
        for groupIndex, group in ipairs(encounter.groups or {}) do
            if group.name ~= "Healing" then
                local labels = {}
                for _, slot in ipairs(
                    self:GetEncounterGroupSlots(groupIndex, encounter)) do
                    labels[#labels + 1] = self:GetSlotLabel(slot)
                end
                lines[#lines + 1] = group.name .. ": "
                    .. table.concat(labels, ", ") .. "."
            end
        end
        lines[#lines + 1] =
            "This encounter has assignment guidance; a detailed mechanic guide is still being authored."
    end
    local y = 4
    for index, text in ipairs(lines) do
        local line = self.mechanicLines[index]
        if not line then
            line = BackdropFrame("Frame", nil, self.assignmentContent)
            line:SetWidth(
                self.assignmentRowWidth or ASSIGNMENT_ROW_WIDTH)
            line:SetBackdrop({ bgFile = WHITE })
            line:SetBackdropColor(.10, .10, .10, .82)
            line.Number = Font(line, 14, "accent", "")
            line.Number:SetPoint("TOPLEFT", 10, -10)
            line.Text = Font(line, 10, "text", "")
            line.Text:SetPoint("TOPLEFT", 42, -10)
            line.Text:SetPoint("RIGHT", -12, 0)
            line.Text:SetJustifyH("LEFT")
            line.Text:SetJustifyV("TOP")
            self.mechanicLines[index] = line
        end
        line:ClearAllPoints()
        line:SetPoint("TOPLEFT", 0, -y)
        line.Number:SetText(index)
        line.Text:SetText(text)
        line.Text:SetWidth(
            (self.assignmentRowWidth or ASSIGNMENT_ROW_WIDTH) - 56)
        local height = math.max(48, line.Text:GetStringHeight() + 22)
        line:SetHeight(height)
        line:Show()
        y = y + height + 7
    end
    for index = #lines + 1, #self.mechanicLines do
        self.mechanicLines[index]:Hide()
    end
    self.assignmentContent:SetHeight(math.max(1, y))
    self.assignmentTitle:SetText(encounter.name:upper() .. "  QUICK GUIDE")
end

function Raid:CreateRaidGroupFrame(groupIndex)
    self.raidGroupFrames = self.raidGroupFrames or {}
    local group = CreateFrame("Frame", nil, self.assignmentContent)
    group.GroupIndex = groupIndex
    group.HeaderBg = group:CreateTexture(nil, "BACKGROUND")
    group.HeaderBg:SetTexture(WHITE)
    group.HeaderBg:SetPoint("TOPLEFT", 0, 0)
    group.HeaderBg:SetPoint("TOPRIGHT", 0, 0)
    group.HeaderBg:SetHeight(28)
    group.HeaderBg:SetVertexColor(.025, .075, .105, .92)
    group.Accent = group:CreateTexture(nil, "ARTWORK")
    group.Accent:SetTexture(WHITE)
    group.Accent:SetPoint("TOPLEFT", 0, 0)
    group.Accent:SetPoint("BOTTOMLEFT", group.HeaderBg, "BOTTOMLEFT", 0, 0)
    SetPixelWidth(group.Accent, 2)
    group.Accent:SetVertexColor(unpack(ACCENT))
    group.HeaderLine = group:CreateTexture(nil, "ARTWORK")
    group.HeaderLine:SetTexture(WHITE)
    group.HeaderLine:SetPoint(
        "BOTTOMLEFT", group.HeaderBg, "BOTTOMLEFT", 0, 0)
    group.HeaderLine:SetPoint(
        "BOTTOMRIGHT", group.HeaderBg, "BOTTOMRIGHT", 0, 0)
    SetPixelHeight(group.HeaderLine, 1)
    group.HeaderLine:SetVertexColor(.14, .29, .38, .8)
    group.Divider = group:CreateTexture(nil, "BACKGROUND")
    group.Divider:SetTexture(WHITE)
    group.Divider:SetPoint("TOPRIGHT", 0, 0)
    group.Divider:SetPoint("BOTTOMRIGHT", 0, 0)
    SetPixelWidth(group.Divider, 1)
    group.Divider:SetVertexColor(.09, .14, .18, .65)
    group.Title = Font(group, 10, "accent", "GROUP " .. groupIndex)
    group.Title:SetPoint("LEFT", group.HeaderBg, "LEFT", 10, 0)
    group.Count = Font(group, 9, "muted", "0/5")
    group.Count:SetPoint("RIGHT", group.HeaderBg, "RIGHT", -9, 0)
    group.Slots = {}
    for slotIndex = 1, 5 do
        local slot = Button(group, "", 140, 29)
        slot:SetPoint("TOPLEFT", 0, -32 - ((slotIndex - 1) * 31))
        slot:SetPoint("TOPRIGHT", -7, -32 - ((slotIndex - 1) * 31))
        slot.Text:ClearAllPoints()
        slot.Text:SetPoint("LEFT", 17, 0)
        slot.Text:SetPoint("RIGHT", -76, 0)
        slot.Text:SetJustifyH("LEFT")
        slot.Status = Font(slot, 8, "muted", "")
        slot.Status:SetPoint("RIGHT", -28, 0)
        slot.Status:SetWidth(48)
        slot.Status:SetJustifyH("RIGHT")
        slot.ClassDot = slot:CreateTexture(nil, "OVERLAY")
        slot.ClassDot:SetTexture(WHITE)
        PixelSetSize(slot.ClassDot, 3, 17)
        slot.ClassDot:SetPoint("LEFT", 7, 0)
        slot.Role = slot:CreateTexture(nil, "ARTWORK")
        slot.Role:SetTexture(ROLE_TEXTURE)
        PixelSetSize(slot.Role, 16, 16)
        slot.Role:SetPoint("RIGHT", -7, 0)
        slot.Leader = slot:CreateTexture(nil, "ARTWORK")
        slot.Leader:SetTexture(
            "Interface\\GroupFrame\\UI-Group-LeaderIcon")
        PixelSetSize(slot.Leader, 14, 14)
        slot.Assistant = slot:CreateTexture(nil, "ARTWORK")
        slot.Assistant:SetTexture(
            "Interface\\GroupFrame\\UI-Group-AssistantIcon")
        PixelSetSize(slot.Assistant, 14, 14)
        slot.MainTank = slot:CreateTexture(nil, "ARTWORK")
        slot.MainTank:SetTexture(
            "Interface\\GroupFrame\\UI-Group-MainTankIcon")
        PixelSetSize(slot.MainTank, 14, 14)
        slot.MainAssist = slot:CreateTexture(nil, "ARTWORK")
        slot.MainAssist:SetTexture(
            "Interface\\GroupFrame\\UI-Group-MainAssistIcon")
        PixelSetSize(slot.MainAssist, 14, 14)
        slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        slot:RegisterForDrag("LeftButton")
        slot:SetScript("OnClick", function(self, mouseButton)
            if mouseButton == "RightButton" and self.player then
                Raid:ShowRaidPlayerMenu(self.player, self)
                return
            end
            if not Raid:CanEditRaidGroups() then return end
            if Raid.selectedPlayer
                and Raid.selectedPlayer ~= self.player
            then
                Raid:MoveRosterPlayer(
                    Raid.selectedPlayer, groupIndex, self.player)
            elseif self.player then
                Raid.selectedPlayer = self.player
                Raid:RefreshRoster()
                Raid:RefreshAssignments()
            end
        end)
        slot:SetScript("OnDragStart", function(self)
            if not Raid:CanEditRaidGroups() or not self.player then return end
            Raid.dragPlayer = self.player
            Raid.selectedPlayer = self.player
            Raid:ShowDragGhost(self.player)
        end)
        slot:SetScript("OnReceiveDrag", function(self)
            local player = Raid.dragPlayer or Raid.selectedPlayer
            if player and player ~= self.player then
                Raid:MoveRosterPlayer(player, groupIndex, self.player)
            end
            Raid:HideDragGhost()
            Raid.dragPlayer = nil
            ResetCursor()
        end)
        slot:SetScript("OnDragStop", function()
            Raid:HideDragGhost()
            Raid.dragPlayer = nil
            ResetCursor()
        end)
        slot:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(unpack(ACCENT))
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if self.player then
                GameTooltip:SetText(self.player.name)
                if self.player.leader then
                    GameTooltip:AddLine("Raid Leader", .95, .78, .25)
                elseif self.player.assistant then
                    GameTooltip:AddLine("Raid Assistant", .55, .78, 1)
                end
                if self.player.raidAssignment == "MAINTANK" then
                    GameTooltip:AddLine("Main Tank", .35, .75, 1)
                elseif self.player.raidAssignment == "MAINASSIST" then
                    GameTooltip:AddLine("Main Assist", .35, .75, 1)
                end
                GameTooltip:AddLine(
                    "Drag onto another player to swap groups.",
                    MUTED[1], MUTED[2], MUTED[3], true)
                GameTooltip:AddLine(
                    "Right-click for player actions.",
                    MUTED[1], MUTED[2], MUTED[3], true)
            else
                GameTooltip:SetText("Empty group position")
                GameTooltip:AddLine(
                    "Drop a player here to move them into this group.",
                    MUTED[1], MUTED[2], MUTED[3], true)
            end
            GameTooltip:Show()
        end)
        slot:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(unpack(self.baseBorder))
            GameTooltip:Hide()
        end)
        group.Slots[slotIndex] = slot
    end
    PixelSetSize(group, 160, 194)
    self.raidGroupFrames[groupIndex] = group
    return group
end

function Raid:CreateRaidGroupQuickActions()
    if self.raidGroupQuickActions then
        return self.raidGroupQuickActions
    end
    local panel = CreateFrame("Frame", nil, self.frame)
    panel:SetPoint("BOTTOMLEFT", 12, 8)
    panel:SetPoint("BOTTOMRIGHT", -24, 8)
    panel:SetHeight(40)
    panel:SetFrameLevel(self.frame:GetFrameLevel() + 8)
    local actions = {
        {
            label = "READY CHECK",
            icon = "Interface\\RaidFrame\\ReadyCheck-Ready",
            title = "Ready Check",
            detail = "Start Blizzard's raid ready check.",
            action = function() Raid:StartReadyCheck() end,
            rightAction = function()
                Raid:ShowPinnedReadyCheckWindow()
            end,
        },
        {
            label = "ROLE CHECK",
            icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
            title = "Role Check",
            detail = "Ask the raid to confirm combat roles.",
            action = function() Raid:StartRoleCheck() end,
        },
        {
            label = "PULL 10",
            icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
            title = "Pull Timer",
            detail = "Start a 10-second pull countdown.",
            action = function() Raid:StartPullCountdown(10) end,
        },
        {
            label = "BREAK 5",
            icon = "Interface\\Icons\\INV_Drink_05",
            title = "Break Timer",
            detail = "Announce and start a five-minute break.",
            action = function() Raid:StartBreakTimer(5) end,
            rightAction = function(button)
                ShowSelectionMenu(
                    button,
                    {
                        { 5, "5 minutes" },
                        { 10, "10 minutes" },
                        { 15, "15 minutes" },
                    },
                    5,
                    function(minutes)
                        Raid:StartBreakTimer(minutes)
                    end,
                    156)
            end,
            rightDetail =
                "\nRight-click to choose 5, 10, or 15 minutes.",
        },
    }
    panel.Actions = {}
    local previous
    for index, entry in ipairs(actions) do
        local action, rightAction = entry.action, entry.rightAction
        local button = Button(panel, entry.label, 126, 28)
        if previous then
            button:SetPoint("LEFT", previous, "RIGHT", 5, 0)
        else
            button:SetPoint("LEFT", 0, 0)
        end
        AddButtonIcon(button, entry.icon, 16)
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        button:SetScript("OnClick", function(_, mouseButton)
            if not Raid:CanEditRaidGroups() then return end
            if mouseButton == "RightButton" and rightAction then
                rightAction(button)
            else
                action()
            end
        end)
        AddButtonTooltip(
            button, entry.title,
            entry.detail .. (rightAction
                and (entry.rightDetail
                    or "\nRight-click to pin the latest results.")
                or ""))
        if index == 1 then StyleButton(button, "primary") end
        panel.Actions[index] = button
        previous = button
    end
    for _, button in ipairs(panel.Actions) do
        self.footerActionButtons[#self.footerActionButtons + 1] = button
    end
    panel:Hide()
    self.raidGroupQuickActions = panel
    return panel
end

function Raid:RefreshRaidGroups()
    self.raidGroupFrames = self.raidGroupFrames or {}
    local quickActions = self:CreateRaidGroupQuickActions()
    local hasRaid = IsInRaid and IsInRaid()
    local isSimulated = self.simulation and self.simulation.enabled
    if not hasRaid and not isSimulated then
        quickActions:Hide()
        for _, group in ipairs(self.raidGroupFrames) do
            group:Hide()
        end
        if not self.raidGroupsEmptyState then
            self.raidGroupsEmptyState = Font(
                self.assignmentContent, 15, "muted",
                "Not in a raid group")
            self.raidGroupsEmptyState:SetPoint(
                "TOP", self.assignmentContent, "TOP", 0, -145)
        end
        self.raidGroupsEmptyState:Show()
        self.assignmentContent:SetHeight(330)
        self.assignmentTitle:SetText("RAID GROUPS")
        self:RefreshFooterLayout()
        return
    end
    if self.raidGroupsEmptyState then
        self.raidGroupsEmptyState:Hide()
    end
    local grouped = {}
    for groupIndex = 1, 8 do grouped[groupIndex] = {} end
    for _, player in ipairs(self.roster or {}) do
        local groupIndex = math.max(
            1, math.min(8, tonumber(player.subgroup) or 1))
        grouped[groupIndex][#grouped[groupIndex] + 1] = player
    end
    local rowWidth = self.assignmentRowWidth or ASSIGNMENT_ROW_WIDTH
    local canEdit = self:CanEditRaidGroups()
    for _, button in ipairs(quickActions.Actions) do
        button:SetEnabled(canEdit)
        button:SetAlpha(canEdit and 1 or .4)
    end
    quickActions:Show()
    local gap = 8
    local cardWidth = math.floor((rowWidth - (gap * 3)) / 4)
    for groupIndex = 1, 8 do
        local group = self.raidGroupFrames[groupIndex]
            or self:CreateRaidGroupFrame(groupIndex)
        local column = (groupIndex - 1) % 4
        local row = math.floor((groupIndex - 1) / 4)
        group:ClearAllPoints()
        group:SetPoint(
            "TOPLEFT",
            column * (cardWidth + gap),
            -(row * 204))
        group:SetWidth(cardWidth)
        group.Count:SetText(
            ("%d/5"):format(#grouped[groupIndex]))
        for slotIndex, slot in ipairs(group.Slots) do
            local player = grouped[groupIndex][slotIndex]
            slot.player = player
            if player then
                SetClassText(slot.Text, player.name, player.class)
                local unavailable = player.online == false
                slot.Status:SetText(
                    unavailable
                        and (player.manual and "PLANNED" or "OFFLINE")
                        or "")
                slot.Status:SetTextColor(
                    unavailable and 1 or MUTED[1],
                    unavailable and .32 or MUTED[2],
                    unavailable and .32 or MUTED[3],
                    1)
                local color = player.class and RAID_CLASS_COLORS
                    and RAID_CLASS_COLORS[player.class]
                slot.ClassDot:SetVertexColor(
                    color and color.r or .55,
                    color and color.g or .62,
                    color and color.b or .69, 1)
                slot.ClassDot:Show()
                local roleCoords = ROLE_COORDS[player.role]
                if roleCoords then
                    slot.Role:SetTexCoord(unpack(roleCoords))
                    slot.Role:Show()
                else
                    slot.Role:Hide()
                end
                slot.Leader:SetShown(player.leader or false)
                slot.Assistant:SetShown(
                    not player.leader and player.assistant or false)
                slot.MainTank:SetShown(
                    player.raidAssignment == "MAINTANK")
                slot.MainAssist:SetShown(
                    player.raidAssignment == "MAINASSIST")
                local rightOffset = -7
                for _, icon in ipairs({
                    slot.Role, slot.MainTank, slot.MainAssist,
                    slot.Leader, slot.Assistant,
                }) do
                    icon:ClearAllPoints()
                    if icon:IsShown() then
                        icon:SetPoint("RIGHT", slot, "RIGHT", rightOffset, 0)
                        rightOffset = rightOffset - 22
                    end
                end
                slot.Status:ClearAllPoints()
                slot.Status:SetShown(unavailable)
                if unavailable then
                    slot.Status:SetPoint(
                        "RIGHT", slot, "RIGHT", rightOffset, 0)
                    rightOffset = rightOffset - 58
                end
                slot.Text:ClearAllPoints()
                slot.Text:SetPoint("LEFT", 17, 0)
                slot.Text:SetPoint(
                    "RIGHT", slot, "RIGHT", rightOffset - 5, 0)
                slot.baseColor = { .035, .075, .095, .98 }
                slot:SetAlpha(
                    unavailable and (player.manual and .72 or .48) or 1)
            else
                slot.Text:SetText("Empty")
                slot.Text:SetTextColor(unpack(MUTED))
                slot.ClassDot:Hide()
                slot.Role:Hide()
                slot.Leader:Hide()
                slot.Assistant:Hide()
                slot.MainTank:Hide()
                slot.MainAssist:Hide()
                slot.Status:SetText("")
                slot.Status:Hide()
                slot.Text:ClearAllPoints()
                slot.Text:SetPoint("LEFT", 17, 0)
                slot.Text:SetPoint("RIGHT", -7, 0)
                slot.baseColor = { .025, .038, .052, .92 }
                slot:SetAlpha(1)
            end
            slot.baseBorder = { unpack(BORDER) }
            slot:SetBackdropColor(unpack(slot.baseColor))
            slot:SetBackdropBorderColor(unpack(slot.baseBorder))
        end
        group:Show()
    end
    self.assignmentContent:SetHeight(406)
    self.assignmentTitle:SetText("RAID GROUP EDITOR")
    self:RefreshFooterLayout()
end

local function GetGearItemLevel(link)
    if not link then return nil end
    if C_Item and C_Item.GetDetailedItemLevelInfo then
        local ok, level = pcall(
            C_Item.GetDetailedItemLevelInfo, link)
        if ok then return tonumber(level) end
    end
    if GetDetailedItemLevelInfo then
        local ok, level = pcall(GetDetailedItemLevelInfo, link)
        if ok then return tonumber(level) end
    end
    return nil
end

local function GetGearItemQuality(link)
    if not link then return nil end
    if GetItemInfo then
        local quality = select(3, GetItemInfo(link))
        if quality ~= nil then return quality end
    end
    if C_Item and C_Item.GetItemQualityByID and GetItemInfoInstant then
        local itemID = GetItemInfoInstant(link)
        if itemID then
            local ok, quality = pcall(C_Item.GetItemQualityByID, itemID)
            if ok then return quality end
        end
    end
    return nil
end

function Raid:CaptureGearInspectUnit(player)
    if not player or not player.unit or not UnitExists(player.unit) then
        return
    end
    self.gearInspectCache = self.gearInspectCache or {}
    local key = player.guid or player.name
    local data = {
        items = {},
        updated = GetTime(),
    }
    local totalLevel, levelCount = 0, 0
    for _, definition in ipairs(GEAR_INSPECT_SLOTS) do
        local link = GetInventoryItemLink
            and GetInventoryItemLink(player.unit, definition.id)
        local texture = GetInventoryItemTexture
            and GetInventoryItemTexture(player.unit, definition.id)
        local level = GetGearItemLevel(link)
        local quality = GetInventoryItemQuality
            and GetInventoryItemQuality(player.unit, definition.id)
            or GetGearItemQuality(link)
        data.items[definition.id] = {
            link = link,
            texture = texture,
            level = level,
            quality = quality,
        }
        if level then
            totalLevel = totalLevel + level
            levelCount = levelCount + 1
        end
    end
    data.averageLevel = levelCount > 0
        and math.floor((totalLevel / levelCount) + .5) or nil
    data.complete = levelCount >= 12
    self.gearInspectCache[key] = data
    if self.UpdateGearScoreFromTipTac then
        self:UpdateGearScoreFromTipTac(player)
    end
end

function Raid:StorePeerGearSnapshot(sender, links)
    local wanted = ShortPlayerName(sender)
    local player
    for _, candidate in ipairs(self.roster or {}) do
        if ShortPlayerName(candidate.name) == wanted then
            player = candidate
            break
        end
    end
    if not player then return end
    self.gearInspectCache = self.gearInspectCache or {}
    local data = {
        items = {},
        updated = GetTime(),
        source = "ADDON",
    }
    local totalLevel, levelCount = 0, 0
    for _, definition in ipairs(GEAR_INSPECT_SLOTS) do
        local link = links and links[definition.id]
        local texture, quality
        if link and GetItemInfo then
            quality = GetGearItemQuality(link)
            texture = select(10, GetItemInfo(link))
        end
        if link and not texture and GetItemIcon then
            texture = GetItemIcon(link)
        elseif link and not texture
            and C_Item and C_Item.GetItemIconByID
            and GetItemInfoInstant
        then
            local itemID = GetItemInfoInstant(link)
            if itemID then texture = C_Item.GetItemIconByID(itemID) end
        end
        local level = GetGearItemLevel(link)
        data.items[definition.id] = {
            link = link,
            texture = texture,
            level = level,
            quality = quality,
        }
        if level then
            totalLevel = totalLevel + level
            levelCount = levelCount + 1
        end
    end
    data.averageLevel = levelCount > 0
        and math.floor((totalLevel / levelCount) + .5) or nil
    data.complete = true
    self.gearInspectCache[player.guid or player.name] = data
    if self.gearPeerWait then
        self.gearPeerWait[player.guid or player.name] = nil
    end
    if self.gearInspectView and self.gearInspectView:IsShown() then
        self:RefreshGearInspectView(false)
    end
end

function Raid:QueueGearInspections()
    self.gearInspectQueue = {}
    self.gearInspectQueued = {}
    self.gearPeerWait = self.gearPeerWait or {}
    local now = GetTime()
    for _, player in ipairs(self.roster or {}) do
        local unit = player.unit
        if unit and UnitExists(unit)
            and player.online ~= false
            and not player.manual
            and not player.simulated
        then
            if UnitIsUnit and UnitIsUnit(unit, "player") then
                self:CaptureGearInspectUnit(player)
            else
                local key = player.guid or player.name
                local cached = self.gearInspectCache
                    and self.gearInspectCache[key]
                -- Addon snapshots and local fallback inspections are both
                -- fresh for five minutes. Re-inspecting fallback data every
                -- 15 seconds needlessly competes for Blizzard's shared
                -- inspection channel.
                local freshCache = cached and cached.complete
                    and now - (cached.updated or 0) < 300
                local compatiblePeer
                for sender, compatible in pairs(
                    self.compatiblePeers or {})
                do
                    if compatible
                        and ShortPlayerName(sender)
                            == ShortPlayerName(player.name)
                    then
                        compatiblePeer = true
                        break
                    end
                end
                if compatiblePeer and not cached then
                    self.gearPeerWait[key] =
                        self.gearPeerWait[key] or now
                end
                local waitingForPeer = compatiblePeer
                    and not cached
                    and now - (self.gearPeerWait[key] or now) < 8
                if not freshCache and not waitingForPeer
                    and not self.gearInspectQueued[key]
                then
                    self.gearInspectQueued[key] = true
                    self.gearInspectQueue[
                        #self.gearInspectQueue + 1] = player
                end
            end
        end
    end
end

function Raid:ProcessGearInspectQueue()
    local now = GetTime()
    if self.gearInspectPending then
        if now - (self.gearInspectPendingAt or 0) < 4 then
            return
        end
        self.gearInspectPending = nil
    end
    if self.pendingInspect then return end
    if InCombatLockdown and InCombatLockdown() then return end
    if _G.InspectFrame and InspectFrame:IsShown() then return end
    if now - (self.lastGlobalInspectAt or 0) < 5 then return end
    while self.gearInspectQueue and #self.gearInspectQueue > 0 do
        local player = table.remove(self.gearInspectQueue, 1)
        local unit = player and player.unit
        local inspectKey = player and (player.guid or player.name)
        if unit and UnitExists(unit)
            and CanInspect and CanInspect(unit, false)
            and NotifyInspect
            and (not self.IsPeerInspectReserved
                or not self:IsPeerInspectReserved(inspectKey))
        then
            if self.BroadcastInspectClaim then
                self:BroadcastInspectClaim(inspectKey, 10)
            end
            local ok = pcall(NotifyInspect, unit)
            if ok then
                self.gearInspectPending = player.guid or player.name
                self.gearInspectPendingAt = GetTime()
                return
            end
        end
    end
end

function Raid:HandleGearInspectReady(event, guid)
    -- AceEvent keeps one handler per event on this addon object. Dispatch the
    -- same result to the character-intel inspector before handling gear.
    if self.INSPECT_READY then
        self:INSPECT_READY(event, guid)
    end
    local pending = self.gearInspectPending
    -- Ignore inspection results initiated by MRT, Blizzard's InspectFrame, or
    -- another addon. Only consume the request owned by this queue.
    if not pending then return end
    if guid and pending ~= guid then return end
    for _, player in ipairs(self.roster or {}) do
        if player.guid == guid
            or (not guid and (player.guid or player.name) == pending)
        then
            self:CaptureGearInspectUnit(player)
            break
        end
    end
    self.gearInspectPending = nil
    -- MRT intentionally reads equipment shortly after INSPECT_READY. Do not
    -- clear the shared inspect state, and delay our next request long enough
    -- for that read to complete.
    self.lastGlobalInspectAt = GetTime()
    if self.gearInspectView and self.gearInspectView:IsShown() then
        self:RefreshGearInspectView(false)
    end
end

function Raid:CreateGearInspectView()
    if self.gearInspectView then return self.gearInspectView end
    local view = CreateFrame("Frame", nil, self.assignmentPanel)
    view:SetPoint("TOPLEFT", 6, -8)
    view:SetPoint("BOTTOMRIGHT", -6, 8)
    view.HeaderBackground =
        view:CreateTexture(nil, "BACKGROUND")
    view.HeaderBackground:SetTexture(WHITE)
    view.HeaderBackground:SetPoint("TOPLEFT", 0, 0)
    view.HeaderBackground:SetPoint("TOPRIGHT", 0, 0)
    view.HeaderBackground:SetHeight(30)
    view.HeaderBackground:SetVertexColor(.035, .105, .145, .98)
    view.Summary = Font(view, 9, "accent", "")
    view.Summary:SetPoint("TOPLEFT", 7, -10)
    view.Summary:SetWidth(130)
    view.Summary:SetJustifyH("LEFT")
    view.GearScoreHeader = Font(view, 8, "accent", "GS")
    view.GearScoreHeader:SetPoint("TOPLEFT", 142, -10)
    view.GearScoreHeader:SetWidth(38)
    view.GearScoreHeader:SetJustifyH("RIGHT")
    view.ItemLevelHeader = Font(view, 8, "accent", "ILVL")
    view.ItemLevelHeader:SetPoint("TOPLEFT", 184, -10)
    view.ItemLevelHeader:SetWidth(31)
    view.ItemLevelHeader:SetJustifyH("RIGHT")
    view.Headers = {}
    for index, definition in ipairs(GEAR_INSPECT_SLOTS) do
        local slotLabel = definition.label
        local header = CreateFrame("Frame", nil, view)
        PixelSetSize(header, 31, 28)
        header:SetPoint(
            "TOPRIGHT",
            -((#GEAR_INSPECT_SLOTS - index) * 33), -1)
        header.Background = header:CreateTexture(nil, "BACKGROUND")
        header.Background:SetAllPoints()
        header.Background:SetTexture(WHITE)
        header.Background:SetVertexColor(
            index % 2 == 0 and .045 or .055,
            index % 2 == 0 and .14 or .16,
            index % 2 == 0 and .19 or .215, 1)
        header.Icon = header:CreateTexture(nil, "ARTWORK")
        local texture
        if GetInventorySlotInfo then
            local _, slotTexture =
                GetInventorySlotInfo(definition.token)
            texture = slotTexture
        end
        header.Icon:SetTexture(
            texture or "Interface\\Icons\\INV_Misc_QuestionMark")
        PixelSetSize(header.Icon, 20, 20)
        header.Icon:SetPoint("CENTER")
        header.Icon:SetDesaturated(true)
        header.Icon:SetAlpha(.62)
        header:EnableMouse(true)
        header:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(slotLabel)
            GameTooltip:Show()
        end)
        header:SetScript("OnLeave", function() GameTooltip:Hide() end)
        view.Headers[index] = header
    end
    view.Scroll, view.Content = CreateScrollArea(view)
    view.Scroll:SetPoint("TOPLEFT", 0, -32)
    view.Scroll:SetPoint("BOTTOMRIGHT", 0, 0)
    view.Content:SetWidth(790)
    view.Rows = {}
    view:SetScript("OnUpdate", function(self, elapsed)
        self.inspectElapsed = (self.inspectElapsed or 0) + elapsed
        self.rescanElapsed = (self.rescanElapsed or 0) + elapsed
        if self.inspectElapsed >= 2 then
            self.inspectElapsed = 0
            Raid:ProcessGearInspectQueue()
        end
        if self.rescanElapsed >= 60 then
            self.rescanElapsed = 0
            Raid:QueueGearInspections()
        end
    end)
    view:Hide()
    self.gearInspectView = view
    return view
end

function Raid:CreateGearInspectRow(index, view)
    local row = CreateFrame("Frame", nil, view.Content)
    row:SetHeight(34)
    row.Bg = row:CreateTexture(nil, "BACKGROUND")
    row.Bg:SetAllPoints()
    row.Bg:SetTexture(WHITE)
    row.Bg:SetVertexColor(
        index % 2 == 0 and .025 or .035,
        index % 2 == 0 and .045 or .06,
        index % 2 == 0 and .06 or .075, .92)
    row.Name = Font(row, 10, "text", "")
    row.Name:SetPoint("LEFT", 7, 0)
    row.Name:SetWidth(132)
    row.Name:SetJustifyH("LEFT")
    row.GearScore = Font(row, 9, "muted", "")
    row.GearScore:SetPoint("LEFT", 142, 0)
    row.GearScore:SetWidth(38)
    row.GearScore:SetJustifyH("RIGHT")
    row.ItemLevel = Font(row, 9, "accent", "")
    row.ItemLevel:SetPoint("LEFT", 184, 0)
    row.ItemLevel:SetWidth(31)
    row.ItemLevel:SetJustifyH("RIGHT")
    row.Cells = {}
    for slotIndex, definition in ipairs(GEAR_INSPECT_SLOTS) do
        local cell = BackdropFrame("Button", nil, row)
        PixelSetSize(cell, 30, 30)
        cell:SetPoint(
            "RIGHT",
            -((#GEAR_INSPECT_SLOTS - slotIndex) * 33), 0)
        cell:SetBackdrop({
            bgFile = WHITE,
            edgeFile = WHITE,
            edgeSize = Pixel(1),
        })
        InstallPixelBorder(cell)
        cell:SetBackdropColor(.008, .014, .019, .76)
        cell:SetBackdropBorderColor(.12, .16, .19, .75)
        cell.Icon = cell:CreateTexture(nil, "ARTWORK")
        cell.Icon:SetAllPoints()
        cell.Icon:SetTexture(
            "Interface\\Icons\\INV_Misc_QuestionMark")
        cell.Icon:SetAlpha(.18)
        cell.Level = Font(cell, 8, "text", "")
        cell.Level:SetPoint("BOTTOMRIGHT", -1, 1)
        cell.Level:SetShadowColor(0, 0, 0, 1)
        cell:SetScript("OnEnter", function(self)
            if not self.link then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:Show()
        end)
        cell:SetScript("OnLeave", function() GameTooltip:Hide() end)
        cell.slotID = definition.id
        row.Cells[slotIndex] = cell
    end
    view.Rows[index] = row
    return row
end

function Raid:RefreshGearInspectView(queueScan)
    local view = self:CreateGearInspectView()
    view:Show()
    view.Content:SetWidth(math.max(
        1, (view.Scroll:GetWidth() or view:GetWidth() or 790) - 2))
    if queueScan ~= false
        and (not self.gearInspectQueue
            or #self.gearInspectQueue == 0)
    then
        self:QueueGearInspections()
    end
    self.gearInspectCache = self.gearInspectCache or {}
    local inspected, addonReported, locallyInspected = 0, 0, 0
    for index, player in ipairs(self.roster or {}) do
        local row = view.Rows[index]
            or self:CreateGearInspectRow(index, view)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -((index - 1) * 35))
        row:SetPoint("TOPRIGHT", 0, -((index - 1) * 35))
        SetClassText(row.Name, player.name, player.class)
        row.Bg:SetVertexColor(
            GetClassRowColor(player.class, index % 2 == 0))
        row:SetAlpha(player.online == false and .35 or 1)
        row.GearScore:SetText(
            player.gearScore and tostring(player.gearScore) or "—")
        local data =
            self.gearInspectCache[player.guid or player.name]
        row.ItemLevel:SetText(
            data and data.averageLevel
                and tostring(data.averageLevel) or "—")
        if data then
            inspected = inspected + 1
            if data.source == "ADDON" then
                addonReported = addonReported + 1
            else
                locallyInspected = locallyInspected + 1
            end
        end
        for slotIndex, definition in ipairs(GEAR_INSPECT_SLOTS) do
            local cell = row.Cells[slotIndex]
            local item = data and data.items[definition.id]
            cell.link = item and item.link
            cell.Icon:SetTexture(
                item and item.texture
                    or "Interface\\Icons\\INV_Misc_QuestionMark")
            cell.Icon:SetAlpha(item and item.link and 1 or .14)
            cell.Level:SetText(
                item and item.level and tostring(item.level) or "")
            local qualityColor = item and item.quality
                and ITEM_QUALITY_COLORS
                and ITEM_QUALITY_COLORS[item.quality]
            cell:SetBackdropBorderColor(
                qualityColor and qualityColor.r or .12,
                qualityColor and qualityColor.g or .16,
                qualityColor and qualityColor.b or .19,
                qualityColor and .95 or .55)
            cell.Level:SetTextColor(
                qualityColor and qualityColor.r or MUTED[1],
                qualityColor and qualityColor.g or MUTED[2],
                qualityColor and qualityColor.b or MUTED[3],
                1)
        end
        row:Show()
    end
    for index = #(self.roster or {}) + 1, #view.Rows do
        view.Rows[index]:Hide()
    end
    view.Content:SetHeight(math.max(
        1, #(self.roster or {}) * 35))
    view.Summary:SetText(
        ("%d/%d · %d ADDON · %d INSPECT")
            :format(
                inspected, #(self.roster or {}),
                addonReported, locallyInspected))
    self.assignmentTitle:SetText("GEAR INSPECT")
end

function Raid:CreateAboutView()
    if self.aboutView then return self.aboutView end
    local view = CreateFrame("Frame", nil, self.assignmentPanel)
    view:SetPoint("TOPLEFT", 22, -24)
    view:SetPoint("BOTTOMRIGHT", -22, 24)

    view.Icon = view:CreateTexture(nil, "ARTWORK")
    view.Icon:SetTexture("Interface\\Icons\\INV_BannerPVP_02")
    PixelSetSize(view.Icon, 64, 64)
    view.Icon:SetPoint("TOPLEFT")

    view.Name = Font(view, 20, "accent", "LUNARAIDS")
    view.Name:SetPoint("TOPLEFT", view.Icon, "TOPRIGHT", 16, -4)
    local metadata = C_AddOns and C_AddOns.GetAddOnMetadata
        or GetAddOnMetadata
    local version = metadata
        and metadata("LunaRaids", "Version") or "0.1.0"
    view.Version = Font(
        view, 9, "muted", "Version " .. (version or "0.1.0"))
    view.Version:SetPoint("TOPLEFT", view.Name, "BOTTOMLEFT", 1, -6)

    view.Credit = Font(
        view, 11, "text",
        "Developed by Wuild together with the guild Voracious "
            .. "on Thunderstrike.")
    view.Credit:SetPoint("TOPLEFT", 0, -92)
    view.Credit:SetPoint("RIGHT", -10, 0)
    view.Credit:SetJustifyH("LEFT")

    view.Description = Font(
        view, 10, "muted",
        "A collaborative raid-planning and assignment tool built for "
            .. "Vanilla and The Burning Crusade.")
    view.Description:SetPoint("TOPLEFT", 0, -122)
    view.Description:SetPoint("RIGHT", -10, 0)
    view.Description:SetJustifyH("LEFT")

    view.Divider = view:CreateTexture(nil, "ARTWORK")
    view.Divider:SetTexture(WHITE)
    view.Divider:SetPoint("TOPLEFT", 0, -164)
    view.Divider:SetPoint("TOPRIGHT", 0, -164)
    SetPixelHeight(view.Divider, 1)
    view.Divider:SetVertexColor(.12, .28, .38, .9)

    view.GitHubLabel = Font(view, 9, "muted", "SOURCE CODE")
    view.GitHubLabel:SetPoint("TOPLEFT", 0, -192)
    view.GitHub = EditField(
        view, 520, "https://github.com/Wuild/LunaRaids")
    view.GitHub:SetPoint("TOPLEFT", 0, -210)
    view.GitHub:SetPoint("TOPRIGHT", 0, -210)
    view.GitHub:SetText("https://github.com/Wuild/LunaRaids")
    view.GitHub:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)

    view.PatreonLabel = Font(view, 9, "muted", "SUPPORT DEVELOPMENT")
    view.PatreonLabel:SetPoint("TOPLEFT", 0, -264)
    view.Patreon = EditField(
        view, 520, "https://www.patreon.com/wuild")
    view.Patreon:SetPoint("TOPLEFT", 0, -282)
    view.Patreon:SetPoint("TOPRIGHT", 0, -282)
    view.Patreon:SetText("https://www.patreon.com/wuild")
    view.Patreon:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)

    view.CopyHint = Font(
        view, 9, "muted",
        "Click a link, then press Ctrl+C to copy it.")
    view.CopyHint:SetPoint("TOPLEFT", 1, -324)
    view:Hide()
    self.aboutView = view
    return view
end

function Raid:RefreshAboutView()
    self:CreateAboutView():Show()
end

function Raid:RefreshAssignments()
    if self.RefreshPersonalAssignments then
        self:RefreshPersonalAssignments()
    end
    if self.raidPickerActive then return end
    if self.RefreshRaidIdentityHeader then
        self:RefreshRaidIdentityHeader()
    end
    if not self.assignmentContent then return end
    local encounter = self:GetEncounter()
    local activeTab = self.workspaceMode == "STATUS"
        and "STATUS"
        or self.workspaceMode == "GEAR" and "GEAR"
        or self.workspaceMode == "GROUPS" and "GROUPS"
        or self.workspaceMode == "ABOUT" and "ABOUT"
        or self.activeBossTab or "ASSIGNMENTS"
    if self.bossSettingsButton then
        self.bossSettingsButton:SetShown(
            encounter.name ~= "Raid Overview"
                and activeTab ~= "GROUPS"
                and activeTab ~= "STATUS"
                and activeTab ~= "GEAR"
                and activeTab ~= "ABOUT")
        if (encounter.name == "Raid Overview"
            or activeTab == "GROUPS"
            or activeTab == "STATUS"
            or activeTab == "GEAR"
            or activeTab == "ABOUT")
            and self.bossSettingsPanel
        then
            self.bossSettingsPanel:Hide()
        elseif self.bossSettingsPanel
            and self.bossSettingsPanel:IsShown()
        then
            self:RefreshBossSettingsPanel()
        end
    end
    self.assignmentSlots = self.assignmentSlots or {}
    self.groupHeaders = self.groupHeaders or {}
    self.markerRows = self.markerRows or {}
    self:RefreshBossTabs()
    if self.mechanicLines then
        for _, line in ipairs(self.mechanicLines) do line:Hide() end
    end
    if activeTab ~= "GROUPS" then
        if self.raidGroupQuickActions then
            self.raidGroupQuickActions:Hide()
        end
        if self.raidGroupsEmptyState then
            self.raidGroupsEmptyState:Hide()
        end
        for _, group in ipairs(self.raidGroupFrames or {}) do
            group:Hide()
        end
    end
    if activeTab ~= "STATUS" and self.raidStatusView then
        self.raidStatusView:Hide()
    end
    if activeTab ~= "GEAR" and self.gearInspectView then
        self.gearInspectView:Hide()
    end
    if activeTab ~= "ABOUT" and self.aboutView then
        self.aboutView:Hide()
    end
    if activeTab == "ABOUT" then
        for _, slot in ipairs(self.assignmentSlots) do slot:Hide() end
        for _, header in ipairs(self.groupHeaders) do header:Hide() end
        for _, row in ipairs(self.markerRows) do row:Hide() end
        if self.autoAssignButton then self.autoAssignButton:Hide() end
        if self.assignmentPanel
            and self.assignmentPanel.ProgressTrack
        then
            self.assignmentPanel.ProgressTrack:Hide()
            self.assignmentPanel.ProgressFill:Hide()
        end
        self:RefreshAboutView()
        return
    end
    if activeTab == "GEAR" then
        for _, slot in ipairs(self.assignmentSlots) do slot:Hide() end
        for _, header in ipairs(self.groupHeaders) do header:Hide() end
        for _, row in ipairs(self.markerRows) do row:Hide() end
        if self.autoAssignButton then self.autoAssignButton:Hide() end
        if self.assignmentPanel
            and self.assignmentPanel.ProgressTrack
        then
            self.assignmentPanel.ProgressTrack:Hide()
            self.assignmentPanel.ProgressFill:Hide()
        end
        self:RefreshGearInspectView()
        return
    end
    if activeTab == "STATUS" then
        for _, slot in ipairs(self.assignmentSlots) do slot:Hide() end
        for _, header in ipairs(self.groupHeaders) do header:Hide() end
        for _, row in ipairs(self.markerRows) do row:Hide() end
        if self.autoAssignButton then self.autoAssignButton:Hide() end
        if self.assignmentPanel
            and self.assignmentPanel.ProgressTrack
        then
            self.assignmentPanel.ProgressTrack:Hide()
            self.assignmentPanel.ProgressFill:Hide()
        end
        self:RefreshRaidStatusView()
        return
    end
    if activeTab == "GROUPS" then
        for _, slot in ipairs(self.assignmentSlots) do slot:Hide() end
        for _, header in ipairs(self.groupHeaders) do header:Hide() end
        for _, row in ipairs(self.markerRows) do row:Hide() end
        if self.autoAssignButton then self.autoAssignButton:Hide() end
        if self.assignmentPanel
            and self.assignmentPanel.ProgressTrack
        then
            self.assignmentPanel.ProgressTrack:Hide()
            self.assignmentPanel.ProgressFill:Hide()
        end
        self:RefreshRaidGroups()
        return
    end
    if activeTab == "MECHANICS" then
        for _, slot in ipairs(self.assignmentSlots) do slot:Hide() end
        for _, header in ipairs(self.groupHeaders) do header:Hide() end
        for _, row in ipairs(self.markerRows) do row:Hide() end
        if self.autoAssignButton then self.autoAssignButton:Hide() end
        if self.assignmentPanel
            and self.assignmentPanel.ProgressTrack
        then
            self.assignmentPanel.ProgressTrack:Hide()
            self.assignmentPanel.ProgressFill:Hide()
        end
        self:RefreshMechanics()
        return
    end
    local slotNumber, groupNumber, y = 0, 0, 0
    local filledSlots, totalSlots = 0, 0
    local encounterTargets = self:GetEncounterTargets()
    if activeTab == "ASSIGNMENTS" then
        if not self.autoAssignButton then
            self.autoAssignButton =
                Button(self.assignmentContent, "AUTO ASSIGN", 132, 25)
            AddButtonIcon(
                self.autoAssignButton,
                "Interface\\Icons\\Spell_Holy_MindVision")
            self.autoAssignButton:SetScript(
                "OnClick", function() Raid:AutoAssignEncounter() end)
            StyleButton(self.autoAssignButton, "primary")
            self.autoAssignButton:HookScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Smart Auto Assign")
                GameTooltip:AddLine(
                    "Fills empty slots using raid roles, class utility, "
                    .. "and GearScore. Existing assignments are kept.",
                    MUTED[1], MUTED[2], MUTED[3], true)
                GameTooltip:Show()
            end)
            self.autoAssignButton:HookScript(
                "OnLeave", function() GameTooltip:Hide() end)
        end
        self.autoAssignButton:ClearAllPoints()
        self.autoAssignButton:SetPoint("TOPRIGHT", -1, -y)
        if self:IsLocalRaidEditor() then
            self.autoAssignButton:Show()
            y = y + 34
        else
            self.autoAssignButton:Hide()
        end
    elseif self.autoAssignButton then
        self.autoAssignButton:Hide()
    end
    if activeTab == "MARKERS" and #encounterTargets > 0 then
        groupNumber = groupNumber + 1
        local markerHeader = self.groupHeaders[groupNumber]
        if not markerHeader then
            markerHeader = Font(
                self.assignmentContent, 10, "accent", "")
            self.groupHeaders[groupNumber] = markerHeader
        end
        markerHeader:ClearAllPoints()
        markerHeader:SetPoint("TOPLEFT", 2, -y)
        markerHeader:SetText("BOSSES & ADDS")
        markerHeader:Show()
        y = y + 29
        for targetIndex, targetName in ipairs(encounterTargets) do
            local row = self.markerRows[targetIndex]
            if not row then
                row = self:CreateMarkerRow(targetIndex)
                self.markerRows[targetIndex] = row
            end
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, -y)
            row.targetIndex = targetIndex
            row.Label:SetText(targetName)
            local markerIndex =
                self:GetMarkerAssignment(targetIndex)
            local marker = markerIndex and self.markers[markerIndex]
            SetMarkerTexture(row.MarkerIcon, markerIndex)
            row.MarkerText:SetText(
                marker and marker.name or "No marker")
            if marker then
                row.MarkerText:SetTextColor(1, 1, 1, 1)
            else
                row.MarkerText:SetTextColor(unpack(MUTED))
            end
            row:Show()
            y = y + ROW_HEIGHT
        end
        y = y + 12
    end
    for index = #encounterTargets + 1, #self.markerRows do
        self.markerRows[index]:Hide()
    end
    if activeTab ~= "MARKERS" then
        for _, row in ipairs(self.markerRows) do row:Hide() end
    end
    local visibleGroups = {}
    for groupIndex, group in ipairs(encounter.groups) do
        if encounter.name == "Raid Overview"
            or group.name ~= "Healing"
        then
            visibleGroups[#visibleGroups + 1] = {
                index = groupIndex, group = group,
            }
        end
    end
    if encounter.name == "Raid Overview" then
        local groupOrder = {
            Tanks = 1, Healing = 2, Damage = 3,
        }
        table.sort(visibleGroups, function(left, right)
            local leftOrder = groupOrder[left.group.name] or 10
            local rightOrder = groupOrder[right.group.name] or 10
            if leftOrder ~= rightOrder then
                return leftOrder < rightOrder
            end
            return left.index < right.index
        end)
    end
    if activeTab == "ASSIGNMENTS" then
    for _, entry in ipairs(visibleGroups) do
        local groupIndex, group = entry.index, entry.group
        groupNumber = groupNumber + 1
        local header = self.groupHeaders[groupNumber]
        if not header then
            header = Font(self.assignmentContent, 10, "accent", "")
            self.groupHeaders[groupNumber] = header
        end
        header:ClearAllPoints()
        header:SetPoint("TOPLEFT", 4, -y)
        header:SetText(group.name:upper())
        header:SetTextColor(.48, .78, .96, 1)
        header:Show()
        y = y + 29
        for slotIndex, assignmentSlot in ipairs(
            self:GetEncounterGroupSlots(groupIndex, encounter)) do
            slotNumber = slotNumber + 1
            local slot = self.assignmentSlots[slotNumber]
            if not slot then
                slot = self:CreateAssignmentSlot(slotNumber)
                self.assignmentSlots[slotNumber] = slot
            end
            slot:ClearAllPoints()
            slot:SetPoint("TOPLEFT", 0, -y)
            slot.groupIndex, slot.slotIndex = groupIndex, slotIndex
            slot.healingSlotIndex = nil
            slot.HealingTarget:Hide()
            slot.Label:Show()
            local assignmentLabel = self:GetSlotLabel(assignmentSlot)
            local assignmentRole =
                assignmentSlot.role or group.role
            local markerToken = self:GetMarkerTokenForText(
                assignmentLabel, assignmentRole == self.Role.TANK)
            if markerToken ~= "" then
                assignmentLabel = assignmentLabel .. " "
                    .. self:FormatMarkerTokensForLocalDisplay(markerToken)
            end
            slot.Label:SetText(assignmentLabel)
            local roleCoords = ROLE_COORDS[
                assignmentSlot.role or group.role]
            if roleCoords then
                slot.RoleIcon:SetTexCoord(unpack(roleCoords))
                slot.RoleIcon:Show()
            else
                slot.RoleIcon:Hide()
            end
            local assignment = self:GetAssignment(groupIndex, slotIndex)
            totalSlots = totalSlots + 1
            if assignment then
                filledSlots = filledSlots + 1
                SetClassText(slot.Player, assignment.name, assignment.class)
                slot.FilledBar:Show()
                slot.baseColor = { .035, .105, .095, .98 }
                slot.baseBorder = { .12, .30, .27, 1 }
            else
                slot.Player:SetText("Drop or click to suggest")
                slot.Player:SetTextColor(unpack(MUTED))
                slot.FilledBar:Hide()
                slot.baseColor = { .038, .055, .075, .96 }
                slot.baseBorder = { unpack(BORDER) }
            end
            slot:SetBackdropColor(unpack(slot.baseColor))
            slot:SetBackdropBorderColor(unpack(slot.baseBorder))
            slot.HealingTarget.baseColor = slot.baseColor
            slot.HealingTarget:SetBackdropColor(
                unpack(slot.baseColor))
            slot:Show()
            y = y + ROW_HEIGHT
        end
        y = y + 12
    end
    if encounter.name ~= "Raid Overview" then
        groupNumber = groupNumber + 1
        local healingHeader = self.groupHeaders[groupNumber]
        if not healingHeader then
            healingHeader = Font(
                self.assignmentContent, 10, "accent", "")
            self.groupHeaders[groupNumber] = healingHeader
        end
        healingHeader:ClearAllPoints()
        healingHeader:SetPoint("TOPLEFT", 4, -y)
        healingHeader:SetText("HEALER ASSIGNMENTS")
        healingHeader:SetTextColor(.48, .78, .96, 1)
        healingHeader:Show()
        y = y + 29
        local healingTargets = self:GetHealingTargets()
        for healerIndex = 1, self:GetHealingSlotCount() do
            slotNumber = slotNumber + 1
            local slot = self.assignmentSlots[slotNumber]
            if not slot then
                slot = self:CreateAssignmentSlot(slotNumber)
                self.assignmentSlots[slotNumber] = slot
            end
            slot:ClearAllPoints()
            slot:SetPoint("TOPLEFT", 0, -y)
            slot.groupIndex = nil
            slot.slotIndex = healerIndex
            slot.healingSlotIndex = healerIndex
            slot.Label:Hide()
            slot.HealingTarget:Show()
            slot.RoleIcon:SetTexCoord(unpack(ROLE_COORDS.HEALER))
            slot.RoleIcon:Show()
            local target = healingTargets[
                self:GetHealingTargetIndex(healerIndex)]
            local healingTargetLabel =
                self:GetHealingTargetLabel(target)
            local healingMarkerToken = healingTargetLabel ~= "Raid"
                and self:GetMarkerTokenForText(healingTargetLabel)
                or ""
            if healingMarkerToken ~= "" then
                healingTargetLabel = healingTargetLabel .. " "
                    .. self:FormatMarkerTokensForLocalDisplay(
                        healingMarkerToken)
            end
            slot.HealingTarget.Text:SetText(
                ("Healer %d -> %s"):format(
                    healerIndex, healingTargetLabel))
            local assignment = self:GetHealingAssignment(healerIndex)
            totalSlots = totalSlots + 1
            if assignment then
                filledSlots = filledSlots + 1
                SetClassText(
                    slot.Player, assignment.name, assignment.class)
                slot.FilledBar:Show()
                slot.baseColor = { .035, .105, .095, .98 }
                slot.baseBorder = { .12, .30, .27, 1 }
            else
                slot.Player:SetText("Drop or click to suggest")
                slot.Player:SetTextColor(unpack(MUTED))
                slot.FilledBar:Hide()
                slot.baseColor = { .038, .055, .075, .96 }
                slot.baseBorder = { unpack(BORDER) }
            end
            slot:SetBackdropColor(unpack(slot.baseColor))
            slot:SetBackdropBorderColor(unpack(slot.baseBorder))
            slot.HealingTarget.baseColor = slot.baseColor
            slot.HealingTarget:SetBackdropColor(
                unpack(slot.baseColor))
            slot:Show()
            y = y + ROW_HEIGHT
        end
        y = y + 12
    end
    end

    if activeTab == "MARKERS" and #encounterTargets == 0 then
        groupNumber = groupNumber + 1
        local empty = self.groupHeaders[groupNumber]
        if not empty then
            empty = Font(self.assignmentContent, 10, "muted", "")
            self.groupHeaders[groupNumber] = empty
        end
        empty:ClearAllPoints()
        empty:SetPoint("TOPLEFT", 8, -12)
        empty:SetText("Select a boss to configure its markers.")
        empty:Show()
        y = 42
    end

    for index = slotNumber + 1, #self.assignmentSlots do
        self.assignmentSlots[index]:Hide()
    end
    for index = groupNumber + 1, #self.groupHeaders do
        self.groupHeaders[index]:Hide()
    end
    self.assignmentContent:SetHeight(math.max(1, y))
    if self.assignmentTitle then
        if activeTab == "MARKERS" then
            self.assignmentTitle:SetText("BOSS & ADD MARKERS")
        else
            self.assignmentTitle:SetText(
                ("ASSIGNMENTS  %d/%d"):format(
                    filledSlots, totalSlots))
        end
    end
    if self.assignmentPanel
        and self.assignmentPanel.ProgressTrack
    then
        local showProgress =
            activeTab == "ASSIGNMENTS" and totalSlots > 0
        self.assignmentPanel.ProgressTrack:SetShown(showProgress)
        self.assignmentPanel.ProgressFill:SetShown(showProgress)
        if showProgress then
            self.assignmentPanel.ProgressFill:SetWidth(
                math.max(
                    1,
                    (self.assignmentRowWidth or ASSIGNMENT_ROW_WIDTH)
                        * filledSlots / totalSlots))
        end
    end
end

function Raid:CreateBossRailButton(index)
    local button = Button(
        self.bossRail, "", BOSS_BUTTON_SIZE, BOSS_BUTTON_SIZE)
    button.Icon = button:CreateTexture(nil, "ARTWORK")
    button.Icon:SetTexture("Interface\\Icons\\INV_Sword_27")
    button.Icon:SetPoint("TOPLEFT", 4, -4)
    button.Icon:SetPoint("BOTTOMRIGHT", -4, 4)
    button.Icon:SetTexCoord(.08, .92, .08, .92)
    button.ActiveBar = button:CreateTexture(nil, "OVERLAY")
    button.ActiveBar:SetTexture(WHITE)
    button.ActiveBar:SetPoint("TOPLEFT", 1, -1)
    button.ActiveBar:SetPoint("BOTTOMLEFT", 1, 1)
    SetPixelWidth(button.ActiveBar, 4)
    button.ActiveBar:SetVertexColor(unpack(ACCENT))
    button.SelectionGlow = button:CreateTexture(nil, "OVERLAY")
    button.SelectionGlow:SetTexture(WHITE)
    button.SelectionGlow:SetPoint("TOPLEFT", 2, -2)
    button.SelectionGlow:SetPoint("BOTTOMRIGHT", -2, 2)
    button.SelectionGlow:SetVertexColor(.18, .70, 1, .12)
    button.SelectionGlow:Hide()
    button.CurrentDot = button:CreateTexture(nil, "OVERLAY")
    button.CurrentDot:SetTexture(WHITE)
    PixelSetSize(button.CurrentDot, 7, 7)
    button.CurrentDot:SetPoint("TOPRIGHT", -3, -3)
    button.CurrentDot:SetVertexColor(.22, .9, .55, 1)
    button.CurrentDot:Hide()
    button.Text:Hide()
    button:SetScript("OnClick", function(self)
        Raid:SetEncounter(self.encounterIndex)
    end)
    button:SetScript("OnEnter", function(self)
        self:SetBackdropColor(.04, .16, .23, .98)
        self:SetBackdropBorderColor(
            self.selected and .18 or .22,
            self.selected and .70 or .48,
            self.selected and 1 or .64, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.encounterName or "Boss")
        if self.currentBoss then
            GameTooltip:AddLine(
                "Current boss", .22, .9, .55)
        end
        GameTooltip:AddLine("Click to open this boss plan.", unpack(MUTED))
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(self.baseColor))
        if self.selected then
            self:SetBackdropBorderColor(unpack(ACCENT))
        else
            self:SetBackdropBorderColor(unpack(BORDER))
        end
        GameTooltip:Hide()
    end)
    return button
end

function Raid:LayoutAssignmentToolbar()
    if not self.bossRail or not self.assignmentPanel then return end
    local railHeight = math.max(
        BOSS_BUTTON_SIZE + (BOSS_RAIL_GAP * 2),
        self.bossRail:GetHeight() or 0)
    local tabTop = 42 + railHeight + 6
    local firstTab = self.bossTabs
        and (
            self.bossTabs.MARKERS
            or self.bossTabs.ASSIGNMENTS
            or self.bossTabs.MECHANICS)
    if firstTab then
        firstTab:ClearAllPoints()
        firstTab:SetPoint("TOPLEFT", 8, -tabTop)
    end
    if self.assignmentPanel.ProgressTrack then
        self.assignmentPanel.ProgressTrack:ClearAllPoints()
        self.assignmentPanel.ProgressTrack:SetPoint(
            "TOPLEFT", 8, -(tabTop + 35))
    end
    if self.assignmentScroll then
        self.assignmentScroll:ClearAllPoints()
        self.assignmentScroll:SetPoint(
            "TOPLEFT", 6, -(tabTop + 39))
        self.assignmentScroll:SetPoint("BOTTOMRIGHT", -6, 8)
    end
end

function Raid:RefreshBossRail()
    if not self.bossRail then return end
    if self.raidPickerActive or not self.db.raidLocked then
        for _, button in ipairs(self.bossButtons or {}) do
            button:Hide()
        end
        self.bossRail:Hide()
        return
    end
    local raid = self:GetRaid()
    local currentBossIndex = self:GetCurrentBossIndex(raid)
    if self.setCurrentBossButton then
        local isOverview = self.db.activeEncounter == 1
        local isCurrent = self.db.activeEncounter == currentBossIndex
        self.setCurrentBossButton:SetEnabled(
            not isOverview and self:IsLocalRaidEditor())
        self.setCurrentBossButton.Text:SetText(
            isCurrent and "CURRENT BOSS" or "SET CURRENT BOSS")
        StyleButton(
            self.setCurrentBossButton,
            isCurrent and "positive" or "default")
    end
    if self.frame and self.frame.Title then
        self.frame.Title:SetText("LUNA RAIDS")
        if self.frame.Subtitle then
            self.frame.Subtitle:SetText(
                raid.name:upper() .. "  ·  ACTIVE PLAN")
        end
    end
    self.bossButtons = self.bossButtons or {}
    local availableWidth = math.max(
        BOSS_BUTTON_SIZE + (BOSS_RAIL_GAP * 2),
        self.bossRail:GetWidth() or 0)
    local columns = math.max(
        1,
        math.floor(
            (availableWidth - BOSS_RAIL_GAP)
                / (BOSS_BUTTON_SIZE + BOSS_RAIL_GAP)))
    for index, encounter in ipairs(raid.encounters) do
        local button = self.bossButtons[index]
        if not button then
            button = self:CreateBossRailButton(index)
            self.bossButtons[index] = button
        end
        button:ClearAllPoints()
        local gridIndex = index - 1
        local column = gridIndex % columns
        local row = math.floor(gridIndex / columns)
        button:SetPoint(
            "TOPLEFT", self.bossRail, "TOPLEFT",
            BOSS_RAIL_GAP
                + (column * (BOSS_BUTTON_SIZE + BOSS_RAIL_GAP)),
            -BOSS_RAIL_GAP
                - (row * (BOSS_BUTTON_SIZE + BOSS_RAIL_GAP)))
        button.encounterIndex = index
        button.encounterName = encounter.name
        button.selected = index == self.db.activeEncounter
        button.currentBoss = index == currentBossIndex
        button.CurrentDot:SetShown(button.currentBoss)
        local icon = encounter.icon or raid.icon
        local spellID = encounter.spellIcon
        if spellID then
            local spellTexture
            if C_Spell and C_Spell.GetSpellTexture then
                spellTexture = C_Spell.GetSpellTexture(spellID)
            elseif GetSpellTexture then
                spellTexture = GetSpellTexture(spellID)
            end
            icon = spellTexture or icon
        end
        button.Icon:SetTexture(
            icon or "Interface\\Icons\\INV_Sword_27")
        button.Icon:SetDesaturated(not button.selected)
        button.Icon:SetAlpha(button.selected and 1 or .62)
        if button.selected then
            button.baseColor = { .035, .14, .21, .98 }
            button.baseBorder = { unpack(ACCENT) }
            button:SetBackdropColor(unpack(button.baseColor))
            button:SetBackdropBorderColor(unpack(button.baseBorder))
            button.ActiveBar:Show()
            button.SelectionGlow:Show()
        else
            button.baseColor = { .035, .052, .07, .98 }
            button.baseBorder = { unpack(BORDER) }
            button:SetBackdropColor(unpack(button.baseColor))
            button:SetBackdropBorderColor(unpack(button.baseBorder))
            button.ActiveBar:Hide()
            button.SelectionGlow:Hide()
        end
        button:Show()
    end
    for index = #raid.encounters + 1, #self.bossButtons do
        self.bossButtons[index]:Hide()
    end
    local rows = math.ceil(#raid.encounters / columns)
    self.bossRail:SetHeight(
        BOSS_RAIL_GAP
            + (rows * (BOSS_BUTTON_SIZE + BOSS_RAIL_GAP)))
    self:LayoutAssignmentToolbar()
end

local function WeaponEnchantTooltipName(unit, slot, fallback)
    if C_TooltipInfo and C_TooltipInfo.GetInventoryItem then
        local tooltip = C_TooltipInfo.GetInventoryItem(unit, slot)
        for index, line in ipairs(tooltip and tooltip.lines or {}) do
            local text = line.leftText
            local color = line.leftColor
            if index > 1 and text and text ~= ""
                and color and color.g and color.r and color.b
                and color.g > color.r * 1.25
                and color.g > color.b * 1.15
            then
                return text
            end
        end
    end
    return fallback
end

local function AddWeaponEnchantDetail(
    found, unit, slot, enchantID, handLabel)
    local enchantName = WeaponEnchantTooltipName(
        unit, slot, handLabel .. " weapon enhancement")
    local normalizedName = enchantName and enchantName:lower() or ""
    -- This readiness column is for raid-prep consumables plus the Shaman's
    -- own Windfury Weapon imbue. The temporary effect supplied by Windfury
    -- Totem and unrelated class effects must not satisfy this check.
    local isWeaponConsumable =
        normalizedName:find(" oil", 1, true)
        or normalizedName:find("sharpening stone", 1, true)
        or normalizedName:find("weightstone", 1, true)
        or normalizedName:find("weapon coating", 1, true)
        or (
            normalizedName:find("windfury", 1, true)
            and not normalizedName:find("totem", 1, true))
    if not isWeaponConsumable then
        return false
    end
    local details = found.details.weapon or {}
    found.details.weapon = details
    details[#details + 1] = {
        enchantID = enchantID,
        icon = GetInventoryItemTexture
            and GetInventoryItemTexture(unit, slot)
            or READY_CHECK_COLUMNS[#READY_CHECK_COLUMNS - 1].icon,
        name = enchantName,
        hand = slot == 16 and "MAIN" or "OFF",
        inventoryUnit = unit,
        inventorySlot = slot,
    }
    return true
end

local function ScanReadyCheckAuras(unit)
    if not unit or not UnitExists(unit) then return nil end
    local found = { details = {} }
    for index = 1, 60 do
        local spellID, icon, auraName
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            local aura =
                C_UnitAuras.GetAuraDataByIndex(unit, index, "HELPFUL")
            if not aura then break end
            spellID, icon, auraName = aura.spellId, aura.icon, aura.name
        elseif UnitBuff then
            local name, texture, _, _, _, _, _, _, _, id =
                UnitBuff(unit, index)
            if not name then break end
            spellID, icon, auraName = id, texture, name
        end
        if spellID
            and (not issecretvalue or not issecretvalue(spellID))
        then
            local matches = READY_CHECK_BY_SPELL[spellID]
            if not matches and icon == 136000 then
                matches = READY_CHECK_FOOD_MATCHES
            end
            for _, column in ipairs(matches or {}) do
                found[column.key] = true
                local details = found.details[column.key] or {}
                found.details[column.key] = details
                local duplicate
                for _, detail in ipairs(details) do
                    if detail.spellID == spellID then
                        duplicate = true
                        break
                    end
                end
                if not duplicate then
                    details[#details + 1] = {
                        spellID = spellID,
                        icon = icon or column.icon,
                        name = auraName or column.label,
                        unit = unit,
                        auraIndex = index,
                        filter = "HELPFUL",
                    }
                end
            end
        end
    end
    if UnitIsUnit and UnitIsUnit(unit, "player") then
        if GetWeaponEnchantInfo then
            local mainHand, _, _, mainHandID,
                offHand, _, _, offHandID =
                GetWeaponEnchantInfo()
            local weaponConsumable
            if mainHand then
                weaponConsumable =
                    AddWeaponEnchantDetail(
                        found, unit, 16, mainHandID, "Main-hand")
                    or weaponConsumable
            end
            if offHand then
                weaponConsumable =
                    AddWeaponEnchantDetail(
                        found, unit, 17, offHandID, "Off-hand")
                    or weaponConsumable
            end
            found.weapon = weaponConsumable or false
        end
    end
    return found
end

function Raid:GetReadyCheckAuras(unit, force)
    if not unit then return nil end
    self.readyCheckAuraCache = self.readyCheckAuraCache or {}
    local now = GetTime and GetTime() or 0
    local cached = self.readyCheckAuraCache[unit]
    if not force and cached and now - cached.updatedAt < 5 then
        return cached.checks
    end
    local checks = ScanReadyCheckAuras(unit)
    self.readyCheckAuraCache[unit] = {
        checks = checks,
        updatedAt = now,
    }
    return checks
end

function Raid:BroadcastReadyCheckStatus()
    if not self.QueueSync or not IsInGroup or not IsInGroup() then return end
    local checks = self:GetReadyCheckAuras("player", true)
    if not checks then return end
    local mask = 0
    for index, column in ipairs(READY_CHECK_COLUMNS) do
        if checks[column.key] then
            mask = mask + (2 ^ (index - 1))
        end
    end
    local weaponDetails = checks.details
        and checks.details.weapon or {}
    local mainHand, offHand
    for _, detail in ipairs(weaponDetails) do
        if detail.hand == "MAIN" then
            mainHand = detail
        elseif detail.hand == "OFF" then
            offHand = detail
        end
    end
    self:QueueSync("CHECK", {
        UnitName("player") or "", mask,
        mainHand and mainHand.name or "",
        mainHand and mainHand.icon or "",
        offHand and offHand.name or "",
        offHand and offHand.icon or "",
    })
end

function Raid:ReceiveReadyCheckStatus(
    name, mask, mainHandName, mainHandIcon, offHandName, offHandIcon)
    if not name or name == "" then return end
    mask = tonumber(mask) or 0
    self.readyCheckPeerData = self.readyCheckPeerData or {}
    local shortName = name:match("^[^-]+") or name
    local checks = self.readyCheckPeerData[name]
        or self.readyCheckPeerData[shortName]
        or { details = {} }
    checks.details = checks.details or {}
    for index, column in ipairs(READY_CHECK_COLUMNS) do
        if column.key ~= "durability" then
            checks[column.key] =
                math.floor(mask / (2 ^ (index - 1))) % 2 == 1
        end
    end
    if checks.weapon then
        local weaponDetails = {}
        local function AddPeerWeapon(enchantName, icon, handLabel)
            if not enchantName or enchantName == "" then return end
            weaponDetails[#weaponDetails + 1] = {
                name = enchantName,
                icon = tonumber(icon)
                    or READY_CHECK_COLUMNS[
                        #READY_CHECK_COLUMNS - 1].icon,
                handLabel = handLabel,
            }
        end
        AddPeerWeapon(mainHandName, mainHandIcon, "Main-hand")
        AddPeerWeapon(offHandName, offHandIcon, "Off-hand")
        if #weaponDetails > 0 then
            checks.details.weapon = weaponDetails
        end
    end
    self.readyCheckPeerData[name] = checks
    self.readyCheckPeerData[shortName] = checks
    self:ScheduleReadyCheckRefresh()
end

function Raid:ReceiveLibDurability(percent, broken, sender)
    if not sender or sender == "" then return end
    percent = math.max(
        0, math.min(100, math.floor((tonumber(percent) or 0) + .5)))
    self.readyCheckPeerData = self.readyCheckPeerData or {}
    local shortName = sender:match("^[^-]+") or sender
    local checks = self.readyCheckPeerData[sender]
        or self.readyCheckPeerData[shortName]
        or { details = {} }
    checks.details = checks.details or {}
    checks.durabilityPercent = percent
    checks.durability = percent >= 30
    checks.brokenItems = math.max(0, tonumber(broken) or 0)
    checks.durabilitySource = "LIB"
    self.readyCheckPeerData[sender] = checks
    self.readyCheckPeerData[shortName] = checks
    self:ScheduleReadyCheckRefresh()
end

function Raid:InitializeLibDurability()
    if self.libDurability then return end
    local library = LibStub
        and LibStub:GetLibrary("LibDurability", true)
    if not library then return end
    self.libDurability = library
    library:Register(self, "ReceiveLibDurability")
end

function Raid:RequestGroupDurability()
    self:InitializeLibDurability()
    if self.libDurability then
        self.libDurability:RequestDurability()
    end
end

function Raid:ScheduleReadyCheckRefresh()
    if self.readyCheckRefreshPending then return end
    local popupShown = self.readyCheckWindow
        and self.readyCheckWindow:IsShown()
    local embeddedShown = self.raidStatusView
        and self.raidStatusView:IsShown()
    if not popupShown and not embeddedShown then return end
    self.readyCheckRefreshPending = true
    if C_Timer and C_Timer.After then
        C_Timer.After(.10, function()
            Raid.readyCheckRefreshPending = nil
            if Raid.readyCheckWindow
                and Raid.readyCheckWindow:IsShown() then
                Raid:RefreshReadyCheckWindow()
            end
            if Raid.raidStatusView
                and Raid.raidStatusView:IsShown() then
                Raid:RefreshReadyCheckWindow(Raid.raidStatusView)
            end
        end)
    else
        self.readyCheckRefreshPending = nil
        if popupShown then self:RefreshReadyCheckWindow() end
        if embeddedShown then
            self:RefreshReadyCheckWindow(self.raidStatusView)
        end
    end
end

function Raid:CreateReadyCheckWindow()
    if self.readyCheckWindow then return self.readyCheckWindow end
    local saved = self.db.readyCheck
    local frame = Panel(UIParent)
    PixelSetSize(frame, 730, 120)
    frame:SetPoint(
        saved.point or "CENTER", UIParent,
        saved.point or "CENTER", saved.x or 0, saved.y or 120)
    -- Stay above the LunaRaids workspace without covering Blizzard's
    -- ready-check confirmation dialog.
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(200)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint(1)
        Raid.db.readyCheck.point = point
        Raid.db.readyCheck.x, Raid.db.readyCheck.y = x, y
    end)
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then self:Hide() end
    end)

    frame.Header = frame:CreateTexture(nil, "ARTWORK")
    frame.Header:SetTexture(WHITE)
    frame.Header:SetPoint("TOPLEFT", 1, -1)
    frame.Header:SetPoint("TOPRIGHT", -1, -1)
    frame.Header:SetHeight(34)
    frame.Header:SetVertexColor(.025, .075, .105, .99)
    frame.Icon = frame:CreateTexture(nil, "OVERLAY")
    frame.Icon:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
    PixelSetSize(frame.Icon, 21, 21)
    frame.Icon:SetPoint("TOPLEFT", 10, -7)
    frame.Title = Font(frame, 12, "text", "READY CHECK")
    frame.Title:SetPoint("LEFT", frame.Icon, "RIGHT", 7, 0)
    frame.Timer = Font(frame, 10, "accent", "")
    frame.Timer:SetPoint("LEFT", frame.Title, "RIGHT", 7, 0)
    frame.Close = CreateFrame(
        "Button", nil, frame, "UIPanelCloseButton")
    frame.Close:SetPoint("TOPRIGHT", -2, -2)
    frame.Close:SetScript("OnClick", function() frame:Hide() end)
    frame.FadeOut = frame:CreateAnimationGroup()
    local fade = frame.FadeOut:CreateAnimation("Alpha")
    fade:SetFromAlpha(1)
    fade:SetToAlpha(0)
    -- Keep the completed results readable; the old sub-second fade made the
    -- window feel as though it disappeared immediately after the check.
    fade:SetDuration(1.8)
    fade:SetSmoothing("OUT")
    frame.FadeOut:SetScript("OnFinished", function()
        frame.dismissPending = nil
        frame.dismissHovered = nil
        frame:Hide()
        frame:SetAlpha(1)
    end)

    frame.Summary = Font(frame, 10, "muted", "")
    frame.Summary:SetPoint("TOPRIGHT", -48, -12)
    frame.Summary:SetJustifyH("RIGHT")
    frame.Hint = Font(
        frame, 9, "muted",
        "Right-click to dismiss")
    frame.Hint:Hide()
    frame.HeaderY = -37
    -- Rows are children of the scroll area, which is inset from the popup.
    -- Offset the popup headers by the same amount so both grids share one
    -- physical column origin.
    frame.HeaderGridOffset = 7
    frame.HeaderBackground =
        frame:CreateTexture(nil, "BACKGROUND")
    frame.HeaderBackground:SetTexture(WHITE)
    frame.HeaderBackground:SetPoint("TOPLEFT", 7, -36)
    frame.HeaderBackground:SetPoint("TOPRIGHT", -7, -36)
    frame.HeaderBackground:SetHeight(24)
    frame.HeaderBackground:SetVertexColor(.035, .105, .145, .98)
    frame.HeaderLabel = Font(frame, 9, "accent", "PLAYER / STATUS")
    frame.HeaderLabel:SetPoint("TOPLEFT", 14, -43)
    frame.Headers = {}
    for index, column in ipairs(READY_CHECK_COLUMNS) do
        local header = CreateFrame("Frame", nil, frame)
        PixelSetSize(header, 28, 22)
        header:SetPoint(
            "TOPLEFT",
            READY_CHECK_GRID_START
                + ((index - 1) * READY_CHECK_COLUMN_WIDTH),
            frame.HeaderY)
        header.Background = header:CreateTexture(nil, "BACKGROUND")
        header.Background:SetAllPoints()
        header.Background:SetTexture(WHITE)
        header.Background:SetVertexColor(
            index % 2 == 0 and .045 or .055,
            index % 2 == 0 and .14 or .16,
            index % 2 == 0 and .19 or .215, 1)
        header.Icon = header:CreateTexture(nil, "ARTWORK")
        header.Icon:SetTexture(column.icon)
        PixelSetSize(header.Icon, 17, 17)
        header.Icon:SetPoint("CENTER")
        header:EnableMouse(true)
        header:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(column.label)
            GameTooltip:Show()
        end)
        header:SetScript(
            "OnLeave", function() GameTooltip:Hide() end)
        frame.Headers[index] = header
    end
    frame.Scroll, frame.Content = CreateScrollArea(frame)
    frame.Scroll:SetPoint("TOPLEFT", 7, -61)
    frame.Scroll:SetPoint("BOTTOMRIGHT", -7, 7)
    frame.Content:SetWidth(714)
    frame.Rows = {}
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.auraRefreshElapsed =
            (self.auraRefreshElapsed or 0) + elapsed
        self.timerElapsed = (self.timerElapsed or 0) + elapsed
        if self.timerElapsed < .1 then return end
        self.timerElapsed = 0
        if self.auraRefreshElapsed >= 5 then
            self.auraRefreshElapsed = 0
            Raid:RefreshReadyCheckWindow()
        end
        if self.dismissPending then
            local hovering = self:IsMouseOver()
            if hovering then
                if not self.dismissHovered then
                    self.dismissHovered = true
                    self.FadeOut:Stop()
                    self:SetAlpha(1)
                end
            elseif self.dismissHovered then
                -- Give the user another complete reading period after they
                -- move away instead of fading immediately on mouse leave.
                self.dismissHovered = nil
                self.dismissAt = GetTime()
                    + (Raid.db.readyCheck.holdDuration or 15)
            elseif GetTime() >= (self.dismissAt or 0)
                and not self.FadeOut:IsPlaying()
            then
                self.FadeOut:Play()
            end
        end
        if self.endTime then
            local remaining = math.max(
                0, math.ceil(self.endTime - GetTime()))
            self.Timer:SetText(("· %ds"):format(remaining))
        else
            self.Timer:SetText("")
        end
    end)
    frame:Hide()
    self.readyCheckWindow = frame
    return frame
end

function Raid:CreateReadyCheckRow(index, frame)
    frame = frame or self:CreateReadyCheckWindow()
    local row = BackdropFrame("Frame", nil, frame.Content)
    PixelSetSize(row, 714, 20)
    row:SetBackdrop({
        bgFile = WHITE,
    })
    row:SetBackdropColor(.035, .055, .072, .97)
    row.Status = row:CreateTexture(nil, "ARTWORK")
    PixelSetSize(row.Status, 16, 16)
    row.Status:SetPoint("LEFT", 6, 0)
    row.Name = Font(row, 10, "text", "")
    if frame.Embedded then
        row.Status:Hide()
        row.Name:SetPoint("LEFT", 8, 0)
        row.Name:SetWidth(152)
    else
        row.Name:SetPoint("LEFT", row.Status, "RIGHT", 6, 0)
        row.Name:SetWidth(126)
    end
    row.Name:SetJustifyH("LEFT")
    row.Role = row:CreateTexture(nil, "ARTWORK")
    row.Role:SetTexture(ROLE_TEXTURE)
    PixelSetSize(row.Role, 15, 15)
    row.Role:SetPoint("LEFT", 172, 0)
    row.Checks = {}
    for columnIndex, column in ipairs(READY_CHECK_COLUMNS) do
        local cell = CreateFrame("Frame", nil, row)
        PixelSetSize(cell, 27, 18)
        cell:SetPoint(
            "LEFT",
            READY_CHECK_GRID_START
                + ((columnIndex - 1) * READY_CHECK_COLUMN_WIDTH),
            0)
        cell:EnableMouse(true)
        cell.Icons = {}
        cell.Value = Font(cell, 9, "text", "")
        cell.Value:SetPoint("CENTER")
        cell.Value:Hide()
        cell.Column = column
        cell:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(self.Column.label)
            if self.Column.key == "durability"
                and self.DurabilityPercent
            then
                GameTooltip:AddLine(
                    ("%d%% average equipped durability.")
                        :format(self.DurabilityPercent),
                    .90, .90, .90)
                if self.BrokenItems and self.BrokenItems > 0 then
                    GameTooltip:AddLine(
                        ("%d broken item%s."):format(
                            self.BrokenItems,
                            self.BrokenItems == 1 and "" or "s"),
                        1, .28, .28)
                end
            elseif self.Column.key == "durability" then
                GameTooltip:AddLine(
                    "No compatible addon reported this player's durability.",
                    MUTED[1], MUTED[2], MUTED[3], true)
            elseif self.Details and #self.Details > 0 then
                for _, detail in ipairs(self.Details) do
                    local name = detail.name
                    if type(name) ~= "string"
                        or issecretvalue and issecretvalue(name)
                    then
                        name = "Detected buff"
                    end
                    GameTooltip:AddLine(name, .90, .90, .90)
                end
            elseif self.Present then
                GameTooltip:AddLine(
                    "Reported by LunaRaids peer", unpack(MUTED))
            else
                GameTooltip:AddLine("Not detected", 1, .35, .35)
            end
            GameTooltip:Show()
        end)
        cell:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row.Checks[columnIndex] = cell
    end
    frame.Rows[index] = row
    return row
end

function Raid:RefreshReadyCheckWindow(frame)
    frame = frame or self.readyCheckWindow
    if not frame or not frame:IsShown() then return end
    local pending, declined, ready, waiting = {}, 0, 0, 0
    for _, player in ipairs(self.roster or {}) do
        local status = self.readyCheckStatus
            and self.readyCheckStatus[player.name]
        local checks = self:GetReadyCheckAuras(player.unit)
        local peerChecks = self.readyCheckPeerData
            and (
                self.readyCheckPeerData[player.name]
                or self.readyCheckPeerData[
                    player.name:match("^[^-]+") or player.name])
        if peerChecks then
            checks = checks or { details = {} }
            checks.details = checks.details or {}
            for _, column in ipairs(READY_CHECK_COLUMNS) do
                if peerChecks[column.key] then
                    checks[column.key] = true
                end
            end
            for key, details in pairs(peerChecks.details or {}) do
                if not checks.details[key]
                    or #checks.details[key] == 0
                then
                    checks.details[key] = details
                end
            end
            if peerChecks.durabilityPercent then
                checks.durabilityPercent =
                    peerChecks.durabilityPercent
                checks.durabilitySource =
                    peerChecks.durabilitySource
                checks.brokenItems = peerChecks.brokenItems
            end
        end
        local consumablesOkay = checks
            and checks.food and checks.flask
        if status == true then
            ready = ready + 1
        elseif status == nil then
            waiting = waiting + 1
        end
        if status == false then declined = declined + 1 end
        pending[#pending + 1] = {
            player = player,
            declined = status == false,
            ready = status == true,
            checks = checks,
            missingConsumables =
                checks and not consumablesOkay or false,
        }
    end
    table.sort(pending, function(left, right)
        if left.declined ~= right.declined then
            return left.declined
        end
        return left.player.name < right.player.name
    end)
    local columnWidths = {}
    local gridWidth = 0
    for columnIndex, column in ipairs(READY_CHECK_COLUMNS) do
        local largest = 1
        for _, entry in ipairs(pending) do
            local details = entry.checks and entry.checks.details
                and entry.checks.details[column.key]
            largest = math.max(largest, details and #details or 0)
        end
        local minimumWidth =
            column.key == "durability" and 38
            or READY_CHECK_COLUMN_WIDTH
        columnWidths[columnIndex] = math.max(
            minimumWidth, 6 + (largest * 18))
        gridWidth = gridWidth + columnWidths[columnIndex]
    end
    local windowWidth = math.max(
        730,
        frame.Embedded and frame:GetWidth() or 0,
        READY_CHECK_GRID_START + gridWidth + 12)
    local gridStart = frame.Embedded
        and math.max(
            READY_CHECK_GRID_START,
            windowWidth - gridWidth - 24)
        or READY_CHECK_GRID_START
    local layoutSignature =
        windowWidth .. ":" .. gridStart .. ":"
            .. table.concat(columnWidths, ",")
    if frame.LayoutSignature ~= layoutSignature then
        frame.LayoutSignature = layoutSignature
        if not frame.Embedded then frame:SetWidth(windowWidth) end
        frame.Content:SetWidth(windowWidth - 16)
        local headerX = gridStart + (frame.HeaderGridOffset or 0)
        for columnIndex, header in ipairs(frame.Headers) do
            header:ClearAllPoints()
            header:SetPoint(
                "TOPLEFT", headerX, frame.HeaderY or -57)
            header:SetWidth(columnWidths[columnIndex])
            headerX = headerX + columnWidths[columnIndex]
        end
    end
    if frame.Embedded then
        frame.Summary:SetText("")
        frame.Summary:Hide()
    else
        frame.Summary:SetText(
            ("|cff55dd77%d ready|r  ·  |cffffcc44%d waiting|r"
                .. "  ·  |cffff5555%d not ready|r"):format(
                ready, waiting, declined))
        frame.Summary:Show()
    end
    if frame.Hint then
        frame.Hint:Show()
    end
    for index, entry in ipairs(pending) do
        local row = frame.Rows[index]
            or self:CreateReadyCheckRow(index, frame)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -((index - 1) * 21))
        if row.LayoutSignature ~= layoutSignature then
            row.LayoutSignature = layoutSignature
            row:SetWidth(windowWidth - 16)
        end
        SetClassText(
            row.Name, entry.player.name, entry.player.class)
        row:SetBackdropColor(
            GetClassRowColor(entry.player.class, index % 2 == 0))
        row.Status:SetTexture(
            entry.declined
                and "Interface\\RaidFrame\\ReadyCheck-NotReady"
                or entry.ready
                    and "Interface\\RaidFrame\\ReadyCheck-Ready"
                or "Interface\\RaidFrame\\ReadyCheck-Waiting")
        local role = ROLE_COORDS[entry.player.role]
        if role then
            row.Role:SetTexCoord(unpack(role))
            row.Role:Show()
        else
            row.Role:Hide()
        end
        row:SetAlpha(entry.player.online == false and .35 or 1)
        local cellX = gridStart
        for columnIndex, column in ipairs(READY_CHECK_COLUMNS) do
            local present = entry.checks
                and entry.checks[column.key]
            local cell = row.Checks[columnIndex]
            local details = entry.checks and entry.checks.details
                and entry.checks.details[column.key]
            cell.Present, cell.Details = present, details
            if cell.LayoutSignature ~= layoutSignature then
                cell.LayoutSignature = layoutSignature
                cell:ClearAllPoints()
                cell:SetPoint("LEFT", cellX, 0)
                cell:SetWidth(columnWidths[columnIndex])
            end
            if column.key == "durability" then
                local percent = entry.checks
                    and entry.checks.durabilityPercent
                cell.DurabilityPercent = percent
                cell.DurabilitySource = entry.checks
                    and entry.checks.durabilitySource
                cell.BrokenItems = entry.checks
                    and entry.checks.brokenItems
                for _, iconFrame in ipairs(cell.Icons) do
                    iconFrame:Hide()
                end
                cell.Value:SetText(
                    percent and ("%d%%"):format(percent) or "?")
                if not percent then
                    cell.Value:SetTextColor(unpack(MUTED))
                elseif percent < 30 then
                    cell.Value:SetTextColor(1, .24, .24, 1)
                elseif percent < 60 then
                    cell.Value:SetTextColor(1, .72, .20, 1)
                else
                    cell.Value:SetTextColor(.34, .86, .48, 1)
                end
                cell.Value:Show()
            else
                cell.DurabilityPercent = nil
                cell.DurabilitySource = nil
                cell.BrokenItems = nil
                cell.Value:Hide()
                local iconCount = details and #details or 0
                local visibleIcons = math.max(1, iconCount)
                local iconGroupWidth =
                    (visibleIcons * 15)
                        + (math.max(0, visibleIcons - 1) * 3)
                local iconStart =
                    (columnWidths[columnIndex] - iconGroupWidth) / 2
                for iconIndex = 1, visibleIcons do
                local iconFrame = cell.Icons[iconIndex]
                if not iconFrame then
                    iconFrame = CreateFrame("Frame", nil, cell)
                    PixelSetSize(iconFrame, 15, 15)
                    iconFrame:EnableMouse(true)
                    iconFrame.Texture =
                        iconFrame:CreateTexture(nil, "ARTWORK")
                    iconFrame.Texture:SetAllPoints()
                    iconFrame:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_TOP")
                        local detail = self.Detail
                        local shown
                        if detail and detail.inventoryUnit
                            and detail.inventorySlot
                            and GameTooltip.SetInventoryItem
                        then
                            shown = pcall(
                                GameTooltip.SetInventoryItem,
                                GameTooltip,
                                detail.inventoryUnit,
                                detail.inventorySlot)
                        elseif detail and detail.unit and detail.auraIndex
                            and GameTooltip.SetUnitBuff
                        then
                            local currentIndex = detail.auraIndex
                            if detail.spellID and C_UnitAuras
                                and C_UnitAuras.GetAuraDataByIndex
                            then
                                for auraIndex = 1, 60 do
                                    local aura =
                                        C_UnitAuras.GetAuraDataByIndex(
                                            detail.unit, auraIndex,
                                            detail.filter or "HELPFUL")
                                    if not aura then break end
                                    if aura.spellId == detail.spellID then
                                        currentIndex = auraIndex
                                        break
                                    end
                                end
                            end
                            shown = pcall(
                                GameTooltip.SetUnitBuff, GameTooltip,
                                detail.unit, currentIndex,
                                detail.filter or "HELPFUL")
                        end
                        if not shown and detail and detail.spellID
                            and GameTooltip.SetSpellByID
                        then
                            shown = pcall(
                                GameTooltip.SetSpellByID,
                                GameTooltip, detail.spellID)
                        end
                        if not shown then
                            GameTooltip:SetText(self.Column.label)
                            if detail and detail.name then
                                GameTooltip:AddLine(
                                    detail.name, .90, .90, .90)
                            else
                                GameTooltip:AddLine(
                                    self.Present and "Detected"
                                        or "Not detected",
                                    self.Present and .35 or 1,
                                    self.Present and .85 or .35,
                                    self.Present and .45 or .35)
                            end
                        end
                        GameTooltip:Show()
                    end)
                    iconFrame:SetScript(
                        "OnLeave", function() GameTooltip:Hide() end)
                    cell.Icons[iconIndex] = iconFrame
                end
                iconFrame:ClearAllPoints()
                iconFrame:SetPoint(
                    "LEFT",
                    iconStart + ((iconIndex - 1) * 18), 0)
                iconFrame.Detail = iconCount > 0
                    and details[iconIndex] or nil
                iconFrame.Column = column
                iconFrame.Present = present
                iconFrame.Texture:SetTexture(
                    iconCount > 0 and details[iconIndex].icon
                        or not entry.checks
                            and "Interface\\RaidFrame\\ReadyCheck-Waiting"
                        or present
                            and column.icon
                            or "Interface\\RaidFrame\\ReadyCheck-NotReady")
                iconFrame.Texture:SetAlpha(present and 1 or .68)
                iconFrame:Show()
                end
                for iconIndex = visibleIcons + 1, #cell.Icons do
                    cell.Icons[iconIndex]:Hide()
                end
            end
            cellX = cellX + columnWidths[columnIndex]
        end
        row:Show()
    end
    for index = #pending + 1, #frame.Rows do
        frame.Rows[index]:Hide()
    end
    frame.Content:SetHeight(math.max(1, #pending * 21))
    if not frame.Embedded then
        frame:SetHeight(
            math.min(560, math.max(92, 71 + (#pending * 21))))
        FitAndClampToScreen(frame)
    end
    frame.Scroll:Show()
    for _, header in ipairs(frame.Headers) do header:Show() end
    if frame.Scroll.UpdateScrollbar then
        frame.Scroll:UpdateScrollbar()
    end
end

function Raid:CreateRaidStatusView()
    if self.raidStatusView then return self.raidStatusView end
    local frame = CreateFrame("Frame", nil, self.assignmentPanel)
    frame:SetPoint("TOPLEFT", 0, 0)
    frame:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.Embedded = true
    frame.HeaderY = -1
    frame.Summary = Font(frame, 10, "muted", "")
    frame.Summary:SetPoint("TOPLEFT", 4, -5)
    frame.ActionBar = CreateFrame("Frame", nil, self.frame)
    frame.ActionBar:SetPoint("BOTTOMLEFT", 12, 8)
    frame.ActionBar:SetPoint("BOTTOMRIGHT", -24, 8)
    frame.ActionBar:SetHeight(40)
    frame.ActionBar:SetFrameLevel(self.frame:GetFrameLevel() + 8)
    frame.Actions = {}
    local actionEntries = {
        {
            label = "READY CHECK",
            icon = "Interface\\RaidFrame\\ReadyCheck-Ready",
            title = "Ready Check",
            detail = "Start Blizzard's raid ready check.",
            run = function() Raid:StartReadyCheck() end,
            rightRun = function()
                Raid:ShowPinnedReadyCheckWindow()
            end,
        },
        {
            label = "ROLE CHECK",
            icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
            title = "Role Check",
            detail = "Ask the raid to confirm combat roles.",
            run = function() Raid:StartRoleCheck() end,
        },
        {
            label = "PULL 10",
            icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
            title = "Pull Timer",
            detail = "Start a 10-second pull countdown.",
            run = function() Raid:StartPullCountdown(10) end,
        },
        {
            label = "BREAK 5",
            icon = "Interface\\Icons\\INV_Drink_05",
            title = "Break Timer",
            detail = "Announce and start a five-minute break.",
            run = function() Raid:StartBreakTimer(5) end,
            rightRun = function(button)
                ShowSelectionMenu(
                    button,
                    {
                        { 5, "5 minutes" },
                        { 10, "10 minutes" },
                        { 15, "15 minutes" },
                    },
                    5,
                    function(minutes)
                        Raid:StartBreakTimer(minutes)
                    end,
                    156)
            end,
            rightDetail =
                "\nRight-click to choose 5, 10, or 15 minutes.",
        },
    }
    local previous
    for index, entry in ipairs(actionEntries) do
        local run, rightRun = entry.run, entry.rightRun
        local button = Button(frame.ActionBar, entry.label, 126, 28)
        if previous then
            button:SetPoint("LEFT", previous, "RIGHT", 5, 0)
        else
            button:SetPoint("LEFT", 0, 0)
        end
        AddButtonIcon(button, entry.icon, 16)
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        button:SetScript("OnClick", function(_, mouseButton)
            if mouseButton == "RightButton" and rightRun then
                rightRun(button)
            else
                run()
            end
        end)
        AddButtonTooltip(
            button, entry.title,
            entry.detail .. (rightRun
                and (entry.rightDetail
                    or "\nRight-click to pin the latest results.")
                or ""))
        if index == 1 then StyleButton(button, "primary") end
        frame.Actions[index] = button
        previous = button
    end
    self.statusFooterActionButtons = frame.Actions
    for _, button in ipairs(frame.Actions) do
        self.footerActionButtons[#self.footerActionButtons + 1] = button
    end
    frame.ActionBar:Hide()
    frame.HeaderBackground =
        frame:CreateTexture(nil, "BACKGROUND")
    frame.HeaderBackground:SetTexture(WHITE)
    frame.HeaderBackground:SetPoint("TOPLEFT", 0, 0)
    frame.HeaderBackground:SetPoint("TOPRIGHT", 0, 0)
    frame.HeaderBackground:SetHeight(24)
    frame.HeaderBackground:SetVertexColor(.035, .105, .145, .98)
    frame.HeaderLabel = Font(frame, 9, "accent", "PLAYER")
    frame.HeaderLabel:SetPoint("TOPLEFT", 7, -7)
    frame.Headers = {}
    for index, column in ipairs(READY_CHECK_COLUMNS) do
        local header = CreateFrame("Frame", nil, frame)
        PixelSetSize(header, 28, 22)
        header:SetPoint(
            "TOPLEFT",
            READY_CHECK_GRID_START
                + ((index - 1) * READY_CHECK_COLUMN_WIDTH),
            frame.HeaderY)
        header.Background = header:CreateTexture(nil, "BACKGROUND")
        header.Background:SetAllPoints()
        header.Background:SetTexture(WHITE)
        header.Background:SetVertexColor(
            index % 2 == 0 and .045 or .055,
            index % 2 == 0 and .14 or .16,
            index % 2 == 0 and .19 or .215, 1)
        header.Icon = header:CreateTexture(nil, "ARTWORK")
        header.Icon:SetTexture(column.icon)
        PixelSetSize(header.Icon, 17, 17)
        header.Icon:SetPoint("CENTER")
        header:EnableMouse(true)
        header:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(column.label)
            GameTooltip:Show()
        end)
        header:SetScript(
            "OnLeave", function() GameTooltip:Hide() end)
        frame.Headers[index] = header
    end
    frame.Scroll, frame.Content = CreateScrollArea(frame)
    frame.Scroll:SetPoint("TOPLEFT", 0, -24)
    frame.Scroll:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.Content:SetWidth(714)
    frame.Rows = {}
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.refreshElapsed = (self.refreshElapsed or 0) + elapsed
        if self.refreshElapsed >= 5 then
            self.refreshElapsed = 0
            Raid:RefreshReadyCheckWindow(self)
        end
    end)
    frame:Hide()
    self.raidStatusView = frame
    return frame
end

function Raid:RefreshRaidStatusView()
    local frame = self:CreateRaidStatusView()
    self.readyCheckStatus = self.readyCheckStatus or {}
    self.readyCheckPeerData = self.readyCheckPeerData or {}
    self.readyCheckAuraCache = self.readyCheckAuraCache or {}
    frame:Show()
    frame.ActionBar:Show()
    local canEdit = self:IsLocalRaidEditor()
    for _, button in ipairs(frame.Actions or {}) do
        button:SetEnabled(canEdit)
        button:SetAlpha(canEdit and 1 or .4)
    end
    self.assignmentTitle:SetText("RAID STATUS")
    self:RefreshWorkspaceNavigation()
    self:BroadcastReadyCheckStatus()
    self:RequestGroupDurability()
    self:RefreshReadyCheckWindow(frame)
end

function Raid:ShowReadyCheckWindow(timeout, simulated, caller)
    if self.db.readyCheck.showWindow == false then return end
    self:UpdateRoster()
    local frame = self:CreateReadyCheckWindow()
    self.readyCheckSequence = (self.readyCheckSequence or 0) + 1
    self.readyCheckStatus = {}
    self.readyCheckPeerData = {}
    self.readyCheckAuraCache = {}
    self:RequestGroupDurability()
    frame.endTime = GetTime() + (tonumber(timeout) or 35)
    local callerName = caller
    if not callerName or callerName == "" then
        callerName = simulated and (
            GetUnitName("player", true) or UnitName("player"))
            or nil
    end
    if callerName then
        local callerShort =
            callerName:match("^[^-]+") or callerName
        for _, player in ipairs(self.roster or {}) do
            local playerShort =
                player.name:match("^[^-]+") or player.name
            if player.name == callerName or playerShort == callerShort then
                self.readyCheckStatus[player.name] = true
                break
            end
        end
    end
    frame.Title:SetText(
        simulated and "READY CHECK · SIMULATION"
            or callerName and ("READY CHECK · " .. callerName)
            or "READY CHECK")
    frame.FadeOut:Stop()
    frame.dismissPinned = nil
    frame.dismissPending = nil
    frame.dismissHovered = nil
    frame.dismissAt = nil
    frame:SetAlpha(1)
    frame:Show()
    self:BroadcastReadyCheckStatus()
    self:RefreshReadyCheckWindow()
end

function Raid:ShowPinnedReadyCheckWindow()
    self:UpdateRoster()
    local frame = self:CreateReadyCheckWindow()
    frame.FadeOut:Stop()
    frame:SetAlpha(1)
    frame.dismissPinned = true
    frame.dismissPending = nil
    frame.dismissHovered = nil
    frame.dismissAt = nil
    frame.endTime = nil
    if not self.readyCheckStatus then
        self.readyCheckStatus = {}
        self.readyCheckPeerData = {}
        frame.Title:SetText("READY CHECK RESULTS")
    end
    frame:Show()
    self:RefreshReadyCheckWindow()
end

function Raid:RaiseBlizzardReadyCheckDialog()
    local dialog = _G.ReadyCheckFrame or _G.ReadyCheckListenerFrame
    if not dialog then return end
    if dialog.SetFrameStrata then
        pcall(dialog.SetFrameStrata, dialog, "FULLSCREEN_DIALOG")
    end
    if dialog.SetFrameLevel then
        pcall(dialog.SetFrameLevel, dialog, 500)
    end
    if dialog.Raise then
        pcall(dialog.Raise, dialog)
    end
end

function Raid:HandleReadyCheckStarted(_, initiator, timeout)
    -- Release any LunaRaids full-screen menu overlays before Blizzard opens
    -- its confirmation dialog.
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
    if not self:IsLocalRaidEditor() then
        self:RequestGroupDurability()
        return
    end
    local caller
    if not (issecretvalue and issecretvalue(initiator))
        and type(initiator) == "string" and initiator ~= ""
    then
        -- Classic supplies the initiator as a GUID on some clients rather
        -- than as a unit token. Resolve that GUID through the current roster.
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
    frame.Title:SetText("READY CHECK COMPLETE")
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
        -- Repair-all can fire several inventory updates before every slot
        -- reports its final durability.
        C_Timer.After(.35, Refresh)
    else
        Refresh()
    end
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
    bar:SetClampedToScreen(true)
    bar:SetMovable(true)
    bar:EnableMouse(true)

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
        GameTooltip:SetText("Raid Tools")
        GameTooltip:AddLine(
            "Drag to move. Right-click to reset position.",
            MUTED[1], MUTED[2], MUTED[3], true)
        GameTooltip:Show()
    end)
    bar.Handle:HookScript(
        "OnLeave", function() GameTooltip:Hide() end)
    bar.Handle.Icon = bar.Handle:CreateTexture(nil, "ARTWORK")
    bar.Handle.Icon:SetTexture("Interface\\Icons\\INV_BannerPVP_02")
    PixelSetSize(bar.Handle.Icon, 22, 22)
    bar.Handle.Icon:SetPoint("LEFT", 8, 0)
    bar.Handle.Title = Font(bar.Handle, 9, "accent", "RAID\nTOOLS")
    bar.Handle.Title:SetPoint("LEFT", bar.Handle.Icon, "RIGHT", 6, 0)

    local actions = {
        {
            label = "READY",
            icon = "Interface\\RaidFrame\\ReadyCheck-Ready",
            title = "Ready Check",
            detail = "Start Blizzard's raid ready check.",
            action = function() Raid:StartReadyCheck() end,
            rightAction = function()
                Raid:ShowPinnedReadyCheckWindow()
            end,
        },
        {
            label = "ROLES",
            icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
            title = "Role Check",
            detail = "Ask the group to confirm their combat roles.",
            action = function() Raid:StartRoleCheck() end,
        },
        {
            label = "PULL 10",
            icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
            title = "Pull Timer",
            detail = "Start a 10-second group countdown.",
            action = function() Raid:StartPullCountdown(10) end,
        },
        {
            label = "BREAK 5",
            icon = "Interface\\Icons\\INV_Drink_05",
            title = "Break Timer",
            detail = "Announce and start a five-minute break.",
            action = function() Raid:StartBreakTimer(5) end,
            rightAction = function(button)
                ShowSelectionMenu(
                    button,
                    {
                        { 5, "5 minutes" },
                        { 10, "10 minutes" },
                        { 15, "15 minutes" },
                    },
                    5,
                    function(minutes)
                        Raid:StartBreakTimer(minutes)
                    end,
                    156)
            end,
            rightDetail =
                "\nRight-click to choose 5, 10, or 15 minutes.",
        },
        {
            label = "ASSIGN",
            icon = "Interface\\Icons\\INV_Misc_Note_05",
            title = "Raid Assignments",
            detail = "Open LunaRaids directly to the raid assignments.",
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
            button:SetPoint("LEFT", bar.Handle, "RIGHT", 4, 0)
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
                    and "\nRight-click to open and pin the latest results."
                or ""))
        if index == 1 then StyleButton(button, "primary") end
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
    bar.BossNav.Background:SetVertexColor(.018, .045, .062, .92)
    bar.BossNav.Previous = Button(bar.BossNav, "", 28, 24)
    bar.BossNav.Previous:SetPoint("LEFT", 4, -1)
    bar.BossNav.Previous.Icon =
        bar.BossNav.Previous:CreateTexture(nil, "ARTWORK")
    bar.BossNav.Previous.Icon:SetTexture(
        "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    PixelSetSize(bar.BossNav.Previous.Icon, 16, 16)
    bar.BossNav.Previous.Icon:SetPoint("CENTER")
    bar.BossNav.Previous:SetScript(
        "OnClick", function() Raid:NavigateBoss(-1) end)
    bar.BossNav.Previous.tooltipAnchorFrame = bar
    AddButtonTooltip(
        bar.BossNav.Previous, "Previous Boss",
        "Select the previous boss and set it as the current encounter.")
    bar.BossNav.Next = Button(bar.BossNav, "", 28, 24)
    bar.BossNav.Next:SetPoint("RIGHT", -4, -1)
    bar.BossNav.Next.Icon =
        bar.BossNav.Next:CreateTexture(nil, "ARTWORK")
    bar.BossNav.Next.Icon:SetTexture(
        "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    PixelSetSize(bar.BossNav.Next.Icon, 16, 16)
    bar.BossNav.Next.Icon:SetPoint("CENTER")
    bar.BossNav.Next:SetScript(
        "OnClick", function() Raid:NavigateBoss(1) end)
    bar.BossNav.Next.tooltipAnchorFrame = bar
    AddButtonTooltip(
        bar.BossNav.Next, "Next Boss",
        "Select the next boss and set it as the current encounter.")
    bar.BossNav.Name = Font(bar.BossNav, 9, "accent", "")
    bar.BossNav.Name:SetPoint(
        "LEFT", bar.BossNav.Previous, "RIGHT", 8, -1)
    bar.BossNav.Name:SetPoint(
        "RIGHT", bar.BossNav.Next, "LEFT", -8, -1)
    bar.BossNav.Name:SetJustifyH("CENTER")
    self.quickActionBar = bar
    return bar
end

function Raid:RefreshQuickActionBar()
    local bar = self:CreateQuickActionBar()
    local settings = self.db.quickBar
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
    local showBossNav = encounter
        and IsInRaid and IsInRaid()
        and self:IsLocalRaidEditor() or false
    bar:SetHeight(showBossNav and 76 or 42)
    bar.Handle:ClearAllPoints()
    bar.Handle:SetPoint("TOPLEFT", 1, -1)
    bar.Handle:SetPoint(
        "BOTTOMLEFT", 1, showBossNav and 35 or 1)
    bar.BossNav:SetShown(showBossNav)
    if showBossNav then
        bar.BossNav.Name:SetText(encounter.name:upper())
        local hasPrevious = encounterIndex > 2
        local hasNext = encounterIndex < #raid.encounters
        bar.BossNav.Previous:SetEnabled(hasPrevious)
        bar.BossNav.Next:SetEnabled(hasNext)
        bar.BossNav.Previous:SetAlpha(hasPrevious and 1 or .35)
        bar.BossNav.Next:SetAlpha(hasNext and 1 or .35)
    end
    local grouped = IsInGroup and IsInGroup()
    local raidGroup = IsInRaid and IsInRaid()
    local authorized = grouped and (
        UnitIsGroupLeader and UnitIsGroupLeader("player")
        or UnitIsGroupAssistant and UnitIsGroupAssistant("player"))
    local visibility = settings.visibility or "GROUP"
    local allowed = visibility == "ALWAYS"
        or visibility == "GROUP" and authorized
        or visibility == "RAID" and raidGroup and authorized
    if settings.hideInCombat
        and InCombatLockdown and InCombatLockdown()
    then
        allowed = false
    end
    bar:SetShown(not settings.hide and allowed or false)
end

function Raid:CreateSettingsView()
    if self.settingsView then return self.settingsView end
    local view = CreateFrame("Frame", nil, self.frame)
    view:SetPoint("TOPLEFT", 1, -46)
    view:SetPoint("BOTTOMRIGHT", -1, 1)
    view:SetFrameLevel(self.frame:GetFrameLevel() + 3)
    view.Background = view:CreateTexture(nil, "BACKGROUND")
    view.Background:SetTexture(WHITE)
    view.Background:SetAllPoints()
    view.Background:SetVertexColor(.012, .022, .031, 1)
    view.Title = Font(view, 15, "accent", "ADDON SETTINGS")
    view.Title:SetPoint("TOPLEFT", 20, -22)
    view.Title:Hide()
    view.Subtitle = Font(
        view, 10, "muted",
        "Interface, communication, and automation")
    view.Subtitle:SetPoint("TOPLEFT", 21, -50)
    view.Subtitle:Hide()
    view.GeneralTab = Button(view, "GENERAL", 126, 28)
    view.GeneralTab:SetPoint("TOPLEFT", 8, -8)
    view.AdminTab = Button(view, "RAID ADMIN", 126, 28)
    view.AdminTab:SetPoint("LEFT", view.GeneralTab, "RIGHT", 8, 0)
    view.CooldownTab = Button(view, "COOLDOWNS", 126, 28)
    view.CooldownTab:SetPoint("LEFT", view.AdminTab, "RIGHT", 8, 0)
    view.GeneralTab:SetScript("OnClick", function()
        Raid.settingsTab = "GENERAL"
        if Raid.settingsView and Raid.settingsView.Scroll then
            Raid.settingsView.Scroll:SetVerticalScroll(0)
        end
        Raid:RedrawSettingsView()
    end)
    view.AdminTab:SetScript("OnClick", function()
        Raid.settingsTab = "ADMIN"
        if Raid.settingsView and Raid.settingsView.Scroll then
            Raid.settingsView.Scroll:SetVerticalScroll(0)
        end
        Raid:RedrawSettingsView()
    end)
    view.CooldownTab:SetScript("OnClick", function()
        Raid.settingsTab = "COOLDOWNS"
        if Raid.settingsView and Raid.settingsView.Scroll then
            Raid.settingsView.Scroll:SetVerticalScroll(0)
        end
        Raid:RedrawSettingsView()
    end)
    view.Footer = CreateFrame("Frame", nil, view)
    view.Footer:SetPoint("BOTTOMLEFT", 1, 1)
    view.Footer:SetPoint("BOTTOMRIGHT", -1, 1)
    view.Footer:SetHeight(43)
    view.Footer.Background =
        view.Footer:CreateTexture(nil, "BACKGROUND")
    view.Footer.Background:SetTexture(WHITE)
    view.Footer.Background:SetAllPoints()
    view.Footer.Background:SetVertexColor(.018, .045, .062, 1)
    view.Footer.TopLine = view.Footer:CreateTexture(nil, "ARTWORK")
    view.Footer.TopLine:SetTexture(WHITE)
    view.Footer.TopLine:SetPoint("TOPLEFT")
    view.Footer.TopLine:SetPoint("TOPRIGHT")
    SetPixelHeight(view.Footer.TopLine, 1)
    view.Footer.TopLine:SetVertexColor(.12, .30, .40, 1)
    view.ResetAllSettings =
        Button(view.Footer, "RESET ALL SETTINGS", 168, 28)
    view.ResetAllSettings:SetPoint("RIGHT", -12, 0)
    StyleButton(view.ResetAllSettings, "danger")
    view.ResetAllSettings:SetScript("OnClick", function()
        StaticPopup_Show("LUNARAIDS_RESET_ALL_SETTINGS")
    end)
    AddButtonTooltip(
        view.ResetAllSettings, "Reset All Settings",
        "Restore addon options and every movable window to defaults.")
    view.Scroll, view.Content = CreateScrollArea(view)
    view.Scroll:SetPoint("TOPLEFT", 8, -44)
    view.Scroll:SetPoint("BOTTOMRIGHT", -8, 49)
    view.Content:SetWidth(math.max(1, view:GetWidth() - 28))

    local general = CreateFrame("Frame", nil, view.Content)
    general:SetPoint("TOPLEFT", 12, -8)
    general:SetPoint("TOPRIGHT", -12, -8)
    general:SetHeight(224)
    SectionHeader(general, "GENERAL")
    local interfaceCard = Panel(general)
    interfaceCard:SetPoint("TOPLEFT", 0, -40)
    interfaceCard:SetPoint("TOPRIGHT", 0, -40)
    interfaceCard:SetHeight(184)
    SectionHeader(interfaceCard, "INTERFACE & MESSAGES")
    local function SettingLabel(parent, text, description, y)
        local label = Font(parent, 10, "text", text)
        label:SetPoint("TOPLEFT", 14, y)
        local detail = Font(parent, 9, "muted", description)
        detail:SetPoint("TOPLEFT", 14, y - 16)
        return label, detail
    end

    SettingLabel(interfaceCard, "Minimap launcher",
        "Show the LibDBIcon button.", -36)
    view.Minimap = Button(interfaceCard, "", 142, 28)
    view.Minimap:SetPoint("TOPRIGHT", -14, -39)
    view.Minimap:SetScript("OnClick", function()
        Raid.db.minimap.hide = not Raid.db.minimap.hide
        Raid:RefreshMinimapButton()
        Raid:RefreshSettingsView()
    end)
    SettingLabel(interfaceCard, "Announcement channel",
        "Click to cycle the assignment channel.", -82)
    view.Channel = Button(interfaceCard, "", 142, 28)
    view.Channel:SetPoint("TOPRIGHT", -14, -85)
    view.Channel:SetScript("OnClick", function()
        local order = {
            "AUTO", "RAID_WARNING", "RAID", "PARTY", "SAY",
        }
        local current = Raid.db.announcementChannel or "AUTO"
        local index = 1
        for candidate, value in ipairs(order) do
            if value == current then index = candidate break end
        end
        Raid.db.announcementChannel =
            order[(index % #order) + 1]
        Raid:RefreshSettingsView()
    end)
    SettingLabel(interfaceCard, "Message interval",
        "Delay between chat messages to avoid throttling.", -128)
    view.DelayMinus = Button(interfaceCard, "-", 30, 28)
    view.DelayMinus:SetPoint("TOPRIGHT", -126, -131)
    view.DelayValue = Button(interfaceCard, "", 88, 28)
    view.DelayValue:SetPoint(
        "LEFT", view.DelayMinus, "RIGHT", 4, 0)
    view.DelayPlus = Button(interfaceCard, "+", 30, 28)
    view.DelayPlus:SetPoint(
        "LEFT", view.DelayValue, "RIGHT", 4, 0)
    view.DelayMinus:SetScript("OnClick", function()
        Raid.db.messageDelay = math.max(
            .20, (Raid.db.messageDelay or .45) - .05)
        Raid:RefreshSettingsView()
    end)
    view.DelayPlus:SetScript("OnClick", function()
        Raid.db.messageDelay = math.min(
            1.50, (Raid.db.messageDelay or .45) + .05)
        Raid:RefreshSettingsView()
    end)

    view.ResetWindow = Button(view, "RESET WINDOW", 138, 27)
    view.ResetWindow:SetPoint(
        "BOTTOMLEFT", view, "BOTTOMLEFT", 116, 14)
    view.ResetWindow:SetScript(
        "OnClick", function() Raid:ResetWindowPosition() end)
    AddButtonTooltip(view.ResetWindow, "Reset Window",
        "Return LunaRaids to the center of the screen.")
    view.AutoMarker = Button(view, "", 174, 27)
    view.AutoMarker:SetPoint("BOTTOMLEFT", 264, 14)
    view.AutoMarker:SetScript("OnClick", function()
        Raid:ToggleAutoMarker()
        Raid:RefreshSettingsView()
    end)
    AddButtonTooltip(
        view.AutoMarker, "Auto Marker",
        "Automatically apply the configured marks when matching "
            .. "units for the current encounter are targeted.")
    view.QuickBar = Button(view, "", 174, 27)
    view.QuickBar:SetScript("OnClick", function()
        Raid.db.quickBar.hide = not Raid.db.quickBar.hide
        Raid:RefreshQuickActionBar()
        Raid:RefreshSettingsView()
    end)
    AddButtonTooltip(
        view.QuickBar, "Quick Action Bar",
        "Enable the standalone toolbar. Its visibility and permission "
            .. "rules are configured below.")
    local automation = Panel(view.Content)
    automation:SetPoint("TOPLEFT", general, "BOTTOMLEFT", 0, -10)
    automation:SetPoint("TOPRIGHT", general, "BOTTOMRIGHT", 0, -10)
    automation:SetHeight(416)
    SectionHeader(
        automation, "AUTOMATION",
        "Ready checks, raid markers, and quick-action behavior.")
    view.AutoMarker:SetParent(automation)
    view.AutoMarker:SetFrameLevel(automation:GetFrameLevel() + 1)
    view.QuickBar:SetParent(automation)
    view.QuickBar:SetFrameLevel(automation:GetFrameLevel() + 1)
    SettingLabel(
        automation, "Encounter auto marker",
        "Apply configured boss and add markers as units are targeted.",
        -38)
    view.AutoMarker:ClearAllPoints()
    view.AutoMarker:SetPoint("TOPRIGHT", automation, -14, -42)
    SettingLabel(
        automation, "Quick action bar",
        "Standalone controls for ready checks, roles, and pull timers.",
        -84)
    view.QuickBar:SetPoint("TOPRIGHT", automation, -14, -88)
    SettingLabel(
        automation, "Ready-check results",
        "Time the completed window remains open before fading.", -130)
    view.ReadyHoldMinus = Button(automation, "-", 30, 28)
    view.ReadyHoldMinus:SetPoint("TOPRIGHT", -126, -134)
    view.ReadyHoldValue = Button(automation, "", 88, 28)
    view.ReadyHoldValue:SetPoint(
        "LEFT", view.ReadyHoldMinus, "RIGHT", 4, 0)
    view.ReadyHoldPlus = Button(automation, "+", 30, 28)
    view.ReadyHoldPlus:SetPoint(
        "LEFT", view.ReadyHoldValue, "RIGHT", 4, 0)
    view.ReadyHoldMinus:SetScript("OnClick", function()
        Raid.db.readyCheck.holdDuration = math.max(
            5, (Raid.db.readyCheck.holdDuration or 15) - 5)
        Raid:RefreshSettingsView()
    end)
    view.ReadyHoldPlus:SetScript("OnClick", function()
        Raid.db.readyCheck.holdDuration = math.min(
            60, (Raid.db.readyCheck.holdDuration or 15) + 5)
        Raid:RefreshSettingsView()
    end)
    SettingLabel(
        automation, "Compact toolbar",
        "Show action icons without text labels.", -176)
    view.QuickBarIcons = Button(automation, "", 174, 27)
    view.QuickBarIcons:SetPoint("TOPRIGHT", automation, -14, -180)
    view.QuickBarIcons:SetScript("OnClick", function()
        Raid.db.quickBar.iconOnly = not Raid.db.quickBar.iconOnly
        Raid:RefreshQuickActionBar()
        Raid:RefreshSettingsView()
    end)
    SettingLabel(
        automation, "Toolbar visibility",
        "Grouped modes require leader or assistant permissions.", -222)
    view.QuickBarVisibility = Button(automation, "", 174, 27)
    AddDropdownArrow(view.QuickBarVisibility)
    view.QuickBarVisibility:SetPoint(
        "TOPRIGHT", automation, -14, -226)
    view.QuickBarVisibility:SetScript("OnClick", function()
        ShowSelectionMenu(view.QuickBarVisibility, {
            { "ALWAYS", "Always" },
            { "GROUP", "Party or Raid" },
            { "RAID", "Raid Only" },
        }, Raid.db.quickBar.visibility or "GROUP", function(value)
            Raid.db.quickBar.visibility = value
            Raid:RefreshQuickActionBar()
            Raid:RefreshSettingsView()
        end)
    end)
    SettingLabel(
        automation, "Combat visibility",
        "Hide the quick action bar while you are in combat.", -268)
    view.QuickBarCombat = Button(automation, "", 174, 27)
    view.QuickBarCombat:SetPoint("TOPRIGHT", automation, -14, -272)
    view.QuickBarCombat:SetScript("OnClick", function()
        Raid.db.quickBar.hideInCombat =
            not Raid.db.quickBar.hideInCombat
        Raid:RefreshQuickActionBar()
        Raid:RefreshSettingsView()
    end)
    SettingLabel(
        automation, "Ready-check window",
        "Automatically open LunaRaids results during ready checks.", -314)
    view.ReadyCheckWindow = Button(automation, "", 174, 27)
    view.ReadyCheckWindow:SetPoint(
        "TOPRIGHT", automation, -14, -318)
    view.ReadyCheckWindow:SetScript("OnClick", function()
        Raid.db.readyCheck.showWindow =
            Raid.db.readyCheck.showWindow == false
        if Raid.db.readyCheck.showWindow == false
            and Raid.readyCheckWindow
        then
            Raid.readyCheckWindow:Hide()
        end
        Raid:RefreshSettingsView()
    end)
    SettingLabel(
        automation, "Personal assignment panel",
        "Show your current boss duties in a movable info frame.", -360)
    view.AssignmentInfo = Button(automation, "", 174, 27)
    view.AssignmentInfo:SetPoint(
        "TOPRIGHT", automation, -14, -364)
    view.AssignmentInfo:SetScript("OnClick", function()
        Raid.db.assignmentInfo.hide =
            not Raid.db.assignmentInfo.hide
        Raid:RefreshPersonalAssignments()
        Raid:RefreshSettingsView()
    end)
    local cooldowns = CreateFrame("Frame", nil, view.Content)
    cooldowns:SetPoint("TOPLEFT", 12, -8)
    cooldowns:SetPoint("TOPRIGHT", -12, -8)
    cooldowns:SetHeight(628)
    SectionHeader(
        cooldowns, "RAID COOLDOWNS",
        "Choose the raid abilities displayed by the standalone cooldown HUD.",
        162)
    view.CooldownEnabled = Button(cooldowns, "", 142, 28)
    view.CooldownEnabled:SetPoint("TOPRIGHT", cooldowns, -10, -2)
    view.CooldownEnabled:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        settings.enabled = not settings.enabled
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end)
    view.CooldownAppearanceTab =
        Button(cooldowns, "APPEARANCE", 148, 28)
    view.CooldownAppearanceTab:SetPoint("TOPLEFT", 14, -42)
    view.CooldownAppearanceTab:SetScript("OnClick", function()
        Raid.cooldownSettingsSection = "APPEARANCE"
        Raid:RefreshSettingsView()
    end)
    view.CooldownSpellsTab = Button(cooldowns, "SPELLS", 148, 28)
    view.CooldownSpellsTab:SetPoint(
        "LEFT", view.CooldownAppearanceTab, "RIGHT", 6, 0)
    view.CooldownSpellsTab:SetScript("OnClick", function()
        Raid.cooldownSettingsSection = "SPELLS"
        Raid:RefreshSettingsView()
    end)
    view.CooldownBody = Panel(cooldowns)
    view.CooldownBody:SetPoint("TOPLEFT", cooldowns, 0, -78)
    view.CooldownBody:SetPoint("TOPRIGHT", cooldowns, 0, -78)
    view.CooldownBody:SetHeight(536)
    view.CooldownBody:SetFrameLevel(
        math.max(0, cooldowns:GetFrameLevel() - 1))
    view.CooldownBody:EnableMouse(false)
    view.CooldownDisplayControls = {}
    local positionLabel, positionDetail = SettingLabel(
        cooldowns, "HUD position",
        "Move the HUD in-game, or return it to its default position.", -92)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        positionLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        positionDetail
    view.CooldownReset = Button(cooldowns, "RESET POSITION", 142, 28)
    view.CooldownReset:SetPoint("TOPRIGHT", cooldowns, -14, -96)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownReset
    view.CooldownReset:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        settings.point, settings.x, settings.y =
            "CENTER", -330, 20
        if Raid.raidCooldownFrame then
            Raid.raidCooldownFrame:ClearAllPoints()
            Raid.raidCooldownFrame:SetPoint(
                "CENTER", UIParent, "CENTER", -330, 20)
        end
    end)
    local layoutLabel, layoutDetail = SettingLabel(
        cooldowns, "Layout",
        "Show each ability as a category column or as a compact row.", -136)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        layoutLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        layoutDetail
    view.CooldownLayout = Button(cooldowns, "", 180, 28)
    AddDropdownArrow(view.CooldownLayout)
    view.CooldownLayout:SetPoint("TOPRIGHT", cooldowns, -14, -140)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownLayout
    view.CooldownLayout:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        ShowSelectionMenu(view.CooldownLayout, {
            { "CATEGORIES", "Category columns" },
            { "ROWS", "Ability rows" },
            { "LIST", "Vertical player list" },
        }, settings.layout or "CATEGORIES", function(value)
            settings.layout = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local sortLabel, sortDetail = SettingLabel(
        cooldowns, "Sort abilities",
        "Order by the configured spell list, class, or ability name.", -180)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        sortLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        sortDetail
    view.CooldownSort = Button(cooldowns, "", 180, 28)
    AddDropdownArrow(view.CooldownSort)
    view.CooldownSort:SetPoint("TOPRIGHT", cooldowns, -14, -184)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownSort
    view.CooldownSort:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        ShowSelectionMenu(view.CooldownSort, {
            { "SPELL", "Configured order" },
            { "CLASS", "Class" },
            { "NAME", "Ability name" },
        }, settings.sortMode or "SPELL", function(value)
            settings.sortMode = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local colorLabel, colorDetail = SettingLabel(
        cooldowns, "Ready-bar colors",
        "Use each player's class color, or choose one shared color.", -224)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        colorLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        colorDetail
    view.CooldownClassColors = Button(cooldowns, "", 180, 28)
    view.CooldownClassColors:SetPoint("TOPRIGHT", cooldowns, -14, -228)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownClassColors
    view.CooldownClassColors:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        settings.classColors = not settings.classColors
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end)
    view.CooldownReadyColor = Button(cooldowns, "READY", 92, 28)
    view.CooldownReadyColor:SetPoint("TOPLEFT", cooldowns, 14, -270)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownReadyColor
    view.CooldownReadyColor:SetScript("OnClick", function()
        Raid:OpenRaidCooldownColorPicker("readyColor")
    end)
    view.CooldownCooldownColor =
        Button(cooldowns, "COOLDOWN", 112, 28)
    view.CooldownCooldownColor:SetPoint(
        "LEFT", view.CooldownReadyColor, "RIGHT", 7, 0)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownCooldownColor
    view.CooldownCooldownColor:SetScript("OnClick", function()
        Raid:OpenRaidCooldownColorPicker("cooldownColor")
    end)
    local scaleLabel, scaleDetail = SettingLabel(
        cooldowns, "HUD scale",
        "Scale the complete cooldown display without changing its layout.",
        -314)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        scaleLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        scaleDetail
    view.CooldownScale = Button(cooldowns, "", 180, 28)
    AddDropdownArrow(view.CooldownScale)
    view.CooldownScale:SetPoint("TOPRIGHT", cooldowns, -14, -318)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownScale
    view.CooldownScale:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        ShowSelectionMenu(view.CooldownScale, {
            { .75, "75%" }, { .85, "85%" }, { 1, "100%" },
            { 1.1, "110%" }, { 1.25, "125%" },
        }, settings.scale or 1, function(value)
            settings.scale = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local alphaLabel, alphaDetail = SettingLabel(
        cooldowns, "Overall HUD opacity",
        "Fade the complete display, including icons, names, and bars.", -358)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        alphaLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        alphaDetail
    view.CooldownAlpha = Button(cooldowns, "", 180, 28)
    AddDropdownArrow(view.CooldownAlpha)
    view.CooldownAlpha:SetPoint("TOPRIGHT", cooldowns, -14, -362)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownAlpha
    view.CooldownAlpha:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        ShowSelectionMenu(view.CooldownAlpha, {
            { .45, "45%" }, { .6, "60%" }, { .75, "75%" },
            { .9, "90%" }, { 1, "100%" },
        }, settings.hudOpacity or .82, function(value)
            settings.hudOpacity = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local lockLabel, lockDetail = SettingLabel(
        cooldowns, "Lock HUD",
        "Prevent accidental movement after positioning the display.", -402)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        lockLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        lockDetail
    view.CooldownLock = Button(cooldowns, "", 180, 28)
    view.CooldownLock:SetPoint("TOPRIGHT", cooldowns, -14, -406)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownLock
    view.CooldownLock:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        settings.locked = not settings.locked
        Raid:RefreshSettingsView()
    end)
    local rowNameLabel, rowNameDetail = SettingLabel(
        cooldowns, "Ability-row names",
        "Show the spell name beside its icon in Ability Rows layout.", -446)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        rowNameLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        rowNameDetail
    view.CooldownRowNames = Button(cooldowns, "", 180, 28)
    view.CooldownRowNames:SetPoint("TOPRIGHT", cooldowns, -14, -450)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownRowNames
    view.CooldownRowNames:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        settings.showAbilityName = not settings.showAbilityName
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end)
    local rowTotalLabel, rowTotalDetail = SettingLabel(
        cooldowns, "Ability-row totals",
        "Show the number of ready players and total available.", -490)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        rowTotalLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        rowTotalDetail
    view.CooldownRowTotals = Button(cooldowns, "", 180, 28)
    view.CooldownRowTotals:SetPoint("TOPRIGHT", cooldowns, -14, -494)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownRowTotals
    view.CooldownRowTotals:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        settings.showAbilityTotal = not settings.showAbilityTotal
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end)
    local visibilityLabel, visibilityDetail = SettingLabel(
        cooldowns, "HUD visibility",
        "Choose whether cooldowns appear solo, in groups, or only in raids.",
        -534)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        visibilityLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        visibilityDetail
    view.CooldownVisibility = Button(cooldowns, "", 180, 28)
    AddDropdownArrow(view.CooldownVisibility)
    view.CooldownVisibility:SetPoint(
        "TOPRIGHT", cooldowns, -14, -538)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownVisibility
    view.CooldownVisibility:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        ShowSelectionMenu(view.CooldownVisibility, {
            { "ALWAYS", "Always" },
            { "GROUP", "Party & raid" },
            { "RAID", "Raid only" },
        }, settings.visibility or "GROUP", function(value)
            settings.visibility = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local cooldownDefinitions = Raid.GetRaidCooldownDefinitions
        and Raid:GetRaidCooldownDefinitions() or {}
    view.CooldownClassButtons = {}
    local filters = {
        { "ALL", "ALL" },
        { "ENABLED", "ENABLED" },
    }
    local seenClasses = {}
    for _, definition in ipairs(cooldownDefinitions) do
        if not seenClasses[definition[3]] then
            seenClasses[definition[3]] = true
            filters[#filters + 1] = {
                definition[3], definition[3],
            }
        end
    end
    table.sort(filters, function(left, right)
        if left[1] == "ALL" then return true end
        if right[1] == "ALL" then return false end
        if left[1] == "ENABLED" then return true end
        if right[1] == "ENABLED" then return false end
        return left[2] < right[2]
    end)
    for index, filter in ipairs(filters) do
        local filterKey = filter[1]
        local button = Button(cooldowns, filter[2], 92, 27)
        local column = (index - 1) % 6
        local row = math.floor((index - 1) / 6)
        button:SetPoint(
            "TOPLEFT", 14 + (column * 98), -88 - (row * 32))
        button.filterKey = filterKey
        button:SetScript("OnClick", function()
            Raid.cooldownClassFilter = filterKey
            Raid:RefreshSettingsView()
        end)
        view.CooldownClassButtons[index] = button
    end
    view.CooldownEnableAll = Button(cooldowns, "ENABLE SHOWN", 132, 27)
    view.CooldownEnableAll:SetPoint("BOTTOMLEFT", cooldowns, 14, 8)
    view.CooldownEnableAll:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        local filter = Raid.cooldownClassFilter or "ALL"
        for _, definition in ipairs(cooldownDefinitions) do
            if filter == "ALL" or filter == "ENABLED"
                or definition[3] == filter
            then
                settings.spells[definition[1]] = true
            end
        end
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end)
    view.CooldownDisableAll = Button(cooldowns, "DISABLE SHOWN", 132, 27)
    view.CooldownDisableAll:SetPoint(
        "LEFT", view.CooldownEnableAll, "RIGHT", 6, 0)
    view.CooldownDisableAll:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        local filter = Raid.cooldownClassFilter or "ALL"
        for _, definition in ipairs(cooldownDefinitions) do
            if filter == "ALL" or filter == "ENABLED"
                or definition[3] == filter
            then
                settings.spells[definition[1]] = false
            end
        end
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end)
    view.CooldownSpellButtons = {}
    for index, definition in ipairs(cooldownDefinitions) do
        local definitionForButton = definition
        local column = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        local button = Button(cooldowns, "", 294, 30)
        button:SetPoint(
            "TOPLEFT", 14 + (column * 304), -158 - (row * 36))
        AddButtonIcon(
            button,
            GetSpellTexture and GetSpellTexture(definition[4])
                or definition[4],
            18)
        button.Text:ClearAllPoints()
        button.Text:SetPoint("LEFT", 34, 0)
        button.Text:SetPoint("RIGHT", -42, 0)
        button.Text:SetJustifyH("LEFT")
        button.State = Font(button, 9, "muted", "")
        button.State:SetPoint("RIGHT", -9, 0)
        button.definition = definitionForButton
        button:SetScript("OnClick", function()
            local settings = Raid:GetRaidCooldownSettings()
            local key = definitionForButton[1]
            settings.spells[key] = not settings.spells[key]
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
        view.CooldownSpellButtons[index] = button
    end

    local admin = CreateFrame("Frame", nil, view.Content)
    admin:SetPoint("TOPLEFT", 12, -8)
    admin:SetPoint("TOPRIGHT", -12, -8)
    admin:SetHeight(480)
    SectionHeader(
        admin,
        "RAID ADMINISTRATION",
        "Automate entry, permissions, and loot without opening Blizzard menus.")

    local inviteCard = Panel(admin)
    inviteCard:SetPoint("TOPLEFT", 0, -40)
    inviteCard:SetPoint("TOPRIGHT", 0, -40)
    inviteCard:SetHeight(96)
    local promoteCard = Panel(admin)
    promoteCard:SetPoint("TOPLEFT", inviteCard, "BOTTOMLEFT", 0, -9)
    promoteCard:SetPoint("TOPRIGHT", inviteCard, "BOTTOMRIGHT", 0, -9)
    promoteCard:SetHeight(150)
    local lootCard = Panel(admin)
    lootCard:SetPoint("TOPLEFT", promoteCard, "BOTTOMLEFT", 0, -9)
    lootCard:SetPoint("TOPRIGHT", promoteCard, "BOTTOMRIGHT", 0, -9)
    lootCard:SetHeight(140)

    SectionHeader(
        inviteCard, "AUTO INVITE",
        "Invite exact whisper keywords, separated by commas.", 162)
    view.AutoInvite = Button(inviteCard, "", 142, 28)
    view.AutoInvite:SetPoint("TOPRIGHT", inviteCard, -10, -2)
    view.AutoInvite:SetScript("OnClick", function()
        local settings = Raid.db.raidAdmin
        settings.autoInvite = not settings.autoInvite
        Raid:RefreshSettingsView()
    end)
    view.InviteKeywords = EditField(
        inviteCard, 330, "inv, invite")
    view.InviteKeywords:SetPoint("BOTTOMLEFT", inviteCard, 14, 10)
    view.InviteKeywords:SetScript("OnTextChanged", function(self, user)
        self.Placeholder:SetShown(self:GetText() == "")
        if user then Raid.db.raidAdmin.inviteKeywords = self:GetText() end
    end)

    SectionHeader(
        promoteCard, "ASSISTANT PROMOTION",
        "Promote named players or guild ranks while you are raid leader.", 162)
    view.AutoPromote = Button(promoteCard, "", 142, 28)
    view.AutoPromote:SetPoint("TOPRIGHT", promoteCard, -10, -2)
    view.AutoPromote:SetScript("OnClick", function()
        local settings = Raid.db.raidAdmin
        settings.autoPromote = not settings.autoPromote
        Raid:ApplyAutoPromote()
        Raid:RefreshSettingsView()
    end)
    view.PromoteNames = EditField(
        promoteCard, 430, "Names or shift-click player links")
    view.PromoteNames:SetPoint("TOPLEFT", promoteCard, 14, -56)
    view.PromoteNames:SetScript("OnTextChanged", function(self, user)
        self.Placeholder:SetShown(self:GetText() == "")
        if user then Raid.db.raidAdmin.promoteNames = self:GetText() end
    end)
    view.PromoteNames:HookScript("OnEditFocusGained", function(self)
        Raid.playerNameInsertBox = self
        Raid.playerNameInsertKey = "promoteNames"
    end)
    view.PromoteNames:HookScript(
        "OnEditFocusLost", function() Raid:ApplyAutoPromote() end)
    view.PromoteNames:HookScript("OnHide", function(self)
        if Raid.playerNameInsertBox == self then
            Raid.playerNameInsertBox = nil
            Raid.playerNameInsertKey = nil
        end
    end)
    view.PromoteGuildRank = Button(promoteCard, "", 260, 28)
    AddDropdownArrow(view.PromoteGuildRank)
    view.PromoteGuildRank:SetPoint("TOPLEFT", promoteCard, 14, -94)
    view.PromoteGuildRank:SetScript("OnClick", function()
        if C_GuildInfo and C_GuildInfo.GuildRoster then
            C_GuildInfo.GuildRoster()
        elseif GuildRoster then
            GuildRoster()
        end
        local entries = CurrentGuildRankEntries()
        if #entries == 0 then
            Raid:Print(
                "Guild ranks are not available yet. Open the guild roster and try again.")
            return
        end
        Raid.db.raidAdmin.promoteGuildRanks =
            Raid.db.raidAdmin.promoteGuildRanks or {}
        ShowMultiSelectionMenu(
            view.PromoteGuildRank, entries,
            Raid.db.raidAdmin.promoteGuildRanks,
            function()
                Raid:ApplyAutoPromote()
                Raid:RefreshSettingsView()
            end)
    end)

    SectionHeader(
        lootCard, "LOOT RULES",
        "Apply saved method and quality while leading a raid.", 162)
    view.ManageLoot = Button(lootCard, "", 142, 28)
    view.ManageLoot:SetPoint("TOPRIGHT", lootCard, -10, -2)
    view.ManageLoot:SetScript("OnClick", function()
        local settings = Raid.db.raidAdmin
        settings.manageLoot = not settings.manageLoot
        if settings.manageLoot then Raid:ApplyLootRules(false, true) end
        Raid:RefreshSettingsView()
    end)
    view.LootMethod = Button(lootCard, "", 210, 28)
    AddDropdownArrow(view.LootMethod)
    view.LootMethod:SetPoint("TOPLEFT", lootCard, 14, -56)
    view.LootMethod:SetScript("OnClick", function()
        ShowSelectionMenu(view.LootMethod, {
            { "group", "Group Loot" },
            { "master", "Master Loot" },
            { "roundrobin", "Round Robin" },
            { "freeforall", "Free For All" },
        }, Raid.db.raidAdmin.lootMethod or "group", function(value)
            Raid.db.raidAdmin.manageLoot = true
            Raid.db.raidAdmin.lootMethod = value
            Raid:RefreshSettingsView()
            Raid:ApplyLootRules(false, true)
        end)
    end)
    view.LootThreshold = Button(lootCard, "", 210, 28)
    AddDropdownArrow(view.LootThreshold)
    view.LootThreshold:SetPoint(
        "LEFT", view.LootMethod, "RIGHT", 8, 0)
    view.LootThreshold:SetScript("OnClick", function()
        ShowSelectionMenu(view.LootThreshold, {
            { 0, "|cff9d9d9dPoor|r" },
            { 1, "|cffffffffCommon|r" },
            { 2, "|cff1eff00Uncommon|r" },
            { 3, "|cff0070ddRare|r" },
            { 4, "|cffa335eeEpic|r" },
        }, Raid.db.raidAdmin.lootThreshold or 2, function(value)
            Raid.db.raidAdmin.manageLoot = true
            Raid.db.raidAdmin.lootThreshold = value
            Raid:RefreshSettingsView()
            Raid:ApplyLootRules(false)
        end)
    end)
    view.MasterLooter = EditField(
        lootCard, 330, "Fallback names, first available wins")
    view.MasterLooter:SetPoint("TOPLEFT", lootCard, 14, -94)
    view.MasterLooter:SetScript("OnTextChanged", function(self, user)
        self.Placeholder:SetShown(self:GetText() == "")
        if user then Raid.db.raidAdmin.masterLooter = self:GetText() end
    end)
    view.MasterLooter:HookScript("OnEditFocusGained", function(self)
        Raid.playerNameInsertBox = self
        Raid.playerNameInsertKey = "masterLooter"
    end)
    view.MasterLooter:HookScript(
        "OnEditFocusLost", function(self)
            Raid:ApplyLootRules(false, true)
        end)
    view.MasterLooter:HookScript("OnHide", function(self)
        if Raid.playerNameInsertBox == self then
            Raid.playerNameInsertBox = nil
            Raid.playerNameInsertKey = nil
        end
    end)
    view.AdminPanel = admin
    view.GeneralPanel = general
    view.AutomationPanel = automation
    view.CooldownPanel = cooldowns

    view.Back = Button(view, "BACK", 86, 28)
    view.Back:SetPoint("BOTTOMLEFT", 20, 14)
    view.Back:SetScript(
        "OnClick", function() Raid:ExitSettingsView() end)
    view.Back:Hide()
    view.ResetWindow:Hide()
    view:Hide()
    self.settingsView = view
    return view
end

function Raid:RefreshSettingsView()
    local view = self.settingsView
    if not view or not view:IsShown() then return end
    local adminTab = self.settingsTab == "ADMIN"
    local cooldownTab = self.settingsTab == "COOLDOWNS"
    view.Subtitle:SetText(
        adminTab
            and "Invites, assistant promotion, and loot rules"
            or cooldownTab
                and "Raid cooldown visibility and tracked abilities"
            or "Interface, communication, and toolbar behavior")
    view.GeneralPanel:SetShown(not adminTab and not cooldownTab)
    view.AutomationPanel:SetShown(not adminTab and not cooldownTab)
    view.AdminPanel:SetShown(adminTab)
    view.CooldownPanel:SetShown(cooldownTab)
    view.ResetWindow:Hide()
    view.Back:Hide()
    view.Content:SetWidth(math.max(1, view:GetWidth() - 28))
    view.Content:SetHeight(
        adminTab and 496 or cooldownTab and 644 or 658)
    if view.Scroll.UpdateScrollbar then
        view.Scroll:UpdateScrollbar()
    end
    StyleButton(
        view.GeneralTab,
        not adminTab and not cooldownTab and "primary" or nil)
    StyleButton(view.AdminTab, adminTab and "primary" or nil)
    StyleButton(
        view.CooldownTab, cooldownTab and "primary" or nil)
    local cooldownSettings = self:GetRaidCooldownSettings()
    local cooldownSection =
        self.cooldownSettingsSection or "APPEARANCE"
    local spellSection = cooldownSection == "SPELLS"
    StyleButton(
        view.CooldownAppearanceTab,
        not spellSection and "primary" or nil)
    StyleButton(
        view.CooldownSpellsTab,
        spellSection and "primary" or nil)
    for _, control in ipairs(view.CooldownDisplayControls or {}) do
        control:SetShown(not spellSection)
    end
    local classFilter = self.cooldownClassFilter or "ALL"
    for _, button in ipairs(view.CooldownClassButtons or {}) do
        button:SetShown(spellSection)
        StyleButton(
            button,
            button.filterKey == classFilter and "primary" or nil)
        if button.filterKey ~= "ALL"
            and button.filterKey ~= "ENABLED"
        then
            local classColor = RAID_CLASS_COLORS
                and RAID_CLASS_COLORS[button.filterKey]
            if classColor then
                button.Text:SetTextColor(
                    classColor.r, classColor.g, classColor.b, 1)
            end
        end
    end
    view.CooldownEnableAll:SetShown(spellSection)
    view.CooldownDisableAll:SetShown(spellSection)
    view.CooldownEnabled.Text:SetText(
        cooldownSettings.enabled and "COOLDOWNS: ON"
            or "COOLDOWNS: OFF")
    StyleButton(
        view.CooldownEnabled,
        cooldownSettings.enabled and "positive" or "danger")
    local layoutLabels = {
        CATEGORIES = "CATEGORY COLUMNS",
        ROWS = "ABILITY ROWS",
        LIST = "VERTICAL PLAYER LIST",
    }
    view.CooldownLayout.Text:SetText(
        layoutLabels[cooldownSettings.layout] or "CATEGORY COLUMNS")
    local sortLabels = {
        SPELL = "CONFIGURED ORDER",
        CLASS = "CLASS",
        NAME = "ABILITY NAME",
    }
    view.CooldownSort.Text:SetText(
        sortLabels[cooldownSettings.sortMode] or "CONFIGURED ORDER")
    view.CooldownClassColors.Text:SetText(
        cooldownSettings.classColors
            and "CLASS COLORS: ON" or "CLASS COLORS: OFF")
    StyleButton(
        view.CooldownClassColors,
        cooldownSettings.classColors and "positive" or nil)
    local readyColor = cooldownSettings.readyColor
    local cooldownColor = cooldownSettings.cooldownColor
    view.CooldownReadyColor:SetBackdropBorderColor(
        readyColor[1], readyColor[2], readyColor[3], 1)
    view.CooldownReadyColor.Text:SetTextColor(
        readyColor[1], readyColor[2], readyColor[3], 1)
    view.CooldownCooldownColor:SetBackdropBorderColor(
        cooldownColor[1], cooldownColor[2], cooldownColor[3], 1)
    view.CooldownCooldownColor.Text:SetTextColor(
        cooldownColor[1], cooldownColor[2], cooldownColor[3], 1)
    view.CooldownScale.Text:SetText(
        ("%d%%"):format(
            math.floor((cooldownSettings.scale or 1) * 100 + .5)))
    view.CooldownAlpha.Text:SetText(
        ("%d%%"):format(
            math.floor(
                (cooldownSettings.hudOpacity or .82) * 100 + .5)))
    view.CooldownLock.Text:SetText(
        cooldownSettings.locked and "HUD: LOCKED" or "HUD: UNLOCKED")
    StyleButton(
        view.CooldownLock,
        cooldownSettings.locked and "positive" or nil)
    view.CooldownRowNames.Text:SetText(
        cooldownSettings.showAbilityName
            and "SPELL NAMES: ON" or "SPELL NAMES: OFF")
    StyleButton(
        view.CooldownRowNames,
        cooldownSettings.showAbilityName and "positive" or nil)
    view.CooldownRowTotals.Text:SetText(
        cooldownSettings.showAbilityTotal
            and "TOTALS: ON" or "TOTALS: OFF")
    StyleButton(
        view.CooldownRowTotals,
        cooldownSettings.showAbilityTotal and "positive" or nil)
    local cooldownVisibilityLabels = {
        ALWAYS = "ALWAYS",
        GROUP = "PARTY & RAID",
        RAID = "RAID ONLY",
    }
    view.CooldownVisibility.Text:SetText(
        cooldownVisibilityLabels[cooldownSettings.visibility]
            or "PARTY & RAID")
    local visibleSpellIndex = 0
    for _, button in ipairs(view.CooldownSpellButtons or {}) do
        local enabled =
            cooldownSettings.spells[button.definition[1]] ~= false
        local matchesFilter = classFilter == "ALL"
            or classFilter == "ENABLED" and enabled
            or button.definition[3] == classFilter
        button:SetShown(spellSection and matchesFilter)
        if spellSection and matchesFilter then
            local column = visibleSpellIndex % 2
            local row = math.floor(visibleSpellIndex / 2)
            button:ClearAllPoints()
            button:SetPoint(
                "TOPLEFT", view.CooldownPanel,
                "TOPLEFT", 14 + (column * 304),
                -158 - (row * 36))
            visibleSpellIndex = visibleSpellIndex + 1
        end
        button.Text:SetText(
            button.definition[2] .. "  |cff71818c"
                .. button.definition[3] .. " · "
                .. tostring(button.definition[5]) .. "s|r")
        button.State:SetText(enabled and "ON" or "OFF")
        button.State:SetTextColor(
            enabled and .18 or .75,
            enabled and .9 or .25,
            enabled and .55 or .25, 1)
        StyleButton(button, enabled and "positive" or nil)
    end
    view.Minimap.Text:SetText(
        self.db.minimap.hide and "HIDDEN" or "SHOWN")
    StyleButton(
        view.Minimap,
        self.db.minimap.hide and "danger" or "positive")
    local labels = {
        AUTO = "AUTOMATIC", RAID_WARNING = "RAID WARNING",
        RAID = "RAID", PARTY = "PARTY", SAY = "SAY",
    }
    view.Channel.Text:SetText(
        labels[self.db.announcementChannel or "AUTO"])
    view.DelayValue.Text:SetText(
        ("%.2f SEC"):format(self.db.messageDelay or .45))
    view.ReadyHoldValue.Text:SetText(
        ("%d SEC"):format(self.db.readyCheck.holdDuration or 15))
    local autoMarkerEnabled = self:IsAutoMarkerEnabled()
    view.AutoMarker.Text:SetText(
        autoMarkerEnabled and "AUTO MARK: ON" or "AUTO MARK: OFF")
    StyleButton(
        view.AutoMarker,
        autoMarkerEnabled and "positive" or "danger")
    local quickBarShown = not self.db.quickBar.hide
    view.QuickBar.Text:SetText(
        quickBarShown and "TOOLBAR: ENABLED" or "TOOLBAR: DISABLED")
    StyleButton(
        view.QuickBar,
        quickBarShown and "positive" or "danger")
    local iconOnly = self.db.quickBar.iconOnly
    view.QuickBarIcons.Text:SetText(
        iconOnly and "ICONS ONLY: ON" or "ICONS ONLY: OFF")
    StyleButton(
        view.QuickBarIcons, iconOnly and "positive" or "danger")
    local visibilityLabels = {
        ALWAYS = "ALWAYS", GROUP = "PARTY OR RAID", RAID = "RAID ONLY",
    }
    view.QuickBarVisibility.Text:SetText(
        visibilityLabels[self.db.quickBar.visibility or "GROUP"]
            or "PARTY OR RAID")
    local hideInCombat = self.db.quickBar.hideInCombat ~= false
    view.QuickBarCombat.Text:SetText(
        hideInCombat and "HIDE IN COMBAT: ON"
            or "HIDE IN COMBAT: OFF")
    StyleButton(
        view.QuickBarCombat,
        hideInCombat and "positive" or "danger")
    local showReadyWindow = self.db.readyCheck.showWindow ~= false
    view.ReadyCheckWindow.Text:SetText(
        showReadyWindow and "RESULTS WINDOW: ON"
            or "RESULTS WINDOW: OFF")
    StyleButton(
        view.ReadyCheckWindow,
        showReadyWindow and "positive" or "danger")
    local showAssignmentInfo = not self.db.assignmentInfo.hide
    view.AssignmentInfo.Text:SetText(
        showAssignmentInfo and "ASSIGNMENTS: ON"
            or "ASSIGNMENTS: OFF")
    StyleButton(
        view.AssignmentInfo,
        showAssignmentInfo and "positive" or "danger")
    local settings = self.db.raidAdmin
    view.AutoInvite.Text:SetText(
        settings.autoInvite and "AUTO INVITE: ON" or "AUTO INVITE: OFF")
    StyleButton(
        view.AutoInvite, settings.autoInvite and "positive" or "danger")
    view.AutoPromote.Text:SetText(
        settings.autoPromote and "PROMOTE: ON" or "PROMOTE: OFF")
    StyleButton(
        view.AutoPromote, settings.autoPromote and "positive" or "danger")
    local selectedRankNames = {}
    for _, entry in ipairs(CurrentGuildRankEntries()) do
        if settings.promoteGuildRanks
            and settings.promoteGuildRanks[entry[1]]
        then
            selectedRankNames[#selectedRankNames + 1] = entry[2]
        end
    end
    view.PromoteGuildRank.Text:SetText(
        #selectedRankNames > 0
            and table.concat(selectedRankNames, ", "):upper()
            or "SELECT GUILD RANKS")
    view.ManageLoot.Text:SetText(
        settings.manageLoot and "LOOT RULES: ON" or "LOOT RULES: OFF")
    StyleButton(
        view.ManageLoot, settings.manageLoot and "positive" or "danger")
    local methods = {
        group = "GROUP LOOT", master = "MASTER LOOT",
        roundrobin = "ROUND ROBIN", freeforall = "FREE FOR ALL",
    }
    local thresholds = {
        [0] = "|cff9d9d9dPOOR|r",
        [1] = "|cffffffffCOMMON|r",
        [2] = "|cff1eff00UNCOMMON|r",
        [3] = "|cff0070ddRARE|r",
        [4] = "|cffa335eeEPIC|r",
    }
    view.LootMethod.Text:SetText(
        methods[settings.lootMethod] or "GROUP LOOT")
    view.LootThreshold.Text:SetText(
        thresholds[settings.lootThreshold or 2]
            or "|cff1eff00UNCOMMON|r")
    if not view.InviteKeywords:HasFocus() then
        view.InviteKeywords:SetText(settings.inviteKeywords or "")
    end
    if not view.PromoteNames:HasFocus() then
        view.PromoteNames:SetText(settings.promoteNames or "")
    end
    if not view.MasterLooter:HasFocus() then
        view.MasterLooter:SetText(settings.masterLooter or "")
    end
    view.MasterLooter:SetShown(settings.lootMethod == "master")
end

function Raid:RedrawSettingsView()
    self:RefreshSettingsView()
    self:UpdateWindowLayout()
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if Raid.settingsView and Raid.settingsView:IsShown() then
                Raid:RefreshSettingsView()
                Raid:UpdateWindowLayout()
            end
        end)
    end
end

function Raid:ShowSettingsView()
    self:CreateUI()
    if C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
    elseif GuildRoster then
        GuildRoster()
    end
    local view = self:CreateSettingsView()
    if self.newRaidWizard then self.newRaidWizard:Hide() end
    self.workspaceMode = "SETTINGS"
    self:SetRaidWorkspaceVisible(false)
    if self.workspaceRail then self.workspaceRail:Show() end
    if self.bossSettingsPanel then self.bossSettingsPanel:Hide() end
    if self.manualPlayerPanel then self.manualPlayerPanel:Hide() end
    self.frame.Title:SetText("SETTINGS")
    self.frame.Subtitle:SetText(
        "INTERFACE, COMMUNICATION, AND RAID ADMINISTRATION")
    self.settingsTab = self.settingsTab or "GENERAL"
    view:Show()
    self:RefreshWorkspaceNavigation()
    self:RefreshFooterLayout()
    self:RedrawSettingsView()
    self.frame:Show()
end

function Raid:ExitSettingsView()
    if self.settingsView then self.settingsView:Hide() end
    if self.db.raidLocked then
        self:EnterBossUI()
    elseif self:CanStartRaid() then
        self:ShowNewRaidWizard()
    else
        self.frame:Hide()
    end
end

function Raid:CreateNewRaidWizard()
    if self.newRaidWizard then return self.newRaidWizard end
    -- The raid picker replaces only the assignment pane's contents.
    local wizard = Panel(self.assignmentPanel)
    wizard:SetPoint("TOPLEFT", 1, -1)
    wizard:SetPoint("BOTTOMRIGHT", -1, 1)
    wizard:SetFrameLevel(self.assignmentPanel:GetFrameLevel() + 20)
    wizard:SetBackdropColor(.018, .030, .043, 1)
    wizard:EnableMouse(true)
    wizard.Title = Font(wizard, 15, "accent", "START A RAID")
    wizard.Title:SetPoint("TOPLEFT", 20, -22)
    wizard.Subtitle = Font(wizard, 10, "muted", "")
    wizard.Subtitle:SetPoint("TOPLEFT", 21, -50)
    wizard.Subtitle:SetPoint("RIGHT", -20, 0)
    wizard.Subtitle:SetJustifyH("LEFT")
    wizard.Back = Button(wizard, "BACK", 86, 26)
    wizard.Back:SetPoint("BOTTOMLEFT", 20, 14)
    wizard.Back:SetScript("OnClick", function()
        wizard.step = "EXPANSION"
        Raid:RefreshNewRaidWizard()
    end)
    wizard.Buttons = {}
    wizard:Hide()
    self.newRaidWizard = wizard
    return wizard
end

function Raid:WizardButton(index)
    local wizard = self.newRaidWizard
    local button = wizard.Buttons[index]
    if not button then
        button = Button(
            wizard, "", math.max(1, wizard:GetWidth() - 40), 42)
        button.Text:ClearAllPoints()
        button.Text:SetPoint("LEFT", 12, 0)
        button.Text:SetPoint("RIGHT", -10, 0)
        button.Text:SetJustifyH("LEFT")
        button.Delete = Button(button, "X", 26, 26)
        button.Delete:SetPoint("RIGHT", -4, 0)
        button.Delete:SetFrameLevel(button:GetFrameLevel() + 3)
        button.Delete.Text:SetTextColor(1, .35, .35)
        AddButtonTooltip(
            button.Delete, "Delete Saved Raid",
            "Permanently remove this saved raid plan.")
        button.Delete:Hide()
        wizard.Buttons[index] = button
    end
    return button
end

function Raid:RefreshNewRaidWizard()
    local wizard = self:CreateNewRaidWizard()
    if not wizard:IsShown() then return end
    for _, button in ipairs(wizard.Buttons) do
        button:Hide()
        button.Delete:Hide()
        button.Text:ClearAllPoints()
        button.Text:SetPoint("LEFT", 12, 0)
        button.Text:SetPoint("RIGHT", -10, 0)
    end
    local entries = {}
    if wizard.step == "RAID" then
        wizard.Subtitle:SetText("Select a raid  -  Back returns to expansions")
        wizard.Back:Show()
        for _, raid in ipairs(self.raids) do
            if raid.expansion == wizard.expansion then
                local raidKey = raid.key
                local raidExpansion = raid.expansion
                entries[#entries + 1] = {
                    label = raid.name .. "  (" .. raid.size .. " player)",
                    action = function()
                        self.db.newRaidExpansion = raidExpansion
                        if self:BeginRaid(raidKey) then
                            self:EnterBossUI("ASSIGNMENTS")
                        end
                    end,
                }
            end
        end
    else
        wizard.step = "EXPANSION"
        wizard.Subtitle:SetText(
            "Choose an expansion, or open a raid saved in advance")
        wizard.Back:Hide()
        for _, expansion in ipairs(self.expansions) do
            local expansionKey = expansion.key
            entries[#entries + 1] = {
                label = "EXPANSION  -  " .. expansion.name,
                action = function()
                    wizard.expansion = expansionKey
                    self.db.newRaidExpansion = expansionKey
                    wizard.step = "RAID"
                    self:RefreshNewRaidWizard()
                end,
            }
        end
        local saved = {}
        for id, data in pairs(self.db.savedRaids or {}) do
            saved[#saved + 1] = { id = id, data = data }
        end
        table.sort(saved, function(left, right)
            return (left.data.savedAt or 0) > (right.data.savedAt or 0)
        end)
        for savedIndex, entry in ipairs(saved) do
            if savedIndex > 9 then break end
            local savedID, data = entry.id, entry.data
            local raid = self.raidByKey[data.raidKey]
            entries[#entries + 1] = {
                label = "SAVED  -  " .. data.name
                    .. (raid and "  [" .. raid.name .. "]" or ""),
                action = function()
                    if self:LoadSavedRaid(savedID) then
                        self:EnterBossUI()
                    end
                end,
                deleteID = savedID,
                deleteName = data.name,
            }
        end
    end
    for index, entry in ipairs(entries) do
        local button = self:WizardButton(index)
        button:SetPoint("TOPLEFT", 20, -78 - ((index - 1) * 47))
        button.Text:SetText(entry.label)
        button:SetScript("OnClick", entry.action)
        if entry.deleteID then
            local deleteID = entry.deleteID
            local deleteName = entry.deleteName
            button.Text:ClearAllPoints()
            button.Text:SetPoint("LEFT", 12, 0)
            button.Text:SetPoint("RIGHT", -40, 0)
            button.Delete:SetScript("OnClick", function()
                Raid.pendingDeleteSavedRaidID = deleteID
                if StaticPopup_Show then
                    StaticPopup_Show(
                        "LUNARAIDS_DELETE_SAVED_RAID",
                        deleteName or "Saved Raid", nil, deleteID)
                else
                    Raid:DeleteSavedRaid(deleteID)
                end
            end)
            button.Delete:Show()
        end
        button:Show()
    end
end

function Raid:SetRaidWorkspaceVisible(visible)
    for _, frame in ipairs(self.workspaceFrames or {}) do
        frame:SetShown(visible)
    end
    for _, button in ipairs(self.raidActionButtons or {}) do
        button:SetShown(visible)
    end
    if visible then self:RefreshWorkspaceNavigation() end
end

function Raid:ExitNewRaidWizard()
    if not self.db.raidLocked then
        if self.newRaidWizard then self.newRaidWizard:Show() end
        return
    end
    if self.newRaidWizard then self.newRaidWizard:Hide() end
    self:SetRaidPickerMode(false)
    if self.db.raidLocked then
        self:SetRaidWorkspaceVisible(true)
        self:RefreshAll()
    elseif self.frame then
        self:SetRaidWorkspaceVisible(true)
        self:RefreshWorkspaceNavigation()
        self:RefreshAssignments()
    end
end

function Raid:FinishOpeningNewRaid(saveCurrent, name)
    if not self:CanStartRaid() then
        self:Print(
            "Only the raid leader can create or load the active raid.")
        return
    end
    if saveCurrent then
        self:SaveCurrentRaid(name)
    end
    self:ClearCurrentRaidSession()
    self:ShowNewRaidWizard(false)
end

function Raid:RequestNewRaid()
    if not self:CanStartRaid() then
        self:Print(
            "Only the raid leader can create or load the active raid.")
        return
    end
    if not self.db.raidLocked then
        self:ShowNewRaidWizard(false)
        return
    end
    local saved = self.db.activeSavedRaid
        and self.db.savedRaids[self.db.activeSavedRaid]
    if saved then
        self:SaveCurrentRaid(saved.name)
        self:FinishOpeningNewRaid(false)
        return
    end
    if StaticPopup_Show then
        local raid = self:GetRaid()
        local popup = StaticPopup_Show(
            "LUNARAIDS_NEW_RAID_SAVE", raid.name)
        local editBox = self:GetPopupEditBox(popup)
        if editBox then
            editBox:SetText(raid.name .. " Plan")
            editBox:HighlightText()
            editBox:SetFocus()
        end
    else
        self:FinishOpeningNewRaid(false)
    end
end

function Raid:ShowNewRaidWizard(clearCurrentRaid)
    if not self:CanStartRaid() then
        self:Print(
            "Only the raid leader can create or load the active raid.")
        return
    end
    if clearCurrentRaid then
        self:ClearCurrentRaidSession()
    end
    local wizard = self:CreateNewRaidWizard()
    if self.settingsView then self.settingsView:Hide() end
    wizard.step = "EXPANSION"
    wizard.expansion = self.db.newRaidExpansion
        or self.db.activeExpansion
    if self.bossSettingsPanel then self.bossSettingsPanel:Hide() end
    self.workspaceMode = "ASSIGNMENTS"
    self.activeBossTab = "ASSIGNMENTS"
    self:SetRaidWorkspaceVisible(true)
    self:SetRaidPickerMode(true)
    self:UpdateRoster()
    self:RefreshWorkspaceNavigation()
    for _, button in ipairs(self.assignmentActionButtons or {}) do
        button:Hide()
    end
    if self.generalFooterActionButtons
        and self.generalFooterActionButtons[2]
    then
        self.generalFooterActionButtons[2]:Hide()
    end
    self:RefreshFooterLayout()
    self:UpdateWindowLayout()
    self.frame.Title:SetText("LUNA RAIDS")
    if self.frame.Subtitle then
        self.frame.Subtitle:SetText("CREATE OR LOAD A RAID PLAN")
    end
    wizard:Show()
    self:RefreshNewRaidWizard()
end

function Raid:EnterBossUI(initialWorkspace)
    self:CreateUI()
    if self.newRaidWizard then self.newRaidWizard:Hide() end
    self:SetRaidPickerMode(false)
    if self.settingsView then self.settingsView:Hide() end
    self:SetRaidWorkspaceVisible(true)
    if self.manualPlayerPanel then self.manualPlayerPanel:Hide() end
    if self.bossSettingsPanel then self.bossSettingsPanel:Hide() end
    self.workspaceMode = initialWorkspace == "ASSIGNMENTS"
        and "ASSIGNMENTS" or "GROUPS"
    self.activeBossTab = "ASSIGNMENTS"
    self:UpdateRoster()
    self:RefreshAll()
    self.frame:Show()
end

function Raid:PromptSaveRaid()
    local current = self.db.activeSavedRaid
        and self.db.savedRaids[self.db.activeSavedRaid]
    if current then
        self:SaveCurrentRaid(current.name)
        return
    end
    if StaticPopup_Show then
        local popup = StaticPopup_Show("LUNARAIDS_SAVE_RAID")
        local editBox = self:GetPopupEditBox(popup)
        if editBox then
            editBox:SetText(
                self:GetRaid().name .. " Plan")
            editBox:HighlightText()
        end
    else
        self:SaveCurrentRaid(self:GetRaid().name .. " Plan")
    end
end

function Raid:RefreshRaidIdentityHeader()
    if not self.assignmentRaidTitle
        or not self.assignmentRaidIcon
    then
        return
    end
    local raid = self:GetRaid()
    self.assignmentRaidTitle:SetText(
        raid and raid.name:upper() or "NO RAID SELECTED")
    self.assignmentRaidIcon:SetTexture(
        raid and raid.icon
            or "Interface\\Icons\\INV_BannerPVP_02")
end

function Raid:RedrawWorkspace()
    if not self.frame or not self.assignmentPanel then return end
    if self.settingsView and self.settingsView:IsShown() then
        self:SetRaidWorkspaceVisible(false)
        self:RefreshSettingsView()
        self:UpdateWindowLayout()
        return
    end
    self:RefreshWorkspaceNavigation()
    -- Full-width workspaces (Groups, Status, and Gear) read self.roster
    -- directly while the assignment sidebar is hidden. Rebuild the sidebar
    -- whenever navigation makes it visible again so its rows and count can
    -- never remain at their pre-login state.
    if self.workspaceMode == "ASSIGNMENTS"
        and not self.raidPickerActive
        and self.rosterPanel and self.rosterPanel:IsShown()
    then
        self:RefreshRoster()
    end
    self:UpdateWindowLayout()
    self:RefreshAssignments()
    self:UpdateWindowLayout()

    -- Anchored frame dimensions are finalized at the end of the UI tick.
    -- Repeat the layout once then so navigating never inherits measurements
    -- from the previously visible workspace.
    self.workspaceRedrawToken = (self.workspaceRedrawToken or 0) + 1
    local token = self.workspaceRedrawToken
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if token ~= Raid.workspaceRedrawToken
                or not Raid.frame or not Raid.frame:IsShown()
                or Raid.settingsView
                    and Raid.settingsView:IsShown()
            then
                return
            end
            if Raid.workspaceMode == "ASSIGNMENTS"
                and not Raid.raidPickerActive
                and Raid.rosterPanel and Raid.rosterPanel:IsShown()
            then
                Raid:RefreshRoster()
            end
            Raid:UpdateWindowLayout()
            Raid:RefreshAssignments()
            Raid:UpdateWindowLayout()
        end)
    end
end

function Raid:RefreshAll()
    if self.settingsView and self.settingsView:IsShown() then
        self:SetRaidWorkspaceVisible(false)
        if self.newRaidWizard then self.newRaidWizard:Hide() end
        self:RefreshSettingsView()
        self:UpdateWindowLayout()
        return
    end
    if self.raidPickerActive then
        self:SetRaidPickerMode(true)
        self:RefreshWorkspaceNavigation()
        if self.frame and self.frame.Title then
            self.frame.Title:SetText("LUNA RAIDS")
            if self.frame.Subtitle then
                self.frame.Subtitle:SetText(
                    "CREATE OR LOAD A RAID PLAN")
            end
        end
        return
    end
    local canEdit = self:IsLocalRaidEditor()
    for _, button in ipairs(self.editorActionButtons or {}) do
        if canEdit then button:Show() else button:Hide() end
    end
    if not canEdit then
        self.selectedPlayer = nil
        self.dragPlayer = nil
        self:HideDragGhost()
        if self.roleMenu then self.roleMenu:Hide() end
        if self.bossSettingsPanel then self.bossSettingsPanel:Hide() end
    end
    self:RefreshBossRail()
    self:RefreshRaidIdentityHeader()
    self:RefreshRoster()
    self:RedrawWorkspace()
    if self.newRaidWizard and self.newRaidWizard:IsShown()
        and self.frame and self.frame.Title
    then
        self.frame.Title:SetText("LUNA RAIDS")
        if self.frame.Subtitle then
            self.frame.Subtitle:SetText("CREATE OR LOAD A RAID PLAN")
        end
    end
end

function Raid:ApplyPixelSnapping()
    if not self.frame then return end
    SnapTree(self.frame, {})
end

function Raid:UI_SCALE_CHANGED()
    if self.frame and self.frame:IsShown() then
        self:RedrawWorkspace()
    end
    if self.readyCheckWindow then
        FitAndClampToScreen(self.readyCheckWindow)
    end
    if self.quickActionBar then
        FitAndClampToScreen(self.quickActionBar)
    end
    self:ApplyPixelSnapping()
end

function Raid:UpdateWindowLayout()
    if not self.frame or not self.assignmentPanel then return end
    local rowWidth = PixelForRegion(
        self.assignmentPanel,
        math.max(520, self.assignmentPanel:GetWidth() - 12))
    self.assignmentRowWidth = rowWidth
    self.assignmentContent:SetWidth(rowWidth)
    for _, slot in ipairs(self.assignmentSlots or {}) do
        slot:SetWidth(rowWidth)
    end
    for _, row in ipairs(self.markerRows or {}) do
        row:SetWidth(rowWidth)
    end
    for _, line in ipairs(self.mechanicLines or {}) do
        line:SetWidth(rowWidth)
        line.Text:SetWidth(rowWidth - 56)
    end
    if self.assignmentPanel.ProgressTrack then
        local oldWidth =
            math.max(1, self.assignmentPanel.ProgressTrack:GetWidth())
        local progress = math.min(
            1, self.assignmentPanel.ProgressFill:GetWidth() / oldWidth)
        self.assignmentPanel.ProgressTrack:SetWidth(rowWidth)
        self.assignmentPanel.ProgressFill:SetWidth(
            math.max(1, rowWidth * progress))
    end
    local tabCount = 0
    for _ in pairs(self.bossTabs or {}) do
        tabCount = tabCount + 1
    end
    -- During OnSizeChanged, anchored child widths may still report their
    -- previous value. Derive the assignment pane from the window itself so
    -- the tab row can never retain an oversized layout.
    local panelWidth = math.max(
        1, (self.frame:GetWidth() or FRAME_WIDTH) - ROSTER_WIDTH - 2)
    local tabWidth = PixelForRegion(
        self.assignmentPanel,
        math.max(
            1,
            (panelWidth - 10
                - (math.max(1, tabCount) - 1) * 6)
                / math.max(1, tabCount)))
    for _, tab in pairs(self.bossTabs or {}) do
        tab:SetWidth(tabWidth)
    end
    if self.newRaidWizard then
        local wizardWidth = math.max(
            1, self.newRaidWizard:GetWidth() - 40)
        for _, button in ipairs(self.newRaidWizard.Buttons or {}) do
            button:SetWidth(wizardWidth)
        end
    end
    if self.settingsView and self.settingsView.Content then
        self.settingsView.Content:SetWidth(math.max(
            1, self.settingsView:GetWidth() - 28))
        if self.settingsView.Scroll.UpdateScrollbar then
            self.settingsView.Scroll:UpdateScrollbar()
        end
    end
    if self.rosterScroll and self.rosterScroll.UpdateScrollbar then
        self.rosterScroll:UpdateScrollbar()
    end
    if self.assignmentScroll
        and self.assignmentScroll.UpdateScrollbar
    then
        self.assignmentScroll:UpdateScrollbar()
    end
    if self.workspaceMode == "ASSIGNMENTS"
        and self.db.raidLocked
        and not self.raidPickerActive
    then
        self:RefreshBossRail()
    end
end

function Raid:CreateUI()
    if self.frame then return end
    local frame = BackdropFrame(
        "Frame", "LunaRaidsLeaderFrame", UIParent)
    UISpecialFrames = UISpecialFrames or {}
    local registered
    for _, frameName in ipairs(UISpecialFrames) do
        if frameName == "LunaRaidsLeaderFrame" then
            registered = true
            break
        end
    end
    if not registered then
        UISpecialFrames[#UISpecialFrames + 1] =
            "LunaRaidsLeaderFrame"
    end
    PixelSetSize(
        frame,
        math.max(860, self.db.window.width or FRAME_WIDTH),
        math.max(520, self.db.window.height or FRAME_HEIGHT))
    frame:SetPoint(
        self.db.window.point or "CENTER", UIParent,
        self.db.window.point or "CENTER",
        self.db.window.x or 0, self.db.window.y or 0)
    frame:SetScale(1)
    -- Keep the complete workspace above ordinary unit frames and HUD
    -- elements. Blizzard dialogs use DIALOG/FULLSCREEN_DIALOG and therefore
    -- still remain above it.
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(100)
    frame:SetClampedToScreen(false)
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(860, 520, 1600, 1200)
    else
        frame:SetMinResize(860, 520)
        frame:SetMaxResize(1600, 1200)
    end
    frame:EnableMouse(true)
    frame.OpenAnimation = frame:CreateAnimationGroup()
    local openFade = frame.OpenAnimation:CreateAnimation("Alpha")
    openFade:SetFromAlpha(0)
    openFade:SetToAlpha(1)
    openFade:SetDuration(.18)
    openFade:SetSmoothing("OUT")
    frame.OpenAnimation:SetScript("OnPlay", function()
        frame:SetAlpha(0)
    end)
    frame.OpenAnimation:SetScript("OnFinished", function()
        frame:SetAlpha(1)
    end)
    frame:SetScript("OnShow", function()
        frame.OpenAnimation:Stop()
        frame.OpenAnimation:Play()
        -- Startup roster events can fire before CreateUI has built the
        -- sidebar. Re-read the live group now that every roster widget exists.
        Raid:UpdateRoster()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if frame:IsShown() then
                    Raid:RedrawWorkspace()
                end
            end)
        else
            Raid:RedrawWorkspace()
        end
    end)
    frame:SetScript("OnHide", function()
        frame:StopMovingOrSizing()
        Raid:HideDragGhost()
        Raid.dragPlayer = nil
        if Raid.roleMenu then Raid.roleMenu:Hide() end
        if Raid.raidPlayerMenu then Raid.raidPlayerMenu:Hide() end
        ResetCursor()
    end)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint(1)
        Raid.db.window.point = point
        Raid.db.window.x, Raid.db.window.y = x, y
    end)
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.gearScoreElapsed =
            (self.gearScoreElapsed or 0) + elapsed
        if self.gearScoreElapsed >= 10 then
            self.gearScoreElapsed = 0
            Raid:UpdateGearScores()
        end
    end)
    frame.BrandIcon = frame:CreateTexture(nil, "OVERLAY")
    frame.BrandIcon:SetTexture("Interface\\Icons\\INV_BannerPVP_02")
    PixelSetSize(frame.BrandIcon, 30, 30)
    frame.BrandIcon:SetPoint("TOPLEFT", 12, -7)
    frame.Title = Font(frame, 15, "text", "LUNA RAID LEADER")
    frame.Title:SetPoint("LEFT", frame.BrandIcon, "RIGHT", 10, 4)
    frame.Subtitle = Font(frame, 9, "muted", "TACTICAL RAID PLANNER")
    frame.Subtitle:SetPoint("TOPLEFT", frame.Title, "BOTTOMLEFT", 0, -1)
    frame.WindowBg = frame:CreateTexture(nil, "BACKGROUND")
    frame.WindowBg:SetTexture(WHITE)
    frame.WindowBg:SetAllPoints()
    frame.WindowBg:SetVertexColor(.018, .028, .04, .98)
    frame.TitleBarBg = frame:CreateTexture(nil, "ARTWORK")
    frame.TitleBarBg:SetTexture(WHITE)
    frame.TitleBarBg:SetPoint("TOPLEFT", 1, -1)
    frame.TitleBarBg:SetPoint("TOPRIGHT", -1, -1)
    frame.TitleBarBg:SetHeight(45)
    frame.TitleBarBg:SetVertexColor(.022, .082, .118, .99)
    frame.TitleAccent = frame:CreateTexture(nil, "OVERLAY")
    frame.TitleAccent:SetTexture(WHITE)
    frame.TitleAccent:SetPoint("TOPLEFT", 1, -44)
    frame.TitleAccent:SetPoint("TOPRIGHT", -1, -44)
    SetPixelHeight(frame.TitleAccent, 2)
    frame.TitleAccent:SetVertexColor(unpack(ACCENT))
    frame.DarkInset = frame:CreateTexture(nil, "BORDER")
    frame.DarkInset:SetTexture(WHITE)
    frame.DarkInset:SetPoint("TOPLEFT", 1, -46)
    frame.DarkInset:SetPoint("BOTTOMRIGHT", -1, 58)
    frame.DarkInset:SetVertexColor(.008, .015, .024, .88)
    frame.StatusBg = frame:CreateTexture(nil, "ARTWORK")
    frame.StatusBg:SetTexture(WHITE)
    frame.StatusBg:SetPoint("TOPLEFT", frame.DarkInset, "BOTTOMLEFT")
    frame.StatusBg:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.StatusBg:SetVertexColor(.018, .068, .092, .99)
    frame.OuterBorder = BackdropFrame("Frame", nil, frame)
    frame.OuterBorder:SetAllPoints()
    frame.OuterBorder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = Pixel(12),
    })
    frame.OuterBorder:SetBackdropBorderColor(.22, .22, .22, 1)
    frame.OuterBorder:EnableMouse(false)
    frame.Title:SetDrawLayer("OVERLAY", 3)

    frame.CloseButton = Button(frame, "X", 28, 28)
    frame.CloseButton:SetPoint("TOPRIGHT", -7, -8)
    frame.CloseButton.Text:SetFont(
        "Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    frame.CloseButton.Text:SetTextColor(.72, .79, .84)
    frame.CloseButton:SetScript("OnClick", function() frame:Hide() end)
    frame.CloseButton:HookScript("OnEnter", function(self)
        self:SetBackdropColor(.22, .045, .055, .98)
        self:SetBackdropBorderColor(.92, .22, .28, 1)
        self.Text:SetTextColor(1, .82, .84)
    end)
    frame.CloseButton:HookScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(self.baseColor))
        self:SetBackdropBorderColor(unpack(self.baseBorder))
        self.Text:SetTextColor(.72, .79, .84)
    end)
    AddButtonTooltip(
        frame.CloseButton, "Close LunaRaids",
        "Hide the LunaRaids window. Your active raid remains open.")
    self.frame = frame

    self.workspaceMode = self.workspaceMode or "GROUPS"
    self.workspaceRail = Panel(frame)
    self.workspaceRail:SetPoint(
        "TOPRIGHT", frame, "TOPLEFT", 1, -45)
    self.workspaceRail:SetWidth(NAV_RAIL_WIDTH)
    self.workspaceRail:SetHeight(266)
    self.workspaceRail:SetFrameLevel(frame:GetFrameLevel() + 3)
    self.workspaceButtons = {}
    local workspaceEntries = {
        {
            key = "ASSIGNMENTS",
            title = "Raid Assignments",
            description =
                "Open boss markers, assignments, and mechanics.",
            icon = "Interface\\Icons\\INV_Misc_Note_05",
        },
        {
            key = "GROUPS",
            title = "Raid Groups",
            description =
                "Arrange the raid's eight Blizzard groups.",
            icon = "Interface\\Icons\\INV_Misc_GroupLooking",
        },
        {
            key = "STATUS",
            title = "Raid Status",
            description =
                "View ready-check results, buffs, and consumables.",
            icon = "Interface\\RaidFrame\\ReadyCheck-Ready",
        },
        {
            key = "GEAR",
            title = "Gear Inspect",
            description =
                "Inspect the current raid's equipped items and item levels.",
            icon = "Interface\\Icons\\INV_Chest_Plate04",
        },
        {
            key = "SETTINGS",
            title = "LunaRaids Settings",
            description =
                "Configure interface, communication, and automation.",
            icon = "Interface\\Buttons\\UI-OptionsButton",
        },
        {
            key = "ABOUT",
            title = "About LunaRaids",
            description =
                "View project credits, source code, and support links.",
            icon = "Interface\\Icons\\INV_Misc_QuestionMark",
        },
    }
    for index, entry in ipairs(workspaceEntries) do
        local workspaceKey = entry.key
        local button = Button(self.workspaceRail, "", 38, 38)
        button:SetPoint("TOPLEFT", 5, -5 - ((index - 1) * 43))
        button.Icon = button:CreateTexture(nil, "ARTWORK")
        button.Icon:SetTexture(entry.icon)
        PixelSetSize(button.Icon, 24, 24)
        button.Icon:SetPoint("CENTER")
        button.Text:Hide()
        button.ActiveBar = button:CreateTexture(nil, "OVERLAY")
        button.ActiveBar:SetTexture(WHITE)
        button.ActiveBar:SetPoint("TOPRIGHT", -1, -1)
        button.ActiveBar:SetPoint("BOTTOMRIGHT", -1, 1)
        SetPixelWidth(button.ActiveBar, 3)
        button.ActiveBar:SetVertexColor(unpack(ACCENT))
        button:SetScript("OnClick", function()
            Raid:SetWorkspaceMode(workspaceKey)
        end)
        AddButtonTooltip(button, entry.title, entry.description)
        self.workspaceButtons[workspaceKey] = button
    end

    self.bossRail = Panel(frame)
    self.bossRail:SetPoint(
        "TOPLEFT", frame, "TOPRIGHT", -1, -45)
    self.bossRail:SetWidth(BOSS_RAIL_WIDTH)
    self.bossRail:SetFrameLevel(frame:GetFrameLevel() + 3)
    local rosterPanel = Panel(frame)
    self.rosterPanel = rosterPanel
    rosterPanel:SetPoint("TOPLEFT", 12, -59)
    rosterPanel:SetPoint("BOTTOMLEFT", 12, 68)
    rosterPanel:SetWidth(ROSTER_WIDTH)
    rosterPanel.Divider = rosterPanel:CreateTexture(nil, "OVERLAY")
    rosterPanel.Divider:SetTexture(WHITE)
    rosterPanel.Divider:SetPoint("TOPRIGHT", 0, 0)
    rosterPanel.Divider:SetPoint("BOTTOMRIGHT", 0, 0)
    SetPixelWidth(rosterPanel.Divider, 1)
    rosterPanel.Divider:SetVertexColor(.13, .27, .35, .9)
    local rosterIcon = rosterPanel:CreateTexture(nil, "ARTWORK")
    rosterIcon:SetTexture("Interface\\Icons\\INV_Misc_GroupLooking")
    PixelSetSize(rosterIcon, 22, 22)
    rosterIcon:SetPoint("TOPLEFT", 10, -9)
    local rosterTitle = Font(rosterPanel, 12, "accent", "RAID ROSTER")
    rosterTitle:SetPoint("LEFT", rosterIcon, "RIGHT", 7, 0)
    self.rosterCount = Font(rosterPanel, 9, "muted", "0 players")
    self.rosterCount:SetPoint("TOPRIGHT", -42, -13)
    local addPlanned = Button(rosterPanel, "+", 27, 27)
    addPlanned:SetPoint("TOPRIGHT", -8, -7)
    StyleButton(addPlanned, "primary")
    addPlanned:SetScript(
        "OnClick", function() Raid:ShowManualPlayerPanel() end)
    addPlanned:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Add Planned Player")
        GameTooltip:AddLine(
            "Add someone before they join the live raid.",
            MUTED[1], MUTED[2], MUTED[3], true)
        GameTooltip:Show()
    end)
    addPlanned:HookScript("OnLeave", function() GameTooltip:Hide() end)
    self.rosterScroll, self.rosterContent =
        CreateScrollArea(rosterPanel)
    self.rosterScroll:SetPoint("TOPLEFT", 6, -40)
    self.rosterScroll:SetPoint("BOTTOMRIGHT", -6, 8)
    self.rosterContent:SetWidth(ROSTER_ROW_WIDTH)

    local assignmentPanel = Panel(frame)
    self.assignmentPanel = assignmentPanel
    assignmentPanel:SetPoint("TOPLEFT", rosterPanel, "TOPRIGHT", 10, 0)
    assignmentPanel:SetPoint("BOTTOMRIGHT", -12, 68)
    self.bossRail:SetParent(assignmentPanel)
    self.bossRail:ClearAllPoints()
    self.bossRail:SetPoint("TOPLEFT", 8, -42)
    self.bossRail:SetPoint("TOPRIGHT", -8, -42)
    self.bossRail:SetHeight(
        BOSS_BUTTON_SIZE + (BOSS_RAIL_GAP * 2))
    self.bossRail:SetFrameLevel(assignmentPanel:GetFrameLevel() + 3)
    self.bossRail:SetBackdropColor(.018, .045, .062, .88)
    self.bossRail:SetBackdropBorderColor(0, 0, 0, 0)
    if self.bossRail.InnerGlow then self.bossRail.InnerGlow:Hide() end
    if self.bossRail.TopLine then self.bossRail.TopLine:Hide() end
    self.bossRail.BottomLine =
        self.bossRail:CreateTexture(nil, "ARTWORK")
    self.bossRail.BottomLine:SetTexture(WHITE)
    self.bossRail.BottomLine:SetPoint("BOTTOMLEFT", 0, 0)
    self.bossRail.BottomLine:SetPoint("BOTTOMRIGHT", 0, 0)
    SetPixelHeight(self.bossRail.BottomLine, 1)
    self.bossRail.BottomLine:SetVertexColor(.12, .28, .38, .9)
    assignmentPanel.Watermark =
        assignmentPanel:CreateTexture(nil, "BACKGROUND")
    assignmentPanel.Watermark:SetTexture(
        "Interface\\Icons\\INV_BannerPVP_02")
    PixelSetSize(assignmentPanel.Watermark, 260, 260)
    assignmentPanel.Watermark:SetPoint("CENTER", 0, -10)
    assignmentPanel.Watermark:SetAlpha(.035)
    self.assignmentRaidIcon =
        assignmentPanel:CreateTexture(nil, "ARTWORK")
    self.assignmentRaidIcon:SetTexture(
        "Interface\\Icons\\INV_BannerPVP_02")
    PixelSetSize(self.assignmentRaidIcon, 28, 28)
    self.assignmentRaidIcon:SetPoint("TOPLEFT", 9, -7)
    self.assignmentRaidTitle =
        Font(assignmentPanel, 12, "accent", "NO RAID SELECTED")
    self.assignmentRaidTitle:SetPoint(
        "TOPLEFT", self.assignmentRaidIcon, "TOPRIGHT", 8, -1)
    self.assignmentTitle =
        Font(assignmentPanel, 9, "muted", "ASSIGNMENTS")
    self.assignmentTitle:SetPoint(
        "TOPLEFT", self.assignmentRaidTitle, "BOTTOMLEFT", 0, -1)
    self.bossSettingsButton = Button(assignmentPanel, "", 29, 29)
    self.bossSettingsButton:SetPoint("TOPRIGHT", -8, -7)
    self.bossSettingsButton.Cog =
        self.bossSettingsButton:CreateTexture(nil, "OVERLAY")
    self.bossSettingsButton.Cog:SetTexture(
        "Interface\\Buttons\\UI-OptionsButton")
    PixelSetSize(self.bossSettingsButton.Cog, 18, 18)
    self.bossSettingsButton.Cog:SetPoint("CENTER")
    self.bossSettingsButton:SetScript(
        "OnClick", function() Raid:ToggleBossSettings() end)
    self.bossSettingsButton:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Boss Assignment Setup")
        GameTooltip:AddLine(
            "Change assignment counts for this boss only.",
            MUTED[1], MUTED[2], MUTED[3], true)
        GameTooltip:Show()
    end)
    self.bossSettingsButton:HookScript(
        "OnLeave", function() GameTooltip:Hide() end)
    self.setCurrentBossButton =
        Button(assignmentPanel, "SET CURRENT BOSS", 142, 29)
    self.setCurrentBossButton:SetPoint(
        "RIGHT", self.bossSettingsButton, "LEFT", -6, 0)
    self.setCurrentBossButton:SetScript("OnClick", function()
        Raid:SetCurrentBoss(Raid.db.activeEncounter)
    end)
    AddButtonTooltip(
        self.setCurrentBossButton, "Set Current Boss",
        "Show this boss's assignments in each player's Your Assignments panel.")
    self.activeBossTab = self.activeBossTab or "ASSIGNMENTS"
    self.bossTabs = {}
    local tabEntries = {
        { key = "MARKERS", label = "MARKERS",
            icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8" },
        { key = "ASSIGNMENTS", label = "ASSIGNMENTS",
            icon = "Interface\\Icons\\INV_Misc_Note_05" },
        { key = "MECHANICS", label = "MECHANICS",
            icon = "Interface\\Icons\\INV_Misc_Book_09" },
    }
    local previousTab
    for _, entry in ipairs(tabEntries) do
        local tab = Button(assignmentPanel, entry.label, 214, 32)
        if previousTab then
            tab:SetPoint("TOPLEFT", previousTab, "TOPRIGHT", 6, 0)
        else
            tab:SetPoint("TOPLEFT", 8, -45)
        end
        AddButtonIcon(tab, entry.icon)
        PixelSetSize(tab.ActionIcon, 15, 15)
        tab.Text:ClearAllPoints()
        tab.Text:SetPoint("LEFT", 31, 0)
        tab.Text:SetPoint("RIGHT", -6, 0)
        tab.Text:SetJustifyH("LEFT")
        tab.ActiveLine = tab:CreateTexture(nil, "OVERLAY")
        tab.ActiveLine:SetTexture(WHITE)
        tab.ActiveLine:SetPoint("BOTTOMLEFT", 1, 0)
        tab.ActiveLine:SetPoint("BOTTOMRIGHT", -1, 0)
        SetPixelHeight(tab.ActiveLine, 2)
        tab.ActiveLine:SetVertexColor(unpack(ACCENT))
        tab.tabKey = entry.key
        tab:SetScript("OnClick", function(self)
            Raid:SetBossTab(self.tabKey)
        end)
        tab:HookScript("OnEnter", function() Raid:RefreshBossTabs() end)
        tab:HookScript("OnLeave", function() Raid:RefreshBossTabs() end)
        self.bossTabs[entry.key] = tab
        previousTab = tab
    end
    assignmentPanel.ProgressTrack =
        assignmentPanel:CreateTexture(nil, "ARTWORK")
    assignmentPanel.ProgressTrack:SetTexture(WHITE)
    assignmentPanel.ProgressTrack:SetPoint("TOPLEFT", 8, -80)
    PixelSetSize(
        assignmentPanel.ProgressTrack, ASSIGNMENT_ROW_WIDTH, 2)
    SetPixelHeight(assignmentPanel.ProgressTrack, 2)
    assignmentPanel.ProgressTrack:SetVertexColor(.10, .16, .20, 1)
    assignmentPanel.ProgressFill =
        assignmentPanel:CreateTexture(nil, "OVERLAY")
    assignmentPanel.ProgressFill:SetTexture(WHITE)
    assignmentPanel.ProgressFill:SetPoint(
        "LEFT", assignmentPanel.ProgressTrack, "LEFT", 0, 0)
    SetPixelHeight(assignmentPanel.ProgressFill, 2)
    assignmentPanel.ProgressFill:SetVertexColor(unpack(ACCENT))
    self.assignmentScroll, self.assignmentContent =
        CreateScrollArea(assignmentPanel)
    self.assignmentScroll:SetPoint("TOPLEFT", 6, -84)
    self.assignmentScroll:SetPoint("BOTTOMRIGHT", -6, 8)
    self.assignmentContent:SetWidth(ASSIGNMENT_ROW_WIDTH)

    local newRaid = Button(frame, "NEW RAID", 100, 30)
    newRaid:SetPoint("BOTTOMLEFT", 12, 14)
    AddButtonIcon(
        newRaid, "Interface\\Icons\\INV_Misc_GroupLooking", 16)
    newRaid:SetScript("OnClick", function()
        Raid:RequestNewRaid()
    end)
    AddButtonTooltip(
        newRaid, "New Raid",
        "Open raid setup to create a new plan or load a saved raid.")
    local clear = Button(frame, "CLEAR BOSS", 104, 30)
    clear:SetPoint("LEFT", newRaid, "RIGHT", 5, 0)
    AddButtonIcon(
        clear, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", 16)
    clear:SetScript("OnClick", function() Raid:ClearPlan() end)
    AddButtonTooltip(
        clear, "Clear Boss",
        "Remove every player, healing target, and marker assignment from the current boss.")
    local saveRaid = Button(frame, "SAVE RAID", 110, 30)
    saveRaid:SetPoint("LEFT", clear, "RIGHT", 5, 0)
    AddButtonIcon(
        saveRaid, "Interface\\Icons\\INV_Misc_Note_01", 16)
    saveRaid:SetScript("OnClick", function() Raid:PromptSaveRaid() end)
    AddButtonTooltip(
        saveRaid, "Save Raid",
        "Save the complete raid plan so it can be loaded before a future raid.")
    local whisper = Button(frame, "WHISPER", 114, 30)
    whisper:SetPoint("BOTTOMRIGHT", -163, 14)
    StyleButton(whisper, "positive")
    AddButtonIcon(whisper, "Interface\\Icons\\INV_Letter_15", 16)
    whisper:SetScript("OnClick", function() Raid:WhisperAssignments() end)
    AddButtonTooltip(
        whisper, "Whisper Roles",
        "Whisper each selected player their assignments for the current boss.")
    local announce = Button(frame, "ANNOUNCE", 134, 30)
    announce:SetPoint("BOTTOMRIGHT", -24, 14)
    StyleButton(announce, "primary")
    AddButtonIcon(
        announce, "Interface\\Icons\\Ability_Warrior_BattleShout", 16)
    announce:SetScript("OnClick", function() Raid:AnnounceAssignments() end)
    AddButtonTooltip(
        announce, "Announce Assignments",
        "Post the current boss assignments and markers in Raid Warning.")
    self.workspaceFrames = {
        self.bossRail, rosterPanel, assignmentPanel,
    }
    self.raidActionButtons = {
        newRaid, clear, saveRaid, whisper, announce,
    }
    self.editorActionButtons = {
        addPlanned, self.bossSettingsButton,
        newRaid, clear, saveRaid, whisper, announce,
    }
    self.assignmentActionButtons = {
        clear, whisper, announce,
    }
    self.generalFooterActionButtons = {
        newRaid, saveRaid,
    }
    self.footerActionButtons = {
        newRaid, clear, saveRaid, whisper, announce,
    }
    self.footerLeftButtons = {
        newRaid, clear, saveRaid,
    }
    self.footerRightButtons = {
        announce, whisper,
    }
    self:RefreshWorkspaceNavigation()

    frame.ResizeGrip = CreateFrame("Button", nil, frame)
    PixelSetSize(frame.ResizeGrip, 20, 20)
    frame.ResizeGrip:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.ResizeGrip:SetFrameLevel(frame:GetFrameLevel() + 20)
    frame.ResizeGrip:SetNormalTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    frame.ResizeGrip:SetHighlightTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    frame.ResizeGrip:SetPushedTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    frame.ResizeGrip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            frame.isUserResizing = true
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)
    frame.ResizeGrip:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        frame.isUserResizing = nil
        local snappedWidth =
            PixelForRegion(frame, frame:GetWidth())
        local snappedHeight =
            PixelForRegion(frame, frame:GetHeight())
        frame.pixelResizeGuard = true
        frame:SetSize(snappedWidth, snappedHeight)
        frame.pixelResizeGuard = nil
        Raid.db.window.width =
            math.floor(frame:GetWidth() + .5)
        Raid.db.window.height =
            math.floor(frame:GetHeight() + .5)
        Raid:UpdateWindowLayout()
        Raid:RefreshAssignments()
        Raid:ApplyPixelSnapping()
    end)
    AddButtonTooltip(
        frame.ResizeGrip, "Resize",
        "Drag to resize the LunaRaids window.")
    frame:SetScript("OnSizeChanged", function(_, width, height)
        if frame.isUserResizing then
            Raid.db.window.width = width
            Raid.db.window.height = height
            return
        end
        if not frame.pixelResizeGuard then
            local snappedWidth = PixelForRegion(frame, width)
            local snappedHeight = PixelForRegion(frame, height)
            if math.abs(snappedWidth - width) > .0001
                or math.abs(snappedHeight - height) > .0001
            then
                frame.pixelResizeGuard = true
                frame:SetSize(snappedWidth, snappedHeight)
                frame.pixelResizeGuard = nil
                return
            end
        end
        Raid.db.window.width = math.floor(width + .5)
        Raid.db.window.height = math.floor(height + .5)
        Raid:UpdateWindowLayout()
    end)
    self:UpdateWindowLayout()
    -- OnEnable may already have populated self.roster, but its UI refresh is
    -- intentionally a no-op until rosterContent exists.
    self:UpdateRoster()
    frame:Hide()
end

function Raid:Toggle()
    self:CreateUI()
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
        if not self.db.raidLocked then
            if self:CanStartRaid() then
                self:ShowNewRaidWizard()
            else
                self.frame:Hide()
                self:Print(
                    "No active raid. Waiting for the raid leader to start one.")
            end
        else
            self:UpdateRoster()
            self:RefreshAll()
        end
    end
end

function Raid:RefreshMinimapButton()
    if not self.dbIcon then return end
    if self.db.minimap.hide then
        self.dbIcon:Hide("LunaRaids")
    else
        self.dbIcon:Show("LunaRaids")
    end
end

function Raid:InitializeDataBroker()
    if self.dataBroker then return end
    if not LibStub then
        self:Print("LibStub is unavailable; minimap launcher disabled.")
        return
    end
    local dataBroker = LibStub:GetLibrary(
        "LibDataBroker-1.1", true)
    local dbIcon = LibStub:GetLibrary("LibDBIcon-1.0", true)
    if not dataBroker or not dbIcon then
        self:Print(
            "LibDataBroker or LibDBIcon is unavailable; minimap launcher disabled.")
        return
    end
    self.dataBroker = dataBroker:NewDataObject("LunaRaids", {
        type = "launcher",
        label = "LunaRaids",
        icon = "Interface\\Icons\\INV_BannerPVP_02",
        OnClick = function(_, button)
            if button == "RightButton" then
                Raid:OpenSettings()
            else
                Raid:Toggle()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("LunaRaids", 1, 1, 1)
            tooltip:AddLine(
                "Left-click to open raid assignments.",
                .82, .82, .82)
            tooltip:AddLine(
                "Right-click to open settings.",
                .82, .82, .82)
            tooltip:AddLine(
                "Drag to reposition.", .62, .62, .62)
            tooltip:AddLine(
                "/lr minimap to hide or restore.",
                .35, .72, 1)
        end,
    })
    self.dbIcon = dbIcon
    if not dbIcon:IsRegistered("LunaRaids") then
        dbIcon:Register(
            "LunaRaids", self.dataBroker, self.db.minimap)
    end
    self:RefreshMinimapButton()
end
