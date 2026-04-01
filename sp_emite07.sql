-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 17/05/2019 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite07;

create procedure "informix".sp_emite07() 
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

	let _prima_neta_emi = 0.00;
	let _prima_neta = 0.00;
	let _dif_prima = 0.00;
	let _cant_iter = 0;
	let _cont = 0;
	let v_codcompania = '001';
	let _error_desc = "";   

	foreach
		select no_poliza,
			    no_documento
		  into _no_poliza,
			    _no_documento
		  from emipomae 
		 where actualizado = 0
		   and nueva_renov = 'R'
		   and no_factura is not null
		   and no_factura not like '%-%'
		   and cod_ramo in ('001','003')--no_documento in ('0121-00447-01','0116-00042-06')
		   and no_documento not in ('0123-00035-01','0123-00035-01','0124-04947-07','0193-0526-01')
		   --and suma_asegurada > 500000
		   --and prima_retenida < 40

		-- Actualización de la Póliza
		call sp_pro374(_no_poliza) returning _error,_error_isam,_error_title,_error_desc;
		--call sp_sis61b(_no_poliza) returning _error,_error_desc;

		if _error = 0 then
			let _error = sp_pro326(_no_poliza,'AUTOMATI');
			return _error,_error_desc with resume;
		else
			return 0,_error_desc || ' ' || _no_documento with resume;
		end if
	end foreach	
	
	end
end procedure;