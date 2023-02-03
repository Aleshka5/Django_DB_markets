from django.conf.urls import url, include
from django.contrib.auth.models import User
from rest_framework import routers, serializers, viewsets
from .models import Products, Shopper, Markets_prods, Markets

class ProductSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Products
        fields = '__all__'

class ClientSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Shopper
        fields = '__all__'

class MarketProdsSerializer(serializers.HyperlinkedModelSerializer):
    market_id = serializers.StringRelatedField()
    prod_id = serializers.StringRelatedField()
    class Meta:
        model = Markets_prods
        #exclude = ('market_id',)
        fields = '__all__'