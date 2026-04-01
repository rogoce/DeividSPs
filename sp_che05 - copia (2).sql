-- Procedimiento que Genera el Proceso Intermedio de Seleccion
-- de a cuales corredores se generaran los cheques  

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/04/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 14/10/2005 - Autor: Amado Perez Mendoza
-- Modificado: 23/05/2007 - Autor: Amado Perez Mendoza
--                                 Se busca los saldo arrastre de agtsalra y se insertan en tmp_ramo
-- Modificado: 25/02/2008 - Autor: Amado Perez Mendoza
--								   Se modofico para pagos semanales
-- Modificado: 21/08/2018 - Autor: Amado Perez Mendoza 
--								   Se modifico la manera de leer los arrastres, se guardo copia "sp_che05 - copia.sql"
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che05;

CREATE PROCEDURE sp_che05(
a_compania 		 CHAR(3), 
a_sucursal 		 CHAR(3),
a_fecha_desde    DATE,
a_fecha_hasta    DATE
) RETURNING SMALLINT,	-- Generar Cheque
			CHAR(50),   -- Agente
			DEC(16,2),	-- Comision Total
			DEC(16,2),	-- Comision	Periodo
			DEC(16,2),	-- Comision	Arrastre
			CHAR(5),	-- Codigo Corredor
			SMALLINT,   -- Tipo de pago
			CHAR(17),	-- Codigo de cuenta
			DEC(16,2);  -- Deuda 
			
DEFINE v_generar_chq    	SMALLINT; 
DEFINE v_nombre_agt     	CHAR(50); 
DEFINE v_comision       	DEC(16,2);
DEFINE v_comis_periodo  	DEC(16,2);
DEFINE v_comis_arrastre 	DEC(16,2);
DEFINE v_cod_cuenta     	CHAR(17);
DEFINE v_alias     			CHAR(50);
DEFINE v_deuda_tot			DEC(16,2);

DEFINE _cod_agente      	CHAR(5);  
DEFINE _cod_ramo        	CHAR(3);
DEFINE _no_poliza       	CHAR(10);
define _no_recibo			char(10); 
DEFINE _monto_minimo    	DEC(16,2);
define _comision_adelanto	dec(16,2);
DEFINE _tipo_pago       	SMALLINT; 
DEFINE _quincena     		SMALLINT;
DEFINE _deuda				DEC(16,2);
DEFINE _cant_reg        	INTEGER;

DEFINE _comis_desc			DEC(16,2);
DEFINE _saldo           	DEC(16,2);

DEFINE _tipo				smallint;
DEFINE _no_documento		char(30);
DEFINE _estatus_licencia    CHAR(1);
DEFINE _fecha_ult_comis_orig DATE;
DEFINE _no_requis_c         CHAR(10);

SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "sp_che05.trc";
--TRACE ON;

--DROP TABLE tmp_ramo;

CREATE TEMP TABLE tmp_ramo(
	cod_agente		CHAR(5),
	cod_ramo		CHAR(3),
	comision		DEC(16,2),
	PRIMARY KEY (cod_agente, cod_ramo)
	) WITH NO LOG;

CREATE TEMP TABLE tmp_arrastre(
	cod_agente		CHAR(5),
	cod_ramo		CHAR(3),
	comision		DEC(16,2),
	PRIMARY KEY (cod_agente, cod_ramo)
	) WITH NO LOG;

SELECT chq_monto_min
  INTO _monto_minimo
  FROM parparam
 WHERE cod_compania = a_compania;

IF _monto_minimo IS NULL THEN
	LET _monto_minimo = 0;
END IF

IF DAY(a_fecha_hasta) < 16 THEN	--Se tomara la fecha_hasta para determinar de que quincena y no la fecha_desde
   LET _quincena = 1;
ELSE	
   LET _quincena = 2;
END IF

-- Genera los registros de las comisiones

CALL sp_che02(
a_compania, 
a_sucursal,
a_fecha_desde,
a_fecha_hasta,
1
);

-- Genera el archivo para las comisiones de Ducruet

execute procedure sp_che28(a_fecha_desde, a_fecha_hasta);

-- Genera el archivo para las comisiones de Semusa

execute procedure sp_che91(a_fecha_desde, a_fecha_hasta);

-- Genera el archivo para las comisiones de Semusa

--execute procedure sp_che139(a_fecha_desde, a_fecha_hasta);

-- Genera archivo para envio de correos en ach

execute procedure sp_che35(a_fecha_desde, a_fecha_hasta);	   --> quitar comentario

-- Genera el intermedio de los cheques

--SET DEBUG FILE TO "sp_che05.trc";
--TRACE ON;


LET _comis_desc = 0;

FOREACH
 SELECT	cod_agente,
 		no_poliza,
		comision,
		no_recibo,
		no_documento
   INTO	_cod_agente,
   		_no_poliza,
		v_comision,
		_no_recibo,
		_no_documento
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

--Buscando los arrastres del corredor y agregarlos en tmp_ramo -- Amado 21-08-2019
FOREACH
    SELECT cod_agente
	  INTO _cod_agente
	  FROM tmp_agente
	GROUP BY cod_agente
	
	SELECT fecha_ult_comis
	  INTO _fecha_ult_comis_orig
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	IF _fecha_ult_comis_orig IS NOT NULL THEN
		LET _fecha_ult_comis_orig = _fecha_ult_comis_orig +	1 UNITS DAY;
	ELSE
		LET _fecha_ult_comis_orig = a_fecha_desde;
	END IF
    LET _no_requis_c = NULL;
	
	-- Buscando las requisiciones anuladas dentro del periodo de pago de comision
	FOREACH
		 select no_requis
		   into _no_requis_c
		   from chqchmae
		  where cod_agente = _cod_agente
		    and origen_cheque in (2, 7)
			and anulado = 1
			and no_requis is not null
			and fecha_anulado <= a_fecha_hasta
			and fecha_anulado >= _fecha_ult_comis_orig

		 If _no_requis_c is not null And Trim(_no_requis_c) <> "" Then
			FOREACH
				SELECT no_poliza,
					   comision
				  INTO _no_poliza,
					   v_comis_arrastre
				  FROM chqcomis
				 WHERE no_requis = _no_requis_c
				   AND no_poliza <> '00000'
			   
				SELECT cod_ramo
				  INTO _cod_ramo
				  FROM emipomae
				 WHERE no_poliza = _no_poliza;

				BEGIN

					ON EXCEPTION IN(-239)

						UPDATE tmp_arrastre
						   SET comision   = comision + v_comis_arrastre
						 WHERE cod_agente = _cod_agente
						   AND cod_ramo   = _cod_ramo;

					END EXCEPTION

					INSERT INTO tmp_arrastre(
					cod_agente,
					cod_ramo,
					comision
					)
					VALUES(
					_cod_agente,
					_cod_ramo,
					v_comis_arrastre
					);

				END

				BEGIN

					ON EXCEPTION IN(-239)

						UPDATE tmp_ramo
						   SET comision   = comision + v_comis_arrastre
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
					v_comis_arrastre
					);

				END
			  
			 END FOREACH
			 
		-- Comision descontada	 
			FOREACH
				SELECT comision
				  INTO v_comis_arrastre
				  FROM chqcomis
				 WHERE no_requis = _no_requis_c
				   AND no_poliza = '00000'
			   
				LET v_comis_arrastre = v_comis_arrastre * -1;
				LET _comis_desc = v_comis_arrastre;
				LET _cant_reg = 0;

				SELECT COUNT(*)
				  INTO _cant_reg
				  FROM tmp_arrastre
				 WHERE cod_agente = _cod_agente;

				IF _cant_reg IS NULL THEN
				  LET _cant_reg = 0;
				END IF				

               -- Cargando temporal de arrastre
			   
			   IF _cant_reg > 0 THEN
				   FOREACH		
					SELECT comision,
						   cod_ramo	
					  INTO v_comision,
						   _cod_ramo   
					  FROM tmp_arrastre
					 WHERE cod_agente = _cod_agente
					 ORDER BY cod_ramo

						IF _comis_desc = 0 THEN
							EXIT FOREACH;
						ELSE
							IF _comis_desc >= v_comision THEN
								UPDATE tmp_arrastre
								   SET comision   = 0
								 WHERE cod_agente = _cod_agente
								   AND cod_ramo   = _cod_ramo;
								LET _comis_desc   = _comis_desc - v_comision;
							ELSE
								UPDATE tmp_arrastre
								   SET comision   = comision - _comis_desc
								 WHERE cod_agente = _cod_agente
								   AND cod_ramo   = _cod_ramo;
								LET _comis_desc   = 0;
							END IF
						END IF

					END FOREACH

					SELECT SUM(comision)
					  INTO v_comision
					  FROM tmp_arrastre
					 WHERE cod_agente = _cod_agente;

					IF v_comision = 0 AND _comis_desc > 0 THEN
						FOREACH
							SELECT cod_ramo
							  INTO _cod_ramo
							  FROM tmp_arrastre
							 WHERE cod_agente = _cod_agente
							   AND comision   = 0
							 EXIT FOREACH;
						END FOREACH

						UPDATE tmp_arrastre
						   SET comision   = _comis_desc * -1
						 WHERE cod_agente = _cod_agente
						   AND cod_ramo   = _cod_ramo;
					END IF 

				ELSE
					INSERT INTO tmp_arrastre(
					cod_agente,
					cod_ramo,
					comision
					)
					VALUES(
					_cod_agente,
					'002',
					_comis_desc * -1
					);
				END IF
              
			    -- Cargando temporal tmp_ramo
				
				SELECT COUNT(*)
				  INTO _cant_reg
				  FROM tmp_ramo
				 WHERE cod_agente = _cod_agente;
				 
				LET _comis_desc = v_comis_arrastre;

				IF _cant_reg IS NULL THEN
				  LET _cant_reg = 0;
				END IF
		
			   IF _cant_reg > 0 THEN
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

					SELECT SUM(comision)
					  INTO v_comision
					  FROM tmp_ramo
					 WHERE cod_agente = _cod_agente;

					IF v_comision = 0 AND _comis_desc > 0 THEN
						FOREACH
							SELECT cod_ramo
							  INTO _cod_ramo
							  FROM tmp_ramo
							 WHERE cod_agente = _cod_agente
							   AND comision   = 0
							 EXIT FOREACH;
						END FOREACH

						UPDATE tmp_ramo
						   SET comision   = _comis_desc * -1
						 WHERE cod_agente = _cod_agente
						   AND cod_ramo   = _cod_ramo;
					END IF 

				ELSE
					INSERT INTO tmp_ramo(
					cod_agente,
					cod_ramo,
					comision
					)
					VALUES(
					_cod_agente,
					'002',
					_comis_desc * -1
					);
				END IF

			 END FOREACH
		 End If
	END FOREACH
END FOREACH


FOREACH  --Comision Descontada
 SELECT SUM(comision),
		cod_agente
   INTO _comis_desc,
		_cod_agente
   FROM tmp_agente
  WHERE no_poliza = '00000'
  GROUP BY cod_agente

	LET _comis_desc = _comis_desc * -1;
	LET _cant_reg = 0;

   SELECT COUNT(*)
     INTO _cant_reg
	 FROM tmp_ramo
	WHERE cod_agente = _cod_agente;

   IF _cant_reg IS NULL THEN
   	LET _cant_reg = 0;
   END IF

   IF _cant_reg > 0 THEN
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

        SELECT SUM(comision)
		  INTO v_comision
		  FROM tmp_ramo
		 WHERE cod_agente = _cod_agente;

        IF v_comision = 0 AND _comis_desc > 0 THEN
			FOREACH
				SELECT cod_ramo
				  INTO _cod_ramo
				  FROM tmp_ramo
				 WHERE cod_agente = _cod_agente
				   AND comision   = 0
				 EXIT FOREACH;
			END FOREACH

			UPDATE tmp_ramo
			   SET comision   = _comis_desc * -1
			 WHERE cod_agente = _cod_agente
			   AND cod_ramo   = _cod_ramo;
        END IF 

	ELSE
		INSERT INTO tmp_ramo(
		cod_agente,
		cod_ramo,
		comision
		)
		VALUES(
		_cod_agente,
		'002',
		_comis_desc * -1
		);
	END IF

--	DELETE FROM tmp_ramo
--	 WHERE cod_agente = _cod_agente
--	   AND comision   = 0; 

END FOREACH

FOREACH
 SELECT SUM(comision),
		cod_agente
   INTO v_comis_periodo,
		_cod_agente
   FROM tmp_ramo
  GROUP BY cod_agente

    LET _estatus_licencia = '';
  
	SELECT nombre,
		   generar_cheque,
		   --saldo,
		   tipo_pago,
		   cod_cuenta,
		   alias, 
		   estatus_licencia
	  INTO v_nombre_agt,
	  	   v_generar_chq,
		   --v_comis_arrastre,
		   _tipo_pago,
		   v_cod_cuenta,
		   v_alias,
		   _estatus_licencia
	  FROM agtagent
	 WHERE cod_agente = _cod_agente; 
	 	 	   		   	
	LET v_comis_arrastre = 0.00;
	
    SELECT sum(comision)
	  INTO v_comis_arrastre
	  FROM tmp_arrastre
	 WHERE cod_agente = _cod_agente;
	 
	IF v_comis_arrastre is null then
		let v_comis_arrastre = 0;
	END IF

    LET _deuda	= 0;
	LET v_deuda_tot = 0;

--> Se modifica para hacer el calculo correcto de las deudas <--
   	FOREACH
	    SELECT monto,
			   no_documento,
			   tipo
	      INTO _deuda,
			   _no_documento,
			   _tipo
	      FROM agtdeuda
	     WHERE cod_agente = _cod_agente
		   AND quincena   in (0, _quincena)

        If _tipo = 2 Then
			let _saldo = sp_cob115b('001','001',_no_documento,'');
		End If

		If _saldo < _deuda then
			let _deuda = _saldo;
		end if

		LET v_deuda_tot = v_deuda_tot + _deuda; 

	END FOREACH

 {	SELECT sum(monto)
	  INTO _deuda
	  FROM agtdeuda					   
	 WHERE quincena = 0
	   AND cod_agente = _cod_agente;

	LET v_deuda_tot = v_deuda_tot + _deuda; 

 	IF _quincena = 1 THEN
		SELECT SUM(monto)
		  INTO _deuda
		  FROM agtdeuda
		 WHERE cod_agente = _cod_agente
		   AND quincena = 1;
	ELIF _quincena = 2 THEN
		SELECT SUM(monto)
		  INTO _deuda
		  FROM agtdeuda
		 WHERE cod_agente = _cod_agente
		   AND quincena = 2;
	END IF
  
	LET v_deuda_tot = v_deuda_tot + _deuda; 
}  
	LET v_comision = v_comis_periodo;
--	LET v_comision = v_comis_arrastre + v_comis_periodo;

    -- Agente o corredor suspendido
	IF _estatus_licencia in('X','P') THEN
		LET v_generar_chq = 0;
	END IF

	IF v_comision <= 0 THEN
		LET v_generar_chq = 0;
	END IF

	IF _tipo_pago <> 1 THEN	 -- Pregunta si no es ACH
		IF v_comision < _monto_minimo THEN
			LET v_generar_chq = 0;
		END IF
	END IF

	IF TRIM(v_nombre_agt[1,7]) = "DIRECTO" THEN
		LET v_nombre_agt = v_alias;
	END IF

	RETURN  v_generar_chq,
			v_nombre_agt,
			v_comision,
			v_comis_periodo - v_comis_arrastre,
			v_comis_arrastre,
			_cod_agente,
			_tipo_pago,
			v_cod_cuenta,
			v_deuda_tot
			WITH RESUME;
	
END FOREACH

DROP TABLE tmp_agente;

END PROCEDURE;