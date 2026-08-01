local _, Raid = ...
local UI = Raid.UI
local L = Raid.L

local WHITE = UI.WHITE
local ACCENT = UI.ACCENT
local Font = UI.Font

function Raid:GetMechanicsHUDSettings()
    return self.db.mechanicsHUD
end

function Raid:CreateMechanicsHUD()
    if self.mechanicsHUDFrame then return self.mechanicsHUDFrame end
    local settings = self:GetMechanicsHUDSettings()
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(settings.width or 430, 100)
    frame:SetPoint(settings.point or "CENTER", UIParent,
        settings.point or "CENTER", settings.x or 330, settings.y or 120)
    frame:SetFrameStrata("MEDIUM")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetBackdrop({ bgFile = WHITE })
    frame:SetBackdropColor(0, 0, 0, 0)
    frame:SetScript("OnDragStart", function(self)
        if Raid:GetMechanicsHUDSettings().locked then return end
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint(1)
        local current = Raid:GetMechanicsHUDSettings()
        current.point, current.x, current.y = point, x, y
    end)
    frame.Header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.Header:SetPoint("TOPLEFT")
    frame.Header:SetPoint("TOPRIGHT")
    frame.Header:SetHeight(30)
    frame.Header:SetBackdrop({
        bgFile = WHITE, edgeFile = WHITE, edgeSize = 1,
    })
    frame.Header:SetBackdropColor(.025, .070, .090, .98)
    frame.Header:SetBackdropBorderColor(.12, .38, .48, .9)
    frame.Title = Font(frame.Header, 10, "accent", L.MECHANICS_HUD_TITLE)
    frame.Title:SetPoint("LEFT", 10, 0)
    frame.Boss = Font(frame.Header, 11, "text", "")
    frame.Boss:SetPoint("RIGHT", -32, 0)
    frame.Boss:SetJustifyH("RIGHT")
    frame.Close = CreateFrame("Button", nil, frame.Header)
    frame.Close:SetPoint("RIGHT", -5, 0)
    frame.Close:SetSize(22, 22)
    frame.Close.Text = Font(frame.Close, 12, "muted", "X")
    frame.Close.Text:SetPoint("CENTER", 0, 1)
    frame.Close:SetScript("OnEnter", function(self)
        self.Text:SetTextColor(1, .35, .35, 1)
    end)
    frame.Close:SetScript("OnLeave", function(self)
        self.Text:SetTextColor(.56, .66, .72, 1)
    end)
    frame.Close:SetScript("OnClick", function()
        Raid:GetMechanicsHUDSettings().enabled = false
        frame:Hide()
        Raid:RefreshSettingsView()
    end)
    frame.Cards = {}
    self.mechanicsHUDFrame = frame
    return frame
end

function Raid:RefreshMechanicsHUD()
    local settings = self:GetMechanicsHUDSettings()
    local frame = self:CreateMechanicsHUD()
    local raid = self:GetRaid()
    local bossIndex = self:GetCurrentBossIndex(raid)
    local encounter = bossIndex and raid.encounters[bossIndex]
    local mechanics = encounter and encounter.mechanics or {}
    local inGroup = IsInGroup and IsInGroup()
    local inRaid = IsInRaid and IsInRaid()
    local visibility = settings.visibility or "GROUP"
    local allowed = visibility == "ALWAYS"
        or visibility == "GROUP" and inGroup
        or visibility == "RAID" and inRaid
    if not settings.enabled or not encounter or #mechanics == 0
        or not allowed
        or settings.combatOnly and not (InCombatLockdown and InCombatLockdown())
    then
        frame:Hide()
        return
    end
    frame:SetWidth(settings.width or 430)
    frame:SetScale(self:GetHUDScale())
    frame:SetAlpha(settings.opacity or .92)
    frame.Header:SetShown(settings.showTitle ~= false)
    frame.Boss:SetText(encounter.name)
    local y = settings.showTitle == false and 0 or 36
    local limit = math.max(1, math.min(#mechanics,
        tonumber(settings.maxLines) or 6))
    for index = 1, limit do
        local card = frame.Cards[index]
        if not card then
            card = CreateFrame("Frame", nil, frame, "BackdropTemplate")
            card:SetBackdrop({
                bgFile = WHITE, edgeFile = WHITE, edgeSize = 1,
            })
            card:SetBackdropColor(.025, .050, .065, .97)
            card:SetBackdropBorderColor(.10, .24, .30, .95)
            card.Accent = card:CreateTexture(nil, "ARTWORK")
            card.Accent:SetTexture(WHITE)
            card.Accent:SetPoint("TOPLEFT", 1, -1)
            card.Accent:SetPoint("BOTTOMLEFT", 1, 1)
            card.Accent:SetWidth(3)
            card.Accent:SetVertexColor(unpack(ACCENT))
            card.Number = Font(card, 12, "accent", "")
            card.Number:SetPoint("LEFT", 12, 0)
            card.Number:SetWidth(20)
            card.Number:SetJustifyH("CENTER")
            card.Text = Font(card, 10, "text", "")
            card.Text:SetPoint("TOPLEFT", 42, -9)
            card.Text:SetJustifyH("LEFT")
            card.Text:SetJustifyV("TOP")
            card.Text:SetWordWrap(true)
            frame.Cards[index] = card
        end
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", 0, -y)
        card:SetWidth(settings.width or 430)
        card.Number:SetText(tostring(index))
        card.Text:SetWidth(math.max(40, (settings.width or 430) - 54))
        card.Text:SetText(mechanics[index])
        local textHeight = card.Text.GetStringHeight
            and card.Text:GetStringHeight() or 28
        local cardHeight = math.max(40, math.ceil(textHeight) + 18)
        card:SetHeight(cardHeight)
        card.Text:SetHeight(cardHeight - 14)
        card:Show()
        y = y + cardHeight + 7
    end
    for index = limit + 1, #frame.Cards do frame.Cards[index]:Hide() end
    frame:SetHeight(math.max(1, y - 7))
    frame:Show()
end
