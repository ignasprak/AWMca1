from django.contrib.auth import get_user_model
from django.db import models
from django.contrib.gis.db import models as gis_models
from django.db.models.signals import post_save
from django.dispatch import receiver


class User(models.Model):
    username = models.CharField(max_length=20)
    email = models.EmailField(max_length=30)
    password = models.CharField(max_length=15)

    def __str__(self):
        return str(self.username)


class Profile(models.Model):
    user = models.OneToOneField(
        get_user_model(),
        on_delete=models.PROTECT,
        primary_key=True,
    )
    lat = models.FloatField(null=True)
    lon = models.FloatField(null=True)
    description = models.TextField(blank=True, null=True)
    location = gis_models.PointField(null=True)
    last_updated = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{str(self.lon)}, {str(self.lat)}"


@receiver(post_save, sender=get_user_model())
def manage_user_profile(sender, instance, created, **kwargs):
    try:
        my_profile = instance.profile
        my_profile.save()
    except Profile.DoesNotExist:
        Profile.objects.create(user=instance, lon=10, lat=10)


class Landmark(models.Model):
    latitude = models.FloatField()
    longitude = models.FloatField()
    description = models.TextField(blank=True, null=True)
    location = gis_models.PointField(null=True)

    def __str__(self):
        return f"Landmark {self.description} ({self.latitude}, {self.longitude})"
