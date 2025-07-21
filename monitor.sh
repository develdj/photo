#!/bin/bash

# Monitor GPU usage
nvidia-smi dmon -s mu -c 1

# Monitor container stats
docker stats --no-stream rapidraw-comfyui

# Check memory usage
free -h

# Monitor processes
docker exec rapidraw-comfyui ps aux --sort=-%mem | head -10
