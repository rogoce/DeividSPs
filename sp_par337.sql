-- Procedimiento que genera las cancelaciones por lote de las polizas SODA sin ningun pago
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par337;

create procedure "informix".sp_par337()
returning integer,
          char(100);

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
define _cant_pagos		integer;
define _cod_pagador		char(10);
define _user_added		char(8);

--set debug file to "sp_par184.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

let _cantidad   = 0;
let _user_added = "GERENCIA";
let _periodo    = "2013-08";

-- el procedure sp_par333 borra los duplicados

foreach	with hold
 select poliza
   into _no_documento
   from deivid_tmp:tmp_cancsodaago2013
  where cancelada = 0
--    and poliza    = "2009-10265-01"  
  order by poliza

	let _cantidad    = _cantidad + 1;
	let _no_poliza   = sp_sis21(_no_documento);
	let _saldo	     = sp_cob174(_no_documento);

	select count(*)
	  into _cant_pagos
	  from cobredet
	 where actualizado = 1
	   and no_poliza   = _no_poliza;

	--{	   
	begin work;

		if _cant_pagos = 0 then

			if _saldo > 0 then 

				-- Verifica que exista emireama y emireaco

				delete from emireaco
				 where no_poliza         = _no_poliza
				   and porc_partic_suma  = 0
				   and porc_partic_prima = 0;

				call sp_pro159(_no_poliza) returning _error, _descripcion;

				if _error <> 0 then
					rollback work;
					return _error, _cantidad || " Registros " || trim(_no_documento) || " " || _descripcion with resume;
					continue foreach;
				end if

				-- Actualiza los datos de la Poliza

				foreach	
				 select no_unidad
				   into _no_unidad
				   from emipouni
				  where no_poliza = _no_poliza

					call sp_proe02(_no_poliza, _no_unidad, "001") returning _error;

					if _error <> 0 then
						rollback work;
						return _error, _cantidad || " Registros " || trim(_no_documento) || " " || "Actualizando los Datos de la Unidad (sp_proe02)" with resume; 
						continue foreach;
					end if

				end foreach

				call sp_proe03(_no_poliza, "001") returning _error;

				if _error <> 0 then
					rollback work;
					return _error, _cantidad || " Registros " || trim(_no_documento) || " " || "Actualizando los Datos de la Poliza (sp_proe03)" with resume; 
					continue foreach;
				end if

				-- Actualiza el endoso

				update emipomae
				   set estatus_poliza = 1
				 where no_poliza      = _no_poliza;

				-- Proceso de Renovacion

				let _error = sp_sis61d(_no_poliza);

				if _error <> 0 then
					rollback work;
					return _error, _cantidad || " Registros " || trim(_no_documento) || " " || "No Se Pudo Eliminar del Proceso de Renovacion" with resume; 
					continue foreach;
				end if
						 
				call sp_par130(_no_poliza, _user_added, _saldo) returning _error, _descripcion, _no_endoso;

				if _error <> 0 then
					rollback work;
					return _error, _cantidad || " Registros " || trim(_no_documento) || " " || _descripcion with resume; 
					continue foreach;
				end if

				-- Actualizaciones

				select no_factura,
				       prima_bruta
				  into _no_factura,
				       _prima_bruta
				  from endedmae
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso;

				if _prima_bruta > 0.1 then
					rollback work;
					let _descripcion = "Prima Bruta Errada " || _prima_bruta;
					return 1, _cantidad || " Registros " || trim(_no_documento) || " " || _descripcion with resume; 
					continue foreach;
				end if

				select cod_pagador
				  into _cod_pagador
				  from emipomae
				 where no_poliza = _no_poliza;

				insert into cobgesti(
				no_poliza,
				fecha_gestion,
				desc_gestion,
				user_added,
				no_documento,
				fecha_aviso,
				tipo_aviso,
				cod_gestion,
				cod_pagador
				)
				values(
				_no_poliza,
				current,
				"CANCELACION DE LA POLIZA POR NO TOMADA",
				_user_added,
				_no_documento,
				null,
				0,
				null,
				_cod_pagador
				);

			else

				let _no_factura = "00-00000";

			end if

		else

			let _no_factura = "00-00000";

		end if
	
		-- Actualizaciones Finales 
				
		update deivid_tmp:tmp_cancsodaago2013
		   set cancelada  = 1,
		       no_factura = _no_factura,
			   saldo      = _saldo,
			   no_pagos   = _cant_pagos
		 where poliza     = _no_documento;

		if _no_factura <> "00-00000" then

			update endedmae
			   set periodo      = _periodo,
			       cod_tipocan  = "024",
				   cod_tipocalc = "004"
			 where no_factura   = _no_factura;

			update endedhis
			   set periodo      = _periodo,
			       cod_tipocan  = "024",
				   cod_tipocalc = "004"
			 where no_factura   = _no_factura;
	
		end if

--	rollback work;
	commit work;
	--}

--	return _cant_pagos, " Poliza " || _no_documento || " Saldo " || _saldo with resume; 

	if _cantidad >= 10 then
		exit foreach;
	end if

end foreach

end 

return 0, "Actualizacion Exitosa " || _cantidad || " Registros Procesados"; 

end procedure