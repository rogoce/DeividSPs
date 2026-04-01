-- Informe de Detalle de Transacciones de Pagos de Reclamos
-- Creado    : 01/08/2023 - Autor: Henry Giron
-- SIS v.2.0 - d_sp_rec748_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec748;
CREATE PROCEDURE sp_rec748(a_periodo_desde CHAR(7),a_periodo_hasta CHAR(7)) 

RETURNING char(20)	as	poliza	,
varchar(50)	as	ramo	,
char(50)	as	subramo	,
char(18)	as	reclamo	,
char(10)	as	transaccion	,
char(10)	as	anular_nt	,
char(7)	as	periodo	,
varchar(100)	as	reclamante	,
varchar(100)	as	diagnostico	,
varchar(100)	as	procedimiento	,
date	as	fecha_documento	,
date	as	fecha_reclamo	,
date	as	fecha_siniestro	,
date	as	fecha_factura	,
date	as	fecha_pagado	,
date	as	fechatrx	,
varchar(50)	as	tipo_pago	,
varchar(50)	as	codcobertura	,
varchar(50)	as	cobertura	,
char(3)	as	codtipocob	,
varchar(50)	as	tipocobertura	,
dec(16,2)	as	facturado	,
dec(16,2)	as	montonocubierto	,
dec(16,2)	as	elegible	,
dec(16,2)	as	copago	,
dec(16,2)	as	coaseguro	,
dec(16,2)	as	adeducible	,
dec(16,2)	as	ahorro	,
dec(16,2)	as	montopagado	,
char(3)	as	codnocubierto	,
char(50)	as	razonnocubierto	,
char(10)	as	codclienteafavorde	,
char(10)	as	codproveedor	,
char(100)	as	afavorde	,
char(10)	as	codasignacion	,
char(5)	as	codcorredor	,
varchar(50)	as	corredor	,
date	as	fechacreado	,
date	as	fechacompletado	,
dec(16,2)	as	montobloque	,
smallint	as	preautorizado	,
char(10)	as	codcontratante	,
varchar(50)	as	contratante	,
char(7)	as	codgrupo	,
varchar(50)	as	grupo,
varchar(50)	as	compania_nombre	

; 

define	_no_documento	char(20);
define	_desc_subramo	char(50);
define	_numrecla	char(18);
define	_transaccion	char(10);
define	_anular_nt	char(10);
define	_periodo	char(7);
define	_reclamante	varchar(100);
define	_nombre_icd	varchar(100);
define	_nombre_cpt	varchar(100);
define	_fecha_documento	date;
define	_fecha_reclamo	date;
define	_fecha_siniestro	date;
define	_fecha_factura	date;
define	_fecha_pagado	date;
define	_fecha	date;
define	_tipo_pago	varchar(50);
define	_cod_cobertura	varchar(50);
define	_nombre_cobertura	varchar(50);
define	_cod_tipo	char(3);
define	_tipo_cobertura	varchar(50);
define	_facturado	dec(16,2);
define	_monto_no_cubierto	dec(16,2);
define	_elegible	dec(16,2);
define	_copago	dec(16,2);
define	_coaseguro	dec(16,2);
define	_adeducible	dec(16,2);
define	_ahorro	dec(16,2);
define	_montopagado	dec(16,2);
define	_codnocubierto	char(3);
define	_razonnocubierto	char(50);
define	_codclienteafavorde	char(10);
define	_codproveedor	char(10);
define	_nombre_aseg	char(100);
define	_codasignacion	char(10);
define	_cod_agente	char(5);
define	_nombre_agente	varchar(50);
define	_fechacreado	date;
define	_fechacompletado	date;
define	_montobloque	dec(16,2);
define	_preautorizado	smallint;
define	_codcontratante	char(10);
define	_contratante	varchar(50);
define	_codgrupo	char(7);
define	_grupo	varchar(50);
define	_cod_ramo	char(3);
define	_desc_ramo	varchar(50);
define _compania_nombre VARCHAR(50);

set isolation to dirty read;
--set debug file to "sp_rec748.trc";
--trace on;
LET _compania_nombre = sp_sis01('001');

let _desc_ramo = '';
let _desc_subramo = '';


FOREACH
	select emi.no_documento,
	        ram.nombre,	
			sub.nombre,
			rec.numrecla,
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
			doc.fecha_completado,
			doc.monto,
			doc.preautorizado,
			emi.cod_contratante,
			con.nombre,
			grp.cod_grupo,
			grp.nombre,
			emi.cod_ramo            	
		INTO _no_documento,
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
			_cod_Ramo				
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
	  left join atcdocde doc on doc.cod_asignacion = trx.cod_asignacion
	  left join recicd icd on icd.cod_icd = rec.cod_icd
	  left join reccpt cpt on cpt.cod_cpt = trx.cod_cpt
	  left join recnocub cub on cub.cod_no_cubierto = tco.cod_no_cubierto
	  left join prdticob sal on sal.cod_tipo = tco.cod_tipo
	 where trx.cod_tipotran = '004'
	   and trx.periodo between a_periodo_desde and a_periodo_hasta
	   and trx.actualizado = 1
	   and emi.cod_ramo in ('018','004')
	   and trx.anular_nt is null


	RETURN _no_documento,
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
            _compania_nombre			
		   WITH RESUME;

END FOREACH


                                                     
END PROCEDURE;




