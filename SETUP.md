# Hermes Integrated Setup

This is a combined setup that runs both Hermes Agent and Hermes WebUI in a single Docker container.

## Architecture

- **Hermes Agent**: Runs on port 9119 (dashboard)
- **Hermes WebUI**: Runs on port 8787 (web interface)
- **Auth Proxy**: Runs on the main port with cookie-based authentication

## Files

- `Dockerfile` - Combined Docker image with both services
- `entrypoint.sh` - Startup script that launches both services
- `webui/` - Hermes WebUI code
- `auth_proxy.py` - Authentication proxy from original setup

## Environment Variables

- `AUTO_UPDATE` - Auto-update hermes-agent on startup (default: true)
- `DASHBOARD_PASSWORD` - Required for auth_proxy authentication
- `HERMES_WEBUI_PASSWORD` - Optional password for webui
- `HERMES_HOME` - Base directory for hermes state (default: /root/.hermes)

## Deployment to Railway

1. Create a new GitHub repository
2. Push this code to GitHub
3. Connect the repository to your Railway project
4. Set `DASHBOARD_PASSWORD` environment variable in Railway
5. Railway will build and deploy automatically

## Local Testing

```bash
docker build -t hermes-integrated .
docker run -p 8000:8000 -e DASHBOARD_PASSWORD=your_password hermes-integrated
```

Then visit http://localhost:8000 and log in with credentials.

