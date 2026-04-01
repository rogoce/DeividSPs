-- Procesamiento Masivo de Pólizas en Pool Automático  para TXT de Ducruet
-- Creado    : 19/11/2014 - Autor: Román Gordón

drop procedure sp_pro324a;

create procedure "informix".sp_pro324a()
returning smallint,char(20);		 --_no_documento,   

define _error_desc	    varchar(100);
define _no_documento	char(20);
define _no_poliza_nuevo	char(10);
define _no_factura		char(10);
define _no_poliza		char(10);
define _actualizado		smallint;	 
define _error			integer;

set isolation to dirty read;

--set debug file to "sp_pro324a.trc";
--trace on;

foreach
	select no_poliza,
		   no_documento
	  into _no_poliza,
		   _no_documento
      from emirepo  
	 where user_added = 'AUTOMATI'
	   and cod_agente = '00035'
	   and vigencia_final between '01/12/2014' and '31/12/2014'
	   and estatus    = 1

	call sp_sis13('001', 'PRO', '02', 'par_no_poliza') returning _no_poliza_nuevo;
	
	call sp_pro320c('ARLINK',_no_poliza, _no_poliza_nuevo) returning _error,_error_desc;
	
	if _error = 0 then
		select actualizado,
			   no_factura
		  into _actualizado,
			   _no_factura
		  from emipomae
		 where no_poliza = _no_poliza_nuevo;
		 
		if _no_factura is null or _actualizado = 0 then
			call sp_sis27(_no_poliza_nuevo, 1) returning _error;

			if _error = 0 then			
				update emipomae
				   set renovada  = 0
				 where no_poliza = _no_poliza;
			end if
			
			call sp_sis27(_no_poliza_nuevo, 2) returning _error;
		end if
	end if
	
	call sp_sis61b(_no_poliza_nuevo) returning _error,_error_desc;
	
	return 0,_no_documento with resume;
end foreach
end procedure;