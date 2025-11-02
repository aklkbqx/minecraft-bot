# Minecraft Bot with noVNC

This project provides a containerized Minecraft bot environment with a graphical interface accessible through your web browser using noVNC.

minecraft-bot afk in server
`note: but this is gui to high RAM and CPU usage`
### `＊🖥️ recommend: CPU 4C 4T, RAM 6GB+`

## 🌟 Features

- Ubuntu-based container with XFCE4 desktop environment
- Remote access through VNC and noVNC (web-based)
- Pre-installed Minecraft dependencies
- Shared folder support
- Automatic restart capability
- Firefox browser included

## 🚀 Quick Start

### Prerequisites

- Docker
- Docker Compose

### Installation

1. Clone the repository:
```bash
git clone https://github.com/aklkbqx/minecraft-bot.git
cd minecraft-bot
```

2. Create a shared folder (if it doesn't exist):
```bash
mkdir -p shared
```

3. Start the container:
```bash
docker compose up -d
```

## 🔧 Configuration

### Default Ports
- noVNC Web Interface: `6080`
- VNC: `5900`

### Environment Variables

You can modify these variables in the `docker-compose.yml`:

- `RESOLUTION`: Screen resolution (default: 1600x900x24)
- `VNC_PORT`: VNC port (default: 5900)
- `NOVNC_PORT`: noVNC port (default: 8080)
- `MINECRAFT_SERVER`: Minecraft server address

## 📝 Usage

1. Access the desktop environment:
   - Open your web browser
   - Navigate to `http://localhost:6080`
   - You'll see the Ubuntu desktop environment

2. Shared Files:
   - Place files in the `shared` folder
   - Access them inside the container at `/home/ubuntu/shared`

## 🛠️ Project Structure

```
bot/
├── docker compose.yml    # Container orchestration
├── Dockerfile           # Container build instructions
├── supervisord.conf     # Process management configuration
└── shared/             # Shared folder between host and container
```

## ⚠️ Note

- The container runs with automatic restart unless stopped manually
- All changes outside the shared folder will be lost when the container is removed