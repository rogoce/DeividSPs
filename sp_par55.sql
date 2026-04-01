-- Procedimiento que cambia la vigencia final  que estan nulas
-- por 3 meses mas de la vigencia inicial
--
-- Creado    : 10/08/2001 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 10/08/2001 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par55;

CREATE PROCEDURE "informix".sp_par55()
   RETURNING  CHAR(10),
              CHAR(20),
			  DATE,
			  DATE,
			  DATE;

  DEFINE v_poliza 											CHAR(10);
  DEFINE v_documento 										CHAR(20);
  DEFINE v_primer_pago, v_vigencia_ini, v_vigencia_final  	DATE;
  DEFINE v_primer_pago_nuevo                                DATE;
  DEFINE v_periodo                      					CHAR(7);
  DEFINE v_saldos                       					DEC(16,2);
  DEFINE v_codperpago                  						CHAR(3);
  DEFINE v_perpago											CHAR(50);
  DEFINE _meses, _mes, _dia, _ano, _no_pagos                INT;
  DEFINE _char_mes, _char_dia                       		CHAR(2);
  DEFINE _char_ano											CHAR(4);

CREATE TEMP TABLE tmp_arreglo(
		no_poliza        CHAR(10), 
		no_documento	 CHAR(20), 
		vigen_ini        DATE,
		primer_pago      DATE
		) WITH NO LOG;

-- General Representative 00161
--SET DEBUG FILE TO "gen_repr";-- Nombre de la Compania
--TRACE ON;


	FOREACH WITH HOLD
		SELECT 	Emipomae.no_poliza, Emipomae.no_documento,
		  		Emipomae.vigencia_inic, Emipomae.vigencia_final
		  INTO 	v_poliza, v_documento, 					
		  		v_vigencia_ini, v_vigencia_final  
		 FROM  Emipomae
		 WHERE Emipomae.actualizado = 1
		   AND Emipomae.vigencia_final IS NULL
		   AND Emipomae.cod_ramo = '009'
 --		   AND Emipomae.estatus_poliza = 1
 --		   AND Emipomae.fecha_cancelacion IS NULL

		LET _meses = 3;

		LET _mes = MONTH(v_vigencia_ini) + _meses;
		LET _ano = YEAR(v_vigencia_ini);
		LET _dia = DAY(v_vigencia_ini);

		If _mes > 12 Then
		   LET _mes = _mes - 12;
		   LET _ano = _ano + 1;
		End If
		If _mes = 2 Then
			If _dia > 28 Then
				LET _dia = 28;
			End If
		ElIf _mes = 4  Or _mes = 6 Or _mes = 9 Or _mes = 11 Then
			If _dia > 30 Then
				LET _dia = 30;
			End If
		End If

		LET _char_mes = _mes;
		LET _char_dia = _dia;
		LET _char_ano = _ano;

		IF _mes < 10 THEN
		   LET _char_mes = '0' || _char_mes;
		END IF

		IF _dia < 10 THEN
		   LET _char_dia = '0' || _char_dia;
		END IF    

		LET v_primer_pago_nuevo = Date(_char_dia || "/" || _char_mes || "/" || _char_ano);
--		LET v_primer_pago_nuevo = Date('31/12/2001');
						  
		INSERT INTO tmp_arreglo(
		no_poliza,   
		no_documento,
		vigen_ini,
		primer_pago   
		)
		VALUES(
		v_poliza,
		v_documento,
		v_vigencia_ini,
		v_primer_pago_nuevo
		);

      RETURN v_poliza, 
      		 v_documento, 				
			 v_vigencia_ini, 
			 v_vigencia_final,
			 v_primer_pago_nuevo
		   	 WITH RESUME; 
			 
    END FOREACH

 	FOREACH WITH HOLD

		SELECT no_poliza,   
			   no_documento,
			   vigen_ini,   
			   primer_pago
		  INTO v_poliza,
			   v_documento,
			   v_vigencia_ini,
	  		   v_primer_pago_nuevo
		  FROM tmp_arreglo

		UPDATE emipomae
		   SET vigencia_final = v_primer_pago_nuevo
		 WHERE no_poliza = v_poliza;


	END FOREACH


  DROP TABLE tmp_arreglo; 
END PROCEDURE




