"""Marker placement system for gameplay elements"""

from typing import List, Tuple
import random
from .models import Part, Vector3, MaterialType


class MarkerPlacer:
    """Handles placement of gameplay markers"""
    
    @staticmethod
    def create_marker(name: str, position: Vector3, attributes: dict = None) -> Part:
        """Create an invisible marker part"""
        marker = Part(
            name=name,
            size=Vector3(1, 1, 1),
            position=position,
            material=MaterialType.NEON,
            anchored=True,
            can_collide=False,
            transparency=1.0,
            attributes=attributes or {}
        )
        return marker
    
    @staticmethod
    def place_player_spawn(hall_center: Vector3) -> Part:
        """Place player spawn at entry hall"""
        spawn_pos = Vector3(hall_center.x, hall_center.y + 3, hall_center.z)
        return MarkerPlacer.create_marker("PlayerSpawn", spawn_pos)
    
    @staticmethod
    def place_granny_spawn(basement_pos: Vector3) -> Part:
        """Place Granny spawn in basement"""
        spawn_pos = Vector3(basement_pos.x, basement_pos.y + 3, basement_pos.z)
        return MarkerPlacer.create_marker("GrannySpawn", spawn_pos)
    
    @staticmethod
    def place_escape_exit(door_pos: Vector3) -> Part:
        """Place escape exit marker"""
        return MarkerPlacer.create_marker("EscapeExit", door_pos)
    
    @staticmethod
    def place_patrol_points(path_points: List[Vector3], count: int = 12) -> List[Part]:
        """Place patrol points along a path"""
        markers = []
        step = max(1, len(path_points) // count)
        
        for i in range(0, len(path_points), step):
            if i < len(path_points):
                marker = MarkerPlacer.create_marker(
                    f"PatrolPoint_{len(markers) + 1}",
                    path_points[i]
                )
                markers.append(marker)
                
                if len(markers) >= count:
                    break
        
        return markers
    
    @staticmethod
    def place_key_spawns(room_positions: List[Vector3], count: int = 6) -> List[Part]:
        """Place key spawn points randomly in rooms"""
        markers = []
        selected = random.sample(room_positions, min(count, len(room_positions)))
        
        for i, pos in enumerate(selected, 1):
            marker = MarkerPlacer.create_marker(
                f"KeySpawn_{i}",
                Vector3(pos.x, pos.y + 2, pos.z),
                {"KeyId": f"key_{i}"}
            )
            markers.append(marker)
        
        return markers
    
    @staticmethod
    def place_hiding_spots(furniture_positions: List[Tuple[str, Vector3]], count: int = 8) -> List[Part]:
        """Place hiding spot markers near furniture"""
        markers = []
        selected = random.sample(furniture_positions, min(count, len(furniture_positions)))
        
        for i, (furniture_type, pos) in enumerate(selected, 1):
            marker = MarkerPlacer.create_marker(
                f"HidingSpot_{i}",
                Vector3(pos.x, pos.y + 1, pos.z),
                {"FurnitureType": furniture_type}
            )
            markers.append(marker)
        
        return markers
    
    @staticmethod
    def place_noise_zones(room_centers: List[Tuple[str, Vector3]]) -> List[Part]:
        """Place noise zone markers in noisy rooms"""
        markers = []
        noisy_rooms = ["Kitchen", "Corridors", "Stairs"]
        
        for room_name, pos in room_centers:
            if any(noisy in room_name for noisy in noisy_rooms):
                marker = MarkerPlacer.create_marker(
                    f"NoiseZone_{room_name}",
                    pos,
                    {"NoiseRadius": 15}
                )
                markers.append(marker)
        
        return markers
    
    @staticmethod
    def place_fuse_box(basement_wall_pos: Vector3) -> Part:
        """Place fuse box marker"""
        return MarkerPlacer.create_marker("FuseBox", basement_wall_pos)
    
    @staticmethod
    def place_generator(exterior_pos: Vector3) -> Part:
        """Place generator marker"""
        return MarkerPlacer.create_marker("Generator", exterior_pos)
