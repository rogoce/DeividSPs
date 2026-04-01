-- Reporte de secuenacia de Recibos por remesa
-- 
-- Creado: 06/10/2015 Federico Coronado
-- SIS v.2.0 - d_sac_sp_cob18c - DEIVID, S.A.

DROP PROCEDURE sp_cob18c;

CREATE PROCEDURE "informix".sp_cob18c(a_compania CHAR(3), a_fecha date, a_fecha2 date)
RETURNING   CHAR(10),		-- Recibo
			varchar(50),    --nombre
			varchar(100),    --descripcion
			varchar(20),	--sucursal
			DATE,			-- Fecha
		    CHAR(1),		-- Tipo Remesa
		  	DEC(16,2),  	-- Monto Banco
			date,       	--a_fecha
			date,       	--a_fecha2
			varchar(100);   -- Compañia
DEFINE v_renglon		 SMALLINT;	
DEFINE v_no_recibo		 CHAR(10);
DEFINE v_tipo_mov        CHAR(1);
DEFINE v_doc_remesa      CHAR(30);
DEFINE v_desc_remesa     CHAR(100);
DEFINE v_monto_banco     DEC(16,2);
DEFINE v_prima           DEC(16,2);
DEFINE v_impuesto        DEC(16,2);
DEFINE v_descontada      DEC(16,2);
DEFINE v_fecha           DATE;
DEFINE v_periodo		 CHAR(7);
DEFINE v_nombre_banco    CHAR(50);
DEFINE v_tipo_remesa     CHAR(1);
DEFINE v_actualizado     SMALLINT;
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_remesa          CHAR(10);
DEFINE v_cod_sucursal    char(3);
DEFINE v_nombre_sucursal varchar(20);
DEFINE v_nombre          varchar(50);
DEFINE v_no_poliza       varchar(10);
DEFINE v_cod_asegurado   varchar(10);

DEFINE _cod_banco        CHAR(3);
DEFINE _monto            DEC(16,2);

SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Lectura de la Tabla de Remesas

FOREACH

		SELECT fecha,
			   periodo,
			   cod_banco,
			   tipo_remesa,
			   actualizado,
			   no_remesa,
			   recibi_de
		  INTO v_fecha,
			   v_periodo,
			   _cod_banco,
			   v_tipo_remesa,
			   v_actualizado,
			   v_remesa,
			   v_nombre
		  FROM cobremae
		 WHERE fecha >= a_fecha
		   AND fecha <= a_fecha2
		   AND tipo_remesa in('A','M')  --Recibo Manual , 'A' Recibo Automatico
		   AND actualizado = 1
	     order by tipo_remesa,fecha	   	

		SELECT nombre
		  INTO v_nombre_banco
		  FROM chqbanco
		 WHERE cod_banco = _cod_banco;
		 
		IF v_nombre_banco IS NULL THEN
			LET v_nombre_banco = '... Banco No Definido ...';
		END IF

		-- Recibos por Remesa

		FOREACH 
		 SELECT renglon,
				no_recibo,
				tipo_mov,
				doc_remesa,
				desc_remesa,
				monto,
				prima_neta,
				impuesto,
				monto_descontado,  
				no_poliza,
                cod_sucursal
		   INTO	v_renglon,
				v_no_recibo,
				v_tipo_mov,
				v_doc_remesa,
				v_desc_remesa,
				v_monto_banco,
				v_prima,
				v_impuesto,
				v_descontada,
				v_no_poliza,
				v_cod_sucursal
		   FROM cobredet
		  WHERE no_remesa = v_remesa
			AND renglon   <> 0
			AND tipo_mov  = 'P'
		  ORDER BY no_recibo, renglon
		  
		 select descripcion
		   into v_nombre_sucursal
		   from insagen
		  where codigo_agencia 		= v_cod_sucursal
			and codigo_compania 	= a_compania;
			
		/* select nombre
		   into v_nombre
		   from emipomae inner join cliclien on cod_cliente = cod_contratante
		  where no_poliza = v_no_poliza;*/

			-- Obtiene el Monto del Banco

			IF v_tipo_mov   = 'M' AND
			   v_descontada <> 0  THEN
				LET _monto = 0;
			ELSE
				LET _monto = v_monto_banco;
			END IF

			LET v_monto_banco = _monto - v_descontada;
					
			RETURN v_no_recibo,	
				   v_nombre,
				   v_desc_remesa,
				   v_nombre_sucursal,	
				   v_fecha,	
				   v_tipo_remesa,				   
				   v_monto_banco,              
				   a_fecha,
				   a_fecha2,			   
				   v_compania_nombre				   
				   WITH RESUME;	 		

		END FOREACH

	END FOREACH

END PROCEDURE;

