# ??? Angry Granny Manor - Gameplay Guide

## ?? How to Play

### Objective
Survive the night by completing tasks in the manor while avoiding Granny. Each task generates noise - make too much noise and Granny will wake up!

### Starting the Game

1. **Launch with Rojo:**
   ```bash
   rojo serve
   ```
   
2. **Connect in Studio:**
   - Open Roblox Studio
   - Plugins ? Rojo ? Connect (localhost:34872)
   - Press **Play Solo**

3. **You Spawn in the Entryway:**
   - The manor is now fully generated with multiple rooms
   - You have a flashlight in your backpack
   - Granny is sleeping in her bedroom upstairs

### Game Mechanics

#### ?? Movement & Exploration
- **WASD** - Move around
- **Space** - Jump
- **Mouse** - Look around
- **Equip Flashlight** - Press 1 or click it in your hotbar

#### ?? Interactive Tasks
Walk up to glowing objects and you'll see a **ProximityPrompt**:
- **Windows with open shutters** - Hold E to close shutters
- **Clocks** - Hold E to wind the clock
- **Baby cribs** - Hold E to calm the crying baby
- **Phones** - Hold E to answer the ringing phone
- **Radios** - Hold E to turn off static
- **Squeaky doors** - Hold E to oil the hinges

#### ?? Debug HUD (Top-Left)
Shows real-time information:
```
DEBUG HUD
Granny: Sleeping
Night: 1
Remotes: OK
```

#### ?? Rewards
- **+5 Coins** for each completed task
- Tasks turn green when completed
- New tasks spawn as you complete them

### Manor Layout

#### Ground Floor (Level 0)
```
Storage ??? DiningRoom ??? Library ??? Nursery
               ?             ?
           LivingRoom ?????????
               ?             ?
           Entryway ?????  Kitchen ????? Study
           (SPAWN)
```

#### Second Floor (Level 14)
```
GrannyBedroom ??? Bedroom2 ??? Bedroom3
(Granny here!)      ?
                Hallway ????? GuestRoom
                    ?
                Bathroom2
```

#### ?? Stairs
- From **Entryway** to **GrannyBedroom** (be quiet upstairs!)

### Task Types & Locations

| Task Type | Location | Hold Time | Difficulty |
|-----------|----------|-----------|------------|
| Window Shutters | LivingRoom, Bedrooms, Study | 2s | Easy |
| Clock Winding | Library, LivingRoom | 3s | Medium |
| Baby Calming | Nursery | 3s | Hard |
| Phone Answering | Study, LivingRoom, Entryway | 1s | Easy |
| Radio Static | LivingRoom | 1.5s | Easy |
| Door Oiling | Hallways, Storage, Bathroom | 2.5s | Medium |

### Danger System

#### Decibel Meter
- Each task generates noise (dB)
- Noise decays over time
- If total dB exceeds threshold ? **Granny wakes up!**

#### Granny States
1. **Sleeping** ?? (Start) - Safe, explore and complete tasks
2. **Searching** ?? - Awake, investigating noise hotspots
3. **Chasing** ?? - Spotted you! RUN!
4. **Cooldown** ?? - Returning to bed

#### Survival Tips
- ? Complete tasks quickly to minimize noise accumulation
- ? Use your flashlight to navigate dark rooms
- ? Stay away from Granny's bedroom when possible
- ? If Granny wakes up, hide or move to a different floor
- ? Don't complete multiple tasks rapidly (noise adds up!)
- ? Don't make noise near Granny's bedroom
- ? Don't get caught by Granny (instant game over)

### Night Progression

#### Night 1 (Tutorial)
- Duration: 3.5 minutes
- Max concurrent tasks: 1
- dB threshold: 70 (easy)
- Granny speed: 9 studs/sec
- **Goal:** Learn the basics, explore the manor

#### Night 2+
- Duration increases (+10s per night)
- More tasks spawn (up to 5 concurrent)
- dB threshold decreases (gets harder)
- Granny gets faster (+1.1/night)
- More coins rewarded

### Controls Reference

| Action | Key/Button |
|--------|------------|
| Move | WASD |
| Jump | Space |
| Look | Mouse |
| Interact | Hold E (when prompted) |
| Flashlight | Press 1 (hotbar) |
| Shop | Press B (when implemented) |

## ??? Manor Features

### Rooms & Atmosphere
- **Dark Gothic Theme** - Low ambient lighting, fog, shadows
- **Point Lights** - Each room has a chandelier/light source
- **Realistic Layout** - Kitchen, library, bedrooms, nursery, bathrooms
- **Multiple Floors** - Ground floor and second floor connected by stairs
- **Granny's Bedroom** - Special room with her bed (upstairs, far corner)

### Interactive Objects
All tasks appear as **physical objects** in the manor:
- ?? Windows with wooden shutters
- ? Grandfather clocks & wall clocks
- ?? Baby cribs with crying babies
- ?? Rotary phones
- ?? Vintage radios
- ?? Wooden doors with hinges

## ?? Testing Checklist

### Startup Tests
- [ ] Manor generates without errors
- [ ] All rooms appear (16 total)
- [ ] Walls, floors, ceilings present
- [ ] Granny spawns in her bedroom
- [ ] Player spawns in Entryway
- [ ] Flashlight appears in backpack
- [ ] Debug HUD shows "Granny: Sleeping"

### Gameplay Tests
- [ ] Can walk through manor
- [ ] Can climb stairs to second floor
- [ ] Flashlight works and lights up rooms
- [ ] ProximityPrompts appear near tasks
- [ ] Can hold E to complete tasks
- [ ] Completed tasks turn green
- [ ] Coins increment after task completion
- [ ] New tasks spawn after completing one

### Granny AI Tests
- [ ] Granny stays in bedroom initially
- [ ] Granny has WalkSpeed = 0 when sleeping
- [ ] Debug HUD updates when Granny wakes
- [ ] (Later) Granny pathfinds to noise sources

### Atmosphere Tests
- [ ] Dark/spooky lighting
- [ ] Fog visible
- [ ] Room lights work
- [ ] Shadows appear
- [ ] Gothic color scheme (purples, browns)

## ?? Troubleshooting

### "Manor doesn't generate"
**Solution:** Check Output for errors from ManorGenerator. Make sure all modules loaded.

### "No tasks spawn"
**Solution:** Wait 3 seconds for Night 1 to start. Check Output for EventsServer logs.

### "Can't interact with objects"
**Solution:** Make sure ProximityPromptService is enabled. Walk closer to the object.

### "Granny doesn't spawn"
**Solution:** Check GrannyBedroom exists in manor. Look for "GrannyBed" part.

### "Too dark to see"
**Solution:** Equip your flashlight (press 1) or increase Lighting.Brightness in Init.server.lua.

### "Game crashes on start"
**Solution:** Check Output for Lua errors. Common issues:
- Missing modules
- Syntax errors
- Circular dependencies

## ?? Next Steps

### Suggested Improvements
1. **Add more room decorations** - Furniture, paintings, rugs
2. **Improve Granny model** - Use a rig with animations
3. **Add sound effects** - Creaking, footsteps, Granny sounds
4. **More task types** - Fixing pipes, closing curtains, etc.
5. **Power-ups/Items** - Noise reducers, speed boosts
6. **Multiple difficulty modes**
7. **Co-op multiplayer** - Survive with friends

### IAP Integration
Follow BUILD_INSTRUCTIONS.md to:
- Create Game Passes (silent shoes, etc.)
- Create Developer Products (consumables)
- Update ItemCatalog.lua with real IDs

## ?? Success Criteria

Your game is working if:
- ? Manor loads with 16 rooms
- ? You can explore and navigate
- ? Tasks spawn with ProximityPrompts
- ? Completing tasks gives coins
- ? Granny sleeps in her bedroom
- ? Dark, spooky atmosphere
- ? No errors in Output

**Have fun surviving the night in Granny's manor!** ?????
