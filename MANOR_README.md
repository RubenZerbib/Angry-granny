# 🏰 Angry Granny Manor Generator

A procedural generator for creating haunted manor maps for Roblox games. Generates Roblox-ready structures optimized for Rojo import and scripted gameplay.

## 🎮 Features

- **Procedurally generated manor structures** with multiple rooms and layouts
- **Gameplay-ready markers** for player spawns, AI patrol points, hiding spots, key spawns, and more
- **Multiple export formats**: RBXMX (Roblox XML) and Rojo (folder structure)
- **Web-based configurator** with real-time preview
- **Standalone CLI tool** for batch generation
- **Optimized for performance**: Configurable part limits, clean topology, zero unions

## 📁 Project Structure

```
/app/
├── manor_generator/          # Core generation engine
│   ├── generator.py         # Main manor generator
│   ├── models.py            # Data structures
│   ├── markers.py           # Gameplay marker placement
│   ├── rooms/              # Room generators
│   │   ├── base.py         # Base room generator
│   │   ├── hall.py         # Entry hall
│   │   ├── kitchen.py      # Kitchen room
│   │   ├── bedroom.py      # Bedroom generator
│   │   └── basement.py     # Basement generator
│   └── exporters/          # Export handlers
│       ├── rbxmx.py        # Roblox XML exporter
│       └── rojo.py         # Rojo JSON exporter
├── generate_manor.py        # CLI tool
├── backend/
│   └── server.py           # FastAPI backend with manor endpoints
└── frontend/
    └── src/
        └── App.js          # React configurator UI
```

## 🚀 Getting Started

### Web Interface

1. **Start the services**:
```bash
sudo supervisorctl restart all
```

2. **Access the web interface** at your frontend URL

3. **Configure your manor**:
   - Toggle rooms (Basement, Attic, Secret Passage)
   - Adjust scale factor and prop density
   - Set gameplay marker counts

4. **Generate**:
   - Click "Preview Statistics" to validate
   - Click "Generate Manor" to create files
   - Download RBXMX or view Rojo files

### Command Line Interface

```bash
# Basic usage
python3 /app/generate_manor.py --output-dir ./my_manor

# Advanced options
python3 /app/generate_manor.py \
  --output-dir ./my_manor \
  --format both \
  --scale 1.5 \
  --prop-density 0.7 \
  --no-basement \
  --no-attic

# With custom config file
python3 /app/generate_manor.py \
  --config my_config.json \
  --output-dir ./my_manor
```

### CLI Options

- `--output-dir, -o`: Output directory (default: `./output`)
- `--format, -f`: Export format: `rbxmx`, `rojo`, or `both` (default: `both`)
- `--config, -c`: Path to JSON config file
- `--no-basement`: Exclude basement
- `--no-attic`: Exclude attic
- `--no-secret`: Exclude secret passage
- `--scale`: Scale factor (default: 1.0)
- `--prop-density`: Prop density 0.0-1.0 (default: 0.5)

## 🎯 Generated Rooms

### Main Floor
- **Entry Hall**: Large open space with main entrance
- **Kitchen**: Functional kitchen with noise zones
- **Dining Room**: Formal dining area with table and chairs
- **Corridors**: Connecting passages between rooms
- **Exterior Porch**: Entry area

### Upper Floor
- **Bedroom A & B**: Player hiding spots, wardrobes
- **Bathroom**: Smaller utility room
- **Stairs**: Connecting upper and lower floors

### Optional Rooms
- **Basement**: Dark, damp lower level (Granny spawn)
- **Attic**: Dusty upper storage area
- **Secret Passage**: Hidden shortcut

## 🎮 Gameplay Markers

All markers are invisible Parts (1x1x1, Anchored, Transparency=1) for scripting integration:

### Required Markers
- **PlayerSpawn**: Entry hall spawn point
- **GrannySpawn**: AI spawn location (basement or attic)
- **EscapeExit**: Victory condition location

### Utility Markers
- **FuseBox**: Electrical puzzle element
- **Generator**: Power system element

### AI Navigation
- **PatrolPoint_***: 12+ patrol points forming a loop through the manor

### Collectibles
- **KeySpawn_***: 6-8 key spawn locations
- **HidingSpot_***: 4-8 hiding spots (beds, wardrobes)

### Environment
- **NoiseZone_***: Sound detection areas (kitchen, corridors, stairs)

## 📤 Export Formats

### RBXMX (Roblox XML)
- Single file: `Manor.rbxmx`
- Import directly into Roblox Studio:
  1. Open Roblox Studio
  2. Model tab → Import 3D
  3. Select the `.rbxmx` file

### Rojo (Folder Structure)
- Folder structure with `model.json` files
- Organized by room with chunking for large models
- Includes `default.project.json` for Rojo sync
- Usage:
  ```bash
  rojo serve default.project.json
  ```
  Then connect from Roblox Studio plugin

## ⚙️ Configuration Options

### Room Toggles
- `include_basement`: Add basement level
- `include_attic`: Add attic level
- `include_secret_passage`: Add hidden passage

### Dimensions
- `scale_factor`: Overall size multiplier (0.5 - 2.0)
- `ceiling_height`: Room height in studs (default: 10)
- `corridor_width`: Corridor width in studs (default: 4)

### Aesthetics
- `prop_density`: Furniture/decoration density (0.0 - 1.0)
- `light_count`: Number of lamps
- `dark_mode`: Use darker colors
- `victorian_style`: Victorian aesthetic theme

### Gameplay
- `patrol_point_count`: AI patrol waypoints (6-20)
- `key_spawn_count`: Key spawn locations (3-12)
- `hiding_spot_count`: Player hiding spots (4-16)

### Performance
- `max_parts`: Maximum part count (default: 6000)

## 🏗️ Technical Specifications

### Roblox Compatibility
- ✅ Standard Parts and Models only (no unions)
- ✅ All parts anchored
- ✅ Grid-aligned (2 stud grid)
- ✅ Proper scaling (Roblox studs)
- ✅ Clean topology for performance

### Dimensions
- **Ceiling height**: ≥10 studs
- **Door frames**: 6.5H x 4W studs
- **Corridors**: ≥2 studs wide (default 4)
- **Wall thickness**: 0.5 studs

### Navigation
- **Character size**: 4x2x1 studs (R15 Humanoid)
- **Clear paths**: No dead ends without hiding spots
- **Vertical movement**: Stairs + optional basement/attic access
- **Loop design**: Multiple routes for chase gameplay

### Materials
- Concrete (basement, walls)
- WoodPlanks (floors, doors, furniture)
- Brick (exterior walls)
- Metal (hinges, handles)
- Glass (windows)
- Neon (markers only)

## 📊 Statistics & Validation

The generator provides detailed statistics:
- **Total parts**: Count of all Part objects
- **Room count**: Number of room models
- **Marker count**: Total gameplay markers
- **Patrol points**: AI navigation waypoints
- **Hiding spots**: Player hiding locations
- **Key spawns**: Collectible locations

Validation checks:
- ✅ Part count within limits
- ✅ Required markers present
- ✅ Navigable paths exist
- ✅ Minimum distances maintained

## 🔌 API Endpoints

### Preview Manor
```bash
GET /api/manor/preview
```
Query params: `include_basement`, `include_attic`, `scale_factor`, `prop_density`, etc.

Response:
```json
{
  "valid": true,
  "statistics": {
    "total_parts": 154,
    "room_count": 12,
    "marker_count": 30
  },
  "errors": [],
  "config": {...}
}
```

### Generate Manor
```bash
POST /api/manor/generate
```
Body: Configuration JSON

Response:
```json
{
  "success": true,
  "statistics": {...},
  "download_urls": {
    "rbxmx": "/api/manor/download/rbxmx/{id}",
    "rojo": "/api/manor/download/rojo/{id}"
  }
}
```

### Download RBXMX
```bash
GET /api/manor/download/rbxmx/{manor_id}
```

## 🎨 Customization

### Creating Custom Rooms

Extend the `RoomGenerator` base class:

```python
from manor_generator.rooms.base import RoomGenerator
from manor_generator.models import Model, Vector3

class MyCustomRoom(RoomGenerator):
    def generate(self, position: Vector3) -> Model:
        room = Model(name="MyRoom")
        
        # Add floor, walls, ceiling
        room.add_part(self.create_floor("MyRoom", 10, 10, position))
        # ... add more parts
        
        return room
```

### Custom Export Formats

Implement custom exporters by extending base functionality:

```python
class MyExporter:
    def __init__(self, manor: Manor):
        self.manor = manor
    
    def export(self, filepath: str):
        # Custom export logic
        pass
```

## 🐛 Troubleshooting

### "Part count exceeds maximum"
- Reduce `prop_density`
- Reduce `scale_factor`
- Disable optional rooms (attic, basement, secret passage)

### "Missing required marker"
- Ensure `include_basement` or `include_attic` is enabled (for GrannySpawn)
- Check `patrol_point_count` is ≥6

### RBXMX import fails
- Ensure file is not corrupted
- Check Roblox Studio version compatibility
- Try importing into empty baseplate first

### Rojo sync issues
- Verify `default.project.json` exists
- Check file paths in project file
- Ensure Rojo plugin is installed and updated

## 📝 Example Configurations

### Minimal Performance Mode
```json
{
  "include_basement": false,
  "include_attic": false,
  "include_secret_passage": false,
  "scale_factor": 0.8,
  "prop_density": 0.2,
  "max_parts": 3000
}
```

### Maximum Detail Mode
```json
{
  "include_basement": true,
  "include_attic": true,
  "include_secret_passage": true,
  "scale_factor": 1.5,
  "prop_density": 0.9,
  "light_count": 30,
  "patrol_point_count": 20,
  "hiding_spot_count": 16
}
```

## 🎯 Game Integration

### Using Markers in Scripts

```lua
-- Find all patrol points
local patrolPoints = {}
for _, obj in pairs(workspace.Manor:GetDescendants()) do
    if obj.Name:match("^PatrolPoint_") then
        table.insert(patrolPoints, obj)
    end
end

-- Find player spawn
local playerSpawn = workspace.Manor:FindFirstChild("PlayerSpawn")
if playerSpawn then
    player.Character.HumanoidRootPart.CFrame = playerSpawn.CFrame
end
```

### Door Interactions

Doors include a `Handle` part with attributes:
```lua
local handle = door:FindFirstChild("Handle")
if handle then
    local isLocked = handle:GetAttribute("Locked")
    local keyId = handle:GetAttribute("KeyId")
    -- Implement door opening logic
end
```

## 🤝 Contributing

The manor generator is modular and extensible:
1. Add new room types in `manor_generator/rooms/`
2. Extend marker types in `manor_generator/markers.py`
3. Add export formats in `manor_generator/exporters/`

## 📜 License

This project is part of the Emergent development environment.

## 🙏 Credits

Generated with love for Roblox game developers. Perfect for horror games, escape rooms, and adventure experiences!

---

**Happy Building! 🏰👻**
