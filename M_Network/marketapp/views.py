from django.shortcuts import render
from django.urls import reverse, reverse_lazy
from django.http import HttpResponseRedirect
from .forms import RegForm
from .models import Products
# Create your views here.
def main_view(request):
    prods = Products.objects.all()
    return render(request,'marketapp/index.html',context = {'products':prods})

def reg(request):
    print(f'Request Method: {request.method}')
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