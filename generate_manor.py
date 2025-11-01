#!/usr/bin/env python3
"""Standalone CLI for generating Roblox manor files"""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from manor_generator import ManorGenerator, ManorConfig
from manor_generator.exporters import RBXMXExporter, RojoExporter
import argparse
import json


def main():
    parser = argparse.ArgumentParser(
        description="Generate Roblox Haunted Manor (Angry Granny Manor)"
    )
    
    parser.add_argument(
        "--output-dir",
        "-o",
        default="./output",
        help="Output directory for generated files"
    )
    
    parser.add_argument(
        "--format",
        "-f",
        choices=["rbxmx", "rojo", "both"],
        default="both",
        help="Export format (rbxmx, rojo, or both)"
    )
    
    parser.add_argument(
        "--config",
        "-c",
        help="Path to JSON config file"
    )
    
    parser.add_argument(
        "--no-basement",
        action="store_true",
        help="Exclude basement"
    )
    
    parser.add_argument(
        "--no-attic",
        action="store_true",
        help="Exclude attic"
    )
    
    parser.add_argument(
        "--no-secret",
        action="store_true",
        help="Exclude secret passage"
    )
    
    parser.add_argument(
        "--scale",
        type=float,
        default=1.0,
        help="Scale factor for manor size"
    )
    
    parser.add_argument(
        "--prop-density",
        type=float,
        default=0.5,
        help="Prop density (0.0 to 1.0)"
    )
    
    args = parser.parse_args()
    
    # Create output directory
    os.makedirs(args.output_dir, exist_ok=True)
    
    # Load or create config
    if args.config and os.path.exists(args.config):
        with open(args.config, 'r') as f:
            config_dict = json.load(f)
            config = ManorConfig(**config_dict)
    else:
        config = ManorConfig(
            include_basement=not args.no_basement,
            include_attic=not args.no_attic,
            include_secret_passage=not args.no_secret,
            scale_factor=args.scale,
            prop_density=args.prop_density
        )
    
    print("="*50)
    print("🏰 ANGRY GRANNY MANOR GENERATOR 🏰")
    print("="*50)
    print(f"\nConfiguration:")
    print(f"  - Basement: {config.include_basement}")
    print(f"  - Attic: {config.include_attic}")
    print(f"  - Secret Passage: {config.include_secret_passage}")
    print(f"  - Scale: {config.scale_factor}x")
    print(f"  - Prop Density: {config.prop_density}")
    print(f"  - Max Parts: {config.max_parts}")
    print()
    
    # Generate manor
    generator = ManorGenerator(config)
    manor = generator.generate()
    
    # Display statistics
    print("\n" + "="*50)
    print("📊 MANOR STATISTICS")
    print("="*50)
    for key, value in manor.statistics.items():
        print(f"  {key.replace('_', ' ').title()}: {value}")
    print()
    
    # Export
    if args.format in ["rbxmx", "both"]:
        rbxmx_exporter = RBXMXExporter(manor)
        rbxmx_file = os.path.join(args.output_dir, "Manor.rbxmx")
        rbxmx_exporter.export(rbxmx_file)
        print(f"✅ RBXMX file created: {rbxmx_file}")
    
    if args.format in ["rojo", "both"]:
        rojo_exporter = RojoExporter(manor)
        rojo_dir = rojo_exporter.export(args.output_dir)
        print(f"✅ Rojo structure created: {rojo_dir}")
    
    print("\n" + "="*50)
    print("✅ GENERATION COMPLETE!")
    print("="*50)
    print(f"\nOutput saved to: {args.output_dir}")
    print("\nNext steps:")
    if args.format in ["rbxmx", "both"]:
        print("  1. Open Roblox Studio")
        print("  2. Go to Model tab > Import 3D")
        print(f"  3. Select {os.path.join(args.output_dir, 'Manor.rbxmx')}")
    if args.format in ["rojo", "both"]:
        print("  1. Install Rojo (https://rojo.space/)")
        print(f"  2. Run: rojo serve {os.path.join(args.output_dir, 'default.project.json')}")
        print("  3. Connect from Roblox Studio")
    print()


if __name__ == "__main__":
    main()
