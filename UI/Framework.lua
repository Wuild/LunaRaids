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

Raid.UI = {
    ROW_HEIGHT = ROW_HEIGHT,
    FRAME_WIDTH = FRAME_WIDTH,
    FRAME_HEIGHT = FRAME_HEIGHT,
    ROSTER_WIDTH = ROSTER_WIDTH,
    ROSTER_ROW_WIDTH = ROSTER_ROW_WIDTH,
    ASSIGNMENT_ROW_WIDTH = ASSIGNMENT_ROW_WIDTH,
    BOSS_RAIL_WIDTH = BOSS_RAIL_WIDTH,
    BOSS_BUTTON_SIZE = BOSS_BUTTON_SIZE,
    NAV_RAIL_WIDTH = NAV_RAIL_WIDTH,
    BOSS_RAIL_GAP = BOSS_RAIL_GAP,
    ACCENT = ACCENT,
    BORDER = BORDER,
    MUTED = MUTED,
    WHITE = WHITE,
    ROLE_TEXTURE = ROLE_TEXTURE,
    ROLE_COORDS = ROLE_COORDS,
    READY_CHECK_COLUMNS = READY_CHECK_COLUMNS,
    READY_CHECK_BY_SPELL = READY_CHECK_BY_SPELL,
    READY_CHECK_FOOD_MATCHES = READY_CHECK_FOOD_MATCHES,
    READY_CHECK_GRID_START = READY_CHECK_GRID_START,
    READY_CHECK_COLUMN_WIDTH = READY_CHECK_COLUMN_WIDTH,
    GEAR_INSPECT_SLOTS = GEAR_INSPECT_SLOTS,
    Pixel = Pixel,
    PixelForRegion = PixelForRegion,
    PhysicalPixels = PhysicalPixels,
    SetPixelHeight = SetPixelHeight,
    SetPixelWidth = SetPixelWidth,
    PixelSetSize = PixelSetSize,
    FitAndClampToScreen = FitAndClampToScreen,
    SnapAnchors = SnapAnchors,
    SnapTree = SnapTree,
    BackdropFrame = BackdropFrame,
    Font = Font,
    InstallPixelBorder = InstallPixelBorder,
    Button = Button,
    StyleButton = StyleButton,
    AddButtonIcon = AddButtonIcon,
    AddDropdownArrow = AddDropdownArrow,
    AddButtonTooltip = AddButtonTooltip,
    Panel = Panel,
    SectionHeader = SectionHeader,
    EditField = EditField,
    ShowSelectionMenu = ShowSelectionMenu,
    ShowMultiSelectionMenu = ShowMultiSelectionMenu,
    CurrentGuildRankEntries = CurrentGuildRankEntries,
    SetClassText = SetClassText,
    GetClassRowColor = GetClassRowColor,
    CreateScrollArea = CreateScrollArea,
}
