FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ARG SCRCPY_VERSION=3.3.3

RUN apt-get update && apt-get install -y --no-install-recommends \
      xvfb x11vnc novnc websockify \
      ca-certificates curl xz-utils \
      libsdl2-2.0-0 libusb-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

# scrcpy 官方预编译包（自带 adb）
RUN curl -fsSL -o /tmp/scrcpy.tgz \
      https://github.com/Genymobile/scrcpy/releases/download/v${SCRCPY_VERSION}/scrcpy-linux-x86_64-v${SCRCPY_VERSION}.tar.gz \
    && mkdir -p /opt/scrcpy \
    && tar xf /tmp/scrcpy.tgz -C /opt/scrcpy --strip-components=1 \
    && rm /tmp/scrcpy.tgz

RUN apt-get update && apt-get install -y --no-install-recommends \
      xvfb x11vnc novnc websockify \
      ca-certificates curl xz-utils \
      libsdl2-2.0-0 libusb-1.0-0 \
      iproute2 procps \
    && rm -rf /var/lib/apt/lists/*

ENV PATH=/opt/scrcpy:$PATH \
    ANDROID_ADB_SERVER_PORT=5038 \
    ADB_ADDR=127.0.0.1:15555 \
    DISPLAY=:1 \
    SCREEN=720x1600x24 \
    MAX_SIZE=1280 \
    MAX_FPS=30 \
    BITRATE=4M \
    VNC_PASSWORD=changeme \
    NOVNC_PORT=6080 \
    VNC_PORT=5900 \
    SDL_RENDER_DRIVER=software

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]