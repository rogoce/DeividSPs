-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 17/05/2019 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite08a;

create procedure "informix".sp_emite08a(a_no_documento char(20), a_no_poliza char(10)) 
returning	smallint,varchar(200);

define _prima_neta_emi 	dec(16,2);
define _prima_neta 		dec(16,2);
define _dif_prima 		dec(16,2);
define _cant_iter 		smallint;
define _cont 				smallint;
define _error           	smallint;
define _no_poliza		   	char(10);
define _no_unidad      	char(5);
define _error_desc		varchar(200);
define _error_isam		smallint;
define _error_title		varchar(30);
define _vigencia_inic			date;
define _cnt			smallint;
define v_codcompania		char(3);
define _no_documento		varchar(20);

	begin
	on exception set _error,_error_isam,_error_desc
		return _error,_error_desc;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_emite01.trc"; 
	--trace on;

--begin work;

	let _error_desc = "";   

	foreach
		select no_poliza
		  into _no_poliza
		  from emipomae
		 where actualizado = 0
		   and no_factura is not null
		   and no_factura not like '%-%'
		   and no_poliza not in (a_no_poliza)
		   and no_documento = a_no_documento

		call sp_sis61b(_no_poliza) returning _error,_error_desc;
	end foreach

	if _error <> 0 then
		return _error,_error_desc with resume;
	else
		return 0,"Actualización Exitosa: "|| a_no_documento with resume;
	end if
	
	end
end procedure;