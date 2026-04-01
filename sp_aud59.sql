-- Procedimiento PERDIDAS TOTALES ENVIADO A AMADO PEREZ EL DIA DE AYER,  ESTE VEZ SACANDO SOLO LAS PERDIDAS TOTALES PENDIENTES A LA FECHA DE HOY
-- solo perdi_total = 1 del procedimiento sp_rec252a tabla:tmp_26612
-- Creado : 12/02/2020 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_aud59;
CREATE PROCEDURE informix.sp_aud59()
RETURNING  CHAR(20) as poliza,
           CHAR(5) as unidad,
   		   DATE as vigencia_inic,
		   DATE as vigencia_final,
		   DATE as fecha_suscripcion,
		   CHAR(10) as cod_asegurado,
		   VARCHAR(100) as asegurado,
		   DEC(16,2) as suma_asegurada,
		   CHAR(5) as cod_agente,
		   VARCHAR(50) as agente,
		   DEC(16,2) as prima,
		   SMALLINT AS ano_auto,
		   VARCHAR(50) as marca,
		   VARCHAR(50) as modelo,
		   VARCHAR(50) as color,
		   VARCHAR(50) as referencia,
		   VARCHAR(50) as barrio,
		   CHAR(5) as cod_producto,
		   VARCHAR(50) as producto,
		   VARCHAR(50) as cobertura,
		   VARCHAR(50) as deducible,
		   VARCHAR(50) as desc_limite1,
		   DEC(16,2) as limite_1,
		   VARCHAR(50) as desc_limite2,
		   DEC(16,2) as limite_2,
		   DEC(16,2) as co_pago;			

				   		
DEFINE _cod_asegurado  CHAR(10);
DEFINE _no_documento   CHAR(20);
DEFINE _no_poliza	   CHAR(10); 	
DEFINE _cod_ramo       CHAR(3);
DEFINE _cod_subramo    CHAR(3);
DEFINE _cod_cobertura CHAR(5);
DEFINE _cobertura       VARCHAR(50);
DEFINE _vigencia_inic   DATE;
DEFINE _vigencia_final  DATE;
DEFINE _fecha_suscripcion DATE;
DEFINE _sucursal_origen CHAR(3);
DEFINE _cod_agente      CHAR(5);
DEFINE _corredor        VARCHAR(50);
DEFINE _asegurado       VARCHAR(100);

DEFINE _no_motor        CHAR(30);
DEFINE _placa           CHAR(10);							
DEFINE _marca			VARCHAR(50);
DEFINE _modelo		    VARCHAR(50);
DEFINE _cod_marca       CHAR(5);
DEFINE _cod_modelo      CHAR(5);
DEFINE _cod_color       CHAR(5);
DEFINE _color		    VARCHAR(50);
DEFINE _no_unidad		char(5);
DEFINE _ano_auto        SMALLINT;

DEFINE _ramo_sis        SMALLINT;
DEFINE _suma_asegurada  DEC(16,2);
DEFINE _prima_suscrita  DEC(16,2);
DEFINE _cod_manzana     CHAR(15);
DEFINE _referencia      VARCHAR(50);
DEFINE _cod_barrio      CHAR(4);   
DEFINE _cod_provincia   CHAR(2);   
DEFINE _cod_distrito    CHAR(3);   
DEFINE _cod_correg      CHAR(3); 
DEFINE _barrio	        VARCHAR(50);
DEFINE _cod_producto    CHAR(5);
DEFINE _producto		VARCHAR(50);	   
DEFINE _limite_1        DEC(16,2);
DEFINE _limite_2        DEC(16,2);
DEFINE _deducible       VARCHAR(50);
DEFINE _desc_limite1    VARCHAR(50);
DEFINE _desc_limite2    VARCHAR(50);
DEFINE _co_pago         DEC(16,2);

 --SET DEBUG FILE TO "sp_rec307.trc";      
 --TRACE ON;   

set isolation to dirty read;

FOREACH
	SELECT no_poliza,
	       no_documento,
	       vigencia_inic,
	       vigencia_final,
		   fecha_suscripcion,
	       sucursal_origen,
		   cod_ramo,
		   cod_subramo,
		   cod_contratante
      INTO _no_poliza,
	       _no_documento,
	       _vigencia_inic,
	       _vigencia_final,
		   _fecha_suscripcion,
	       _sucursal_origen,
		   _cod_ramo,
		   _cod_subramo,
		   _cod_asegurado
      FROM emipomae
     WHERE sucursal_origen = '006'
       and fecha_suscripcion >= '01/12/2019'
       and fecha_suscripcion <= '29/02/2020' 
	   and nueva_renov = 'N'
	   and actualizado = 1
	   
	SELECT ramo_sis
	  INTO _ramo_sis
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;
	
	FOREACH
		SELECT cod_agente
		  INTO _cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

   SELECT nombre
     INTO _corredor 
	 FROM agtagent
	WHERE cod_agente = _cod_agente;
	
  SELECT nombre 
    INTO _asegurado
	FROM cliclien
   WHERE cod_cliente = _cod_asegurado;

	FOREACH
		select no_unidad,
		       cod_producto,
			   suma_asegurada,
			   prima_suscrita,
			   cod_manzana
		  into _no_unidad,
		       _cod_producto,
			   _suma_asegurada,
			   _prima_suscrita,
			   _cod_manzana
          from emipouni
		 where no_poliza = _no_poliza

		let _no_motor   = null;
		let _cod_marca  = null;
		let _cod_modelo = null;
		let _cod_color = null;
		let _ano_auto = null;

		let _marca    = null;
		let _modelo   = null;
		let _color    = null;
		let _ano_auto = 0;
		let _cod_cobertura = null;
		let _referencia = null;
		let _cod_barrio = null; 
		let _cod_provincia = null;   
		let _cod_distrito = null;   
		let _cod_correg	= null;	
		let _barrio	= null;	

		if _ramo_sis = 1 then		
			select no_motor
			  into _no_motor
			  from emiauto
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
			   
			 select cod_marca,
					cod_modelo,
					cod_color,
					ano_auto
			   into _cod_marca,
					_cod_modelo,
					_cod_color,
					_ano_auto	
			   from emivehic
			  where no_motor = _no_motor;
			 			
			if _ano_auto is null then
				let _ano_auto = 0;
			end if	

			if _cod_marca is null then
				let _cod_marca = "";
			else
				select nombre
				  into _marca
				  from emimarca
				 where cod_marca = _cod_marca;
			end if

			if _cod_modelo is null then
				let _cod_modelo = "";
			else
				select nombre
				  into _modelo
				  from emimodel
				 where cod_marca  = _cod_marca
				   and cod_modelo = _cod_modelo;
			end if
			
			if _cod_color is null then
				let _cod_color = "";
			else
				select nombre
				  into _color
				  from emicolor
				 where cod_color  = _cod_color;
			end if	
		elif _ramo_sis in (2, 8) then	
			select referencia,
                   cod_barrio,   
                   cod_provincia,   
                   cod_distrito,   
                   cod_correg
			  into _referencia,
                   _cod_barrio,   
                   _cod_provincia,   
                   _cod_distrito,   
                   _cod_correg
			  from emiman05
			 where cod_manzana = _cod_manzana;
			 
			select nombre
			  into _barrio
			  from emiman04
			 where cod_provincia = _cod_provincia   
         	   and cod_distrito = _cod_distrito   
			   and cod_correg = _cod_correg 
         	   and cod_barrio = _cod_barrio;  
			 			 
		elif _ramo_sis = 99 then
			if _cod_ramo in ('013','014') then
				select referencia,
					   cod_barrio,   
					   cod_provincia,   
					   cod_distrito,   
					   cod_correg
				  into _referencia,
					   _cod_barrio,   
					   _cod_provincia,   
					   _cod_distrito,   
					   _cod_correg
				  from emiman05
				 where cod_manzana = _cod_manzana;
				 
				select nombre
				  into _barrio
				  from emiman04
				 where cod_provincia = _cod_provincia   
				   and cod_distrito = _cod_distrito   
				   and cod_correg = _cod_correg 
				   and cod_barrio = _cod_barrio;  				
			end if
		end if
		
	SELECT nombre
	  INTO _producto
	  FROM prdprod
	 WHERE cod_producto = _cod_producto;
		
	FOREACH
		SELECT cod_cobertura,
		       limite_1,
			   limite_2,
			   deducible,
			   desc_limite1,
			   desc_limite2
		  INTO _cod_cobertura,
		       _limite_1,
			   _limite_2,
			   _deducible,
			   _desc_limite1,
			   _desc_limite2
		  FROM emipocob
		 WHERE no_poliza = _no_poliza
		   and no_unidad = _no_unidad
	
		SELECT nombre
		  INTO _cobertura
		  FROM prdcober
		 WHERE cod_cobertura = _cod_cobertura;
   
        SELECT co_pago
		  INTO _co_pago
		  FROM prdcobpd
		 WHERE cod_producto = _cod_producto
		   AND cod_cobertura = _cod_cobertura;
 
		RETURN _no_documento,
			   _no_unidad,
			   _vigencia_inic,
			   _vigencia_final,
			   _fecha_suscripcion,
			   _cod_asegurado,
			   _asegurado,
			   _suma_asegurada,
			   _cod_agente,
			   _corredor,
			   _prima_suscrita,
			   _ano_auto,
			   _marca,
			   _modelo,
			   _color,
			   _referencia,
			   _barrio,
			   _cod_producto,
			   _producto,
			   _cobertura,
			   _deducible,
			   _desc_limite1,
			   _limite_1,
			   _desc_limite2,
			   _limite_2,
			   _co_pago
		WITH RESUME;
	END FOREACH
 END FOREACH
END FOREACH

END PROCEDURE;