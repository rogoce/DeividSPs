-- Listado de Cooredores segun Bonos y sus agrupados
-- Creado    : 23/01/2019 - Autor: Henry Girón
-- SIS v.2.0 - d_cobr_sp_cob168_REP_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob168_rep_cob;
CREATE PROCEDURE "informix".sp_cob168_rep_cob()
RETURNING	smallint as bono,
			CHAR(255) as Filtros;

			

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);
DEFINE v_nombre_agente		CHAR(50);
DEFINE _cod_agente			CHAR(5);
DEFINE v_tipo_persona			CHAR(1);
DEFINE v_numero_licencia		CHAR(10);
DEFINE _no_poliza				CHAR(10);
DEFINE v_telefono_2			CHAR(10);
DEFINE v_nombre_cobrador		CHAR(50);

DEFINE v_compania_nombre		CHAR(50);
DEFINE _cod_coasegur			CHAR(3);
DEFINE _cod_tipoprod			CHAR(3);
DEFINE _cod_agrupado			CHAR(5);
define _impuesto				smallint;
define _bono					smallint;
DEFINE _nombre_agrupado		CHAR(50);
DEFINE _tipo_agente			CHAR(1);
define _estatus_licencia		char(1);
define _no_documento			char(20);
define _agente_agrupado		char(5);
define _porc_coaseguro		dec(16,2);
define _prima_suscrita		dec(16,2);
define _porc_impuesto			dec(16,2);
define _por_vencer			dec(16,2);
define _corriente				dec(16,2);
define _prima_fac				dec(16,2);
define _exigible				dec(16,2);
define _monto_90				dec(16,2);
define _monto_60				dec(16,2);
define _monto_30				dec(16,2);
define _saldo					dec(16,2);

	


--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania
let _cod_agrupado = '';
let _bono = 0;

CREATE TEMP TABLE tmp_agente(
cod_agente			CHAR(5),
nombre_agente		CHAR(50),
agrupado			CHAR(5),
nombre_agrupado   char(50),
no_documento		char(20),
prima_suscrita	dec(16,2),
prima_fac			dec(16,2),
exigible_3112		dec(16,2),
saldo				dec(16,2),
seleccionado		SMALLINT	DEFAULT 1
) WITH NO LOG;

foreach 
	select pol.no_documento,
			agt.cod_agente,
			agt.nombre,
			cob.no_poliza
	  into _no_documento,
		   _cod_agente,
		   v_nombre_agente,
		   _no_poliza
	  from cobmoros4 cob
	 inner join emipoliza pol on cob.no_documento = pol.no_documento
	 inner join agtagent agt on agt.cod_agente = pol.cod_agente
	 where cob.saldo_pxc != 0
	   and agt.tipo_agente  = 'A'
	   
	call sp_cob33d('001','001',_no_documento,'2025-12','31/12/2025') returning _por_vencer,_exigible,_corriente,_monto_30,_monto_60,_monto_90,_saldo;

	call sp_che168(_cod_agente) returning _bono, _cod_agrupado;
	
	select nombre
	  into _nombre_agrupado
	  from agtagent
	 where cod_agente = _cod_agrupado;

	select sum(factor_impuesto)
	  into _porc_impuesto
	  from emipolim imp
	 inner join prdimpue prd on prd.cod_impuesto = imp.cod_impuesto
	 where imp.no_poliza = _no_poliza;

	if _porc_impuesto is null then
		let _porc_impuesto  = 0.00;
	end if

	let _exigible = _exigible / (1 + (_porc_impuesto/100));
	let _saldo = _saldo / (1 + (_porc_impuesto/100));
	
	select cod_tipoprod,
		    prima_suscrita
	  into _cod_tipoprod,
		   _prima_suscrita
	  from emipomae
	 where no_poliza = _no_poliza;
	
	if _cod_tipoprod = "001" then	          --Coas. Mayoritario
		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = '036';

		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;		          
		end if
		let _exigible = _exigible * (_porc_coaseguro / 100);
		let _saldo = _saldo * (_porc_coaseguro / 100);
	end if
	
	select sum(c.prima)
	  into _prima_fac
	  from emifacon c, reacomae r
	 where c.no_poliza = _no_poliza
	   and c.no_endoso = '00000'
	   and r.cod_contrato = c.cod_contrato
	   and r.tipo_contrato = 3;
	   
	if _prima_fac is null then
		let _prima_fac = 0.00;
	end if
	
	INSERT INTO tmp_agente(
	cod_agente,      
	nombre_agente,   
	agrupado,
	nombre_agrupado,
	no_documento,
	prima_suscrita,
	prima_fac,
	exigible_3112,
	saldo
	)
	VALUES(
	_cod_agente,
	v_nombre_agente,
	_cod_agrupado,
	_nombre_agrupado,
	_no_documento,
	_prima_suscrita,
	_prima_fac,
	_exigible,
	_saldo
	);
	
	let _cod_agrupado = '';
	let _nombre_agrupado = '';
	let _bono = 0;

END FOREACH
END PROCEDURE;