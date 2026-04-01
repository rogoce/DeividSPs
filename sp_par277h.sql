-- Procedimiento que genera las cancelaciones automaticas por perdida total
-- 
-- Creado     : 16/01/2009 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par277;

create procedure "informix".sp_par277()
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
define _estatus_poliza	smallint;
define _fecha_end_canc	date;

define _cancelada		smallint;
define _fecha_canc		date;
define _fecha_perdida	date;

-- Vigencia Actual
define _no_poliza2		char(10);
define _estatus_poliza2 smallint;
define _desc_estatus	char(10);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _descripcion		char(50);
define _cantidad		integer;

--set debug file to "sp_par184.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam, "", _error_desc, "", "", "", "";
end exception

let _cantidad = 0;
 
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

	-- Verifica que exista emireama y emireaco

	delete from emireaco
	 where no_poliza         = _no_poliza
	   and porc_partic_suma  = 0
	   and porc_partic_prima = 0;

	call sp_pro159(_no_poliza) returning _error, _descripcion;

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
			       fecha_cancelacion
			  into _estatus_poliza,
			       _fecha_end_canc
			  from emipomae
			 where no_poliza = _no_poliza;

			if _fecha_end_canc is null then
				let _fecha_end_canc = today;
			end if

			if _estatus_poliza = 2 then

				let _cancelada   = 0;
				let _fecha_canc  = _fecha_end_canc;
				let _descripcion = "Poliza ya fue Cancelada";

			else
			
				call sp_par278(_no_poliza, _user_added, 0.00) returning _error, _descripcion, _no_endoso;

				if _error <> 0 then

					let _cancelada   = 0;
					let _fecha_canc  = null;

				else

					let _cancelada   = 1;
					let _fecha_canc  = today;
					let _descripcion = "Poliza Cancelada";

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

			call sp_par280(_no_poliza, _no_unidad, _user_added, 0.00) returning _error, _descripcion, _no_endoso;

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

	if _cancelada = 1 then

		select no_factura
		  into _no_factura
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;
				
	else

		let _no_factura = null;

	end if

	update recpolpe
	   set procesada       = 1,
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

	if _estatus_poliza2 = 1 then
		let _desc_estatus = "Vigente";
	elif _estatus_poliza2 = 2 then
		let _desc_estatus = "Cancelada";
	elif _estatus_poliza2 = 3 then
		let _desc_estatus = "Vencida";
	elif _estatus_poliza2 = 4 then
		let _desc_estatus = "Anulada";
	end if

	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cantidad = 1 and _estatus_poliza2 = 1 then -- Cancelar la otra vigencia

		select * 
		  from recpolpe
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
		  into temp prueba;

		update prueba 
		   set no_poliza       = _no_poliza2,
			   procesada       = 0,
			   cancelada       = 0,
			   motivo          = "",
			   fecha_cancelada = null,
			   fecha_procesada = null,
			   no_factura	   = null
		 where no_poliza = _no_poliza;

		insert into recpolpe	--recargos
		select * 
		  from prueba
		 where no_poliza = _no_poliza2;

		drop table prueba;

		call sp_par277a(_no_poliza2) returning return "", "", "", "", "", "", "", "";

	elif _cantidad > 1 

		if _no_poliza <> _no_poliza2 then

			select * 
			  from recpolpe
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
			  into temp prueba;

			update prueba 
			   set no_poliza       = _no_poliza2,
				   procesada       = 0,
				   cancelada       = 0,
				   motivo          = "",
				   fecha_cancelada = null,
				   fecha_procesada = null,
				   no_factura	   = null
			 where no_poliza = _no_poliza;

			insert into recpolpe	--recargos
			select * 
			  from prueba
			 where no_poliza = _no_poliza2;

			drop table prueba;

			call sp_par277a(_no_poliza2) returning return "", "", "", "", "", "", "", "";
			
		end if		

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

end procedure