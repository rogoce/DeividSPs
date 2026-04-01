-- Procedimiento que verifica a detalle las diferencias entre la cuenta tecnica y cuentas en sac en Reclamos
-- Creado : 08/01/2015 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac248;
create procedure informix.sp_sac248(
a_compania  char(3), 
a_agencia   char(3), 
a_periodo1  char(7), 
a_periodo2  char(7),
a_cod_ramo	varchar(100),
a_cuenta    varchar(100))
returning	varchar(50)		as compania,
			varchar(50)		as nom_cuenta,
			char(18)		as cuenta,			
			char(3)			as origen,
			dec(16,2)		as db,
			dec(16,2)		as cr,
			dec(16,2)		as monto_tecnico,
			integer			as sac_notrx,
			char(10)		as no_remesa,
			integer     	as renglon,
			char(10)		as transaccion,
			varchar(255)	as descripcion;

define _error_desc			varchar(255);
define _descripcion			varchar(255);
define v_compania_nombre	varchar(50);
define _nom_cuenta			varchar(50);
define _cuenta				char(18);
define _res_comprobante		char(15);
define _transaccion         char(10);
define _no_reclamo          char(10);
define _no_tranrec			char(10);
define _no_poliza			char(10);
define _no_remesa           char(10);
define _res_origen          char(3);
define _cod_ramo			char(3);
define _tipo		        char(1);
define v_recupero_bruto		dec(16,2);
define v_incurrido_bru		dec(16,2);
define _prima_suscrita		dec(16,2);
define v_pagado_bruto1		dec(16,2);
define v_reserva_bruto		dec(16,2);
define _monto_tecnico		dec(16,2);
define v_pagado_bruto		dec(16,2);
define v_reserva_neto		dec(16,2);
define _mto_cobasien		dec(16,2);
define _mto_recasien		dec(16,2);
define v_salv_bruto			dec(16,2);
define v_dec_bruto			dec(16,2);
define _res_db				dec(16,2);
define _res_cr				dec(16,2);
define _monto				dec(16,2);
define _dif					dec(16,2);
define _db					dec(16,2);
define _cr					dec(16,2);
define _cnt_cglresumen		smallint;
define _res_notrx           integer;
define _sac_notrx           integer;
define _renglon				integer;
define _error				integer;
define _cnt                 integer;
define _fechatrx_inic		date;
define _fechatrx_fin		date;


drop table if exists tmp_salida;

let v_compania_nombre = sp_sis01(a_compania);
let _prima_suscrita = 0;
let _mto_cobasien = 0;
let _mto_recasien = 0;
let _res_db = 0;
let _res_cr = 0;
let _monto = 0;
let _dif = 0;
let _db = 0;
let _cr = 0;

create temp table tmp_salida(
no_tranrec		char(10),
no_reclamo		char(10),
monto			dec(16,2),
cuenta			char(18)) with no log;

drop table if exists tmp_codigos;
drop table if exists tmp_contable;

let _fechatrx_inic = sp_sis36bk(a_periodo1); --retorna 01/11/2015 si el periodo es 2015-11
let _fechatrx_fin = sp_sis36(a_periodo1);   --retorna 30/11/2015 si el periodo es 2015-11

--let _cuenta = a_cuenta || ';';
call sp_sac246(a_compania,a_agencia,a_periodo1,a_periodo2,a_cuenta) returning _error, _error_desc;

if _error <> 0 then
	return 'Cuadre Contable, Error: ' || trim(_error_desc),'',a_cuenta,'',0.00,0.00,0.00,_error,'',0,'','';
end if

--let _fecha1 = sp_sis36bk(a_periodo1); --retorna 01/11/2015 si el periodo es 2015-11
--let _fecha2 = sp_sis36(a_periodo1);   --retorna 30/11/2015 si el periodo es   2015-11

let _error_desc = sp_rec01d(a_compania, a_agencia, a_periodo1, a_periodo2);

--Filtro por Ramo
if a_cod_ramo <> "*" then
	let _tipo = sp_sis04(a_cod_ramo); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo not in(select codigo from tmp_codigos);
	else
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo in(select codigo from tmp_codigos);
	end if
	drop table if exists tmp_codigos;
end if

{foreach
	select no_reclamo
	  into _no_reclamo
	  from tmp_sinis 
	 group by no_reclamo
	 order by no_reclamo

	foreach
		select no_tranrec,
			   cod_tipotran,
			   monto
		  into _no_tranrec,
			   _cod_tipotran,
			   _monto
		  from rectrmae
		 where cod_compania = a_compania
		   and actualizado  = 1
		   and cod_tipotran in ('004','005','006','007')
		   and periodo      >= a_periodo1 
		   and periodo      <= a_periodo2
		   and no_reclamo   = _no_reclamo
		   and monto        <> 0

		insert into tmp_salida(
				no_tranrec,
				cod_tipotran,
				no_reclamo,
				monto)
		values(	_no_tranrec,
				_cod_tipotran,
				_no_reclamo,
				_monto);
	end foreach			
end foreach}

--Carga de datos del area técnica por cuenta 
foreach
	select no_poliza,
		   cod_ramo,
		   no_reclamo,
		   no_tranrec,
		   sum(incurrido_bruto),
		   sum(pagado_bruto),
		   sum(reserva_bruto),
		   sum(reserva_neto),
		   sum(pagado_bruto1),
		   sum(salvamento_bruto),
		   sum(recupero_bruto),
		   sum(deducible_bruto)
	  into _no_poliza,
		   _cod_ramo,
		   _no_reclamo,
		   _no_tranrec,
		   v_incurrido_bru,
		   v_pagado_bruto,
		   v_reserva_bruto,
		   v_reserva_neto,
		   v_pagado_bruto1,
		   v_salv_bruto,
		   v_recupero_bruto,
		   v_dec_bruto
	  from tmp_sinis
	 where seleccionado = 1
	 group by cod_ramo,no_poliza,no_reclamo,no_tranrec
	 order by cod_ramo,no_poliza,no_reclamo,no_tranrec

	-- Reserva de Siniestros en Tramite Cuenta 222
	if v_reserva_bruto is null then
		let v_reserva_bruto = 0.00;
	end if
	
	if v_reserva_neto is null then
		let v_reserva_neto = 0.00;
	end if
	
	if (v_reserva_bruto - v_reserva_neto) <> 0.00 then
		let _cuenta = sp_sis15('RPRDSMR', '01', _no_poliza);

		insert into tmp_salida(
				no_tranrec,
				no_reclamo,
				monto,
				cuenta)
		values(	_no_tranrec,
				_no_reclamo,
				v_reserva_bruto - v_reserva_neto,
				_cuenta);
	end if

	-- Reserva de Siniestros Monto Recuperable --Cuenta 221
	if v_reserva_bruto is null then
		let v_reserva_bruto = 0.00;
	end if

	if v_reserva_bruto <> 0.00 then
		let _cuenta = sp_sis15('RPRDSET', '01', _no_poliza);

		insert into tmp_salida(
				no_tranrec,
				no_reclamo,
				monto,
				cuenta)
		values(	_no_tranrec,
				_no_reclamo,
				v_reserva_bruto,
				_cuenta);
	end if

	-- Aumento/Disminucion de Reserva	Cuenta 553	
	if v_reserva_neto is null then
		let v_reserva_neto = 0.00;
	end if

	if v_reserva_neto <> 0.00 then
		let _cuenta = sp_sis15('RGADRST', '01', _no_poliza);

		insert into tmp_salida(
				no_tranrec,
				no_reclamo,
				monto,
				cuenta)
		values(	_no_tranrec,
				_no_reclamo,
				v_reserva_neto,
				_cuenta);
	end if

	-- Siniestros Pagados Cuenta 541	
	if v_pagado_bruto1 is null then
		let v_pagado_bruto1 = 0.00;
	end if

	if v_dec_bruto is null then
		let v_dec_bruto = 0.00;
	end if

	if (v_pagado_bruto1 + v_dec_bruto) <> 0.00 then
		let _cuenta = sp_sis15('RGSP', '01', _no_poliza);

		insert into tmp_salida(
				no_tranrec,
				no_reclamo,
				monto,
				cuenta)
		values(	_no_tranrec,
				_no_reclamo,
				v_pagado_bruto1 + v_dec_bruto,
				_cuenta);
	end if
	
	-- Salvamentos y Recupero Cuenta 419
	if v_recupero_bruto is null then
		let v_recupero_bruto = 0.00;
	end if
	
	if v_salv_bruto is null then
		let v_salv_bruto = 0.00;
	end if
	
	if (v_recupero_bruto + v_salv_bruto) <> 0.00 then
		let _cuenta = sp_sis15('SISAL', '01', _no_poliza);

		insert into tmp_salida(
				no_tranrec,
				no_reclamo,
				monto,
				cuenta)
		values(	_no_tranrec,
				_no_reclamo,
				v_recupero_bruto + v_salv_bruto,
				_cuenta);
	end if	
end foreach

if a_cuenta <> "*" then
	let _tipo = sp_sis04(a_cuenta); -- separa los valores del string
end if

foreach
	select no_tranrec,
		   no_reclamo,
		   monto,
		   cuenta
	  into _no_tranrec,
		   _no_reclamo,
		   _monto,
		   _cuenta
	  from tmp_salida
	 where cuenta in (select codigo from tmp_codigos)
	 order by 1

	select count(*)
	  into _cnt
	  from recasien
	 where no_tranrec = _no_tranrec
	   and cuenta in (_cuenta);

	if _cnt is null then
		let _cnt = 0;
	end if

	let _cnt_cglresumen = 0;

	if _cnt = 0 then
		foreach
			select no_remesa,
				   renglon,
				   prima_neta
			  into _no_remesa,
				   _renglon,
				   _monto_tecnico
			  from cobredet
			 where actualizado = 1
			   and no_tranrec = _no_tranrec --no_reclamo = _no_reclamo

			select count(*)
			  into _cnt
			  from cobasien
			 where no_remesa = _no_remesa
			   and renglon   = _renglon
			   and cuenta in (_cuenta);

			if _cnt is null then
				let _cnt = 0;
			end if

			if _cnt = 0 then
				insert into tmp_contable(
						cuenta,
						no_tranrec,
						db,
						cr,
						sac_notrx,
						origen,
						monto_tecnico,
						no_remesa,
						renglon,
						descripcion)
				values(	_cuenta,
						_no_tranrec,
						0.00,
						0.00,
						'',
						'',
						_monto_tecnico,
						_no_remesa,
						_renglon,
						'NO EXISTEN ASIENTOS PARA LA REMESA');
			else
				foreach
					select sac_notrx,
						   debito-credito
					  into _sac_notrx,
						   _monto_tecnico
					  from cobasien
					 where no_remesa = _no_remesa
					   and renglon   = _renglon
					   and cuenta in (_cuenta)

					select count(*)
					  into _cnt_cglresumen
					  from cglresumen
					 where res_notrx = _sac_notrx
					   and res_cuenta = _cuenta
					   and res_fechatrx >= _fechatrx_inic
					   and res_fechatrx <= _fechatrx_fin;

					if _cnt_cglresumen is null then
						let _cnt_cglresumen = 0;
					end if

					if _cnt_cglresumen = 0 then
						insert into tmp_contable(
								cuenta,
								no_remesa,
								renglon,
								no_tranrec,
								db,
								cr,
								sac_notrx,
								origen,
								monto_tecnico,
								descripcion)
						values(	_cuenta,
								_no_remesa,
								_renglon,
								_no_tranrec,
								0.00,
								0.00,
								_sac_notrx,
								'',
								_monto_tecnico,
								'NO EXISTEN COMPROBANTES DE LA REMESA PARA EL PERIODO: ' || a_periodo1);
					end if
				end foreach
			end if
		end foreach
	else
		foreach
			select sac_notrx,
				   debito+credito
			  into _sac_notrx,
				   _monto_tecnico
			  from recasien
			 where no_tranrec = _no_tranrec
			   and cuenta in (_cuenta)

			select count(*)
			  into _cnt_cglresumen
			  from cglresumen
			 where res_notrx = _sac_notrx
			   and res_cuenta = _cuenta
			   and res_fechatrx >= _fechatrx_inic
			   and res_fechatrx <= _fechatrx_fin;

			if _cnt_cglresumen is null then
				let _cnt_cglresumen = 0;
			end if

			if _cnt_cglresumen = 0 then
				insert into tmp_contable(
						cuenta,
						no_tranrec,
						db,
						cr,
						sac_notrx,
						origen,
						monto_tecnico,
						descripcion)
				values(	_cuenta,
						_no_tranrec,
						0.00,
						0.00,
						_sac_notrx,
						'',
						_monto_tecnico,
						'NO EXISTEN COMPROBANTES DE LA TRANSACCION EN EL PERIODO: ' || a_periodo1);
			end if
		end foreach
    end if  
end foreach

foreach
	select cuenta,
		   no_remesa,
		   renglon,
		   db,
		   cr, 
		   sac_notrx,
		   origen,
		   monto_tecnico,
		   no_tranrec,
		   descripcion
	  into _cuenta,
	       _no_remesa,
		   _renglon,
		   _db,
		   _cr,
		   _res_notrx,
		   _res_origen,
		   _monto_tecnico,
		   _no_tranrec,
		   _descripcion
	  from tmp_contable
	 order by cuenta,origen,sac_notrx

	let _transaccion = '';

	if _no_tranrec is null then
		let _no_tranrec = '';
	end if

	if _no_tranrec not in ('','SALDODET') then
		select transaccion
		  into _transaccion
		  from rectrmae
		 where no_tranrec = _no_tranrec;
	elif _no_tranrec = 'SALDODET' then
		let _transaccion = _no_tranrec;
	end if

	select cta_nombre
	  into _nom_cuenta
	  from cglcuentas
	 where cta_cuenta = _cuenta;

	if _monto_tecnico is null then
		let _monto_tecnico = 0.00;
	end if

	return	v_compania_nombre,
			_nom_cuenta,
			_cuenta,
			_res_origen,
			_db,
			_cr,
			_monto_tecnico,
			_res_notrx,
			_no_remesa,
			_renglon,
			_transaccion,
			_descripcion with resume;
end foreach

drop table if exists tmp_contable;
drop table if exists tmp_codigos;
drop table if exists tmp_salida;
drop table if exists tmp_sinis;
end procedure;