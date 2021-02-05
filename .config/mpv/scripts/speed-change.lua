local opts = {
    min_speed = 0.35,
    max_speed = 3.0,
    mute = false,
    fast_increment = 0.5,
    slow_increment = 0.25
}

local pause = false

-- speed up if speed is below max_speed
-- if speed < 1 then speed up until speed == 1 then wait 
-- half a second before continuing to speed up
function increase_speed()
  speed = mp.get_property_number("speed")
  if speed <= opts.max_speed then
    if speed < 1 then
      newSpeed = speed + opts.slow_increment
    else
      newSpeed = speed + opts.fast_increment
    end
    if speed < 1 and newSpeed >= 1 then
      pause = true
      mp.set_property_number("speed", 1)
      mp.add_timeout(0.5, continue_speed_change)
    elseif pause == false then
      mp.set_property_number("speed", newSpeed)
    end
  end
  set_mute()
  mp.osd_message("Speed: " .. mp.get_property_osd("speed"))
end

-- slow down if speed is above min_speed
-- if speed > 1 then slow down until speed == 1 then wait 
-- half a second before continuing to slow down 
function lower_speed()
  speed = mp.get_property_number("speed")
  if speed >= opts.min_speed then
    if speed <= 1 then
      newSpeed = speed - opts.slow_increment
    else
      newSpeed = speed - opts.fast_increment
    end
    if speed > 1 and newSpeed <= 1 then
      pause = true
      mp.set_property_number("speed", 1)
      mp.add_timeout(0.5, continue_speed_change)
    elseif pause == false then
      mp.set_property_number("speed", newSpeed)
    end
  end
  set_mute()
  mp.osd_message("Speed: " .. mp.get_property_osd("speed"))
end

function continue_speed_change()
  pause = false
end

function set_mute()
  if opts.mute == true then
      speed = mp.get_property_number("speed")
      if speed < 0.8 or speed > 1.2 then
        mp.set_property("mute", "yes")
      end
  end
end

function reset_speed()
  mp.set_property_number("speed", 1)
  --mp.set_property("mute", "no")
end

mp.register_script_message("slow_down", lower_speed)
mp.register_script_message("speed_up", increase_speed)
mp.register_script_message("reset_speed", reset_speed)
