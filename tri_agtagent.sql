
create trigger "informix".de_agtagent delete on "informix".agtagent
referencing old as viejo for each row
        (
        execute procedure "informix".sp_par214(viejo.cod_agente, 'E'));


create trigger "informix".mo_agtagent update on "informix".agtagent 
referencing old as viejo for each row
        (
        execute procedure "informix".sp_par214(viejo.cod_agente, 'M'));


create trigger "informix".ad_agtagent insert on "informix".agtagent 
referencing new as nuevo for each row
        (
        execute procedure "informix".sp_par214(nuevo.cod_agente, 'N'));