-- Procedimiento que genera las cancelaciones por lote de las polizas con saldo dados por VPE
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
-- Modificado : 20/09/2016 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par184bk;
create procedure sp_par184bk()
returning integer,
          char(100),
		  char(10),
		  decimal(16,2);

define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _saldo			dec(16,2);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _no_factura		char(10);
define _periodo			char(7);
define _estatus_poliza	smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _descripcion		char(50);
define _cantidad		integer;
define _cod_pagador		char(10);

--set debug file to "sp_par184.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc,'',0;
end exception

let _cantidad    = 0;

foreach
	select distinct poliza
	  into _no_documento
	  from deivid_tmp:temp_venc2021abr
	 order by poliza

	let _cantidad  = _cantidad + 1;
	let _no_poliza = sp_sis21(_no_documento);
	let _saldo	   = sp_cob174(_no_documento);

		-- Solicitud de Jesica Miller
		-- No cancelar polizas que se encuentran vigentes
		-- 20 / Mayo / 2013
		-- Demetrio Hurtado	Almanza

--			if _saldo > 1 then
				{select min(no_unidad)
                  into _no_unidad
				  from emipouni
				 where no_poliza = _no_poliza;
				
				update emipocob
				   set prima_neta = _saldo
                 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
					and orden = 1;
					update deivid_tmp:temp_venc2021ene
					   set cancelada = 0
					  where poliza = _no_documento; }
				return 1, _no_documento, _no_poliza,_saldo with resume; 	
		--	end if
end foreach
end 
return 0, "Actualizacion Exitosa " || _cantidad || " Registros Procesados",'',0; 

end procedure