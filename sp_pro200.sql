-- Procedimiento para reportes 
-- 
--
-- Creado    : 07/12/2010 - Autor: Amado Perez Mendoza
-- Modificado: 07/12/2010 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro200;
CREATE PROCEDURE "informix".sp_pro200(a_cia CHAR(3), a_periodo CHAR(7), a_periodo2 CHAR(7))
			RETURNING   CHAR(3), VARCHAR(50), VARCHAR(100), CHAR(20), CHAR(10), DEC(16,2), VARCHAR(50), VARCHAR(50), DEC(16,2), VARCHAR(50), DEC(5,2), DEC(16,2), VARCHAR(50) ;   			 


DEFINE _no_poliza			CHAR(10);
DEFINE _no_endoso			CHAR(5);
DEFINE _cod_sucursal		CHAR(3);
DEFINE _cod_ramo			CHAR(3);
DEFINE _no_documento		CHAR(20);
DEFINE _no_factura			CHAR(10);
DEFINE _prima_suscrita		DEC(16,2);
DEFINE _cod_cliente     	CHAR(10);
DEFINE _es_flota        	SMALLINT;
DEFINE _porc_partic_agt 	DEC(5,2);
DEFINE _porc_comis_agt    	DEC(5,2);
DEFINE _cod_agente      	CHAR(10);
DEFINE _nom_agente      	VARCHAR(50);
DEFINE _cod_vendedor    	CHAR(3);
DEFINE _zona            	VARCHAR(50);
DEFINE _cod_tiporamo    	CHAR(3);
DEFINE _nom_tiporamo    	VARCHAR(20);
DEFINE _nueva_renov     	CHAR(1);
DEFINE _fronting        	SMALLINT;
DEFINE _facultativo    		SMALLINT;
DEFINE _nom_tipo_prod   	VARCHAR(50);
DEFINE _nom_asegurado   	VARCHAR(100);
DEFINE _prima_sus_age   	DEC(16,2);
DEFINE _comis_age   	    DEC(16,2);
DEFINE v_compania_nombre	VARCHAR(50); 
DEFINE _suc_promotoria 		CHAR(3);
DEFINE _nom_ramo            VARCHAR(50);
DEFINE _cod_contrato		CHAR(5);
DEFINE _porc_partic_prima	DEC(9,6);
DEFINE _tipo_contrato		SMALLINT;
DEFINE _no_unidad           CHAR(5);
DEFINE _porc_partic_reas    DEC(7,4); 
DEFINE _porc_comis_fac		DEC(5,2);
DEFINE _porc_comis_fac_tot  DEC(5,2);
DEFINE _comis_fac		    DEC(16,2);
DEFINE _prima_suscrita_uni  DEC(16,2);
DEFINE _prima_sus_age_uni   DEC(16,2);


SET ISOLATION TO DIRTY READ;

LET v_compania_nombre = sp_sis01(a_cia);

FOREACH	WITH HOLD
	SELECT no_poliza,
	       no_endoso,
		   no_documento,
		   no_factura,
		   prima_suscrita
	  INTO _no_poliza,
		   _no_endoso,
		   _no_documento,
		   _no_factura,
		   _prima_suscrita
	  FROM endedmae
	 WHERE actualizado = 1
	   AND periodo >= a_periodo
	   AND periodo <= a_periodo2

    LET _fronting = 0;
	LET _facultativo = 0;

    FOREACH
		SELECT cod_contrato, porc_partic_prima
		  INTO _cod_contrato, _porc_partic_prima
		  FROM emifacon
		 WHERE no_poliza = _no_poliza
	       AND no_endoso = _no_endoso
		   AND porc_partic_prima <> 0 

      	SELECT tipo_contrato, fronting
		  INTO _tipo_contrato, _fronting
		  FROM reacomae
		 WHERE cod_contrato = _cod_contrato;

        IF _fronting = 1 THEN
			EXIT FOREACH;
		END IF

        IF _tipo_contrato = 3 THEN
	  		LET _facultativo = _facultativo + _porc_partic_prima;
	    END IF
	END FOREACH

    IF _fronting > 0 OR _facultativo = 100 THEN
		LET _nom_tipo_prod = "FRONTING Y FACULTATIVOS 100%";
	ELSE
	    CONTINUE FOREACH;
	END IF

	LET _es_flota = 0;

   	FOREACH
		SELECT no_unidad
		  INTO _no_unidad
		  FROM endeduni
	     WHERE no_poliza = _no_poliza

		LET _es_flota = _es_flota + 1;

		IF _es_flota > 1 THEN
			EXIT FOREACH;
		END IF
	END FOREACH

    IF _es_flota = 1 THEN
		SELECT cod_cliente
		  INTO _cod_cliente 
		  FROM endeduni
	     WHERE no_poliza = _no_poliza
		   AND no_endoso = _no_endoso;
	ELSE
		SELECT cod_contratante
		  INTO _cod_cliente
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;
	END IF

	SELECT nombre
	  INTO _nom_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

   	FOREACH WITH HOLD
		SELECT cod_agente, porc_partic_agt, porc_comis_agt
		  INTO _cod_agente, _porc_partic_agt, _porc_comis_agt
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza

		LET _prima_sus_age = 0.00;
        LET _prima_sus_age = _prima_suscrita * _porc_partic_agt / 100;
		LET _comis_age     = 0.00;
		LET _comis_age     = _prima_suscrita * _porc_partic_agt / 100 * _porc_comis_agt / 100; 

        SELECT sucursal_origen, cod_ramo, nueva_renov
		  INTO _cod_sucursal, _cod_ramo, _nueva_renov
		  FROM emipomae
	     WHERE no_poliza = _no_poliza;

		SELECT sucursal_promotoria
		  INTO _suc_promotoria
		  FROM insagen
		 WHERE codigo_agencia = _cod_sucursal;
		 
		SELECT cod_vendedor
		  INTO _cod_vendedor
		  FROM parpromo
		 WHERE cod_agente  = _cod_agente
		   AND cod_agencia = _suc_promotoria
		   AND cod_ramo    = _cod_ramo;

        SELECT nombre
		  INTO _zona
		  FROM agtvende
		 WHERE cod_vendedor = _cod_vendedor;

        SELECT nombre
		  INTO _nom_agente
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;
 {
        IF _cod_ramo IN ('002','020') THEN
			LET _nom_tiporamo = 'AUTOMOVIL';
		ELSE
			SELECT cod_tiporamo
			  INTO _cod_tiporamo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;
			 
			IF _cod_tiporamo = "001" THEN
				LET _nom_tiporamo = 'RAMOS DE PERSONAS';		
			ELIF _cod_tiporamo = "002" THEN
				LET _nom_tiporamo = 'PATRIMONIALES';
			ELIF _cod_tiporamo = "003" THEN
				LET _nom_tiporamo = 'FIANZA';
			ELSE
				LET _nom_tiporamo = 'POR DEFINIR';
			END IF
		END IF
 }		
		SELECT nombre
		  INTO _nom_ramo
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

        LET _comis_fac = 0.00;
		LET _porc_comis_fac_tot = 0.00;

        IF _fronting > 0 OR _facultativo = 100 THEN
    	 {	IF _es_flota = 1 THEN
				FOREACH
					SELECT no_unidad, prima_suscrita
					  INTO _no_unidad, _prima_suscrita_uni
					  FROM endeduni
					 WHERE no_poliza = _no_poliza
				       AND no_endoso = _no_endoso

					LET _prima_sus_age_uni = 0.00;
			        LET _prima_sus_age_uni = _prima_suscrita_uni * _porc_partic_agt / 100;

					FOREACH
						SELECT porc_partic_reas, porc_comis_fac
						  INTO _porc_partic_reas, _porc_comis_fac
						  FROM emifafac
						 WHERE no_poliza = _no_poliza
					       AND no_endoso = _no_endoso
						   AND no_unidad = _no_unidad
						   AND cod_contrato = _cod_contrato

		                LET _comis_fac = _comis_fac + _prima_sus_age_uni * _porc_partic_reas / 100 * _porc_comis_fac / 100;
						LET _porc_comis_fac_tot = _porc_comis_fac_tot + _porc_comis_fac;
					END FOREACH

				END FOREACH
			ELSE }
				FOREACH
					SELECT porc_partic_reas, porc_comis_fac
					  INTO _porc_partic_reas, _porc_comis_fac
					  FROM emifafac
					 WHERE no_poliza = _no_poliza
				       AND no_endoso = _no_endoso
					   AND cod_contrato = _cod_contrato

	                LET _comis_fac = _comis_fac + _prima_sus_age * _porc_partic_reas / 100 * _porc_comis_fac / 100;
					LET _porc_comis_fac_tot = _porc_comis_fac_tot + _porc_comis_fac;
					exit foreach;
				END FOREACH
		   --	END IF
		END IF

		RETURN _cod_ramo,
		       _nom_ramo,
		       _nom_asegurado,
			   _no_documento,
			   _no_factura,
		  	   _prima_sus_age,
			   _zona,
			   _nom_agente,
			   _comis_age,
			   _nom_tipo_prod,
			   _porc_comis_fac_tot,
			   _comis_fac,
			   v_compania_nombre
			   WITH RESUME;

	END FOREACH


END FOREACH

END PROCEDURE;

