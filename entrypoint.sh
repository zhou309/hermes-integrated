#!/usr/bin/env bash
set -e

AUTO_UPDATE="${AUTO_UPDATE:-true}"

echo "Starting Hermes integrated setup..."

if [ "$AUTO_UPDATE" = "true" ]; then
  echo "Checking for Hermes Agent updates..."
  cd /opt/hermes-agent
  UPDATE_OUTPUT=$(git pull --recurse-submodules 2>&1)
  if echo "$UPDATE_OUTPUT" | grep -q 'Already up to date'; then
    echo "Agent already up to date."
  else
    echo "$UPDATE_OUTPUT"
    echo "Updating Agent dependencies..."
    VIRTUAL_ENV=/opt/hermes-agent/venv uv pip install -e ".[all]" --quiet
    echo "Agent update complete."
  fi
fi

# Start hermes agent dashboard in background (webui connects to it)
echo "Starting Hermes Agent on port 9119..."
hermes dashboard --host 127.0.0.1 --port 9119 --no-open &

sleep 2

# Run hermes-webui server.py directly as the foreground process
echo "Starting Hermes Web UI on port ${PORT:-8787}..."
export HERMES_WEBUI_HOST=0.0.0.0
export HERMES_WEBUI_PORT="${PORT:-8787}"
export HERMES_WEBUI_AGENT_DIR=/opt/hermes-agent
export HERMES_HOME=/root/.hermes
cd /opt/hermes-webui
exec python server.py
