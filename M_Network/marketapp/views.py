from django.shortcuts import render
from .models import Products
# Create your views here.
def main_view(request):
    prods = Products.objects.all()
    return render(request,'marketapp/index.html',context = {'products':prods})

def cart(request):
    return render(request,'marketapp/shopping_cart.html')

def product(request,id):
    product = Products.objects.get(id = id)
    return render(request,'marketapp/product.html',context = {'product_info':product})