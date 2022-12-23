from django.db import models
from django.contrib.auth.models import AbstractUser

# Create your models here.
class Shopper(AbstractUser):
    age = models.DateField(null=True, blank=True)
    phone = models.CharField(max_length=12)
    market_id = models.IntegerField(null=False, blank=False)
