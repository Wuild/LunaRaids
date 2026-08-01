local MAJOR, MINOR = "AceLocale-3.0", 6
local AceLocale = LibStub:NewLibrary(MAJOR, MINOR)
if not AceLocale then return end

local gameLocale = GetLocale()
if gameLocale == "enGB" then gameLocale = "enUS" end

AceLocale.apps = AceLocale.apps or {}
AceLocale.appnames = AceLocale.appnames or {}

local readmeta = {
    __index = function(self, key)
        rawset(self, key, key)
        geterrorhandler()(MAJOR .. ": "
            .. tostring(AceLocale.appnames[self])
            .. ": Missing entry for '" .. tostring(key) .. "'")
        return key
    end,
}
local readmetasilent = {
    __index = function(self, key)
        rawset(self, key, key)
        return key
    end,
}
local registering
local function AssertFalse() assert(false) end
local writeproxy = setmetatable({}, {
    __newindex = function(_, key, value)
        rawset(registering, key, value == true and key or value)
    end,
    __index = AssertFalse,
})
local writedefaultproxy = setmetatable({}, {
    __newindex = function(_, key, value)
        if not rawget(registering, key) then
            rawset(registering, key, value == true and key or value)
        end
    end,
    __index = AssertFalse,
})

function AceLocale:NewLocale(application, locale, isDefault, silent)
    local activeGameLocale = GAME_LOCALE or gameLocale
    local app = self.apps[application]
    if silent and app and getmetatable(app) ~= readmetasilent then
        geterrorhandler()("Usage: NewLocale(application, locale[, isDefault[, silent]]): "
            .. "'silent' must be specified for the first locale registered")
    end
    if not app then
        if silent == "raw" then
            app = {}
        else
            app = setmetatable({}, silent and readmetasilent or readmeta)
        end
        self.apps[application] = app
        self.appnames[app] = application
    end
    if locale ~= activeGameLocale and not isDefault then return end
    registering = app
    return isDefault and writedefaultproxy or writeproxy
end

function AceLocale:GetLocale(application, silent)
    if not silent and not self.apps[application] then
        error("Usage: GetLocale(application[, silent]): 'application' - "
            .. "No locales registered for '" .. tostring(application) .. "'", 2)
    end
    return self.apps[application]
end
