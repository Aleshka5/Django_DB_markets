from django.urls import path
from marketapp import views

app_name = 'marketapp'

urlpatterns = [
    path('',views.main_view, name = 'index'),
    path('singin/', views.reg, name = 'signIn'),
    path('product/<int:id>', views.product, name = 'product'),
    path('product_buy/<int:product_id><int:market_id>', views.product_buy, name = 'product_buy'),
    path('shopping_cart/', views.shopping_cart, name = 'cart'),
    path('shopping_cart_change/<int:product_id>', views.change_cart, name = 'change_cart'),
    path('add_product/', views.add_product, name = 'add_prod'),
    path('orders/', views.client_orders, name = 'orders'),
    path('orders_for_manager/', views.market_orders, name = 'm_orders'),
    path('profile/', views.profile_view, name = 'profile'),
    path('buy_delivery/', views.by_with_delivery, name = 'delivery'),
    path('updatetoken/',views.update_token, name='update_token'),
]