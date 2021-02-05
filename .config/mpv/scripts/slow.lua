
options = require 'mp.options'
msg = require 'mp.msg'

local opts = {
    speed_increase="+0.1",
    max_speed=0.5,
    decay_delay=0.1,
    decay_interval=0.05,
    speed_decrease="-0.1"
}

options.read_options(opts)

local timer = nil
local paused
local muted
local min_changed = false
local original_min_speed = 0.4
local active = false

local function set_min_speed()
    local speed = mp.get_property_number("speed")
    if min_changed == false then
        original_min_speed = opts.max_speed
    end
    new_speed = speed
    if speed < 1 then
        min_changed = true
    elseif speed >= 1 then
        new_speed = original_min_speed
    end
    opts.max_speed = new_speed 
    mp.osd_message("Min speed: " .. new_speed)
end

local function pause()
    msg.debug("pause fast-forwarding")
    if timer ~= nil then timer:stop() end
end

local function resume()
    msg.debug("resume fast-forwarding")
    if timer ~= nil then timer:resume() end
end

local function on_pause_change(_, pause)
    if pause then
        pause()
    else
        resume()
    end
end

local function on_speed_change(_, speed)
    if speed > 1 then
        msg.debug("stop fast-forwarding")

        if timer ~= nil then 
            timer:kill() 
            timer = nil
        end

        mp.unobserve_property(on_pause_change)
        mp.unobserve_property(on_speed_change)
        mp.set_property_bool("pause", paused)
        mp.set_property_number("speed", 1)
        mp.osd_message("Speed: 1")
    elseif speed <= opts.max_speed then
        -- clamp speed
        mp.set_property_number("speed", opts.max_speed)
        mp.osd_message("▶▶ x" .. opts.max_speed)
    else
        mp.osd_message("▶▶ x" .. string.format("%.2f", speed), 10)
    end
end

local function change_speed(amount)
    local speed = mp.get_property_number("speed")
    local op = amount:sub(1, 1)
    local val = tonumber(amount:sub(2))

    if     op == "+" then speed = speed + val
    elseif op == "-" then speed = speed - val
    elseif op == "*" then speed = speed * val
    elseif op == "/" then speed = speed / val
    else msg.warn("unable to parse value: `" .. amount .. "'")
    end

    mp.set_property_number("speed", speed)
end

local function slow_down()
    change_speed(opts.speed_increase)
end

local function begin_slow_down()
    msg.trace("begin_slow_down()")
    slow_down()
    timer = mp.add_periodic_timer(opts.decay_interval, slow_down)
end

local function speed_down(t)
    local speed = mp.get_property_number("speed")
    
    if speed == 1 or active == false then
        msg.debug("start fast-forwarding")
        paused = mp.get_property_bool("pause")
        mp.observe_property("pause", "bool", on_pause_change)
        mp.observe_property("speed", "number", on_speed_change)

        mp.set_property_bool("pause", false)

        muted = mp.get_property_bool("mute")
        if muted == false then
            mute()
        end
        active = true
    end

    key_event = t['event'] -- strings: down, repeat, up or press
    if key_event == "up" then
        active = false
        if timer ~= nil then timer:kill() end
        timer = mp.add_timeout(opts.decay_delay, begin_slow_down)
        if muted == false then
            unmute()
        end
    end

    if paused == true then
        mp.add_timeout(0.1, print_speed)
        mp.set_property_number("speed", opts.max_speed)
    else
        change_speed(opts.speed_decrease)
    end
end

function mute()
    mp.set_property("mute", "yes")
end

function unmute()
    mp.set_property("mute", "no")
end

function print_speed()
    mp.osd_message("▶▶ x" .. mp.get_property_number("speed"))
end

mp.add_key_binding(nil, "slowdown", speed_down, {repeatable=true,complex=true})
mp.add_key_binding(nil, "setminspeed", set_min_speed)
-- vim: expandtab ts=4 sw=4

