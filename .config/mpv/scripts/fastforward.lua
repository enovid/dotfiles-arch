--[[ fastforward.lua
# make playback faster
)       script-binding fastforward/speedup
# reduce speed
(       script-binding fastforward/slowdown

]]

options = require 'mp.options'
msg = require 'mp.msg'

--[[
Use `script-opts/fastforward.conf` to change these values.
You can also use expressions like [+-*/]{number}, e.g. /2, *0.5, +1, -0.3...
]]
local opts = {
    speed_increase = "+0.2", --    <--  here...
    -- Upper speed limit.
    max_speed = 8, 
    -- Time to elapse until first slow down.
    decay_delay = 2, 
    -- If you don't change the playback speed for `decay_delay` seconds,
    -- it will be decreased by `speed_decrease` at every
    -- `decay_interval` seconds automatically.
    decay_interval = 0.5,
    speed_decrease = "*0.9", -- <--        ...and here.
    -- For fast forwarding above 1 speed
    positive_speed_increase = "*2",
    positive_max_speed = 4,
    positive_decay_delay = 0.1,
    positive_decay_interval = 0.2,
    positive_speed_decrease = "*0.5"
}

options.read_options(opts)

local timer = nil
local paused
local muted
local start_speed=0.4
local reset_start_speed = 1
local below_zero = false
local above_zero = false

local function pause()
    msg.debug("pause fast-forwarding")
    if timer ~= nil then timer:stop() end
end

local function resume()
    msg.debug("resume fast-forwarding")
    if timer ~= nil then timer:resume() end
end

local function on_pause_change(_, is_paused)
    if is_paused then
        pause()
    else
        resume()
    end
end

local function on_speed_change(_, speed)
    if below_zero == false and above_zero == true then
        if speed <= 1.001 then
            msg.debug("stop fast-forwarding")
            if muted == false then
                unmute()
            end

            if timer ~= nil then 
                timer:kill() 
                timer = nil
            end

            mp.unobserve_property(on_pause_change)
            mp.unobserve_property(on_speed_change)

            mp.set_property_bool("pause", paused)
            mp.set_property_number("speed", 1)
        elseif speed > opts.positive_max_speed then
            -- clamp speed
            mp.set_property_number("speed", opts.positive_max_speed)
        end
    elseif below_zero == true then
        if speed <= start_speed then
            msg.debug("stop fast-forwarding")
            reset_start_speed = 1

            if timer ~= nil then 
                timer:kill() 
                timer = nil
            end

            mp.unobserve_property(on_pause_change)
            mp.unobserve_property(on_speed_change)

            mp.set_property_bool("pause", paused)
            mp.set_property_number("speed", start_speed)

            below_zero = false
        elseif speed > opts.max_speed then
            -- clamp speed
            mp.set_property_number("speed", opts.max_speed)
        end
    end

end

local function change_speed(amount)
    local speed = mp.get_property_number("speed")
    if type(amount) ~= "number" then
        local op = amount:sub(1, 1)
        local val = tonumber(amount:sub(2))

        if     op == "+" then speed = speed + val
        elseif op == "-" then speed = speed - val
        elseif op == "*" then speed = speed * val
        elseif op == "/" then speed = speed / val
        else msg.warn("unable to parse value: `" .. amount .. "'")
        end

    else
        speed = speed + amount
    end
    mp.set_property_number("speed", speed)
end


local function slow_down()
    if above_zero == true then
        change_speed(opts.positive_speed_decrease)
    elseif below_zero == true then
        change_speed(opts.speed_decrease)
    end
end

local function begin_slow_down()
    msg.trace("begin_slow_down()")
    if above_zero == true then
        reset_speed()
    elseif below_zero == true then
        reset_speed()
    end
end

function print_speed()
    mp.osd_message("▶▶ x" .. mp.get_property_number("speed"))
end

function reset_speed()
    if above_zero == true then
        local speed = mp.get_property_number("speed")
        local diff = speed - 1
        change_speed(-diff)
    elseif below_zero == true then
        mp.unobserve_property(on_pause_change)
        mp.unobserve_property(on_speed_change)

        mp.set_property_bool("pause", paused)
        mp.set_property_number("speed", start_speed)

        reset_start_speed = 1
        below_zero = false
    end
end

local function speed_up(t)
    local speed = mp.get_property_number("speed")
    if speed < 1 then
        below_zero = true
        above_zero = false
    elseif below_zero == false then
        above_zero = true
    end

    key_event = t['event'] -- strings: down, repeat, up or press
    if key_event == "up" and opts.decay_delay > 0 and opts.decay_interval > 0 then
        if timer ~= nil then timer:kill() end
        if above_zero == true then
            mp.osd_message("Speed: 1")
            reset_speed()
        elseif below_zero == true then
            mp.add_timeout(0.1, print_speed)
            reset_speed()
        end
        key_released = true
    else
        mp.osd_message("▶▶ x" .. mp.get_property_number("speed"), 10)
        key_released = false
    end

    if below_zero == true and reset_start_speed == 1 then
        start_speed = mp.get_property_number("speed")
        reset_start_speed = 0
    end

    if key_released == false then
        if above_zero == true then
            change_speed(opts.positive_speed_increase)
        elseif below_zero == true then
            change_speed(opts.speed_increase)
        end
    end

    if (below_zero == true and speed == start_speed) or speed == 1 then
        msg.debug("start fast-forwarding")
        muted = mp.get_property_bool("mute")
        if muted == false then
            mute()
        end
        paused = mp.get_property_bool("pause")
        mp.observe_property("pause", "bool", on_pause_change)
        mp.observe_property("speed", "number", on_speed_change)
        mp.set_property_bool("pause", false)
    end
end

function mute()
    mp.set_property("mute", "yes")
end

function unmute()
    mp.set_property("mute", "no")
end

local function set_max_speed()
    local speed = mp.get_property_number("speed")
    if speed > 1 then
        opts.positive_max_speed = speed
        mp.osd_message("Max speed: " .. speed)
        mp.set_property_number("speed", 1)
    end
end

mp.add_key_binding(nil, "speedup", speed_up, {repeatable=true,complex=true})
mp.add_key_binding(nil, "setmaxspeed", set_max_speed)
-- vim: expandtab ts=4 sw=4
