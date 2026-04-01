-- Actualizacion para Reclamos de Salud

-- Creado    : 05/10/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 08/11/2001 - Autor: Demetrio Hurtado Almanza

--drop procedure sp_rec56_am;
create procedure sp_rec56_am(
a_cod_compania	char(3),
a_no_tranrec	char(10)
) returning integer,
          	char(100);

define _no_documento		char(20);
define _cod_reclamante		char(10);
define _no_reclamo			char(10);
define _no_poliza, _no_poliza_r			char(10);
define _cod_cober_sub		char(5);
define _cod_cober_cob		char(5);
define _cod_producto		char(5);
define _no_unidad			char(5);
define _ano_cal				char(4);
define _cod_tipo_cob		char(3);
define _cod_tipo_sub		char(3);
define _cod_ramo			char(3);
define _lim_anual_tipo		char(1);
define _lim_vit_tipo		char(1);
define _verif_coaseguro_ext	dec(16,2);
define _verif_coaseguro_loc	dec(16,2);
define _a_deducible_loc		dec(16,2);
define _a_deducible_ext		dec(16,2);
define _a_coaseguro_loc		dec(16,2);
define _a_coaseguro_ext		dec(16,2);
define _verif_deduc_loc		dec(16,2);
define _verif_deduc_ext		dec(16,2);
define _a_deducible			dec(16,2);
define _coaseguro			dec(16,2);
define _monto				dec(16,2);
define _rec_activar_salud	smallint;
define _maneja_stop_loss	smallint;
define _tipo_acum_deduc		smallint;
define _exterior			smallint;
define _ramo_sis			smallint;
define _ano_cal_int			integer;
define _cantidad			integer;
define _error				integer;
define _fecha_factura		date;
define _vigencia_inic		date;
define _fecha_sinies		date;
define _monto_deducible     dec(16,2);
define _monto_deducible2    dec(16,2);
define _no_endoso, _no_endoso_r           char(5);
define _reemplaza_poliza    char(20);

SET DEBUG FILE TO "sp_rec56.trc";  
TRACE ON;

set isolation to dirty read;

begin
on exception set _error 
 	return _error, "Error al Actualizar la Transaccion del Reclamo de Salud";         
end exception           

-- Lectura de Tablas Necesarias para el Proceso

select no_reclamo,
       fecha_factura
  into _no_reclamo,
       _fecha_factura
  from rectrmae
 where no_tranrec = a_no_tranrec;

select no_poliza,
       no_unidad,
	   cod_reclamante,
	   cod_cobertura,
	   cod_tipo,
	   no_documento,
	   fecha_siniestro
  into _no_poliza,
       _no_unidad,
	   _cod_reclamante,
	   _cod_cober_sub,
	   _cod_tipo_sub,
	   _no_documento,
	   _fecha_sinies
  from recrcmae
 where no_reclamo = _no_reclamo;

select vigencia_inic,
	   cod_ramo,
	   reemplaza_poliza
  into _vigencia_inic,
	   _cod_ramo,
	   _reemplaza_poliza
  from emipomae
 where no_poliza = _no_poliza;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

-- Solo para las Polizas de Salud
if _ramo_sis <> 5 Then
	return 0, "Actualizacion Exitosa ...";	
end if

select rec_activar_salud
  into _rec_activar_salud
  from parparam
 where cod_compania = a_cod_compania;

-- Solo Procesa las Transacciones Cuando esta Habilitada la Opcion
-- Automatica de los reclamos de salud

if _rec_activar_salud = 0 then
	return 0, "Actualizacion Exitosa ...";	
end if

let _no_endoso = null;
let _no_endoso_r = null;

foreach
	select no_endoso
	  into _no_endoso
	  from endedmae
	 where no_poliza = _no_poliza
	   and vigencia_inic <= _fecha_factura
	   and vigencia_final > _fecha_factura
	   and cod_endomov = '014'
end foreach

if _no_endoso is null then 
	if _reemplaza_poliza is not null and trim(_reemplaza_poliza) <> "" then
		select no_poliza 
		  into _no_poliza_r
		  from emipomae
		 where no_documento = _reemplaza_poliza;
		 
		foreach
			select no_endoso
			  into _no_endoso_r
			  from endedmae
			 where no_poliza = _no_poliza_r
			   and vigencia_inic >= _fecha_factura
			   and vigencia_final < _fecha_factura
			   and cod_endomov = '014'
		end foreach
		
		if _no_endoso_r is null then
			select cod_producto
			  into _cod_producto
			  from emipouni
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
		else
			select cod_producto
			  into _cod_producto
			  from endeduni
			 where no_poliza = _no_poliza_r
			   and no_endoso = _no_endoso_r
			   and no_unidad = _no_unidad;		
		end if
		   

	else
		select cod_producto
		  into _cod_producto
		  from emipouni
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
	end if
else
	select cod_producto
	  into _cod_producto
	  from endeduni
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and no_unidad = _no_unidad;
end if

if _cod_producto is null then
	foreach	
		select u.cod_producto
		  into _cod_producto
		  from endeduni	u, endedmae e
		 where u.no_poliza   = _no_poliza
		   and u.no_unidad   = _no_unidad
		   and u.no_poliza   = e.no_poliza
		   and u.no_endoso   = e.no_endoso
		   and e.actualizado = 1
		exit foreach;
	end foreach
else
	foreach
		select r.cod_producto
		  into _cod_producto
		  from endedmae e, endeduni r
		 where e.no_poliza = r.no_poliza
		   and e.no_endoso = r.no_endoso
		   and  e.no_poliza = _no_poliza
		   and e.vigencia_inic <= _fecha_factura
		   and e.vigencia_final >  _fecha_factura
		   and e.no_endoso >  _no_endoso
		   and e.cod_endomov = '029'			--tuvo endoso de cambio de producto
		   and r.no_unidad = _no_unidad
		   exit foreach;
	end foreach
	if _cod_producto is null then
		select cod_producto
		  into _cod_producto
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad;
	end if
end if

if _cod_producto is null then
	return 1, "No Existe Producto para la Unidad, Por Favor Verifique ...";
end if

select maneja_stop_loss,
       coaseguro_hasta,
	   coaseguro_fuera,
	   tipo_acum_deduc
  into _maneja_stop_loss,
       _verif_coaseguro_loc,
	   _verif_coaseguro_ext,
	   _tipo_acum_deduc
  from prdprod
 where cod_producto = _cod_producto;

let _ano_cal = year(_fecha_factura);

--Verificación de Deducible por Año Póliza
if _tipo_acum_deduc = 2 then
	if month(_vigencia_inic) > month(_fecha_factura) then
		let _ano_cal_int = _ano_cal;
		let _ano_cal_int = _ano_cal_int - 1;
		let _ano_cal = _ano_cal_int;
	elif month(_vigencia_inic) = month(_fecha_factura) then
		if day(_vigencia_inic) > day(_fecha_factura) then
			let _ano_cal_int = _ano_cal;
			let _ano_cal_int = _ano_cal_int - 1;
			let _ano_cal = _ano_cal_int;
		end if
	end if
end if

let _exterior = 0;

-- Eliminacion de las Coberturas no Utilizadas
set lock mode to wait 60;

delete from rectrcob
 where no_tranrec        = a_no_tranrec
   and facturado         = 0
   and elegible          = 0
   and a_deducible       = 0
   and co_pago           = 0
   and coaseguro         = 0
   and monto             = 0
   and variacion         = 0
   and monto_no_cubierto = 0
   and ahorro            = 0;

-- Actualizacion por Cobertura

set isolation to dirty read;

foreach
	select a_deducible,
		   coaseguro,
		   monto,
		   cod_cobertura,
		   cod_tipo
	  into _a_deducible,
		   _coaseguro,
		   _monto,
		   _cod_cober_cob,
		   _cod_tipo_cob
	  from rectrcob
	 where no_tranrec = a_no_tranrec

	-- Acumulacion de Monto a Deducible	
	if _a_deducible <> 0 then		
		if _cod_tipo_cob is not null then			
			select deducible_local,
				   deducible_fuera 
			  into _verif_deduc_loc,
				   _verif_deduc_ext
			  from prdcobsa
			 where cod_producto  = _cod_producto
			   and cod_cobertura = _cod_cober_cob
			   and cod_tipo      = _cod_tipo_cob;

			select exterior 
			  into _exterior
			  from prdticob
			 where cod_tipo = _cod_tipo_cob;
		else
			select exterior,
			       deducible_local,
				   deducible_fuera 
			  into _exterior,
				   _verif_deduc_loc,
				   _verif_deduc_ext
			  from prdcobpd
			 where cod_producto  = _cod_producto
			   and cod_cobertura = _cod_cober_cob;
		end if

		let _a_deducible_loc = 0.00;
		let _a_deducible_ext = 0.00;

		if _exterior = 1 then
			let _a_deducible_ext = _a_deducible;
		else
			let _a_deducible_loc = _a_deducible;
		end if

		select count(*)
		  into _cantidad
		  from recacuan
		 where no_documento  = _no_documento
		   and ano			 = _ano_cal	
		   and cod_cliente   = _cod_reclamante;

		if _cantidad is null then
			let _cantidad = 0;
		end if

		set lock mode to wait 60;

		if _cantidad = 0 then
			insert into recacuan(
					no_documento,
					ano,
					cod_cliente,
					monto_deducible,
					monto_coaseguro,
					no_unidad,
					monto_deducible2)
			values(	_no_documento,
					_ano_cal,
					_cod_reclamante,
					_a_deducible_loc,
					0,
					_no_unidad,
					_a_deducible_ext
					);
		else			   
			update recacuan
			   set monto_deducible  = monto_deducible  + _a_deducible_loc,
			       monto_deducible2 = monto_deducible2 + _a_deducible_ext
			 where no_documento     = _no_documento
			   and ano			    = _ano_cal	
			   and cod_cliente      = _cod_reclamante;
			   
			select monto_deducible,
			       monto_deducible2
			  into _monto_deducible,
			       _monto_deducible2
			  from recacuan
			 where no_documento     = _no_documento
			   and ano			    = _ano_cal	
			   and cod_cliente      = _cod_reclamante;
			   
			if _monto_deducible < 0 then
				update recacuan
				   set monto_deducible  = 0
				 where no_documento     = _no_documento
				   and ano			    = _ano_cal	
				   and cod_cliente      = _cod_reclamante;
           	end if		
			
			if _monto_deducible2 < 0 then
				update recacuan
				   set monto_deducible2 = 0
				 where no_documento     = _no_documento
				   and ano			    = _ano_cal	
				   and cod_cliente      = _cod_reclamante;
           	end if		
		end if

        set isolation to dirty read;

		-- Verificaciones para despues de Actualizar

		select monto_deducible,
		       monto_deducible2
		  into _a_deducible_loc,
		       _a_deducible_ext
		  from recacuan
		 where no_documento = _no_documento
		   and ano			= _ano_cal	
		   and cod_cliente  = _cod_reclamante;

		if _a_deducible_loc > _verif_deduc_loc then
			return 1, "Deducible Local Mayor al Limite " || _a_deducible_loc || " " || _verif_deduc_loc;
		end if

		if _a_deducible_ext > _verif_deduc_ext then
			return 1, "Deducible Exterior Mayor al Limite";
		end if
	end if

	-- Acumulacion para "Stop Loss" 
	-- Montos en Coaseguro Pagados por el Asegurado

	if _maneja_stop_loss = 1 and _coaseguro <> 0 then 
		if _cod_tipo_cob is not null then			
			select exterior 
			  into _exterior
			  from prdticob
			 where cod_tipo = _cod_tipo_cob;
		end if

--		if _cod_tipo_cob is not null then
--			let _exterior = 0;
--		end if

		let _a_coaseguro_ext = 0.00;
		let _a_coaseguro_loc = 0.00;

		if _exterior = 1 then
			let _a_coaseguro_ext = _coaseguro;
		else
			let _a_coaseguro_loc = _coaseguro;
		end if

		select count(*)
		  into _cantidad
		  from recacuan
		 where no_documento  = _no_documento
		   and ano			 = _ano_cal
		   and cod_cliente   = _cod_reclamante;

		if _cantidad is null then
			let _cantidad = 0;
		end if

		set lock mode to wait 60;

		if _cantidad = 0 then
			insert into recacuan(
			no_documento,
			ano,
			cod_cliente,
			monto_deducible,
			monto_coaseguro,
			no_unidad,
			monto_coaseguro2
			)
			values(
			_no_documento,
			_ano_cal,
			_cod_reclamante,
			0.00,
			_a_coaseguro_loc,
			_no_unidad,
			_a_coaseguro_ext
			);
		else
			update recacuan
			   set monto_coaseguro  = monto_coaseguro  + _a_coaseguro_loc,
				   monto_coaseguro2 = monto_coaseguro2 + _a_coaseguro_ext
			 where no_documento     = _no_documento
			   and ano			    = _ano_cal
			   and cod_cliente      = _cod_reclamante;
		end if

        set isolation to dirty read;

		-- Verificaciones para despues de Actualizar
		select monto_coaseguro,
		       monto_coaseguro2
		  into _a_coaseguro_loc,
		       _a_coaseguro_ext
		  from recacuan
		 where no_documento = _no_documento
		   and ano			= _ano_cal	
		   and cod_cliente  = _cod_reclamante;

--		TRACE ON;
		if _a_coaseguro_loc > _verif_coaseguro_loc then
			return 1, "Coaseguro Local Mayor al Limite";
		end if

		if _a_coaseguro_ext > _verif_coaseguro_ext then
			return 1, "Coaseguro Exterior Mayor al Limite";
		end if
	end if

	-- Acumulacion de Montos Pagados para Control de las Coberturas que 
	-- Tienen Restricciones por Sublimites

	if _cod_cober_sub is not null then
		if _cod_tipo_sub is not null then
			select lim_anual_tipo,
				   lim_vit_tipo
			  into _lim_anual_tipo,
				   _lim_vit_tipo
			  from prdcobsa
			 where cod_producto  = _cod_producto
			   and cod_cobertura = _cod_cober_sub
			   and cod_tipo      = _cod_tipo_sub;
		else		
			select lim_anual_tipo,
				   lim_vit_tipo
			  into _lim_anual_tipo,
				   _lim_vit_tipo
			  from prdcobpd
			 where cod_producto  = _cod_producto
			   and cod_cobertura = _cod_cober_sub;
		end if

		-- Acumulacion de Limites Anuales
		if _lim_anual_tipo = "A" then

			select count(*)
			  into _cantidad
			  from recacusu
			 where no_documento  = _no_documento
			   and ano			 = _ano_cal
			   and cod_cliente   = _cod_reclamante
			   and cod_cobertura = _cod_cober_sub;

			if _cantidad is null then
				let _cantidad = 0;
			end if

			set lock mode to wait 60;

			if _cantidad = 0 then
				insert into recacusu(
				no_documento,
				ano,
				cod_cliente,
				cod_cobertura,
				monto,
				no_unidad
				)
				values(
				_no_documento,
				_ano_cal,
				_cod_reclamante,
				_cod_cober_sub,
				_monto,
				_no_unidad
				);
			else
				update recacusu
				   set monto         = monto + _monto
				 where no_documento  = _no_documento
				   and ano			 = _ano_cal
				   and cod_cliente   = _cod_reclamante
				   and cod_cobertura = _cod_cober_sub;
			end if
       		set isolation to dirty read;
		end if

		-- Acumulacion de Limites Vitalicios

		if _lim_vit_tipo = "V" then

			select count(*)
			  into _cantidad
			  from recacuvi
			 where no_documento  = _no_documento
			   and cod_cliente   = _cod_reclamante
			   and cod_cobertura = _cod_cober_sub;

			if _cantidad is null then
				let _cantidad = 0;
			end if

			set lock mode to wait 60;

			if _cantidad = 0 then
				insert into recacuvi(
				no_documento,
				cod_cliente,
				cod_cobertura,
				monto,
				no_unidad
				)
				values(
				_no_documento,
				_cod_reclamante,
				_cod_cober_sub,
				_monto,
				_no_unidad
				);
			else
				update recacuvi
				   set monto         = monto + _monto
				 where no_documento  = _no_documento
				   and cod_cliente   = _cod_reclamante
				   and cod_cobertura = _cod_cober_sub;
			end if

       		set isolation to dirty read;			
		end if
	end if
end foreach
end

return 0, "Actualizacion Exitosa ...";
end procedure 