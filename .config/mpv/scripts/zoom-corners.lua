local utils = require "mp.utils"
local msg = require "mp.msg"

local opts = {
    cycle_top_to_bottom = false,
    top_right_x_offset = 0.2,
    top_left_x_offset = 0.2,
    top_right_y_offset = 0.3,
    top_left_y_offset = 0.3,
    bottom_right_x_offset = 0.2,
    bottom_left_x_offset = 0.2,
    bottom_right_y_offset = 0.2,
    bottom_left_y_offset = 0.2,
    corner_video_zoom = 0.5
}
(require 'mp.options').read_options(opts)


local isVish = false
mp.register_event('file-loaded', function() 
    local path = mp.get_property_native("path")
    dir, fn = utils.split_path(path)
    isVish = path:find("_vish", 0, true)
end)

-- zoom corners only if filename contains '_vish'
-- otherwise, add video-zoom -0.1
function zoom_handler() 
    if isVish then
        zoom_corner()
    else
        --mp.commandv("script-message", "playlist-view-close")
        --mp.commandv("script-message", "contact-sheet-toggle")
        mp.commandv("add", "video-zoom", "-0.1")
    end
end

function zoom_corner() 
    local x = mp.get_property_number("video-pan-x")
    local y = mp.get_property_number("video-pan-y")
    local dx = 0
    local dy = 0
    local zoom = opts.corner_video_zoom

    if x >= opts.top_left_x_offset and y >= opts.top_left_y_offset then 
        if opts.cycle_top_to_bottom then                                    -- TL -> BL
            dy = -opts.bottom_left_y_offset
            dx =  opts.bottom_left_x_offset
        else                                                                -- TL -> TR 
            dy =  opts.top_right_y_offset
            dx = -opts.top_right_x_offset
        end
    elseif x <= -opts.top_right_x_offset and y >= opts.top_right_y_offset then 
        if opts.cycle_top_to_bottom then                                    -- TR -> BR
            dy = -opts.bottom_right_y_offset
            dx = -opts.bottom_right_x_offset
        else                                                                -- TR -> BL
            dy = -opts.bottom_left_y_offset
            dx =  opts.bottom_left_x_offset
        end
    elseif x >= opts.bottom_left_x_offset and y <= -opts.bottom_left_y_offset then 
        if opts.cycle_top_to_bottom then                                    -- BL -> TR  
            dy =  opts.top_right_y_offset
            dx = -opts.top_right_x_offset
        else                                                                -- BL -> BR
            dy = -opts.bottom_right_y_offset
            dx = -opts.bottom_right_x_offset
        end
    elseif x <= -opts.bottom_right_x_offset and y <= -opts.bottom_right_y_offset then -- BR -> None
        dy =  0
        dx =  0
        zoom = 0
    else                                                                  -- TL
        dy = opts.top_left_y_offset
        dx = opts.top_left_x_offset
    end

    for i=1,20 do
        mp.set_property_number('video-pan-y', dy)
        mp.set_property_number('video-pan-x', dx)
    end
    mp.set_property_number('video-zoom', zoom)
end

function swap_corner_lr()
    local panx_amt = 0.3
    local zoom = mp.get_property_number('video-zoom')
    local panx = mp.get_property_number("video-pan-x")
    if panx == 0 then
        mp.set_property_number('video-pan-x', panx_amt)
    elseif zoom == 0 and panx < 0 then
        mp.set_property_number('video-pan-x', 0.0)
    else
        mp.set_property_number('video-pan-x', -panx)
    end
end

function swap_corner_vert()
    local pany_amt = 0.3
    local zoom = mp.get_property_number('video-zoom')
    local pany = mp.get_property_number("video-pan-y")
    if pany == 0 then
        mp.set_property_number('video-pan-y', 0.4)
    elseif zoom == 0 and pany < 0 then
        mp.set_property_number('video-pan-y', 0.0)
    else
        mp.set_property_number('video-pan-y', -pany)
    end
end

function reset_zoom_fullscreen()
    zoom = mp.get_property_number('video-zoom')
    panx = mp.get_property_number('video-pan-x')
    pany = mp.get_property_number('video-pan-y')
    isFullscreen = mp.get_property('fullscreen')
    if zoom == 0 and panx == 0 and pany == 0 and isFullscreen == 'no' then
        mp.commandv("cycle", "fullscreen")
    end
    reset_zoom()
end

function reset_zoom()
    mp.set_property_number('video-zoom', 0)
    mp.set_property_number('video-pan-x', 0) 
    mp.set_property_number('video-pan-y', 0)
end

--mp.add_key_binding(nil, "zoom_corner_cycle", zoom_handler, {repeatable=true})
--mp.add_key_binding(nil, "zoom_corner_swap_lr", swap_corner_lr, {repeatable=true})
--mp.add_key_binding(nil, "zoom_corner_swap_vert", swap_corner_vert, {repeatable=true})
mp.add_key_binding(nil, "zoom_corner_cycle", zoom_handler)
mp.add_key_binding(nil, "zoom_corner_swap_lr", swap_corner_lr)
mp.add_key_binding(nil, "zoom_corner_swap_vert", swap_corner_vert)
mp.register_script_message("reset_zoom", reset_zoom)
mp.register_script_message("reset_zoom_fullscreen", reset_zoom_fullscreen)
