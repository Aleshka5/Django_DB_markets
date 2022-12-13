from django.core.management.base import BaseCommand
from marketapp.models import Clients,Managers,Top_managers,Reps,Markets,Products,Reps_prods,Markets_prods,Clients_prods,Clients_orders,Orders_prods
from usersapp.models import Shopper
from M_Network import settings
import psycopg2
class Command(BaseCommand):
    def handle(self,*args,**options):
        Shopper.objects.all().delete()
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
        Managers.objects.create(zp=40000,pswrd='MN-123')
        Top_managers.objects.create(zp=70000,pswrd='TMN-123')
        # Главно-Дочерние Таблицы
        Reps.objects.create(top_manager_id = Top_managers.objects.first())
        Markets.objects.create(manager_id = Managers.objects.first(),id_rep = Reps.objects.first())
        Products.objects.create(product_name = 'PS4 Slim',price = 35000)
        Products.objects.create(product_name='PS5', price=70000)
        # Много ко многим
        Reps_prods.objects.create(rep_id = Reps.objects.first(), prod_id = Products.objects.get(product_name='PS5'), count = 4)
        Markets_prods.objects.create(market_id = Markets.objects.first(), prod_id = Products.objects.get(product_name='PS4 Slim'), count = 5)
        #Clients_orders.objects.create()
        #Orders_prods.objects.create()
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
                cursor.execute(
                    '''
                    CREATE OR REPLACE PROCEDURE client_buy_own_shopping_cart_products(IN client_buy_id integer)
                     LANGUAGE plpgsql
                    AS $$
                    declare 
                    count_products_in_market int;
                    count_prods int;
                    cur_prod_id int;
                    buy_market_id int;
                    buy_client_id int;
                    last_order_id int;
                    prod int;
                    count_prod int;
                    begin
                    
                    -- Проверка
                    for count_prods, cur_prod_id in select count,product_id_id from marketapp_clients_prods where client_id_id = client_buy_id
                    loop 
                        count_products_in_market = count from marketapp_markets_prods where prod_id_id = cur_prod_id;
                        if count_prods > count_products_in_market then
                            raise exception 'There is no product available in the store. In market: ""%"" < Cilent query: ""%""', count_products_in_market,count_prods;
                            return;
                        end if;
                    end loop;
                    
                    -- Покупка
                    update marketapp_clients_prods set pay = 1 where client_id_id = client_buy_id;
--#########################################################################--
                    buy_market_id = market_id_id from marketapp_clients_prods where pay = 1 limit 1;
                    buy_client_id = client_id_id from marketapp_clients_prods where pay = 1 limit 1;
                    --Уменьшение товара
                    for prod, count_prod in 
                        select product_id_id, count from marketapp_clients_prods where pay = 1
                    loop
                        update marketapp_markets_prods set count = count - count_prod where market_id_id = buy_market_id and prod_id_id = prod;
                    end loop;
                    --Создание заказа
                    insert into marketapp_clients_orders (client_id_id,order_info) values (buy_client_id,'In Progress');
                    last_order_id = max(id) from marketapp_clients_orders;
                    --Добавление продуктов в заказ
                    insert into marketapp_orders_prods (order_id_id,prod_id_id,count) select last_order_id as o_id,product_id_id as p_id,count as c from marketapp_clients_prods where pay = 1;
                    --Удаление из корзины
                    delete from marketapp_clients_prods where pay = 1;
                    end;
                    $$
                '''
                )
                #print(cursor.fetchone())
        except Exception as _ex:
            print('Error while working with PostgreSQL',_ex)
        finally:
            if connection:
                connection.close()
                print('Connection closed')