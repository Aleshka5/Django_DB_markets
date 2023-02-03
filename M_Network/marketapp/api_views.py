from .models import Products, Shopper, Markets_prods
from .serializers import ProductSerializer, ClientSerializer, MarketProdsSerializer
from rest_framework import viewsets
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.authentication import BasicAuthentication, SessionAuthentication, TokenAuthentication
from .permissions import ReadOnly, AdminReadOnly

class ProductViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAdminUser|ReadOnly]
    queryset = Products.objects.all()
    serializer_class = ProductSerializer

class ClientViewSet(viewsets.ModelViewSet):
    permission_classes = [AdminReadOnly]
    queryset = Shopper.objects.all()
    serializer_class = ClientSerializer

class MarketsProdsViewSet(viewsets.ModelViewSet):
    authentication_classes = [SessionAuthentication, BasicAuthentication, TokenAuthentication]
    permission_classes = [IsAdminUser|ReadOnly]
    queryset = Markets_prods.objects.prefetch_related('prod_id')
    serializer_class = MarketProdsSerializer