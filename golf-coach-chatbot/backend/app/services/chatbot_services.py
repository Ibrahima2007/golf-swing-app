import os
from openai import OpenAI
from dotenv import load_dotenv

# Load .env file from backend directory (parent of app directory)
basedir = os.path.abspath(os.path.dirname(__file__))
env_path = os.path.join(os.path.dirname(basedir), '.env')
print(f"Looking for .env file at: {env_path}")
print(f".env file exists: {os.path.exists(env_path)}")

# Try loading from backend directory first
if os.path.exists(env_path):
    load_dotenv(env_path, override=True)
    print(f"Loaded .env from: {env_path}")
# Also try loading from current directory
load_dotenv(override=True)

GPT_API_KEY = os.environ.get("GPT_API_KEY")
if GPT_API_KEY:
    # Strip whitespace and check if it's not the placeholder
    GPT_API_KEY = GPT_API_KEY.strip()
    if GPT_API_KEY and GPT_API_KEY != "your_openai_api_key_here":
        print(f"✓ GPT API key loaded successfully (length: {len(GPT_API_KEY)}). Chatbot features enabled.")
        client = OpenAI(api_key=GPT_API_KEY)
    else:
        print("Warning: GPT_API_KEY found but appears to be placeholder value. Chatbot features will not work.")
        client = None
else:
    print("Warning: GPT_API_KEY not found in environment. Chatbot features will not work.")
    print(f"Available env vars with 'GPT': {[k for k in os.environ.keys() if 'GPT' in k.upper()]}")
    client = None


def analyze_video(pose_summary: str = None) -> dict:
    """Generate initial analysis of a golf swing video"""
    if not client:
        return {
            "status": "error",
            "message": "GPT API key not configured",
            "analysis": "Demo insight: your backswing tempo looks smooth. Try keeping your lead arm straighter through impact."
        }
    
    try:
        user_prompt = (
            "Provide an expert golf swing review using the pose summary below. "
            "Call out strengths, issues, and 2-3 concrete adjustments.\n\n"
            f"{pose_summary}"
            if pose_summary
            else "No pose summary was supplied, so share a generic encouragement."
        )

        completion = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": (
                        "You are GolfSensei, a seasoned PGA instructor who writes "
                        "succinct, constructive coaching notes."
                    ),
                },
                {"role": "user", "content": user_prompt},
            ],
            max_tokens=500,
            temperature=0.6,
        )

        analysis = completion.choices[0].message.content.strip()
        return {
            "status": "success",
            "analysis": analysis
        }

    except Exception as exc:
        return {
            "status": "error",
            "message": f"Analysis failed: {exc}",
            "analysis": "Demo insight: your backswing tempo looks smooth. Try keeping your lead arm straighter through impact."
        }


def chat_with_coach(message: str, video_context: str = "") -> dict:
    """Handle follow-up chat messages about the swing"""
    if not client:
        return {
            "status": "error",
            "message": "GPT API key not configured",
            "reply": "I'm currently in demo mode. Please configure the GPT API key for full functionality."
        }
    
    if not message:
        return {
            "status": "error",
            "message": "No message provided"
        }

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": (
                        "You are GolfSensei, a professional swing coach. "
                        "Answer in a supportive, specific tone."
                    ),
                },
                {
                    "role": "user",
                    "content": f"Video context:\n{video_context}\n\nGolfer question: {message}",
                },
            ],
            max_tokens=500,
            temperature=0.6,
        )

        reply = response.choices[0].message.content

        return {
            "status": "success",
            "reply": reply
        }

    except Exception as e:
        return {
            "status": "error",
            "message": f"Chat failed: {str(e)}",
            "reply": "I encountered an error processing your question. Please try again."
        }

