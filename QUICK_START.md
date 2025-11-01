# ?? Quick Start - Angry Granny Manor

## Start Playing in 3 Steps

### 1. Start Rojo Server
```bash
cd /workspace
rojo serve
```

### 2. Connect in Studio
1. Open **Roblox Studio**
2. Click **Plugins** ? **Rojo** ? **Connect**
3. Should connect to `localhost:34872`
4. Wait for sync to complete

### 3. Play!
- Press **F5** or click **Play Solo**
- You spawn in the **Entryway**
- Press **1** to equip your flashlight
- **Explore and complete tasks!**

---

## What You'll See

### Spawning
- You start in a dark manor entrance
- Debug HUD in top-left shows: `Granny: Sleeping`
- Flashlight appears in your inventory

### Exploring
- **16 rooms** to discover
- Dark Gothic atmosphere with fog
- Room lights provide some visibility
- Stairs lead to 2nd floor

### Tasks
- Walk near glowing objects
- **ProximityPrompt** appears
- **Hold E** to complete task
- Object turns **green** when done
- **+5 Coins** earned

---

## Controls

| Key | Action |
|-----|--------|
| WASD | Move |
| Space | Jump |
| Mouse | Look around |
| 1 | Equip flashlight |
| E | Hold to interact (when prompted) |

---

## First Task Tutorial

1. **Find the living room** (connected to entryway)
2. Look for a **window with open shutters**
3. Walk close until you see: **"Close Shutters"**
4. **Hold E** for 2 seconds
5. Shutters close, object turns green
6. **+5 Coins!**

---

## Troubleshooting

### "Can't see anything!"
? Press **1** to equip flashlight, or increase `Lighting.Brightness` in `Init.server.lua`

### "No tasks spawn"
? Wait 3 seconds after game starts. Check Output for errors.

### "Granny doesn't appear"
? Go upstairs to GrannyBedroom (far left on floor 2)

### "Game crashes"
? Check **Output** window in Studio for errors. Make sure all files synced via Rojo.

---

## Map Guide

```
GROUND FLOOR:
Storage ? DiningRoom ? Library ? Nursery
            ?            ?
        LivingRoom ???????
            ?            ?
        Entryway ??? Kitchen ??? Study
        [YOU START HERE]

UPSTAIRS (via stairs):
GrannyBedroom ? Bedroom2 ? Bedroom3
[GRANNY!]         ?
               Hallway ??? GuestRoom
                  ?
              Bathroom2
```

---

## Next Steps

1. **Explore all 16 rooms**
2. **Complete 5+ tasks** to earn coins
3. **Go upstairs** and peek at Granny (she's sleeping!)
4. **Survive the night** (3.5 minutes)
5. **Read GAMEPLAY_GUIDE.md** for advanced tips

---

## Files to Read

- **GAMEPLAY_GUIDE.md** - Complete gameplay mechanics
- **PLAYABLE_GAME_SUMMARY.md** - Implementation overview
- **BUILD_INSTRUCTIONS.md** - How to build and publish

---

## Having Fun?

Customize your experience:
- Add more rooms in `ManorGenerator.server.lua`
- Create new tasks in `InteractivePrefabs.server.lua`  
- Adjust difficulty in `Config.lua`
- Add sound effects
- Improve Granny's model

**Enjoy exploring the manor!** ????
