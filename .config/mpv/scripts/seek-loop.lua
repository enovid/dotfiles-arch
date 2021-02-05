local pause_on_seek = false

function toggle_pause_on_seek_loop()
    pause_on_seek = not pause_on_seek
    if pause_on_seek then
        mp.osd_message("Pause after loop: yes")
    else
        mp.osd_message("Pause after loop: no")
    end
end

function seek_loop_start()
  if mp.get_property_number("ab-loop-a") ~= nil then
    local allArgs = {}
    allArgs[1] = "seek"
    allArgs[2] = math.floor(mp.get_property_number("ab-loop-a"))
    allArgs[3] = "absolute"
    local result, err = mp.command_native(allArgs, nil)
    if pause_on_seek then
        mp.set_property("pause", "yes")
    end
    mp.osd_message("Seek A-B loop start")
  end
end

function seek_loop_end()
  if mp.get_property_number("ab-loop-b") ~= nil then
    local allArgs = {}
    allArgs[1] = "seek"
    allArgs[2] = math.floor(mp.get_property_number("ab-loop-b"))
    allArgs[3] = "absolute"
    local result, err = mp.command_native(allArgs, nil)
    mp.osd_message("Seek A-B loop end")
  end
end

function set_loop_start()
  local newStart = mp.get_property("time-pos")
  local newStartOSD = mp.get_property_osd("time-pos")
  mp.set_property("ab-loop-a", newStart)
  mp.osd_message("A-B loop start: " .. newStartOSD)
end

function set_loop_end()
  if mp.get_property_number("ab-loop-b") ~= nil then
    clear_loop_end()
  else
    local newEnd = mp.get_property("time-pos")
    local newEndOSD = mp.get_property_osd("time-pos")
    mp.set_property("ab-loop-b", newEnd)
    mp.osd_message("A-B loop end: " .. newEndOSD)
    if mp.get_property_number("ab-loop-a") ~= nil then
      seek_loop_start()  
    end
  end
end

function clear_loop_end()
  mp.set_property("ab-loop-b", 'no')
  mp.osd_message("Clear A-B loop end")
end

function clear_loop()
  mp.set_property("ab-loop-a", 'no')
  mp.set_property("ab-loop-b", 'no')
  mp.osd_message("Clear A-B loop")
end

function framestep_release(t)
    key_event = t['event'] -- strings: down, repeat, up or press
    if key_event == "up" then
      mp.set_property("pause", "no")
    else
      mp.commandv('frame-back-step')
    end
end

mp.add_key_binding(nil, "framebackstep_release", framestep_release, {repeatable=true,complex=true})
mp.register_script_message("seek_loop_start", seek_loop_start)
mp.register_script_message("seek_loop_end", seek_loop_end)
mp.register_script_message("set_loop_start", set_loop_start)
mp.register_script_message("set_loop_end", set_loop_end)
mp.register_script_message("clear_loop", clear_loop)
mp.register_script_message("toggle_pause_on_seek_loop", toggle_pause_on_seek_loop)
