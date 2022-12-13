import psycopg2
from django.shortcuts import render
from django.urls import reverse, reverse_lazy
from django.http import HttpResponseRedirect
from .forms import RegForm, Form_buy, Form_change
from .models import Products, Markets_prods, Clients_prods, Markets
from usersapp.models import Shopper
from M_Network import settings
# Create your views here.
def main_view(request):
    prods = Products.objects.all()
    market_prods = Markets_prods.objects.all()
    return render(request,'marketapp/index.html',context = {'products':prods,'markets':market_prods})

def reg(request):
    if request.method == 'POST':
        form = RegForm(request.POST)
        if form.is_valid():
            form.save()
            return HttpResponseRedirect(reverse('market:index'))
        else:
            print('Not valid data')
            return render(request, 'marketapp/signin.html', context={'form': form})
    else:
        form = RegForm()
        return render(request, 'marketapp/signin.html', context={'form': form})

def product(request,id):
    product = Products.objects.get(id = id)
    return render(request,'marketapp/product.html',context = {'product_info':product})

def product_buy(request,product_id,market_id):
    product = Products.objects.get(id=product_id)
    print(request.user.id)
    print(market_id)
    print(product_id)
    if request.method == 'POST':
        form = Form_buy(request.POST)
        if form.is_valid():
            count_duplicates = len(Clients_prods.objects.filter(client_id=request.user.id, product_id=product_id))
            if count_duplicates > 0:
                print('Нельзя создать две одинаковые позиции')
                return HttpResponseRedirect(reverse('market:index'))
            count = form.cleaned_data['count']
            Clients_prods.objects.create(pay=0,count=count,client_id=Shopper.objects.get(id=request.user.id),market_id=Markets.objects.get(id=market_id),product_id=Products.objects.get(id=product_id))
            return HttpResponseRedirect(reverse('market:index'))
        else:
            return render(request, 'marketapp/product_buy.html', context={'product_info': product, 'form': form})
    else:
        form = Form_buy(request.POST)
        return render(request,'marketapp/product_buy.html',context = {'product_info':product,'form':form})

def shopping_cart(request):
    products = Clients_prods.objects.filter(client_id=request.user.id)
    if request.method=='GET':
        return render(request, 'marketapp/shopping_cart.html', context={'own_cart': products})
    else:
        try:
            connection = psycopg2.connect(
                host =settings.db_host,
                user =settings.db_user,
                password =settings.db_pswrd,
                database =settings.db_name,
                port = settings.db_port
            )
            connection.autocommit = True
            with connection.cursor() as cursor:
                cursor.execute(f'call client_buy_own_shopping_cart_products({request.user.id})')
        except Exception as _ex:
            print('Error while working with PostgreSQL', _ex)
        finally:
            return HttpResponseRedirect(reverse('market:cart'))

def change_cart(request,product_id):
    product = Products.objects.get(id=product_id)
    cl = Clients_prods.objects.get(client_id=request.user.id, product_id=product_id)
    if request.method == 'POST':
        form = Form_change(request.POST)
        if form.is_valid():
            count = form.cleaned_data['count']
            if count == 0:
                client_product = Clients_prods.objects.get(client_id=request.user.id, product_id=product_id)
                client_product.delete()
            elif count > 0:
                client_product = Clients_prods.objects.get(client_id=request.user.id, product_id=product_id)
                client_product.count = count
                client_product.save()
            return HttpResponseRedirect(reverse('market:cart'))
        else:
            return render(request, 'marketapp/change.html', context={'product_info': product, 'form': form})
    else:
        form = Form_change(request.POST)
        return render(request, 'marketapp/change.html', context={'product_info': product,'count':cl.count, 'form': form})
