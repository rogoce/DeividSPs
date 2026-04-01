-- Procedimiento que Carga los Datos para la Apadea
-- 
-- Creado    : 18/02/2002 - Autor: Amado Perez M. 
-- Modificado: 18/02/2002 - Autor: Amado Perez M. 

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis333;		

CREATE PROCEDURE "informix".sp_sis333()
RETURNING INTEGER, CHAR(250);

DEFINE _mensaje			CHAR(250);
DEFINE _codigo 			CHAR(10);
DEFINE _numerorecl 		CHAR(20);
DEFINE _numerorec2  	SMALLINT;
DEFINE _monto       	DEC(18,2);
DEFINE _cod_cobertura 	CHAR(5);
DEFINE _equivalente 	CHAR(2);
DEFINE _cod_tipotran    CHAR(3);
DEFINE _codasegura      SMALLINT;
DEFINE _no_reclamo      CHAR(10);
DEFINE _fecharegistro1  DATE;
DEFINE _aseg_primer_nom, _aseg_primer_nom_cond	 CHAR(100);
DEFINE _aseg_segundo_nom, _aseg_segundo_nom_cond CHAR(40);
DEFINE _aseg_primer_ape, _aseg_primer_ape_cond	 CHAR(40);
DEFINE _aseg_segundo_ape,_aseg_segundo_ape_cond	 CHAR(40);
DEFINE _aseg_casada_ape, _aseg_casada_ape_cond   CHAR(40);
DEFINE _tipo_persona, _tipo_persona_cond         CHAR(1);
DEFINE _ced_provincia, _ced_provincia_cond  	 CHAR(2);
DEFINE _ced_inicial, _ced_inicial_cond			 CHAR(2);
DEFINE _ced_tomo, _ced_tomo_cond				 CHAR(7);
DEFINE _ced_folio, _ced_folio_cond				 CHAR(7);
DEFINE _ced_asiento			 					 CHAR(7);
DEFINE _cedula				                    CHAR(20);
DEFINE _cod_tercero								CHAR(10);
DEFINE _no_motor_ter							CHAR(30);
DEFINE _cod_conductor_ter						SMALLINT;
DEFINE _perd_total_ter							CHAR(2);
DEFINE _descripcion_ter							CHAR(255);
DEFINE _no_reclamo      					  	CHAR(10);
DEFINE _estatus_reclamo, _perdidatot            CHAR(1);
DEFINE _cod_color								CHAR(5);
DEFINE _perd_total								SMALLINT;
DEFINE _no_chasis								CHAR(30);
DEFINE _vin										CHAR(30);
DEFINE _placa_taxi								CHAR(10);
DEFINE _marca, _modelo, _color, _estilo         CHAR(30);
DEFINE _cod_tipoauto                            CHAR(3);
DEFINE _monto, _monto_tot                       DEC(16,2);
DEFINE _cod_evento, _cod_tipotran			  	CHAR(3);
DEFINE _codaseguradora, _renglon, _contador     SMALLINT;
DEFINE _usuarioregistro                         CHAR(30);
DEFINE _estadosiniestro, _estadorecl            CHAR(2);

--DELETE FROM tmp_coberturas;

SET ISOLATION TO DIRTY READ;

LET _codaseguradora = 8;
LET _usuarioregistro = 'AMADO';

SELECT fecha
  INTO _fecharegistro1
  FROM cib_contador;


FOREACH
	SELECT no_reclamo,
	       cod_tercero,
	       no_motor,
		   cod_conductor,
		   perd_total,
		   descripcion
	  INTO _no_reclamo,
	       _cod_tercero,
	       _no_motor_ter,
		   _cod_conductor_ter,
		   _perd_total_ter,
		   _descripcion_ter
	  FROM recterce
	 WHERE date_changed >= _fecharegistro1
	   AND date_changed <= CURRENT

	IF _cod_tercero is null OR _cod_tercero = '' THEN
	   CONTINUE FOREACH;
	END IF

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
		   a.perd_total
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
		   _perd_total
	  FROM recrcmae a, emipomae b
	 WHERE b.no_poliza = a.no_poliza
	   AND a.no_reclamo = _no_reclamo
	   AND a.actualizado = 1
	   AND b.actualizado = 1
	   AND b.cod_ramo = '002'
	   AND b.cod_tipoprod NOT IN ('002','004')

	IF _estatus_reclamo = 'T' OR _estatus_reclamo = 'R' THEN
		LET _estadosiniestro = 'AB';
	ELSE
	  	LET _estadosiniestro = 'CE';
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

		IF _estatus_reclamo = 'D' THEN
			LET _estadorecl = 'DE';
		ELSE
		  	LET _estadorecl = 'PA';
		END IF

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
		WHERE no_motor = _no_motor_ter;

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
			   AND cod_cliente = _cod_tercero
			   AND cod_tipotran = '004'

			LET _monto_tot = _monto_tot + _monto; 
            
		END FOREACH

		IF _no_motor IS NULL THEN
		   LET _no_motor = '';
		END IF

		IF _tipo_persona IS NULL THEN
		   LET _tipo_persona = '';
		END IF

		IF _cod_tercero is not null AND _cod_tercero <> '' THEN
			BEGIN
			 ON EXCEPTION IN(-239, -268)
			   CONTINUE FOREACH;
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
						CURRENT,
						CURRENT
						);

	            LET _contador = _contador + 1;    
	                
			END
		END IF

END FOREACH
 ----------------------------------------------

	SELECT codigo,
	       numerorecl,
		   numerorec2,
		   codasegura
	  INTO _codigo,
	       _numerorecl,
		   _numerorec2,
		   _codasegura
	  FROM tmp_reclamantes
	 WHERE fecharegistro = '28/02/2002'

	LET _monto = 0;

	FOREACH
		SELECT a.cod_cobertura,
		       a.monto,
			   b.cod_tipotran
		  INTO _cod_cobertura,
		       _monto,
			   _cod_tipotran
		  FROM rectrcob a, rectrmae b
		 WHERE a.no_tranrec = b.no_tranrec
		   AND b.numrecla = _numerorecl
		   AND b.cod_cliente = _codigo    
		   AND b.cod_tipotran = '004'

		SELECT equivalente
		  INTO _equivalente
		  FROM tmp_tipocobertura
		 WHERE cod_cobertura = _cod_cobertura;

		IF _equivalente IS NULL OR _equivalente = '' THEN
		   LET _equivalente = '17';
		END IF

		BEGIN
			ON EXCEPTION IN(-239, -268)
				UPDATE tmp_coberturas
				   SET sum_monto = sum_monto + _monto,
				       fecharegistro = current
				 WHERE numerorecl = _numerorecl
				   AND numerorec2 = _numerorec2
				   AND equivalent = _equivalente;

			END EXCEPTION
			INSERT INTO tmp_coberturas
			VALUES (_codasegura,
			        _numerorecl,
					_numerorec2,
					_equivalente,
					_monto,
					current
					);
		  END

	END FOREACH

END FOREACH

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;
       


END PROCEDURE;