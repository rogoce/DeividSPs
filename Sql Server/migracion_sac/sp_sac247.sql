-- Procedimiento que verifica el cuadre contable con las cuentas tecnicas de producción, cobros y reclamos
-- Creado    : 28/12/2015 - Autor: Armando Moreno
--execute procedure sp_sac247('001','001','2015-12','2015-12','002,020,023;','411020103')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac247;
create procedure informix.sp_sac247(
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
			integer			as renglon,
			char(15)		as comprobante,
			char(10)		as no_tranrec,
			char(10)		as factura,
			varchar(255)	as descripcion;


define _descripcion			varchar(255);
define _error_desc			varchar(255);
define v_compania_nombre	varchar(50);
define _nom_cuenta			varchar(50);
define _cuenta				char(18);
define _res_comprobante		char(15);
define _no_factura			char(10);
define _no_tranrec			char(10);
define _no_remesa			char(10);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _res_origen			char(3);
define _tipo				char(1);
define _prima_suscrita		dec(16,2);
define _mto_recasien		dec(16,2);
define _res_db				dec(16,2);
define _res_cr				dec(16,2);
define _monto				dec(16,2);
define _dif					dec(16,2);
define _db					dec(16,2);
define _cr					dec(16,2);
define _cnt_cglresumen		smallint;
define _cnt_endasien		smallint;
define _error_isam			integer;
define _res_notrx			integer;
define _sac_notrx			integer;
define _renglon				integer;
define _error				integer;
define _fecha1				date;
define _fecha2				date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	drop table if exists tmp_contable;
	drop table if exists temp_det;
	drop table if exists tmp_codigos;
	
	return trim(_error_desc),'',a_cuenta,'',0.00,0.00,0.00,_error,'',0,'','','','';
end exception


let v_compania_nombre = '';
let _res_comprobante = '';
let _res_origen = '';
let _nom_cuenta = '';
let _no_tranrec = '';
let _no_remesa = '';
let _cuenta = '';
let _db = 0.00;
let _cr = 0.00;
let _res_notrx = 0;
let _renglon = 0;

let v_compania_nombre = sp_sis01(a_compania);

drop table if exists tmp_codigos;
drop table if exists tmp_contable;
call sp_sac246(a_compania,a_agencia,a_periodo1,a_periodo2,a_cuenta) returning _error, _error_desc;

if _error <> 0 then
	return 'Cuadre Contable, Error: ' || trim(_error_desc),'',a_cuenta,'',0.00,0.00,0.00,_error,'',0,'','','','';
end if

drop table if exists temp_det;
call sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,'*','*','*','*',a_cod_ramo,'*','1') returning _error_desc;

--Filtro por Cuentas
if a_cuenta <> "*" then
	let _error_desc = trim(_error_desc) ||"Cuenta: "||trim(a_cuenta);
	let _tipo = sp_sis04(a_cuenta); -- separa los valores del string
end if

foreach
	select distinct no_poliza,
		   no_endoso,
		   prima
	  into _no_poliza,
		   _no_endoso,
		   _prima_suscrita
	  from temp_det
	 where seleccionado = 1
	 order by no_poliza,no_endoso

	if _prima_suscrita is null then
		let _prima_suscrita = 0.00;
	end if
	
	if _prima_suscrita = 0.00 then
		continue foreach;
	end if
	
	let _cuenta = sp_sis15('PIPSSD', '01', _no_poliza);

	if a_cuenta <> "*" then
		if _cuenta not in (select codigo from tmp_codigos) then
			continue foreach;
		end if
	end if

	select count(*)
	  into _cnt_endasien
	  from endasien
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and cuenta = _cuenta;

	if _cnt_endasien is null then
		let _cnt_endasien = 0;
	end if

	if _cnt_endasien = 0 then
		insert into tmp_contable(
				cuenta,
				no_poliza,
				no_endoso,
				db,
				cr,
				sac_notrx,
				origen,
				monto_tecnico,
				descripcion)
		values(	_cuenta,
				_no_poliza,
				_no_endoso,
				0.00,
				0.00,
				'',
				'',
				_prima_suscrita,
				'NO EXISTEN ASIENTOS PARA LA FACTURA');
	else
		foreach
			select sac_notrx
			  into _sac_notrx
			  from endasien
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and cuenta = _cuenta

			select count(*)
			  into _cnt_cglresumen
			  from cglresumen
			 where res_notrx = _sac_notrx
			   and res_cuenta = _cuenta;

			if _cnt_cglresumen is null then
				let _cnt_cglresumen = 0;
			end if

			if _cnt_cglresumen = 0 then
				insert into tmp_contable(
						cuenta,
						no_poliza,
						no_endoso,
						db,
						cr,
						sac_notrx,
						origen,
						monto_tecnico,
						descripcion)
				values(	_cuenta,
						_no_poliza,
						_no_endoso,
						0.00,
						0.00,
						_sac_notrx,
						'',
						_prima_suscrita,
						'NO EXISTEN COMPROBANTES DE LA TRANSACCION EN EL PERIODO: ' || a_periodo1);
			end if
		end foreach
	end if
	{foreach
		select sac_notrx
			   sum(debito + credito)
		  into _sac_notrx,
			   _prima_tecnica
		  from endasien
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and cuenta = _cuenta

		select 
	end foreach}
end foreach

foreach
	select cuenta,
		   no_remesa,
		   renglon,
		   db,
		   cr, 
		   sac_notrx,
		   comprobante,
		   origen,
		   monto_tecnico,
		   no_poliza,
		   no_endoso,
		   descripcion
	  into _cuenta,
	       _no_remesa,
		   _renglon,
		   _db,
		   _cr,
		   _res_notrx,
		   _res_comprobante,
		   _res_origen,
		   _prima_suscrita,
		   _no_poliza,
		   _no_endoso,
		   _descripcion
	  from tmp_contable
	 order by cuenta,origen,sac_notrx

	select no_factura
	  into _no_factura
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	select cta_nombre
	  into _nom_cuenta
	  from cglcuentas
	 where cta_cuenta = _cuenta;

	return	v_compania_nombre,
			_nom_cuenta,
			_cuenta,
			_res_origen,
			_db,
			_cr,
			_prima_suscrita,
			_res_notrx,
			_no_remesa,
			_renglon,
			_res_comprobante,
			_no_tranrec,
			_no_factura,
			_descripcion
			with resume;
end foreach
end

drop table if exists tmp_contable;
drop table if exists temp_det;
drop table if exists tmp_codigos;

end procedure;