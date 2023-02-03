import requests
import pprint
token = '243d67720c00453b834f6a9aaf648e89583af613'
headers = {'Authorization':f'Token {token}'}
response = requests.get('http://127.0.0.1:8000/api/v0/markets_prods/', headers=headers)
pprint.pprint(response.json())