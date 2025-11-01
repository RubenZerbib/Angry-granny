"""Roblox XML (.rbxmx) format exporter"""

import xml.etree.ElementTree as ET
from xml.dom import minidom
from typing import Dict, List
from ..models import Manor, Model, Part, Vector3
import math


class RBXMXExporter:
    """Exports manor to Roblox XML format (.rbxmx)"""
    
    def __init__(self, manor: Manor):
        self.manor = manor
        
    def export(self, filepath: str):
        """Export manor to .rbxmx file"""
        print(f"📤 Exporting to {filepath}...")
        
        # Create root roblox element
        root = ET.Element("roblox", version="4")
        
        # Add meta info
        meta = ET.SubElement(root, "Meta", name="ExplicitAutoJoints")
        meta.text = "true"
        
        # Add the manor model
        self._add_model(root, self.manor.root_model)
        
        # Pretty print and save
        xml_str = ET.tostring(root, encoding="utf-8")
        pretty_xml = minidom.parseString(xml_str).toprettyxml(indent="  ")
        
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(pretty_xml)
        
        print(f"✅ Exported successfully! Size: {len(pretty_xml)} bytes")
        return filepath
    
    def _add_model(self, parent: ET.Element, model: Model, referent: str = None):
        """Add a Model to XML"""
        if referent is None:
            referent = self._generate_referent()
        
        item = ET.SubElement(parent, "Item", {
            "class": "Model",
            "referent": referent
        })
        
        # Properties
        self._add_property(item, "Name", "string", model.name)
        
        if model.primary_part:
            self._add_property(item, "PrimaryPart", "Ref", model.primary_part)
        
        # Add parts
        for part in model.parts:
            self._add_part(item, part)
        
        # Add child models
        for child in model.children:
            self._add_model(item, child)
    
    def _add_part(self, parent: ET.Element, part: Part):
        """Add a Part to XML"""
        referent = self._generate_referent()
        
        item = ET.SubElement(parent, "Item", {
            "class": "Part",
            "referent": referent
        })
        
        # Properties
        self._add_property(item, "Name", "string", part.name)
        self._add_property(item, "Anchored", "bool", str(part.anchored).lower())
        self._add_property(item, "CanCollide", "bool", str(part.can_collide).lower())
        self._add_property(item, "Transparency", "float", str(part.transparency))
        self._add_property(item, "Material", "token", str(part.material.value))
        
        # Size
        size_elem = ET.SubElement(item, "Properties")
        self._add_vector3(size_elem, "Size", part.size)
        
        # CFrame (position + rotation)
        cframe_str = self._vector3_to_cframe(part.position, part.rotation)
        self._add_property(item, "CFrame", "CoordinateFrame", cframe_str)
        
        # Color
        color_val = f"{part.color[0]}, {part.color[1]}, {part.color[2]}"
        self._add_property(item, "Color3uint8", "Color3uint8", color_val)
        
        # Attributes
        if part.attributes:
            attr_elem = ET.SubElement(item, "Properties")
            for key, value in part.attributes.items():
                self._add_attribute(attr_elem, key, value)
    
    def _add_property(self, parent: ET.Element, name: str, prop_type: str, value: str):
        """Add a property element"""
        props = parent.find("Properties")
        if props is None:
            props = ET.SubElement(parent, "Properties")
        
        prop = ET.SubElement(props, prop_type, {"name": name})
        prop.text = value
    
    def _add_vector3(self, parent: ET.Element, name: str, vec: Vector3):
        """Add a Vector3 property"""
        vec_elem = ET.SubElement(parent, "Vector3", {"name": name})
        x_elem = ET.SubElement(vec_elem, "X")
        x_elem.text = str(vec.x)
        y_elem = ET.SubElement(vec_elem, "Y")
        y_elem.text = str(vec.y)
        z_elem = ET.SubElement(vec_elem, "Z")
        z_elem.text = str(vec.z)
    
    def _add_attribute(self, parent: ET.Element, name: str, value):
        """Add an attribute"""
        attr_type = "string" if isinstance(value, str) else "bool" if isinstance(value, bool) else "float"
        attr = ET.SubElement(parent, attr_type, {"name": f"Attribute_{name}"})
        attr.text = str(value)
    
    def _vector3_to_cframe(self, position: Vector3, rotation: tuple) -> str:
        """Convert Vector3 and rotation to CFrame string"""
        # Simplified CFrame (position only, rotation as Euler angles would need full matrix)
        # For basic export: <X>, <Y>, <Z>, 1, 0, 0, 0, 1, 0, 0, 0, 1
        return f"{position.x}, {position.y}, {position.z}, 1, 0, 0, 0, 1, 0, 0, 0, 1"
    
    def _generate_referent(self) -> str:
        """Generate a unique referent ID"""
        import uuid
        return f"RBX{uuid.uuid4().hex[:16].upper()}"
