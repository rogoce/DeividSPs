-- Informaci¢n: Actualiza los cliente  Agrupador Porcesados y no permite ser actualizados nuevamente
-- Creado     : 07/10/2007 - Autor: Rub‚n Dar¡o Arn ez S nchez

DROP PROCEDURE sp_par265;

create procedure "informix".sp_par265(a_cod_agrupa char(4))
returning integer,
          char(100),char(10),char(10);

define _cantidad   	integer;
define _estatus   	integer;
define _cod_clt_1   char(10);
define _cod_clt_2   char(10);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

SET ISOLATION TO DIRTY READ;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

select estado
  into _estatus
  from clideagr
 where cod_agrupa = a_cod_agrupa;

if _estatus = 1 then
	return 1, "Este Registro Ya Fue Procesado",null,null;
end if

select count(*)
  into _cantidad
  from clidedup
 where a_cod_agrupa=cod_gpo  
   and seleccion = 1;

if _cantidad > 1 then
	return 1, "No Puede Haber Mas de Un (1) Registro Principal";
end if
if _cantidad = 0 then
	return 1, "Debe Haber Un (1) Registro Principal";
end if

select cod_clt
  into _cod_clt_1
  from clidedup
 where cod_gpo   = a_cod_agrupa
   and seleccion = 1;

foreach
 select cod_clt
   into _cod_clt_2
   from clidedup
  where cod_gpo   = a_cod_agrupa
    and seleccion = 0

end foreach

update clideagr
   set estado     = 1
 where cod_agrupa = a_cod_agrupa;

end
   
return 	 0, "Actualizacion Exitosa";

end procedure;
