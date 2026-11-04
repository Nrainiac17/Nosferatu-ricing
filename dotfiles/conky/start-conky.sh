#!/bin/bash
# Close any running instances first to prevent duplicates
killall conky

# Wait a brief moment
sleep 1

# Start individual widgets
conky -d ~/.config/conky/conky.conf
conky -d ~/.config/conky/weather.conf
conky -d  ~/.config/conky/CPU-section.conf
