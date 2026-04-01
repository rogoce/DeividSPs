-- Listado  de Vencimientos
-- Creado   :  31/12/2008 - Autor:  Ricardo Jim‚nez
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro51b;

CREATE PROCEDURE "informix".sp_pro51b(
       a_compania  	    CHAR(3),
       a_agencia   	    CHAR(3),
       a_periodo1  	    CHAR(7),
       a_periodo2  	    CHAR(7),
	   a_sucursal  	    CHAR(255) DEFAULT "*",
       a_saldo          CHAR(1),
       a_poliza         CHAR(20)  DEFAULT "*" ) RETURNING  CHAR(255);

DEFINE _sucursal_origen  CHAR(3);
DEFINE _cod_agente       CHAR(5);
DEFINE _cod_ramo    	 CHAR(3);
DEFINE _cod_grupo        CHAR(5);
DEFINE _no_documento     CHAR(20);

DEFINE _cod_contratante  CHAR(10);
DEFINE _no_poliza		 CHAR(10);
DEFINE _vigencia_final   DATE;
DEFINE _vigencia_inic    DATE;
DEFINE _prima			 DECIMAL(16,2);
DEFINE _saldo		   	 DECIMAL(16,2);
DEFINE _periodo		     CHAR(7);

DEFINE _desc_agente      CHAR(50);
DEFINE _cod_tipoprod     CHAR(3);
DEFINE _tipo_produccion  CHAR(1);
DEFINE _fecha1  		 DATE;
DEFINE _fecha2	 		 DATE;

DEFINE _mes1     		 SMALLINT;
DEFINE _mes2     	     SMALLINT;
DEFINE _ano1     	     SMALLINT;
DEFINE _ano2     		 SMALLINT;
DEFINE _vfiltros         CHAR(255);
DEFINE _tipo, _estatus   CHAR(1);
DEFINE _porc_saldos      DECIMAL(16,2);
DEFINE _prima_porc       DECIMAL(16,2);
DEFINE _por_vencer_tot   DECIMAL(16,2);
DEFINE _saber 			 CHAR(3);
DEFINE _codigo			 CHAR(5);

LET    _porc_saldos = 10;

-- Descomponer los periodos en fechas
LET _ano1 = a_periodo1[1,4];
LET _mes1 = a_periodo1[6,7];

LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];

LET _mes1   = _mes1;
LET _fecha1 = MDY(_mes1,1,_ano1);

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF

LET _fecha2  = MDY(_mes2,1,_ano2);
LET _fecha2  = _fecha2 - 1;

-- Tabla Temporal tmp_prod

CREATE TEMP TABLE tmp_prod(
	   sucursal_origen   CHAR(3)   NOT NULL,
	   cod_ramo       	 CHAR(3)   NOT NULL,
	   no_documento   	 CHAR(20)  NOT NULL,
	   cod_contratante   CHAR(10)  NOT NULL,
	   vigencia_inicial  DATE      NOT NULL,
	   vigencia_final 	 DATE      NOT NULL,
	   no_poliza	     CHAR(10)  NOT NULL,
	   prima             DECIMAL(16,2) NOT NULL,
	   saldo	         DECIMAL(16,2) NOT NULL,
	   tipo_produccion   CHAR(3)   NOT NULL,
	   estatus			 CHAR(1)   NOT NULL,
	   seleccionado   	 SMALLINT  DEFAULT 1 NOT NULL
	   ) WITH NO LOG;


CREATE INDEX iend1_tmp_prod ON tmp_prod(sucursal_origen);
CREATE INDEX iend2_tmp_prod ON tmp_prod(cod_ramo);
CREATE INDEX iend3_tmp_prod ON tmp_prod(no_documento);
CREATE INDEX iend4_tmp_prod ON tmp_prod(tipo_produccion);


LET _cod_agente = "*";

SET ISOLATION TO DIRTY READ;

FOREACH WITH HOLD
	--Informacion de Poliza
	  SELECT no_poliza,
			 sucursal_origen, 
			 cod_tipoprod, 
			 cod_ramo, 
			 no_documento, 
			 cod_contratante, 
			 vigencia_inic,
			 vigencia_final, 
			 prima_bruta
		INTO _no_poliza, 
		  	 _sucursal_origen,
		  	 _cod_tipoprod,
		  	 _cod_ramo, 
		  	 _no_documento, 
			 _cod_contratante,
			 _vigencia_inic, 
			 _vigencia_final, 
			 _prima
		FROM emipomae
	   WHERE vigencia_final between _fecha1 and _fecha2
		 AND actualizado    = 1
		 AND no_renovar     = 0
	     AND incobrable     = 0
		 AND abierta        = 0
		 AND cod_ramo       = "002"
		 AND cod_subramo    IN ("001", "002")
	     AND no_documento   MATCHES a_poliza
	     AND estatus_poliza IN (1,3)

	   FOREACH WITH HOLD
		  SELECT cod_agente
		    INTO _cod_agente
		    FROM emipoagt
		   WHERE no_poliza = _no_poliza
		   EXIT FOREACH;
	   END FOREACH
	   
	   IF _cod_agente <> "00035" THEN
		  CONTINUE FOREACH;
	   END IF
	   
	   --Buscar el saldo de la poliza
	   
	   CALL sp_cob85(a_compania, a_agencia,	_no_documento) RETURNING _saldo;

	   IF a_saldo = "2" AND _saldo <> 0 THEN
		  CONTINUE FOREACH;
	   END IF

	   IF a_saldo = "3" AND _saldo = 00.00  THEN
		  CONTINUE FOREACH;
	   END IF

	   LET _prima_porc = _prima * _porc_saldos / 100;
	   	
	   IF _saldo > 0 THEN
		 IF _saldo > _prima_porc THEN
			LET _estatus = "0";
		 ELSE
			LET _estatus = "1";
		 END IF
	   ELSE
		    LET _estatus = "1";
	   END IF

	  -- Insercion / Actualizacion a la tabla temporal tmp_prod

	  INSERT INTO tmp_prod ( sucursal_origen,
		                            cod_ramo,
		                        no_documento, 
		                     cod_contratante, 
		                    vigencia_inicial, 
		                      vigencia_final, 
                                   no_poliza, 
                                       prima, 
                                       saldo, 
                             tipo_produccion, 
                                     estatus, 
                                seleccionado)

	         VALUES ( _sucursal_origen,
	                       	 _cod_ramo,
	                   	 _no_documento,
	                  _cod_contratante,
	                    _vigencia_inic,
	                   _vigencia_final,
		               	    _no_poliza,
		                        _prima, 
		                        _saldo,
		               	 _cod_tipoprod,
		              	 _estatus,  1);
	END FOREACH;

-- Procesos para Filtros

 LET _vfiltros = "";

-- IF a_saldo_cero  = 1 THEN --SOLO SALDO = 0
  --  LET _vfiltros = " Saldo Cero y Cred.;";

  --  UPDATE tmp_prod
  -- 	   SET seleccionado =  0
  --	 WHERE seleccionado =  1
  --	   AND estatus     <> "1";

 --ELIF a_saldo_cero = 0 THEN --CON SALDO
 --   LET _vfiltros  = " Con Saldo;";

 --   UPDATE tmp_prod
 --  	   SET seleccionado =   0
 --	 WHERE seleccionado =   1
 --	   AND estatus      <> "0";
 -- ELSE --TODO
 --   LET _vfiltros = " Todas las polizas;";
 --END IF

--DROP TABLE tmp_prod;

RETURN _vfiltros;

END PROCEDURE;