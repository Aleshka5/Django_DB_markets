PGDMP         *            
    z            RZ_web    14.5    14.5 \    b           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            c           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            d           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            e           1262    24721    RZ_web    DATABASE     e   CREATE DATABASE "RZ_web" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Russian_Russia.1251';
    DROP DATABASE "RZ_web";
                postgres    false            �            1255    24981 G   client_add_product_to_shopping_cart(integer, integer, integer, integer) 	   PROCEDURE     i  CREATE PROCEDURE public.client_add_product_to_shopping_cart(IN client_add_id integer, IN market_add_id integer, IN product_add_id integer, IN count_products integer)
    LANGUAGE plpgsql
    AS $$
declare 
current_count int;
begin
current_count = count(*) from clients_prods where prod_id = product_add_id;
if current_count > 0 then
	update clients_prods as cp set count = count + count_products where cp.client_id = client_add_id and cp.prod_id = product_add_id;
else
	insert into clients_prods (client_id,market_id,prod_id,count) values (client_add_id,market_add_id,product_add_id,count_products);
end if;
end;
$$;
 �   DROP PROCEDURE public.client_add_product_to_shopping_cart(IN client_add_id integer, IN market_add_id integer, IN product_add_id integer, IN count_products integer);
       public          postgres    false            �            1255    24989 .   client_buy_own_shopping_cart_products(integer) 	   PROCEDURE     �  CREATE PROCEDURE public.client_buy_own_shopping_cart_products(IN client_buy_id integer)
    LANGUAGE plpgsql
    AS $$
declare 
count_products_in_market int;
count_prods int;
cur_prod_id int;
begin

-- Проверка
for count_prods, cur_prod_id in select count,prod_id from clients_prods where client_id = client_buy_id
loop 
	count_products_in_market = count from markets_prods where prod_id = cur_prod_id;
	if count_prods > count_products_in_market then
		raise exception 'There is no product available in the store. In market: "%" < Cilent query: "%"', count_products_in_market,count_prods;
		return;
	end if;
end loop;

-- Покупка
update clients_prods set pay = 1 where client_id = client_buy_id;
end;
$$;
 W   DROP PROCEDURE public.client_buy_own_shopping_cart_products(IN client_buy_id integer);
       public          postgres    false            �            1255    24978 C   client_delete_product_from_cart(integer, integer, boolean, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.client_delete_product_from_cart(IN client_id_del integer, IN product_id_del integer, IN is_delete boolean, IN count_del integer DEFAULT 1)
    LANGUAGE plpgsql
    AS $$
declare
x int;
begin
x = max(count) from clients_prods as cp where client_id = client_id_del and prod_id = product_id_del;	

if count_del >= x then
	is_delete = True;
end if;

if is_delete then
	delete from clients_prods as cp where client_id = client_id_del and prod_id = product_id_del;	
	return;
else
	update clients_prods as cp set count = count - count_del where cp.client_id = client_id_del and cp.prod_id = product_id_del;
	return;
end if;
end;
$$;
 �   DROP PROCEDURE public.client_delete_product_from_cart(IN client_id_del integer, IN product_id_del integer, IN is_delete boolean, IN count_del integer);
       public          postgres    false            �            1255    24994 @   manager_edit_market_products(integer, integer, integer, boolean) 	   PROCEDURE     �  CREATE PROCEDURE public.manager_edit_market_products(IN market_add_id integer, IN product_add_id integer, IN new_count_product integer DEFAULT 0, IN is_delete boolean DEFAULT false)
    LANGUAGE plpgsql
    AS $$
declare
count_cur_prod int;
begin
count_cur_prod = count from markets_prods where prod_id = product_add_id and market_id = market_add_id;
--Удаление
if is_delete then
	delete from markets_prods where prod_id = product_add_id and market_id = market_add_id;
	return;
--Добавление/Изменение
elsif new_count_product >= 0 then
	if count_cur_prod > 0 then
		update markets_prods set count = new_count_product where prod_id = product_add_id and market_id = market_add_id; 
	else
		insert into markets_prods (market_id,prod_id,count) values (market_add_id,product_add_id,new_count_product);
	end if;
--Ошибка	
else
	raise exception 'Error: count products less then zero';
	
end if;
end;
$$;
 �   DROP PROCEDURE public.manager_edit_market_products(IN market_add_id integer, IN product_add_id integer, IN new_count_product integer, IN is_delete boolean);
       public          postgres    false            �            1255    25003    order_sum(integer)    FUNCTION     �   CREATE FUNCTION public.order_sum(client_cart_id integer) RETURNS numeric
    LANGUAGE sql
    AS $$
select sum(price) as summ 
from clients_prods as cp join products as pr on cp.prod_id = pr.id where cp.client_id = client_cart_id
$$;
 8   DROP FUNCTION public.order_sum(client_cart_id integer);
       public          postgres    false            �            1255    25005 5   part_of_products_in_market(integer, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.part_of_products_in_market(market_id integer, low_price numeric DEFAULT 0, high_price numeric DEFAULT 0) RETURNS TABLE(product_name character varying, product_price numeric, count integer)
    LANGUAGE plpgsql
    AS $$
begin
if low_price = 0 and high_price = 0 then
	return query select pr.product_name, pr.price, mp.count
	from markets_prods as mp join products as pr 
	on mp.prod_id = pr.id;
	return;
elsif low_price = 0 then
	return query select pr.product_name, pr.price, mp.count
	from markets_prods as mp join products as pr 
	on mp.prod_id = pr.id 
	where price <= high_price;
	return;
elsif high_price = 0 then
	return query select pr.product_name, pr.price, mp.count
	from markets_prods as mp join products as pr 
	on mp.prod_id = pr.id 
	where price > low_price;
	return;
else
	return query select pr.product_name, pr.price, mp.count
	from markets_prods as mp join products as pr 
	on mp.prod_id = pr.id 
	where price between low_price and high_price;
end if;
end;
$$;
 k   DROP FUNCTION public.part_of_products_in_market(market_id integer, low_price numeric, high_price numeric);
       public          postgres    false            �            1255    25037    rank_managers()    FUNCTION     0  CREATE FUNCTION public.rank_managers() RETURNS TABLE(id_manager integer, salary numeric, rank integer)
    LANGUAGE sql
    AS $$
select  mn.id,
		zp,
		rank() over(partition by rep_id order by zp desc)
from managers mn 
	join markets mk 
on mn.id = mk.manager_id
	join reps rp
on mk.rep_id = rp.id;
$$;
 &   DROP FUNCTION public.rank_managers();
       public          postgres    false            �            1255    24996 P   top_manager_edit_products(integer, character varying, numeric, boolean, boolean) 	   PROCEDURE     +  CREATE PROCEDURE public.top_manager_edit_products(IN product_edit_id integer, IN product_new_name character varying, IN price_prod numeric, IN is_insert boolean DEFAULT false, IN is_delete boolean DEFAULT false)
    LANGUAGE plpgsql
    AS $$
declare
last_id int;
begin
last_id = max(id) from products;
--Удаление
if is_delete and product_edit_id <= last_id then
	delete from products where id = product_edit_id;	
	return;
--Добавление
elsif is_insert then	 
	insert into products (product_name,price) values (product_new_name,price_prod);
	return;
--Изменение
elsif product_edit_id <= last_id and price_prod >= 0 then	
	if product_new_name = '' then
		update products set price = price_prod where id = product_edit_id;
	elsif price_prod = 0 then
		update products set product_name = product_new_name where id = product_edit_id;
	--Ошибка Изменения
	else
		raise exception 'Error: Your changes are incorrect ';
	end if;
--Ошибка	
else
	raise exception 'Error: index out of range or price incorrect';
	
end if;
end;
$$;
 �   DROP PROCEDURE public.top_manager_edit_products(IN product_edit_id integer, IN product_new_name character varying, IN price_prod numeric, IN is_insert boolean, IN is_delete boolean);
       public          postgres    false            �            1255    24995 A   top_manager_edit_rep_products(integer, integer, integer, boolean) 	   PROCEDURE     �  CREATE PROCEDURE public.top_manager_edit_rep_products(IN rep_edid_id integer, IN product_edit_id integer, IN new_count_product integer DEFAULT 0, IN is_delete boolean DEFAULT false)
    LANGUAGE plpgsql
    AS $$
declare
count_cur_prod int;
begin
count_cur_prod = count from reps_prods where prod_id = product_edit_id and rep_id = rep_edid_id;
--Удаление
if is_delete then
	delete from reps_prods where prod_id = product_edit_id and rep_id = rep_edid_id;
	return;
--Добавление/Изменение
elsif new_count_product >= 0 then
	if count_cur_prod > 0 then
		update reps_prods set count = new_count_product where prod_id = product_edit_id and rep_id = rep_edid_id; 
	else
		insert into reps_prods (rep_id,prod_id,count) values (rep_edid_id,product_edit_id,new_count_product);
	end if;
--Ошибка	
else
	raise exception 'Error: count products less then zero';
	
end if;
end;
$$;
 �   DROP PROCEDURE public.top_manager_edit_rep_products(IN rep_edid_id integer, IN product_edit_id integer, IN new_count_product integer, IN is_delete boolean);
       public          postgres    false            �            1255    25016    trigger_buy()    FUNCTION     �  CREATE FUNCTION public.trigger_buy() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
buy_market_id int;
buy_client_id int;
last_order_id int;
prod int;
count_prod int;
begin
buy_market_id = market_id from clients_prods where pay = 1 limit 1;
buy_client_id = client_id from clients_prods where pay = 1 limit 1;
--Уменьшение товара
for prod, count_prod in 
	select prod_id, count from clients_prods where pay = 1
loop
	update markets_prods set count = count - count_prod where market_id = buy_market_id and prod_id = prod;
end loop;
--Создание заказа
insert into clients_orders (client_id) values (buy_client_id);
last_order_id = max(order_id) from clients_orders;
--Добавление продуктов в заказ
insert into orders_prods (order_id,prod_id,count) select last_order_id as o_id,prod_id as p_id,count as c from clients_prods where pay = 1;
--Удаление из корзины
delete from clients_prods where pay = 1;
return NEW;
end;
$$;
 $   DROP FUNCTION public.trigger_buy();
       public          postgres    false            �            1255    25023    trigger_empty_slots()    FUNCTION     �  CREATE FUNCTION public.trigger_empty_slots() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
rep_for_take_products_id int;
market_with_empty_slots_id int;
min_count_prods int;
count_product_on_rep int;
empty_prod_id int;
begin
min_count_prods = min(count) from markets_prods;
--Если есть отсутсвуюищие продукты
if min_count_prods = 0 then
	market_with_empty_slots_id = market_id from markets_prods where count = 0 limit 1;
	rep_for_take_products_id = rep_id from markets where id = market_with_empty_slots_id;
	--Пополняем каждый
	for empty_prod_id in
 		select prod_id from markets_prods where count = 0
	loop
		count_product_on_rep = count from reps_prods where rep_id = rep_for_take_products_id and prod_id = empty_prod_id;
		if count_product_on_rep between 1 and 5 then
		--Убираем из склада и добавляем в магазин
			update markets_prods set count = count + count_product_on_rep where market_id = market_with_empty_slots_id and prod_id = empty_prod_id;
			update reps_prods set count = count - count_product_on_rep where rep_id = rep_for_take_products_id and prod_id = empty_prod_id;
		elsif count_product_on_rep > 5 then
			update markets_prods set count = count + 5 where market_id = market_with_empty_slots_id and prod_id = empty_prod_id;
			update reps_prods set count = count - 5 where rep_id = rep_for_take_products_id and prod_id = empty_prod_id;		
		end if;
	end loop;
end if;
return NEW;
end;
$$;
 ,   DROP FUNCTION public.trigger_empty_slots();
       public          postgres    false            �            1255    25054    with_cte_orders()    FUNCTION     �  CREATE FUNCTION public.with_cte_orders() RETURNS TABLE(client_id integer, client_name character varying, product_name character varying)
    LANGUAGE sql
    AS $$
with cte_query as
(
	select co.client_id, cl.f, product_name
	from clients_orders co join orders_prods op 
	on co.order_id = op.order_id
		join products pr
	on op.prod_id = pr.id
		join clients cl
	on cl.id = co.client_id
)

select distinct * from cte_query;
$$;
 (   DROP FUNCTION public.with_cte_orders();
       public          postgres    false            �            1259    24864    markets    TABLE     w   CREATE TABLE public.markets (
    id integer NOT NULL,
    manager_id integer NOT NULL,
    rep_id integer NOT NULL
);
    DROP TABLE public.markets;
       public         heap    postgres    false            �            1259    24894    markets_prods    TABLE     �   CREATE TABLE public.markets_prods (
    market_id integer NOT NULL,
    prod_id integer NOT NULL,
    count integer DEFAULT 0
);
 !   DROP TABLE public.markets_prods;
       public         heap    postgres    false            �            1259    24772    products    TABLE     z   CREATE TABLE public.products (
    id integer NOT NULL,
    product_name character varying(50),
    price numeric(8,2)
);
    DROP TABLE public.products;
       public         heap    postgres    false            �            1259    24960    check_products_in_markets    VIEW     _  CREATE VIEW public.check_products_in_markets AS
 SELECT ms.id AS "НомерМагазина",
    pr.product_name AS "Продукт",
    pr.price AS "Цена",
    mp.count AS "Количество"
   FROM ((public.markets ms
     JOIN public.markets_prods mp ON ((ms.id = mp.market_id)))
     JOIN public.products pr ON ((pr.id = mp.prod_id)));
 ,   DROP VIEW public.check_products_in_markets;
       public          postgres    false    210    222    222    222    220    210    210            f           0    0    TABLE check_products_in_markets    ACL     B   GRANT SELECT ON TABLE public.check_products_in_markets TO client;
          public          postgres    false    227            �            1259    24831    clients    TABLE       CREATE TABLE public.clients (
    id integer NOT NULL,
    f character varying(100) NOT NULL,
    i character varying(100) NOT NULL,
    o character varying(100) NOT NULL,
    age date,
    phone character(11),
    pswrd character(30),
    market_id integer
);
    DROP TABLE public.clients;
       public         heap    postgres    false            g           0    0    TABLE clients    ACL     0   GRANT SELECT ON TABLE public.clients TO client;
          public          postgres    false    212            �            1259    24830    clients_id_seq    SEQUENCE     �   CREATE SEQUENCE public.clients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.clients_id_seq;
       public          postgres    false    212            h           0    0    clients_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.clients_id_seq OWNED BY public.clients.id;
          public          postgres    false    211            �            1259    24909    clients_orders    TABLE     �   CREATE TABLE public.clients_orders (
    client_id integer NOT NULL,
    order_id integer NOT NULL,
    order_info text DEFAULT 'in progress'::text
);
 "   DROP TABLE public.clients_orders;
       public         heap    postgres    false            �            1259    24908    clients_orders_order_id_seq    SEQUENCE     �   CREATE SEQUENCE public.clients_orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.clients_orders_order_id_seq;
       public          postgres    false    224            i           0    0    clients_orders_order_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.clients_orders_order_id_seq OWNED BY public.clients_orders.order_id;
          public          postgres    false    223            �            1259    24936    clients_prods    TABLE     �   CREATE TABLE public.clients_prods (
    client_id integer NOT NULL,
    prod_id integer NOT NULL,
    market_id integer NOT NULL,
    count integer NOT NULL,
    pay integer DEFAULT 0
);
 !   DROP TABLE public.clients_prods;
       public         heap    postgres    false            j           0    0    TABLE clients_prods    ACL     =   GRANT INSERT,UPDATE ON TABLE public.clients_prods TO client;
          public          postgres    false    226            �            1259    24838    managers    TABLE     h   CREATE TABLE public.managers (
    id integer NOT NULL,
    zp numeric(7,2),
    pswrd character(30)
);
    DROP TABLE public.managers;
       public         heap    postgres    false            �            1259    24837    managers_id_seq    SEQUENCE     �   CREATE SEQUENCE public.managers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.managers_id_seq;
       public          postgres    false    214            k           0    0    managers_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.managers_id_seq OWNED BY public.managers.id;
          public          postgres    false    213            �            1259    24863    markets_id_seq    SEQUENCE     �   CREATE SEQUENCE public.markets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.markets_id_seq;
       public          postgres    false    220            l           0    0    markets_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.markets_id_seq OWNED BY public.markets.id;
          public          postgres    false    219            �            1259    24923    orders_prods    TABLE     ~   CREATE TABLE public.orders_prods (
    order_id integer NOT NULL,
    prod_id integer NOT NULL,
    count integer NOT NULL
);
     DROP TABLE public.orders_prods;
       public         heap    postgres    false            �            1259    24771    products_fad_a_17_20_id_seq    SEQUENCE     �   CREATE SEQUENCE public.products_fad_a_17_20_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.products_fad_a_17_20_id_seq;
       public          postgres    false    210            m           0    0    products_fad_a_17_20_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.products_fad_a_17_20_id_seq OWNED BY public.products.id;
          public          postgres    false    209            �            1259    24852    reps    TABLE     [   CREATE TABLE public.reps (
    id integer NOT NULL,
    top_manager_id integer NOT NULL
);
    DROP TABLE public.reps;
       public         heap    postgres    false            �            1259    24851    reps_id_seq    SEQUENCE     �   CREATE SEQUENCE public.reps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.reps_id_seq;
       public          postgres    false    218            n           0    0    reps_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.reps_id_seq OWNED BY public.reps.id;
          public          postgres    false    217            �            1259    24880 
   reps_prods    TABLE     {   CREATE TABLE public.reps_prods (
    rep_id integer NOT NULL,
    prod_id integer NOT NULL,
    count integer DEFAULT 0
);
    DROP TABLE public.reps_prods;
       public         heap    postgres    false            �            1259    24845    top_managers    TABLE     l   CREATE TABLE public.top_managers (
    id integer NOT NULL,
    zp numeric(8,2),
    pswrd character(30)
);
     DROP TABLE public.top_managers;
       public         heap    postgres    false            �            1259    24844    top_managers_id_seq    SEQUENCE     �   CREATE SEQUENCE public.top_managers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.top_managers_id_seq;
       public          postgres    false    216            o           0    0    top_managers_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.top_managers_id_seq OWNED BY public.top_managers.id;
          public          postgres    false    215            �           2604    24834 
   clients id    DEFAULT     h   ALTER TABLE ONLY public.clients ALTER COLUMN id SET DEFAULT nextval('public.clients_id_seq'::regclass);
 9   ALTER TABLE public.clients ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    212    211    212            �           2604    24912    clients_orders order_id    DEFAULT     �   ALTER TABLE ONLY public.clients_orders ALTER COLUMN order_id SET DEFAULT nextval('public.clients_orders_order_id_seq'::regclass);
 F   ALTER TABLE public.clients_orders ALTER COLUMN order_id DROP DEFAULT;
       public          postgres    false    223    224    224            �           2604    24841    managers id    DEFAULT     j   ALTER TABLE ONLY public.managers ALTER COLUMN id SET DEFAULT nextval('public.managers_id_seq'::regclass);
 :   ALTER TABLE public.managers ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    214    213    214            �           2604    24867 
   markets id    DEFAULT     h   ALTER TABLE ONLY public.markets ALTER COLUMN id SET DEFAULT nextval('public.markets_id_seq'::regclass);
 9   ALTER TABLE public.markets ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    219    220    220            �           2604    24775    products id    DEFAULT     v   ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_fad_a_17_20_id_seq'::regclass);
 :   ALTER TABLE public.products ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    209    210    210            �           2604    24855    reps id    DEFAULT     b   ALTER TABLE ONLY public.reps ALTER COLUMN id SET DEFAULT nextval('public.reps_id_seq'::regclass);
 6   ALTER TABLE public.reps ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    218    217    218            �           2604    24848    top_managers id    DEFAULT     r   ALTER TABLE ONLY public.top_managers ALTER COLUMN id SET DEFAULT nextval('public.top_managers_id_seq'::regclass);
 >   ALTER TABLE public.top_managers ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    215    216    216            Q          0    24831    clients 
   TABLE DATA           L   COPY public.clients (id, f, i, o, age, phone, pswrd, market_id) FROM stdin;
    public          postgres    false    212   /�       ]          0    24909    clients_orders 
   TABLE DATA           I   COPY public.clients_orders (client_id, order_id, order_info) FROM stdin;
    public          postgres    false    224   y�       _          0    24936    clients_prods 
   TABLE DATA           R   COPY public.clients_prods (client_id, prod_id, market_id, count, pay) FROM stdin;
    public          postgres    false    226   ��       S          0    24838    managers 
   TABLE DATA           1   COPY public.managers (id, zp, pswrd) FROM stdin;
    public          postgres    false    214   ȏ       Y          0    24864    markets 
   TABLE DATA           9   COPY public.markets (id, manager_id, rep_id) FROM stdin;
    public          postgres    false    220   �       [          0    24894    markets_prods 
   TABLE DATA           B   COPY public.markets_prods (market_id, prod_id, count) FROM stdin;
    public          postgres    false    222   G�       ^          0    24923    orders_prods 
   TABLE DATA           @   COPY public.orders_prods (order_id, prod_id, count) FROM stdin;
    public          postgres    false    225   }�       O          0    24772    products 
   TABLE DATA           ;   COPY public.products (id, product_name, price) FROM stdin;
    public          postgres    false    210   ��       W          0    24852    reps 
   TABLE DATA           2   COPY public.reps (id, top_manager_id) FROM stdin;
    public          postgres    false    218   ��       Z          0    24880 
   reps_prods 
   TABLE DATA           <   COPY public.reps_prods (rep_id, prod_id, count) FROM stdin;
    public          postgres    false    221   ��       U          0    24845    top_managers 
   TABLE DATA           5   COPY public.top_managers (id, zp, pswrd) FROM stdin;
    public          postgres    false    216   ��       p           0    0    clients_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.clients_id_seq', 1, true);
          public          postgres    false    211            q           0    0    clients_orders_order_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.clients_orders_order_id_seq', 4, true);
          public          postgres    false    223            r           0    0    managers_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.managers_id_seq', 4, true);
          public          postgres    false    213            s           0    0    markets_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.markets_id_seq', 4, true);
          public          postgres    false    219            t           0    0    products_fad_a_17_20_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.products_fad_a_17_20_id_seq', 16, true);
          public          postgres    false    209            u           0    0    reps_id_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.reps_id_seq', 2, true);
          public          postgres    false    217            v           0    0    top_managers_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.top_managers_id_seq', 4, true);
          public          postgres    false    215            �           2606    24917 "   clients_orders clients_orders_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.clients_orders
    ADD CONSTRAINT clients_orders_pkey PRIMARY KEY (order_id);
 L   ALTER TABLE ONLY public.clients_orders DROP CONSTRAINT clients_orders_pkey;
       public            postgres    false    224            �           2606    24836    clients clients_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.clients DROP CONSTRAINT clients_pkey;
       public            postgres    false    212            �           2606    24843    managers managers_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.managers
    ADD CONSTRAINT managers_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.managers DROP CONSTRAINT managers_pkey;
       public            postgres    false    214            �           2606    24869    markets markets_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.markets
    ADD CONSTRAINT markets_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.markets DROP CONSTRAINT markets_pkey;
       public            postgres    false    220            �           2606    24777 "   products products_fad_a_17_20_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_fad_a_17_20_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.products DROP CONSTRAINT products_fad_a_17_20_pkey;
       public            postgres    false    210            �           2606    24857    reps reps_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.reps
    ADD CONSTRAINT reps_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.reps DROP CONSTRAINT reps_pkey;
       public            postgres    false    218            �           2606    24850    top_managers top_managers_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.top_managers
    ADD CONSTRAINT top_managers_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.top_managers DROP CONSTRAINT top_managers_pkey;
       public            postgres    false    216            �           2620    25024 /   markets_prods auto_increnet_products_to_markets    TRIGGER     �   CREATE TRIGGER auto_increnet_products_to_markets AFTER UPDATE OF count ON public.markets_prods FOR EACH STATEMENT EXECUTE FUNCTION public.trigger_empty_slots();
 H   DROP TRIGGER auto_increnet_products_to_markets ON public.markets_prods;
       public          postgres    false    222    248    222            �           2620    25017    clients_prods when_client_buy    TRIGGER     �   CREATE TRIGGER when_client_buy AFTER UPDATE OF pay ON public.clients_prods FOR EACH STATEMENT EXECUTE FUNCTION public.trigger_buy();
 6   DROP TRIGGER when_client_buy ON public.clients_prods;
       public          postgres    false    247    226    226            �           2606    24918 ,   clients_orders clients_orders_client_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clients_orders
    ADD CONSTRAINT clients_orders_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON UPDATE RESTRICT ON DELETE CASCADE;
 V   ALTER TABLE ONLY public.clients_orders DROP CONSTRAINT clients_orders_client_id_fkey;
       public          postgres    false    212    3240    224            �           2606    24940 *   clients_prods clients_prods_client_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clients_prods
    ADD CONSTRAINT clients_prods_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON UPDATE RESTRICT ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.clients_prods DROP CONSTRAINT clients_prods_client_id_fkey;
       public          postgres    false    212    226    3240            �           2606    24950 *   clients_prods clients_prods_market_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clients_prods
    ADD CONSTRAINT clients_prods_market_id_fkey FOREIGN KEY (market_id) REFERENCES public.markets(id) ON UPDATE RESTRICT ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.clients_prods DROP CONSTRAINT clients_prods_market_id_fkey;
       public          postgres    false    3248    220    226            �           2606    24945 (   clients_prods clients_prods_prod_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clients_prods
    ADD CONSTRAINT clients_prods_prod_id_fkey FOREIGN KEY (prod_id) REFERENCES public.products(id) ON UPDATE RESTRICT ON DELETE CASCADE;
 R   ALTER TABLE ONLY public.clients_prods DROP CONSTRAINT clients_prods_prod_id_fkey;
       public          postgres    false    226    3238    210            �           2606    24870    markets markets_manager_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.markets
    ADD CONSTRAINT markets_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.managers(id) ON UPDATE RESTRICT ON DELETE CASCADE;
 I   ALTER TABLE ONLY public.markets DROP CONSTRAINT markets_manager_id_fkey;
       public          postgres    false    214    3242    220            �           2606    24903 *   markets_prods markets_prods_market_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.markets_prods
    ADD CONSTRAINT markets_prods_market_id_fkey FOREIGN KEY (market_id) REFERENCES public.markets(id) ON UPDATE RESTRICT ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.markets_prods DROP CONSTRAINT markets_prods_market_id_fkey;
       public          postgres    false    3248    220    222            �           2606    24898 (   markets_prods markets_prods_prod_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.markets_prods
    ADD CONSTRAINT markets_prods_prod_id_fkey FOREIGN KEY (prod_id) REFERENCES public.products(id) ON UPDATE RESTRICT ON DELETE CASCADE;
 R   ALTER TABLE ONLY public.markets_prods DROP CONSTRAINT markets_prods_prod_id_fkey;
       public          postgres    false    222    210    3238            �           2606    24875    markets markets_rep_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.markets
    ADD CONSTRAINT markets_rep_id_fkey FOREIGN KEY (rep_id) REFERENCES public.reps(id) ON UPDATE RESTRICT ON DELETE CASCADE;
 E   ALTER TABLE ONLY public.markets DROP CONSTRAINT markets_rep_id_fkey;
       public          postgres    false    218    3246    220            �           2606    24926 '   orders_prods orders_prods_order_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders_prods
    ADD CONSTRAINT orders_prods_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.clients_orders(order_id) ON UPDATE RESTRICT ON DELETE CASCADE;
 Q   ALTER TABLE ONLY public.orders_prods DROP CONSTRAINT orders_prods_order_id_fkey;
       public          postgres    false    3250    225    224            �           2606    24931 &   orders_prods orders_prods_prod_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders_prods
    ADD CONSTRAINT orders_prods_prod_id_fkey FOREIGN KEY (prod_id) REFERENCES public.products(id) ON UPDATE RESTRICT ON DELETE CASCADE;
 P   ALTER TABLE ONLY public.orders_prods DROP CONSTRAINT orders_prods_prod_id_fkey;
       public          postgres    false    225    210    3238            �           2606    24884 "   reps_prods reps_prods_prod_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.reps_prods
    ADD CONSTRAINT reps_prods_prod_id_fkey FOREIGN KEY (prod_id) REFERENCES public.products(id) ON UPDATE RESTRICT ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.reps_prods DROP CONSTRAINT reps_prods_prod_id_fkey;
       public          postgres    false    210    3238    221            �           2606    24889 !   reps_prods reps_prods_rep_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.reps_prods
    ADD CONSTRAINT reps_prods_rep_id_fkey FOREIGN KEY (rep_id) REFERENCES public.reps(id) ON UPDATE RESTRICT ON DELETE CASCADE;
 K   ALTER TABLE ONLY public.reps_prods DROP CONSTRAINT reps_prods_rep_id_fkey;
       public          postgres    false    221    218    3246            �           2606    24858    reps reps_top_manager_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.reps
    ADD CONSTRAINT reps_top_manager_id_fkey FOREIGN KEY (top_manager_id) REFERENCES public.top_managers(id) ON UPDATE RESTRICT ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.reps DROP CONSTRAINT reps_top_manager_id_fkey;
       public          postgres    false    3244    216    218            Q   :   x�3�H-)�/SPvfq�����.�r�[[X�pz+���\1z\\\ �rx      ]   "   x�3�4���S((�O/J-.�2�4A���qqq �Y
�      _      x������ � �      S   =   x�3�43 =N_?]C#c�ˈ�I���	N�Ɯ�H*�MLq�4A������=... �2z      Y   "   x�3�4�4�2�4�ƜƜF\&�&@2F��� 4Ys      [   &   x�3��44�2�4�4�F`҄�Hss��qqq R�\      ^      x�3�4�4�2�4�4�2�4�4����� ":�      O   �   x�5OMj�@^9�;���$�}7.
� dQ��8�fBbEw��7�� C� ��r��H�-���$���N�R���[D�#!��.̇&R�W
S/���ݡ;�|�+e��B��#A��;��a�yۚ
����ꥩ�_HC/ņ��Z54/WM��}�|�?���m�w�;������̆Z�h�R�x�I�4�|9��{��/w���b"�����Ƙ��Q�ګ_�      W      x�3�4�2�4����� ��      Z   %   x�3�4�4�2�4�4���@҄� H�=... LE-      U   @   x�3�44 =�_?]C#c�ˈ�Y���	.�Ɯ��*�MLq�4�4GVibj�Ke� P�~     