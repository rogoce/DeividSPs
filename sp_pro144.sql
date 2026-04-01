-- Procedimiento que evalua las polizas canceladas y con saldo cero.
-- 
-- Creado    : 04/05/2004 - Autor: Armando Moreno M.
-- Modificado: 04/05/2004 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro144;

CREATE PROCEDURE "informix".sp_pro144(a_compania CHAR(3),a_agencia  CHAR(3),a_fecha    DATE)
RETURNING CHAR(50),
		  CHAR(3),
		  CHAR(50),
		  CHAR(100),
		  CHAR(20),
          DATE,
          DATE,
          DATE,
          INTEGER,
          SMALLINT;

DEFINE _mes_contable   			CHAR(2);
DEFINE _ano_contable   			CHAR(4);
DEFINE _periodo        			CHAR(7);
DEFINE _cod_ramo       			CHAR(3);
DEFINE _no_documento   			CHAR(20);
define _vigencia_inic  			date;
define _vigencia_final 			date;
define v_desc_ramo,v_descr_cia  CHAR(50);
define v_desc_cliente  			CHAR(100);
define _estatus_poliza 			integer;
DEFINE _saldo             		DEC(16,2);
DEFINE _por_vencer        		DEC(16,2);
DEFINE _exigible          		DEC(16,2);
DEFINE _corriente         		DEC(16,2);
DEFINE _monto_30          		DEC(16,2);
DEFINE _monto_60          		DEC(16,2);
DEFINE _monto_90          		DEC(16,2);
DEFINE _no_poliza         		CHAR(10);
DEFINE _cod_contratante    		CHAR(10);
DEFINE _fecha_cancelacion		date;
DEFINE _ano						integer;
define _serie					smallint;

SET ISOLATION TO DIRTY READ;
 
-- Periodo de Seleccion
-- Se Filtran los Registros por Fecha y Periodo Contable

LET _ano_contable = YEAR(a_fecha);

IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;

LET v_descr_cia = sp_sis01(a_compania);
BEGIN 

-- Seleccion de la Polizas

FOREACH 
 SELECT no_documento
   INTO	_no_documento
   FROM emipomae 
  WHERE cod_compania  = a_compania		   -- Seleccion por Compania
    AND actualizado   = 1			   	   -- Poliza este actualizada
    AND cod_ramo not in("018","019","016")
--	and cod_ramo in("011","004")
  GROUP BY no_documento

	let _no_poliza = sp_sis21(_no_documento);

	SELECT cod_ramo,
		   cod_contratante,
		   vigencia_inic,
		   vigencia_final,
		   estatus_poliza,
		   fecha_cancelacion,
		   serie
	  INTO _cod_ramo,
		   _cod_contratante,
		   _vigencia_inic,
		   _vigencia_final,
		   _estatus_poliza,
		   _fecha_cancelacion,
		   _serie
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	if _estatus_poliza = 2 then	--vigencia cancelada
		-- Procedimiento que genera la morosidad para una poliza
		CALL sp_cob33(
			 a_compania,
			 a_agencia,
			 _no_documento,
			 _periodo,
			 a_fecha
			 ) RETURNING _por_vencer,       
	    				 _exigible,         
	    				 _corriente,        
	    				 _monto_30,         
	    				 _monto_60,         
	    				 _monto_90,
						 _saldo;          

	   IF _saldo = 0 THEN
		  let _ano = year(_vigencia_final);
		   	
		   --Asegurado
	       SELECT nombre
	         INTO v_desc_cliente
	         FROM cliclien
	        WHERE cod_cliente = _cod_contratante;

			let v_desc_cliente = trim(v_desc_cliente);

		   --Ramo
	       SELECT nombre
	         INTO v_desc_ramo
	         FROM prdramo
	        WHERE cod_ramo = _cod_ramo;

			let v_desc_ramo = trim(v_desc_ramo);

		   RETURN v_descr_cia,
	       		  _cod_ramo,
	       		  v_desc_ramo,
	              v_desc_cliente,
	              _no_documento,
	              _vigencia_inic,
	              _vigencia_final,
				  _fecha_cancelacion,
				  _ano,
				  _serie
	              WITH RESUME;
	   END IF
	else
		continue foreach;
	end if

END FOREACH
END
END PROCEDURE;
