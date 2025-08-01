# 🧭 Nearest Postal Integration for QBCore

A simple and effective Nearest Postal integration for FiveM QBCore servers.  
Displays the closest postal code based on your current location — ideal for immersive roleplay, dispatch systems, and precise location tracking.

## ✨ Features

- 📌 Shows the nearest postal based on player coordinates
- 🗺️ Works with Gabz, default GTA map, and most custom maps
- 🧱 Lightweight and optimized for client performance
- 🔧 Easy to integrate with any QBCore-based scripts
- 💬 Supports exports for custom usage in other scripts

## 🧪 How to Use

Example usage in your `client.lua`:
```lua
local postal = exports['nearest-postal']:getPostal()
print("Nearest Postal:", postal)
