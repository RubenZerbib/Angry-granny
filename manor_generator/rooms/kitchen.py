"""Kitchen room generator"""

from .base import RoomGenerator
from ..models import Model, Vector3


class KitchenGenerator(RoomGenerator):
    """Generates the kitchen"""
    
    def generate(self, position: Vector3, width: float = 12.0, length: float = 10.0, height: float = 10.0) -> Model:
        kitchen = Model(name="Kitchen")
        
        width *= self.scale_factor
        length *= self.scale_factor
        height *= self.scale_factor
        
        center = position
        
        # Floor
        floor = self.create_floor("Kitchen", width, length, center)
        kitchen.add_part(floor)
        
        # Ceiling
        ceiling = self.create_ceiling("Kitchen", width, length, Vector3(center.x, center.y + height, center.z))
        kitchen.add_part(ceiling)
        
        # Walls
        north_wall = self.create_wall("North_Wall", width, height, Vector3(center.x, center.y + height/2, center.z - length/2))
        south_wall = self.create_wall("South_Wall", width, height, Vector3(center.x, center.y + height/2, center.z + length/2))
        east_wall = self.create_wall("East_Wall", length, height, Vector3(center.x + width/2, center.y + height/2, center.z), (0, 90, 0))
        west_wall = self.create_wall("West_Wall", length, height, Vector3(center.x - width/2, center.y + height/2, center.z), (0, 90, 0))
        
        kitchen.add_part(north_wall)
        kitchen.add_part(south_wall)
        kitchen.add_part(east_wall)
        kitchen.add_part(west_wall)
        
        # Door
        door = self.create_door_frame("Kitchen_Door", Vector3(center.x - width/2 + 0.5, center.y + 3.25, center.z))
        kitchen.add_child(door)
        
        # Furniture
        if self.prop_density > 0.2:
            table = self.create_furniture("Table_Kitchen", Vector3(center.x, center.y, center.z))
            kitchen.add_child(table)
            
        if self.prop_density > 0.4:
            lamp = self.create_lamp("Lamp_Kitchen", Vector3(center.x, center.y + height - 2, center.z))
            kitchen.add_child(lamp)
        
        return kitchen
