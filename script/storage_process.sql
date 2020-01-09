create or replace function public.ps_tg_insert_t_post() returns trigger
    language plpgsql
as
$$
BEGIN
    UPDATE t_post set pos_i=new.pos_i where id_post = new.id_pos;
    RETURN NEW;
END;
$$;


create or replace function public.ps_emergency_manager_post() returns trigger
    language plpgsql
as
DECLARE
    NB_Ligne   INTEGER := 0;
    ID_INCENDI INTEGER;
    Nb_Camion  integer := 0;
BEGIN
    SELECT count(*) into NB_Ligne from t_incendie where t_incendie.id_post = new.id_post;
    select count(*)
    into Nb_Camion
    from t_camion
             join t_affectation on t_camion.id_camion = t_affectation.id_camion
             join t_incendie on t_affectation.id_incendie = t_incendie.id_incendie
    where t_incendie.id_post = new.id_post;
    if (new.pos_i <> 0 and NB_Ligne <> 0 and Nb_Camion = 0) then
        select id_incendie into ID_INCENDI from t_incendie where t_incendie.id_post = new.id_post;
        delete from t_incendie where id_incendie = ID_INCENDI;
        insert into t_incendie(id_post, date_incendie) values (new.id_post, now());
    end if;

    if NEW.pos_i <> 0 and NB_Ligne = 0 then
        insert into t_incendie(id_post, date_incendie) values (new.id_post, now());
    end if;
    if NEW.pos_i = 0 then
        select id_incendie into ID_INCENDI from t_incendie where t_incendie.id_post = new.id_post;
        delete from t_affectation where id_incendie = ID_INCENDI;
        delete from t_incendie where id_incendie = ID_INCENDI;
    end if;
    return new;
END

create or replace function public.ps_emergency_manager_incendie() returns trigger
    language plpgsql
as
DECLARE
    Incendie_intensite INTEGER;
    Capacite_gere      integer;
    NbCamion           integer;
BEGIN
    select pos_i into Incendie_intensite from t_post where t_post.id_post = new.id_post;

    insert into t_affectation(id_camion, id_incendie)
    select id_camion, new.id_incendie
    from v_capacite_cumule_camion
    where capacite_cumule <= Incendie_intensite;

    select sum(capacite_camion)
    into Capacite_gere
    from t_affectation
             join t_camion on t_affectation.id_camion = t_camion.id_camion
    where id_incendie = Incendie_intensite;

    select count('x')
    into NbCamion
    from t_affectation
             join t_camion on t_affectation.id_camion = t_camion.id_camion
    where id_incendie = Incendie_intensite;

    if (NbCamion = 0) then
        insert into t_affectation(id_camion, id_incendie)
        select id_camion, new.id_incendie
        from v_camion_disponible
        order by capacite_camion desc
        limit 1;

    end if;

    while (Capacite_gere < Incendie_intensite)
        loop

            insert into t_affectation(id_camion, id_incendie)
            select id_camion, new.id_incendie
            from v_camion_disponible
            order by capacite_camion
            limit 1;

            select sum(capacite_camion)
            into Capacite_gere
            from t_affectation
                     join t_camion on t_affectation.id_camion = t_camion.id_camion
            where id_incendie = Incendie_intensite;


        end loop;

    return new;
END
