"""Data models for Roblox manor generation"""

from dataclasses import dataclass, field
from typing import List, Dict, Tuple, Optional, Literal
from enum import Enum


class MaterialType(str, Enum):
    """Roblox materials"""
    CONCRETE = "Concrete"
    WOOD_PLANKS = "WoodPlanks"
    COBBLESTONE = "Cobblestone"
    MARBLE = "Marble"
    METAL = "Metal"
    NEON = "Neon"
    GLASS = "Glass"
    BRICK = "Brick"


class InteractType(str, Enum):
    """Types of interactable objects"""
    DOOR = "Door"
    WARDROBE = "Wardrobe"
    DRAWER = "Drawer"


@dataclass
class Vector3:
    """3D position/size vector in studs"""
    x: float
    y: float
    z: float
    
    def to_list(self) -> List[float]:
        return [self.x, self.y, self.z]
    
    def to_dict(self) -> Dict[str, float]:
        return {"X": self.x, "Y": self.y, "Z": self.z}


@dataclass
class CFrame:
    """Coordinate frame (position + rotation)"""
    position: Vector3
    rotation: Tuple[float, float, float] = (0, 0, 0)  # Euler angles
    
    def to_dict(self) -> Dict:
        return {
            "position": self.position.to_dict(),
            "rotation": self.rotation
        }


@dataclass
class Part:
    """Roblox Part representation"""
    name: str
    size: Vector3
    position: Vector3
    rotation: Tuple[float, float, float] = (0, 0, 0)
    material: MaterialType = MaterialType.CONCRETE
    color: Tuple[int, int, int] = (163, 162, 165)  # RGB
    anchored: bool = True
    can_collide: bool = True
    transparency: float = 0.0
    attributes: Dict[str, any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict:
        return {
            "ClassName": "Part",
            "Name": self.name,
            "Size": self.size.to_dict(),
            "CFrame": CFrame(self.position, self.rotation).to_dict(),
            "Material": self.material.value,
            "BrickColor": self.color,
            "Anchored": self.anchored,
            "CanCollide": self.can_collide,
            "Transparency": self.transparency,
            "Attributes": self.attributes
        }


@dataclass
class PointLight:
    """Roblox PointLight"""
    enabled: bool = True
    brightness: float = 2.5
    color: Tuple[float, float, float] = (1.0, 0.9, 0.7)  # Warm light
    range: float = 25
    shadows: bool = True
    
    def to_dict(self) -> Dict:
        return {
            "ClassName": "PointLight",
            "Name": "Light",
            "Enabled": self.enabled,
            "Brightness": self.brightness,
            "Color": {"R": self.color[0], "G": self.color[1], "B": self.color[2]},
            "Range": self.range,
            "Shadows": self.shadows
        }


@dataclass
class Model:
    """Roblox Model container"""
    name: str
    parts: List[Part] = field(default_factory=list)
    children: List['Model'] = field(default_factory=list)
    primary_part: Optional[str] = None
    
    def add_part(self, part: Part):
        self.parts.append(part)
    
    def add_child(self, child: 'Model'):
        self.children.append(child)
    
    def count_parts(self) -> int:
        """Count total parts including children"""
        count = len(self.parts)
        for child in self.children:
            count += child.count_parts()
        return count
    
    def to_dict(self) -> Dict:
        result = {
            "ClassName": "Model",
            "Name": self.name,
            "Children": []
        }
        
        if self.primary_part:
            result["PrimaryPart"] = self.primary_part
        
        # Add parts
        for part in self.parts:
            result["Children"].append(part.to_dict())
        
        # Add child models
        for child in self.children:
            result["Children"].append(child.to_dict())
        
        return result


@dataclass
class ManorConfig:
    """Configuration for manor generation"""
    # Room toggles
    include_basement: bool = True
    include_attic: bool = True
    include_secret_passage: bool = True
    
    # Size multipliers
    scale_factor: float = 1.0
    ceiling_height: float = 10.0
    corridor_width: float = 4.0
    
    # Props and details
    prop_density: float = 0.5  # 0.0 to 1.0
    light_count: int = 20
    
    # Gameplay markers
    patrol_point_count: int = 12
    key_spawn_count: int = 6
    hiding_spot_count: int = 8
    
    # Performance
    max_parts: int = 6000
    
    # Style
    dark_mode: bool = True
    victorian_style: bool = True


@dataclass
class Manor:
    """Complete manor structure"""
    config: ManorConfig
    root_model: Model
    markers: Dict[str, List[Part]] = field(default_factory=dict)
    statistics: Dict[str, any] = field(default_factory=dict)
    
    def get_total_parts(self) -> int:
        return self.root_model.count_parts()
    
    def validate(self) -> Tuple[bool, List[str]]:
        """Validate manor meets requirements"""
        errors = []
        
        # Check part count
        total_parts = self.get_total_parts()
        if total_parts > self.config.max_parts:
            errors.append(f"Part count ({total_parts}) exceeds maximum ({self.config.max_parts})")
        
        # Check required markers
        required_markers = ["PlayerSpawn", "GrannySpawn", "EscapeExit"]
        for marker in required_markers:
            if marker not in self.markers or not self.markers[marker]:
                errors.append(f"Missing required marker: {marker}")
        
        return len(errors) == 0, errors
