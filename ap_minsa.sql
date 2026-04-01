-- Procedimiento que verifica si cambia el evento de un reclamo desde el paso de digitalizacion en WF

-- Creado    : 04/04/2014 - Autor: Amado Perez  

drop procedure ap_minsa;

create procedure ap_minsa() 
returning CHAR(10), CHAR(20), CHAR(20), VARCHAR(100), VARCHAR(100), VARCHAR(50), date, date, smallint, varchar(50), varchar(50), smallint, char(10), varchar(50), varchar(50), dec(16,2);

define _no_reclamo              CHAR(10);
define _no_tramite              CHAR(10);
define _numrecla                CHAR(20);
define _no_documento			char(20);
define _asegurado               VARCHAR(100);
define _conductor               VARCHAR(100);
define _evento                  VARCHAR(50);
define _fecha_siniestro			date;
define _fecha_reclamo			date;
define _perd_total              smallint;
define _no_motor 			    char(30);
define _ajustador               varchar(50);
define _estatus_audiencia       smallint;
define _cod_marca				char(5);
define _cod_modelo				char(5);
define _ano_auto			   	smallint;
define _placa					char(10);
define _marca					varchar(50);
define _modelo					varchar(50);
define _estat_aud            	varchar(50);
define _porc_partic_coas	    DECIMAL(7,4);  -- % coaseguro
define _cod_coasegur            CHAR(3);      
define _reserva           		dec(16,2);
define _pagado           		dec(16,2);
define _monto_tran         		dec(16,2);
define _recuperos               dec(16,2);
define _ded                     dec(16,2);
define _recuperos_salida        dec(16,2);
define _cod_tipotran            char(3);
define _tipo_transaccion        smallint;
define _sumar_incurrido         dec(16,2);
define _incurrido_bruto      	dec(16,2);
define _incurrido       		dec(16,2);
define _variacion              	dec(16,2);
define _pagado_salida   		dec(16,2);

LET _cod_coasegur     = sp_sis02('001', '001');



--return 0, "Actualizacion Exitosa";
--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;


set isolation to dirty read;

foreach

  SELECT recrcmae.no_reclamo,
         recrcmae.no_tramite,   
         recrcmae.numrecla,   
         recrcmae.no_documento,   
         cliclien_a.nombre,   
         cliclien_b.nombre,   
         recevent.nombre,   
         recrcmae.fecha_siniestro,   
         recrcmae.fecha_reclamo,   
         recrcmae.perd_total,   
         recrcmae.no_motor,   
         recajust.nombre,   
         recrcmae.estatus_audiencia
    INTO _no_reclamo,
         _no_tramite,        
    	 _numrecla,         
    	 _no_documento,		
    	 _asegurado,        
    	 _conductor,        
    	 _evento,           
    	 _fecha_siniestro,		
    	 _fecha_reclamo,		
    	 _perd_total,       
    	 _no_motor, 			
    	 _ajustador,        
    	 _estatus_audiencia
    FROM recrcmae,   
         cliclien cliclien_a,   
         cliclien cliclien_b,   
         recevent,   
         recajust  
   WHERE ( recrcmae.cod_asegurado = cliclien_a.cod_cliente ) and  
         ( recrcmae.cod_conductor = cliclien_b.cod_cliente ) and  
         ( recevent.cod_evento = recrcmae.cod_evento ) and  
         ( recajust.cod_ajustador = recrcmae.ajust_interno ) and  
         ( ( recrcmae.no_documento = '0210-01288-01' ) ) 
 ORDER BY recrcmae.no_tramite   

  SELECT cod_marca,
         cod_modelo,
		 ano_auto,
		 placa
    INTO _cod_marca,
		 _cod_modelo,
		 _ano_auto,
		 _placa
	FROM emivehic
   WHERE no_motor = _no_motor;

  SELECT nombre
    INTO _marca
	FROM emimarca
   WHERE cod_marca = _cod_marca;

  SELECT nombre
    INTO _modelo
	FROM emimodel
   WHERE cod_marca = _cod_marca
     AND cod_modelo = _cod_modelo;

	IF _estatus_audiencia = 0 THEN
	   LET _estat_aud = "Perdido";
	ELIF _estatus_audiencia = 1 THEN
	   LET _estat_aud = "Ganado";
	ELIF _estatus_audiencia = 2 THEN
	   LET _estat_aud = "Por definir";
	ELIF _estatus_audiencia = 3 THEN
	   LET _estat_aud = "Proceso Penal";
	ELIF _estatus_audiencia = 4 THEN
	   LET _estat_aud = "Proceso Civil";
	ELIF _estatus_audiencia = 5 THEN
	   LET _estat_aud = "Apelacion";
	ELIF _estatus_audiencia = 6 THEN
	   LET _estat_aud = "Apelacion";
	ELIF _estatus_audiencia = 7 THEN
	   LET _estat_aud = "FUT - Ganado";
	ELIF _estatus_audiencia = 8 THEN
	   LET _estat_aud = "FUT - Responsable";
	ELSE
	   LET _estat_aud = NULL;
	END IF

-- Porcentaje de Coaseguro

	SELECT porc_partic_coas
	 INTO  _porc_partic_coas
	 FROM  reccoas
	WHERE  no_reclamo = _no_reclamo
	  AND  cod_coasegur = _cod_coasegur; 

	IF _porc_partic_coas IS NULL THEN
		LET _porc_partic_coas = 0;
	END IF

-- Calculos
	
	LET _reserva   		  = 0.00;
	LET _pagado    		  = 0.00;
	LET _recuperos 	 	  = 0.00;
	LET _ded     	 	  = 0.00;
	LET _incurrido 		  = 0.00;
	LET _recuperos_salida = 0.00;

	LET _incurrido_bruto  = 0.00;
	let _sumar_incurrido  = 0.00;

    foreach
		SELECT monto,
		   	   variacion,
			   cod_tipotran
		  INTO _monto_tran,
		       _variacion,
			   _cod_tipotran
		  FROM rectrmae
		 WHERE no_reclamo = _no_reclamo

	-- Nombre de las Transacciones
		SELECT tipo_transaccion
		 INTO  _tipo_transaccion
		FROM   rectitra
		WHERE  cod_tipotran = _cod_tipotran;

		LET _reserva = _variacion + _reserva;

		{IF _cerrar_rec = 1 AND _reserva < 0 THEN
			LET _reserva = 0;
		END IF}

		IF _tipo_transaccion = 4 THEN
			LET _pagado  = _pagado + _monto_tran;
		ELSE
			LET _pagado_salida = 0.00;
		END IF

		IF _tipo_transaccion = 5 OR   --salvamento
		   _tipo_transaccion = 6 THEN --recupero
			LET _recuperos = (_monto_tran  * -1) + _recuperos;
		ELIF _tipo_transaccion = 7 THEN	--ded
			LET _ded = (_monto_tran  * -1) + _ded;
		ELSE
			LET _recuperos_salida = 0.00;
		END IF

		LET _incurrido = _reserva + _pagado - (_recuperos + _ded);
  --		let _sumar_incurrido = _sumar_incurrido + _incurrido;
	end foreach

	let _incurrido_bruto = _incurrido * _porc_partic_coas / 100;

	return _no_tramite,        
		   _numrecla,          
		   _no_documento,		
		   _asegurado,        
		   _conductor,         
		   _evento,            
		   _fecha_siniestro,		
		   _fecha_reclamo,		
		   _perd_total,        
		   _marca,				
		   _modelo,				
		   _ano_auto,			
		   _placa,				
		   _ajustador,         
		   _estat_aud,         
		   _incurrido_bruto with resume;
end foreach    


end procedure