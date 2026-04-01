-- Informe de Detalle de Transacciones de Pagos de Reclamos
-- Creado    : 01/08/2023 - Autor: Henry Giron
-- SIS v.2.0 - d_sp_rec748_dw1 - DEIVID, S.A.
-- execute procedure sp_rec748('2023-01','2023-10') 

DROP PROCEDURE sp_rec748;
CREATE PROCEDURE sp_rec748(a_periodo_desde CHAR(7),a_periodo_hasta CHAR(7)) 

RETURNING char(20) as poliza,
			varchar(50) as ramo,
			char(50) as subramo,
			char(18) as reclamo,
			char(10) as transaccion,
			char(10) as anular_nt,
			char(7) as periodo,
			varchar(100) as reclamante,
			varchar(100) as diagnostico,
			varchar(100) as procedimiento,
			date as fecha_documento,
			date as fecha_reclamo,
			date as fecha_siniestro,
			date as fecha_factura,
			date as fecha_pagado,
			date as fechatrx,
			varchar(50) as tipo_pago,
			varchar(50) as codcobertura,
			varchar(50) as cobertura,
			char(3) as codtipocob,
			varchar(50) as tipocobertura,
			dec(16,2) as facturado,
			dec(16,2) as montonocubierto,
			dec(16,2) as elegible,
			dec(16,2) as copago,
			dec(16,2) as coaseguro,
			dec(16,2) as adeducible,
			dec(16,2) as ahorro,
			dec(16,2) as montopagado,
			char(3) as codnocubierto,
			char(50) as razonnocubierto,
			char(10) as codclienteafavorde,
			char(10) as codproveedor,
			char(100) as afavorde,
			char(10) as codasignacion,
			char(5) as codcorredor,
			varchar(50) as corredor,
			date as fechacreado,
			/*date as fecha_ajustador,
			date as fecha_scan,
			date as fecha_reasigno,*/
			date as fechacompletado,
			dec(16,2) as montobloque,
			smallint as preautorizado,
			char(10) as codcontratante,
			varchar(50) as contratante,
			char(7) as codgrupo,
			varchar(50) as grupo,
			char(5) as cod_producto,
			varchar(50) as producto,
			varchar(50) as compania_nombre,
			char(10) as no_poliza,
			char(40) as tipo_proveedor,
			char(21) as tipo_red
			/*,
			char(10)	as no_requis,
			date		as fecha_pag_requis,
			date		as fecha_paso_firma,
			date		as fecha_firma1,
			date		as fecha_firma2,
			date		as fecha_pre_aut*/; 

define	_nombre_aseg		varchar(100);
define	_reclamante			varchar(100);
define	_nombre_icd			varchar(100);
define	_nombre_cpt			varchar(100);
define	_nombre_cobertura	varchar(50);
define	_nombre_producto	varchar(50);
define	_razonnocubierto	varchar(50);
define	_tipo_cobertura		varchar(50);
define _compania_nombre 	VARCHAR(50);
define	_cod_cobertura		varchar(50);
define	_nombre_agente		varchar(50);
define	_desc_subramo		varchar(50);
define	_contratante		varchar(50);
define	_tipo_pago			varchar(50);
define	_grupo				varchar(50);
define	_desc_ramo			varchar(50);
define	_no_documento		char(20);
define	_numrecla			char(18);
define	_codclienteafavorde	char(10);
define	_codcontratante		char(10);
define	_codasignacion		char(10);
define	_codproveedor		char(10);
define	_no_poliza			char(10);
define	_transaccion		char(10);
define	_anular_nt			char(10);
define	_no_requis			char(10);
define	_cod_producto		char(7);
define	_codgrupo			char(7);
define	_periodo			char(7);
define	_no_unidad			char(5);
define	_cod_agente			char(5);
define	_cod_ramo			char(3);
define	_codnocubierto		char(3);
define	_cod_tipo			char(3);
define	_facturado			dec(16,2);
define	_monto_no_cubierto	dec(16,2);
define	_elegible			dec(16,2);
define	_copago				dec(16,2);
define	_coaseguro			dec(16,2);
define	_adeducible			dec(16,2);
define	_ahorro				dec(16,2);
define	_montopagado		dec(16,2);
define	_montobloque		dec(16,2);
define	_preautorizado		smallint;
define	_fecha_paso_firma	date;
define	_fecha_pag_requis	date;
define	_fecha_documento	date;
define	_fecha_siniestro	date;
define	_fechacompletado	date;
define	_fecha_ajustador	date;
define	_fecha_reasigno		date;
define	_fecha_reclamo		date;
define	_fecha_factura		date;
define	_fecha_pre_aut		date;
define	_fecha_pagado		date;
define	_fecha_firma1		date;
define	_fecha_firma2		date;
define	_fechacreado		date;
define	_fecha_scan			date;
define	_fecha				date;
define _tipo_red            CHAR(21);
define _tipo_proveedor      char(3);
DEFINE _n_tip_prov          char(40);

set isolation to dirty read;
--set debug file to "sp_rec748.trc";
--trace on;
LET _compania_nombre = sp_sis01('001');

let _desc_ramo = '';
let _desc_subramo = '';

foreach
	select	emi.no_documento,
			emi.no_poliza,
			ram.nombre,	
			sub.nombre,
			rec.numrecla,
			rec.no_unidad,
			trx.transaccion,			
			nvl(trx.anular_nt,''),
			trx.periodo,
			rcl.nombre,
			icd.nombre,
			cpt.nombre,
			rec.fecha_documento,
			rec.fecha_reclamo,
			rec.fecha_siniestro,
			trx.fecha_factura,
			trx.fecha_pagado,
			trx.fecha,
			tip.nombre,
			cob.cod_cobertura,
			cob.nombre,
			sal.cod_tipo,
			sal.nombre,
			tco.facturado,
			tco.monto_no_cubierto,
			tco.elegible,
			tco.co_pago,
			tco.coaseguro,
			tco.a_deducible,
			tco.ahorro,
			tco.monto,
			tco.cod_no_cubierto,
			cub.nombre,
			trx.cod_cliente,
			trx.cod_proveedor,
			cli.nombre,
			trx.cod_asignacion,
			agt.cod_agente,
			agt.nombre,
			doc.date_added,
			doc.ajustador_fecha,
			doc.fecha_scan,
			doc.fecha_reasigno,
			doc.fecha_completado,			
			doc.monto,
			doc.preautorizado,
			emi.cod_contratante,
			con.nombre,
			grp.cod_grupo,
			grp.nombre,
			emi.cod_ramo,
			prd.cod_producto,
			prd.nombre,
			chq.no_requis,
			chq.fecha_cobrado,
			chq.fecha_paso_firma,
			chq.fecha_firma1,
			chq.fecha_firma2,
			chq.date_pre_aut,
			decode(cli.tipo_red,0,'ANCON HEALTH NETWORK',1,'ANCON PREMIER CARE',2,'AMBAS'),
			cli.tipo_proveedor
		INTO _no_documento,
		    _no_poliza,
			_desc_ramo,
			_desc_subramo,
			_numrecla,
			_no_unidad,
			_transaccion,
			_anular_nt,
			_periodo,
			_reclamante,
			_nombre_icd,
			_nombre_cpt,
			_fecha_documento,
			_fecha_reclamo,
			_fecha_siniestro,
			_fecha_factura,
			_fecha_pagado,
			_fecha,
			_tipo_pago,
			_cod_cobertura,
			_nombre_cobertura,
			_cod_tipo,
			_tipo_cobertura,
			_facturado,
			_monto_no_cubierto,
			_Elegible,
			_CoPago,
			_Coaseguro,
			_Adeducible,
			_Ahorro,
			_MontoPagado,
			_CodNoCubierto,
			_RazonNoCubierto,
			_CodClienteAFavorDe,
			_CodProveedor,
			_nombre_aseg,
			_CodAsignacion,
			_cod_agente,
			_nombre_agente,
			_FechaCreado,
			_fecha_ajustador,
			_fecha_scan,
			_fecha_reasigno,
			_FechaCompletado,
			_MontoBloque,
			_Preautorizado,
			_CodContratante,
			_Contratante,
			_CodGrupo,
			_Grupo,
			_cod_Ramo,
			_cod_producto,
			_nombre_producto,
			_no_requis,
			_fecha_pag_requis,
			_fecha_paso_firma,
			_fecha_firma1,
			_fecha_firma2,
			_fecha_pre_aut,
			_tipo_red,
			_tipo_proveedor
	   from rectrmae trx
	 inner join recrcmae rec on rec.no_reclamo = trx.no_reclamo
	 inner join emipomae emi on emi.no_poliza = rec.no_poliza
	 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	 inner join rectipag tip on tip.cod_tipopago = trx.cod_tipopago
	 inner join rectrcob tco on tco.no_tranrec = trx.no_tranrec
	 inner join prdcober cob on cob.cod_cobertura = tco.cod_cobertura
	 inner join cliclien cli on cli.cod_cliente = trx.cod_cliente
	 inner join cliclien rcl on rcl.cod_cliente = rec.cod_reclamante
	 inner join cliclien con on con.cod_cliente = emi.cod_contratante
	 inner join emipoliza pol on pol.no_documento = rec.no_documento
	 inner join agtagent agt on agt.cod_agente = pol.cod_agente
	 inner join cligrupo grp on grp.cod_grupo = emi.cod_grupo
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	  left join emipouni uni on uni.no_poliza = emi.no_poliza and uni.no_unidad = rec.no_unidad 
	  left join prdprod prd on prd.cod_producto = uni.cod_producto
	  left join atcdocde doc on doc.cod_asignacion = trx.cod_asignacion
	  left join recicd icd on icd.cod_icd = rec.cod_icd
	  left join reccpt cpt on cpt.cod_cpt = trx.cod_cpt
	  left join recnocub cub on cub.cod_no_cubierto = tco.cod_no_cubierto
	  left join prdticob sal on sal.cod_tipo = tco.cod_tipo
	  left join chqchmae chq on chq.no_requis = trx.no_requis
	 where trx.cod_tipotran = '004'
	   and trx.periodo between a_periodo_desde and a_periodo_hasta
	   and trx.actualizado = 1
	   and emi.cod_ramo in ('018','004','016')
	   and trx.anular_nt is null
	
	if _cod_producto is null then
		foreach
			select prd.cod_producto,
				   prd.nombre
			  into _cod_producto,
				   _nombre_producto
			  from endedmae mae
			 inner join endeduni uni on uni.no_poliza = mae.no_poliza and uni.no_unidad = _no_unidad
			 inner join prdprod prd on prd.cod_producto = uni.cod_producto
			 where mae.no_poliza = _no_poliza
			   and mae.actualizado = 1
			   and mae.fecha_emision <= _fecha
			 order by fecha_emision desc
			exit foreach;
		end foreach
	end if
	
	if _fecha_factura is null then
		let _fecha_factura = '';
	end if
	select descripcion
	  into _n_tip_prov
	  from rectipprov
	 where codigo = _tipo_proveedor;
	 
	RETURN  _no_documento,
	        _desc_ramo,
			_desc_subramo,
			_numrecla,
			_transaccion,
			_anular_nt,
			_periodo,
			_reclamante,
			_nombre_icd,
			_nombre_cpt,
			_fecha_documento,
			_fecha_reclamo,
			_fecha_siniestro,
			_fecha_factura,
			_fecha_pagado,
			_fecha,
			_tipo_pago,
			_cod_cobertura,
			_nombre_cobertura,
			_cod_tipo,
			_tipo_cobertura,
			_facturado,
			_monto_no_cubierto,
			_Elegible,
			_CoPago,
			_Coaseguro,
			_Adeducible,
			_Ahorro,
			_MontoPagado,
			_CodNoCubierto,
			_RazonNoCubierto,
			_CodClienteAFavorDe,
			_CodProveedor,
			_nombre_aseg,
			_CodAsignacion,
			_cod_agente,
			_nombre_agente,
			_FechaCreado,
			_FechaCompletado,
			_MontoBloque,
			_Preautorizado,
			_CodContratante,
			_Contratante,
			_CodGrupo,
			_Grupo,
			_cod_producto,
			_nombre_producto,
            _compania_nombre,
			_no_poliza,
			_n_tip_prov,
			_tipo_red
		   WITH RESUME;
END FOREACH
END PROCEDURE;




