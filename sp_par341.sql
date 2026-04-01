-- Procedimiento que Simula los Registros Contables de Reclamos para el contrato C/P Auto
-- 
-- Creado     : 21/01/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado :	21/01/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par341;		

create procedure "informix".sp_par341()
returning integer,
		  char(100);									  

define a_no_tranrec 		char(10);
define _transaccion 		char(10);

define _cod_tipotran		char(3);
define _tipo_transaccion	smallint;
define _cod_compania		char(3);
define _par_ase_lider		char(3);
define _porc_coas			dec(16,2);
define _porc_coas_otras		dec(16,2);
define _porc_reas			dec(16,6);
define _no_reclamo			char(10);
define _fecha_reclamo		date;
define _monto				dec(16,2);
define _monto_cob			dec(16,2);
define _monto2				dec(16,2);
define _monto3				dec(16,2);
define _variacion_tot		dec(16,2);
define _variacion_cob		dec(16,2);
define _variacion_bru		dec(16,2);
define _variacion_net		dec(16,2);
define _no_poliza			char(10);
define _debito				dec(16,2);
define _credito				dec(16,2);
define _cuenta				char(25);
define _tipo_comp			smallint;
define _fecha_prov			date;
define _tipo_contrato       smallint;
define _cod_cobertura		char(5);
define _cod_cober_reas		char(3);
define _cuenta_cat			char(25);
define _porc_reas_cont		dec(16,6);
define _cod_contrato	 	char(5);
define _generar_cheque		smallint;

define _cod_traspaso	 	char(5);
define _traspaso   		 	smallint;
define _orden				smallint;
define _cod_coasegur		char(3);
define _consolida_mayor		smallint;
define _cod_origen			char(3);
define _cod_origen_aseg		char(3);
define _cod_auxiliar		char(5);
define _cod_ramo			char(3);
define _cod_subramo			char(3);
define _porc_cont_partic	dec(16,6);
define _cod_tipoprod		char(3);
define _cantidad			smallint;

define _fecha				date;
define _fecha_anulado		date;
define _periodo				char(7);
define _periodo2			char(7);
define _centro_costo		char(3);

define _error_cod			integer;
define _error_isam			integer;
define _error_desc			char(50);

--set debug file to "sp_par71.trc";

------------------------------------------------------------------------------
--                          Tipos de Comprobantes
------------------------------------------------------------------------------
-- 1. Reserva de Siniestros
-- 2. Siniestros Pagados
-- 3. Siniestros Coaseguradores
-- 4. Reaseguro Cedido - Siniestros Pagados
-- 5. Reaseguro Cedido - Salvamentos, Recuperos, Deducibles
-- 9. Consolidacion de Compañias

-- 10.	Comprobante de Reclamos Incendio
-- 11.	Comprobante de Reclamos Automovil
-- 12.	Comprobante de Reclamos Fianzas
-- 13.	Comprobante de Reclamos Personas
-- 14.	Comprobante de Reclamos Patrimoniales

------------------------------------------------------------------------------

begin 
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

create temp table tmp_asientos(
transaccion		char(10),
cuenta			char(25),
debito			dec(16,2),
credito			dec(16,2)
) with no log;

select par_ase_lider,
	   rec_fecha_prov	
  into _par_ase_lider,
       _fecha_prov
  from parparam 
 where cod_compania = "001";

foreach
 select no_tranrec
   into a_no_tranrec
   from camrecreaco
  where no_tranrec is not null
--    and no_tranrec = "1173281"

select cod_tipotran,
	   cod_compania,
	   no_reclamo,
	   monto,
	   variacion,
	   fecha,
	   periodo,
	   generar_cheque,
	   transaccion	
  into _cod_tipotran,
       _cod_compania,
	   _no_reclamo,
	   _monto,
	   _variacion_tot,
	   _fecha_anulado,
	   _periodo,
	   _generar_cheque,
	   _transaccion
  from rectrmae
 where no_tranrec = a_no_tranrec;

if _periodo >= "2013-10" then
	continue foreach;
end if

select sum(monto),
       sum(variacion)
  into _monto_cob,
       _variacion_cob
  from rectrcob
 where no_tranrec = a_no_tranrec;

if _monto_cob is null then
	let _monto_cob = 0.00;
end if

if _monto_cob <> _monto then
	return 1, "No Cuadra Sumatoria de Montos de Transaccion y Coberturas: " || a_no_tranrec;
end if

if _variacion_cob is null then
	let _variacion_cob = 0.00;
end if

if _variacion_cob <> _variacion_tot then
	return 1, "No Cuadra Sumatoria de Variacion de Transaccion y Coberturas: " || a_no_tranrec;
end if

select fecha_reclamo,
       no_poliza
  into _fecha_reclamo,
	   _no_poliza	
  from recrcmae
 where no_reclamo = _no_reclamo;

select cod_ramo,
       cod_subramo,
	   cod_origen,
	   cod_tipoprod
  into _cod_ramo,
       _cod_subramo,
	   _cod_origen,
	   _cod_tipoprod
  from emipomae
 where no_poliza = _no_poliza;

-- Tipo de Comprobante

if _cod_ramo in ("001", "003") then		
	let _tipo_comp = 10;				-- Incendio
elif _cod_ramo in ("002", "020") then	
	let _tipo_comp = 11;				-- Autos
elif _cod_ramo in ("008") then			
	let _tipo_comp = 12;				-- Fianzas
elif _cod_ramo in ("004", "016", "018", "019") then	
	let _tipo_comp = 13;				-- Personas
else
	let _tipo_comp = 14;				-- Patrimoniales
end if

-- Periodo y Fecha

let _periodo2 = sp_sis39(_fecha_anulado);

if _periodo = _periodo2 then
	let _fecha = _fecha_anulado;
elif _periodo > _periodo2 then
	let _fecha = MDY(_periodo[6,7], 1, _periodo[1,4]);
elif _periodo < _periodo2 then
	let _fecha = sp_sis36(_periodo);
end if

-- Centro de Costo

call sp_sac93(_no_poliza, 1) returning _error_cod, _error_desc, _centro_costo;

if _error_cod <> 0 then

	let _error_desc = "Error en sp_sac93" || " Poliza " || _no_poliza;
	return _error_cod, _error_desc;

end if

select tipo_transaccion
  into _tipo_transaccion
  from rectitra
 where cod_tipotran = _cod_tipotran;

select porc_partic_coas
  into _porc_coas
  from reccoas
 where no_reclamo   = _no_reclamo
   and cod_coasegur = _par_ase_lider; 

foreach
 select cod_cobertura,
        monto,
        variacion
   into _cod_cobertura,
        _monto_cob,
        _variacion_cob
   from rectrcob
  where no_tranrec = a_no_tranrec

	select cod_cober_reas
	  into _cod_cober_reas
	  from prdcober
	 where cod_cobertura = _cod_cobertura;

	select count(*)
	  into _cantidad
	  from rectrrea
	 where no_tranrec     = a_no_tranrec
	   and cod_cober_reas = _cod_cober_reas;

	if _cantidad = 0 then

		select count(*)
		  into _cantidad
		  from rectrrea
		 where no_tranrec     = a_no_tranrec;

		if _cantidad = 1 then

			select cod_cober_reas
			  into _cod_cober_reas
			  from rectrrea
			 where no_tranrec     = a_no_tranrec;
		
		else

			return 1, "No hay Distribucion de Reaseguro para la Transaccion: " || a_no_tranrec || " " || _cod_cober_reas;

		end if

	end if

	select porc_partic_suma
	  into _porc_reas
	  from rectrrea
	 where no_tranrec     = a_no_tranrec
	   and cod_cober_reas = _cod_cober_reas
	   and tipo_contrato  = 1;

	if _porc_reas is null then
		let _porc_reas = 0;
	end if;

	-- Reserva de Siniestros

	let _variacion_bru = _variacion_cob / 100 * _porc_coas;
	let _variacion_net = _variacion_bru / 100 * _porc_reas;

	-- Reserva de Siniestros en Tramite

	if _variacion_bru <> 0.00 then

		let _debito  = 0.00;
		let _credito = 0.00;
		let _monto2  = _variacion_bru * -1;

		if _monto2 > 0.00 then
			let _debito  = _monto2;
		else
			let _credito = _monto2;
		end if
			
		let _cuenta    = sp_sis15('RPRDSET', '01', _no_poliza);
		
		insert into tmp_asientos (transaccion, cuenta, debito, credito)
		values (_transaccion, _cuenta, _debito, _credito);

	end if

	-- Reserva de Siniestros Monto Recuperable

	let _monto2 = _variacion_bru - _variacion_net;

	if _monto2 <> 0.00 then

		let _debito  = 0.00;
		let _credito = 0.00;

		if _monto2 >= 0.00 then
			let _debito  = _monto2;
		else
			let _credito = _monto2;
		end if

		let _cuenta    = sp_sis15('RPRDSMR', '01', _no_poliza);

		select count(*)
		  into _cantidad
		  from recasien
		 where no_tranrec  = a_no_tranrec
		   and cuenta[1,3] = "222";

		if _cantidad <> 0 then
			return 1, "Ya Hay Asientos para Transaccion: " || a_no_tranrec with resume;
		end if

		insert into tmp_asientos (transaccion, cuenta, debito, credito)
		values (_transaccion, _cuenta, _debito, _credito);

	end if

	-- Aumento/Disminucion de Reserva

	if _variacion_net <> 0.00 then

		let _debito  = 0.00;
		let _credito = 0.00;

		if _variacion_net >= 0.00 then
			let _debito  = _variacion_net;
		else
			let _credito = _variacion_net;
		end if

		let _cuenta    = sp_sis15('RGADRST', '01', _no_poliza);

		insert into tmp_asientos (transaccion, cuenta, debito, credito)
		values (_transaccion, _cuenta, _debito, _credito);

	end if


end foreach

--{
select sum(debito + credito)
  into _monto
  from tmp_asientos 
 where transaccion = _transaccion;

If _monto <> 0.00 Then

	return 1, "Asientos No Cuadran Transaccion " || _transaccion;

End If
--}

end foreach

end

return 0, "Actualizacion Exitosa ...";

end procedure;




