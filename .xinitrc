# Fix for dunst failing to start via systemd
systemctl --user import-environment DISPLAY

# Disable display sleep
xset s off -dpms

# Source colors from .Xresources for use in dwm
xrdb .Xresources

# Enable 2nd monitor
xrandr --output DP-2 --auto --left-of DVI-D-0

# Start dwm
exec /home/enovid/bin/startdwm
