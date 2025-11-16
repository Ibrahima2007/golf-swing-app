"""
Video processing module for extracting frames from golf swing videos.
"""
import os
import cv2
from pathlib import Path
from typing import List
import tempfile


def extract_frames(video_path: str, interval_seconds: float = 0.1, max_frames: int = 50) -> List[str]:
    """
    Extract frames from a video at fixed intervals.
    
    Args:
        video_path: Path to the input video file
        interval_seconds: Time interval between frames (default: 0.1s = 10 fps)
        max_frames: Maximum number of frames to extract (to avoid too many API calls)
    
    Returns:
        List of file paths to extracted frame images
    """
    if not os.path.exists(video_path):
        raise FileNotFoundError(f"Video file not found: {video_path}")
    
    # Create temporary directory for frames
    temp_dir = tempfile.mkdtemp(prefix="golf_frames_")
    frame_paths = []
    
    # Open video file
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        raise ValueError(f"Could not open video file: {video_path}")
    
    fps = cap.get(cv2.CAP_PROP_FPS)
    if fps <= 0:
        fps = 30  # Default fallback
    
    frame_interval = int(fps * interval_seconds)  # Frames to skip
    frame_count = 0
    extracted_count = 0
    
    try:
        while extracted_count < max_frames:
            ret, frame = cap.read()
            if not ret:
                break
            
            # Extract frame at specified interval
            if frame_count % frame_interval == 0:
                frame_filename = os.path.join(temp_dir, f"frame_{extracted_count:04d}.jpg")
                cv2.imwrite(frame_filename, frame)
                frame_paths.append(frame_filename)
                extracted_count += 1
            
            frame_count += 1
        
        print(f"Extracted {len(frame_paths)} frames from video")
        return frame_paths
    
    finally:
        cap.release()


def cleanup_frames(frame_paths: List[str]):
    """Clean up temporary frame files."""
    for frame_path in frame_paths:
        try:
            if os.path.exists(frame_path):
                os.remove(frame_path)
        except Exception as e:
            print(f"Warning: Could not delete frame {frame_path}: {e}")
    
    # Try to remove the temp directory if empty
    if frame_paths:
        temp_dir = os.path.dirname(frame_paths[0])
        try:
            if os.path.exists(temp_dir) and not os.listdir(temp_dir):
                os.rmdir(temp_dir)
        except Exception:
            pass

