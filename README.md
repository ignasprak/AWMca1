# Geo-Django CA Landmark Discoverer

A basic landmark locations map application.

Website: 
https://ignasprak-geodjango.site

Username:
ignasprak

Password:
ignasprak@gmail.com

# How to deploy

docker network:
```bash
docker network create geodjango_assignment_network
```

Create Postgres GIS database container in docker:
```bash
docker create --name geodjango_assignment_postgis --network geodjango_assignment_network --network-alias geodjango-assignment-postgis -t -v geodjango_assignment_postgis_data:/var/lib/postgresql -e 'POSTGRES_USER=c20424992' -e 'POSTGRES_PASS=c20424992' kartoza/postgis
```

Create PGAdmin4 database frontend management system container in docker:
```bash
docker create --name geodjango_assignment_pgadmin4 --network geodjango_assignment_network --network-alias geodjango-assignment-pgadmin4 -t -v geodjango_assignment_pgadmin_data:/var/lib/pgadmin -e 'PGADMIN_DEFAULT_EMAIL=YOURNAME@tudublin.ie' -p 20080:80 -e 'PGADMIN_DEFAULT_PASSWORD=YOURPASSWORD' dpage/pgadmin4
```

Create the app image:
```bash
docker build -t geodjango_assignment .
```

Create the Django application container from the image:
```bash
docker create --name geodjango_assignment --network geodjango_assignment_network --network-alias geodjango_assignment -t -p 8001:8001 hunthawk11/geodjango_assignment:latest
```

Create the certbot docker image:
```bash
cd certbot
docker build -t geodjango_assignment_nginx_certbot .
```

Create the nginx server and certbot container from my image container:
```bash
docker create --name geodjango_assignment_nginx_certbot --network geodjango_assignment_network --network-alias geodjango-assignment-nginx-certbot -p 80:80 -p 443:443 -t -v geodjango_assignment_web_data:/usr/share/nginx/html -v $HOME/geodjango_assignment_nginx_certbot/conf:/etc/nginx/conf.d -v /etc/letsencrypt:/etc/letsencrypt -v /var/www/certbot -v html_data:/usr/share/nginx/html/static hunthawk11/geodjango_assignment_nginx_certbot:v1
```

Test Nginx and setup the SSL cert with certbot inside the container:
```bash
docker exec -it geodjango_assignment_nginx_certbot /bin/bash
nginx
nginx -s reload
nginx -t 
certbot certonly --nginx
```

Start the containers in order:
```bash
docker start geodjango_assignment_postgis
docker start geodjango_assignment_pgadmin4
docker start geodjango_assignment
docker start geodjango_assignment_nginx_certbot
```

Run the migrations:
```bash
docker exec geodjango_assignment bash -c "conda run -n geodjango_assignment python manage.py migrate"
```

Import the map locations data:
```bash
docker exec geodjango_assignment bash -c "conda run -n geodjango_assignment python manage.py import_landmarks"
```

Create a superuser to be able to setup users etc. :
```bash
docker exec -it geodjango_assignment bash
python manage.py createsuperuser
```


