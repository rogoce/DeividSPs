-- Procedimiento que genera las cancelaciones de las polizas que estan con forma de pago "Cuentas Malas (082)"
-- 
-- Creado     : 24/09/2010 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par302;

create procedure "informix".sp_par302(
a_user_added	char(8)
) returning integer,
            char(100);

define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _no_factura		char(10);
define _periodo			char(7);
define _cod_pagador		char(10);

define _prima_neta		dec(16,2);
define _prima_suscrita	dec(16,2);
define _impuesto		dec(16,2);

define _descripcion		char(50);
define _cantidad		integer;
define _fecha			date;
define _desc_mala_ref	char(250);
define _no_canc			char(10);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--set debug file to "sp_par302.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

let _fecha = today;

select max(no_canc)
  into _no_canc
  from emicaninc
 where fecha_canc = _fecha;

if _no_canc is null then

	let _no_canc = sp_sis13("001", "PRO", "02", "par_no_canc_inc");

end if

let _cantidad = 0;
 
foreach	with hold
 select no_documento,
		cod_cliente
   into _no_documento,
		_cod_pagador
   from cobcuema
  where cancelar    = 1
    and actualizado = 0

	let _cantidad    = _cantidad + 1;
	let _prima_bruta = sp_cob174(_no_documento);
	let _no_poliza   = sp_sis21(_no_documento);

	begin work;

	if _prima_bruta <= 0.00 then 

		let _no_factura = "00-00000";

	else

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

		call sp_par130(_no_poliza, a_user_added, _prima_bruta) returning _error, _descripcion, _no_endoso;

		if _error <> 0 then
			rollback work;
			return _error, _cantidad || " Registros " || trim(_no_documento) || " " || _descripcion with resume; 
			continue foreach;
		end if

		-- Actualizaciones

		select no_factura,
		       prima_neta,
			   prima_suscrita,
			   impuesto
		  into _no_factura,
		       _prima_neta,
			   _prima_suscrita,
			   _impuesto
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		{
		update endedmae
		   set periodo   = _periodo
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		update endedhis
		   set periodo   = _periodo
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;
		}
		
		update emipomae
		   set incobrable   = 1,
		       cod_formapag = "082"
		 where no_poliza    = _no_poliza;
		   					
		select desc_mala_ref
		  into _desc_mala_ref
		  from cliclien
		 where cod_cliente = _cod_pagador;

		if _desc_mala_ref is null then

			let _desc_mala_ref = "CUENTAS INCOBRABLES POLIZA: " || _no_documento; 

		else

			if length(_desc_mala_ref) < 213 then

				let _desc_mala_ref = trim(_desc_mala_ref) || "; CUENTAS INCOBRABLES POLIZA: " || _no_documento;

			end if

		end if

		update cliclien
		   set mala_referencia = 1,
		       desc_mala_ref   = _desc_mala_ref
		 where cod_cliente     = _cod_pagador;

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
		"CUENTAS INCOBRABLES, NO: " || _no_canc || " DEL: " || _fecha,
		a_user_added,
		_no_documento,
		null,
		0,
		null,
		_cod_pagador
		);

	end if

	insert into emicaninc(
	no_canc,
	fecha_canc,
	no_documento,
	saldo,
	no_factura,
	prima_neta,
	impuesto,
	prima_suscrita
	)		
	values(
	_no_canc,
	_fecha,
	_no_documento,
	_prima_bruta,
	_no_factura,
	_prima_neta,
	_impuesto,
	_prima_suscrita
	);

	update cobcuema
	   set actualizado  = 1,
	       user_cancelo = a_user_added,
		   date_cancelo = _fecha
	 where no_documento = _no_documento;

	commit work;
--	rollback work;

	if _cantidad >= 10 then
		exit foreach;
	end if

end foreach

--rollback work;

end 

return 0, "Actualizacion Exitosa " || _cantidad || " Registros Procesados"; 

end procedure