-- Creado     : 04/10/2007 - Autor: Rub‚n Arn ez 

 DROP PROCEDURE sp_sisdepu;

create procedure "informix".sp_sisdepu()
returning integer,
        char(100);

-- Para crear la tabla temporal de CLIDEPUR

DEFINE cod_errado           char(10);
DEFINE cod_correcto         char(10);
DEFINE user_changed         char(8);
DEFINE date_changed         datetime year to fraction(5);
DEFINE nom_tabla            varchar(30);


SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE temp_clidepur(
cod_errado           char(10),
cod_correcto         char(10),
user_changed         char(8),
date_changed         datetime year to fraction(5),
nom_tabla            varchar(30,0)
) WITH NO LOG;	
return 0, "Actualizacion Exitosa";

end procedure;


-- end procedure;
