"""Rojo model.json format exporter"""

import json
import os
from typing import Dict, List
from ..models import Manor, Model, Part, Vector3


class RojoExporter:
    """Exports manor to Rojo folder structure with model.json files"""
    
    def __init__(self, manor: Manor):
        self.manor = manor
        
    def export(self, output_dir: str):
        """Export manor to Rojo folder structure"""
        print(f"📁 Exporting to Rojo format at {output_dir}...")
        
        # Create output directory
        manor_dir = os.path.join(output_dir, "Manor")
        os.makedirs(manor_dir, exist_ok=True)
        
        # Export root model
        self._export_model(self.manor.root_model, manor_dir)
        
        # Create default.project.json for Rojo
        self._create_project_file(output_dir)
        
        print(f"✅ Exported to {manor_dir}")
        return manor_dir
    
    def _export_model(self, model: Model, base_path: str):
        """Export a model and its children"""
        # Create directory for this model
        model_path = os.path.join(base_path, model.name)
        os.makedirs(model_path, exist_ok=True)
        
        # Count parts for chunking (max 500 parts per file)
        total_parts = len(model.parts)
        chunk_size = 500
        
        if total_parts > 0:
            # Split parts into chunks if needed
            for chunk_idx in range(0, total_parts, chunk_size):
                chunk_parts = model.parts[chunk_idx:chunk_idx + chunk_size]
                
                # Create model.json for this chunk
                chunk_name = f"{model.name}_A" if chunk_idx == 0 else f"{model.name}_{chr(65 + chunk_idx // chunk_size)}"
                model_data = {
                    "ClassName": "Model",
                    "Name": chunk_name,
                    "Children": [self._part_to_dict(part) for part in chunk_parts]
                }
                
                if model.primary_part:
                    model_data["PrimaryPart"] = model.primary_part
                
                # Write to file
                output_file = os.path.join(model_path, f"{chunk_name}.model.json")
                with open(output_file, "w", encoding="utf-8") as f:
                    json.dump(model_data, f, indent=2)
        
        # Export child models recursively
        for child in model.children:
            self._export_model(child, model_path)
    
    def _part_to_dict(self, part: Part) -> Dict:
        """Convert Part to dictionary for JSON"""
        part_dict = {
            "ClassName": "Part",
            "Name": part.name,
            "Properties": {
                "Anchored": part.anchored,
                "CanCollide": part.can_collide,
                "Transparency": part.transparency,
                "Material": part.material.value,
                "Size": [part.size.x, part.size.y, part.size.z],
                "Position": [part.position.x, part.position.y, part.position.z],
                "Orientation": list(part.rotation),
                "Color": {
                    "R": part.color[0] / 255.0,
                    "G": part.color[1] / 255.0,
                    "B": part.color[2] / 255.0
                }
            }
        }
        
        # Add attributes if any
        if part.attributes:
            part_dict["Attributes"] = part.attributes
        
        return part_dict
    
    def _create_project_file(self, output_dir: str):
        """Create default.project.json for Rojo"""
        project = {
            "name": "AngryGrannyManor",
            "tree": {
                "$className": "DataModel",
                "Workspace": {
                    "$className": "Workspace",
                    "Manor": {
                        "$path": "Manor"
                    }
                }
            }
        }
        
        project_file = os.path.join(output_dir, "default.project.json")
        with open(project_file, "w", encoding="utf-8") as f:
            json.dump(project, f, indent=2)
        
        print(f"✅ Created Rojo project file: {project_file}")
