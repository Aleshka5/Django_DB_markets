from rest_framework.authtoken.models import Token
from django.contrib.auth.views import LoginView,LogoutView
from django.views.generic import CreateView, DetailView
from django.urls import reverse, reverse_lazy
from django.http import HttpResponseRedirect
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

class ProfileView(DetailView):
    model = Shopper
    template_name = 'usersapp/profile_token.html'

def update_token(requests):
    user = requests.user
    if user.auth_token:
        user.auth_token.delete()
        Token.objects.create(users=user)
    else:
        Token.objects.create(users=user)
    return HttpResponseRedirect(reverse('users:profile'))

