"""
Frame analyzer module for analyzing individual video frames using GPT Vision.
"""
import base64
import os
from typing import Dict, Optional, List
from openai import OpenAI
from dotenv import load_dotenv

# Load environment variables
basedir = os.path.abspath(os.path.dirname(__file__))
env_path = os.path.join(os.path.dirname(basedir), '.env')
load_dotenv(env_path)
load_dotenv()

GPT_API_KEY = os.environ.get("GPT_API_KEY")
if GPT_API_KEY:
    GPT_API_KEY = GPT_API_KEY.strip()
    if GPT_API_KEY and GPT_API_KEY != "your_openai_api_key_here":
        client = OpenAI(api_key=GPT_API_KEY)
    else:
        client = None
else:
    client = None


def encode_image_to_base64(image_path: str) -> str:
    """Encode an image file to base64 string."""
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')


def analyze_frame(
    image_path: str,
    frame_number: int,
    previous_context: Optional[List[Dict]] = None,
    total_frames: int = 1
) -> Dict:
    """
    Analyze a single frame using GPT Vision API.
    
    Args:
        image_path: Path to the frame image
        frame_number: Current frame number (0-indexed)
        previous_context: List of previous frame analyses for continuity
        total_frames: Total number of frames being analyzed
    
    Returns:
        Dictionary containing frame analysis
    """
    if not client:
        return {
            "frame": frame_number,
            "error": "GPT API key not configured",
            "observations": "Demo mode: Frame analysis unavailable",
            "issues": [],
            "corrections": []
        }
    
    if not os.path.exists(image_path):
        return {
            "frame": frame_number,
            "error": "Frame image not found",
            "observations": "",
            "issues": [],
            "corrections": []
        }
    
    try:
        # Encode image
        base64_image = encode_image_to_base64(image_path)
        
        # Build context from previous frames
        context_summary = ""
        if previous_context and len(previous_context) > 0:
            recent = previous_context[-2:]  # Last 1-2 frames
            context_summary = "\n\nPrevious frame context:\n"
            for prev in recent:
                context_summary += f"Frame {prev.get('frame', '?')}: {prev.get('observations', '')[:200]}...\n"
        
        # System prompt
        system_prompt = """You are a golf swing analysis expert. Analyze the player's body position, club movement, alignment, rotation, weight shift, and sequencing for THIS SINGLE FRAME. Reference previous-frame context if available. Be specific and technical."""
        
        # User prompt
        user_prompt = f"""Frame number: {frame_number + 1} of {total_frames}
{context_summary}

Analyze this golf swing frame and provide:
1. Key observations (body position, club angle, posture, rotation, balance, weight shift)
2. Mechanical issues (if any)
3. Positive elements
4. Suggested corrections (if needed)

Return your analysis in a clear, structured format focusing on:
- Setup/address position
- Backswing mechanics
- Transition phase
- Downswing mechanics
- Impact position
- Follow-through
- Tempo and timing markers
- Risk of injury indicators"""
        
        # Call GPT Vision API
        response = client.chat.completions.create(
            model="gpt-4o",  # GPT-4o supports vision
            messages=[
                {
                    "role": "system",
                    "content": system_prompt
                },
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": user_prompt
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64_image}"
                            }
                        }
                    ]
                }
            ],
            max_tokens=500,
            temperature=0.3  # Lower temperature for more consistent analysis
        )
        
        analysis_text = response.choices[0].message.content
        
        # Parse the response (GPT will return text, we'll extract structured info)
        return {
            "frame": frame_number,
            "observations": analysis_text,
            "raw_analysis": analysis_text,
            "issues": _extract_issues(analysis_text),
            "corrections": _extract_corrections(analysis_text),
            "status": "success"
        }
    
    except Exception as e:
        print(f"Error analyzing frame {frame_number}: {str(e)}")
        return {
            "frame": frame_number,
            "error": str(e),
            "observations": f"Error analyzing frame: {str(e)}",
            "issues": [],
            "corrections": []
        }


def _extract_issues(analysis_text: str) -> List[str]:
    """Extract issues from analysis text."""
    issues = []
    lines = analysis_text.split('\n')
    for line in lines:
        line_lower = line.lower()
        if any(keyword in line_lower for keyword in ['issue', 'problem', 'error', 'incorrect', 'wrong', 'poor', 'weak']):
            if line.strip() and not line.strip().startswith('#'):
                issues.append(line.strip())
    return issues[:5]  # Limit to top 5 issues


def _extract_corrections(analysis_text: str) -> List[str]:
    """Extract correction suggestions from analysis text."""
    corrections = []
    lines = analysis_text.split('\n')
    for line in lines:
        line_lower = line.lower()
        if any(keyword in line_lower for keyword in ['suggest', 'recommend', 'should', 'improve', 'fix', 'correct', 'adjust']):
            if line.strip() and not line.strip().startswith('#'):
                corrections.append(line.strip())
    return corrections[:5]  # Limit to top 5 corrections

