"""
Image processing service for handling uploads and storage
"""
import os
import uuid
import shutil
from pathlib import Path
try:
    from PIL import Image
    HAS_PIL = True
except ImportError:
    HAS_PIL = False
from io import BytesIO
from typing import Tuple
from app.config import settings


class ImageService:
    """Service for image upload, compression, and storage"""
    
    def __init__(self):
        self.upload_dir = Path(settings.UPLOAD_DIR)
        self.upload_dir.mkdir(parents=True, exist_ok=True)
    
    async def save_image(self, file_bytes: bytes, filename: str) -> Tuple[str, bytes]:
        """
        Save uploaded image with compression
        
        Returns:
            Tuple of (file_path, compressed_bytes)
        """
        # Validate file size
        if len(file_bytes) > settings.MAX_UPLOAD_SIZE:
            raise ValueError(f"File size exceeds maximum allowed size of {settings.MAX_UPLOAD_SIZE} bytes")
        
        # Generate unique filename
        file_ext = Path(filename).suffix.lower()
        if file_ext not in settings.ALLOWED_EXTENSIONS:
            raise ValueError(f"File type {file_ext} not allowed. Allowed: {settings.ALLOWED_EXTENSIONS}")
        
        unique_filename = f"{uuid.uuid4().hex}{file_ext}"
        file_path = self.upload_dir / unique_filename
        
        # Compress and save image
        try:
            if not HAS_PIL:
                # Fallback: Save raw bytes if PIL is missing
                with open(file_path, "wb") as f:
                    f.write(file_bytes)
                return str(file_path), file_bytes

            image = Image.open(BytesIO(file_bytes))
            
            # Convert HEIC or other formats to JPEG
            if image.format not in ["JPEG", "PNG"]:
                image = image.convert("RGB")
                unique_filename = f"{uuid.uuid4().hex}.jpg"
                file_path = self.upload_dir / unique_filename
            
            # Resize if too large (max 1920px on longest side)
            max_dimension = 1920
            if max(image.size) > max_dimension:
                image.thumbnail((max_dimension, max_dimension), Image.Resampling.LANCZOS)
            
            # Save with compression
            output = BytesIO()
            if image.mode in ("RGBA", "LA", "P"):
                image = image.convert("RGB")
            
            image.save(file_path, format="JPEG", quality=85, optimize=True)
            image.save(output, format="JPEG", quality=85, optimize=True)
            compressed_bytes = output.getvalue()
            
            return str(file_path), compressed_bytes
            
        except Exception as e:
            raise ValueError(f"Error processing image: {str(e)}")
    
    def get_image_url(self, file_path: str) -> str:
        """
        Get public URL for image
        In production, this would be S3/Cloud Storage URL
        """
        # For now, return local path
        # In production: upload to S3 and return public URL
        return f"/uploads/{Path(file_path).name}"
    
    def delete_image(self, file_path: str):
        """Delete image from storage"""
        try:
            Path(file_path).unlink(missing_ok=True)
        except Exception as e:
            print(f"Error deleting image: {e}")


# Global image service instance
image_service = ImageService()
