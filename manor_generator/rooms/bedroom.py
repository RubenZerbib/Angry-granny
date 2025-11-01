"""Bedroom room generator"""

from .base import RoomGenerator
from ..models import Model, Vector3


class BedroomGenerator(RoomGenerator):
    """Generates a bedroom"""
    
    def generate(self, name: str, position: Vector3, width: float = 10.0, length: float = 12.0, height: float = 10.0) -> Model:
        bedroom = Model(name=name)
        
        width *= self.scale_factor
        length *= self.scale_factor
        height *= self.scale_factor
        
        center = position
        
        # Floor
        floor = self.create_floor(name, width, length, center)
        bedroom.add_part(floor)
        
        # Ceiling
        ceiling = self.create_ceiling(name, width, length, Vector3(center.x, center.y + height, center.z))
        bedroom.add_part(ceiling)
        
        # Walls
        north_wall = self.create_wall("North_Wall", width, height, Vector3(center.x, center.y + height/2, center.z - length/2))
        south_wall = self.create_wall("South_Wall", width, height, Vector3(center.x, center.y + height/2, center.z + length/2))
        east_wall = self.create_wall("East_Wall", length, height, Vector3(center.x + width/2, center.y + height/2, center.z), (0, 90, 0))
        west_wall = self.create_wall("West_Wall", length, height, Vector3(center.x - width/2, center.y + height/2, center.z), (0, 90, 0))
        
        bedroom.add_part(north_wall)
        bedroom.add_part(south_wall)
        bedroom.add_part(east_wall)
        bedroom.add_part(west_wall)
        
        # Door
        door = self.create_door_frame(f"{name}_Door", Vector3(center.x - width/2 + 0.5, center.y + 3.25, center.z))
        bedroom.add_child(door)
        
        # Window
        window = self.create_window(f"{name}_Window", Vector3(center.x, center.y + height/2, center.z + length/2 - 0.2))
        bedroom.add_part(window)
        
        # Furniture
        if self.prop_density > 0.3:
            bed = self.create_furniture(f"Bed_{name}", Vector3(center.x + width/4, center.y + 0.5, center.z - length/4))
            bedroom.add_child(bed)
            
        if self.prop_density > 0.5:
            wardrobe = self.create_furniture(f"Wardrobe_{name}", Vector3(center.x - width/4, center.y + 3.5, center.z + length/4))
            bedroom.add_child(wardrobe)
            
        if self.prop_density > 0.4:
            lamp = self.create_lamp(f"Lamp_{name}", Vector3(center.x, center.y + height - 2, center.z))
            bedroom.add_child(lamp)
        
        return bedroom
