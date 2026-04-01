-- Procedimiento que Carga los Datos para la Apadea
-- 
-- Creado    : 08/02/2002 - Autor: Amado Perez M. 
-- Modificado: 08/02/2002 - Autor: Amado Perez M. 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis33;		

CREATE PROCEDURE "informix".sp_sis33()
RETURNING INTEGER, CHAR(250);

DEFINE _mensaje									CHAR(250);

DEFINE _no_poliza                             	CHAR(10);
DEFINE _cod_evento, _cod_tipotran			  	CHAR(3);
DEFINE _no_reclamo      					  	CHAR(10);
DEFINE _parte_policivo  					  	CHAR(10);
DEFINE _fecha_siniestro, _fecha_reclamo       	DATE;   
DEFINE _cod_asegurado, _cod_conductor, _placa	CHAR(10); 
DEFINE _cedula_aseg, _cedula_cond, _no_motor  	CHAR(30); 
DEFINE _cod_marca, _cod_modelo, _cod_agente    	CHAR(5);
DEFINE _ano_auto         						SMALLINT;
DEFINE _numrecla         						CHAR(18);
DEFINE _no_resolucion    						CHAR(20);
DEFINE _no_denuncia      						CHAR(20);
DEFINE _no_oficio		 						CHAR(20);
DEFINE _no_placa_policia 						CHAR(30);
DEFINE _desc_transaccion                        CHAR(60);
DEFINE _descripcion                             CHAR(255);
DEFINE _tiposiniestro                           CHAR(2);
DEFINE _estadosiniestro, _estadorecl            CHAR(2);
DEFINE _codaseguradora, _renglon, _contador     SMALLINT;
DEFINE _fecharegistro, _fecharegistro1          DATE;
DEFINE _usuarioregistro                         CHAR(30);
DEFINE _nombrecorredor                          CHAR(100);
DEFINE _estatus_reclamo, _perdidatot, _coaseguro CHAR(1);
DEFINE _user_added                              CHAR(8);
DEFINE _tamano                                  INTEGER;
DEFINE _tipo_persona, _tipo_persona_cond         CHAR(1);
DEFINE _ced_provincia, _ced_provincia_cond  	 CHAR(2);
DEFINE _ced_inicial, _ced_inicial_cond			 CHAR(2);
DEFINE _ced_tomo, _ced_tomo_cond				 CHAR(7);
DEFINE _ced_folio, _ced_folio_cond				 CHAR(7);
DEFINE _ced_asiento			 					 CHAR(7);
DEFINE _aseg_primer_nom, _aseg_primer_nom_cond	 CHAR(100);
DEFINE _aseg_segundo_nom, _aseg_segundo_nom_cond CHAR(40);
DEFINE _aseg_primer_ape, _aseg_primer_ape_cond	 CHAR(40);
DEFINE _aseg_segundo_ape,_aseg_segundo_ape_cond	 CHAR(40);
DEFINE _aseg_casada_ape, _aseg_casada_ape_cond   CHAR(40);
DEFINE _cod_color								CHAR(5);
DEFINE _perd_total								SMALLINT;
DEFINE _no_chasis								CHAR(30);
DEFINE _vin										CHAR(30);
DEFINE _placa_taxi								CHAR(10);
DEFINE _marca, _modelo, _color, _estilo         CHAR(30);
DEFINE _cod_tipoauto, _cod_tipoprod             CHAR(3);
DEFINE _monto, _monto_tot                       DEC(16,2);
DEFINE _cedula				                    CHAR(20);
DEFINE _cod_tercero								CHAR(10);
DEFINE _no_motor_ter							CHAR(30);
DEFINE _cod_conductor_ter						SMALLINT;
DEFINE _perd_total_ter							CHAR(2);
DEFINE _descripcion_ter							CHAR(255);

SET ISOLATION TO DIRTY READ;

-- Lectura del Reclamo

DELETE FROM cib_reclamos;
DELETE FROM cib_reclamantes;

LET _codaseguradora = 8;
LET _fecharegistro = CURRENT;
LET _fecharegistro = '20/12/2000';
--LET _fecharegistro1 = _fecharegistro - 1;
--LET _fecharegistro1 = '20/03/2003';	   --poner en comentario
LET _usuarioregistro = 'AMADO';

SELECT fecha
  INTO _fecharegistro1
  FROM cib_contador;
-- Trae los reclamos
LET _fecharegistro1 = '20/12/2000';	   --poner en comentario

--set debug file to "sp_rwf02.trc";
--trace on;


FOREACH
	SELECT a.numrecla,
	       a.fecha_reclamo,
		   a.fecha_siniestro,
		   a.cod_evento,
		   a.parte_policivo,
		   a.estatus_reclamo,
		   a.user_added,
		   a.no_reclamo,
		   a.no_poliza,
		   a.no_resolucion,
		   a.no_denuncia,
		   a.no_oficio,
		   a.no_placa_policia,
		   b.cod_tipoprod
	  INTO _numrecla,
	       _fecha_reclamo,
		   _fecha_siniestro,
		   _cod_evento,
		   _parte_policivo,
		   _estatus_reclamo,
		   _user_added,
		   _no_reclamo,
		   _no_poliza,
		   _no_resolucion,   
		   _no_denuncia,     
		   _no_oficio,		
		   _no_placa_policia,
		   _cod_tipoprod
	  FROM recrcmae a, emipomae b
	 WHERE b.no_poliza = a.no_poliza
	   AND a.fecha_reclamo >= _fecharegistro1
	   AND a.fecha_reclamo <= _fecharegistro
	   AND a.actualizado = 1
	   AND b.actualizado = 1
	   AND b.cod_ramo = '002'
	   AND b.cod_tipoprod NOT IN ('002','004')
--	   AND a.cod_evento = '039'

    -- Es coaseguro?
	IF _cod_tipoprod = '001' THEN
	   LET _coaseguro = 'S';
	ELSE
	   LET _coaseguro = 'N';
	END IF

	-- Estatus del Reclamo
	IF _estatus_reclamo = 'T' OR _estatus_reclamo = 'R' THEN	 
		LET _estadosiniestro = 'AB'; --Abierto
	ELSE
	  	LET _estadosiniestro = 'CE'; --Cerrado
	END IF

	LET _desc_transaccion = '';
	LET _descripcion = '';
	LET _tamano = 0;

	--Descripcion del reclamo
	FOREACH
		SELECT desc_transaccion,
		       renglon
		  INTO _desc_transaccion,
		       _renglon
		  FROM recrcde2
		 WHERE no_reclamo = _no_reclamo
	  ORDER BY renglon										  

	  LET _desc_transaccion = TRIM(_desc_transaccion); 
	  LET _tamano = _tamano + LENGTH(_desc_transaccion);

	  IF _tamano <= 255  THEN  
		  LET _descripcion = TRIM(_descripcion) || TRIM(_desc_transaccion);
	  ELSE
	      EXIT FOREACH;
	  END IF

	END FOREACH

	--Corredor
	FOREACH
		SELECT cod_agente
		  INTO _cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza

		SELECT nombre
		  INTO _nombrecorredor
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		EXIT FOREACH;
	END FOREACH

	LET _tiposiniestro = '';

    -- Tipo de Siniestro
	SELECT equivalente
	  INTO _tiposiniestro
	  FROM cib_tiposiniestro
	 WHERE cod_evento = _cod_evento;

	IF _tiposiniestro IS NULL OR _tiposiniestro = '' THEN
		LET _tiposiniestro = '6';
	END IF

	BEGIN
	 ON EXCEPTION IN(-239, -268)
 --	   UPDATE cib_reclamos
 --	      SET fecharegistro = _fecharegistro
 --		WHERE no_reclamo = _no_reclamo;

	 END EXCEPTION
		INSERT INTO cib_reclamos
		VALUES (_codaseguradora,
		        _numrecla,
		        _fecharegistro,
				_usuarioregistro,
				_fecha_reclamo,
				_user_added,
				_fecha_siniestro,
				_tiposiniestro,
				_descripcion,
				_parte_policivo,
				_no_resolucion,
				_no_denuncia,
				_no_oficio,
				_nombrecorredor,
				_estadosiniestro,
				'',
				_no_placa_policia,
				'',
				_coaseguro,
				_no_reclamo
				);

	END

END FOREACH

--LLenar la tabla de Reclamantes con los terceros y los asegurados
FOREACH
   SELECT no_reclamo,
          numeroreclamo,
          fechareclamo
     INTO _no_reclamo,
		  _numrecla,
		  _fecha_reclamo
	 FROM cib_reclamos
 --	WHERE fecharegistro = _fecharegistro
 --	WHERE tiposiniestro = '17'

   SELECT cod_asegurado,
          cod_conductor,
		  no_motor,
	      perd_total
	 INTO _cod_asegurado,
		  _cod_conductor,
		  _no_motor,
		  _perd_total
	 FROM recrcmae
	WHERE no_reclamo = _no_reclamo;

	LET _contador = 1;

-- Asegurados
   SELECT tipo_persona,
          cedula,
		  ced_provincia,
		  ced_inicial,
		  ced_tomo,
		  ced_folio,
		  ced_asiento,
		  aseg_primer_nom,
		  aseg_segundo_nom,
		  aseg_primer_ape,
		  aseg_segundo_ape,
		  aseg_casada_ape
	 INTO _tipo_persona,
	      _cedula,
		  _ced_provincia,
		  _ced_inicial,
		  _ced_tomo,
		  _ced_folio,
		  _ced_asiento,
		  _aseg_primer_nom,
		  _aseg_segundo_nom,
		  _aseg_primer_ape,
		  _aseg_segundo_ape,
          _aseg_casada_ape
     FROM cliclien   	
	WHERE cod_cliente = _cod_asegurado;

	IF _aseg_primer_nom IS NULL THEN
	   LET _aseg_primer_nom = '';
	END IF

	IF _aseg_primer_ape IS NULL THEN
	   LET _aseg_primer_ape = '';
	END IF

   -- Conductor
   SELECT tipo_persona,
          cedula,
		  ced_provincia,
		  ced_inicial,
		  ced_tomo,
		  ced_folio,
		  aseg_primer_nom,
		  aseg_segundo_nom,
		  aseg_primer_ape,
		  aseg_segundo_ape,
		  aseg_casada_ape
	 INTO _tipo_persona_cond,
		  _cedula_cond,
		  _ced_provincia_cond,
		  _ced_inicial_cond,
		  _ced_tomo_cond,
		  _ced_folio_cond,
		  _aseg_primer_nom_cond,
		  _aseg_segundo_nom_cond,
		  _aseg_primer_ape_cond,
		  _aseg_segundo_ape_cond,
		  _aseg_casada_ape_cond
     FROM cliclien   	
	WHERE cod_cliente = _cod_conductor;

	IF _aseg_primer_nom_cond IS NULL THEN
	   LET _aseg_primer_nom_cond = '';
	END IF

	IF _aseg_primer_ape_cond IS NULL THEN
	   LET _aseg_primer_ape_cond = '';
	END IF

   -- Auto
   SELECT cod_marca,
          cod_modelo,
		  cod_color,
		  ano_auto,
		  no_chasis,
		  vin,
		  placa,
		  placa_taxi
	 INTO _cod_marca,
		  _cod_modelo,
		  _cod_color,
		  _ano_auto,
		  _no_chasis,
		  _vin,
		  _placa,
		  _placa_taxi
	 FROM emivehic
	WHERE no_motor = _no_motor;

	SELECT nombre
	  INTO _marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

	SELECT nombre,
	       cod_tipoauto
	  INTO _modelo,
	       _cod_tipoauto
	  FROM emimodel
	 WHERE cod_marca = _cod_marca
	   AND cod_modelo = _cod_modelo;

	SELECT nombre
	  INTO _color
	  FROM emicolor
	 WHERE cod_color = _cod_color;

	SELECT nombre
	  INTO _estilo   
	  FROM emitiaut
	 WHERE cod_tipoauto = _cod_tipoauto;

	LET _monto_tot = 0;

	FOREACH
		SELECT monto,
		       cod_tipotran
		  INTO _monto,
		       _cod_tipotran
		  FROM rectrmae
		 WHERE no_reclamo = _no_reclamo
		   AND cod_cliente = _cod_asegurado
		   AND cod_tipotran = '004'

		LET _monto_tot = _monto_tot + _monto;         
	END FOREACH

	IF _estatus_reclamo = 'D' THEN
		LET _estadorecl = 'DE';
	ELSE
	  	LET _estadorecl = 'PA';
	END IF

	IF _perd_total = 1 THEN
	   LET _perdidatot = 'S';
	ELSE 
	   LET _perdidatot = 'N';
	END IF
	   
	IF _no_motor IS NULL THEN
	   LET _no_motor = '';
	END IF

	IF _tipo_persona IS NULL THEN
	   LET _tipo_persona = '';
	END IF

	IF _cod_asegurado is not null AND _cod_asegurado <> '' THEN
		BEGIN
		 ON EXCEPTION IN(-239, -268)
--			   UPDATE cib_reclamantes
--			      SET fecharegistro = _fecharegistro
--				WHERE numerorecl = _numrecla
--				  AND codigo = _cod_asegurado;

		 END EXCEPTION
			INSERT INTO cib_reclamantes
			VALUES (_codaseguradora,
			        _numrecla,
					_contador,
					'AS',
					_fecha_reclamo,
					_monto_tot,
					'',
					'',
					'',
					_estadorecl,
					'N',
					0,
					'PD',
					'',
					_ced_provincia,
					_ced_inicial,
					_ced_tomo,
					_ced_folio,
					_ced_asiento,
					_cedula,
					_tipo_persona,
					_aseg_primer_nom,
					_aseg_segundo_nom,
					_aseg_primer_ape,
					_aseg_segundo_ape,
					_aseg_casada_ape,
					'',
					_placa,
					_no_chasis,
					_no_motor,
					_vin,
					_placa_taxi,
					_marca,
					_modelo,
					_ano_auto,
					_color,
					_estilo,
					'N',
					'',
					_perdidatot,
					'RE',
					_ced_provincia_cond,
					_ced_inicial_cond,
					_ced_tomo_cond,
					_ced_folio_cond,
					_cedula_cond,
					_aseg_primer_nom_cond,
					_aseg_segundo_nom_cond,
					_aseg_primer_ape_cond,
					_aseg_segundo_ape_cond,
					_aseg_casada_ape_cond,
					_cod_asegurado,
					_fecharegistro,
					_fecharegistro
					);
		END
	END IF

END FOREACH

-- Terceros
FOREACH
   SELECT no_reclamo,
          numeroreclamo,
          fechareclamo
     INTO _no_reclamo,
		  _numrecla,
		  _fecha_reclamo
	 FROM cib_reclamos
--	WHERE fecharegistro = _fecharegistro

	LET _contador = 1;

	FOREACH
		SELECT cod_tercero,
		       no_motor,
			   cod_conductor,
			   perd_total,
			   descripcion,
			   cod_marca,
			   cod_modelo,
			   placa,
			   ano_auto
		  INTO _cod_tercero,
		       _no_motor_ter,
			   _cod_conductor_ter,
			   _perd_total_ter,
			   _descripcion_ter,
			   _cod_marca,
			   _cod_modelo,
			   _placa,
			   _ano_auto
		  FROM recterce
		 WHERE no_reclamo = _no_reclamo

		IF _cod_tercero is null OR _cod_tercero = '' THEN
		   CONTINUE FOREACH;
		END IF

       -- Asegurados
	   SELECT tipo_persona,
	          cedula,
			  ced_provincia,
			  ced_inicial,
			  ced_tomo,
			  ced_folio,
			  ced_asiento,
			  aseg_primer_nom,
			  aseg_segundo_nom,
			  aseg_primer_ape,
			  aseg_segundo_ape,
			  aseg_casada_ape
		 INTO _tipo_persona,
		      _cedula,
			  _ced_provincia,
			  _ced_inicial,
			  _ced_tomo,
			  _ced_folio,
			  _ced_asiento,
			  _aseg_primer_nom,
			  _aseg_segundo_nom,
			  _aseg_primer_ape,
			  _aseg_segundo_ape,
	          _aseg_casada_ape
	     FROM cliclien   	
		WHERE cod_cliente = _cod_tercero;

		IF _aseg_primer_nom IS NULL THEN
		   LET _aseg_primer_nom = '';
		END IF

		IF _aseg_primer_ape IS NULL THEN
		   LET _aseg_primer_ape = '';
		END IF

	  -- Conductor
	   SELECT tipo_persona,
	          cedula,
			  ced_provincia,
			  ced_inicial,
			  ced_tomo,
			  ced_folio,
			  aseg_primer_nom,
			  aseg_segundo_nom,
			  aseg_primer_ape,
			  aseg_segundo_ape,
			  aseg_casada_ape
		 INTO _tipo_persona_cond,
			  _cedula_cond,
			  _ced_provincia_cond,
			  _ced_inicial_cond,
			  _ced_tomo_cond,
			  _ced_folio_cond,
			  _aseg_primer_nom_cond,
			  _aseg_segundo_nom_cond,
			  _aseg_primer_ape_cond,
			  _aseg_segundo_ape_cond,
			  _aseg_casada_ape_cond
	     FROM cliclien   	
		WHERE cod_cliente = _cod_conductor_ter;

		IF _aseg_primer_ape_cond IS NULL THEN
		   LET _aseg_primer_ape_cond = '';
		END IF

		IF _aseg_primer_nom_cond IS NULL THEN
		   LET _aseg_primer_nom_cond = '';
		END IF

		IF _perd_total_ter = 1 THEN
		   LET _perdidatot = 'S';
		ELSE 
		   LET _perdidatot = 'N';
		END IF

   {	   SELECT cod_marca,
	          cod_modelo,
			  cod_color,
			  ano_auto,
			  no_chasis,
			  vin,
			  placa,
			  placa_taxi
		 INTO _cod_marca,
			  _cod_modelo,
			  _cod_color,
			  _ano_auto,
			  _no_chasis,
			  _vin,
			  _placa,
			  _placa_taxi
		 FROM emivehic
		WHERE no_motor = _no_motor_ter;}

        LET _cod_color = '001';
        LET _no_chasis = '';
        LET _vin = '';
        LET _placa_taxi = '';

		SELECT nombre
		  INTO _marca
		  FROM emimarca
		 WHERE cod_marca = _cod_marca;

		SELECT nombre,
		       cod_tipoauto
		  INTO _modelo,
		       _cod_tipoauto
		  FROM emimodel
		 WHERE cod_marca = _cod_marca
		   AND cod_modelo = _cod_modelo;

{		SELECT nombre
		  INTO _color
		  FROM emicolor
		 WHERE cod_color = _cod_color;}

		SELECT nombre
		  INTO _estilo   
		  FROM emitiaut
		 WHERE cod_tipoauto = _cod_tipoauto;

		LET _monto_tot = 0;

		FOREACH
			SELECT monto,
			       cod_tipotran
			  INTO _monto,
			       _cod_tipotran
			  FROM rectrmae
			 WHERE no_reclamo = _no_reclamo
			   AND cod_cliente = _cod_tercero
			   AND cod_tipotran = '004'

			LET _monto_tot = _monto_tot + _monto; 
            
		END FOREACH

		IF _no_motor_ter IS NULL THEN
		   LET _no_motor_ter = '';
		END IF

		IF _tipo_persona IS NULL THEN
		   LET _tipo_persona = '';
		END IF

		IF _cod_tercero is not null AND _cod_tercero <> '' THEN
			BEGIN
			 ON EXCEPTION IN(-239, -268)
--			   UPDATE cib_reclamantes
--			      SET fecharegistro = _fecharegistro
--				WHERE numerorecl = _numrecla
--				  AND codigo = _cod_tercero;
			 END EXCEPTION
				INSERT INTO cib_reclamantes
				VALUES (_codaseguradora,
				        _numrecla,
						_contador + 1,
						'AF',
						_fecha_reclamo,
						_monto_tot,
						'',
						_descripcion_ter,
						'',
						_estadorecl,
						'N',
						0,
						'OC',
						'',
						_ced_provincia,
						_ced_inicial,
						_ced_tomo,
						_ced_folio,
						_ced_asiento,
						_cedula,
						_tipo_persona,
						_aseg_primer_nom,
						_aseg_segundo_nom,
						_aseg_primer_ape,
						_aseg_segundo_ape,
						_aseg_casada_ape,
						'',
						_placa,
						_no_chasis,
						_no_motor_ter,
						_vin,
						_placa_taxi,
						_marca,
						_modelo,
						_ano_auto,
						_color,
						_estilo,
						'N',
						'',
						_perdidatot,
						'RE',
						_ced_provincia_cond,
						_ced_inicial_cond,
						_ced_tomo_cond,
						_ced_folio_cond,
						_cedula_cond,
						_aseg_primer_nom_cond,
						_aseg_segundo_nom_cond,
						_aseg_primer_ape_cond,
						_aseg_segundo_ape_cond,
						_aseg_casada_ape_cond,
						_cod_tercero,
						_fecharegistro,
						_fecharegistro
						);

	            LET _contador = _contador + 1;    
	                
			END
		END IF
	END FOREACH		  
END FOREACH

{UPDATE cib_reclamantes
   SET tipopago = 'PD'
 WHERE tiporeclam = 'AS';

UPDATE cib_reclamantes
   SET tipopago = 'OC'
 WHERE tiporeclam = 'AF';}

--COMMIT;
-- Lectura de la Poliza

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;

END PROCEDURE;
