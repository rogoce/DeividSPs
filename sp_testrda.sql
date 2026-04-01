-- Procedimiento que Carga las Sobre Comisiones por Corredor
-- Creado    : 07/Junio /2007 - Autor: Rub‚n Dar¡o Arn ez 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_testrda;

CREATE PROCEDURE sp_testrda(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo char(7))

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10); 
DEFINE _no_remesa       CHAR(10); 
DEFINE _renglon         SMALLINT; 
DEFINE _monto           DEC(16,2);
DEFINE _gen_cheque      SMALLINT; 
DEFINE _no_recibo       CHAR(10); 
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2); 
DEFINE _comision        DEC(16,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _monto_vida      DEC(16,2);
DEFINE _monto_danos     DEC(16,2);
DEFINE _monto_fianza    DEC(16,2);
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _fecha_ult_comis DATE;     
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _agente_agrupado CHAR(5);
DEFINE _cod_producto	CHAR(5);
DEFINE _no_licencia2    CHAR(10); 
DEFINE _nombre2         CHAR(50);
DEFINE _nombre_clte     CHAR(100); 
DEFINE _cod_cliente     CHAR(10);
DEFINE _tipo           	CHAR(1);
DEFINE a_fecha_desde 	DATE;
DEFINE a_fecha_hasta 	DATE;
DEFINE _nombre_agente    CHAR(50);
	
SET ISOLATION TO DIRTY READ;

let a_fecha_desde = MDY(a_periodo[6,7], 1, a_periodo[1,4]);
let a_fecha_hasta = sp_sis36(a_periodo);


CREATE TEMP TABLE   tmp_testrda(
	cod_agente		CHAR(15),            
	no_poliza		CHAR(10),	         
	no_recibo		CHAR(10),	         
	fecha			DATE,		         
	monto           DEC(16,2),	         
	prima           DEC(16,2),	         
	porc_partic		DEC(5,2),	         
	porc_comis		DEC(5,2),	         
	comision		DEC(16,2),	         
	nombre			CHAR(50),	        
	no_documento    CHAR(20),	        
	monto_vida      DEC(16,2),	        
	monto_danos     DEC(16,2),	        
	monto_fianza    DEC(16,2),	        
	no_licencia     CHAR(10),	        
	nombre_clte    	CHAR(100),			
	seleccionado    SMALLINT DEFAULT 1,	
	agente_agrupado CHAR(5),
	nombre_agente   CHAR(50),	

	PRIMARY KEY		(cod_agente, no_poliza, no_recibo, fecha)
	) WITH NO LOG;

-- Pagos de Prima y Notas Credito

FOREACH
 SELECT	d.no_poliza,
		d.no_remesa,
		d.renglon,
		d.no_recibo,
		d.fecha,
		d.monto,
		d.prima_neta,
		d.tipo_mov
   INTO	_no_poliza,
		_no_remesa,
		_renglon,
		_no_recibo,
		_fecha,
		_monto,
		_prima,
		_tipo_mov
   FROM	cobredet d, cobremae m
  WHERE	d.cod_compania     = a_compania
    AND d.actualizado      = 1
	AND d.tipo_mov        IN ('P','N')
	AND d.fecha           >= a_fecha_desde
	AND d.fecha           <= a_fecha_hasta
	AND d.no_remesa        = m.no_remesa
	AND m.tipo_remesa      IN ('A', 'M', 'C')

	SELECT no_documento,
		   cod_tipoprod,
		   cod_ramo,
		   incobrable	
	  INTO _no_documento,
		   _cod_tipoprod,
		   _cod_ramo,	
		   _incobrable	
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	IF _incobrable = 1 THEN
	   CONTINUE FOREACH;
	END IF

	SELECT tipo_produccion
	  INTO _tipo_prod
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido

	IF _tipo_prod = 3 OR
	   _tipo_prod = 4 THEN
	   CONTINUE FOREACH;
	END IF
	
	SELECT cod_tiporamo
	  INTO _cod_tiporamo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo; 	

	SELECT tipo_ramo
	  INTO _tipo_ramo
	  FROM prdtiram
	 WHERE cod_tiporamo = _cod_tiporamo;

	FOREACH
	 SELECT	cod_agente,
			porc_partic_agt,
			porc_comis_agt
	   INTO	_cod_agente,
			_porc_partic,
			_porc_comis
	   FROM	cobreagt
	  WHERE	no_remesa = _no_remesa
	    AND renglon   = _renglon

		SELECT generar_cheque,
			   nombre,
			   no_licencia,
			   fecha_ult_comis,
			   tipo_pago,
			   tipo_agente,
			   agente_agrupado
		  INTO _gen_cheque,
		       _nombre_agente,
			   _no_licencia,
			   _fecha_ult_comis,
			   _tipo_pago,
			   _tipo_agente,
			   _agente_agrupado
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		foreach
		 SELECT cod_producto
		   INTO _cod_producto
		   FROM emipouni
		  WHERE no_poliza = _no_poliza
			exit foreach;	
		end foreach

		SELECT sobrecomision
		  INTO _sobrecomision
		  FROM agtsocom
		 WHERE cod_agente   = _agente_agrupado
		   AND cod_producto = _cod_producto;

		if _sobrecomision is not null then

		    SELECT cod_contratante
		  INTO _cod_cliente
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

			SELECT nombre
		  INTO _nombre_clte
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

			SELECT no_licencia,
			       nombre
			  INTO _no_licencia2,
			       _nombre2
			  FROM agtagent
			 WHERE cod_agente = _agente_agrupado;

			LET _comision     = _prima * (_sobrecomision / 100);

			BEGIN

				ON EXCEPTION IN(-239)

					UPDATE tmp_sobrecom
					   SET monto        = monto        + _monto,
					       prima        = prima        + _prima,
						   comision     = comision     + _comision
					 WHERE cod_agente   = _agente_agrupado
					   AND no_poliza    = _no_poliza

					   AND no_recibo    = _no_recibo
					   AND fecha        = _fecha;

				END EXCEPTION

				INSERT INTO tmp_testrda(
				cod_agente,
				no_poliza,
				no_recibo,
				fecha,
				monto,
				prima,
				porc_partic,
				porc_comis,
				comision,
				nombre,
				no_documento,
				no_licencia,
				nombre_clte,
				agente_agrupado,
				nombre_agente
				)
				VALUES(
				_cod_agente,
				_no_poliza,
				_no_recibo,
		      	_fecha,
				_monto,
				_prima,
				100.00,
				_sobrecomision,
				_comision,
				_nombre2,
				_no_documento,
				_no_licencia2,
				_nombre_clte,
				_agente_agrupado,
				_nombre_agente
	   			);
				
			END
			
		end if
  
	END FOREACH
	
END FOREACH

-- Cheques de Devolucion de Primas -- Todos

{
FOREACH 
 SELECT no_requis,
        no_cheque,
		fecha_impresion
   INTO _no_requis,
		_no_recibo,
		_fecha
   FROM chqchmae
  WHERE fecha_impresion >= a_fecha_desde
	AND fecha_impresion <= a_fecha_hasta
	AND pagado           = 1
	AND origen_cheque    = 6

	FOREACH
	 SELECT no_poliza,
	        no_documento,
			prima_neta,
			monto
	   INTO _no_poliza,
	        _no_documento,
			_prima,
			_monto
	   FROM chqchpol
	  WHERE no_requis = _no_requis

		SELECT cod_tipoprod,
			   cod_ramo,
			   incobrable		
		  INTO _cod_tipoprod,
		  	   _cod_ramo,	
			   _incobrable		
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		IF _incobrable = 1 THEN
		   CONTINUE FOREACH;
		END IF

		SELECT tipo_produccion
		  INTO _tipo_prod
		  FROM emitipro
		 WHERE cod_tipoprod = _cod_tipoprod;

		-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido

		IF _tipo_prod = 3 OR
		   _tipo_prod = 4 THEN
		   CONTINUE FOREACH;
		END IF

		SELECT cod_tiporamo
		  INTO _cod_tiporamo
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo; 	

		SELECT tipo_ramo
		  INTO _tipo_ramo
		  FROM prdtiram
		 WHERE cod_tiporamo = _cod_tiporamo;

		FOREACH
		 SELECT cod_agente,
				porc_partic_agt,
				porc_comis_agt
		   INTO	_cod_agente,
				_porc_partic,
				_porc_comis
		   FROM	chqchpoa
		  WHERE no_requis    = _no_requis
		    AND no_documento = _no_documento
			
			LET _monto    = _monto * -1;
			LET _prima    = _prima * -1; 
			LET _comision = _prima * (_porc_partic / 100) * (_porc_comis / 100);
			
			LET _monto_vida   = 0;
			LET _monto_danos  = 0;
			LET _monto_fianza = 0;

			IF   _tipo_ramo = 1 THEN
				LET _monto_vida   = _comision;
			ELIF _tipo_ramo = 2 THEN	
				LET _monto_danos  = _comision;
			ELSE
				LET _monto_fianza = _comision;
			END IF

			SELECT generar_cheque,
				   nombre,
				   no_licencia,
				   fecha_ult_comis	
			  INTO _gen_cheque,
			       _nombre,
				   _no_licencia,
				   _fecha_ult_comis	
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;

			IF a_verif_fecha_comis = 1 THEN
				IF _fecha_ult_comis IS NOT NULL THEN
					IF _fecha_ult_comis >= _fecha THEN
						CONTINUE FOREACH;
					END IF
				END IF
			END IF

			BEGIN

				ON EXCEPTION IN(-239)

					UPDATE tmp_sobrecom
					   SET monto        = monto        + _monto,
					       prima        = prima        + _prima,
						   comision     = comision     + _comision,
						   monto_vida   = monto_vida   + _monto_vida,
						   monto_danos  = monto_danos  + _monto_danos,
						   monto_fianza = monto_fianza + _monto_fianza
					 WHERE cod_agente   = _cod_agente
					   AND no_poliza    = _no_poliza
					   AND no_recibo    = _no_recibo
					   AND fecha        = _fecha;

				END EXCEPTION

				INSERT INTO tmp_sobrecom(
				cod_agente,
				no_poliza,
				no_recibo,
				fecha,
				monto,
				prima,
				porc_partic,
				porc_comis,
				comision,
				nombre,
				no_documento,
				monto_vida,
				monto_danos,
				monto_fianza,
				no_licencia
				)
				VALUES(
				_cod_agente,
				_no_poliza,
				_no_recibo,
				_fecha,
				_monto,
				_prima,
				_porc_partic,
				_porc_comis,
				_comision,
				_nombre,
				_no_documento,
				_monto_vida,
				_monto_danos,
				_monto_fianza,
				_no_licencia
				);

			END

		END FOREACH

	END FOREACH

END FOREACH
}
{
-- Cheques de Devolucion de Primas -- Anulados

FOREACH 
 SELECT no_requis,
        no_cheque,
		fecha_anulado
   INTO _no_requis,
		_no_recibo,
		_fecha
   FROM chqchmae
  WHERE fecha_anulado   >= a_fecha_desde
	AND fecha_anulado   <= a_fecha_hasta
	AND pagado           = 1
	AND origen_cheque    = 6
	AND anulado          = 1

	FOREACH
	 SELECT no_poliza,
	        no_documento,
			prima_neta,
			monto
	   INTO _no_poliza,
	        _no_documento,
			_prima,
			_monto
	   FROM chqchpol
	  WHERE no_requis = _no_requis

		SELECT cod_tipoprod,
			   cod_ramo,
			   incobrable		
		  INTO _cod_tipoprod,
		  	   _cod_ramo,	
			   _incobrable		
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		IF _incobrable = 1 THEN
		   CONTINUE FOREACH;
		END IF

		SELECT tipo_produccion
		  INTO _tipo_prod
		  FROM emitipro
		 WHERE cod_tipoprod = _cod_tipoprod;

		-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido

		IF _tipo_prod = 3 OR
		   _tipo_prod = 4 THEN
		   CONTINUE FOREACH;
		END IF

		SELECT cod_tiporamo
		  INTO _cod_tiporamo
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo; 	

		SELECT tipo_ramo
		  INTO _tipo_ramo
		  FROM prdtiram
		 WHERE cod_tiporamo = _cod_tiporamo;

		FOREACH
		 SELECT cod_agente,
				porc_partic_agt,
				porc_comis_agt
		   INTO	_cod_agente,
				_porc_partic,
				_porc_comis
		   FROM	chqchpoa
		  WHERE no_requis    = _no_requis
		    AND no_documento = _no_documento
			
			LET _monto    = _monto;
			LET _prima    = _prima; 
			LET _comision = _prima * (_porc_partic / 100) * (_porc_comis / 100);
			
			LET _monto_vida   = 0;
			LET _monto_danos  = 0;
			LET _monto_fianza = 0;

			IF   _tipo_ramo = 1 THEN
				LET _monto_vida   = _comision;
			ELIF _tipo_ramo = 2 THEN	
				LET _monto_danos  = _comision;
			ELSE
				LET _monto_fianza = _comision;
			END IF

			SELECT generar_cheque,
				   nombre,
				   no_licencia,
				   fecha_ult_comis,
				   tipo_agente	
			  INTO _gen_cheque,
			       _nombre,
				   _no_licencia,
				   _fecha_ult_comis,
				   _tipo_agente	
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;

			IF a_verif_fecha_comis = 1 THEN
				IF _fecha_ult_comis IS NOT NULL THEN
					IF _fecha_ult_comis >= _fecha THEN
						CONTINUE FOREACH;
					END IF
				END IF
			END IF

			BEGIN

				ON EXCEPTION IN(-239)

					UPDATE tmp_sobrecom
					   SET monto        = monto        + _monto,
					       prima        = prima        + _prima,
						   comision     = comision     + _comision,
						   monto_vida   = monto_vida   + _monto_vida,
						   monto_danos  = monto_danos  + _monto_danos,
						   monto_fianza = monto_fianza + _monto_fianza
					 WHERE cod_agente   = _cod_agente
					   AND no_poliza    = _no_poliza
					   AND no_recibo    = _no_recibo
					   AND fecha        = _fecha;

				END EXCEPTION

				INSERT INTO tmp_sobrecom(
				cod_agente,
				no_poliza,
				no_recibo,
				fecha,
				monto,
				prima,
				porc_partic,
				porc_comis,
				comision,
				nombre,
				no_documento,
				monto_vida,
				monto_danos,
				monto_fianza,
				no_licencia
				)
				VALUES(
				_cod_agente,
				_no_poliza,
				_no_recibo,
				_fecha,
				_monto,
				_prima,
				_porc_partic,
				_porc_comis,
				_comision,
				_nombre,
				_no_documento,
				_monto_vidae,
				_monto_danos,
				_monto_fianza,
				_no_licencia
				);

			END

		END FOREACH

	END FOREACH

END FOREACH
}

END PROCEDURE;