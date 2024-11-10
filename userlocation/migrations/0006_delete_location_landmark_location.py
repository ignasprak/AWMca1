# Generated by Django 4.2.5 on 2023-11-08 01:12

import django.contrib.gis.db.models.fields
from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ("userlocation", "0005_rename_landmarks_landmark"),
    ]

    operations = [
        migrations.DeleteModel(
            name="Location",
        ),
        migrations.AddField(
            model_name="landmark",
            name="location",
            field=django.contrib.gis.db.models.fields.PointField(null=True, srid=4326),
        ),
    ]