 DROP procedure sp_pro73;

 CREATE procedure "informix".sp_pro73(a_compania CHAR(3),a_agencia CHAR(3),a_no_poliza CHAR(20))
   RETURNING CHAR(20),  --POLIZA
   			 CHAR(100),	--ASEGURADO
   			 CHAR(5),	--CERTIFICADO
   			 DEC,		--SUMA ASEGURADA
   			 DATE,		--FECHA NACIMIENTO
             SMALLINT,	--EDAD
             CHAR(100),	--CONTRATANTE
             SMALLINT,	--ENUMERAR UNIDADES
             CHAR(50),  --CIA
             CHAR(30),	--CEDULA
			 DECIMAL(16,2),
			 DECIMAL(16,2);

---------------------------------------------------
---        DETALLE DE UNIDADES (Colectivo de Vida)- 
---  Armando Moreno - Agosto 2001 - AMM -----------
---  Ref. Power Builder - d_sp_pro35    -----------
---------------------------------------------------

BEGIN

    DEFINE v_no_poliza                   CHAR(10);
    DEFINE v_cod_aseg                    CHAR(10);
    DEFINE v_no_documento                CHAR(20);
    DEFINE v_contratante         		 CHAR(10);
    DEFINE v_cod_ramo      				 CHAR(3);
    DEFINE v_descripcion   				 CHAR(50);
    DEFINE v_no_unidad                   CHAR(5);
    DEFINE v_desc_nombre                 CHAR(100);
    DEFINE v_desc_asegurado              CHAR(100);
    DEFINE v_descr_cia                   CHAR(50);
    DEFINE _suma_asegurada               DECIMAL(16,2);
    DEFINE _fecha_aniversario            DATE;
    DEFINE _edad,_cant			         SMALLINT;
	define _cedula						 char(30);
	DEFINE v_prima_anual         		 DECIMAL(16,2);
	DEFINE v_porc_recargo                DECIMAL(16,2);
	DEFINE v_prima_aseg         		 DECIMAL(16,2);
	DEFINE _edad_tot                     INTEGER;

    LET v_descr_cia = sp_sis01(a_compania);
	LET v_prima_aseg = 0;

	SET ISOLATION TO DIRTY READ; 

	let v_no_poliza = sp_sis21(a_no_poliza);	

       SELECT no_documento,
       		  cod_contratante
         INTO v_no_documento,
         	  v_contratante
         FROM emipomae
        WHERE no_poliza = v_no_poliza;

       SELECT nombre
         INTO v_desc_nombre
         FROM cliclien
        WHERE cod_compania = a_compania
          AND cod_cliente  = v_contratante;

	   LET _cant = 0;	
	   LET _edad_tot = 0;
       FOREACH WITH HOLD
          SELECT no_unidad,
          		 desc_unidad,
				 cod_asegurado,
				 suma_asegurada
            INTO v_no_unidad,
            	 v_descripcion,
				 v_cod_aseg,
				 _suma_asegurada
            FROM emipouni
           WHERE no_poliza = v_no_poliza

           LET v_prima_anual = 0.00;
           LET v_porc_recargo = 0.00;

	       SELECT sum(prima_anual) 
	    	 INTO v_prima_anual
			 FROM emipocob
			WHERE no_poliza = v_no_poliza
			  AND no_unidad = v_no_unidad;

	       SELECT porc_recargo 
	    	 INTO v_porc_recargo
			 FROM emiunire
			WHERE no_poliza = v_no_poliza
			  AND no_unidad = v_no_unidad;

           LET v_porc_recargo = v_prima_anual * v_porc_recargo / 100;

	       SELECT nombre,
				  fecha_aniversario,
				  cedula	
	         INTO v_desc_asegurado,
				  _fecha_aniversario,
				  _cedula
	         FROM cliclien
	        WHERE cod_compania = a_compania
	          AND cod_cliente  = v_cod_aseg;

			IF _fecha_aniversario IS NOT NULL THEN
		        LET _edad = sp_sis78(_fecha_aniversario);
			  --	LET _edad_tot = today  - _fecha_aniversario;
			  --	LET _edad = _edad_tot;
			   {	IF MONTH(_fecha_aniversario) <= MONTH(TODAY) AND
				     DAY(_fecha_aniversario) < DAY(TODAY) THEN
					   LET _edad = YEAR(TODAY) - YEAR(_fecha_aniversario);	
				ELSE
					LET _edad = YEAR(TODAY) - YEAR(_fecha_aniversario) - 1;
				END IF 	}
			ELSE
				LET _edad = 0;
			END IF
		    LET _cant = _cant + 1;	

         RETURN v_no_documento,
         		v_desc_asegurado,
		        v_no_unidad,
				_suma_asegurada,
         		_fecha_aniversario,
         		_edad,
                v_desc_nombre,
				_cant,
                v_descr_cia,
				_cedula,
				v_prima_anual, 
				v_porc_recargo
				WITH RESUME;

       END FOREACH

END

END PROCEDURE;
