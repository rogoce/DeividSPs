-- Cartas de Perdida Total
-- Creado    : 03/01/2012 
-- Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec719;
--DROP TABLE tmp_perdida;
CREATE PROCEDURE "informix".sp_rec719(a_reclamo CHAR(10), a_compania CHAR(3) DEFAULT "001")
RETURNING   VARCHAR(100),		 --	v_asegurado, 
			DEC(16,2),			 --	v_suma_aseg,
			CHAR(30),			 --	v_motor, 
			CHAR(30),			 --	v_chasis,
			INT,				 --	v_ano_auto,
			VARCHAR(50),		 --	v_marca,	
			VARCHAR(50),		 --	v_modelo,
			CHAR(10),			 --	v_placa,
			CHAR(50),			 --	v_tipo,
	    	VARCHAR(50),	     -- _Nombre1
	    	CHAR(50),		     -- _Cargo1
			DEC(16,2),			 --	v_depresiacion  	
			DEC(16,2),			 --	v_deducible	   		
			DEC(16,2),			 --	v_salvamento		
			DEC(16,2),			 --	v_prima_pend		
			DEC(16,2),			 --	v_total		   		
			CHAR(100),			 -- v_a_favor_de		
			VARCHAR(100),			 -- v_corredor	   		
			DATE,				 -- v_date_siniestro	
			CHAR(50),			 -- _tipo_siniestro 	
			CHAR(20),			 -- v_numrecla_doc			
			VARCHAR(50),			 -- Acredor hipotecario
			CHAR(50),			 -- Color
			CHAR(8),			 -- v_user_added
			VARCHAR(50),		 -- Municipio
			VARCHAR(100),		 -- Comprador
			CHAR(30),			 -- Cedula Comprador
			CHAR(50),			 -- Ubicacion
			CHAR(2),		 -- TipoEvento
			CHAR(30);             -- Cedula

DEFINE v_Nombre1   	 		     CHAR(100);
DEFINE v_Cargo1   	 		     CHAR(100);	
DEFINE v_depresiacion  	 		 DEC(16,2);
DEFINE v_deducible	   	 		 DEC(16,2);
DEFINE v_salvamento	   	 		 DEC(16,2);
DEFINE v_prima_pend	   	 		 DEC(16,2);
DEFINE v_total		   	 		 DEC(16,2);
DEFINE v_a_favor_de	   	 		 VARCHAR(200);
DEFINE v_cod_agente	   	 		 CHAR(5);	
DEFINE v_corredor	   	 		 VARCHAR(100);
DEFINE v_date_siniestro  		 DATE;
DEFINE _tipo_siniestro   		 CHAR(50);
DEFINE v_numrecla_doc			 CHAR(20);	
DEFINE v_reclamo		 		 CHAR(10);
	
DEFINE v_contratante   	 		 CHAR(100);
DEFINE v_asegurado     	 		 CHAR(100);
DEFINE v_direccion	   	 		 CHAR(50);
DEFINE v_dir_cobro     	 		 CHAR(50);
DEFINE v_dir_postal    	 		 CHAR(20);
DEFINE v_telefono1     	 		 CHAR(10);
DEFINE v_telefono2	   	 		 CHAR(10);
DEFINE v_fax		   	 		 CHAR(10);
DEFINE v_email         	 		 CHAR(50);
DEFINE v_ramo		   	 		 CHAR(50);
DEFINE v_subramo	   	 		 CHAR(50);
DEFINE v_suscripcion   	 		 DATE;
DEFINE v_vigen_ini     	 		 DATE;
DEFINE v_vigen_fin	   	 		 DATE;
DEFINE v_suma_aseg	   	 		 DEC(16,2);
DEFINE v_unidad		   	 		 CHAR(5);
DEFINE v_poliza		   	 		 CHAR(20);
DEFINE v_factura	   	 		 CHAR(10);
DEFINE v_prima		   	 		 DEC(16,2);
DEFINE v_descuento	   	 		 DEC(16,2);
DEFINE v_recargo	   	 		 DEC(16,2);
DEFINE v_prima_neta    	 		 DEC(16,2);
DEFINE v_impuesto	   	 		 DEC(16,2);
DEFINE v_prima_bruta   	 		 DEC(16,2);
DEFINE v_motor         	 		 CHAR(30);
DEFINE v_chasis        	 		 CHAR(30);
DEFINE v_ano_auto      	 		 INT;
DEFINE v_marca		   	 		 CHAR(50);
DEFINE v_modelo        	 		 CHAR(50);
DEFINE v_placa         	 		 CHAR(10);
DEFINE v_tipo          	 		 CHAR(50);
DEFINE v_vig_ini_pol   	 		 DATE;
DEFINE v_vig_fin_pol   	 		 DATE;
DEFINE v_tipo_factura  	 		 CHAR(10);
DEFINE v_desc_factura  	 		 CHAR(50);
DEFINE v_fecha_letra   	 		 CHAR(30);
DEFINE v_dia           	 		 CHAR(2);
DEFINE v_ano           	 		 CHAR(4);
DEFINE v_cedula        	 		 CHAR(30);
DEFINE v_vig_i_end     	 		 DATE;
DEFINE v_vig_f_end	   	 		 DATE;
DEFINE v_nuevo         	 		 SMALLINT;

DEFINE _tipo_mov         		 INT;
DEFINE _no_poliza        		 CHAR(10);
DEFINE _cod_cliente	     		 CHAR(10);
DEFINE _cod_contratante  		 CHAR(10);
DEFINE _cod_marca        		 CHAR(5);
DEFINE _cod_modelo       		 CHAR(5);
DEFINE _cod_ramo         		 CHAR(3);
DEFINE _cod_subramo      		 CHAR(3);
DEFINE _cod_tipoauto     		 CHAR(3);
DEFINE _nueva_renov      		 CHAR(1);
DEFINE _cod_endomov      		 CHAR(3);
DEFINE _dia              		 CHAR(2);
DEFINE _ano              		 CHAR(4);
DEFINE _leasing          		 SMALLINT;
DEFINE _vigencia_fin_pol 		 DATE;
DEFINE _cod_acreedor			 CHAR(5);
DEFINE v_nombre_acreedor 		 VARCHAR(50);
DEFINE _cod_color				 CHAR(5);
DEFINE v_nombre_color			 CHAR(50);

DEFINE _cod_evento               CHAR(3);
DEFINE _perdida					 DEC(16,2);
DEFINE _deprec_anual			 DEC(16,2);
DEFINE _dias                     INTEGER;
DEFINE _windows_user             VARCHAR(20);
DEFINE _depre_mes			     DEC(16,5);
DEFINE _depre_dia			     DEC(16,5);
DEFINE v_user_added              CHAR(8);
DEFINE _code_distrito            CHAR(2);
DEFINE v_municipio               VARCHAR(50);
DEFINE v_comprador               VARCHAR(100);
DEFINE v_ced_comprador			 CHAR(30);
DEFINE v_ubicacion				 CHAR(50);
DEFINE _firma					 CHAR(8);
DEFINE _tipo_evento              CHAR(2);
DEFINE _cia_depto                char(3);
define _cargo                    char(3);
DEFINE _no_unidad                char(5);
define _cedula                   char(30);	


SET ISOLATION TO DIRTY READ;


--SET DEBUG FILE TO "sp_rec719.trc"; 
--TRACE ON; 

FOREACH	
 SELECT cod_asegurado,
        no_poliza,
        numrecla,
		no_motor,
		suma_asegurada,
		fecha_siniestro,
		cod_evento,
        no_unidad		
   INTO _cod_cliente,
        v_poliza,
		v_numrecla_doc,
		v_motor,
		v_suma_aseg,
		v_date_siniestro,
		_cod_evento,
        _no_unidad		
   FROM recrcmae
  WHERE no_reclamo = a_reclamo

   LET v_depresiacion = 0;
   LET v_deducible 	  = 0;
   LET v_salvamento	  = 0;
   LET v_prima_pend	  = 0;

 SELECT perdida,
        deprec_anual,
        deducible * -1,
		salvamento * -1,
		prima_pend * -1,
		dias,
		user_added,
		code_distrito,
		comprador,
		ced_comprador,
		ubicacion,
		municipio,
		firma
   INTO	_perdida,
        _deprec_anual,
		v_deducible,
		v_salvamento,
		v_prima_pend,
		_dias,
		v_user_added,
		_code_distrito,
		v_comprador,
		v_ced_comprador,
		v_ubicacion,
		v_municipio,
		_firma
   FROM recperdida
  WHERE no_reclamo = a_reclamo;
  

 IF _perdida IS NULL THEN
	LET _perdida = 0.00;
 END IF
 IF _deprec_anual IS NULL THEN
	LET _deprec_anual = 0.00;
 END IF
 IF v_deducible IS NULL THEN
	LET v_deducible = 0.00;
 END IF
 IF v_salvamento IS NULL THEN
	LET v_salvamento = 0.00;
 END IF
 IF v_prima_pend IS NULL THEN
	LET v_prima_pend = 0.00;
 END IF

 LET _cod_cliente = NULL;
 
 SELECT cod_asegurado
   INTO _cod_cliente
   FROM emipouni
  WHERE no_poliza = v_poliza
    AND no_unidad = _no_unidad;
	
 IF _cod_cliente IS NULL OR TRIM(_cod_cliente) = "" THEN
	 FOREACH     
		 SELECT a.cod_cliente
		   INTO _cod_cliente
		   FROM endeduni a, endedmae b
		  WHERE a.no_poliza = b.no_poliza
			AND a.no_endoso = b.no_endoso
			AND a.no_poliza = v_poliza
			AND a.no_unidad = _no_unidad
			--AND b.fecha_emision <= v_date_siniestro
		  ORDER BY b.no_endoso DESC
		EXIT FOREACH;		
	 END FOREACH	
 END IF 
	
 SELECT nombre,cedula
   INTO v_asegurado,_cedula
   FROM cliclien
  WHERE cod_cliente = _cod_cliente;

 {SELECT nombre
   INTO v_municipio
   FROM gendtto
  WHERE code_distrito = _code_distrito;
 }
	SELECT cod_marca,
	       no_chasis,
	       cod_modelo,
		   placa,
		   ano_auto,
		   cod_color
	  INTO _cod_marca,
	       v_chasis,
	       _cod_modelo,
		   v_placa,
		   v_ano_auto,
		   _cod_color
	  FROM emivehic
	 WHERE no_motor = v_motor;

    IF v_placa IS NULL THEN
		LET v_placa = "";
	END IF

    SELECT nombre
	  INTO v_marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

    SELECT nombre,
	       cod_tipoauto
	  INTO v_modelo,
	       _cod_tipoauto
	  FROM emimodel
	 WHERE cod_marca  = _cod_marca
	   AND cod_modelo = _cod_modelo;

    SELECT nombre
	  INTO v_tipo
	  FROM emitiaut
	 WHERE cod_tipoauto = _cod_tipoauto;

    SELECT nombre
	  INTO v_nombre_color
	  FROM emicolor
	 WHERE cod_color = _cod_color;

   LET v_nombre_acreedor = SP_REC100(a_reclamo);
   
   foreach
	select cod_agente
	  into v_cod_agente
      from emipoagt
	 where no_poliza = v_poliza

	SELECT nombre
	  INTO v_corredor
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;
	  exit foreach;

	end foreach

    select nombre, tipo_evento
	  into _tipo_siniestro, _tipo_evento
	  from recevent
	 where cod_evento = _cod_evento;

    {SELECT valor_parametro
	  INTO _windows_user
	  FROM inspaag
	 WHERE codigo_compania = a_compania
	   AND aplicacion = "REC"
	   AND version = "02"
	   AND codigo_parametro = "firma_perdida"; }

    SELECT cargo, cia_depto, descripcion     
	  INTO _cargo, _cia_depto, v_Nombre1           
	  FROM insuser
	 WHERE usuario = _firma;

    SELECT nombre
	  INTO v_Cargo1
	  FROM inscargo
	 WHERE cod_cargo = _cargo
	   AND cod_depto = _cia_depto;

-- A Favor de
   IF v_nombre_acreedor IS NULL OR TRIM(v_nombre_acreedor) = "" THEN
		LET v_a_favor_de = v_asegurado; 
   ELSE
		LET v_a_favor_de = TRIM(v_asegurado) || " Y " || TRIM(v_nombre_acreedor);
   END IF

-- Calculo

   LET _depre_mes = _deprec_anual / 12;
   LET _depre_dia = _depre_mes / 30;
   LET v_depresiacion = _depre_dia * _dias;

   LET v_total = v_suma_aseg + v_depresiacion + v_deducible + v_salvamento  + v_prima_pend ;

	RETURN trim(v_asegurado), 		--						CHAR(100),			 --	v_asegurado, 		--	v_asegurado,  
		   v_suma_aseg,			--						DEC(16,2),			 --	v_suma_aseg,		--	v_suma_aseg,  
		   v_motor,				--						CHAR(30),			 --	v_motor, 			--	v_motor,   
		   v_chasis, 			--						CHAR(30),			 --	v_chasis,			--	v_chasis,  
		   v_ano_auto, 			--						INT,				 --	v_ano_auto,			--	v_ano_auto, 
		   v_marca,				--						CHAR(50),			 --	v_marca,			--	v_marca,	  
	 	   v_modelo,			--						CHAR(50),			 --	v_modelo,			--	v_modelo, 
		   v_placa,				--						CHAR(10),			 --	v_placa,			--	v_placa, 
		   v_tipo,				--						CHAR(50),			 --	v_tipo,				--	v_tipo,  
		   v_Nombre1,   	 	-- 				    	CHAR(50),		     v-- _Nombre1			-- _Nombre1  
		   v_Cargo1,   	 		-- 				    	CHAR(50),		     v-- _Cargo1			-- _Cargo1 
		   v_depresiacion,  	--						DEC(16,2),			 --	v_depresiacion  	--	v_depresiacion  						 
		   v_deducible,	   	 	--						DEC(16,2),			 --	v_deducible	   		--	v_deducible	   						 
		   v_salvamento,	  	--						DEC(16,2),			 --	v_salvamento		--	v_salvamento						   	 
		   v_prima_pend,	  	--						DEC(16,2),			 --	v_prima_pend		--	v_prima_pend						   	 
		   v_total,		   	 	--						DEC(16,2),			 --	v_total		   		--	v_total		   						 
		   v_a_favor_de,	  	-- 						CHAR(100),			 -- v_a_favor_de		-- v_a_favor_de		 				   	 
		   TRIM(v_corredor),	   	 	-- 						CHAR(100),			 -- v_corredor	   		-- v_corredor	   					 
		   v_date_siniestro,   	-- 						DATE,				 -- v_date_siniestro	-- v_date_siniestro	 	                 
		   _tipo_siniestro,   	-- 						CHAR(100),			 v-- _tipo_siniestro 	-- _tipo_siniestro 	  				  
		   v_numrecla_doc,		-- 						CHAR(20),			 -- v_numrecla_doc		-- v_numrecla_doc								 
		   trim(v_nombre_acreedor),	--						CHAR(50);			 -- v_nombre_acreedor	-- Acredor hipotecario
		   v_nombre_color,		--						CHAR(50);			 -- v_nombre_color		-- Color
		   v_user_added,         --                     CHAR(8)				 v_user_added
		   v_municipio,
		   v_comprador,    
		   v_ced_comprador,
		   v_ubicacion,
		   _tipo_evento,
           _cedula		   
		   WITH RESUME;			--						

END FOREACH;



END PROCEDURE 



