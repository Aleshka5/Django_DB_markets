from django.contrib.auth.forms import UserCreationForm
from .models import Shopper

class RegistrationForm(UserCreationForm):
    class Meta():
        model = Shopper
        fields = ('username','first_name','last_name','phone','market_id')