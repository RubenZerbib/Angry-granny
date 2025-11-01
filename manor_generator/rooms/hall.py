"""Hall room generator"""

from .base import RoomGenerator
from ..models import Model, Part, Vector3, MaterialType
import random


class HallGenerator(RoomGenerator):
    """Generates the entry hall"""
    
    def generate(self, position: Vector3, width: float = 16.0, length: float = 16.0, height: float = 12.0) -> Model:
        hall = Model(name="Hall")
        
        width *= self.scale_factor
        length *= self.scale_factor
        height *= self.scale_factor
        
        center = position
        
        # Floor
        floor = self.create_floor("Hall", width, length, center)
        hall.add_part(floor)
        
        # Ceiling
        ceiling = self.create_ceiling("Hall", width, length, Vector3(center.x, center.y + height, center.z))
        hall.add_part(ceiling)
        
        # Walls
        # North wall
        north_wall = self.create_wall(
            "North_Wall",
            width,
            height,
            Vector3(center.x, center.y + height/2, center.z - length/2)
        )
        hall.add_part(north_wall)
        
        # South wall (with main door)
        south_wall = self.create_wall(
            "South_Wall",
            width,
            height,
            Vector3(center.x, center.y + height/2, center.z + length/2)
        )
        hall.add_part(south_wall)
        
        # East wall
        east_wall = self.create_wall(
            "East_Wall",
            length,
            height,
            Vector3(center.x + width/2, center.y + height/2, center.z),
            (0, 90, 0)
        )
        hall.add_part(east_wall)
        
        # West wall
        west_wall = self.create_wall(
            "West_Wall",
            length,
            height,
            Vector3(center.x - width/2, center.y + height/2, center.z),
            (0, 90, 0)
        )
        hall.add_part(west_wall)
        
        # Add main entrance door
        main_door = self.create_door_frame(
            "Main_Entrance",
            Vector3(center.x, center.y + 3.25, center.z + length/2 - 0.5)
        )
        hall.add_child(main_door)
        
        # Add some furniture if prop density allows
        if self.prop_density > 0.3:
            # Center table
            table = self.create_furniture("Table_Center", Vector3(center.x, center.y, center.z))
            hall.add_child(table)
            
        if self.prop_density > 0.5:
            # Lamps
            lamp1 = self.create_lamp("Lamp_1", Vector3(center.x - 5, center.y + height - 2, center.z - 5))
            lamp2 = self.create_lamp("Lamp_2", Vector3(center.x + 5, center.y + height - 2, center.z + 5))
            hall.add_child(lamp1)
            hall.add_child(lamp2)
        
        return hall
