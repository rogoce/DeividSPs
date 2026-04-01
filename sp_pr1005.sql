--Reporte para ver los registros de las tablas de estados de cuenta.REAESTCT1 Y REAESTCT2

DROP PROCEDURE sp_pr1005;

CREATE PROCEDURE "informix".sp_pr1005(a_compania CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_reaseguradora CHAR(255) DEFAULT "*",a_tipo CHAR(2) DEFAULT "01")
RETURNING CHAR(9),SMALLINT,CHAR(2),CHAR(3),CHAR(50),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),SMALLINT,CHAR(255),CHAR(255),DECIMAL(16,2),DECIMAL(16,2),CHAR(3),CHAR(50);


-- Procedimiento para ver los registros de los Estados de Cuenta de Reaseguro
-- Creado    : 08/11/2012 - Armando Moreno
-- execute procedure sp_pr1005("001","2012-04","2012-06","063;","01")

BEGIN
		DEFINE _ramo_reas         CHAR(3);
		DEFINE v_filtros          CHAR(255);
		DEFINE v_desc_ramo        CHAR(50);
		DEFINE v_descr_cia        CHAR(50);

		DEFINE  t_tipo    			CHAR(10);
		DEFINE  s_cod_coasegur      CHAR(3);
		DEFINE  s_cod_clase,v_clase CHAR(3); 
		DEFINE  s_cod_contrato      CHAR(5);
		DEFINE  _renglon			Smallint;
		DEFINE  m_contrato			CHAR(50);
		DEFINE  m_concepto1			CHAR(255);
		DEFINE  m_concepto2			CHAR(255);

		DEFINE _anio_reas			Char(9);
		DEFINE _trim_reas			Smallint;

		DEFINE  t_reasegurador		CHAR(50);
		DEFINE _saldo_inicial		DECIMAL(16,2);
		DEFINE _saldo_final			DECIMAL(16,2);
		DEFINE _saldo_trim			DECIMAL(16,2);
		define _tipo2		        smallint;
		define s_debito				DECIMAL(16,2);
		define s_credito			DECIMAL(16,2);

SET ISOLATION TO DIRTY READ;

LET v_descr_cia     = sp_sis01(a_compania);

--set debug file to "sp_pr1005.trc";	
--trace on;

select nombre,tipo
  into m_contrato,_tipo2
  from reacontr
 where activo = 1
   and cod_contrato = a_tipo;

CALL sp_rea002(a_periodo2,_tipo2) RETURNING _anio_reas,_trim_reas;

FOREACH

	select reasegurador,
	       saldo_inicial,
		   saldo_final,
		   saldo_trim
	  into s_cod_coasegur,
	       _saldo_inicial,
		   _saldo_final,
		   _saldo_trim
	  from reaestct1 
	 where ano       = _anio_reas  
	   and trimestre = _trim_reas 	
	   and contrato  = a_tipo

	select nombre
	  into t_reasegurador
	  from emicoase
	 where cod_coasegur = s_cod_coasegur;

    foreach

		select renglon,
			   concepto1,
			   concepto2,
			   debe,
			   haber,
			   ramo_reas
		  into _renglon,
		       m_concepto1,
			   m_concepto2,
			   s_debito,
			   s_credito,
			   _ramo_reas
		  from reaestct2 
		 where ano          = _anio_reas  
		   and trimestre    = _trim_reas 	
		   and contrato     = a_tipo
		   and reasegurador = s_cod_coasegur


		 return _anio_reas,
		        _trim_reas,
		        a_tipo,
		        s_cod_coasegur,	
				t_reasegurador,
				_saldo_inicial,
				_saldo_final,
				_saldo_trim,
				_renglon,
				m_concepto1,
				m_concepto2,
				s_debito,
				s_credito,
				_ramo_reas,
				m_contrato 
				with resume;


    end foreach

END FOREACH

-- Procesos v_filtros
{LET v_filtros ="";
IF a_agente <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Reasegurador "||TRIM(a_agente) ;
	LET _tipo = sp_sis04(a_agente); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE reaestcta
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND reasegurador NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE reaestcta
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND reasegurador IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF}

END
END PROCEDURE;	 