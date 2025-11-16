"""
Result aggregation module for combining frame analyses into a comprehensive swing report.
"""
from typing import List, Dict


def aggregate_frame_analyses(frame_analyses: List[Dict], video_id: str) -> Dict:
    """
    Combine all frame analyses into a concise overall assessment with top recommendations.
    
    Args:
        frame_analyses: List of frame analysis dictionaries
        video_id: Unique identifier for the video
    
    Returns:
        Dictionary containing aggregated swing analysis
    """
    if not frame_analyses:
        return {
            "video_id": video_id,
            "status": "error",
            "message": "No frame analyses provided",
            "full_report": ""
        }
    
    total_frames = len(frame_analyses)
    
    # Collect all observations, issues, and corrections from all frames
    all_observations = []
    all_issues = []
    all_corrections = []
    
    for analysis in frame_analyses:
        obs = analysis.get('observations', '')
        if obs:
            all_observations.append(obs)
        issues = analysis.get('issues', [])
        all_issues.extend(issues)
        corrections = analysis.get('corrections', [])
        all_corrections.extend(corrections)
    
    # Build concise overall assessment
    report_sections = []
    
    # Header
    report_sections.append("GOLF SWING ANALYSIS")
    report_sections.append("=" * 50)
    report_sections.append(f"Analyzed {total_frames} frames from your swing video\n")
    
    # Overall Assessment
    report_sections.append("OVERALL ASSESSMENT")
    report_sections.append("-" * 50)
    
    # Extract key insights from observations
    key_insights = []
    swing_phases = {
        'setup': [],
        'backswing': [],
        'downswing': [],
        'impact': [],
        'follow-through': []
    }
    
    # Categorize observations by swing phase keywords
    for i, obs in enumerate(all_observations[:15]):  # Use first 15 observations
        obs_lower = obs.lower()
        if any(word in obs_lower for word in ['setup', 'address', 'stance', 'posture', 'grip']):
            swing_phases['setup'].append(obs[:150])  # Limit length
        elif any(word in obs_lower for word in ['backswing', 'takeaway', 'back', 'coil']):
            swing_phases['backswing'].append(obs[:150])
        elif any(word in obs_lower for word in ['downswing', 'transition', 'down', 'weight shift']):
            swing_phases['downswing'].append(obs[:150])
        elif any(word in obs_lower for word in ['impact', 'contact', 'ball']):
            swing_phases['impact'].append(obs[:150])
        elif any(word in obs_lower for word in ['follow', 'finish', 'through']):
            swing_phases['follow-through'].append(obs[:150])
        else:
            key_insights.append(obs[:150])
    
    # Build overall assessment summary
    assessment_parts = []
    
    if swing_phases['setup']:
        assessment_parts.append(f"Setup: {swing_phases['setup'][0]}")
    if swing_phases['backswing']:
        assessment_parts.append(f"Backswing: {swing_phases['backswing'][0]}")
    if swing_phases['downswing']:
        assessment_parts.append(f"Downswing: {swing_phases['downswing'][0]}")
    if swing_phases['impact']:
        assessment_parts.append(f"Impact: {swing_phases['impact'][0]}")
    if swing_phases['follow-through']:
        assessment_parts.append(f"Follow-through: {swing_phases['follow-through'][0]}")
    
    # If we have key insights, add them
    if key_insights:
        assessment_parts.append(key_insights[0])
    
    # Combine into overall assessment (limit to 3-4 sentences)
    if assessment_parts:
        overall_text = " ".join(assessment_parts[:3])
        # Truncate if too long
        if len(overall_text) > 400:
            overall_text = overall_text[:400] + "..."
        report_sections.append(overall_text)
    else:
        # Fallback: use first observation
        if all_observations:
            first_obs = all_observations[0][:400]
            report_sections.append(first_obs)
        else:
            report_sections.append("Analysis completed. Review the recommendations below.")
    
    report_sections.append("")
    
    # Top 5 Recommendations
    report_sections.append("TOP 5 RECOMMENDATIONS")
    report_sections.append("-" * 50)
    
    # Get unique corrections, prioritizing longer/more detailed ones
    unique_corrections = []
    seen = set()
    for correction in all_corrections:
        # Normalize and check for duplicates
        normalized = correction.lower().strip()
        if normalized and normalized not in seen and len(correction) > 20:
            unique_corrections.append(correction)
            seen.add(normalized)
            if len(unique_corrections) >= 5:
                break
    
    # If we don't have 5 corrections, extract from observations
    if len(unique_corrections) < 5:
        for obs in all_observations:
            if 'suggest' in obs.lower() or 'should' in obs.lower() or 'improve' in obs.lower():
                # Extract recommendation-like sentences
                sentences = obs.split('.')
                for sentence in sentences:
                    sentence = sentence.strip()
                    if any(word in sentence.lower() for word in ['suggest', 'should', 'improve', 'try', 'focus', 'work on']):
                        normalized = sentence.lower().strip()
                        if normalized and normalized not in seen and len(sentence) > 20:
                            unique_corrections.append(sentence)
                            seen.add(normalized)
                            if len(unique_corrections) >= 5:
                                break
                if len(unique_corrections) >= 5:
                    break
    
    # Ensure we have exactly 5 recommendations
    while len(unique_corrections) < 5:
        unique_corrections.append("Continue practicing and focus on maintaining consistent form throughout your swing.")
    
    # Display top 5
    for i, recommendation in enumerate(unique_corrections[:5], 1):
        # Clean up the recommendation text
        rec_text = recommendation.strip()
        if rec_text.startswith('-') or rec_text.startswith('•'):
            rec_text = rec_text[1:].strip()
        report_sections.append(f"{i}. {rec_text}")
    
    # Combine all sections
    full_report = "\n".join(report_sections)
    
    return {
        "video_id": video_id,
        "status": "success",
        "total_frames": total_frames,
        "full_report": full_report,
        "summary": {
            "total_frames": total_frames,
            "total_issues": len(all_issues),
            "total_corrections": len(unique_corrections)
        },
        "frame_analyses": frame_analyses  # Include raw analyses for chatbot context
    }

