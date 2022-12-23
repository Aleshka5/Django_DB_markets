from django.test import Client
from django.test import TestCase
class OpenViewsTest(TestCase):

    def setUp(self):
        self.client = Client()

    def test_open_views(self):
        response = self.client.get('/')
        self.assertEqual(response.status_code,200)

        response = self.client.get('/orders/')
        self.assertEqual(response.status_code, 200)

        response = self.client.post('/shopping_cart/')
        self.assertEqual(response.status_code, 302)
