package.path = "/home/enovid/.config/mpv/scripts/lib/?.lua;" .. package.path
local gallery = require 'gallery'
local utils = require 'mp.utils'
local msg = require 'mp.msg'

local ON_WINDOWS = (package.config:sub(1,1) ~= "/")

function split(input) -- convert comma seperated config option into list
    local ret = {}
    for str in string.gmatch(input, "([^,]+)") do
        ret[#ret + 1] = str
    end
    return ret
end

local opts = {
    thumbs_dir = ON_WINDOWS and "%APPDATA%\\mpv\\gallery-thumbs-dir" or "~/.mpv_thumbs_dir/",
    generate_thumbnails_with_mpv = ON_WINDOWS,

    --gallery_position = "{30, 30}",
    --gallery_size = "{tw + 4*sw, wh - 2*gy }",
    --min_spacing = "{15, 15}",
    --thumbnail_size = "(ww * wh <= 1280 * 720) and {192, 108} or (ww * wh <= 1920 * 1080) and {288, 162} or {384, 216}",

    -- basic centered grid
    --gallery_position = "{ ww/20, wh/20 }",
    --gallery_size = "{ww - 2*gx, wh - 2*gy}",
    --min_spacing = "{15, 15}",
    --thumbnail_size = "(ww * wh <= 1280 * 720) and {192, 108} or (ww * wh <= 1920 * 1080) and {288, 162} or {384, 216}",

    -- grid with minimum margins
    gallery_position = "{ (ww - gw) / 2, (wh - gh) / 2}",
    gallery_size = "{ 9 * ww / 10, 9 * wh / 10 }",
    min_spacing = "{ 15, 15 }",
    thumbnail_size = "(ww * wh <= 1366 * 768) and {192, 108} or {288, 162}",
    max_thumbnails = 64,

    seek_on_toggle_off = false,
    close_on_seek = true,
    pause_on_start = true,
    resume_on_stop = "only-if-did-pause",

    time_distance = "2%",

    show_text = "selection",
    show_millisecond_precision = true,
    text_size = 28,

    background_color = "333333",
    background_opacity = "33",
    normal_border_color = "BBBBBB",
    normal_border_size = 1,
    selected_border_color = "DDDDDD",
    selected_border_size = 6,
    placeholder_color = "222222",

    command_on_open = "",
    command_on_close = "",

    mouse_support = true,
    UP        = "UP",
    DOWN      = "DOWN",
    LEFT      = "LEFT",
    RIGHT     = "RIGHT",
    PAGE_UP   = "PGUP",
    PAGE_DOWN = "PGDWN",
    FIRST     = "HOME",
    LAST      = "END",
    RANDOM    = "r",
    ACCEPT    = "ENTER",
    CANCEL    = "ESC",
}
(require 'mp.options').read_options(opts)

opts.UP        = split(opts.UP)
opts.DOWN      = split(opts.DOWN)
opts.LEFT      = split(opts.LEFT)
opts.RIGHT     = split(opts.RIGHT)
opts.PAGE_UP   = split(opts.PAGE_UP)
opts.PAGE_DOWN = split(opts.PAGE_DOWN)
opts.FIRST     = split(opts.FIRST)
opts.LAST      = split(opts.LAST)
opts.RANDOM    = split(opts.RANDOM)
opts.ACCEPT    = split(opts.ACCEPT)
opts.CANCEL    = split(opts.CANCEL)

if ON_WINDOWS then
    opts.thumbs_dir = string.gsub(opts.thumbs_dir, "^%%APPDATA%%", os.getenv("APPDATA") or "%APPDATA%")
else
    opts.thumbs_dir = string.gsub(opts.thumbs_dir, "^~", os.getenv("HOME") or "~")
end
opts.max_thumbnails = math.min(opts.max_thumbnails, 64)

local res = utils.file_info(opts.thumbs_dir)
if not res or not res.is_dir then
    msg.error(string.format("Thumbnail directory \"%s\" does not exist", opts.thumbs_dir))
end

local sha256
--[[
minified code below is a combination of:
-sha256 implementation from
http://lua-users.org/wiki/SecureHashAlgorithm
-lua implementation of bit32 (used as fallback on lua5.1) from
https://www.snpedia.com/extensions/Scribunto/engines/LuaCommon/lualib/bit32.lua
both are licensed under the MIT below:

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]
do local b,c,d,e,f;if bit32 then b,c,d,e,f=bit32.band,bit32.rrotate,bit32.bxor,bit32.rshift,bit32.bnot else f=function(g)g=math.floor(tonumber(g))%0x100000000;return(-g-1)%0x100000000 end;local h={[0]={[0]=0,0,0,0},[1]={[0]=0,1,0,1},[2]={[0]=0,0,2,2},[3]={[0]=0,1,2,3}}local i={[0]={[0]=0,1,2,3},[1]={[0]=1,0,3,2},[2]={[0]=2,3,0,1},[3]={[0]=3,2,1,0}}local function j(k,l,m,n,o)for p=1,m do l[p]=math.floor(tonumber(l[p]))%0x100000000 end;local q=1;local r=0;for s=0,31,2 do local t=n;for p=1,m do t=o[t][l[p]%4]l[p]=math.floor(l[p]/4)end;r=r+t*q;q=q*4 end;return r end;b=function(...)return j('band',{...},select('#',...),3,h)end;d=function(...)return j('bxor',{...},select('#',...),0,i)end;e=function(g,u)g=math.floor(tonumber(g))%0x100000000;u=math.floor(tonumber(u))u=math.min(math.max(-32,u),32)return math.floor(g/2^u)%0x100000000 end;c=function(g,u)g=math.floor(tonumber(g))%0x100000000;u=-math.floor(tonumber(u))%32;local g=g*2^u;return g%0x100000000+math.floor(g/0x100000000)end end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(n)return string.gsub(n,".",function(t)return string.format("%02x",string.byte(t))end)end;local function x(y,z)local n=""for p=1,z do local A=y%256;n=string.char(A)..n;y=(y-A)/256 end;return n end;local function B(n,p)local z=0;for p=p,p+3 do z=z*256+string.byte(n,p)end;return z end;local function C(D,E)local F=-(E+1+8)%64;E=x(8*E,8)D=D.."\128"..string.rep("\0",F)..E;return D end;local function G(H)H[1]=0x6a09e667;H[2]=0xbb67ae85;H[3]=0x3c6ef372;H[4]=0xa54ff53a;H[5]=0x510e527f;H[6]=0x9b05688c;H[7]=0x1f83d9ab;H[8]=0x5be0cd19;return H end;local function I(D,p,H)local J={}for K=1,16 do J[K]=B(D,p+(K-1)*4)end;for K=17,64 do local L=J[K-15]local M=d(c(L,7),c(L,18),e(L,3))L=J[K-2]local N=d(c(L,17),c(L,19),e(L,10))J[K]=J[K-16]+M+J[K-7]+N end;local O,s,t,P,Q,R,S,T=H[1],H[2],H[3],H[4],H[5],H[6],H[7],H[8]for p=1,64 do local M=d(c(O,2),c(O,13),c(O,22))local U=d(b(O,s),b(O,t),b(s,t))local V=M+U;local N=d(c(Q,6),c(Q,11),c(Q,25))local W=d(b(Q,R),b(f(Q),S))local X=T+N+W+v[p]+J[p]T=S;S=R;R=Q;Q=P+X;P=t;t=s;s=O;O=X+V end;H[1]=b(H[1]+O)H[2]=b(H[2]+s)H[3]=b(H[3]+t)H[4]=b(H[4]+P)H[5]=b(H[5]+Q)H[6]=b(H[6]+R)H[7]=b(H[7]+S)H[8]=b(H[8]+T)end;local function Y(H)return w(x(H[1],4)..x(H[2],4)..x(H[3],4)..x(H[4],4)..x(H[5],4)..x(H[6],4)..x(H[7],4)..x(H[8],4))end;local Z={}sha256=function(D)D=C(D,#D)local H=G(Z)for p=1,#D,64 do I(D,p,H)end;return Y(H)end end
-- end of sha code

local gallery = gallery_new()

local path = ""
local path_hash = ""
local duration = 0
local did_pause = false

gallery.config.accurate = true
gallery.config.generate_thumbnails_with_mpv = opts.generate_thumbnails_with_mpv
gallery.config.always_show_placeholders = true
gallery.config.align_text = false
gallery.config.placeholder_color = opts.placeholder_color
gallery.config.background_color = opts.background_color
gallery.config.background_opacity = opts.background_opacity
gallery.config.max_thumbnails = opts.max_thumbnails
gallery.config.text_size = opts.text_size

gallery.too_small = function()
    stop()
end
gallery.item_to_overlay_path = function(index, item)
    local thumb_filename = string.format("%s_%u_%d_%d",
        path_hash,
        item * 100,
        gallery.geometry.thumbnail_size[1],
        gallery.geometry.thumbnail_size[2])
    return utils.join_path(opts.thumbs_dir, thumb_filename)
end
gallery.item_to_thumbnail_params = function(index, item)
    return path, item
end
gallery.item_to_border = function(index, item)
    if index == gallery.selection then
        return opts.selected_border_size, opts.selected_border_color
    else
        return opts.normal_border_size, opts.normal_border_color
    end
end
gallery.item_to_text = function(index, item)
    if opts.show_text == "everywhere" or opts.show_text == "selection" and index == gallery.selection then
        local str
        if duration > 3600 then
            str = string.format("%d:%02d:%02d", item / 3600, (item / 60) % 60, item % 60)
        else
            str = string.format("%02d:%02d", (item / 60) % 60, item % 60)
        end
        if opts.show_millisecond_precision then
            local dec = tostring(math.floor(item * 1000 % 1000))
            if dec:len() < 3 then
                dec = dec .. string.rep("0", 3 - dec:len())
            end
            str = str .. "." .. dec
        end
        return str
    else
        return ""
    end
end

do
    local function increment_func(increment, clamp)
        local new = (gallery.pending.selection or gallery.selection) + increment
        if new <= 0 or new > #gallery.items then
            if not clamp then return end
            new = math.max(1, math.min(new, #gallery.items))
        end
        gallery.pending.selection = new
    end

    --local bindings_repeat = {}
        --bindings_repeat[opts.UP]        = function() increment_func(- gallery.geometry.columns, false) end
        --bindings_repeat[opts.DOWN]      = function() increment_func(  gallery.geometry.columns, false) end
        --bindings_repeat[opts.LEFT]      = function() increment_func(- 1, false) end
        --bindings_repeat[opts.RIGHT]     = function() increment_func(  1, false) end
        --bindings_repeat[opts.PAGE_UP]   = function() increment_func(- gallery.geometry.columns * gallery.geometry.rows, true) end
        --bindings_repeat[opts.PAGE_DOWN] = function() increment_func(  gallery.geometry.columns * gallery.geometry.rows, true) end
        --bindings_repeat[opts.RANDOM]    = function() gallery.pending.selection = math.random(1, #gallery.items) end

    local bindings_repeat = {}
        for i,key in pairs(opts.UP) do
	    bindings_repeat[key] =  function() increment_func(- gallery.geometry.columns, false) end
	end
        for i,key in pairs(opts.DOWN) do
	    bindings_repeat[key] =  function() increment_func(  gallery.geometry.columns, false) end
	end
        for i,key in pairs(opts.LEFT) do
	    bindings_repeat[key] =  function() increment_func(- 1, false) end
	end
        for i,key in pairs(opts.RIGHT) do
	    bindings_repeat[key] =  function() increment_func(  1, false) end
	end
        for i,key in pairs(opts.PAGE_UP) do
	    bindings_repeat[key] =  function() increment_func(- gallery.geometry.columns * gallery.geometry.rows, true) end
	end
        for i,key in pairs(opts.PAGE_DOWN) do
	    bindings_repeat[key] =  function() increment_func(  gallery.geometry.columns * gallery.geometry.rows, true) end
	end
        for i,key in pairs(opts.RANDOM) do
	    bindings_repeat[key] =  function() gallery.pending.selection = math.random(1, #gallery.items) end
	end

    local bindings = {}
        --bindings[opts.FIRST]  = function() gallery.pending.selection = 1 end
        --bindings[opts.LAST]   = function() gallery.pending.selection = #gallery.items end
        --bindings[opts.ACCEPT] = function()
            --seek_to_selection()
            --if opts.close_on_seek then stop() end
        --end
        --bindings[opts.CANCEL] = function() stop() end

        for i,key in pairs(opts.FIRST) do
	    bindings[key] =  function() gallery.pending.selection = 1 end
	end
        for i,key in pairs(opts.LAST) do
	    bindings[key] =  function() gallery.pending.selection = #gallery.items end
	end
        for i,key in pairs(opts.ACCEPT) do
	    bindings[key] =  function()
                seek_to_selection()
                if opts.close_on_seek then stop() end
            end
	end
        for i,key in pairs(opts.CANCEL) do
	    bindings[key] =  function() stop() end
	end

    if opts.mouse_support then
        bindings["MBTN_LEFT"]  = function()
            local index = gallery:index_at(mp.get_mouse_pos())
            if not index then return end
            if index == gallery.selection then
                seek_to_selection()
                if opts.close_on_seek then stop() end
            else
                gallery.pending.selection = index
            end
        end
        bindings["WHEEL_UP"]   = function() increment_func(- gallery.geometry.columns, false) end
        bindings["WHEEL_DOWN"] = function() increment_func(  gallery.geometry.columns, false) end
    end

    function setup_ui_handlers()
        for key, func in pairs(bindings_repeat) do
            mp.add_forced_key_binding(key, "contact-sheet-"..key, func, {repeatable = true})
        end
        for key, func in pairs(bindings) do
            mp.add_forced_key_binding(key, "contact-sheet-"..key, func)
        end
    end

    function teardown_ui_handlers()
        for key, _ in pairs(bindings_repeat) do
            mp.remove_key_binding("contact-sheet-"..key)
        end
        for key, _ in pairs(bindings) do
            mp.remove_key_binding("contact-sheet-"..key)
        end
    end
end

-- the purpose of this highly-convoluted code is to handle the geometries of the gallery
-- dynamically, while computing the different properties in the correct order
-- so that they can reference one another (barring cyclical dependencies)
do
    local geometry_functions = loadstring(string.format([[
    return {
    function(ww, wh, gx, gy, gw, gh, sw, sh, tw, th)
        return %s
    end,
    function(ww, wh, gx, gy, gw, gh, sw, sh, tw, th)
        return %s
    end,
    function(ww, wh, gx, gy, gw, gh, sw, sh, tw, th)
        return %s
    end,
    function(ww, wh, gx, gy, gw, gh, sw, sh, tw, th)
        return %s
    end
    }]], opts.gallery_position, opts.gallery_size, opts.min_spacing, opts.thumbnail_size))()

    local names = { "gallery_position", "gallery_size", "min_spacing", "thumbnail_size" }
    local order = {} -- the order in which the 4 properties should be computed, based on inter-dependencies

    -- build the dependency matrix
    local patterns = { "g[xy]", "g[wh]", "s[wh]", "t[wh]" }
    local deps = {}
    for i = 1,4 do
        for j = 1,4 do
            local i_depends_on_j = (string.find(opts[names[i]], patterns[j]) ~= nil)
            if i == j and i_depends_on_j then
                msg.error(names[i] .. " depends on itself")
                return
            end
            deps[i * 4 + j] = i_depends_on_j
        end
    end

    local function has_deps(index)
        for j = 1,4 do
            if deps[index * 4 + j] then
                return true
            end
        end
        return false
    end
    local num_resolved = 0
    local resolved = { false, false, false, false }
    while true do
        local resolved_one = false
        for i = 1, 4 do
            if resolved[i] then
                -- nothing to do
            elseif not has_deps(i) then
                order[#order + 1] = i
                -- since i has no deps, anything that depends on it might as well not
                for j = 1, 4 do
                    deps[j * 4 + i] = false
                end
                resolved[i] = true
                resolved_one = true
                num_resolved = num_resolved + 1
            end
        end
        if num_resolved == 4 then
            break
        elseif not resolved_one then
            local str = ""
            for index, resolved in ipairs(resolved) do
                if not resolved then
                    str = (str == "" and "" or (str .. ", ")) .. names[index]
                end
            end
            msg.error("Circular dependency between " .. str)
            return
        end
    end

    local show_text = (opts.show_text == "selection" or opts.show_text == "everywhere")

    gallery.set_geometry_props = function()
        local g = gallery.geometry
        g.window[1], g.window[2] = mp.get_osd_size()
        for _, index in ipairs(order) do
            g[names[index]] = geometry_functions[index](
                g.window[1], g.window[2],
                g.gallery_position[1], g.gallery_position[2],
                g.gallery_size[1], g.gallery_size[2],
                g.min_spacing[1], g.min_spacing[2],
                g.thumbnail_size[1], g.thumbnail_size[2]
            )
            -- extrawuerst
            if show_text and names[index] == "min_spacing" then
                g.min_spacing[2] = math.max(opts.text_size, g.min_spacing[2])
            elseif names[index] == "thumbnail_size" then
                g.thumbnail_size[1] = math.floor(g.thumbnail_size[1])
                g.thumbnail_size[2] = math.floor(g.thumbnail_size[2])
            end
        end
    end
end

function normalize_path(path)
    if string.find(path, "://") then
        return path
    end
    path = utils.join_path(utils.getcwd(), path)
    if ON_WINDOWS then
        path = string.gsub(path, "\\", "/")
    end
    path = string.gsub(path, "/%./", "/")
    local n
    repeat
        path, n = string.gsub(path, "/[^/]*/%.%./", "/", 1)
    until n == 0
    return path
end

function start()
    if gallery.active then return end
    if not mp.get_property_bool("seekable") then
        msg.error("Video is not seekable")
        return
    end

    path = mp.get_property("path")
    path_hash = string.sub(sha256(normalize_path(path)), 1, 12)
    duration = mp.get_property_number("duration")
    if not duration then return end
    duration = duration - (1 / mp.get_property_number("container-fps", 30))
    local effective_time_distance
    if string.sub(opts.time_distance, -1) == "%" then
        effective_time_distance = tonumber(string.sub(opts.time_distance, 1, -2)) / 100 * duration
    else
        effective_time_distance = tonumber(opts.time_distance)
    end
    local time = 0
    local times = {}
    local selection = 0
    local time_pos = mp.get_property_number("time-pos")
    while time < duration do
        if time < time_pos + 0.1 then
            selection = selection + 1
        end
        times[#times + 1] = time
        time = time + effective_time_distance
    end
    gallery.items = times

    if not gallery:activate(selection) then return end
    if opts.command_on_open ~= "" then
        mp.command(opts.command_on_open)
    end
    did_pause = false
    if opts.pause_on_start and not mp.get_property_bool("pause", false) then
        mp.set_property_bool("pause", true)
        did_pause = true
    end
    mp.register_event("end-file", stop)

    setup_ui_handlers()
end

function seek_to_selection()
    local time = gallery.items[gallery.selection]
    if not time then return end
    mp.commandv("seek", time, "absolute")
end

function stop()
    if not gallery.active then return end
    mp.unregister_event(stop)
    if opts.resume_on_stop == "yes" or (opts.resume_on_stop == "only-if-did-pause" and did_pause) then
        mp.set_property_bool("pause", false)
    end
    if opts.command_on_close ~= "" then
        mp.command(opts.command_on_close)
    end
    gallery:deactivate()
    teardown_ui_handlers()
end

function toggle()
    if not gallery.active then
        start()
    else
        if opts.seek_on_toggle_off then seek_to_selection() end
        stop()
    end
end

mp.register_script_message("thumbnail-generated", function(thumb_path)
     gallery:thumbnail_generated(thumb_path)
end)

mp.register_script_message("thumbnails-generator-broadcast", function(generator_name)
     gallery:add_generator(generator_name)
end)

mp.add_key_binding(nil, "contact-sheet-open", start)
mp.add_key_binding(nil, "contact-sheet-close", stop)
mp.add_key_binding(nil, "contact-sheet-toggle", toggle)
mp.add_key_binding(nil, "contact-sheet-seek", seek_to_selection)
