local _, Raid = ...

Raid.L = LibStub("AceLocale-3.0"):GetLocale("LunaRaids")

function Raid:Localize(key, ...)
    local value = self.L[key]
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, value, ...)
        if ok then return formatted end
    end
    return value
end
