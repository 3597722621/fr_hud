# nopixel_hud

NoPixel-inspired modular HUD for FiveM — merged into **one resource**.

Supports **ESX**, **QBCore**, and **Qbox** with auto framework detection.

> Design inspired by NoPixel-style HUDs. Not affiliated with NoPixel.

## Features

- Player HUD (health, armor, hunger, thirst, stress, stamina, oxygen, voice, ammo)
- Vehicle HUD (speed, RPM, fuel, lights, seatbelt, lock, engine)
- Circular minimap + compass / street labels
- Pulse (heart rate) UI
- Auto UI scaling for different resolutions
- Simple `config.lua`

## Framework / Needs

| Framework | Hunger / Thirst |
|-----------|-----------------|
| ESX | `esx_status` |
| QBCore | `PlayerData.metadata` + `hud:client:UpdateNeeds` |
| Qbox | metadata + state bags (`hunger` / `thirst` / `stress`) |

Set in `config.lua`:

```lua
Config.Framework = 'auto' -- 'auto' | 'esx' | 'qb' | 'qbox' | 'standalone'
```

## Installation

1. Copy `nopixel_hud` into your server `resources` folder  
2. Add to `server.cfg`:

```cfg
ensure nopixel_hud
```

3. Restart the server (or `ensure nopixel_hud`)

Stop other HUDs (e.g. `qbx_hud`) to avoid overlapping UI.

## Commands

| Command / Key | Action |
|---------------|--------|
| `/cinematic` | Toggle cinematic bars |
| `/togglemap` | Toggle minimap |
| `B` | Seatbelt |

## Config

Edit `config.lua`:

- `Config.Framework`
- `Config.UseQbxMedical`
- `Config.CrashSpeedThreshold`
- `Config.BleedingHealthThreshold`
- `Config.HealingEvents`

## Credits

- Original modular HUD concept by Mirage (NoPixel-inspired)
- ESX / QB bridge, merge, and scaling adaptations for this package

## License

Open source for learning and server use.  
Please keep credits. Do not rebrand as official NoPixel content.
