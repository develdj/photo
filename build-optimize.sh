#!/bin/bash

# Build with optimization flags
docker buildx build \
  --platform linux/arm64 \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --cache-from type=registry,ref=your-registry/rapidraw-comfyui:cache \
  --cache-to type=registry,ref=your-registry/rapidraw-comfyui:cache,mode=max \
  -t rapidraw-comfyui:latest \
  -f Dockerfile.unified \
  .

# Prune build cache
docker builder prune -f

# Optimize images
docker image prune -f
