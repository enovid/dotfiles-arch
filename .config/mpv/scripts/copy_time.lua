local utils = require 'mp.utils'
local msg = require 'mp.msg'

local function set_clipboard(text)
	local res = utils.subprocess({ args = {
        'powershell', '-NoProfile', '-Command', string.format([[& {
            Trap {
                Write-Error -ErrorRecord $_
                Exit 1
            }
            Add-Type -AssemblyName PresentationCore
            [System.Windows.Clipboard]::SetText('%s')
        }]], text)
    } })
end

mp.add_key_binding("Ctrl+c", "copy", function()
  local time = mp.get_property_osd('time-pos')
  time = time..".000"
  set_clipboard(time)
	mp.osd_message("Copied time: "..time)
end)


