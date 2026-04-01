-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 17/05/2019 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_act_lpf;

create procedure "informix".sp_act_lpf() 
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
		select no_poliza,
			   club
		  into _no_poliza,
			   _error_desc
		  from deivid_tmp:tmp_lpf

		update emipouni
		   set desc_unidad = _error_desc
		 where no_poliza = _no_poliza
		   --and no_unidad = '00001'
		   and cod_asegurado = '660666';
	end foreach

	return 0,"Actualización Exitosa: "|| _no_documento with resume;
	
	end
end procedure;