from django.contrib import admin
from .models import *

# Register your models here.
admin.site.register(Clients)
admin.site.register(Managers)
admin.site.register(Top_managers)
admin.site.register(Reps)
admin.site.register(Markets)
admin.site.register(Products)
admin.site.register(Reps_prods)
admin.site.register(Markets_prods)
admin.site.register(Clients_prods)
admin.site.register(Clients_orders)
admin.site.register(Orders_prods)