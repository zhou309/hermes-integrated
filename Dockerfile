FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates ripgrep ffmpeg sudo \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Clone hermes-agent
RUN git clone --recurse-submodules https://github.com/NousResearch/hermes-agent.git /opt/hermes-agent

WORKDIR /opt/hermes-agent
RUN uv venv venv --python 3.11 \
    && VIRTUAL_ENV=/opt/hermes-agent/venv uv pip install -e ".[all]"

ENV PATH="/opt/hermes-agent/venv/bin:$PATH"

# Setup .hermes directory
RUN mkdir -p /root/.hermes/{cron,sessions,logs,memories,skills,pairing,hooks,image_cache,audio_cache} \
    && cp cli-config.yaml.example /root/.hermes/config.yaml \
    && touch /root/.hermes/.env

# Setup hermes-webui
WORKDIR /opt/hermes-webui
COPY webui /opt/hermes-webui
RUN python -m pip install --upgrade pip setuptools wheel uv && \
    uv pip install -e . 2>/dev/null || python -m pip install -r requirements.txt 2>/dev/null || true

# Set hermes-webui env vars
ENV HERMES_WEBUI_HOST=0.0.0.0
ENV HERMES_WEBUI_PORT=8787
ENV HERMES_WEBUI_AGENT_DIR=/opt/hermes-agent
ENV HERMES_HOME=/root/.hermes

# Copy auth_proxy and combined entrypoint
COPY auth_proxy.py /auth_proxy.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8787
ENTRYPOINT ["/entrypoint.sh"]
