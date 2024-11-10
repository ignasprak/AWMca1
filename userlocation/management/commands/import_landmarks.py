import csv
from userlocation.models import Landmark
from django.core.management.base import BaseCommand
from django.contrib.gis.geos import Point

class Command(BaseCommand):
    help = 'Import landmark data from a landmarks.csv file'

    def handle(self, *args, **options):
        csv_file = "landmarks.csv"

        # delete all existing landmark data
        Landmark.objects.all().delete()

        with open(csv_file, 'r') as file:
            csv_reader = csv.DictReader(file)
            for row in csv_reader:
                latitude = float(row["lat"])
                longitude = float(row["lon"])
                description = row["description"]
                map_point = Point((longitude, latitude), srid=4326)

                landmark = Landmark(
                    latitude=latitude,
                    longitude=longitude,
                    description=description,
                    location = map_point
                )
                landmark.save()

        print("Successfully imported landmarks")
