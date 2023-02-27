local function GetLanguageCode()
    local loc = locale or (LOC.CurrentLocale and LOC.CurrentLocale.code) or LanguageTranslator.defaultlang
    local traditional = loc == "zht"
    -- replace wegame suffix
    if loc == "zhr" then loc = "zh" end
    return loc, traditional
end
local function readjson(path)
    local f = io.open(resolvefilepath(path))
    if not f then return nil end
    local data = f:read("*all")
    f:close()
    return json.decode(data)
end
local substrs = {["我"] = "咱"}
local function AddLocalFlavor()
    local function dictsub(t, k, dict, src)
        t[k] = src[k]
        for old, new in pairs(dict) do t[k] = string.gsub(t[k], old, new) end
    end
    local function recursivesub(t, src)
        if not src then return end
        if type(src) == "table" then
            for k, v in pairs(src) do
                local tp, tp2 = type(v), type(t[k])
                if tp == "string" and tp2 ~= "string" then
                    dictsub(t, k, substrs, src)
                elseif tp == "table" then
                    if tp2 ~= "table" then t[k] = {} end
                    recursivesub(t[k], v)
                end

            end
        else
            -- ???
        end
    end
    recursivesub(STRINGS.CHARACTERS.NANACHI, STRINGS.CHARACTERS.GENERIC)
    substrs = nil
end
do
    local lang_conf = GetModConfigData("language")
    local lang = lang_conf == "default" and GetLanguageCode() or lang_conf
    if lang ~= "zh" and lang ~= "zht" then
        lang = "en"
    else
    end
    modimport("scripts/languages/mia_" .. lang .. ".lua")
    if lang ~= "en" then
        AddPrefabPostInit("nanachi", function(inst)
            if TheNet:GetIsServer() or inst == ThePlayer or ThePlayer == nil then
                if substrs then AddLocalFlavor() end
            end
        end)
    end
end
