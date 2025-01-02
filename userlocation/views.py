from django.http import JsonResponse
from django.contrib.auth.decorators import login_required
from django.contrib.gis.geos import Point
from . import models
from django.shortcuts import render
from django.apps import apps

from .models import Profile


@login_required
def update_location(request):
    try:
        user_profile = models.Profile.objects.get(user=request.user)
        if not user_profile:
            raise ValueError("Can't get User details")

        point = request.POST["point"].split(",")
        description = request.POST["description"]
        lon_lat = [float(part) for part in point]
        lon, lat = lon_lat
        map_point = Point(lon_lat, srid=4326)

        user_profile.lon = lon
        user_profile.lat = lat
        user_profile.location = map_point
        user_profile.description = f"Your current favourite landmark is {description}"
        user_profile.save()
        return JsonResponse({"message": f"Set location to lat: {lat}, lon: {lon}."}, status=200)
    except Exception as e:
        return JsonResponse({"message": str(e)}, status=400)

@login_required
def map_view(request):
    # lazy import to avoid circular import
    user_profile = Profile.objects.get(user=request.user)
    landmark_model = apps.get_model("userlocation", "Landmark")
    landmarks = landmark_model.objects.all()
    return render(request, "map.html", {"landmarks": landmarks, 
                                        "favourite_mark": user_profile.description, 
                                        "last_updated": user_profile.last_updated
                                        })