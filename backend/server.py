from fastapi import FastAPI, APIRouter, HTTPException
from fastapi.responses import FileResponse
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional
import uuid
from datetime import datetime, timezone
import sys

# Add parent directory to path for manor_generator import
sys.path.insert(0, str(Path(__file__).parent.parent))
from manor_generator import ManorGenerator, ManorConfig
from manor_generator.exporters import RBXMXExporter, RojoExporter


ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# MongoDB connection
mongo_url = os.environ['MONGO_URL']
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ['DB_NAME']]

# Create the main app without a prefix
app = FastAPI()

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")


# Define Models
class StatusCheck(BaseModel):
    model_config = ConfigDict(extra="ignore")  # Ignore MongoDB's _id field
    
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    client_name: str
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class StatusCheckCreate(BaseModel):
    client_name: str

# Manor Generator Models
class ManorConfigRequest(BaseModel):
    include_basement: bool = True
    include_attic: bool = True
    include_secret_passage: bool = True
    scale_factor: float = 1.0
    ceiling_height: float = 10.0
    corridor_width: float = 4.0
    prop_density: float = 0.5
    light_count: int = 20
    patrol_point_count: int = 12
    key_spawn_count: int = 6
    hiding_spot_count: int = 8
    max_parts: int = 6000
    dark_mode: bool = True
    victorian_style: bool = True

class ManorGenerateResponse(BaseModel):
    success: bool
    statistics: dict
    errors: List[str] = []
    download_urls: dict = {}

# Add your routes to the router instead of directly to app
@api_router.get("/")
async def root():
    return {"message": "Hello World"}

@api_router.post("/status", response_model=StatusCheck)
async def create_status_check(input: StatusCheckCreate):
    status_dict = input.model_dump()
    status_obj = StatusCheck(**status_dict)
    
    # Convert to dict and serialize datetime to ISO string for MongoDB
    doc = status_obj.model_dump()
    doc['timestamp'] = doc['timestamp'].isoformat()
    
    _ = await db.status_checks.insert_one(doc)
    return status_obj

@api_router.get("/status", response_model=List[StatusCheck])
async def get_status_checks():
    # Exclude MongoDB's _id field from the query results
    status_checks = await db.status_checks.find({}, {"_id": 0}).to_list(1000)
    
    # Convert ISO string timestamps back to datetime objects
    for check in status_checks:
        if isinstance(check['timestamp'], str):
            check['timestamp'] = datetime.fromisoformat(check['timestamp'])
    
    return status_checks

# Manor Generator Endpoints
@api_router.post("/manor/generate", response_model=ManorGenerateResponse)
async def generate_manor(config: ManorConfigRequest):
    """Generate a Roblox manor with the given configuration"""
    try:
        # Convert request to ManorConfig
        manor_config = ManorConfig(**config.model_dump())
        
        # Generate manor
        generator = ManorGenerator(manor_config)
        manor = generator.generate()
        
        # Validate
        is_valid, errors = manor.validate()
        
        # Create output directory
        output_dir = ROOT_DIR.parent / "output" / "manor_exports"
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Export to both formats
        manor_id = str(uuid.uuid4())[:8]
        
        # Export RBXMX
        rbxmx_exporter = RBXMXExporter(manor)
        rbxmx_file = output_dir / f"Manor_{manor_id}.rbxmx"
        rbxmx_exporter.export(str(rbxmx_file))
        
        # Export Rojo
        rojo_exporter = RojoExporter(manor)
        rojo_dir = output_dir / f"Manor_{manor_id}_Rojo"
        rojo_exporter.export(str(rojo_dir))
        
        return ManorGenerateResponse(
            success=is_valid,
            statistics=manor.statistics,
            errors=errors,
            download_urls={
                "rbxmx": f"/api/manor/download/rbxmx/{manor_id}",
                "rojo": f"/api/manor/download/rojo/{manor_id}"
            }
        )
    except Exception as e:
        logger.error(f"Manor generation error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.get("/manor/download/rbxmx/{manor_id}")
async def download_rbxmx(manor_id: str):
    """Download the generated RBXMX file"""
    file_path = ROOT_DIR.parent / "output" / "manor_exports" / f"Manor_{manor_id}.rbxmx"
    
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Manor file not found")
    
    return FileResponse(
        path=str(file_path),
        filename=f"Manor_{manor_id}.rbxmx",
        media_type="application/xml"
    )

@api_router.get("/manor/preview")
async def get_manor_preview(
    include_basement: bool = True,
    include_attic: bool = True,
    include_secret_passage: bool = True,
    scale_factor: float = 1.0,
    prop_density: float = 0.5
):
    """Get a preview of manor statistics without generating files"""
    try:
        config = ManorConfig(
            include_basement=include_basement,
            include_attic=include_attic,
            include_secret_passage=include_secret_passage,
            scale_factor=scale_factor,
            prop_density=prop_density
        )
        
        generator = ManorGenerator(config)
        manor = generator.generate()
        
        is_valid, errors = manor.validate()
        
        return {
            "valid": is_valid,
            "statistics": manor.statistics,
            "errors": errors,
            "config": config.__dict__
        }
    except Exception as e:
        logger.error(f"Manor preview error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Include the router in the main app
app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=os.environ.get('CORS_ORIGINS', '*').split(','),
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.on_event("shutdown")
async def shutdown_db_client():
    client.close()