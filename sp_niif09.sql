-- Procedure de Generación del detalle Reclamos para IFRS XVII
-- Creado    : 01/12/2014 - Autor: Román Gordón
-- execute procedure sp_niif09('2021-01','2021-12','002,020,023;')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_niif09;
create procedure sp_niif09(a_periodo_desde char(7),a_periodo_hasta char(7), a_cod_ramo varchar(255) default "*")
returning	integer			as error,
			integer			as error_isam,
			varchar(100)	as error_desc;
			
			
define _error_desc			char(50);
define _filtros				varchar(50);
define _nom_ramo			varchar(50);
define _no_documento		char(20);
define _numrecla			char(18);
define _no_reclamo2			char(10);
define _no_reclamo			char(10);
define _no_poliza			char(10);
define _cod_ramo			char(3);
define _estatus_reclamo		char(1);
define _nueva_renov			char(1);
define _estatus_poliza		smallint;
define _clasificacion		smallint;
define _cnt_cob				smallint;
define _fecha_cancelacion	date;
define _fecha_declaracion	date;
define _fecha_ocurrencia	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_cierre		date;
define _error_isam			integer;
define my_sessionid			integer;
define _error				integer;
define _pagado_cedido_acum	dec(16,2);
define _pagado_neto_acum	dec(16,2);
define _pag_bruto_acum		dec(16,2);
define _pagado_cedido		dec(16,2);
define _reserva_cedida		dec(16,2);
define _reserva_bruta		dec(16,2);
define _monto_pag_ret		dec(16,2);
define _reserva_neta		dec(16,2);
define _pagado_bruto		dec(16,2);
define _pagado_neto			dec(16,2);
define _monto_pag			dec(16,2);

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
no_reclamo				char(10),
numrecla				char(18),
estatus_reclamo			char(1),
tipo_clasificacion		smallint,
nueva_renov				char(1),
fecha_ocurrencia		date,
fecha_declaracion		date,
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
primary key (no_reclamo)) with no log;


{foreach with hold
	select distinct no_documento
	  into a_no_documento
	  from emipomae
	 where no_documento in (select distinct no_documento from endedmae where no_endoso = '00000' and activa = 0)
	begin work;}

--Siniestros Pendiente
drop table if exists tmp_sinis;
call sp_rec02('001','001',a_periodo_hasta,'*','*','*', a_cod_ramo,'*') returning _filtros; 

foreach
	select sin.no_poliza,
		   sin.no_documento,
		   emi.vigencia_inic,
		   emi.vigencia_final,
		   emi.cod_ramo,
		   ram.nombre,
		   sin.no_reclamo,
		   sin.numrecla,
		   rec.estatus_reclamo,
		   emi.nueva_renov,
		   rec.fecha_siniestro,
		   rec.fecha_reclamo,
		   sin.reserva_bruto,
		   sin.reserva_neto,
		   sin.reserva_bruto - sin.reserva_neto
	  into _no_poliza,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _nom_ramo,
		   _no_reclamo,
		   _numrecla,
		   _estatus_reclamo,
		   _nueva_renov,
		   _fecha_ocurrencia,
		   _fecha_declaracion,
		   _reserva_bruta,
		   _reserva_neta,
		   _reserva_cedida
	  from tmp_sinis sin
	 inner join emipomae emi on emi.no_poliza = sin.no_poliza
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 inner join recrcmae rec on rec.no_reclamo = sin.no_reclamo
	 where sin.seleccionado = 1

	if _cod_ramo = '020' then
		let _clasificacion = 2;
	elif _cod_ramo in ('002','023') then
		select count(*)
		  into _cnt_cob
		  from emipocob
		 where no_poliza = _no_poliza
		   and cod_cobertura in ('00119','00118','00120','00103','00121','00901','00606','01745','01794','00902','00903','00900','01746','01747','01222',
								 '01299','01300','01301','01302','01303','01304','01305','01306','01307','01308','01309','01310','01311','01312','01313',
								 '01314','01315','01322','01323','01324','01325','01326','01327','01338','01341','01376','01536','01578','01657','01677',
								 '01816');

		if _cnt_cob is null then
			let _cnt_cob = 0;
		end if
		
		if _cnt_cob = 0 then
			if _cod_ramo = '002' then
				let _clasificacion = 2;
			else
				let _clasificacion = 4;
			end if
		else
			if _cod_ramo = '002' then
				let _clasificacion = 1;
			else
				let _clasificacion = 3;
			end if
		end if
	else --PENDIENTE
		
	end if
	let _fecha_cierre = null;
	if _estatus_reclamo = 'C' then
		select max(fecha)
		  into _fecha_cierre
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and actualizado = 1;
	end if
	
	begin
		on exception in (-239)
			update fichero_recl_auto
			   set reserva_bruta = _reserva_bruta,
				   reserva_ret = _reserva_neta,
				   reserva_cedida = _reserva_cedida
			 where no_reclamo = _no_reclamo;
		end exception
		


		insert into fichero_recl_auto(
				no_poliza,
				no_documento,
				vigencia_inic,
				vigencia_final,
				cod_ramo,
				ramo,
				no_reclamo,
				numrecla,
				estatus_reclamo,
				tipo_clasificacion,
				nueva_renov,
				fecha_ocurrencia,
				fecha_declaracion,
				fecha_cierre,
				reserva_bruta,
				reserva_ret,
				reserva_cedida,
				monto_pag,
				monto_pag_acum,
				monto_pag_ret,
				monto_pag_acum_ret,
				monto_pag_cedido,
				monto_pag_acum_ced)
		values(_no_poliza,
			   _no_documento,
			   _vigencia_inic,
			   _vigencia_final,
			   _cod_ramo,
			   _nom_ramo,
			   _no_reclamo,
			   _numrecla,
			   _estatus_reclamo,
			   _clasificacion,
			   _nueva_renov,
			   _fecha_ocurrencia,
			   _fecha_declaracion,
			   _fecha_cierre,
			   _reserva_bruta,
			   _reserva_neta,
			   _reserva_cedida,
			   0.00,
			   0.00,
			   0.00,
			   0.00,
			   0.00,
			   0.00);
	end;
end foreach

drop table if exists tmp_sinis;
--Siniestros Pagados 
/*call sp_rec01('001','001',a_periodo_desde,a_periodo_hasta,'*','*',a_cod_ramo) returning _filtros; 

foreach with hold
	select sin.no_poliza,
		   emi.no_documento,
		   emi.vigencia_inic,
		   emi.vigencia_final,
		   emi.cod_ramo,
		   ram.nombre,
		   sin.no_reclamo,
		   sin.numrecla,
		   rec.estatus_reclamo,
		   emi.nueva_renov,
		   rec.fecha_siniestro,
		   rec.fecha_reclamo,
		   sin.pagado_bruto,
		   sin.pagado_neto,
		   sin.pagado_bruto - sin.pagado_neto
	  into _no_poliza,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _nom_ramo,
		   _no_reclamo,
		   _numrecla,
		   _estatus_reclamo,
		   _nueva_renov,
		   _fecha_ocurrencia,
		   _fecha_declaracion,
		   _pagado_bruto,
		   _pagado_neto,
		   _pagado_cedido
	  from tmp_sinis sin
	 inner join emipomae emi on emi.no_poliza = sin.no_poliza
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 inner join recrcmae rec on rec.no_reclamo = sin.no_reclamo
	 where sin.seleccionado = 1

	if _cod_ramo = '020' then
		let _clasificacion = 2;
	elif _cod_ramo in ('002','023') then
		select count(*)
		  into _cnt_cob
		  from emipocob
		 where no_poliza = _no_poliza
		   and cod_cobertura in ('00119','00118','00120','00103','00121','00901','00606','01745','01794','00902','00903','00900','01746','01747','01222',
								 '01299','01300','01301','01302','01303','01304','01305','01306','01307','01308','01309','01310','01311','01312','01313',
								 '01314','01315','01322','01323','01324','01325','01326','01327','01338','01341','01376','01536','01578','01657','01677',
								 '01816');

		if _cnt_cob is null then
			let _cnt_cob = 0;
		end if
		
		if _cnt_cob = 0 then
			if _cod_ramo = '002' then
				let _clasificacion = 2;
			else
				let _clasificacion = 4;
			end if
		else
			if _cod_ramo = '002' then
				let _clasificacion = 1;
			else
				let _clasificacion = 3;
			end if
		end if
	else --PENDIENTE
		
	end if

	if _estatus_reclamo = 'C' then
		select max(fecha)
		  into _fecha_cierre
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and actualizado = 1;
	end if

	select no_reclamo,
		   sum(monto)
	  into _no_reclamo2,
		   _pag_bruto_acum
	   from rectrmae trx
	  where trx.no_reclamo = _no_reclamo
		and trx.cod_tipotran in ('004','005','006','007')
		and trx.periodo <= a_periodo_hasta
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
	end if

	let _pagado_cedido_acum = _pag_bruto_acum - _pagado_neto_acum;

	begin
		on exception in (-239)
			update fichero_recl_auto
			   set monto_pag = _pagado_bruto,
				   monto_pag_acum =	_pag_bruto_acum,
				   monto_pag_ret = _pagado_neto,
				   monto_pag_acum_ret = _pagado_neto_acum,
				   monto_pag_cedido = _pagado_cedido,
				   monto_pag_acum_ced = _pagado_cedido_acum
			 where no_reclamo = _no_reclamo;
		end exception

		insert into fichero_recl_auto(
					no_poliza,
					no_documento,
					vigencia_inic,
					vigencia_final,
					cod_ramo,
					ramo,
					no_reclamo,
					numrecla,
					estatus_reclamo,
					tipo_clasificacion,
					nueva_renov,
					fecha_ocurrencia,
					fecha_declaracion,
					fecha_cierre,
					reserva_bruta,
					reserva_ret,
					reserva_cedida,
					monto_pag,
					monto_pag_acum,
					monto_pag_ret,
					monto_pag_acum_ret,
					monto_pag_cedido,
					monto_pag_acum_ced)
			values( _no_poliza,
					_no_documento,
					_vigencia_inic,
					_vigencia_final,
					_cod_ramo,
					_nom_ramo,
					_no_reclamo,
					_numrecla,
					_estatus_reclamo,
					_clasificacion,
					_nueva_renov,
					_fecha_ocurrencia,
					_fecha_declaracion,
					_fecha_cierre,
					0.00,
					0.00,
					0.00,
					_pagado_bruto,
					_pag_bruto_acum,
					_pagado_neto,
					_pagado_neto_acum,
					_pagado_cedido,
					_pagado_cedido_acum);
	end
end foreach*/

return 0,0,'Carga Exitosa';

end
end procedure;