from django.db import models
from django.contrib.auth.models import AbstractUser
from django.db.models.signals import post_save
from django.dispatch import receiver

# Create your models here.
class Shopper(AbstractUser):
    age = models.DateField(null=True, blank=True)
    phone = models.CharField(max_length=12,null=True, blank=True)
    market_id = models.IntegerField()

    #def save(self, *args, **kwargs):
    #    user = super().save(*args,**kwargs)
    #    if user is None:
    #    #if not Profile.objects.filter(user=user).exists():
    #        Profile.objects.create(user=user)
    #    return user

class Profile(models.Model):
    delivery_enable = models.BooleanField(default=False)
    user = models.OneToOneField(Shopper,on_delete=models.CASCADE,blank=True)
    address = models.CharField(max_length=150,null=True,blank=True)

@receiver(post_save,sender=Shopper)
def create_profile(sender,instance,**kwargs):
    print('Создан новый профиль')
    if not Profile.objects.filter(user=instance).exists():
        Profile.objects.create(user=instance)