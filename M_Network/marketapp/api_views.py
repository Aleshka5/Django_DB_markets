from .models import Products, Shopper
from .serializers import ProductSerializer, ClientSerializer
from rest_framework import viewsets

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Products.objects.all()
    serializer_class = ProductSerializer

class ClientViewSet(viewsets.ModelViewSet):
    queryset = Shopper.objects.all()
    serializer_class = ClientSerializer