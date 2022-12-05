from django.db import models

# Create your models here.
from django.db import models

# Create your models here.
class Clients(models.Model):
    f = models.CharField(max_length=50)
    i = models.CharField(max_length=50)
    o = models.CharField(max_length=50)
    age = models.DateField()
    phone = models.CharField(max_length=12)
    pswrd = models.CharField(max_length=30)
    def __str__(self):
        return (self.f+' '+self.i+' '+self.o)

class Managers(models.Model):
    zp = models.IntegerField()
    pswrd = models.CharField(max_length=30)

class Top_managers(models.Model):
    zp = models.IntegerField()
    pswrd = models.CharField(max_length=30)

class Reps(models.Model):
    top_manager_id = models.ForeignKey(Top_managers, on_delete=models.CASCADE)

class Markets(models.Model):
    manager_id = models.ForeignKey(Managers, on_delete=models.CASCADE)
    id_rep = models.ForeignKey(Reps, on_delete=models.CASCADE)

class Products(models.Model):
    product_name = models.CharField(max_length=40)
    price = models.FloatField()
    def __str__(self):
        return self.product_name

class Reps_prods(models.Model):
    rep_id = models.ForeignKey(Reps, on_delete=models.CASCADE)
    prod_id = models.ForeignKey(Products, on_delete=models.CASCADE)
    count = models.IntegerField()

class Markets_prods(models.Model):
    market_id = models.ForeignKey(Markets, on_delete=models.CASCADE)
    prod_id = models.ForeignKey(Products, on_delete=models.CASCADE)
    count = models.IntegerField()

class Clients_prods(models.Model):
    client_id = models.ForeignKey(Clients, on_delete=models.CASCADE)
    product_id = models.ForeignKey(Products, on_delete=models.CASCADE)
    market_id = models.ForeignKey(Markets, on_delete=models.CASCADE)
    pay = models.IntegerField()
    count = models.IntegerField()

class Clients_orders(models.Model):
    client_id = models.ForeignKey(Clients, on_delete=models.CASCADE)
    order_info = models.TextField()

class Orders_prods(models.Model):
    order_id = models.ForeignKey(Clients_orders, on_delete=models.CASCADE)
    prod_id = models.ForeignKey(Products, on_delete=models.CASCADE)
    count = models.IntegerField()