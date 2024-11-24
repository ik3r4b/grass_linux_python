#!/bin/bash

# Define variables
HIDDEN_DIR="/opt/.hidden_service_grss"
SERVICE_NAME="systemgrss.service"
PYTHON_SCRIPT="grss_service.py"
SCRIPT_PATH="$(realpath "$0")"

# Create a hidden directory for the Python script
echo "Creating hidden directory at $HIDDEN_DIR..."
sudo mkdir -p "$HIDDEN_DIR"
sudo chown "$(whoami):$(whoami)" "$HIDDEN_DIR"

# Check if Python 3 is installed
if ! command -v python3 &>/dev/null; then
    echo "Python3 is not installed. Installing Python3..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip
else
    echo "Python3 is already installed."
fi

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install --upgrade --user pip
pip3 install --user loguru fake-useragent websockets

# Add the user's local bin directory to PATH
export PATH="$HOME/.local/bin:$PATH"

# Python code to be executed
cat > "$HIDDEN_DIR/$PYTHON_SCRIPT" << 'EOF'
import asyncio
import random
import ssl
import json
import time
import uuid
from loguru import logger
from fake_useragent import UserAgent
import websockets  # Import the standard websockets module

user_agent = UserAgent()
random_user_agent = user_agent.random

async def connect_to_wss(user_id):
    device_id = str(uuid.uuid4())  # Generate a unique device_id
    logger.info(f'Device ID: {device_id}')
    ssl_context = ssl.create_default_context()
    ssl_context.check_hostname = False
    ssl_context.verify_mode = ssl.CERT_NONE

    while True:
        try:
            await asyncio.sleep(random.uniform(0.1, 1.0))
            custom_headers = {"User-Agent": random_user_agent}
            uri = "wss://proxy.wynd.network:4650/"
            server_hostname = "proxy.wynd.network"

            async with websockets.connect(
                uri,
                ssl=ssl_context,
                server_hostname=server_hostname,
                extra_headers=custom_headers
            ) as websocket:
                async def send_ping():
                    while True:
                        send_message = json.dumps({
                            "id": str(uuid.uuid4()),
                            "version": "1.0.0",
                            "action": "PING",
                            "data": {}
                        })
                        logger.debug(f'Sending PING: {send_message}')
                        await websocket.send(send_message)
                        await asyncio.sleep(20)

                await asyncio.sleep(1)
                asyncio.create_task(send_ping())

                while True:
                    response = await websocket.recv()
                    message = json.loads(response)
                    logger.info(f'Received: {message}')
                    if message.get("action") == "AUTH":
                        auth_response = {
                            "id": message["id"],
                            "origin_action": "AUTH",
                            "result": {
                                "browser_id": device_id,
                                "user_id": user_id,
                                "user_agent": custom_headers['User-Agent'],
                                "timestamp": int(time.time()),
                                "device_type": "extension",
                                "version": "3.3.2"
                            }
                        }
                        logger.debug(f'Sending AUTH: {auth_response}')
                        await websocket.send(json.dumps(auth_response))

                    elif message.get("action") == "PONG":
                        pong_response = {
                            "id": message["id"],
                            "origin_action": "PONG"
                        }
                        logger.debug(f'Sending PONG: {pong_response}')
                        await websocket.send(json.dumps(pong_response))
        except Exception as e:
            logger.error(f'Error: {e}')
            await asyncio.sleep(5)  # Wait before attempting to reconnect

async def main():
    _user_id = '89f963fc-f72f-4a00-af43-cbb151c5a587'  # Replace with your obtained user_id
    await connect_to_wss(_user_id)

if __name__ == '__main__':
    asyncio.run(main())
EOF

echo "Python script created at $HIDDEN_DIR/$PYTHON_SCRIPT."

# Create systemd service file
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"

echo "Creating service file at $SERVICE_PATH..."
sudo bash -c "cat > $SERVICE_PATH" << EOF
[Unit]
Description=GRSS WebSocket Service
After=network.target

[Service]
ExecStart=/usr/bin/python3 $HIDDEN_DIR/$PYTHON_SCRIPT
Restart=always
User=$(whoami)
WorkingDirectory=$HIDDEN_DIR

[Install]
WantedBy=multi-user.target
EOF

# Reload daemon and enable the service
echo "Enabling the service $SERVICE_NAME..."
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

echo "Service $SERVICE_NAME has been created and is running."

# Self-destruction of the script
echo "Removing the installation script..."
rm -- "$SCRIPT_PATH"

echo "Installation complete. The installation script has been removed."
