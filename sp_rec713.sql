-- Reporte Detalle de Siniestros incurridos de MULTIRIESGO 
-- Subramo   : Comercial, Residencial y Zona Libre
-- Cobertura : incendio, vendaval, Impacto de Vehículo, Inundación/daños por agua, robo por forzamiento, asalto, etc
-- Creado    : 29/06/2010 - Autor:  Henry Giron
-- execute procedure sp_rec713("2010-01","2010-06")

DROP procedure sp_rec713;
CREATE procedure sp_rec713(a_periodo1 char(7), a_periodo2 char(7))
RETURNING CHAR(50),CHAR(50),CHAR(45),CHAR(20),CHAR(50),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DATE,DATE,CHAR(10),CHAR(3),CHAR(3),CHAR(5);

BEGIN 

    DEFINE _no_poliza                   	  CHAR(10);
	DEFINE _cant							  INTEGER;
	DEFINE _incurrido_total                   dec(16,2);
	DEFINE _pagado_total                      dec(16,2);
	DEFINE _reserva_total                     dec(16,2);
	DEFINE _prima_suscrita                    dec(16,2);
	DEFINE _prima_cobrada                     dec(16,2);
    DEFINE _no_documento                	  CHAR(20);
    DEFINE _vigencia_inic,_vigencia_final     DATE;
    DEFINE _cod_ramo                          CHAR(3);
    DEFINE _cod_subramo                       CHAR(3);
    DEFINE _contratante  			          CHAR(10);
    DEFINE _desc_ramo                         CHAR(50);
    DEFINE _desc_subramo                      CHAR(50);
    DEFINE _cliente 	               		  CHAR(45);
	DEFINE _cod_cobertura                     CHAR(5);
	DEFINE _desc_cobertura                    CHAR(50);
	DEFINE _limite_1    	                  dec(16,2);
	DEFINE _limite_2	                      dec(16,2);
	DEFINE v_filtros                          CHAR(255);
	DEFINE _no_doc	               	  		  CHAR(20);

SET ISOLATION TO DIRTY READ; 	

CREATE TEMP TABLE tmp_rec713(
	cod_ramo 		   CHAR(3),				
	desc_ramo		   CHAR(50),				
	no_documento	   CHAR(20),					
	cliente  		   CHAR(45),				
	contratante	   	   CHAR(10),				
	vigencia_inic	   DATE,				
	vigencia_final     DATE,				
	prima_suscrita	   DECIMAL(16,2),				
	incurrido_total    DECIMAL(16,2),				
	pagado_total	   DECIMAL(16,2),				
	reserva_total	   DECIMAL(16,2),				
	desc_cobertura	   CHAR(50),
	limite_1		   DECIMAL(16,2),									
	limite_2		   DECIMAL(16,2),
	cod_subramo		   CHAR(3),				
	desc_subramo	   CHAR(50),
	cod_cobertura	   CHAR(5),										
    PRIMARY KEY(cod_ramo,cod_subramo,no_documento,cod_cobertura)) WITH NO LOG;

let v_filtros = sp_rec01("001","001",a_periodo1,a_periodo2,"*","*","003;","*","*","*","*","*");

FOREACH
	SELECT distinct no_poliza
	  INTO _no_poliza
	  FROM tmp_sinis
	 WHERE seleccionado = 1

	   LET _cant = 0;

	SELECT count(*) 
	  INTO _cant
	  FROM emipomae  
	 WHERE cod_ramo    = "003"
	   AND actualizado = 1
	   AND no_poliza   =  _no_poliza
	   AND cod_subramo in ("002","001","005");

       IF _cant = 0 THEN
			CONTINUE FOREACH;
	   END IF

	   SELECT  SUM(incurrido_bruto),			 
			   SUM(pagado_bruto),
			   SUM(reserva_bruto) 	
		  INTO  _incurrido_total,
			   _pagado_total,
			   _reserva_total
		  FROM tmp_sinis
		 where no_poliza = _no_poliza;

	    SELECT no_documento
		  INTO _no_documento
		  FROM emipomae
		 WHERE no_poliza   = _no_poliza
		   AND actualizado = 1;	

		   let _no_poliza = sp_sis21(_no_documento);

	    SELECT vigencia_inic,
		       vigencia_final,
			   cod_ramo,
			   cod_subramo,
			   prima_suscrita,
			   cod_contratante
		  INTO _vigencia_inic,
		       _vigencia_final,
			   _cod_ramo,
			   _cod_subramo,
			   _prima_suscrita,
			   _contratante
		  FROM emipomae
		 WHERE no_poliza   = _no_poliza
		   AND actualizado = 1;			   

	       SELECT nombre
	         INTO _desc_ramo
	         FROM prdramo 
	        WHERE cod_ramo  = _cod_ramo;

	       SELECT nombre
	         INTO _desc_subramo
	         FROM prdsubra 
	        WHERE cod_ramo    = _cod_ramo
	          AND cod_subramo = _cod_subramo;

	       SELECT nombre
	         INTO _cliente
	         FROM cliclien
	        WHERE cod_cliente = _contratante;

	       FOREACH
		   	SELECT cod_cobertura,
				   limite_1,
				   limite_2
			  INTO _cod_cobertura,
				   _limite_1,
				   _limite_2
			  FROM emipocob
			 WHERE no_poliza = _no_poliza
--			   AND cod_cobertura in ('00157','00182','00184','00125','00130','00131','00132')

			        SELECT nombre
				      INTO _desc_cobertura
					  FROM prdcober
					 WHERE cod_cobertura = _cod_cobertura;

					 BEGIN
						ON EXCEPTION IN(-239)
							UPDATE tmp_rec713
							   SET  incurrido_total = incurrido_total + _incurrido_total, 
							        pagado_total    = pagado_total    + _pagado_total, 
							        reserva_total   = reserva_total   + _reserva_total
							 WHERE no_documento     = _no_documento  
							   AND cod_ramo		    = _cod_ramo
							   AND cod_subramo	    = _cod_subramo
							   AND cod_cobertura    = _cod_cobertura  ; 

						END EXCEPTION 	


						INSERT INTO tmp_rec713(
								cod_ramo,
								desc_ramo,
								no_documento,
								cliente,
								contratante,
								vigencia_inic,
								vigencia_final,
								prima_suscrita,	
								incurrido_total, 
								pagado_total,	
								reserva_total,	
								desc_cobertura,	
							    limite_1,
							    limite_2,
								cod_subramo,				
								desc_subramo,
								cod_cobertura
							    )
					     VALUES (
								_cod_ramo, 
								_desc_ramo, 
								_no_documento,
								_cliente, 
								_contratante, 
								_vigencia_inic, 
								_vigencia_final,
								_prima_suscrita, 
								_incurrido_total, 
								_pagado_total, 
								_reserva_total, 
								_desc_cobertura,
								_limite_1,
							    _limite_2,
								_cod_subramo,
							    _desc_subramo,
							    _cod_cobertura );
					END
		   END FOREACH
END FOREACH

let _no_doc = "";

FOREACH
	 SELECT desc_ramo,
		    desc_subramo,
	 		cliente,
	 		no_documento,
	 		desc_cobertura,	
	 		limite_1,
	 		limite_2,  
	 		prima_suscrita,	
	 		incurrido_total,
	 		vigencia_inic,
	 		vigencia_final, 
	 		pagado_total,	
	 		reserva_total,	
	 		contratante,	 			 		
			cod_ramo,
			cod_subramo,
			cod_cobertura
	   INTO _desc_ramo, 
			_desc_subramo,
	 		_cliente,
	 		_no_documento,
	 		_desc_cobertura,
	 		_limite_1,
	 		_limite_2,
	 		_prima_suscrita, 
	 		_incurrido_total, 
	 		_vigencia_inic, 
	 		_vigencia_final,
	 		_pagado_total, 
	 		_reserva_total, 
	 		_contratante,  
			_cod_ramo, 	 		
			_cod_subramo,
			_cod_cobertura	 		 	 
       FROM tmp_rec713	
	  ORDER BY 1,2,3,4,5

-- Necesitamos un Informe de Siniestralidad (Siniestros incurridos, o sea Pagos y por pagar) 
-- específicamente para las pólizas MULTIRIESGO, divididas por los subramos (comercial Residencial y Zona Libre, 
-- que detalle las coberturas por separado (incendio, vendaval, Impacto de Vehículo, Inundación/daños por agua, robo por forzamiento, asalto, etc).

-- nombre del cliente, No de poliza, limite de la cobertura de Incendio, prima suscrita,  
-- vigencia de la poliza Siniestros incurridos por cada  una de las coberturas de la poliza

			if _no_doc = _no_documento then
				let _prima_suscrita = 0;
				let _incurrido_total = 0;
				let _pagado_total = 0;
			else
				let _no_doc = _no_documento;
			end if


		RETURN _desc_ramo, 
			   _desc_subramo,
			   _cliente,
			   _no_documento,
			   _desc_cobertura,
			   _limite_1,
			   _limite_2,
			   _prima_suscrita,  
			   _incurrido_total, 
			   _pagado_total,  
			   _vigencia_inic, 
			   _vigencia_final,
		 	   _contratante,  
			   _cod_ramo, 	 		
			   _cod_subramo,
			   _cod_cobertura	 	
		  WITH RESUME;


END FOREACH		

DROP TABLE tmp_sinis;
DROP TABLE tmp_rec713;

END
END PROCEDURE;	