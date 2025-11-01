"""Base room generator class"""

from typing import List, Tuple
from ..models import Model, Part, Vector3, MaterialType, PointLight, InteractType
import random


class RoomGenerator:
    """Base class for room generation"""
    
    def __init__(self, scale_factor: float = 1.0, prop_density: float = 0.5):
        self.scale_factor = scale_factor
        self.prop_density = prop_density
        self.wall_thickness = 0.5
        
    def create_floor(self, name: str, width: float, length: float, position: Vector3) -> Part:
        """Create a floor part"""
        return Part(
            name=f"{name}_Floor",
            size=Vector3(width, self.wall_thickness, length),
            position=position,
            material=MaterialType.WOOD_PLANKS,
            color=(101, 67, 33)  # Dark wood
        )
    
    def create_wall(self, name: str, width: float, height: float, position: Vector3, rotation: Tuple[float, float, float] = (0, 0, 0)) -> Part:
        """Create a wall part"""
        return Part(
            name=name,
            size=Vector3(width, height, self.wall_thickness),
            position=position,
            rotation=rotation,
            material=MaterialType.BRICK,
            color=(138, 138, 138)  # Gray
        )
    
    def create_ceiling(self, name: str, width: float, length: float, position: Vector3) -> Part:
        """Create a ceiling part"""
        return Part(
            name=f"{name}_Ceiling",
            size=Vector3(width, self.wall_thickness, length),
            position=position,
            material=MaterialType.WOOD_PLANKS,
            color=(89, 56, 25)  # Darker wood
        )
    
    def create_door_frame(self, name: str, position: Vector3, rotation: Tuple[float, float, float] = (0, 0, 0)) -> Model:
        """Create a door with frame"""
        door_model = Model(name=name)
        
        # Door frame dimensions
        frame_width = 4.0
        frame_height = 6.5
        door_thickness = 0.3
        
        # Door part
        door = Part(
            name="Door",
            size=Vector3(frame_width - 0.5, frame_height - 0.5, door_thickness),
            position=position,
            rotation=rotation,
            material=MaterialType.WOOD_PLANKS,
            color=(70, 45, 20)
        )
        door_model.add_part(door)
        
        # Hinge marker (for scripting)
        hinge = Part(
            name="Hinge",
            size=Vector3(0.2, frame_height - 0.5, 0.2),
            position=Vector3(position.x - frame_width/2, position.y, position.z),
            rotation=rotation,
            material=MaterialType.METAL,
            color=(52, 52, 52)
        )
        door_model.add_part(hinge)
        
        # Handle
        handle = Part(
            name="Handle",
            size=Vector3(0.8, 0.3, 0.2),
            position=Vector3(position.x + frame_width/4, position.y, position.z),
            rotation=rotation,
            material=MaterialType.METAL,
            color=(212, 175, 55),  # Gold
            attributes={
                "InteractType": InteractType.DOOR.value,
                "Locked": False,
                "KeyId": ""
            }
        )
        door_model.add_part(handle)
        
        return door_model
    
    def create_window(self, name: str, position: Vector3, rotation: Tuple[float, float, float] = (0, 0, 0)) -> Part:
        """Create a window"""
        return Part(
            name=name,
            size=Vector3(3.0, 4.0, 0.2),
            position=position,
            rotation=rotation,
            material=MaterialType.GLASS,
            transparency=0.5,
            color=(200, 220, 255)
        )
    
    def create_lamp(self, name: str, position: Vector3) -> Model:
        """Create a lamp with light"""
        lamp_model = Model(name=name)
        
        # Lamp base
        base = Part(
            name="Base",
            size=Vector3(1.0, 0.5, 1.0),
            position=position,
            material=MaterialType.METAL,
            color=(30, 30, 30)
        )
        lamp_model.add_part(base)
        
        # Light bulb (visual)
        bulb = Part(
            name="Bulb",
            size=Vector3(0.5, 0.8, 0.5),
            position=Vector3(position.x, position.y + 0.7, position.z),
            material=MaterialType.NEON,
            color=(255, 240, 200),
            transparency=0.3
        )
        lamp_model.add_part(bulb)
        
        return lamp_model
    
    def create_furniture(self, furniture_type: str, position: Vector3) -> Model:
        """Create furniture pieces"""
        furniture = Model(name=furniture_type)
        
        if furniture_type.startswith("Wardrobe"):
            # Wardrobe
            body = Part(
                name="Body",
                size=Vector3(4.0, 7.0, 2.0),
                position=position,
                material=MaterialType.WOOD_PLANKS,
                color=(60, 40, 20)
            )
            furniture.add_part(body)
            
            handle = Part(
                name="Handle",
                size=Vector3(0.5, 0.5, 0.3),
                position=Vector3(position.x, position.y, position.z + 1.2),
                material=MaterialType.METAL,
                color=(180, 180, 180),
                attributes={
                    "InteractType": InteractType.WARDROBE.value,
                    "Locked": False
                }
            )
            furniture.add_part(handle)
            
        elif furniture_type.startswith("Bed"):
            # Bed frame
            frame = Part(
                name="Frame",
                size=Vector3(4.0, 1.0, 6.0),
                position=position,
                material=MaterialType.WOOD_PLANKS,
                color=(70, 45, 20)
            )
            furniture.add_part(frame)
            
            # Mattress
            mattress = Part(
                name="Mattress",
                size=Vector3(3.8, 0.8, 5.8),
                position=Vector3(position.x, position.y + 0.9, position.z),
                material=MaterialType.CONCRETE,
                color=(200, 200, 200)
            )
            furniture.add_part(mattress)
            
        elif furniture_type.startswith("Table"):
            # Table top
            top = Part(
                name="Top",
                size=Vector3(6.0, 0.3, 3.0),
                position=Vector3(position.x, position.y + 2.5, position.z),
                material=MaterialType.WOOD_PLANKS,
                color=(80, 50, 25)
            )
            furniture.add_part(top)
            
            # Table legs
            for i, offset in enumerate([(-2.5, -1.2), (2.5, -1.2), (-2.5, 1.2), (2.5, 1.2)]):
                leg = Part(
                    name=f"Leg_{i+1}",
                    size=Vector3(0.4, 2.5, 0.4),
                    position=Vector3(position.x + offset[0], position.y, position.z + offset[1]),
                    material=MaterialType.WOOD_PLANKS,
                    color=(80, 50, 25)
                )
                furniture.add_part(leg)
                
        elif furniture_type.startswith("Chair"):
            # Seat
            seat = Part(
                name="Seat",
                size=Vector3(1.5, 0.3, 1.5),
                position=Vector3(position.x, position.y + 1.5, position.z),
                material=MaterialType.WOOD_PLANKS,
                color=(75, 47, 23)
            )
            furniture.add_part(seat)
            
            # Back
            back = Part(
                name="Back",
                size=Vector3(1.5, 2.0, 0.3),
                position=Vector3(position.x, position.y + 2.5, position.z - 0.6),
                material=MaterialType.WOOD_PLANKS,
                color=(75, 47, 23)
            )
            furniture.add_part(back)
            
        return furniture
