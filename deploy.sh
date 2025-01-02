#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Create Docker network
 echo "Creating Docker network..."
 docker network create geodjango_assignment_network || true

# Create Postgres GIS database container
 echo "Creating Postgres GIS database container..."
 docker create --name geodjango_assignment_postgis --network geodjango_assignment_network --network-alias geodjango-assignment-postgis -t -v geodjango_assignment_postgis_data:/var/lib/postgresql -e 'POSTGRES_USER=c20424992' -e 'POSTGRES_PASS=c20424992' kartoza/postgis || true

# Create PGAdmin4 database frontend management system container
 echo "Creating PGAdmin4 database frontend management system container..."
 docker create --name geodjango_assignment_pgadmin4 --network geodjango_assignment_network --network-alias geodjango-assignment-pgadmin4 -t -v geodjango_assignment_pgadmin_data:/var/lib/pgadmin -e 'PGADMIN_DEFAULT_EMAIL=c20424992@tudublin.ie' -p 20080:80 -e 'PGADMIN_DEFAULT_PASSWORD=c20424992' dpage/pgadmin4 || true

# # Build the app image
# echo "Building the app image..."
# docker build -t hunthawk11/geodjango_assignment:latest .

# # Push the app image to Docker Hub
# echo "Pushing the app image to Docker Hub..."
# docker login --username hunthawk11
# docker push hunthawk11/geodjango_assignment:latest

# Check if the Django application container is running
if [ "$(docker ps -q -f name=geodjango_assignment)" ]; then
    echo "Stopping the running Django application container..."
    docker stop geodjango_assignment
fi

# Check if the Django application container exists
if [ "$(docker ps -aq -f name=geodjango_assignment)" ]; then
    echo "Removing the existing Django application container..."
    docker rm geodjango_assignment
fi

# Create the Django application container
echo "Creating the Django application container..."
docker create --name geodjango_assignment --network geodjango_assignment_network --network-alias geodjango_assignment -t -p 8001:8001 hunthawk11/geodjango_assignment:latest || true

# Check if the certbot and nginx server container is running
if [ "$(docker ps -q -f name=geodjango_assignment_nginx_certbot)" ]; then
    echo "Stopping the running certbot and nginx server container..."
    docker stop geodjango_assignment_nginx_certbot
fi

# Check if the certbot and nginx server container exists
if [ "$(docker ps -aq -f name=geodjango_assignment_nginx_certbot)" ]; then
    echo "Removing the existing certbot and nginx server container..."
    docker rm geodjango_assignment_nginx_certbot
fi

# Create the certbot and nginx server container
echo "Creating the certbot and nginx server container..."
docker create --name geodjango_assignment_nginx_certbot \
    --network geodjango_assignment_network \
    --network-alias geodjango-assignment-nginx-certbot \
    -p 80:80 \
    -p 443:443 \
    -t \
    -v geodjango_assignment_web_data:/usr/share/nginx/html \
    -v $HOME/geodjango_assignment_nginx_certbot/conf:/etc/nginx/conf.d \
    -v $HOME/geodjango_assignment_nginx_certbot/letsencrypt:/etc/letsencrypt \
    -v $HOME/geodjango_assignment_nginx_certbot/certbot:/var/www/certbot \
    -v $HOME/geodjango_assignment_nginx_certbot/html_data:/usr/share/nginx/html/static \
    hunthawk11/geodjango_assignment_nginx_certbot:v1

# Wait for the container to initialize
sleep 5

# Execute commands inside the container
echo "Initializing Nginx in the container..."
docker exec geodjango_assignment_nginx_certbot nginx

echo "Reloading Nginx configuration..."
docker exec geodjango_assignment_nginx_certbot nginx -s reload

echo "Testing Nginx configuration..."
docker exec geodjango_assignment_nginx_certbot nginx -t

# Start the containers in order
echo "Starting the containers..."
docker start geodjango_assignment_postgis
docker start geodjango_assignment_pgadmin4
docker start geodjango_assignment_nginx_certbot
docker start geodjango_assignment

# Run the migrations
echo "Running migrations..."
docker exec geodjango_assignment bash -c "conda run -n geodjango_assignment python manage.py migrate"

# Import the map locations data
echo "Importing map locations data..."
docker exec geodjango_assignment bash -c "conda run -n geodjango_assignment python manage.py import_landmarks"

# Create a superuser
 echo "Creating a superuser..."
 docker exec -it geodjango_assignment bash -c "conda run -n geodjango_assignment python manage.py createsuperuser"

echo "Container creation completed successfully!"
