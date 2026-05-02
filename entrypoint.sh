#!/usr/bin/env bash
set -e

AUTO_UPDATE="${AUTO_UPDATE:-true}"

echo "🚀 Starting Hermes integrated setup..."

# Update hermes-agent if needed
if [ "$AUTO_UPDATE" = "true" ]; then
  echo "Checking for Hermes Agent updates..."
  cd /opt/hermes-agent
  if git pull --recurse-submodules 2>&1 | grep -v 'Already up to date'; then
    echo "Updating Agent dependencies..."
    VIRTUAL_ENV=/opt/hermes-agent/venv uv pip install -e ".[all]" --quiet
    echo "Agent update complete."
  else
    echo "Agent already up to date."
  fi
fi

# Start hermes dashboard in background
echo "Starting Hermes Agent dashboard on port 9119..."
hermes dashboard --host 127.0.0.1 --port 9119 --no-open &
HERMES_PID=$!

# Give hermes time to start
sleep 2

# Start hermes-webui
echo "Starting Hermes Web UI on port 8787..."
cd /opt/hermes-webui
python bootstrap.py --no-browser &
WEBUI_PID=$!

# Give webui time to start
sleep 3

# Start auth proxy as the main foreground process
echo "Starting auth proxy on main port..."
exec python /auth_proxy.py
