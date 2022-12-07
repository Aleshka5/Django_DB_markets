from django import forms
from .models import Clients

class RegForm(forms.ModelForm):
    f = forms.CharField(label='Фамилия')
    i = forms.CharField(label='Имя')
    o = forms.CharField(label='Отчество')
    phone = forms.CharField(label='Номер телефона')
    pswrd = forms.CharField(label='Пароль')
    class Meta:
        model = Clients
        #fields = '__all__'
        exclude = ('age',)