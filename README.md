# Ro-TAS
Really basic, low-end universal TAS recorder/player made for Roblox
> **Reminder**: This script in itself is fully customizable, not including an interface!

## Bundler ⚙️
> [!WARNING]
> Tape does not support Lua types and most Luau-exclusive functions

This project is handled and bundled using [Tape](https://github.com/Belkworks/tape), a Lua bundler.

## Script 📜
Use the latest version of RoTAS with the script below:
```lua
-- Loads the contents you'll see in the main repository
-- For customizing this TAS, I recommend you use our code as a base!

loadstring(game:HttpGet(
 "https://github.com/Starry-Proj/RoTAS/releases/download/v1.0.a/release.luau"
))()
```

## Features 🔢
1. **TAS Recording** (Key: **H**)
- - Replicates **exactly** what you recorded
  - As of now, it does **not** include player animations
2. **TAS Playback** (Key: **G**)
- - Reads JSON TAS file and replays the movements
3. **Pause / Unpause** (Key: **F**)
- - Introduces frame trimming with unpausing, [read source](https://github.com/Starry-Proj/RoTAS/blob/main/framework.luau)
4. **Frame Manipulation** (Keys: **Z, X**)
 - - When paused, allows you to go backward or forward in the current recording
   - When unpaused, any frames ahead of your current frame will **be permanently removed**

## Contributors 🛠️
1. [Suno](https://github.com/mr-suno) - Developer
