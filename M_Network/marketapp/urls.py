from django.urls import path
from marketapp import views

app_name = 'marketapp'

urlpatterns = [
    path('',views.main_view, name = 'index'),
    path('cart/', views.cart, name = 'shopping_cart'),
    path('product/<int:id>', views.product, name = 'product')
]