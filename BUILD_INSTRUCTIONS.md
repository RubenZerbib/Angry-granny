# Build and Publish Instructions

## Quick Start - Local Development

### Start Rojo Server
```bash
rojo serve
```

Then in Roblox Studio:
1. Install the **Rojo plugin** from the marketplace
2. Click **Plugins ? Rojo ? Connect** (localhost:34872)
3. Code synchronizes automatically
4. Press **Play Solo** to test

## Build .rbxlx File

### Create build directory
```bash
mkdir -p build
```

### Build the place file
```bash
rojo build --output build/AngryGranny.rbxlx
```

Or using the default project config:
```bash
rojo build default.project.json -o build/AngryGranny.rbxlx
```

### Open and Publish
1. Open `build/AngryGranny.rbxlx` in Roblox Studio
2. Test in **Play Solo** (verify HUD shows, Granny spawns at bed, RemoteEvents work)
3. Check **Output** window for server logs:
   - `[SERVER] ? Init complete (Remotes, NightLoop, Granny).`
   - `[GRANNY] Initializing Granny AI?`
   - `[NIGHT] Starting night loop?`
4. Go to **File ? Publish to Roblox As?**

## Expected Behavior on Play

? **Debug HUD** appears in top-left:
```
DEBUG HUD
Granny: Sleeping
Night: 1
Remotes: OK
```

? **Granny spawns** at bed anchor (behind spawn) in Sleeping state

? **RemoteEvents** created automatically:
- DecibelUpdate
- NightUpdate
- EventSpawn
- PlayerAction
- GrannyState
- Purchase
- Reward

? **Server logs** show initialization:
```
[DB    ]  Created RemoteEvent DecibelUpdate
[DB    ]  Created RemoteEvent NightUpdate
...
[GRANNY]  Initializing Granny AI?
[NIGHT ]  Starting night loop?
[SERVER] ? Init complete (Remotes, NightLoop, Granny).
```

## Configure IAP (In-App Purchases)

### 1. Enable API Access
**Game Settings ? Security ? Enable Studio Access to API Services** ?

### 2. Create Game Passes & Developer Products

Go to [Roblox Creator Hub](https://create.roblox.com/dashboard/creations):

**Game Passes** (permanent):
- `silent_shoes` - 149 Robux
- `clock_tuner_pro` - 149 Robux
- `soft_close_hinges` - 600 Robux

**Developer Products** (consumable):
- `radio_lullaby` - 100 Robux
- `earplugs_granny` - 100 Robux
- `pro_insoles_v2` - 60 Robux
- `white_noise_box` - 60 Robux
- `panic_button_radio` - 30 Robux
- (see `src/shared/ItemCatalog.lua` for full list)

### 3. Update Item IDs

Edit `src/shared/ItemCatalog.lua`:

```lua
local GamePassIds = {
  silent_shoes = 1234567890,  -- Replace with your actual ID
  clock_tuner_pro = 1234567891,
  soft_close_hinges = 1234567892,
}

local DevProductIds = {
  radio_lullaby = 9876543210,  -- Replace with your actual ID
  earplugs_granny = 9876543211,
  -- ...
}
```

### 4. Test IAP

?? **Important:** Set game to **Public** to test IAP in real conditions.

## Debug Toggle

Server debug logs are controlled by `src/server/ServerDebug` (auto-created by Init.server.lua):

```lua
local M = { 
  ENABLED = true,  -- Master switch
  TAGS = {
    NIGHT=true,    -- Night system logs
    GRANNY=true,   -- Granny AI logs
    EVENTS=true,   -- Event spawning logs
    DB=true,       -- Decibel system logs
    IAP=false      -- Purchase logs (disabled by default)
  }
}
```

To disable debug output, set `ENABLED = false` or toggle individual tags.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Granny not spawning | Check workspace for existing "Granny" model, or let Init spawn it automatically |
| No RemoteEvents | Init.server.lua creates them automatically on first run |
| No debug HUD | Check PlayerGui for "DebugHUD" ScreenGui |
| Server errors in Output | Check all .server.lua files are in ServerScriptService |
| IAP not working | Verify Game Settings ? Security ? API Services enabled, and IDs are correct |

## Deployment Checklist

- [ ] Test Play Solo - verify Granny spawns in Sleeping state
- [ ] Check Output - no errors, all systems initialized
- [ ] Verify Debug HUD shows correct info
- [ ] Build .rbxlx file
- [ ] Open in Studio and test again
- [ ] Replace IAP placeholder IDs with real IDs
- [ ] Enable API Services in Game Settings
- [ ] Publish to Roblox
- [ ] Create all Game Passes & Dev Products
- [ ] Update ItemCatalog.lua with real IDs
- [ ] Republish with IAP IDs
- [ ] Set game to Public
- [ ] Test IAP purchases in live game

---

**Ready to publish! ??**
