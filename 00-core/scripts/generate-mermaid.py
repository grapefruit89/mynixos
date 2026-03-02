#!/usr/bin/env python3
import os
import sys
import json
import urllib.request

# Minimal Architect Script for NixOS Layer Visualization
# Usage: ./generate-mermaid.py <API_KEY> <BASE_DIR>

# Try to find the nixos root
BASE_DIR = sys.argv[2] if len(sys.argv) > 2 else ("/etc/nixos" if os.path.exists("/etc/nixos/configuration.nix") else ".")

API_KEY = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("GEMINI_API_KEY")
if not API_KEY:
    print("Error: Missing GEMINI_API_KEY")
    sys.exit(1)

def get_file_structure(startpath):
    structure = []
    for root, dirs, files in os.walk(startpath):
        if ".git" in root or ".gemini" in root: continue
        level = root.replace(startpath, '').count(os.sep)
        indent = ' ' * 4 * (level)
        structure.append(f"{indent}{os.path.basename(root)}/")
        for f in files:
            if f.endswith(".nix"):
                structure.append(f"{indent}    {f}")
    return chr(10).join(structure)

def get_main_imports(base):
    try:
        config_path = os.path.join(base, "configuration.nix")
        with open(config_path, "r") as f:
            return f.read()
    except:
        return f"configuration.nix not found in {base}"

repo_structure = get_file_structure(BASE_DIR)
main_config = get_main_imports(BASE_DIR)

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

req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers=headers)
try:
    with urllib.request.urlopen(req) as response:
        result = json.loads(response.read().decode('utf-8'))
        text = result['candidates'][0]['content']['parts'][0]['text']
        # Extract mermaid block
        if "```mermaid" in text:
            # Take the last mermaid block if multiple exist, usually it's the most complete one
            mermaid_code = text.split("```mermaid")[-1].split("```")[0].strip()
            print("# 🏗️ System Architecture (Auto-Generated)")
            print()
            print("```mermaid")
            print(mermaid_code)
            print("```")
        elif "graph " in text or "flowchart " in text:
            # Fallback if the model forgot the code block markers
            print("# 🏗️ System Architecture (Auto-Generated)")
            print()
            print("```mermaid")
            print(text.strip())
            print("```")
        else:
            print(text)
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
