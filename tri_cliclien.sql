
create trigger "informix".de_cliclien delete on "informix".cliclien
referencing old as viejo for each row
        (
        execute procedure "informix".sp_par163(viejo.cod_cliente, 'E'));


create trigger "informix".mo_cliclien update on "informix".cliclien 
referencing old as viejo for each row
        (
        execute procedure "informix".sp_par163(viejo.cod_cliente, 'M'));


create trigger "informix".ad_cliclien insert on "informix".cliclien 
referencing new as nuevo for each row
        (
        execute procedure "informix".sp_par163(nuevo.cod_cliente, 'N'));