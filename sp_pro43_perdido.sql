-- Procedimiento que Actualiza el Endoso

-- Creado    : 20/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 20/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro43;

CREATE PROCEDURE sp_pro43(
a_no_poliza		CHAR(10), 
a_no_endoso		CHAR(5)
) RETURNING SMALLINT,
		    CHAR(100);

DEFINE _mensaje         CHAR(100);
DEFINE _cod_compania	CHAR(3);
DEFINE _cod_sucursal	CHAR(3);
DEFINE _cod_endomov		CHAR(3);
DEFINE _tipo_mov		SMALLINT;
DEFINE _periodo_par     CHAR(7);
DEFINE _periodo_end     CHAR(7);
DEFINE _cod_tipocan     CHAR(3);
DEFINE _vigencia_inic   DATE;
DEFINE _vigencia_final	DATE;

-- Lectura de la Tabla de Endosos

SELECT cod_compania,
	   cod_sucursal,
	   cod_endomov,
	   periodo,
	   vigencia_inic
	   vigencia_final,
	   cod_tipocan	
  INTO _cod_compania,
	   _cod_sucursal,
	   _cod_endomov,
	   _periodo_end,
	   _vigencia_inic,
	   _vigencia_final,	
	   _cod_tipocan	
  FROM endedmae
 WHERE no_poliza   = a_no_poliza
   AND no_endoso   = a_no_endoso
   AND actualizado = 0;

IF _cod_compania IS NULL THEN
	LET _mensaje = 'Este Endoso No Existe, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Seleccion del Periodo Contable

SELECT emi_periodo
  INTO _periodo_par
  FROM parparam
 WHERE cod_compania = _cod_compania;

IF _periodo_end < _periodo_par THEN
	LET _mensaje = 'No Puede Actualizar un Endoso para Un Periodo Cerrado, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Seleccion del Tipo de Movimiento del Endoso

SELECT tipo_mov
  INTO _tipo_mov
  FROM endtimov
 WHERE cod_endomov = _cod_endomov; 	

IF _tipo_mov = 1 THEN		-- Cambio de Vigencia 	

	UPDATE emipomae
	   SET vigencia_final = _vigencia_final
	 WHERE no_poliza      = a_no_poliza;

ELIF _tipo_mov = 2 THEN		-- Cancelacion
	
	BEGIN

		DEFINE _accion SMALLINT;

		SELECT accion
		  INTO _accion
		  FROM endtican
		 WHERE cod_tipocan = _cod_tipocan;

		UPDATE emipomae
		   SET estatus_poliza    = _accion,
			   fecha_cancelacion = CURRENT
		 WHERE no_poliza         = a_no_poliza;
	
	END 

ELIF _tipo_mov = 3 THEN		-- Rehabilitacion

	BEGIN

		DEFINE _vigen_fin_poliza DATE;
		DEFINE _accion           SMALLINT;

		SELECT vigencia_final
		  INTO _vigen_fin_poliza
		  FROM emipomae
		 WHERE no_poliza = a_no_poliza;

		IF _vigen_fin_poliza < CURRENT THEN
			LET _accion = 3;
		ELSE
			LET _accion = 1;
		END IF
	
		UPDATE emipomae
		   SET estatus_poliza    = _accion,
			   fecha_cancelacion = NULL
		 WHERE no_poliza         = a_no_poliza;
	
	END

ELIF _tipo_mov = 4 THEN		-- Inclusion de Unidades

	BEGIN

	    DEFINE _cod_ruta         char(5);
	    DEFINE _cod_producto     char(5);
	    DEFINE _cod_asegurado    char(10);
	    DEFINE _suma_asegurada   dec(16,2);
	    DEFINE _prima            dec(16,2);
	    DEFINE _descuento        dec(16,2);
	    DEFINE _recargo          dec(16,2);
	    DEFINE _prima_neta       dec(16,2);
	    DEFINE _impuesto         dec(16,2);
	    DEFINE _prima_bruta      dec(16,2);
	    DEFINE _reasegurada      smallint;
	    DEFINE _vigencia_inic    date;
	    DEFINE _vigencia_final   date;
	    DEFINE _beneficio_max    dec(16,2);
	    DEFINE _desc_unidad      varchar(50);
	    DEFINE _activo           smallint;
	    DEFINE _prima_asegurado  dec(16,2);
	    DEFINE _prima_total      dec(16,2);
	    DEFINE _no_activo_desde  date;
	    DEFINE _facturado        smallint;
	    DEFINE _user_no_activo   char(8);
	    DEFINE _fecha_emision    date;
	    DEFINE _prima_suscrita   dec(16,2);
	    DEFINE _prima_retenida   dec(16,2);

		FOREACH
		 SELECT	cod_ruta       
				cod_producto   
				cod_cliente  
				suma_asegurada 
				prima          
				descuento      
				recargo        
				prima_neta     
				impuesto       
				prima_bruta    
				reasegurada    
				vigencia_inic  
				vigencia_final 
				beneficio_max  
				desc_unidad    
				prima_suscrita 
				prima_retenida 
		   INTO	_cod_ruta       
				_cod_producto   
				_cod_cliente  
				_suma_asegurada 
				_prima          
				_descuento      
				_recargo        
				_prima_neta     
				_impuesto       
				_prima_bruta    
				_reasegurada    
				_vigencia_inic  
				_vigencia_final 
				_beneficio_max  
				_desc_unidad    
				_prima_suscrita 
				_prima_retenida
		   FROM	endeduni
		  WHERE	no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso
			
			INSERT INTO emipouni(
		    no_poliza,
		    no_unidad,
		    cod_ruta,
		    cod_producto,
		    cod_asegurado,
		    suma_asegurada,
		    prima,
		    descuento,
		    recargo,
		    prima_neta,
		    impuesto,
		    prima_bruta,
		    reasegurada,
		    vigencia_inic,
		    vigencia_final,
		    beneficio_max,
		    desc_unidad,
		    activo,
		    prima_asegurado,
		    prima_total,
		    no_activo_desde,
		    facturado,
		    user_no_activo,
		    perd_total,
		    impreso,
		    fecha_emision,
		    prima_suscrita,
		    prima_retenidal
			)
			VALUES(
		    a_no_poliza,
		    a_no_unidad,
		    _cod_ruta,
		    _cod_producto,
		    _cod_asegurado,
		    _suma_asegurada,
		    _prima,
		    _descuento,
		    _recargo,
		    _prima_neta,
		    _impuesto,
		    _prima_bruta,
		    _reasegurada,
		    _vigencia_inic,
		    _vigencia_final,
		    _beneficio_max,
		    _desc_unidad,
		    1,
		    0,
		    0,
		    NULL,
		    1,
		    NULL,
		    0,
		    1,
		    CURRENT,
		    _prima_suscrita,
		    _prima_retenida
			);

			-- Insercion de Acreedores

			INSERT INTO emipoacr(
			no_poliza,
			no_unidad, 
			cod_acreedor,
			limite
			)
			VALUES(SELECT no_poliza,
						  no_unidad,
						  cod_acreedor,
						  limite
				 	 FROM endedacr
				 	WHERE no_poliza = a_no_poliza
				 	  AND no_endoso = a_no_endoso
				 	  AND no_unidad = _no_unidad)
				 	   	
			
		END FOREACH

	END 

ELIF _tipo_mov = 5 THEN		-- Eliminacion de Unidades

	BEGIN
	END 

ELIF _tipo_mov = 6 THEN		-- Modicicacion de Unidades

	BEGIN
	END 

ELIF _tipo_mov = 10 THEN	-- Modificacion de Acreedores

	BEGIN

		DEFINE _no_unidad    CHAR(5);
		DEFINE _cod_acreedor CHAR(5);
		DEFINE _limite       DEC(16,2);

		FOREACH
		 SELECT	no_unidad
		   INTO	_no_unidad
		   FROM	endeduni
		  WHERE	no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso

			DELETE FROM emipoacr
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad;

			FOREACH 
			 SELECT	cod_acreedor,
					limite
			   INTO	_cod_acreedor,
					_limite
			   FROM	endedacr
			  WHERE no_poliza = a_no_poliza
			    AND no_endoso = a_no_endoso
				AND no_unidad = _no_unidad

				INSERT INTO emipoacr(
				no_poliza, 
				no_unidad,
				cod_acreedor,
				limite
				)
				VALUES(
				a_no_poliza,
				_no_unidad,
				_cod_acreedor,
				_limite
				);

			END FOREACH

		END FOREACH

	END 	

ELIF _tipo_mov = 12 THEN		-- Modificacion de Corredores

	BEGIN

		DEFINE _cod_agente   CHAR(5);
		DEFINE _porc_partic  DEC(5,2);
		DEFINE _porc_comis   DEC(5,2);
		DEFINE _porc_produc  DEC(5,2);

		DELETE FROM emipoagt
		 WHERE no_poliza = a_no_poliza;

		FOREACH
		 SELECT	cod_agente, 
				porc_partic_agt,
				porc_comis_agt, 
				porc_produc
		   INTO	_cod_agente, 
				_porc_partic,
				_porc_comis, 
				_porc_produc
		   FROM	endmoage
		  WHERE	no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso

				INSERT INTO emipoagt(
				no_poliza,
				cod_agente, 
				porc_partic_agt,
				porc_comis_agt, 
				porc_produc
				)
				VALUES(
				a_no_poliza,
				_cod_agente, 
				_porc_partic,
				_porc_comis, 
				_porc_produc
				);

		END FOREACH

	END 

ELIF _tipo_mov = 13 THEN		-- Modificacion de Asegurado

	BEGIN

		DEFINE _cod_cliente CHAR(10);

		SELECT cod_cliente
		  INTO _cod_cliente
		  FROM endmoase
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso;

		UPDATE emipomae
		   SET cod_contratante = _cod_cliente
		 WHERE no_poliza       = a_no_poliza;

	END 

ELIF _tipo_mov = 15 THEN		-- Cambio de Coaseguro

	BEGIN

		DEFINE _cod_coasegur     CHAR(3);
		DEFINE _porc_partic_coas DEC(7,4);
		DEFINE _porc_gastos      DEC(5,2);
		DEFINE _no_cambio_int	 SMALLINT;
		DEFINE _no_cambio_char   CHAR(3);

		SELECT COUNT(*)
		  INTO _no_cambio_int
		  FROM emihcmm
		 WHERE no_poliza = a_no_poliza;

		LET _no_cambio_char = '000';

		IF _no_cambio_int > 99 THEN
			LET _no_cambio_char[1,3] = _no_cambio_int;
		ELIF _no_cambio_int > 9 THEN
			LET _no_cambio_char[2,3] = _no_cambio_int;
		ELSE
			LET _no_cambio_char[3,3] = _no_cambio_int;
		END IF

		DELETE FROM emicoama
		 WHERE no_poliza = a_no_poliza;

		INSERT INTO emihcmm(
		no_poliza,
		no_cambio,
		vigencia_inic,
		vigencia_final,
		fecha_mov,
		no_endoso
		)
		VALUES(
		a_no_poliza,
		_no_cambio_char,
		_vigencia_inic,
		_vigencia_final,
		CURRENT,
		a_no_endoso
		);


		FOREACH
		 SELECT cod_coasegur,    
				porc_partic_coas,
				porc_gastos     
		   INTO _cod_coasegur,    
				_porc_partic_coas,
				_porc_gastos     
		   FROM	endcamco
		  WHERE no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso

			INSERT INTO emicoama(
			no_poliza,
			cod_coasegur,    
			porc_partic_coas,
			porc_gastos     
			)
			VALUES(
			a_no_poliza,
			_cod_coasegur,    
			_porc_partic_coas,
			_porc_gastos     
			);

			INSERT INTO emihcmd(
			no_poliza,
			no_cambio,
			cod_coasegur,    
			porc_partic_coas,
			porc_gastos     
			)
			VALUES(
			a_no_poliza,
			_no_cambio_char,
			_cod_coasegur,    
			_porc_partic_coas,
			_porc_gastos     
			);

		END FOREACH

	END 

END IF


BEGIN
	
	DEFINE _no_factura CHAR(10);

	-- Determina el Numero de Factura

	LET _no_factura = sp_sis14(_cod_compania, _cod_sucursal, a_no_poliza);

	-- Actualizacion de los Valores del Endoso

	UPDATE endedmae
	   SET actualizado 		= 1,
	       posteado   		= '1',
		   fecha_emision	= CURRENT,
		   date_changed		= CURRENT,
		   no_factura		= _no_factura
	 WHERE no_poliza		= a_no_poliza
	   AND no_endoso		= a_no_endoso;

END 

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;

END PROCEDURE;
