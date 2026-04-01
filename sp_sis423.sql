-- Creado: Armando Moreno	09/04/2015

--Procedimiento para buscar si el corredor aplica para bono de polizas de salud(por cada 4 $100)

drop procedure sp_sis423;

create procedure "informix".sp_sis423(a_cod_agente char(10),a_fecha_genera date, a_fecha_desde date, a_fecha_hasta date)
returning integer,char(20);

define _error			integer;
define _cnt	    		integer;
define _no_documento	char(20);

BEGIN
ON EXCEPTION SET _error
	return _error,_no_documento;
end exception


create temp table tmp_chqcomsa
(no_documento char(20));
	
let _cnt = 0;
foreach

	select no_documento
	  into _no_documento
	  from chqcomsa
	 where cod_agente = a_cod_agente
       and pagada     = 0

	Insert Into tmp_chqcomsa(no_documento)
	Values (_no_documento);
	
	let _cnt = _cnt + 1;
	
	if _cnt = 4 then
		update chqcomsa
		   set fecha_comision = a_fecha_genera,
			   pagada         = 1,
			   fecha_desde    = a_fecha_desde,
			   fecha_hasta    = a_fecha_hasta
		 where no_documento   in (select no_documento from tmp_chqcomsa)
		   and cod_agente     = a_cod_agente;
		   
		let _cnt = 0;
		
		delete from tmp_chqcomsa;
	end if
	
end foreach

drop table tmp_chqcomsa;
end

return 0,"";
end procedure