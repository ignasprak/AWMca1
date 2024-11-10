# from django.contrib import admin
from django.contrib.gis import admin
from .models import User, Profile, Landmark

admin.site.register(User)
admin.site.register(Profile)
admin.site.register(Landmark, admin.ModelAdmin)