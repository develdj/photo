#!/bin/bash
set -e

# Configure Jetson for maximum performance
if [ -f /usr/bin/jetson_clocks ]; then
    echo "Setting Jetson to maximum performance mode..."
    nvpmodel -m 0 || true
    jetson_clocks || true
fi

# Start RapidRAW in background
echo "Starting RapidRAW..."
rapidraw --port $RAPIDRAW_PORT --gpu-only --cache-size 4096 &
RAPIDRAW_PID=$!

# Wait for RapidRAW to be ready
until curl -f http://localhost:$RAPIDRAW_PORT/health; do
    echo "Waiting for RapidRAW..."
    sleep 2
done

# Start ComfyUI
echo "Starting ComfyUI..."
cd /app/comfyui
python3 main.py \
    --listen 0.0.0.0 \
    --port $COMFYUI_PORT \
    --gpu-only \
    --highvram \
    --preview-method auto \
    --use-pytorch-cross-attention &
COMFYUI_PID=$!

# Function to handle shutdown
shutdown() {
    echo "Shutting down services..."
    kill $RAPIDRAW_PID $COMFYUI_PID 2>/dev/null || true
    exit 0
}

# Trap signals
trap shutdown SIGTERM SIGINT

# Wait for both processes
wait $RAPIDRAW_PID $COMFYUI_PID
