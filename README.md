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

## MIT License

MIT License

Copyright (c) 2025, Faisal Hasan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## GNU General Public License (GPL)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
