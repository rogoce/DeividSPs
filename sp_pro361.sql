-- Procedimiento que genera el numero de carga por agente del proceso de Emisiones Electronicas.
-- Creado    : 31/07/2012 - autor: Roman Gordon

-- sis v.2.0 - deivid, s.a.


drop procedure sp_pro361;

create procedure "informix".sp_pro361(a_cod_agente char(5), a_opcion char(1)) 
returning char(5);

define _no_carga_int   integer; 
define _no_carga_char  char(10);

--set debug file to "sp_pro361.trc"; 
--trace on;

-- lectura del contador de transacciones (llave primaria) 

set lock mode to wait;

if a_opcion in ('','C') then	--Coaseguro del Estado
	select max(num_carga)
	  into _no_carga_char
	  from emicacoami
	 where cod_coasegur = a_cod_agente;
else
	select max(num_carga)
	  into _no_carga_char
	  from prdemielect
	 where cod_agente = a_cod_agente
	   and proceso = a_opcion;
end if


if _no_carga_char is null then
	let _no_carga_int = 1;
else
	let _no_carga_int	= cast(_no_carga_char as integer);
	let _no_carga_int	= _no_carga_int + 1;
end if

set isolation to dirty read;

-- numero de transaccion

let _no_carga_char  = '00000';

if _no_carga_int > 9999 then
	let _no_carga_char = _no_carga_int;
elif _no_carga_int > 999 then
	let _no_carga_char[2,5] = _no_carga_int;
elif _no_carga_int > 99  then
	let _no_carga_char[3,5] = _no_carga_int;
elif _no_carga_int > 9  then
	let _no_carga_char[4,5] = _no_carga_int;
else
	let _no_carga_char[5,5] = _no_carga_int;
end if

return _no_carga_char;

end procedure;
