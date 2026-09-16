# fr_hud

Modern modular HUD for FiveM — merged into **one resource**.

Supports **ESX**, **QBCore**, and **Qbox** with auto framework detection.

> Design inspired by the HUD style seen on popular GTA RP servers. Not affiliated with or endorsed by any of them.

## Features

- Player HUD (health, armor, hunger, thirst, stress, stamina, oxygen, voice, ammo)
- Vehicle HUD (speed, RPM, fuel, lights, seatbelt, lock, engine)
- Circular minimap + compass / street labels
- Pulse (heart rate) UI
- Auto UI scaling for different resolutions
- Simple `config.lua`
- GitHub update check (server console notice on startup)

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

1. Copy `fr_hud` into your server `resources` folder  
2. Add to `server.cfg`:

```cfg
ensure fr_hud
```

3. Restart the server (or `ensure fr_hud`)

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
- `Config.UpdateCheck`

## Update Check

On startup the server queries the GitHub repo once and prints a notice to the server console when a newer version exists. Players are never notified.

```lua
Config.UpdateCheck = {
    enabled = true,
    repository = '3597722621/fr_hud', -- owner/repo, empty disables the check
    downloadUrl = '',                      -- empty = repo releases page
    debug = false,                         -- log failures / "already up to date"
}
```

The check reads `api.github.com/repos/<repository>/releases/latest` and falls back to the tag list when the repo has no release. The local version comes from `version` in `fxmanifest.lua`, so bump it on every release.

## Changelog

### 1.0.0

- First release under the `fr_hud` name — a modern modular HUD for FiveM
- Supports **ESX**, **QBCore**, and **Qbox** with auto framework detection
- GitHub update check: the server console prints a notice when a newer version exists

## Credits

- Original modular HUD concept by Mirage
- ESX / QB bridge, merge, and scaling adaptations for this package

## License

Open source for learning and server use.  
Please keep credits. Do not republish as the official release of any server or project.
