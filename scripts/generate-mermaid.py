#!/usr/bin/env python3
import os
import sys
import requests
import json

# Minimal Architect Script for NixOS Layer Visualization
# Usage: ./generate-mermaid.py <API_KEY>

API_KEY = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("GEMINI_API_KEY")
if not API_KEY:
    print("Error: Missing GEMINI_API_KEY")
    sys.exit(1)

def get_file_structure(startpath):
    structure = []
    for root, dirs, files in os.walk(startpath):
        if ".git" in root: continue
        level = root.replace(startpath, '').count(os.sep)
        indent = ' ' * 4 * (level)
        structure.append(f"{indent}{os.path.basename(root)}/")
        subindent = ' ' * 4 * (level + 1)
        for f in files:
            if f.endswith(".nix"):
                structure.append(f"{subindent}{f}")
    return "
".join(structure)

def get_main_imports():
    try:
        with open("/etc/nixos/configuration.nix", "r") as f:
            return f.read()
    except:
        return "configuration.nix not found"

repo_structure = get_file_structure("/etc/nixos/")
main_config = get_main_imports()

prompt = f"""
Analyze the dependencies between my NixOS layers based on the file structure and the main configuration imports.
Layers: 00-core, 10-infrastructure, 20-services, 90-policy.

File Structure:
{repo_structure}

Main Imports:
{main_config}

Task:
Generate a valid Mermaid.js flowchart (graph TB) representing the actual imports and data flows between these layers.
- Group services into their respective layers using subgraphs.
- Identify dependencies (who imports what).
- Mark violations (e.g., 00-core importing 20-services) with red styling or dotted lines.
- Use professional icons/styles if possible.
- Output ONLY the raw mermaid code block starting with ```mermaid and ending with ```.
"""

url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={API_KEY}"
headers = {'Content-Type': 'application/json'}
data = {
    "contents": [{"parts": [{"text": prompt}]}]
}

response = requests.post(url, headers=headers, data=json.dumps(data))
if response.status_code == 200:
    result = response.json()
    text = result['candidates'][0]['content']['parts'][0]['text']
    # Extract mermaid block
    if "```mermaid" in text:
        mermaid_code = text.split("```mermaid")[1].split("```")[0].strip()
        print("# 🏗️ System Architecture (Auto-Generated)
")
        print("```mermaid")
        print(mermaid_code)
        print("```")
    else:
        print(text)
else:
    print(f"Error: {response.status_code} - {response.text}")
    sys.exit(1)
