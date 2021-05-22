CREATE TABLE public.completed_orders
(
    ord_id integer NOT NULL,
    ord_complete_time timestamp without time zone NOT NULL,
    CONSTRAINT completed_orders_pkey PRIMARY KEY (ord_id)
)

CREATE TABLE public.dish_composition
(
    dish_id integer,
    ing_id integer,
    ing_amount integer,
    CONSTRAINT dish_composition_dish_id_ing_id_key UNIQUE (dish_id, ing_id),
    CONSTRAINT dish_composition_ing_amount_check CHECK (ing_amount > 0)
)

CREATE TABLE public.dishes
(
    d_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    d_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    d_type character varying(50) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT dish_pkey PRIMARY KEY (d_id)
)

CREATE TABLE public.ingredients
(
    i_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    d_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    available_count integer NOT NULL,
    reserved_count integer NOT NULL,
    price numeric(5,2) NOT NULL,
    CONSTRAINT ingredient_pkey PRIMARY KEY (i_id),
    CONSTRAINT ingredient_d_name_check CHECK (d_name::text ~ similar_to_escape('[A-Z]%'::text)),
    CONSTRAINT ingredient_available_count_check CHECK (available_count >= 0),
    CONSTRAINT ingredient_reserved_count_check CHECK (reserved_count >= 0),
    CONSTRAINT ingredient_price_check CHECK (price > 0.00)
)

CREATE TABLE public.ingredients_replacement
(
    i_id integer,
    change_id integer,
    CONSTRAINT ingredients_replacement_i_id_change_id_key UNIQUE (i_id, change_id),
    CONSTRAINT ingredients_replacement_check CHECK (change_id <> i_id)
)

CREATE TABLE public.lunch_composition
(
    l_id integer,
    d_id integer,
    CONSTRAINT lunch_composition_l_id_d_id_key UNIQUE (l_id, d_id)
)

CREATE TABLE public.order_structure
(
    ord_id integer NOT NULL,
    d_id integer NOT NULL,
    d_category character varying(10) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT order_structure_pkey PRIMARY KEY (ord_id),
    CONSTRAINT order_structure_ord_id_d_id_d_category_key UNIQUE (ord_id, d_id, d_category),
    CONSTRAINT order_structure_ord_id_fkey FOREIGN KEY (ord_id)
        REFERENCES public.processing_orders (ord_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT order_structure_d_category_check CHECK (d_category::text = ANY (ARRAY['dish'::character varying, 'lunch'::character varying]::text[]))
)

CREATE TABLE public.processing_orders
(
    ord_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    ord_start_time timestamp without time zone NOT NULL,
    CONSTRAINT processing_orders_pkey PRIMARY KEY (ord_id)
)

CREATE TABLE public.set_lunches
(
    l_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    l_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT set_lunches_pkey PRIMARY KEY (l_id),
    CONSTRAINT set_lunches_l_name_check CHECK (l_name::text ~ similar_to_escape('[A-Z]%'::text))
)

CREATE TABLE public.vegetarian_dishes
(
    d_id integer NOT NULL,
    CONSTRAINT vegetarian_dishes_pkey PRIMARY KEY (d_id),
    CONSTRAINT vegetarian_dishes_d_id_fkey FOREIGN KEY (d_id)
        REFERENCES public.dishes (d_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

CREATE TABLE public.child_dishes
(
    d_id integer NOT NULL,
    CONSTRAINT child_dishes_pkey PRIMARY KEY (d_id),
    CONSTRAINT child_dishes_d_id_fkey FOREIGN KEY (d_id)
        REFERENCES public.dishes (d_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

CREATE TABLE new_order_composition
(	
	d_name VARCHAR(50) NOT NULL PRIMARY KEY,
	d_category VARCHAR(10) NOT NULL CHECK (d_category IN ('dish', 'lunch')),
	d_id INTEGER,
	d_count INTEGER NOT NULL CHECK (d_count > 0)
);
