create table public.t_post
(
    id_post serial           not null
        constraint t_post_pkey
            primary key,
    pos_x   double precision not null,
    pos_y   double precision not null,
    pos_i   integer          not null,
    constraint uk_posx_posy
        unique (pos_x, pos_y)
);

create table public.t_incendie
(
    id_incendie   serial    not null
        constraint t_incendie_pkey
            primary key,
    id_post       integer   not null
        constraint t_incendie_id_post_fkey
            references public.t_post,
    date_incendie timestamp not null
);

create table public.t_caserne
(
    id_caserne  serial       not null
        constraint t_caserne_pkey
            primary key,
    nom_caserne varchar(250) not null,
    caserne_x   double precision,
    caserne_y   double precision
);

create table public.t_camion
(
    id_camion              serial  not null
        constraint t_camion_pkey
            primary key,
    immatriculation_camion varchar(15),
    capacite_camion        integer not null,
    id_caserne             integer
        constraint t_camion_id_caserne_fkey
            references public.t_caserne,
    camion_x               double precision,
    camion_y               double precision
);

create table public.t_affectation
(
    id_affectation serial  not null
        constraint t_affectation_pkey
            primary key,
    id_camion      integer not null
        constraint t_affectation_id_camion_fkey
            references public.t_camion,
    id_incendie    integer not null
        constraint t_affectation_id_incendie_fkey
            references public.t_incendie
);


