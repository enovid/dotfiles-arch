opts = {
    blacklist="",
    whitelist="",
    remove_files_without_extension = false,
    oneshot = true,
}
(require 'mp.options').read_options(opts)
local msg = require 'mp.msg'

function split(input)
    local ret = {}
    for str in string.gmatch(input, "([^,]+)") do
        ret[#ret + 1] = str
    end
    return ret
end

opts.blacklist = split(opts.blacklist)
opts.whitelist = split(opts.whitelist)
local original_whitelist = opts.whitelist
local whitelist_changed = false

local substr_filter_enabled = false
local substr = ""

local exclude
if #opts.whitelist > 0 then
    exclude = function(filename)
        for _, ext in pairs(opts.whitelist) do
            local extension = string.match(filename, "%.([^./]+)$")
            if extension == ext then
                return false
            end
        end
        return true
    end
elseif #opts.blacklist > 0 then
    exclude = function(extension)
        for _, ext in pairs(opts.blacklist) do
            if extension == ext then
                return true
            end
        end
        return false
    end
else
    return
end

function should_remove(filename)
    if string.find(filename, "://") then
        return false
    end
	if string.find(filename, "/trash/") then
        return true
    end
    if substr_filter_enabled and not string.find(filename, substr) then
        return true
    else
        local extension = string.match(filename, "%.([^./]+)$")
        if not extension and opts.remove_file_without_extension then
            return true
        end
        if extension and exclude(string.lower(filename)) then
            return true
        end
    end
    return false
end

function process(playlist_count)
    if playlist_count < 2 then return end
    if opts.oneshot then
        mp.unobserve_property(observe)
    end
    local playlist = mp.get_property_native("playlist")
    local removed = 0
    for i = #playlist, 1, -1 do
        if should_remove(playlist[i].filename) then
            mp.commandv("playlist-remove", i-1)
            removed = removed + 1
        end
    end
    if removed == #playlist then
        msg.warn("Removed eveything from the playlist")
    end
end

function observe(k,v) process(v) end

function set_whitelist(input) 
    if whitelist_changed then
      mp.osd_message("Reset Whitelist")
      opts.whitelist = original_whitelist
      whitelist_changed = false
    else
      mp.osd_message("Whitelist: " .. input)
      opts.whitelist = split(input)
      whitelist_changed = true
    end
end

function open_with_whitelist(input) 
    mp.osd_message("Whitelist: " .. input)
    opts.whitelist = split(input)
end

function reset_whitelist()
    mp.add_timeout(2, reset_whitelist_helper)
end

function reset_whitelist_helper()
    opts.whitelist = original_whitelist
    substr_filter_enabled = false
    substr = ""
end

function open_with_substr(input)
    substr = input
    substr_filter_enabled = true
end

mp.observe_property("playlist-count", "number", observe)
mp.register_script_message("set_whitelist", set_whitelist)
mp.register_script_message("open_with_whitelist", open_with_whitelist)
mp.register_script_message("open_with_substr", open_with_substr)
mp.register_script_message("reset_whitelist", reset_whitelist)
