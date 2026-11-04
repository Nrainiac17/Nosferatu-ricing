#!/bin/bash
mkdir -p ~/.cache
CACHE="$HOME/.cache/weather.json"

# Download new data only if the cache file doesn't exist or is older than 30 minutes
if [ ! -f "$CACHE" ] || [ -n "$(find "$CACHE" -mmin +30 2>/dev/null)" ]; then
    curl -s "https://wttr.in/Thane?format=j1" > "$CACHE"
fi

# Parse current weather and today's highs/lows
TEMP=$(jq -r '.current_condition[0].temp_C' "$CACHE")
COND=$(jq -r '.current_condition[0].weatherDesc[0].value' "$CACHE")
TODAY_H=$(jq -r '.weather[0].maxtempC' "$CACHE")
TODAY_L=$(jq -r '.weather[0].mintempC' "$CACHE")

# Parse Day 1 (Tomorrow) Forecast
D1_DATE=$(jq -r '.weather[1].date' "$CACHE")
D1_DAY=$(date -d "$D1_DATE" +%a) # Converts 2026-07-19 to "Sun"
D1_H=$(jq -r '.weather[1].maxtempC' "$CACHE")
D1_L=$(jq -r '.weather[1].mintempC' "$CACHE")

# Parse Day 2 (Day after tomorrow) Forecast
D2_DATE=$(jq -r '.weather[2].date' "$CACHE")
D2_DAY=$(date -d "$D2_DATE" +%a)
D2_H=$(jq -r '.weather[2].maxtempC' "$CACHE")
D2_L=$(jq -r '.weather[2].mintempC' "$CACHE")

# Map the current weather code to a JetBrains Nerd Font Icon
CODE=$(jq -r '.current_condition[0].weatherCode' "$CACHE")
case $CODE in
    113) ICON="󰖙 " ;; # Sunny/Clear
    116) ICON="󰖕 " ;; # Partly cloudy
    119|122) ICON="󰖐 " ;; # Cloudy/Overcast
    143|248|260) ICON="󰖑 " ;; # Fog
    176|263|266|293|296|299|302|305|308|311|353|356|359) ICON="󰖗 " ;; # Rain
    200|386|389|392|395) ICON="󰖓 " ;; # Storm
    227|230|320|323|326|329|332|335|338|350|362|365|368|371) ICON="󰖘 " ;; # Snow
    *) ICON="󰖐 " ;; # Default fallback
esac

# Feed the formatted layout back to Conky
cat << EOF
# --- Current Weather Section ---
\${voffset 10}\${goto 20}\${font JetBrainsMono Font:bold:size=16}Thane\${alignr 20}\${font JetBrainsMono Nerd Font:size=22}${ICON}\${font}
\${voffset -10}\${goto 20}\${font JetBrainsMono Font:medium:size=48}${TEMP}°\${font}
\${voffset 5}\${goto 20}\${font JetBrainsMono Font:bold:size=11}${COND}\${font}
\${voffset 2}\${goto 20}\${font JetBrainsMono Font:size=11}H:${TODAY_H}°  L:${TODAY_L}°\${font}

# --- Multi-Day Forecast Section ---
\${voffset 8}\${goto 20}\${font JetBrainsMono Font:size=11}Tomorrow       \${alignr 20}${D1_H}° / ${D1_L}°\${font}
\${voffset 5}\${goto 20}\${font JetBrainsMono Font:size=11}${D2_DAY}      \${alignr 20}${D2_H}° / ${D2_L}°\${font}
EOF
