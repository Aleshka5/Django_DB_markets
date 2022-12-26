from django.contrib.auth.views import LoginView,LogoutView
from django.views.generic import CreateView
from django.urls import reverse, reverse_lazy
from .forms import RegistrationForm
from .models import Shopper

# Create your views here.
class UserLoginView(LoginView):
    title = 'Вход'
    template_name = 'usersapp/login.html'

class UserCreateView(CreateView):
    model = Shopper
    template_name = 'usersapp/register.html'
    form_class = RegistrationForm
    success_url = reverse_lazy('users:login')

