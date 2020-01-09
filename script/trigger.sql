
create trigger tg_emergency_manager
    after update
    on public.t_post
    for each row
execute procedure public.ps_emergency_manager_post();

create trigger tg_emergency_manager
    after insert
    on public.t_incendie
    for each row
execute procedure public.ps_emergency_manager_incendie();

create trigger tg_insert_t_post
    after insert
    on public.v_pos
    for each row
execute procedure public.ps_tg_insert_t_post();