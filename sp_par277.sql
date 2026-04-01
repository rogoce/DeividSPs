-- Procedimiento que genera las cancelaciones automaticas por perdida total
-- 
-- Creado     : 16/01/2009 - Autor: Demetrio Hurtado Almanza
-- Modificado : 01/10/2010 - Autor: Henry Giron se copio el que existia en BD produccion que no presentaba error
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par277;
create procedure sp_par277()
returning char(20),
          char(10),
          date,
          char(50),
          char(8),
          date,
          char(5),
          char(10);

define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _no_poliza		char(10);
define _no_unidad		char(5);
define _no_endoso		char(5);
define _no_factura		char(10);
define _user_added		char(8);
define _no_motor		char(30);
define _estatus_poliza	smallint;
define _cancelada		smallint;
define _procesada		smallint;
define _descripcion		char(50);
define _error_desc		char(50);
define _desc_estatus	char(10);
define _no_poliza2		char(10);
define _cod_compania    char(3);
define _cod_sucursal    char(3);
define _cod_formapago   char(3);
define v_saldo          dec(16,2);
define _error_isam		integer;
define _cantidad		integer;
define _error			integer;
define _estatus_poliza2 smallint;
define _fecha_perdida	date;
define _fecha_canc		date;
define _fecha_end_canc	date;

--set debug file to "sp_par277.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam, "", _error_desc, "", "", "", "";
end exception

let _cantidad = 0;
let _no_motor = "";
 
foreach	
	select no_poliza,
		   no_unidad,
		   user_added,
		   no_documento,
		   fecha_perdida
	  into _no_poliza,
		   _no_unidad,
		   _user_added,
		   _no_documento,
		   _fecha_perdida
	  from recpolpe
	 where procesada = 0
	 order by 1,2

	-- Verifica que exista emireama y emireaco
	delete from emireaco
	 where no_poliza         = _no_poliza
	   and porc_partic_suma  = 0
	   and porc_partic_prima = 0;

	call sp_pro159(_no_poliza) returning _error, _descripcion; --Crea Dist. de Reasguro.


	-- Cantidad de Unidades
	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cantidad = 1 then -- Cancelacion de Poliza

		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _cantidad = 0 then		
			let _cancelada   = 0;
			let _fecha_canc  = today;
			let _descripcion = "Unidad ya fue Eliminada";
		else
			select estatus_poliza,
			       fecha_cancelacion,
				   cod_compania,
				   cod_sucursal,
				   cod_formapag
			  into _estatus_poliza,
			       _fecha_end_canc,
				   _cod_compania,
				   _cod_sucursal,
				   _cod_formapago
			  from emipomae
			 where no_poliza = _no_poliza;

			if _fecha_end_canc is null then
				let _fecha_end_canc = today;
			end if

			if _estatus_poliza in(2,4) then
				let _cancelada   = 0;
				let _fecha_canc  = _fecha_end_canc;
				let _descripcion = "Poliza ya fue Cancelada";
			else			
				call sp_par278(_no_poliza, _user_added, 0.00) returning _error, _descripcion, _no_endoso;
				if _descripcion is null then
					let _descripcion = 'ERROR';
				end if
				if _error <> 0 then
					let _cancelada   = 0;
					let _fecha_canc  = null;
				else
					let _cancelada   = 1;
					let _fecha_canc  = today;
					let _descripcion = "Poliza Cancelada";
				end if
				-- buscando el saldo de la poliza  
				call sp_cob174(_no_documento)RETURNING v_saldo;

				if _cod_formapago = '003' or _cod_formapago = '005' then
					-- cambio de plan de pago
					call sp_pro531(_no_poliza,_user_added,	v_saldo, _cod_compania, _cod_sucursal,'006') RETURNING _error, _descripcion;
					if _descripcion is null then
						let _descripcion = 'ERROR';
					end if
					if _error <> 0 then
						return _error,'','',_descripcion,'','','','';
					end if
				end if
			end if
		end if
	else -- Eliminacion de Unidades
		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _cantidad = 0 then		
			let _cancelada   = 0;
			let _fecha_canc  = today;
			let _descripcion = "Unidad ya fue Eliminada";
		else
			select no_motor
			  into _no_motor
			  from emiauto 
			 where no_poliza = _no_poliza 
			   and no_unidad = _no_unidad;
			   
			call sp_par280(_no_poliza, _no_unidad, _user_added, 0.00) returning _error, _descripcion, _no_endoso;
			if _descripcion is null then
				let _descripcion = 'ERROR';
			end if
			if _error <> 0 then
				let _descripcion = _error || " " || trim(_descripcion);
				let _cancelada   = 0;
				let _fecha_canc  = null;
			else
				let _cancelada   = 1;
				let _fecha_canc  = today;
				let _descripcion = "Unidad Eliminada";
			end if
		end if
	end if

	-- La Poliza se Cancelo
	if _cancelada = 1 then
		select no_factura
		  into _no_factura
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;				
	else
		let _no_factura = null;
	end if

	-- No Hubo error en el proceso
	if _error = 0 then
		let _procesada   = 1;
	else
		let _procesada   = 0;
		let _descripcion = "ERROR: " || trim(_descripcion);
	end if
	
	-- Actualizacion de la Tabla para cancelar

	update recpolpe
	   set procesada       = _procesada,
	       cancelada       = _cancelada,
		   fecha_cancelada = _fecha_canc,
		   fecha_procesada = today,
		   motivo          = _descripcion,
	       no_factura      = _no_factura
	 where no_poliza       = _no_poliza
	   and no_unidad	   = _no_unidad;

	if _no_factura is null then
		let _no_factura = "";
	end if

	let _no_poliza2 = sp_sis21(_no_documento);

	select estatus_poliza
	  into _estatus_poliza2
	  from emipomae
	 where no_poliza = _no_poliza2;

{
	if _estatus_poliza2 = 1 then
		let _desc_estatus = "Vigente";
	elif _estatus_poliza2 = 2 then
		let _desc_estatus = "Cancelada";
	elif _estatus_poliza2 = 3 then
		let _desc_estatus = "Vencida";
	elif _estatus_poliza2 = 4 then
		let _desc_estatus = "Anulada";
	end if
}
	if _estatus_poliza2 = 1 and _no_poliza <> _no_poliza2 then
		call sp_par335(_no_poliza2, _user_added, _no_motor, _no_unidad) RETURNING _error, _descripcion;	-- Cancelacion por Perdida Total  Vigencia Renovada
		if _error <> 0 then
			let _descripcion = _error || " " || trim(_descripcion);
		else
			select estatus_poliza
			  into _estatus_poliza2
			  from emipomae
			 where no_poliza = _no_poliza2;
		end if
	end if

	if _estatus_poliza2 = 1 then
		let _desc_estatus = "Vigente";
	elif _estatus_poliza2 = 2 then
		let _desc_estatus = "Cancelada";
	elif _estatus_poliza2 = 3 then
		let _desc_estatus = "Vencida";
	elif _estatus_poliza2 = 4 then
		let _desc_estatus = "Anulada";
	end if

	return _no_documento,
	       _no_factura,
		   today,
		   _descripcion,
		   _user_added,
		   _fecha_perdida,
		   _no_unidad,
		   _desc_estatus
		   with resume;
end foreach
end
end procedure;