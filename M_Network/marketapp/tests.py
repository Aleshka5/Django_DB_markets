from django.test import TestCase
from .models import Clients_prods, Products
from usersapp.models import Shopper
from faker import Faker
from mixer.backend.django import mixer
# Create your tests here.

class ShopperTestCaseMixer(TestCase):
    def setUp(self):
        faker = Faker()
        self.shopper = mixer.blend(Shopper)

class Clients_prodsTestCaseMixer(TestCase):
    def setUp(self):
        self.shopper = mixer.blend(Shopper,id = 1)
        self.product = mixer.blend(Products, id = 2)
        self.clients_prods = mixer.blend(Clients_prods, client_id = self.shopper, product_id = self.product)

    def test_chnage(self):

        self.assertTrue(self.clients_prods.change(2, 1, 2) == 2)
        self.assertTrue(self.clients_prods.change(0, 1, 2) == 1)
        self.assertTrue(self.clients_prods.change(-1, 1, 2) == 0)
