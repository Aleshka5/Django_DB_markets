from django.core.management.base import BaseCommand
from marketapp.models import Clients,Managers,Top_managers,Reps,Markets,Products,Reps_prods,Markets_prods,Clients_prods,Clients_orders,Orders_prods
import psycopg2
class Command(BaseCommand):
    def handle(self,*args,**options):
        Clients.objects.all().delete()
        Managers.objects.all().delete()
        Top_managers.objects.all().delete()
        Reps.objects.all().delete()
        Products.objects.all().delete()
        Reps_prods.objects.all().delete()
        Markets_prods.objects.all().delete()
        Clients_prods.objects.all().delete()
        #Clients_orders.objects.all().delete()
        #Orders_prods.objects.all().delete()

        # Главные таблицы
        Clients.objects.create(id = 1, f='Ivanov',i='Ivan',o='Ivanovich',age='2000-03-05',phone='89138472233',pswrd='2468')
        Managers.objects.create(id = 1, zp=40000,pswrd='MN-123')
        Top_managers.objects.create(id = 1, zp=70000,pswrd='TMN-123')
        # Главно-Дочерние Таблицы
        Reps.objects.create(id = 1, top_manager_id = Top_managers.objects.get(id = 1))
        Markets.objects.create(id = 1, manager_id = Managers.objects.get(id = 1),id_rep = Reps.objects.get(id = 1))
        Products.objects.create(id = 1, product_name = 'PS4 Slim',price = 35000)
        Products.objects.create(id = 2, product_name='PS5', price=70000)
        # Много ко многим
        Reps_prods.objects.create(rep_id = Reps.objects.get(id = 1), prod_id = Products.objects.get(id = 1), count = 4)
        Markets_prods.objects.create(market_id = Markets.objects.get(id = 1), prod_id = Products.objects.get(id = 2), count = 5)
        Clients_prods.objects.create(client_id = Clients.objects.get(id = 1), product_id = Products.objects.get(id = 2), market_id = Markets.objects.get(id = 1), pay = 0, count = 1)
        #Clients_orders.objects.create()
        #Orders_prods.objects.create()

        return None
        try:
            connection = psycopg2.connect(
                host ='containers',
                user ='postgres',
                password ='xhY0PtShlwJ64lNzN5zl',
                database ='railway',
                port = '5804'
            )
            connection.autocommit = True
            with connection.cursor() as cursor:
                cursor.execute(
                    '''
                    CREATE OR REPLACE FUNCTION foo(in a int,in b int) returns int as
                    $$
                    BEGIN
                    RETURN a+b;
                    END;
                    $$ language plpgsql;
                    '''
                )
                #cursor.execute(
                #    '''
                #    INSERT INTO marketapp_products (product_name,price) values
                #    ('Iphone 12',199999),
                #    ('PS4',30000),
                #    ('PS5',70000);'''
                #)
                #print(cursor.fetchone())
        except Exception as _ex:
            print('Error while working with PostgreSQL',_ex)
        finally:
            if connection:
                connection.close()
                print('Connection closed')