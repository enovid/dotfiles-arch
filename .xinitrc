# Source colors from .Xresources for use in dwm
xrdb .Xresources

# Enable 2nd monitor
xrandr --output DP-2 --auto --left-of DVI-D-0

# Start dwm
exec /home/enovid/bin/startdwm
