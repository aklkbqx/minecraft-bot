FROM ubuntu:22.04

# หลีกเลี่ยงการถามคำถามระหว่างการติดตั้ง
ENV DEBIAN_FRONTEND=noninteractive

# ติดตั้งแพ็คเกจที่จำเป็น
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    xfce4 \
    xfce4-terminal \
    supervisor \
    net-tools \
    wget \
    curl \
    unzip \
    git \
    python3 \
    python3-pip \
    novnc \
    websockify \
    openjdk-17-jre \
    ca-certificates \
    libcurl4 \
    libssl3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libgtk-3-0 \
    libgbm1 \
    libasound2 \
    xdg-utils \
    menu \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libxshmfence1 \
    firefox \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ตัวแปรสภาพแวดล้อม
ENV HOME=/home/minecraft \
    DISPLAY=:1 \
    VNC_PORT=5900 \
    NOVNC_PORT=8080 \
    RESOLUTION=1920x1080 \
    MINECRAFT_SERVER=minecraft.aklkbqx.xyz

# สร้างผู้ใช้ minecraft
RUN useradd -m -d /home/minecraft minecraft && \
    mkdir -p /home/minecraft/.minecraft && \
    chown -R minecraft:minecraft /home/minecraft && \
    echo "minecraft:minecraft" | chpasswd

# สร้างไดเรกทอรีที่แชร์
RUN mkdir -p /home/minecraft/shared && chmod 777 /home/minecraft/shared

# ตั้งค่า NoVNC
RUN mkdir -p /usr/share/novnc && \
    ln -s /usr/share/novnc /usr/lib/novnc && \
    ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# สลับไปยังผู้ใช้ minecraft สำหรับการติดตั้ง
USER minecraft
WORKDIR /home/minecraft

# สร้าง Desktop directory
RUN mkdir -p /home/minecraft/Desktop

# สร้างโฟลเดอร์สำหรับ launcher
RUN mkdir -p /home/minecraft/launcher

# คัดลอกไฟล์ Legacy Launcher จาก host ไปยัง container
USER root
COPY LegacyLauncher_mcl.jar /home/minecraft/launcher/LegacyLauncher_mcl.jar
RUN chown minecraft:minecraft /home/minecraft/launcher/LegacyLauncher_mcl.jar && \
    chmod +x /home/minecraft/launcher/LegacyLauncher_mcl.jar

# กลับไปเป็น minecraft user
USER minecraft

# สร้างสคริปต์สำหรับเริ่ม Legacy Launcher
RUN echo '#!/bin/bash\ncd /home/minecraft/launcher\njava -jar LegacyLauncher_mcl.jar' > /home/minecraft/launcher/start-launcher.sh && \
    chmod +x /home/minecraft/launcher/start-launcher.sh

# สร้างทางลัดบนเดสก์ท็อป
RUN mkdir -p /home/minecraft/.local/share/applications && \
    echo "[Desktop Entry]\n\
Name=Legacy Launcher\n\
Comment=Minecraft Legacy Launcher\n\
Exec=/home/minecraft/launcher/start-launcher.sh\n\
Terminal=false\n\
Type=Application\n\
Categories=Game;" > /home/minecraft/.local/share/applications/legacy-launcher.desktop && \
    ln -s /home/minecraft/.local/share/applications/legacy-launcher.desktop /home/minecraft/Desktop/

# สร้างไฟล์ text บนเดสก์ท็อปที่มีข้อมูลเซิร์ฟเวอร์
RUN echo "เซิร์ฟเวอร์ Minecraft: ${MINECRAFT_SERVER}" > /home/minecraft/Desktop/minecraft_server_info.txt

# กลับไปเป็น root สำหรับการตั้งค่า supervisor
USER root

# สร้างไฟล์คอนฟิก supervisord
RUN echo "[supervisord]\n\
nodaemon=true\n\
logfile=/var/log/supervisor/supervisord.log\n\
pidfile=/var/run/supervisord.pid\n\
childlogdir=/var/log/supervisor\n\
\n\
[program:xvfb]\n\
command=/usr/bin/Xvfb :1 -screen 0 %(ENV_RESOLUTION)s -ac\n\
autorestart=true\n\
priority=100\n\
\n\
[program:x11vnc]\n\
command=/usr/bin/x11vnc -display :1 -nopw -forever -shared\n\
autorestart=true\n\
priority=200\n\
\n\
[program:novnc]\n\
command=websockify --web=/usr/share/novnc %(ENV_NOVNC_PORT)s localhost:%(ENV_VNC_PORT)s\n\
autorestart=true\n\
priority=300\n\
\n\
[program:xfce4]\n\
command=/usr/bin/startxfce4\n\
environment=DISPLAY=:1\n\
autorestart=true\n\
priority=400\n\
user=minecraft" > /etc/supervisor/conf.d/supervisord.conf

# เปิด port NoVNC
EXPOSE 8080

RUN mkdir -p /home/minecraft/.config/xfce4/xfconf/xfce-perchannel-xml && \
    echo '<?xml version="1.0" encoding="UTF-8"?>\n\
<channel name="xfce4-session" version="1.0">\n\
  <property name="general" type="empty">\n\
    <property name="LockCommand" type="string" value=""/>\n\
  </property>\n\
</channel>' > /home/minecraft/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml && \
    chown -R minecraft:minecraft /home/minecraft/.config
    
# เริ่ม supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]