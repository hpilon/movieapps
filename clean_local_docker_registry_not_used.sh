#!/bin/bash
# troubleshooting section
set -o xtrace

echo "Cleaning up unused Docker images..."

docker images

# Remove dangling images (those without a tag)
echo "Removing dangling images..."
docker image prune -f

# Remove all unused images (those not associated with a running container)
echo "Removing all unused images..."
docker images --quiet --filter "dangling=false" | while read -r image_id; do
    # Check if the image is used by a running container
    if ! docker ps --all --quiet --filter "ancestor=$image_id" | grep .; then
        echo "Removing image: $image_id"
        docker rmi -f "$image_id"
    else
        echo "Skipping in-use image: $image_id"
    fi
done

echo "Docker cleanup complete."

docker images
