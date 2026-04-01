-- Procedure de Generación del detalle Reclamos para IFRS XVII
-- Creado    : 01/12/2014 - Autor: Román Gordón
-- execute procedure sp_niif09a('2021-01','2021-12','001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016,017,018,019,020,021,022,023;')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_niif09a;
create procedure sp_niif09a(a_periodo_desde char(7),a_periodo_hasta char(7), a_cod_ramo varchar(255) default "*")
returning	integer			as error,
			integer			as error_isam,
			varchar(100)	as error_desc;

define _error_desc			char(50);
define _estatus_recl		varchar(20);
define _desc_clasif			varchar(50);
define _categoria_contable	varchar(50);
define _segm_triangulo		varchar(50);
define _nom_subramo			varchar(50);
define _filtros				varchar(50);
define _nom_grupo			varchar(50);
define _nom_ramo			varchar(50);
define _tipotran			varchar(50);
define _no_documento		char(20);
define _numrecla			char(18);
define _no_requis			char(10);
define _transaccion			char(10);
define _anular_nt			char(10);
define _no_reclamo2			char(10);
define _nueva_renov			char(10);
define _no_reclamo			char(10);
define _no_tranrec			char(10);
define _no_poliza			char(10);
define _no_unidad			char(5);
define _cod_grupo			char(5);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_tipotran		char(3);
define _cod_ramo			char(3);
define _periodo_requis		char(7);
define _periodo_pago		char(7);
define _periodo				char(7);
define _estatus_reclamo		char(1);
define _tipo				char(1);
define _estatus_poliza		smallint;
define _flag_anio_pago		smallint;
define _clasificacion		smallint;
define _tipo_contrato		smallint;
define _no_cambio			smallint;
define _fronting			smallint;
define _cnt_cob				smallint;
define _pagado				smallint;
define _fecha_decl			date;
define _fecha_ocurr			date;
define _fecha_transaccion	date;
define _fecha_cancelacion	date;
define _fecha_declaracion	date;
define _fecha_ocurrencia	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_cobrado		date;
define _fecha_pago		date;
define _fecha_cierre		date;
define _error_isam			integer;
define my_sessionid			integer;
define _error				integer;
define _pagado_cedido_acum	dec(16,2);
define _pagado_neto_acum	dec(16,2);
define _pag_bruto_acum		dec(16,2);
define _reserva_cedida		dec(16,2);
define _pagado_cedido		dec(16,2);
define _reserva_bruta		dec(16,2);
define _monto_reserva		dec(16,2);
define _monto_pag_ret		dec(16,2);
define _monto_pagado		dec(16,2);
define _pagado_bruto		dec(16,2);
define _reserva_ret			dec(16,2);
define _monto_total			dec(16,2);
define _monto_bruto			dec(16,2);
define _pagado_neto			dec(16,2);
define _variacion			dec(16,2);
define _monto_pag			dec(16,2);
define _porc_reas			dec(9,6);
define _porc_partic_prima	dec(9,6);
define _porc_facultativo	dec(9,6);
define _porc_retencion		dec(9,6);
define _porc_fronting		dec(9,6);
define _porc_cedido			dec(9,6);
define _porc_coas			dec(7,4);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	if _no_poliza is null then
		let _no_poliza = '';
	end if
	
	if _no_documento is null then
		let _no_documento = '';
	end if
	
	let _error_desc = 'poliza: ' || trim(_no_poliza) || trim(_no_documento) || trim(_error_desc);
	return _error,
		   _error_isam,
		   _error_desc;
end exception


--set debug file to "sp_pro545.trc";
--trace on;


drop table if exists fichero_recl_auto;
create temp table fichero_recl_auto(
no_poliza				char(10),--
no_documento			char(20),--
vigencia_inic			date,--
vigencia_final			date,--
cod_ramo				char(3),--
ramo					varchar(50),
cod_subramo				char(3),--
subramo					varchar(50),
no_reclamo				char(10),
numrecla				char(18),
no_tranrec				char(10),
transaccion				char(10),
anular_nt				char(10),
cod_tipotran			char(3),
tipotran				varchar(50),
cod_grupo				char(5),
nom_grupo				varchar(50),
fecha_transaccion		date,
estatus_reclamo			varchar(50),
categoria_contable		varchar(50),
tipo_clasificacion		varchar(50),
segm_triangulo			varchar(50),
nueva_renov				char(10),
fecha_ocurrencia		date,
fecha_declaracion		date,
fecha_pago		date,
fecha_cierre			date,
monto_pag				dec(16,2) default 0.00,
monto_pag_acum			dec(16,2) default 0.00,
monto_pag_ret			dec(16,2) default 0.00,
monto_pag_acum_ret		dec(16,2) default 0.00,
monto_pag_cedido		dec(16,2) default 0.00,
monto_pag_acum_ced		dec(16,2) default 0.00,
reserva_bruta			dec(16,2) default 0.00,
reserva_ret				dec(16,2) default 0.00,
reserva_cedida			dec(16,2) default 0.00, 
ibnr					dec(16,2) default 0.00,
porc_retencion			dec(9,6) default 0.00,
porc_cedido				dec(9,6) default 0.00,
porc_facultativo		dec(9,6) default 0.00,
porc_fronting			dec(9,6) default 0.00,
periodo					char(7),
periodo_requ			char(7),
no_requis				char(10),
pagado					smallint,
fecha_cobrado			date,
periodo_pago			char(7),
periodo_anular			char(7),
flag_anio_pago			smallint,
primary key (no_reclamo,no_tranrec)) with no log;


{foreach with hold
	select distinct no_documento
	  into a_no_documento
	  from emipomae
	 where no_documento in (select distinct no_documento from endedmae where no_endoso = '00000' and activa = 0)
	begin work;}

--drop table if exists tmp_sinis;
--Siniestros Pagados 
--call sp_rec01('001','001',a_periodo_desde,a_periodo_hasta,'*','*',a_cod_ramo) returning _filtros; 

let _cod_coasegur = '036';
drop table if exists tmp_codigos;
let _tipo = sp_sis04(a_cod_ramo);
let _fecha_cierre = '';

FOREACH
	select trx.no_reclamo,
		   trx.monto,
		   trx.variacion,
		   trx.periodo,
		   trx.no_tranrec,
		   trx.cod_tipotran,
		   trx.transaccion,
		   trx.anular_nt,
		   tip.nombre,
		   trx.fecha,
		   trx.fecha_pagado,
		   rec.no_poliza,
		   rec.no_unidad,
		   emi.no_documento,
		   emi.vigencia_inic,
		   emi.vigencia_final,
		   case emi.nueva_renov when 'N' then 'NUEVA' when 'R' then 'RENOVACION' end,
		   emi.cod_ramo,
		   ram.nombre,
		   sub.cod_subramo,
		   sub.nombre,
		   rec.numrecla,
		   rec.fecha_siniestro,
		   rec.fecha_reclamo,
		   case rec.estatus_reclamo when 'C' then 'CERRADO' when 'A' then 'ABIERTO' when 'D' then 'DECLINADO' when 'N' then 'NO APLICA' end,
		   emi.cod_grupo,
		   grp.nombre,
		   chq.no_requis,
		   chq.pagado,
		   chq.fecha_cobrado
	  into _no_reclamo,
		   _monto_total,
		   _variacion,
		   _periodo,
		   _no_tranrec,
		   _cod_tipotran,
		   _transaccion,
		   _anular_nt,
		   _tipotran,
		   _fecha_transaccion,
		   _fecha_pago,
		   _no_poliza,
		   _no_unidad,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _nueva_renov,
		   _cod_ramo,
		   _nom_ramo,
		   _cod_subramo,
		   _nom_subramo,
		   _numrecla,
		   _fecha_ocurrencia,
		   _fecha_declaracion,
		   _estatus_recl,
		   _cod_grupo,
		   _nom_grupo,
		   _no_requis,
		   _pagado,
		   _fecha_cobrado
	  from rectrmae trx
	 inner join recrcmae rec on rec.no_reclamo = trx.no_reclamo
	 inner join emipomae emi on emi.no_poliza = rec.no_poliza
	 inner join tmp_codigos tmp on tmp.codigo = emi.cod_ramo
	 inner join rectitra tip on tip.cod_tipotran = trx.cod_tipotran
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	 inner join cligrupo grp on grp.cod_grupo = emi.cod_grupo
--	  left join chqchrec trc on trx.no_tranrec = trc.no_tranrec
	  left join chqchmae chq on chq.no_requis = trx.no_requis
	 where trx.actualizado  = 1
	  -- and trx.cod_tipotran in ('004','005','006','007','002','011','012','013')
	   and trx.periodo >= a_periodo_desde 
	   and trx.periodo <= a_periodo_hasta
	   and (trx.monto <> 0  or trx.variacion <> 0)
	--   and trx.numrecla = '02-0121-00099-01'

	let _porc_facultativo = 0.00;
	let _porc_retencion = 0.00;
	let _porc_fronting = 0.00;
	let _porc_cedido = 0.00;
	let _categoria_contable = '';
	
	call sp_niif13(_no_poliza,_no_reclamo,_no_tranrec,1)
	returning _error,_error_isam,_error_desc,_desc_clasif,_categoria_contable,_segm_triangulo;
	
	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;
	
	foreach
		select distinct mae.tipo_contrato,
			   emi.porc_partic_prima,
			   mae.fronting
		  into _tipo_contrato,
			   _porc_partic_prima,
			   _fronting
		  from emireaco emi
		 inner join reacomae mae on mae.cod_contrato = emi.cod_contrato
		 where emi.no_poliza = _no_poliza
		   and emi.no_unidad = _no_unidad
		   and emi.no_cambio = _no_cambio

		if _fronting = 1 then
			let _porc_fronting = _porc_partic_prima;
		else
			if _tipo_contrato = 1 then
				let _porc_retencion = _porc_partic_prima;
			elif _tipo_contrato = 3 then
				let _porc_facultativo = _porc_partic_prima;
			elif _tipo_contrato in (5,7) then
				let _porc_cedido = _porc_partic_prima;
			end if	
		end if
	end foreach

	let _periodo_pago = '1900-12';
	let _periodo_requis = '1900-12';
	let _flag_anio_pago = 0;
	if _cod_tipotran = '004' then
		
		if _no_requis is null then
			let _flag_anio_pago = 2;
		else
			foreach
				select cta.periodo
				  into _periodo_requis
				  from chqchmae chq
				 inner join chqchcta cta on cta.no_requis = chq.no_requis
				 where chq.no_requis = _no_requis
				   and cta.cuenta in ('26612','14103')
				exit foreach;
			end foreach
			
			if _periodo_requis is null or _periodo_requis = '1900-12' then
				let _flag_anio_pago = 1;
			end if
			if _periodo[1,4] <> _periodo_requis[1,4] then
				let _flag_anio_pago = 1;
			end if
		end if
		
		let _monto_pagado = _monto_total;
		let _monto_reserva = _variacion;
		
		if _fecha_cobrado is null then
			let _periodo_pago = '1900-12';
		else
			let _periodo_pago = sp_sis39(_fecha_cobrado);			
		end if		
	elif _cod_tipotran in ('005','006','007') then
		let _monto_pagado = _monto_total;
		let _monto_reserva = _variacion;
	else
		let _monto_pagado = 0.00;
		let _monto_reserva = _variacion;
	end if
	
	-- Informacion de Coaseguro
	select porc_partic_coas
	  into _porc_coas
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coas is null then
		let _porc_coas = 0;
	end if

	-- Informacion de Reaseguro

	let _porc_reas = 0;
	
	foreach
		select porc_partic_suma
		  into _porc_reas
		  from rectrrea
		 where no_tranrec = _no_tranrec
		   and tipo_contrato = 1
		exit foreach;
	end foreach
	  
	if _porc_reas is null then
		let _porc_reas = 0;
	end if;

	let _reserva_cedida = 0.00;
	let _reserva_bruta = 0.00;
	let _monto_pag_ret = 0.00;
	let _pagado_cedido = 0.00;
	let _pagado_bruto = 0.00;
	let _reserva_ret = 0.00;

	-- Calculos
	let _pagado_bruto = _monto_pagado / 100 * _porc_coas;
	let _monto_pag_ret = _pagado_bruto / 100 * _porc_reas;
	let _pagado_cedido = _pagado_bruto - _monto_pag_ret;
	
	let _reserva_bruta = _monto_reserva / 100 * _porc_coas;
	let _reserva_ret = _reserva_bruta / 100 * _porc_reas;
	let _reserva_cedida = _reserva_bruta - _reserva_ret;
	
	if _estatus_recl <> 'ABIERTO' then
		select max(fecha)
		  into _fecha_cierre
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and actualizado = 1;

		if _fecha_cierre is null then
			let _fecha_cierre = '';
		end if
	end if

	/*select no_reclamo,
		   sum(monto)
	  into _no_reclamo2,
		   _pag_bruto_acum
	   from rectrmae trx
	  where trx.no_reclamo = _no_reclamo
		and trx.cod_tipotran in ('004','005','006','007')
		and trx.periodo <= a_periodo_desde
		and trx.actualizado  = 1
	  group by 1;

	if _pag_bruto_acum is null then
		let _pag_bruto_acum = 0.00;
		let _pagado_neto_acum = 0.00;		
	else
		select no_reclamo,
			   sum(monto * (porc_partic_prima/100))
		  into _no_reclamo2,
			   _pagado_neto_acum
		   from rectrmae trx
		  inner join rectrrea rea on rea.no_tranrec = trx.no_tranrec
		  inner join reacomae con on con.cod_contrato = rea.cod_contrato and con.tipo_contrato = 1
		  where trx.no_reclamo = _no_reclamo
			and trx.cod_tipotran in ('004','005','006','007')
			and trx.periodo <= a_periodo_hasta
			and trx.actualizado  = 1
		  group by 1;	
	end if*/

	--let _pagado_cedido_acum = _pag_bruto_acum - _pagado_neto_acum;
	let _pag_bruto_acum = 0.00;
	let _pagado_neto_acum = 0.00;
	let _pagado_cedido_acum = 0.00;
	

	begin
		on exception in (-239)
			update fichero_recl_auto
			   set monto_pag = monto_pag + _pagado_bruto,
				   monto_pag_ret = monto_pag_ret + _monto_pag_ret,
				   monto_pag_cedido = monto_pag_cedido + _pagado_cedido,
				   reserva_bruta = reserva_bruta + _reserva_bruta,
				   reserva_ret = reserva_ret + _reserva_ret,
				   reserva_cedida = reserva_cedida + _reserva_cedida			   
			 where no_reclamo = _no_reclamo
			   and no_tranrec = _no_tranrec;
		end exception

		insert into fichero_recl_auto(
					no_poliza,
					no_documento,
					vigencia_inic,
					vigencia_final,
					cod_ramo,
					ramo,
					cod_subramo,
					subramo,
					no_reclamo,
					numrecla,
					no_tranrec,
					transaccion,
					anular_nt,
					fecha_transaccion,
					cod_tipotran,
					tipotran,
					estatus_reclamo,
					tipo_clasificacion,
					segm_triangulo,
					categoria_contable,
					nueva_renov,
					fecha_ocurrencia,
					fecha_declaracion,
					fecha_pago,
					fecha_cierre,
					reserva_bruta,
					reserva_ret,
					reserva_cedida,
					monto_pag,
					monto_pag_acum,
					monto_pag_ret,
					monto_pag_acum_ret,
					monto_pag_cedido,
					monto_pag_acum_ced,
					periodo,
					cod_grupo,
					nom_grupo,
					porc_retencion,
					porc_cedido,
					porc_facultativo,
					porc_fronting,
					no_requis,
					pagado,
					fecha_cobrado,
					periodo_pago,
					periodo_anular,
					flag_anio_pago
					)
			values( _no_poliza,
					_no_documento,
					_vigencia_inic,
					_vigencia_final,
					_cod_ramo,
					_nom_ramo,
					_cod_subramo,
					_nom_subramo,
					_no_reclamo,
					_numrecla,
					_no_tranrec,
					_transaccion,
					_anular_nt,
					_fecha_transaccion,
					_cod_tipotran,
					_tipotran,
					_estatus_recl,
					_desc_clasif,
					_segm_triangulo,
					_categoria_contable,
					_nueva_renov,
					_fecha_ocurrencia,
					_fecha_declaracion,
					_fecha_pago,
					_fecha_cierre,
					_reserva_bruta,
					_reserva_ret,
					_reserva_cedida,
					_pagado_bruto,
					_pag_bruto_acum,
					_monto_pag_ret,
					_pagado_neto_acum,
					_pagado_cedido,
					_pagado_cedido_acum,
					_periodo,
					_cod_grupo,
					_nom_grupo,
					_porc_retencion,
					_porc_cedido,
					_porc_facultativo,
					_porc_fronting,
					_no_requis,
					_pagado,
					_fecha_cobrado,
					_periodo_requis,
					'',
					_flag_anio_pago);
	end
end foreach

return 0,0,'Carga Exitosa';

end
end procedure;