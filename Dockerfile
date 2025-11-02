FROM python:3.11-slim

# 1) OS deps
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg git \
    && rm -rf /var/lib/apt/lists/*

# 2) Sécuriser/fiabiliser pip (pas de hash obligatoire)
ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DEFAULT_TIMEOUT=120 \
    PIP_REQUIRE_HASHES=0

RUN python -m pip install --upgrade pip setuptools wheel

# 3) Installer Torch CPU depuis l’index officiel (évite surprises)
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# 4) Installer Whisper
RUN pip install openai-whisper

WORKDIR /app
CMD ["bash"]
