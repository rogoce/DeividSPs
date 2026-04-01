-- Procedimiento que Genera el Proceso Intermedio de Seleccion
-- de a cuales corredores se generaran los cheques  

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/04/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 14/10/2005 - Autor: Amado Perez Mendoza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che05;

CREATE PROCEDURE sp_che05() RETURNING integer;
			
DEFINE v_generar_chq    SMALLINT; 
DEFINE v_nombre_agt     CHAR(50); 
DEFINE v_comision       DEC(16,2);
DEFINE v_comis_periodo  DEC(16,2);
DEFINE v_comis_arrastre DEC(16,2);
DEFINE v_cod_cuenta     CHAR(17);
DEFINE v_alias     		CHAR(50);

DEFINE _cod_agente      CHAR(5);  
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_poliza       CHAR(10); 
DEFINE _monto_minimo    DEC(16,2);
DEFINE _tipo_pago       SMALLINT; 

DEFINE _comis_desc		DEC(16,2);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che05.trc";
--TRACE ON;

--DROP TABLE tmp_ramo;

CREATE TEMP TABLE tmp_ramo(
	cod_agente		CHAR(5),
	cod_ramo		CHAR(3),
	comision		DEC(16,2),
	PRIMARY KEY (cod_agente, cod_ramo)
	) WITH NO LOG;

-- Genera los registros de las comisiones

CALL sp_che02(
a_compania, 
a_sucursal,
a_fecha_desde,
a_fecha_hasta,
0
);

-- Genera el intermedio de los cheques

LET _comis_desc = 0;

FOREACH
 SELECT	cod_agente,
 		no_poliza,
		comision
   INTO	_cod_agente,
   		_no_poliza,
		v_comision
   FROM	tmp_agente
  WHERE no_poliza <> '00000'

	SELECT cod_ramo
	  INTO _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre,
		   generar_cheque,
		   saldo
	  INTO v_nombre_agt,
	  	   v_generar_chq,
		   v_comis_arrastre
	  FROM agtagent
	 WHERE cod_agente = _cod_agente; 	   		   	

	BEGIN

		ON EXCEPTION IN(-239)

			UPDATE tmp_ramo
			   SET comision   = comision + v_comision
			 WHERE cod_agente = _cod_agente
			   AND cod_ramo   = _cod_ramo;

		END EXCEPTION

		INSERT INTO tmp_ramo(
		cod_agente,
		cod_ramo,
		comision
		)
		VALUES(
		_cod_agente,
		_cod_ramo,
		v_comision
		);

	END

END FOREACH

FOREACH 
 SELECT SUM(comision),
		cod_agente
   INTO _comis_desc,
		_cod_agente
   FROM tmp_agente
  WHERE no_poliza = '00000'
  GROUP BY cod_agente

	LET _comis_desc = _comis_desc * -1;

   FOREACH		
	SELECT comision,
		   cod_ramo	
	  INTO v_comision,
	       _cod_ramo   
	  FROM tmp_ramo
	 WHERE cod_agente = _cod_agente
	 ORDER BY cod_ramo

		IF _comis_desc = 0 THEN
			EXIT FOREACH;
		ELSE
			IF _comis_desc >= v_comision THEN
				UPDATE tmp_ramo
				   SET comision   = 0
				 WHERE cod_agente = _cod_agente
				   AND cod_ramo   = _cod_ramo;
				LET _comis_desc   = _comis_desc - v_comision;
			ELSE
				UPDATE tmp_ramo
				   SET comision   = comision - _comis_desc
				 WHERE cod_agente = _cod_agente
				   AND cod_ramo   = _cod_ramo;
				LET _comis_desc   = 0;
			END IF
		END IF

	END FOREACH

	DELETE FROM tmp_ramo
	 WHERE cod_agente = _cod_agente
	   AND comision   = 0; 

END FOREACH

FOREACH
 SELECT comision,
		cod_agente
   INTO v_comis_periodo,
		_cod_agente
   FROM tmp_ramo
  where cod_agente in ("00912", "01033")

	select 
	  into
	  from chqchagt
	 where 
	
END FOREACH

DROP TABLE tmp_agente;
DROP TABLE tmp_ramo;

RETURN 0;

END PROCEDURE;