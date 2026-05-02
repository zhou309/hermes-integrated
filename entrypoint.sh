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

# Debug: show what's in the hermes home dir
echo "--- /root/.hermes contents ---"
ls -la /root/.hermes/ 2>/dev/null || echo "(empty or not mounted)"
echo "--- /root/.hermes/sessions (if exists) ---"
ls /root/.hermes/sessions/ 2>/dev/null | head -5 || echo "(no sessions dir)"
echo "--- state.db exists? ---"
ls -lh /root/.hermes/state.db 2>/dev/null || echo "(no state.db)"
echo "------------------------------"

# Migrate old hermes dashboard sessions into webui sessions dir
OLD_SESSIONS=/root/.hermes/sessions
WEBUI_SESSIONS=/root/.hermes/webui/sessions
if [ -d "$OLD_SESSIONS" ]; then
  mkdir -p "$WEBUI_SESSIONS"
  COUNT=0
  for f in "$OLD_SESSIONS"/session_*.json "$OLD_SESSIONS"/*.json; do
    [ -f "$f" ] || continue
    BASENAME=$(basename "$f")
    DEST_NAME="${BASENAME#session_}"
    DEST="$WEBUI_SESSIONS/$DEST_NAME"
    if [ ! -f "$DEST" ]; then
      cp "$f" "$DEST"
      COUNT=$((COUNT + 1))
    fi
  done
  [ "$COUNT" -gt 0 ] && echo "Migrated $COUNT old sessions to webui."
fi

echo "Starting Hermes Agent on port 9119..."
hermes dashboard --host 127.0.0.1 --port 9119 --no-open &

sleep 2

echo "Starting Hermes Web UI on port ${PORT:-8787}..."
export HERMES_WEBUI_HOST=0.0.0.0
export HERMES_WEBUI_PORT="${PORT:-8787}"
export HERMES_WEBUI_AGENT_DIR=/opt/hermes-agent
export HERMES_HOME=/root/.hermes
cd /opt/hermes-webui
exec python server.py
