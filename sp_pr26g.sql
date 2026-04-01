-- Reporte de Total de Produccion por Corredor
--
-- Creado    : 09/03/2001 - Autor: Amado Perez
-- Modificado: 09/03/2001 - Autor: Amado Perez
--
-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_pro26g;

CREATE PROCEDURE "informix".sp_pro26g(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7)
) 
RETURNING CHAR(20),
		  CHAR(5),
		  CHAR(3),
		  CHAR(3),
		  CHAR(3),
		  CHAR(3);

DEFINE v_nombre          CHAR(50);
DEFINE v_total_prima_sus DECIMAL(16,2);
DEFINE v_total_prima_nva DECIMAL(16,2);
DEFINE v_total_prima_ren DECIMAL(16,2);
DEFINE v_total_prima_end DECIMAL(16,2);
DEFINE v_total_prima_can DECIMAL(16,2);
DEFINE v_total_prima_rev DECIMAL(16,2);
DEFINE v_cnt_prima_sus   INTEGER;
DEFINE v_cnt_prima_nva   INTEGER;
DEFINE v_cnt_prima_ren   INTEGER;
DEFINE v_cnt_prima_end   INTEGER;
DEFINE v_cnt_prima_can   INTEGER;
DEFINE v_cnt_prima_rev   INTEGER;
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_filtros         CHAR(255);
DEFINE v_nombre_vend	 CHAR(50);

DEFINE _cod_agente       CHAR(5);
DEFINE _cod_sucursal     CHAR(3);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_vendedor     CHAR(3);
DEFINE _cod_agencia      CHAR(3);
DEFINE _no_documento	 CHAR(20);
DEFINE _no_poliza		 CHAR(10);
	
-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

LET v_filtros = sp_pro26(
a_compania,
a_agencia, 
a_periodo1,
a_periodo2
);

--Recorre la tabla temporal y asigna valores a variables de salida

FOREACH
 SELECT cod_agente,
		total_pri_sus,
		total_pri_nva,
		total_pri_ren, 
		total_pri_end, 
		total_pri_can, 
		total_pri_rev, 
		cnt_prima_sus, 
		cnt_prima_nva, 
		cnt_prima_ren, 
		cnt_prima_end, 
		cnt_prima_can, 
		cnt_prima_rev,
		cod_sucursal,
		cod_ramo,
		no_poliza
   INTO _cod_agente,
		v_total_prima_sus,
		v_total_prima_nva, 
		v_total_prima_ren, 
		v_total_prima_end, 
		v_total_prima_can, 
		v_total_prima_rev, 
		v_cnt_prima_sus, 
		v_cnt_prima_nva, 
		v_cnt_prima_ren, 
		v_cnt_prima_end, 
		v_cnt_prima_can, 
		v_cnt_prima_rev,
		_cod_sucursal,
		_cod_ramo,
		_no_poliza
   FROM tmp_prod
  WHERE	seleccionado = 1

	select centro_costo
	  into _cod_agencia
	  from insagen
	 where codigo_agencia  = _cod_sucursal
	   and codigo_compania = a_compania;

	select cod_vendedor
 	  into _cod_vendedor
	  from parpromo
	 where cod_agente  = _cod_agente
	   and cod_agencia = _cod_agencia
	   and cod_ramo    = _cod_ramo;

	SELECT nombre
	  INTO v_nombre
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	SELECT nombre
	  INTO v_nombre_vend
	  FROM agtvende
     WHERE cod_vendedor = _cod_vendedor;

	SELECT no_documento
	  INTO _no_documento
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	if v_nombre_vend is null then

		let v_nombre_vend = " VENDEDOR NO DEFINIDO " || _cod_agente;

		RETURN _no_documento,
		       _cod_agente,
		       _cod_ramo,
		       a_compania,
		       _cod_sucursal,
		       _cod_agencia 
			    WITH RESUME;

	end if


END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;
