#!/bin/bash

# === Configuration ===
PING_INTERVAL=3         # seconds between pings
PING_DURATION=30        # total duration in seconds
mkdir -p output         # make sure output folder exists
CSV_FILE="output/ping_log.csv"
GRAPH_FILE="output/latency_graph.png"
OUTPUT_FILE="output/players_info.txt"
RESET="\e[0m"

# === Dependency Check ===
if ! command -v jq &> /dev/null; then
    echo "❗ 'jq' not installed. Please install it with: sudo apt install jq"
    exit 1
fi

if ! command -v gnuplot &> /dev/null; then
    echo "❗ 'gnuplot' not installed. Please install it with: sudo apt install gnuplot"
    exit 1
fi

# === Prompt ===
read -p "Enter FiveM Server IP or domain: " SERVER_IP
read -p "Enter FiveM Server Port: " QUERY_PORT

# === Check if Server is Reachable ===
if ! ping -c 1 "$SERVER_IP" &> /dev/null; then
    echo "❌ Server is not reachable. Exiting."
    exit 1
fi

# === Get detailed IP info ===
echo -e "\n🌍 Fetching server info from ip-api.com...\n"
IP_DATA=$(curl -s "http://ip-api.com/json/$SERVER_IP")

# Debug output: Check raw JSON if something fails
# echo "$IP_DATA"

STATUS=$(echo "$IP_DATA" | jq -r '.status')

if [[ "$STATUS" != "success" ]]; then
    echo "❌ Failed to fetch IP information. Server may be unreachable or invalid IP/domain."
    exit 1
fi

# Extract values
IP=$(echo "$IP_DATA" | jq -r '.query')
CITY=$(echo "$IP_DATA" | jq -r '.city')
REGION=$(echo "$IP_DATA" | jq -r '.regionName')
COUNTRY=$(echo "$IP_DATA" | jq -r '.country')
ISP=$(echo "$IP_DATA" | jq -r '.isp')
ORG=$(echo "$IP_DATA" | jq -r '.org')
ASN=$(echo "$IP_DATA" | jq -r '.as')
LAT=$(echo "$IP_DATA" | jq -r '.lat')
LON=$(echo "$IP_DATA" | jq -r '.lon')
TIMEZONE=$(echo "$IP_DATA" | jq -r '.timezone')
ZIP=$(echo "$IP_DATA" | jq -r '.zip')

# === Output ===
echo -e "IP:             $IP"
echo -e "City:           $CITY"
echo -e "Region:         $REGION"
echo -e "Country:        $COUNTRY"
echo -e "ISP:            $ISP"
echo -e "Organization:   $ORG"
echo -e "ASN:            $ASN"
echo -e "Latitude:       $LAT"
echo -e "Longitude:      $LON"
echo -e "Timezone:       $TIMEZONE"
echo -e "ZIP:            $ZIP"

# === Fetch Player Count and Server Info ===
INFO_URL="http://$SERVER_IP:$QUERY_PORT/info.json"
PLAYERS_URL="http://$SERVER_IP:$QUERY_PORT/players.json"

echo -e "\n👾 Fetching player count and server info...\n"

INFO_JSON=$(curl -s "$INFO_URL")
PLAYERS_JSON=$(curl -s "$PLAYERS_URL")

if [[ -z "$INFO_JSON" || "$INFO_JSON" == "null" ]]; then
    echo "❌ Failed to fetch info.json from server."
    exit 1
fi

SERVER_NAME=$(echo "$INFO_JSON" | jq -r '.vars.sv_hostname // "Unknown"')
GAMETYPE=$(echo "$INFO_JSON" | jq -r '.vars.gametype // "Unknown"')
MAPNAME=$(echo "$INFO_JSON" | jq -r '.vars.mapname // "Unknown"')
TAGS=$(echo "$INFO_JSON" | jq -r '.vars.tags // "None"')
VERSION=$(echo "$INFO_JSON" | jq -r '.version // "Unknown"')
LOCALE=$(echo "$INFO_JSON" | jq -r '.vars.locale // "Unknown"')
ENFORCE_STEAM=$(echo "$INFO_JSON" | jq -r '.vars.sv_enforceGameBuild // "Not enforced"')
DISCORD_LINK=$(echo "$INFO_JSON" | jq -r '.vars.discord // "Not provided"')

echo -e "🌐 Location: $CITY, $COUNTRY"
echo -e "📡 ISP: $ISP"
echo -e "📜 Server name: $SERVER_NAME"
echo -e "🎮 Game type: $GAMETYPE"
echo -e "🗺️ Map: $MAPNAME"
echo -e "🏷️ Tags: $TAGS"
echo -e "🌐 Locale: $LOCALE"
echo -e "🛠️ Server version: $VERSION"
echo -e "🧩 Steam Enforce Build: $ENFORCE_STEAM"
echo -e "💬 Discord: $DISCORD_LINK"

PLAYER_COUNT=$(echo "$PLAYERS_JSON" | jq length)

if [[ "$PLAYER_COUNT" == "null" || -z "$PLAYER_COUNT" ]]; then
    echo "❌ Unable to retrieve player count or the player list is empty."
else
    echo "💥 Player count: $PLAYER_COUNT"
    echo "📜 Server name: $SERVER_NAME"
fi

# === CSV Header ===
echo "Time,Latency" > "$CSV_FILE"

# === Ping Loop ===
echo -e "\n📡 Starting ping monitoring for $PING_DURATION seconds every $PING_INTERVAL sec...\n"
START_TIME=$(date +%s)
while [ $(($(date +%s) - START_TIME)) -lt $PING_DURATION ]; do
    TIMESTAMP=$(date +%H:%M:%S)
    PING_RESULT=$(ping -c 1 "$SERVER_IP")
    
    LATENCY=$(echo "$PING_RESULT" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    TTL=$(echo "$PING_RESULT" | grep 'ttl=' | awk -F'ttl=' '{print $2}' | cut -d' ' -f1)

    if [[ -z "$LATENCY" ]]; then
        LATENCY="NaN"
        echo "$TIMESTAMP,Timeout" | tee -a "$CSV_FILE"
        echo -e "$TIMESTAMP, Timeout"
    else
        echo "$TIMESTAMP,$LATENCY,$TTL" | tee -a "$CSV_FILE"
        echo -e "$TIMESTAMP, Latency: $LATENCY ms, TTL: $TTL"
    fi

    sleep $PING_INTERVAL
done

# === Generate Latency Graph ===
echo -e "\n📈 Generating latency graph with gnuplot...\n"

gnuplot <<-EOF
    set terminal png size 800,400
    set output "$GRAPH_FILE"
    set title "FiveM Server Latency ($SERVER_IP)"
    set xlabel "Time"
    set ylabel "Latency (ms)"
    set xdata time
    set timefmt "%H:%M:%S"
    set format x "%H:%M"
    set grid
    set datafile separator ","
    plot "$CSV_FILE" using 1:2 with linespoints title "Ping" lw 2
EOF

echo -e "\n✅ Done! Graph saved as $GRAPH_FILE"

# === Save Player Info ===
if [[ "$PLAYER_COUNT" -eq 0 ]]; then
    echo -e "\n🚫 No players are currently online." | tee "$OUTPUT_FILE"
else
    echo -e "\n🎮 Connected player data saved...\n" | tee "$OUTPUT_FILE"

    echo "$PLAYERS_JSON" | jq -r '
      .[] |
      "Player: \(.name)\nID: \(.id)\nPing: \(.ping)\nIdentifiers:\n\(.identifiers | if length > 0 then join(", ") else "None" end)\n---"
    ' | tee -a "$OUTPUT_FILE"
fi
