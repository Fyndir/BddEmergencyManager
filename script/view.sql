create or replace view public.v_camion (camion_x, camion_y, immatriculation_camion, destination_x, destination_y) as
WITH cte AS (
    SELECT COALESCE(t_camion.camion_x, t_caserne.caserne_x) AS camion_x,
           COALESCE(t_camion.camion_y, t_caserne.caserne_y) AS camion_y,
           t_camion.immatriculation_camion,
           COALESCE(tp.pos_x, t_caserne.caserne_x)          AS destination_x,
           COALESCE(tp.pos_y, t_caserne.caserne_y)          AS destination_y
    FROM t_camion
             LEFT JOIN t_affectation ta ON t_camion.id_camion = ta.id_camion
             LEFT JOIN t_incendie ti ON ta.id_incendie = ti.id_incendie
             LEFT JOIN t_post tp ON ti.id_post = tp.id_post
             JOIN t_caserne ON t_camion.id_caserne = t_caserne.id_caserne
)
SELECT cte.camion_x,
       cte.camion_y,
       cte.immatriculation_camion,
       cte.destination_x,
       cte.destination_y
FROM cte;

create or replace view public.v_camion_disponible
            (id_camion, immatriculation_camion, capacite_camion, id_caserne, partition) as
SELECT t_camion.id_camion,
       t_camion.immatriculation_camion,
       t_camion.capacite_camion,
       t_camion.id_caserne,
       1 AS partition
FROM t_camion
WHERE (NOT (t_camion.id_camion IN (SELECT t_affectation.id_camion
                                   FROM t_affectation)));

create or replace view public.v_capacite_cumule_camion
            (id_camion, immatriculation_camion, capacite_camion, id_caserne, capacite_cumule) as
SELECT v_camion_disponible.id_camion,
       v_camion_disponible.immatriculation_camion,
       v_camion_disponible.capacite_camion,
       v_camion_disponible.id_caserne,
       sum(v_camion_disponible.capacite_camion)
       OVER (ORDER BY v_camion_disponible.capacite_camion DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS capacite_cumule
FROM v_camion_disponible;


create or replace view public.v_pos(id_pos, pos_x, pos_y, pos_i) as
SELECT t_post.id_post AS id_pos,
       t_post.pos_x,
       t_post.pos_y,
       t_post.pos_i
FROM t_post;





