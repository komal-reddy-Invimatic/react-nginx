#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <branch_name> <image_name> <container_name>"
    exit 1
fi

BRANCH_NAME=$1
IMAGE_NAME=$2
CONTAINER_NAME=$3

# Step 1: Remove uncommitted changes
echo "Removing uncommitted changes..."
git reset --hard HEAD
if [ $? -ne 0 ]; then
    echo "Failed to reset git. Exiting."
    exit 1
fi

# Step 2: Fetch and checkout the specified branch
echo "Checking out branch: $BRANCH_NAME..."
git checkout $BRANCH_NAME
if [ $? -ne 0 ]; then
    echo "Failed to checkout branch. Exiting."
    exit 1
fi

echo "Pulling latest changes from $BRANCH_NAME..."
git pull origin $BRANCH_NAME
if [ $? -ne 0 ]; then
    echo "Failed to pull latest changes. Exiting."
    exit 1
fi

# Step 3: Build the Docker image
echo "Building Docker image: $IMAGE_NAME..."
docker build -t $IMAGE_NAME .
if [ $? -ne 0 ]; then
    echo "Failed to build Docker image. Exiting."
    exit 1
fi

# Step 4: Stop and remove any existing container with the same name
echo "Stopping and removing existing container: $CONTAINER_NAME..."
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null

# Step 5: Start the Docker container
echo "Starting Docker container: $CONTAINER_NAME..."
docker run -d --name $CONTAINER_NAME -p 3000:3000 $IMAGE_NAME
if [ $? -ne 0 ]; then
    echo "Failed to start Docker container. Exiting."
    exit 1
fi

echo "Deployment completed successfully!"
