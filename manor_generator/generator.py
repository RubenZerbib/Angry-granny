"""Main manor generator"""

from typing import Dict, List, Tuple
import random
from .models import Manor, ManorConfig, Model, Vector3, Part
from .markers import MarkerPlacer
from .rooms.hall import HallGenerator
from .rooms.kitchen import KitchenGenerator
from .rooms.bedroom import BedroomGenerator
from .rooms.basement import BasementGenerator
from .rooms.base import RoomGenerator


class ManorGenerator:
    """Generates complete haunted manor structures"""
    
    def __init__(self, config: ManorConfig = None):
        self.config = config or ManorConfig()
        self.root_model = Model(name="Manor")
        self.markers = {}
        self.room_centers = []
        self.furniture_positions = []
        
    def generate(self) -> Manor:
        """Generate the complete manor"""
        print("🏰 Generating Angry Granny Manor...")
        
        # Create root model
        self.root_model = Model(name="Manor")
        
        # Generate all rooms
        self._generate_rooms()
        
        # Place gameplay markers
        self._place_markers()
        
        # Create manor object
        manor = Manor(
            config=self.config,
            root_model=self.root_model,
            markers=self.markers,
            statistics=self._calculate_statistics()
        )
        
        # Validate
        is_valid, errors = manor.validate()
        if not is_valid:
            print("⚠️ Validation warnings:")
            for error in errors:
                print(f"  - {error}")
        
        print(f"✅ Manor generated! Total parts: {manor.get_total_parts()}")
        return manor
    
    def _generate_rooms(self):
        """Generate all room structures"""
        base_y = 0
        
        # Hall (entry, center of manor)
        hall_gen = HallGenerator(self.config.scale_factor, self.config.prop_density)
        hall = hall_gen.generate(Vector3(0, base_y, 0), 16, 16, self.config.ceiling_height)
        self.root_model.add_child(hall)
        self.room_centers.append(("Hall", Vector3(0, base_y + 3, 0)))
        
        # Kitchen (west of hall)
        kitchen_gen = KitchenGenerator(self.config.scale_factor, self.config.prop_density)
        kitchen = kitchen_gen.generate(Vector3(-20, base_y, 0), 12, 10, self.config.ceiling_height)
        self.root_model.add_child(kitchen)
        self.room_centers.append(("Kitchen", Vector3(-20, base_y + 3, 0)))
        
        # Dining Room (east of hall)
        dining_gen = RoomGenerator(self.config.scale_factor, self.config.prop_density)
        dining = self._generate_dining_room(Vector3(20, base_y, 0))
        self.root_model.add_child(dining)
        self.room_centers.append(("DiningRoom", Vector3(20, base_y + 3, 0)))
        
        # Corridors (north of hall)
        corridors = self._generate_corridors(Vector3(0, base_y, -20))
        self.root_model.add_child(corridors)
        self.room_centers.append(("Corridors", Vector3(0, base_y + 3, -20)))
        
        # Stairs (connecting floors)
        stairs = self._generate_stairs(Vector3(10, base_y, -20))
        self.root_model.add_child(stairs)
        self.room_centers.append(("Stairs", Vector3(10, base_y + 5, -20)))
        
        # Bedrooms (upper floor)
        bedroom_gen = BedroomGenerator(self.config.scale_factor, self.config.prop_density)
        bedroom_a = bedroom_gen.generate("Bedroom_A", Vector3(-15, base_y + 12, -30), 10, 12, self.config.ceiling_height)
        bedroom_b = bedroom_gen.generate("Bedroom_B", Vector3(15, base_y + 12, -30), 10, 12, self.config.ceiling_height)
        self.root_model.add_child(bedroom_a)
        self.root_model.add_child(bedroom_b)
        self.room_centers.append(("Bedroom_A", Vector3(-15, base_y + 15, -30)))
        self.room_centers.append(("Bedroom_B", Vector3(15, base_y + 15, -30)))
        
        # Store furniture positions for hiding spots
        self.furniture_positions.extend([
            ("Bed", Vector3(-12.5, base_y + 12, -32.5)),
            ("Wardrobe", Vector3(-17.5, base_y + 12, -27.5)),
            ("Bed", Vector3(17.5, base_y + 12, -32.5)),
            ("Wardrobe", Vector3(12.5, base_y + 12, -27.5)),
        ])
        
        # Bathroom
        bathroom = self._generate_bathroom(Vector3(0, base_y + 12, -40))
        self.root_model.add_child(bathroom)
        self.room_centers.append(("Bathroom", Vector3(0, base_y + 15, -40)))
        
        # Basement (if enabled)
        if self.config.include_basement:
            basement_gen = BasementGenerator(self.config.scale_factor, self.config.prop_density)
            basement = basement_gen.generate(Vector3(0, base_y - 10, 0), 20, 16, 8)
            self.root_model.add_child(basement)
            self.room_centers.append(("Basement", Vector3(0, base_y - 7, 0)))
        
        # Attic (if enabled)
        if self.config.include_attic:
            attic = self._generate_attic(Vector3(0, base_y + 24, -20))
            self.root_model.add_child(attic)
            self.room_centers.append(("Attic", Vector3(0, base_y + 27, -20)))
        
        # Secret Passage (if enabled)
        if self.config.include_secret_passage:
            secret = self._generate_secret_passage(Vector3(-25, base_y, -10))
            self.root_model.add_child(secret)
            self.room_centers.append(("SecretPassage", Vector3(-25, base_y + 3, -10)))
        
        # Exterior Porch
        porch = self._generate_porch(Vector3(0, base_y, 15))
        self.root_model.add_child(porch)
        self.room_centers.append(("ExteriorPorch", Vector3(0, base_y + 1, 15)))
    
    def _generate_dining_room(self, position: Vector3) -> Model:
        """Generate dining room"""
        room_gen = RoomGenerator(self.config.scale_factor, self.config.prop_density)
        dining = Model(name="DiningRoom")
        
        width, length, height = 14, 12, self.config.ceiling_height
        center = position
        
        # Basic structure
        dining.add_part(room_gen.create_floor("DiningRoom", width, length, center))
        dining.add_part(room_gen.create_ceiling("DiningRoom", width, length, Vector3(center.x, center.y + height, center.z)))
        
        # Walls
        dining.add_part(room_gen.create_wall("North_Wall", width, height, Vector3(center.x, center.y + height/2, center.z - length/2)))
        dining.add_part(room_gen.create_wall("South_Wall", width, height, Vector3(center.x, center.y + height/2, center.z + length/2)))
        dining.add_part(room_gen.create_wall("East_Wall", length, height, Vector3(center.x + width/2, center.y + height/2, center.z), (0, 90, 0)))
        dining.add_part(room_gen.create_wall("West_Wall", length, height, Vector3(center.x - width/2, center.y + height/2, center.z), (0, 90, 0)))
        
        # Door
        door = room_gen.create_door_frame("DiningRoom_Door", Vector3(center.x - width/2 + 0.5, center.y + 3.25, center.z))
        dining.add_child(door)
        
        # Furniture
        if self.config.prop_density > 0.3:
            table = room_gen.create_furniture("Table_Dining", Vector3(center.x, center.y, center.z))
            dining.add_child(table)
            
            # Chairs
            for i, pos in enumerate([(center.x - 3, center.z), (center.x + 3, center.z), (center.x, center.z - 2), (center.x, center.z + 2)]):
                chair = room_gen.create_furniture(f"Chair_{i+1}", Vector3(pos[0], center.y, pos[1]))
                dining.add_child(chair)
        
        return dining
    
    def _generate_corridors(self, position: Vector3) -> Model:
        """Generate corridor network"""
        room_gen = RoomGenerator(self.config.scale_factor, self.config.prop_density)
        corridors = Model(name="Corridors")
        
        # Main corridor (east-west)
        width, length, height = self.config.corridor_width, 30, self.config.ceiling_height
        center = position
        
        corridors.add_part(room_gen.create_floor("Main_Corridor", width, length, center))
        corridors.add_part(room_gen.create_ceiling("Main_Corridor", width, length, Vector3(center.x, center.y + height, center.z)))
        
        # Walls
        corridors.add_part(room_gen.create_wall("East_Wall", length, height, Vector3(center.x + width/2, center.y + height/2, center.z), (0, 90, 0)))
        corridors.add_part(room_gen.create_wall("West_Wall", length, height, Vector3(center.x - width/2, center.y + height/2, center.z), (0, 90, 0)))
        
        return corridors
    
    def _generate_stairs(self, position: Vector3) -> Model:
        """Generate staircase"""
        room_gen = RoomGenerator(self.config.scale_factor, self.config.prop_density)
        stairs = Model(name="Stairs")
        
        # Stair steps (simplified as parts)
        step_count = 12
        step_width = 4.0
        step_depth = 1.0
        step_height = 1.0
        
        for i in range(step_count):
            step = Part(
                name=f"Step_{i+1}",
                size=Vector3(step_width, step_height, step_depth),
                position=Vector3(position.x, position.y + i * step_height, position.z + i * step_depth),
                material=room_gen.create_floor("temp", 1, 1, Vector3(0, 0, 0)).material,
                color=(90, 60, 30)
            )
            stairs.add_part(step)
        
        return stairs
    
    def _generate_bathroom(self, position: Vector3) -> Model:
        """Generate bathroom"""
        room_gen = RoomGenerator(self.config.scale_factor, self.config.prop_density)
        bathroom = Model(name="Bathroom")
        
        width, length, height = 8, 8, self.config.ceiling_height
        center = position
        
        bathroom.add_part(room_gen.create_floor("Bathroom", width, length, center))
        bathroom.add_part(room_gen.create_ceiling("Bathroom", width, length, Vector3(center.x, center.y + height, center.z)))
        
        # Walls
        bathroom.add_part(room_gen.create_wall("North_Wall", width, height, Vector3(center.x, center.y + height/2, center.z - length/2)))
        bathroom.add_part(room_gen.create_wall("South_Wall", width, height, Vector3(center.x, center.y + height/2, center.z + length/2)))
        bathroom.add_part(room_gen.create_wall("East_Wall", length, height, Vector3(center.x + width/2, center.y + height/2, center.z), (0, 90, 0)))
        bathroom.add_part(room_gen.create_wall("West_Wall", length, height, Vector3(center.x - width/2, center.y + height/2, center.z), (0, 90, 0)))
        
        # Door
        door = room_gen.create_door_frame("Bathroom_Door", Vector3(center.x, center.y + 3.25, center.z + length/2 - 0.5))
        bathroom.add_child(door)
        
        return bathroom
    
    def _generate_attic(self, position: Vector3) -> Model:
        """Generate attic"""
        room_gen = RoomGenerator(self.config.scale_factor, self.config.prop_density)
        attic = Model(name="Attic")
        
        width, length, height = 16, 12, 8
        center = position
        
        attic.add_part(room_gen.create_floor("Attic", width, length, center))
        attic.add_part(room_gen.create_ceiling("Attic", width, length, Vector3(center.x, center.y + height, center.z)))
        
        # Walls
        attic.add_part(room_gen.create_wall("North_Wall", width, height, Vector3(center.x, center.y + height/2, center.z - length/2)))
        attic.add_part(room_gen.create_wall("South_Wall", width, height, Vector3(center.x, center.y + height/2, center.z + length/2)))
        attic.add_part(room_gen.create_wall("East_Wall", length, height, Vector3(center.x + width/2, center.y + height/2, center.z), (0, 90, 0)))
        attic.add_part(room_gen.create_wall("West_Wall", length, height, Vector3(center.x - width/2, center.y + height/2, center.z), (0, 90, 0)))
        
        return attic
    
    def _generate_secret_passage(self, position: Vector3) -> Model:
        """Generate secret passage"""
        room_gen = RoomGenerator(self.config.scale_factor, self.config.prop_density)
        secret = Model(name="SecretPassage")
        
        width, length, height = 3, 15, 8
        center = position
        
        secret.add_part(room_gen.create_floor("SecretPassage", width, length, center))
        secret.add_part(room_gen.create_ceiling("SecretPassage", width, length, Vector3(center.x, center.y + height, center.z)))
        
        # Walls (darker, narrower)
        secret.add_part(room_gen.create_wall("East_Wall", length, height, Vector3(center.x + width/2, center.y + height/2, center.z), (0, 90, 0)))
        secret.add_part(room_gen.create_wall("West_Wall", length, height, Vector3(center.x - width/2, center.y + height/2, center.z), (0, 90, 0)))
        
        return secret
    
    def _generate_porch(self, position: Vector3) -> Model:
        """Generate exterior porch"""
        room_gen = RoomGenerator(self.config.scale_factor, self.config.prop_density)
        porch = Model(name="ExteriorPorch")
        
        width, length = 16, 4
        center = position
        
        # Porch floor
        floor = room_gen.create_floor("Porch", width, length, center)
        porch.add_part(floor)
        
        return porch
    
    def _place_markers(self):
        """Place all gameplay markers"""
        marker_placer = MarkerPlacer()
        
        # Required markers
        hall_center = Vector3(0, 3, 0)
        self.markers["PlayerSpawn"] = [marker_placer.place_player_spawn(hall_center)]
        
        if self.config.include_basement:
            basement_center = Vector3(0, -7, 0)
            self.markers["GrannySpawn"] = [marker_placer.place_granny_spawn(basement_center)]
        else:
            attic_center = Vector3(0, 27, -20)
            self.markers["GrannySpawn"] = [marker_placer.place_granny_spawn(attic_center)]
        
        porch_exit = Vector3(0, 1, 17)
        self.markers["EscapeExit"] = [marker_placer.place_escape_exit(porch_exit)]
        
        # Utility markers
        if self.config.include_basement:
            fuse_pos = Vector3(-9, -7, -7)
            self.markers["FuseBox"] = [marker_placer.place_fuse_box(fuse_pos)]
            
            generator_pos = Vector3(15, 0, 20)
            self.markers["Generator"] = [marker_placer.place_generator(generator_pos)]
        
        # Patrol points (create a loop through rooms)
        patrol_path = [
            Vector3(0, 3, 0),      # Hall
            Vector3(-15, 3, 0),    # Toward Kitchen
            Vector3(-20, 3, 0),    # Kitchen
            Vector3(-20, 3, -10),  # Kitchen to Corridor
            Vector3(0, 3, -20),    # Corridor
            Vector3(10, 5, -20),   # Stairs
            Vector3(10, 15, -25),  # Upper floor
            Vector3(-15, 15, -30), # Bedroom A
            Vector3(15, 15, -30),  # Bedroom B
            Vector3(0, 15, -40),   # Bathroom
            Vector3(10, 5, -20),   # Back to stairs
            Vector3(0, 3, -10),    # Back to hall
        ]
        self.markers["PatrolPoints"] = marker_placer.place_patrol_points(patrol_path, self.config.patrol_point_count)
        
        # Key spawns
        key_positions = [pos for _, pos in self.room_centers if _ not in ["Corridors", "Stairs"]]
        self.markers["KeySpawns"] = marker_placer.place_key_spawns(key_positions, self.config.key_spawn_count)
        
        # Hiding spots
        self.markers["HidingSpots"] = marker_placer.place_hiding_spots(self.furniture_positions, self.config.hiding_spot_count)
        
        # Noise zones
        self.markers["NoiseZones"] = marker_placer.place_noise_zones(self.room_centers)
        
        # Add all markers to root model
        for marker_type, markers in self.markers.items():
            for marker in markers:
                self.root_model.add_part(marker)
    
    def _calculate_statistics(self) -> Dict:
        """Calculate manor statistics"""
        return {
            "total_parts": self.root_model.count_parts(),
            "room_count": len(self.root_model.children),
            "marker_count": sum(len(markers) for markers in self.markers.values()),
            "patrol_points": len(self.markers.get("PatrolPoints", [])),
            "hiding_spots": len(self.markers.get("HidingSpots", [])),
            "key_spawns": len(self.markers.get("KeySpawns", [])),
        }
