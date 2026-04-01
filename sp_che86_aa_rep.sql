--*****************************************************************************************
-- Procedimiento que genera el Reporte ubicado en Metas de cobros, modulo de cobros
--*****************************************************************************************

--execute procedure sp_che86_aa_rep('001','001','2026-01','2026-01')

DROP PROCEDURE sp_che86_aa_rep;
CREATE PROCEDURE sp_che86_aa_rep(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo char(7), a_periodo2 char(7))
RETURNING	varchar(200)	as zona_ventas,
			char(5)		as cod_agente_agrupado,
			varchar(50)	as corredor_agrupado,
			char(5)		as cod_agente,
			varchar(50)	as corredor,
			varchar(200)	as chequera,
			dec(16,2)		as prima_dev_cor,
			dec(16,2)		as impuesto_cor,
			dec(16,2)		as prima_coa_cor,
			dec(16,2)		as prima_fac_cor,
			dec(16,2)		as prima_zl,
			dec(16,2)		as prima_gob,
			dec(16,2)		as prima_cen_cor,
			dec(16,2)		as prima_net_cor;

DEFINE _no_poliza       CHAR(10);
DEFINE _monto,_monto2   DEC(16,2);
DEFINE _fecha,_fecha_ini,_fecha_fin     DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _cod_tiporamo    CHAR(3);
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _nombre_ramo     CHAR(50);  
DEFINE _cod_subramo     CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _cod_producto	char(5);
DEFINE _cod_chequera    char(3);
DEFINE _cod_formapag    char(3);
DEFINE _tipo_forma      SMALLINT;
DEFINE v_prima_orig     DEC(16,2);
DEFINE v_saldo          DEC(16,2);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);
define v_monto_90       DEC(16,2);
define _cnt,my_sessionid integer;
define _cod_grupo       char(5);
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define _cedula_cont		char(30);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _estatus_licencia char(1);
define _per_ini 		char(7);
define _per_ini_ap 		char(7);
define _per_fin_ap 		char(7);
define _pri_sus 		DEC(16,2);
define _zona_ventas		varchar(200);
define _nom_chequera			varchar(200);
define _per_fin_dic     char(7);
define _prima_sus_pag   DEC(16,2);
define _sini_incu		DEC(16,2);
define _siniestralidad  DEC(16,2);
define _fecha_pago      date;
define _renglon         integer;
define _porc_coaseguro	dec(16,4);
define _prima_can		DEC(16,2);
define _sin_pag_aa		DEC(16,2);
define _no_reclamo		char(10);
define _sin_pen_dic		DEC(16,2);
define _sin_pen_aa      DEC(16,2);
define _pri_pag         DEC(16,2);
define _pri_can         DEC(16,2);
define _pri_dev         DEC(16,2);
define _prima_orig      DEC(16,2);
define _prima_suscrita  DEC(16,2);
define _prima_dev_cor  DEC(16,2);
define _prima_suscri  DEC(16,2);
define _flag            smallint;
define _cod_coasegur	char(3);
define _cod_agente,_cod_agente_tmp   	char(5);
define _cnt_zl			smallint;
define _cnt_gob			smallint;
define _monto_90_aa     DEC(16,2);
define _monto_cob			DEC(16,2);
define _impuesto			DEC(16,2);
define _agente_agrupado char(5);
define _error           integer;
define _error_isam      integer;
define _error_desc      char(50);
DEFINE _monto_dev        DEC(16,2);
define _pagado           integer;
define _fecha_anulado    date;
define _no_remesa        char(10);
define _porc_partic_prima  dec(16,2);
define _porc_proporcion    dec(16,2);
define _monto_fac_ac	dec(16,2);
define _impuesto_cor	dec(16,2);
define _monto_fac       dec(16,2);
define _no_endoso       char(10);
define _prima_net_cor       dec(16,2);
define _prima_fac_cor       dec(16,2);
define _prima_zl       dec(16,2);
define _prima_gob       dec(16,2);
define _prima_coa_cor       dec(16,2);
define _prima_cen_cor       dec(16,2);
define _prima_fac       dec(16,2);
define _prima_neta    dec(16,2);
define _monto_coa    dec(16,2);
define _monto_cen    dec(16,2);
define _valor           decimal(16,2);
define _porcentaje      decimal(16,4);
define _n_cor_agrupado,_n_corredor   varchar(50);


--SET DEBUG FILE TO "sp_che86_aa_rep.trc";
--TRACE ON;

begin 

let _error          = 0;
let _prima_can      = 0;
let _pri_can        = 0;
let _siniestralidad = 0;
let _sini_incu      = 0;
let _prima_sus_pag  = 0;
let _pri_dev        = 0;
let _cnt            = 0;
let _pri_pag        = 0;
let _sin_pen_dic    = 0;
let _sin_pen_aa     = 0;
let _sin_pag_aa     = 0;
let v_por_vencer    = 0;
let v_exigible	    = 0;
let v_corriente	    = 0;
let v_monto_30	    = 0;
let v_monto_60	    = 0;
let v_monto_90	    = 0;
let v_saldo         = 0;
let _prima_orig     = 0;
let _monto_90_aa    = 0;
let _pri_can		= 0;
let _monto_fac_ac   = 0;
let _monto_fac      = 0;
let _prima_fac      = 0;
let _prima_suscri   = 0;

-- Periodo Actual

select par_ase_lider
  into _cod_coasegur
  from parparam;
  
let my_sessionid = DBINFO('sessionid');

SET ISOLATION TO DIRTY READ;

drop table if exists tmp_concurso1;
create temp table tmp_concurso1(
no_documento	char(20),
prima_net_cor	dec(16,2),
prima_coa_cor	dec(16,2),
prima_fac_cor	dec(16,2),
prima_cen_cor	dec(16,2),
impuesto_cor	dec(16,2),
prima_dev_cor   dec(16,2) default 0,
cod_agente      char(5),
nom_chequera	varchar(200),
zona_ventas	varchar(200),
tipo            smallint,
prima_zl		dec(16,2),
prima_gob		dec(16,2)
) with no log;
CREATE INDEX x_tmp_concurso1 ON tmp_concurso1(cod_agente);

let _fecha_ini = sp_sis36b(a_periodo);
let _fecha_fin = sp_sis36(a_periodo2);
--***************
-- Prima Cobrada
--***************
foreach
	select cob.doc_remesa,
		   mae.cod_chequera,
		   cob.prima_neta,
		   cob.fecha,
		   cob.renglon,
		   cob.no_poliza,
		   cob.no_remesa,
		   cob.tipo_mov,
		   emi.cod_tipoprod,
		   emi.cod_ramo,
		   emi.cod_subramo,
		   emi.cod_grupo,
		   cob.monto
	  into _no_documento,
		   _cod_chequera,
		   _prima_neta,
		   _fecha_pago,
		   _renglon,
		   _no_poliza,
		   _no_remesa,
		   _tipo_mov,
		   _cod_tipoprod,
		   _cod_ramo,
		   _cod_subramo,
		   _cod_grupo,
		   _monto_cob
	   from cobredet cob
	  inner join cobremae mae on mae.no_remesa = cob.no_remesa
	  inner join emipomae emi on emi.no_poliza = cob.no_poliza
	  where cob.periodo >= a_periodo
	    and cob.periodo <= a_periodo2
		and cob.actualizado = 1
		and cob.tipo_mov in ("P","N","X")
	
	let _monto = 0.00;
	let _monto_fac_ac = 0.00;
	let _monto_coa = 0.00;
	let _monto_cen = 0.00;
	let _impuesto = 0.00;
	
	if _tipo_mov = 'X' then	--Ajuste de centavos
		let _monto = 0.00;
		let _monto_fac_ac = 0.00;
		let _monto_coa = 0.00;
		let _impuesto = 0.00;
		let _monto_cen = _prima_neta;
	else
		
		let _monto_cen = 0.00;
		let _monto_coa = 0.00;
		let _monto = _prima_neta;
		let _impuesto = _monto_cob - _prima_neta;
		
		--Quitar Coaseguro Cedido
		if _cod_tipoprod = "001" then
			select porc_partic_coas
			  into _porc_coaseguro
			  from emicoama
			 where no_poliza    = _no_poliza
			   and cod_coasegur = _cod_coasegur;
					  
			if _porc_coaseguro is null then
				let _porc_coaseguro = 0.00;
			end if

			let _monto = _prima_neta * (_porc_coaseguro / 100);
			let _monto_coa = _prima_neta - _monto;
		end if
		
		--Quitar facultativo cedido
		foreach
			select porc_partic_prima,
				   porc_proporcion
			  into _porc_partic_prima,
				   _porc_proporcion
			  from cobreaco c, reacomae r
			 where c.no_remesa = _no_remesa
			   and c.renglon   = _renglon
			   and r.cod_contrato = c.cod_contrato
			   and r.tipo_contrato = 3

			if _porc_partic_prima is null then
				let _porc_partic_prima = 0.00;
			end if
			
			let _monto_fac = _monto * (_porc_partic_prima/100) * (_porc_proporcion/100);
			let _monto_fac_ac = _monto_fac_ac +_monto_fac;
		end foreach

		let _monto = _monto - _monto_fac_ac;
	end if
	
	let _cnt_zl  = 0;
	let _cnt_gob = 0;
	
	if _cod_ramo = '001' and _cod_subramo = '006' then
		let _cnt_zl = 1;
	elif _cod_ramo = '003' and _cod_subramo = '005' then
		let _cnt_zl = 1;
	end if
	
	if _cod_grupo in ('00000','1000') then
		let _cnt_gob = 1;
	end if
	
	select nombre
	  into _nom_chequera
	  from chqchequ
	 where cod_chequera = _cod_chequera;

	let _valor = sp_sis101a(_no_documento,_fecha_ini,_fecha_fin,my_sessionid);	--Crea tabla tmp_corr con el corredor
	
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from con_corr
		 where sessionid = my_sessionid 
		  
		let _prima_net_cor = 0.00;  
		let _prima_fac_cor = 0.00;  
		let _prima_coa_cor = 0.00;  
		let _prima_cen_cor = 0.00;  
		let _impuesto_cor = 0.00;  
		
		let _prima_net_cor = _monto * _porcentaje /100;  
		let _impuesto_cor = _impuesto * _porcentaje /100;  
		let _prima_fac_cor = _monto_fac_ac * _porcentaje /100;  
		let _prima_coa_cor = _monto_coa * _porcentaje /100;  
		let _prima_cen_cor = _monto_cen * _porcentaje /100;
		
		--Saber la prima zona libre
		if _cnt_zl = 1 then
			let _prima_zl = _prima_net_cor;
		else
			let _prima_zl = 0;
		end if
		--Saber la prima gobierno
		if _cnt_gob = 1 then
			let _prima_gob = _prima_net_cor;
		else
			let _prima_gob = 0;
		end if
		
		select zon.nombre
		  into _zona_ventas
		  from parpromo pro
		 inner join agtvende zon on zon.cod_vendedor = pro.cod_vendedor
		 where pro.cod_agente = _cod_agente
		   and pro.cod_ramo = _cod_ramo
		   and pro.cod_agencia = '001';
		
		insert into tmp_concurso1(no_documento,prima_net_cor,prima_coa_cor,prima_fac_cor,prima_cen_cor,impuesto_cor,cod_agente,tipo,prima_zl,prima_gob,nom_chequera,zona_ventas)
        values (_no_documento,_prima_net_cor,_prima_coa_cor,_prima_fac_cor,_prima_cen_cor,_impuesto_cor,_cod_agente,0,_prima_zl,_prima_gob,_nom_chequera,_zona_ventas);
	end foreach
end foreach

--Devoluciones de prima
foreach
	select  pol.no_documento,
			pol.monto,
			chq.pagado,
			chq.fecha_anulado,
			emi.cod_ramo,
			emi.cod_subramo,
			emi.cod_grupo
	  into _no_documento,
		    _monto_dev, 
			_pagado,
			_fecha_anulado,
			_cod_ramo,
			_cod_subramo,
			_cod_grupo			 
	  from chqchpol pol
	 inner join chqchmae chq on chq.no_requis = pol.no_requis
	 inner join emipomae emi on emi.no_poliza = pol.no_poliza
	 where chq.fecha_impresion between _fecha_ini and _fecha_fin

	if _pagado = 1 then
		if _fecha_anulado is not null then
			if _fecha_anulado >= _fecha_ini and _fecha_anulado <= _fecha_fin then
				let _monto_dev = 0;
			end if
		end if			
	else
		let _monto_dev = 0;
	end if	
	if _monto_dev is null then
		let _monto_dev = 0;
	end if
	
	let _cnt_zl = 0;
	let _cnt_gob = 0;
	
	if _cod_ramo = '001' and _cod_subramo = '006' then
		let _cnt_zl = 1;
	elif _cod_ramo = '003' and _cod_subramo = '005' then
		let _cnt_zl = 1;
	end if
	
	if _cod_grupo in ('00000','1000') then
		let _cnt_gob = 1;
	end if

	let _valor = sp_sis101a(_no_documento,_fecha_ini,_fecha_fin,my_sessionid);	--Crea tabla tmp_corr con el corredor

	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from con_corr
		 where sessionid = my_sessionid 
		  
		let _prima_dev_cor = 0.00;  
		
		let _prima_dev_cor = _monto_dev * _porcentaje /100;
		
		if _cnt_zl = 1 then
			let _prima_zl = _prima_dev_cor;
		else
			let _prima_zl = 0;
		end if
		if _cnt_gob = 1 then
			let _prima_gob = _prima_dev_cor;
		else
			let _prima_gob = 0;
		end if
		
		select zon.nombre
		  into _zona_ventas
		  from parpromo pro
		 inner join agtvende zon on zon.cod_vendedor = pro.cod_vendedor
		 where pro.cod_agente = _cod_agente
		   and pro.cod_ramo = _cod_ramo
		   and pro.cod_agencia = '001';

		insert into tmp_concurso1(no_documento, prima_dev_cor, cod_agente,tipo,prima_zl,prima_gob,nom_chequera,zona_ventas)
		values (_no_documento,_prima_dev_cor, _cod_agente,0,_prima_zl,_prima_gob,_nom_chequera,_zona_ventas);
	end foreach
	
end foreach

--*****SALIDA****
foreach
	select cod_agente,
	       nom_chequera,
		   zona_ventas,
		   sum(prima_dev_cor),
		   sum(impuesto_cor),
		   sum(prima_coa_cor),
		   sum(prima_fac_cor),
		   sum(prima_zl),
		   sum(prima_gob),
		   sum(prima_cen_cor),
		   sum(prima_net_cor)
	  into _cod_agente,
	       _nom_chequera,
		   _zona_ventas,
	       _prima_dev_cor,
           _impuesto_cor,
		   _prima_coa_cor,
		   _prima_fac_cor,
		   _prima_zl,
		   _prima_gob,
		   _prima_cen_cor,
		   _prima_net_cor
	  from tmp_concurso1
     group by cod_agente,nom_chequera,zona_ventas
	 
	--********  Unificacion de Agente *******
	call sp_che168(_cod_agente) returning _error,_cod_agente_tmp;
	
	select nombre
	  into _n_cor_agrupado
	  from agtagent
	 where cod_agente = _cod_agente_tmp;
	 
	select nombre
	  into _n_corredor
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	return  _zona_ventas,
		    _cod_agente_tmp,
			_n_cor_agrupado,
			_cod_agente,
			_n_corredor,
			_nom_chequera,
			_prima_dev_cor,
			_impuesto_cor,
			_prima_coa_cor,
			_prima_fac_cor,
			_prima_zl,
			_prima_gob,
			_prima_cen_cor,
			_prima_net_cor with resume;
	 
end foreach

end
END PROCEDURE; 