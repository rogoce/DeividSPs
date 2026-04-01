-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 17/05/2019 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite10;

create procedure "informix".sp_emite10() 
returning	smallint,varchar(200);

define _prima_neta_emi 	dec(16,2);
define _prima_neta 		dec(16,2);
define _dif_prima 		dec(16,2);
define _cant_iter 		smallint;
define _cont 				smallint;
define _error           	smallint;
define _no_poliza		   	char(10);
define _no_unidad      	char(5);
define _aseguradora		varchar(200);
define _error_desc		varchar(200);
define _error_isam		smallint;
define _poliza_cont		varchar(30);
define _error_title		varchar(30);
define _fecha_efectividad			date;
define li_return			smallint;
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

	foreach
		select poliza_continuidad,
			   aseguradora,
			   fecha_efectividad,
			   no_unidad
		  into _poliza_cont,
			   _aseguradora,
			   _fecha_efectividad,
			   _no_unidad
		  from deivid_tmp:tmp_continuidad
		  

		-- Actualización de la Póliza
		update emipouni
		   set poliza_cont = _poliza_cont,
			   vig_ini_cont = _fecha_efectividad,
			   comp_cont = _aseguradora
		 where no_poliza = '0001775769'
		   and no_unidad = _no_unidad;
	end foreach	
	
	end
end procedure;