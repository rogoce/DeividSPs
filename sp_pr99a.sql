-- Listado de Aniversario Colectivo de Salud - Filtro de Datos 
-- Creado   :  25/10/2011 - Autor:  Giron Henry 
-- SIS v.2.0 d_- DEIVID, S.A. 

--DROP PROCEDURE sp_pr99a; 
CREATE PROCEDURE "informix".sp_pr99a(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*", 
a_ramo  	CHAR(255) DEFAULT "*", 
a_grupo 	CHAR(255) DEFAULT "*", 
a_usuario   CHAR(255) DEFAULT "*", 
a_reaseguro CHAR(255) DEFAULT "*", 
a_agente    CHAR(255) DEFAULT "*", 
a_saldo_cero SMALLINT, 
a_cod_cliente CHAR(255) DEFAULT "*", 
a_no_documento CHAR(255) DEFAULT "*", 
a_opcion_renovar SMALLINT DEFAULT 0, 
a_tipo_prod			CHAR(255) DEFAULT "*",
a_cod_vendedor		CHAR(255) DEFAULT "*",
a_status_pool       CHAR(255) DEFAULT "*")
RETURNING CHAR(20), CHAR(100), DATE, CHAR(10), CHAR(10), DECIMAL(16,2), CHAR(50), DECIMAL(16,2), CHAR(50), CHAR(50), CHAR(50), CHAR(255), SMALLINT,CHAR(10),CHAR(10),SMALLINT,DATE,VARCHAR(50),VARCHAR(50), DECIMAL(16,2),smallint, DATE, DECIMAL(16,2);

DEFINE v_nombre_ramo   	 CHAR(50);
DEFINE v_nombre_grupo 	 CHAR(50);
DEFINE v_nombre_cliente  CHAR(100);
DEFINE v_nombre_agente   CHAR(50);
DEFINE _saldo			 DECIMAL(16,2);
DEFINE _prima			 DECIMAL(16,2);
DEFINE _ultfact_prima_bruta DECIMAL(16,2); 
DEFINE v_compania_nombre CHAR(50);
DEFINE v_filtros         CHAR(255);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_grupo        CHAR(5);
DEFINE _cod_contratante  CHAR(10);
DEFINE _cod_agente       CHAR(5);
DEFINE _no_documento     CHAR(20);
DEFINE _vigencia_final   DATE;
DEFINE _vigencia_inicial DATE;
DEFINE _fecha_ult_pago   DATE;
DEFINE v_tel1			 CHAR(10);
DEFINE v_tel2			 CHAR(10);
DEFINE v_tel3			 CHAR(10);
DEFINE v_celular	  	 CHAR(10);
DEFINE v_conoce_cliente  smallint;
DEFINE _cod_formapag	 CHAR(3);
DEFINE _formapag		 VARCHAR(50);
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_acreedor     CHAR(5);
DEFINE _acreedor         VARCHAR(50);
DEFINE _porc_saldo		 DECIMAL(16,2);
DEFINE _estatus_pool	 smallint;
DEFINE _fecha_final      DATE;
DEFINE _fecha_inicial    DATE;
define _dif_meses			smallint;
define _mes1				smallint;
define _mes2				smallint;


SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania
LET v_compania_nombre = sp_sis01(a_compania);
--DROP TABLE tmp_prod;

LET _mes1 = a_periodo1[6,7];
LET _mes2 = a_periodo2[6,7];

let _dif_meses	= _mes2 - _mes1 + 1;

if _dif_meses < 0 then
	let _dif_meses = _dif_meses + 12;
end if

if _dif_meses > 3 then
	return '',
		   '',
		   '01/01/1900',
		   '',
		   '',
		   0.00,
		   '',
		   0.00,
		   '',
		   '',
		   '',
		   '',
		   0,
		   '',
		   '',
		   0,
		   '01/01/1900',
		   '',
		   '',
		   0.00,
		   0,
		   '',
		   '';
end if


LET v_filtros = sp_pr99b(
a_compania,
a_agencia,
a_periodo1,
a_periodo2,
a_sucursal,
a_ramo,
a_grupo,
a_usuario,
a_reaseguro,
a_agente,
a_saldo_cero,
a_cod_cliente,
a_no_documento,
a_opcion_renovar
);
--Recorre la tabla temporal y asigna valores a variables de salida
--SET DEBUG FILE TO "sp_pr99b.trc";
--trace on;

FOREACH WITH HOLD
 SELECT no_documento, cod_contratante, vigencia_final, prima, cod_agente, saldo, cod_ramo, cod_grupo, vigencia_inicial
   INTO _no_documento, _cod_contratante, _vigencia_final, _prima, _cod_agente, _saldo, _cod_ramo, _cod_grupo, _vigencia_inicial
   FROM tmp_prod
   WHERE seleccionado = 1
  ORDER BY cod_grupo, cod_ramo, no_documento

 LET _no_poliza=sp_sis21(_no_documento);
 LET _cod_acreedor = NULL;

--Selecciona los nombres de Ramos
         SELECT nombre
  	       INTO v_nombre_ramo
           FROM prdramo
          WHERE cod_ramo = _cod_ramo;

--Selecciona los nombres de los Grupos
         SELECT nombre
  	       INTO v_nombre_grupo
           FROM cligrupo
          WHERE cod_grupo = _cod_grupo;

--Selecciona los nombres de Clientes
         SELECT nombre,telefono1,telefono2 ,telefono3, celular, conoce_cliente
  	       INTO v_nombre_cliente,v_tel1,v_tel2,v_tel3,v_celular, v_conoce_cliente
           FROM cliclien
          WHERE cod_cliente = _cod_contratante;

--Selecciona los nombres de los Corredores
         SELECT nombre
  	       INTO v_nombre_agente
           FROM agtagent
          WHERE cod_agente = _cod_agente;

--Selecciona el fecha de ultimo pago, la forma de pago y acreedor
		 SELECT fecha_ult_pago,cod_formapag
		   INTO _fecha_ult_pago,_cod_formapag
		   FROM emipomae
		  WHERE	no_poliza =_no_poliza;

		 SELECT nombre
		   INTO	_formapag
		   FROM cobforpa
		  WHERE	cod_formapag = _cod_formapag;

--Selecciona el acreedor
		 FOREACH
				SELECT cod_acreedor
			   	  INTO _cod_acreedor
			   	  FROM emipoacr
			  	 WHERE no_poliza = _no_poliza
	   		  ORDER BY no_unidad ASC
	   	 EXIT FOREACH;
		 END FOREACH

		let _acreedor = ""; 
		if _cod_acreedor is not null then

		 SELECT nombre
		   INTO	_acreedor
		   FROM emiacre
		  WHERE	cod_acreedor = _cod_acreedor;
		end if

--Selecciona la ultima prima facturada del aniverversario
let _ultfact_prima_bruta = 0.00;
let _fecha_inicial = sp_sis36((year(_vigencia_final) - 1) || "-" || (month(_vigencia_final) - 1)); -- mdy(_mes_inic, 1, a_anio);
let _fecha_final   = _vigencia_final; 
	 FOREACH
		SELECT sum(prima_bruta)
	   	  INTO _ultfact_prima_bruta
	   	  FROM endedmae
	  	 WHERE no_poliza = _no_poliza
		   AND cod_endomov = '014'
		   and fecha_emision >= _fecha_inicial 
		   and fecha_emision <= _fecha_final
--	 ORDER BY fecha_emision DESC
   	 EXIT FOREACH;
	  END FOREACH		 

if _ultfact_prima_bruta is null then
	let _prima = _prima;
 else
	let _prima = _ultfact_prima_bruta;
end if

--
--Calculo para porcentaje de la prima bruta
 LET _porc_saldo=_prima;
 LET _porc_saldo=_porc_saldo * 0.10;
--		
		 
--saber en que pool esta
let _estatus_pool = null;

 SELECT estatus
   INTO	_estatus_pool
   FROM emirepo
  WHERE	no_poliza = _no_poliza;

 if _estatus_pool is null then

	 SELECT estatus
	   INTO	_estatus_pool
	   FROM emirepol
	  WHERE	no_poliza = _no_poliza;
	
 end if

 if _estatus_pool in(1,2,3,4,5,9) then
 else
	let _estatus_pool = 0;
 end if

RETURN _no_documento,
   	   v_nombre_cliente,
	   _vigencia_final,
	   v_tel1,
	   v_tel2,
	   _prima,
	   v_nombre_agente,
	   _saldo,
	   v_nombre_ramo,
	   v_nombre_grupo,
	   v_compania_nombre,
	   v_filtros,
	   a_opcion_renovar,
	   v_tel3,	
	   v_celular,
	   v_conoce_cliente,
	   _fecha_ult_pago,
	   _formapag,
	   _acreedor,
       _porc_saldo,
	   _estatus_pool,
	   _vigencia_inicial,
	   _ultfact_prima_bruta
	   WITH RESUME;

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;
