name = "Riko, Reg &Nanachi"
description =
    [[Riko, a lively and inquisitive girl, a apprentice delver, her dream is to catch up with her mother, become the legendary explorer "White Whistle".
Reg, the humanoid-looking robot that Riko had found in the Abyss, has lost its memory.
Nanachi, a furry creature from the bottom of the abyss. Smells good.]]
author = "Haori & Mario, zzzzzzzs"
forumthread = ""
priority = 1
api_version = ChooseTranslationTable and 10 or 6
dst_compatible = true
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true
all_clients_require_mod = true
icon_atlas = "modicon.xml"
icon = "modicon.tex"
server_filter_tags = {"XZmodmaker", "made_in_abyss"}
version = "20230225.2"
configuration = {
    {
        name = "language",
        label = "Language",
        hover = "Set Language",
        options = {
            {description = "Default", hover = "Accord to the game", data = "default"},
            {description = "English", data = "en", hover = "English"},
            {description = "中文", data = "zh", hover = "Simplified Chinese"},
            {description = "繁体中文", data = "zht", hover = "Traditional Chinese"}
        },
        default = "default"
    }
}

translation = {
    {
        matchLanguage = function(lang)
            return lang == "zh" or lang == "zht" or lang == "zhr" or lang == "chs" or lang == "cht"
        end,
        translateFunction = function(key)
            return translation[1].dict[key] or nil
        end,
        dict = {
            name = "莉可，雷古与娜娜奇",
            language = "语言",
            author = "羽织Haori & 宵征, zzzzzzzs",
            unusable = "不可用",
            attract = "吸引伙伴",
            attract_hover = "娜娜奇是否吸引猪人",
            description = [[
莉可，活泼而又好奇心旺盛的女孩子，是见习探窟家，梦想追上母亲，成为传说中的探窟家“白笛”。
雷古，莉可在深渊里发现的，拥有和人类相似外形的机器人，失去了记忆。
娜娜奇，来自深渊底部的迷之生物，毛茸茸的闻起来很香很香。]],
            version = [[雷古改版]],
            ["Accord to the game"] = "跟随游戏设置",
            ["Set Language"] = "设置语言",
            Keybinds = "按键绑定",
            No = "否",
            Yes = "是",
            Default = "默认",
            Client = "客户端",
            debug = "开启调试"
        }
    },
    {
        matchLanguage = function(lang)
            return lang == "en"
        end,
        dict = {
            name = name,
            description = description,
            attract_hover = "Nanachi will/won't attract pigman.",
            version = [[Reg reworked]]
        },
        translateFunction = function(key)
            return translation[2].dict[key] or key
        end
    }
}
local function makeConfigurations(conf, translate, baseTranslate, language)
    local index = 0
    local config = {}
    local function trans(str)
        return translate(str) or baseTranslate(str)
    end

    local string = ""
    for i = 1, #conf do
        local v = conf[i]
        if not v.disabled then
            index = index + 1
            config[index] = {
                name = v.name or "",
                label = v.name ~= "" and translate(v.name) or (v.label and trans(v.label)) or baseTranslate(v.name)
                    or nil,
                hover = v.name ~= "" and (v.hover and trans(v.hover)) or nil,
                default = v.default or "",
                options = v.name ~= "" and {{description = "", data = ""}} or nil,
                client = v.client
            }
            if v.unusable then config[index].label = config[index].label .. "[" .. trans("unusable") .. "]" end
            if v.key then
                if language == "zh" then
                    config[index].options = input_table_zh
                else
                    config[index].options = input_table_en
                end
                config[index].iskey = true
                config[index].default = 0
            elseif v.options then
                for j = 1, #v.options do
                    local opt = v.options[j]
                    config[index].options[j] = {
                        description = opt.description and trans(opt.description) or "",
                        hover = opt.hover and trans(opt.hover) or "",
                        data = opt.data ~= nil and opt.data or ""
                    }
                end
            end
        end
    end
    configuration_options = config
end

local function makeInfo(translation)
    local localName = translation("name")
    local localDescription = translation("description")
    local localVersionInfo = translation("version") or ""
    local localAuthor = translation("author")
    if localVersionInfo ~= "" then
        if not localDescription then localDescription = "" end
        localDescription = localVersionInfo .. "\n" .. localDescription
    end
    if localName then name = localName end
    if localAuthor then author = localAuthor end
    if localDescription then description = localDescription end
end

local function getLang()
    local lang = locale or "en"
    return lang
end

local function generate()
    local lang = getLang()
    local localTranslation = translation[#translation].translateFunction
    local baseTranslation = translation[#translation].translateFunction
    for i = 1, #translation - 1 do
        local v = translation[i]
        if v.matchLanguage(lang) then
            localTranslation = v.translateFunction
            break
        end
    end
    makeInfo(localTranslation)
    makeConfigurations(configuration, localTranslation, baseTranslation, lang)
end
generate()
