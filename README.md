# FiveM Server Monitoring Script

This Bash script allows you to monitor the latency, player count, and server information of a FiveM server. It fetches server data such as IP info, server name, game type, and player list, while also performing continuous ping monitoring to measure latency and generate latency graphs.

## Features

- **Server Info Fetching**: Get detailed information about the server's location, ISP, organization, and more using `ip-api.com`.
- **Player Count**: Fetches the current player count from the server and displays player information (ID, ping, identifiers).
- **Ping Monitoring**: Continuously pings the server at specified intervals, logs latency and TTL values, and handles timeouts.
- **Graph Generation**: Generates a latency graph using `gnuplot` for visualizing server performance over time.
- **Exportable Data**: Saves ping latency data to a CSV file, player information to a text file, and creates a latency graph in PNG format.

## Requirements

- **`jq`**: A lightweight and flexible command-line JSON processor. Install using:
  ```bash
  sudo apt install jq
