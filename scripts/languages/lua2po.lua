ConvertEscapeCharactersToString = function(str)
    local newstr = string.gsub(str, "\\", "\\\\")
    newstr = string.gsub(newstr, "\n", "\\n")
    newstr = string.gsub(newstr, "\r", "\\r")
    newstr = string.gsub(newstr, "\"", "\\\"")
    return newstr
end
local function SortedKeysIter( state, i )
    i = next( state.sorted_keys, i )
    if i then
        local key = state.sorted_keys[ i ]
        return i, key, state.t[ key ]
    end
end

function sorted_pairs( t, fn )
    local sorted_keys = {}
    for k, v in pairs(t) do
        table.insert( sorted_keys, k )
    end
    table.sort( sorted_keys, fn or StringSort )
    return SortedKeysIter, { sorted_keys = sorted_keys, t = t }
end
function write_for_strings(base, data, file,empty)
    for _, k, v in sorted_pairs(data) do
        local path = base.."."..k
        if type(v) == "table" then
            write_for_strings(path, v, file,empty)
        else
            local s=ConvertEscapeCharactersToString(v)..'"\n'
            file:write('\n')
            file:write('#. '..path..'\n')
            file:write('msgctxt "'..path..'"\n')
            file:write('msgid "'..s)
            file:write('msgstr "'..(empty and '"\n' or s))
        end
    end
end
return function(filename, strings,empty)
    file=io.open(filename,"w")
    if not file then return end
    file:write([[msgid ""
msgstr ""
"Language: zh\n"
"Content-Type: text/plain; charset=utf-8\n"
"Content-Transfer-Encoding: 8bit\n"
"POT Version: 2.0"]])

    write_for_strings("STRINGS", strings, file,empty)

    file:close()
end
