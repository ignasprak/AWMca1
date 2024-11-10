# Geo-Django CA Landmark Finder Map

A landmark locations map application.

Website: 
https://ignutwork-django-assignment.site

Developmental Website:
http://localhost:8001/#


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
docker create --name geodjango_assignment --network geodjango_assignment_network --network-alias geodjango_assignment -t -p 8001:8001 geodjango_assignment
```

Start the containers in order:
```bash
docker start geodjango_assignment_postgis
docker start geodjango_assignment_pgadmin4
docker start geodjango_assignment
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


