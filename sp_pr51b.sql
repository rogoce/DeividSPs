-- Reporte de Vencimientos
-- 
-- Creado    : 04/12/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 04/12/2000 - Autor: Lic. Armando Moreno
-- Modificado: 28/08/2001 - Autor: Lic. Marquelda Valdelamar (para incluir filtro de cliente y poliza)
-- Modificado: 07/09/2010 - Autor: Roman Gordon
-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_pr51b;

CREATE PROCEDURE "informix".sp_pr51b(a_compania CHAR(3), a_agencia CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7), a_sucursal CHAR(255) DEFAULT "*", a_ramo CHAR(255) DEFAULT "*", a_grupo CHAR(255) DEFAULT "*", a_usuario CHAR(255) DEFAULT "*", a_reaseguro CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*", a_saldo_cero SMALLINT, a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*", a_opcion_renovar SMALLINT DEFAULT 0)
RETURNING CHAR(20), CHAR(100), DATE, CHAR(10), CHAR(10), DECIMAL(16,2), CHAR(50), DECIMAL(16,2), CHAR(50), CHAR(50), CHAR(50), CHAR(255), SMALLINT,CHAR(10),CHAR(10),SMALLINT,DATE,VARCHAR(50),VARCHAR(50), DECIMAL(16,2),smallint;

DEFINE v_nombre_ramo   	 CHAR(50);
DEFINE v_nombre_grupo 	 CHAR(50);
DEFINE v_nombre_cliente  CHAR(100);
DEFINE v_nombre_agente   CHAR(50);
DEFINE _saldo			 DECIMAL(16,2);
DEFINE _prima			 DECIMAL(16,2);
DEFINE v_compania_nombre CHAR(50);
DEFINE v_filtros         CHAR(255);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_grupo        CHAR(5);
DEFINE _cod_contratante  CHAR(10);
DEFINE _cod_agente       CHAR(5);
DEFINE _no_documento     CHAR(20);
DEFINE _vigencia_final   DATE;
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



SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania


LET v_compania_nombre = sp_sis01(a_compania);


--DROP TABLE tmp_prod;

LET v_filtros = sp_pro51(
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

FOREACH WITH HOLD
 SELECT no_documento, cod_contratante, vigencia_final, prima, cod_agente, saldo, cod_ramo, cod_grupo
   INTO _no_documento, _cod_contratante, _vigencia_final, _prima, _cod_agente, _saldo, _cod_ramo, _cod_grupo
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
	   _estatus_pool

	   WITH RESUME;

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;
