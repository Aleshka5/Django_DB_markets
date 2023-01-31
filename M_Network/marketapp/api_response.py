import requests
import pprint

response = requests.get('http://127.0.0.1:8000/api/v0/products/')
pprint.pprint(response.json())