"""Basement room generator"""

from .base import RoomGenerator
from ..models import Model, Vector3, MaterialType, Part


class BasementGenerator(RoomGenerator):
    """Generates the basement"""
    
    def generate(self, position: Vector3, width: float = 20.0, length: float = 16.0, height: float = 8.0) -> Model:
        basement = Model(name="Basement")
        
        width *= self.scale_factor
        length *= self.scale_factor
        height *= self.scale_factor
        
        center = position
        
        # Floor (damp concrete)
        floor = Part(
            name="Basement_Floor",
            size=Vector3(width, self.wall_thickness, length),
            position=center,
            material=MaterialType.CONCRETE,
            color=(80, 80, 80)  # Dark gray
        )
        basement.add_part(floor)
        
        # Ceiling
        ceiling = self.create_ceiling("Basement", width, length, Vector3(center.x, center.y + height, center.z))
        basement.add_part(ceiling)
        
        # Walls (concrete)
        north_wall = Part(
            name="North_Wall",
            size=Vector3(width, height, self.wall_thickness),
            position=Vector3(center.x, center.y + height/2, center.z - length/2),
            material=MaterialType.CONCRETE,
            color=(70, 70, 70)
        )
        south_wall = Part(
            name="South_Wall",
            size=Vector3(width, height, self.wall_thickness),
            position=Vector3(center.x, center.y + height/2, center.z + length/2),
            material=MaterialType.CONCRETE,
            color=(70, 70, 70)
        )
        east_wall = Part(
            name="East_Wall",
            size=Vector3(length, height, self.wall_thickness),
            position=Vector3(center.x + width/2, center.y + height/2, center.z),
            rotation=(0, 90, 0),
            material=MaterialType.CONCRETE,
            color=(70, 70, 70)
        )
        west_wall = Part(
            name="West_Wall",
            size=Vector3(length, height, self.wall_thickness),
            position=Vector3(center.x - width/2, center.y + height/2, center.z),
            rotation=(0, 90, 0),
            material=MaterialType.CONCRETE,
            color=(70, 70, 70)
        )
        
        basement.add_part(north_wall)
        basement.add_part(south_wall)
        basement.add_part(east_wall)
        basement.add_part(west_wall)
        
        # Add minimal lighting (dim)
        if self.prop_density > 0.3:
            lamp = self.create_lamp("Lamp_Basement", Vector3(center.x, center.y + height - 1.5, center.z))
            basement.add_child(lamp)
        
        return basement
