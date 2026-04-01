 DROP procedure sp_pro73_1;

 CREATE procedure "informix".sp_pro73_1(a_compania CHAR(3),a_agencia CHAR(3),a_no_poliza CHAR(20))
  RETURNING CHAR(20) as no_documento, 	 --POLIZA
			CHAR(100) as asegurado,	--ASEGURADO
			CHAR(5) as certificado,	--CERTIFICADO
			CHAR(50) as tipo_asegurado,  	
			DEC as suma_asegurada,	--SUMA ASEGURADA
			DATE as fecha_nacimiento,	--FECHA NACIMIENTO
			SMALLINT as edad,	--EDAD
			CHAR(100) as contratante,	--CONTRATANTE
			SMALLINT as cantidad,	--ENUMERAR UNIDADES
			CHAR(50) as v_descr_cia,  	--CIA
			CHAR(30) as cedula,	--CEDULA
			DECIMAL(16,2) as prima_anual,	
			DECIMAL(16,2) as recargo,	
			char(5) as cod_producto,	
			char(50) as nom_producto,	
			char(3) as tipo_pago,
			char(2) as tiene_asistencia,
			DECIMAL(16,2) as prima_asist_vial;	
 
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
	define _cod_producto                 char(5);
	define _n_producto                   char(50);
	define _tipo_pago                    char(3);  
	define _existe	              		smallint;
	define _tipo_asegurado   		 CHAR(50);
	DEFINE _no_unidad_principal      CHAR(5);
	DEFINE _cod_cli_principal	     CHAR(10);
	DEFINE _nombre_principal         CHAR(100);	
	DEFINE v_prima_asist_viaje			DECIMAL(16,2);
	DEFINE v_cnt_asist_viaje         SMALLINT;


    LET v_descr_cia = sp_sis01(a_compania);
	LET v_prima_aseg = 0;
	SET ISOLATION TO DIRTY READ; 
	let v_no_poliza = sp_sis21(a_no_poliza);
	let _tipo_pago = "";
	

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
				 suma_asegurada,
				 cod_producto
            INTO v_no_unidad,
            	 v_descripcion,
				 v_cod_aseg,
				 _suma_asegurada,
				 _cod_producto
            FROM emipouni
           WHERE no_poliza = v_no_poliza
		     and activo = 1

           LET v_prima_anual = 0.00;
           LET v_porc_recargo = 0.00;
		   LET v_prima_asist_viaje = 0.00;
		   LET v_cnt_asist_viaje = 0;

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
			  
		   SELECT COUNT(*)            -- Caso 36318 - 11-01-2021 -- Amado Perez
		     INTO v_cnt_asist_viaje
			 FROM emipocob
			WHERE no_poliza = v_no_poliza
			  AND no_unidad = v_no_unidad
			  AND cod_cobertura = '01636';		
     
		   IF v_cnt_asist_viaje IS NULL THEN
				LET v_cnt_asist_viaje = 0;
           END IF		   
		   
		   IF v_cnt_asist_viaje = 1 THEN
			   SELECT sum(prima_anual) 
				 INTO v_prima_asist_viaje
				 FROM emipocob
				WHERE no_poliza = v_no_poliza
				  AND no_unidad = v_no_unidad
				  AND cod_cobertura = '01636';		  		   
		   END IF
		   
		   IF v_prima_asist_viaje IS NULL THEN
				LET v_prima_asist_viaje = 0.00;
		   END IF

           LET v_porc_recargo = v_prima_anual * v_porc_recargo / 100;

	       SELECT nombre,
				  fecha_aniversario,
				  cedula,
				  decode(tipo_pago,1,"ACH",2,"CHK")
	         INTO v_desc_asegurado,
				  _fecha_aniversario,
				  _cedula,
				  _tipo_pago
	         FROM cliclien
	        WHERE cod_cliente  = v_cod_aseg;

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
		    
			let _n_producto = null;

		    select nombre
		      into _n_producto
			  from prdprod
			 where cod_producto = _cod_producto;
			 
			let _existe = 0;
			select count(*)	
			  INTO _existe
			   from uniprdp
			  WHERE no_poliza = v_no_poliza
				--AND no_endoso = a_endoso
				AND no_unidad_dp = v_no_unidad;
				
				if _existe is null then
					let _existe = 0;
				end if
				 if _existe > 0 then
					let _tipo_asegurado = 'DEPENDIENTE';
				else
					let _tipo_asegurado = 'PRINCIPAL';
				end if	

				if _tipo_asegurado = 'DEPENDIENTE' then 
						select no_unidad	
						  INTO _no_unidad_principal
						   from uniprdp
						  WHERE no_poliza = v_no_poliza
							--AND no_endoso = a_endoso
							AND no_unidad_dp = v_no_unidad;
							let v_no_unidad = _no_unidad_principal;
				end if			
		      	
		 RETURN v_no_documento,
				v_desc_asegurado,
				v_no_unidad,
				_tipo_asegurado,
				_suma_asegurada,
				_fecha_aniversario,
				_edad,
				 v_desc_nombre,
				_cant,
				 v_descr_cia,
				_cedula,
				v_prima_anual, 
				v_porc_recargo,
				_cod_producto,
				_n_producto,
				_tipo_pago,
				case (v_cnt_asist_viaje = 1, 'SI', 'NO'),
				v_prima_asist_viaje
				WITH RESUME;

       END FOREACH

END

END PROCEDURE;
