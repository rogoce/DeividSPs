-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_actualiza_historico;
create procedure sp_actualiza_historico()
returning	integer;

define _error_desc			char(100);
define _error,_no_cambio,_valor		        integer;
define _error_isam	        integer;
define _no_tranrec,_no_reclamo,_no_poliza        char(10); 
define _cod_ruta,_no_unidad           char(5);
define _cantidad,_renglon,_cant_ruta            smallint;
define _porc_suma,_porcentaje  dec(9,6);
define _cod_ramo,_cod_cober_reas  char(3);
define _vigencia_final,_vigencia_inic,_fecha_actual date;
define _mensaje 			varchar(250);
define _cod_subramo         char(3);
define _prima_devengada		dec(16,2);
define _prima_retenida		dec(16,2);  
define _porc_partic			dec(5,2);	

set debug file to "sp_actualiza_historico.trc";
trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

foreach
	select cod_ramo,
	       cod_subramo,
	       prima_devengada,
		   prima_retenida,
		   porc_partic
	  into _cod_ramo,
	       _cod_subramo,
	       _prima_devengada,
		   _prima_retenida,
		   _porc_partic	
	  from ramosubr222
  
	update ramosubrh
	   set prima_devengada = _prima_devengada,
	       prima_retenida = _prima_retenida,
		   porc_partic = _porc_partic
     where cod_ramo = _cod_ramo
	   and cod_subramo = _cod_subramo
	   and origen = 1
	   and periodo = '2025-01';
end foreach

foreach
	select cod_ramo,
	       cod_subramo,
	       prima_devengada,
		   prima_retenida,
		   porc_partic
	  into _cod_ramo,
	       _cod_subramo,
	       _prima_devengada,
		   _prima_retenida,
		   _porc_partic	
	  from ramootro222
  
	update ramootroh
	   set prima_devengada = _prima_devengada,
	       prima_retenida = _prima_retenida,
		   porc_partic = _porc_partic
     where cod_ramo = _cod_ramo
	   and cod_subramo = _cod_subramo
	   and origen = 1
	   and periodo = '2025-01';
end foreach
	   
return 0;
end
end procedure;