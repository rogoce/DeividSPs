-- Depuracion de las Formas de Pago
-- Creado    : 16/09/2010 - Autor: Roman Gordon 

drop procedure sp_sis134;

create procedure "informix".sp_sis134(
a_cod_errado	char(3), 
a_cod_correcto 	char(3)
) returning integer,
            char(100);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(100);

--set debug file to "sp_sis134.trc";
--trace on;

begin work;

begin
on exception set _error, _error_isam, _error_desc
   	rollback work;
	return _error, _error_desc;
end exception

update emipoliza
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;

update emipomae
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;

update emiporen
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;

update emipouni
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;

update emireaut 
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;

update endedmae
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;

update endedhis
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;
 
update endeduni 
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;

update endedtri
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;

update emicartasal
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;

update cobcampl
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;

update cascampanafil
   set cod_filtro   = a_cod_correcto
 where cod_filtro   = a_cod_errado
   and tipo_filtro  = 3;

update campoliza
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;

{update avicanpoliza
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;

update avisocanc
   set cod_formapag = a_cod_correcto
 where cod_formapag = a_cod_errado;}


delete from cobforpa
 where cod_formapag = a_cod_errado;

commit work;

return 0, "Actualizacion Exitosa";

end

end procedure



