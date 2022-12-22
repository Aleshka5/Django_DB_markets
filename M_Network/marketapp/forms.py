from django import forms
from .models import Clients, Markets_prods

class RegForm(forms.ModelForm):
    last_name = forms.CharField(label='Фамилия')
    first_name = forms.CharField(label='Имя')
    phone = forms.CharField(label='Номер телефона')
    market_id = forms.CharField(label='Ближайший магазин')
    class Meta:
        model = Clients
        #fields = '__all__'
        exclude = ('age',)

class Add_form(forms.Form):
    prod_id = forms.IntegerField(label='Индекс нового товара')
    count = forms.IntegerField(label='Количество товара')

class Form_buy(forms.Form):
    count = forms.IntegerField(label='Количество')

class Form_change(forms.Form):
    count = forms.IntegerField(label='Изменить количество')