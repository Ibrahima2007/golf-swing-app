from flask import Blueprint, request, jsonify
from services import chatbot_services
from services import video_processing
from services import frame_analyzer
from services import aggregate_results
import os
import uuid
from werkzeug.utils import secure_filename
import threading

chat_bp = Blueprint('chat', __name__)

# Directory to store uploaded videos
UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), '..', 'uploads')
ALLOWED_EXTENSIONS = {'mp4', 'mov', 'avi', 'mkv'}

# Ensure upload directory exists
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# In-memory cache for video analyses (in production, use Redis or database)
video_analyses_cache = {}
cache_lock = threading.Lock()


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@chat_bp.route('/upload_video', methods=['POST'])
def upload_video():
    """Handle video upload and return frame-by-frame analysis"""
    try:
        if 'video' not in request.files:
            return jsonify({
                'status': 'error',
                'message': 'No video file provided',
                'video_id': None,
                'initial_analysis': ''
            }), 400

        file = request.files['video']
        if file.filename == '':
            return jsonify({
                'status': 'error',
                'message': 'No file selected',
                'video_id': None,
                'initial_analysis': ''
            }), 400

        if file and allowed_file(file.filename):
            # Generate unique video ID
            video_id = str(uuid.uuid4())
            filename = secure_filename(file.filename)
            # Save with video_id prefix
            filepath = os.path.join(UPLOAD_FOLDER, f"{video_id}_{filename}")
            file.save(filepath)
            
            print(f"Video uploaded: {filepath}")
            print("Starting frame-by-frame analysis...")

            try:
                # Step 1: Extract frames from video
                print("Step 1: Extracting frames...")
                frame_paths = video_processing.extract_frames(
                    filepath, 
                    interval_seconds=0.1,  # Extract every 0.1 seconds
                    max_frames=30  # Limit to 30 frames to avoid too many API calls
                )
                print(f"Extracted {len(frame_paths)} frames")

                # Step 2: Analyze each frame with GPT Vision
                print("Step 2: Analyzing frames with GPT Vision...")
                frame_analyses = []
                previous_context = []
                
                for i, frame_path in enumerate(frame_paths):
                    print(f"Analyzing frame {i+1}/{len(frame_paths)}...")
                    analysis = frame_analyzer.analyze_frame(
                        frame_path,
                        frame_number=i,
                        previous_context=previous_context,
                        total_frames=len(frame_paths)
                    )
                    frame_analyses.append(analysis)
                    # Keep last 2 analyses for context
                    previous_context = frame_analyses[-2:] if len(frame_analyses) >= 2 else frame_analyses
                
                print(f"Completed analysis of {len(frame_analyses)} frames")

                # Step 3: Aggregate results into comprehensive report
                print("Step 3: Aggregating results...")
                aggregated = aggregate_results.aggregate_frame_analyses(frame_analyses, video_id)
                full_report = aggregated.get('full_report', '')
                
                # Step 4: Cache the analysis for chatbot use
                with cache_lock:
                    video_analyses_cache[video_id] = {
                        'frame_analyses': frame_analyses,
                        'aggregated': aggregated,
                        'video_path': filepath
                    }
                
                print("Analysis complete and cached")
                
                # Clean up temporary frame files
                try:
                    video_processing.cleanup_frames(frame_paths)
                except Exception as cleanup_error:
                    print(f"Warning: Could not cleanup frames: {cleanup_error}")

                # Return the comprehensive analysis
                return jsonify({
                    'status': 'success',
                    'video_id': video_id,
                    'initial_analysis': full_report
                }), 200

            except Exception as analysis_error:
                print(f"Frame analysis error: {str(analysis_error)}")
                import traceback
                traceback.print_exc()
                # Fallback to simple analysis if frame processing fails
                analysis_result = chatbot_services.analyze_video(None)
                initial_analysis = analysis_result.get('analysis', 'Analysis failed. Please try again.')
                
                return jsonify({
                    'status': 'success',
                    'video_id': video_id,
                    'initial_analysis': initial_analysis
                }), 200
        else:
            return jsonify({
                'status': 'error',
                'message': 'Invalid file type. Please upload a video file.',
                'video_id': None,
                'initial_analysis': ''
            }), 400

    except Exception as e:
        print(f"Upload error: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'status': 'error',
            'message': f'Upload failed: {str(e)}',
            'video_id': None,
            'initial_analysis': ''
        }), 500


@chat_bp.route('/chat', methods=['POST'])
def chat():
    """Handle chat messages about the swing with access to cached frame analyses"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({
                'status': 'error',
                'message': 'No data provided',
                'reply': ''
            }), 400

        video_id = data.get('video_id', '')
        message = data.get('message', '')
        
        if not message:
            return jsonify({
                'status': 'error',
                'message': 'No message provided',
                'reply': ''
            }), 400

        # Load cached video analysis if available
        video_context = ""
        if video_id:
            with cache_lock:
                cached = video_analyses_cache.get(video_id)
                if cached:
                    aggregated = cached.get('aggregated', {})
                    frame_analyses = cached.get('frame_analyses', [])
                    
                    # Build rich context from frame analyses
                    video_context = f"""Video Analysis Summary:
Total Frames Analyzed: {aggregated.get('total_frames', 0)}
Full Swing Report:
{aggregated.get('full_report', '')[:2000]}...

Frame-by-Frame Details:
"""
                    # Add key frame observations
                    for frame in frame_analyses[:5]:  # Include first 5 frames
                        video_context += f"\nFrame {frame.get('frame', '?') + 1}: {frame.get('observations', '')[:300]}..."
                else:
                    video_context = f"Video ID: {video_id} (Analysis not found in cache)"
        
        chat_result = chatbot_services.chat_with_coach(message, video_context)
        reply = chat_result.get('reply', 'I encountered an error processing your question.')

        return jsonify({
            'status': 'success',
            'reply': reply
        }), 200

    except Exception as e:
        print(f"Chat error: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'status': 'error',
            'message': f'Chat failed: {str(e)}',
            'reply': 'I encountered an error processing your question. Please try again.'
        }), 500

