-- Procedimiento que Actualiza los datos para las cotizaciones de polizas en emisiones electronicas-- 
-- Creado    : 29/08/2012 - Autor: Roman Gordon 
-- Nota: es una copia del sp_sis107 solo que no toma en cuenta si la ruta es web o no.

-- SIS v.2.0 - DEIVID, S.A.


drop procedure ap_act_eeuu;

create procedure ap_act_eeuu()
returning integer, char(50);

define _error_desc		char(50);
define _periodo			char(7);
define _cod_contrato    char(5);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _cod_ruta		char(5);
define _cod_cober_reas  char(3);
define _cod_compania	char(3);
define _cod_ramo		char(3);
define _suma_asegurada	dec(16,2);
define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _prima_neta		dec(16,2);
define _porc_par_prima	dec(9,6);
define _porc_par_suma	dec(9,6);
define _tipo_contrato	smallint;
define _cantidad		smallint;
define _serie			smallint;
define _orden			smallint;
define _error_isam		integer;
define _error			integer;
define _vig_ini         date;
define _valor           smallint;
define _no_poliza       char(10);
define li_return        integer;

set isolation to dirty read; 

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception
 
--set debug file to "sp_sis107abk.trc"; 
--trace on; 
 
 
let _no_poliza = '0002281026';
let li_return = 0;
let _error_desc = '';

foreach
    select no_unidad,
	       limite_1
	  into _no_unidad,
	       _suma_asegurada
	  from emipocob
	 where no_poliza = _no_poliza
	   and cod_cobertura = '01892'
	--   and no_unidad = '00002'
	 
	update emipouni
	   set suma_asegurada = _suma_asegurada
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad; 
	   
	--Cargar el Reaseguro Individual de la Unidad
	call sp_sis107a(_no_poliza)	returning _error,_error_desc;

	if _error <> 0 then
		return _error,_error_desc;
	end if
	
	delete from emifacon
     where no_poliza   = _no_poliza
       and no_endoso  = '00000'
       and no_unidad  = _no_unidad
	   and porc_partic_prima = 0.00;

	--Actualizar los valores en las unidades
	call sp_proe02(_no_poliza, _no_unidad, '001') returning li_return;

	if li_return = 0 then
		let li_return = sp_proe03(_no_poliza,'001');
		
		if li_return <> 0 then
			return li_return,_error_desc;
		end if
	else
		return li_return,_error_desc;
	end if

	call sp_proe03(_no_poliza,'001') returning li_return;

	if li_return <> 0 then
		return li_return,'Error al Emitir la Póliza ';
	end if
	
	   
end foreach

end

return 0, "Actualizacion Exitosa";

end procedure;