// when seeking displays position and
// duration like so: 00:00 / 120:00
// this is different from MPC which
// uses 00:00:00 / 02:00:00

function add_zero(val)
{
    val = Math.round(val);
    return val > 9 ? "" + val : "0" + val;
}

function format(val)
{
    var sec = Math.round(val);

    if (sec < 0)
        sec = 0;

    pos_min_floor = Math.floor(sec / 60);
    sec_rest = sec - pos_min_floor * 60;
    return add_zero(pos_min_floor) + ":" + add_zero(sec_rest);
}

function on_seek(_)
{
  pos = format(mp.get_property_number("time-pos"))
  if (pos != "00:00") {
      display_string = pos + " / " + format(mp.get_property_number("duration"))
      mp.commandv("show-text", display_string);
  }
}

mp.register_event("seek", on_seek);
