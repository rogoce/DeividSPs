-- MOTOR DE GENERACION Y CORRECCION DE DATA DE TTCORP_INFORMIX
--
-- Creado    : 09/07/2014 - Autor: Angel Tello
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_ttc08;

create procedure "informix".sp_ttc08(a_periodo char(7) ,a_modulo smallint)
			returning   integer,
						char(255);

define _ano				char(4);
define _mes				char(2);
define _cod_pagador		char(10);
define _fecha_char		char(30);
define _e_mail			char(50);
define _nombre_aseg		char(100);
define _periodo_ex		char(7);
define _nombre_cli		char(100);
define _cod_cliente		char(10);
define _no_poliza       char(10);
define _no_documento    char(20);
define _no_documento1   char(20);
define _mensaje  		char(255);
define _tarjeta_cre	    char(20);
define _id_mov_tecnico  integer;
define _id_mov_reas  	integer;
define _id_reas_caract  integer;
define _reg				integer;
define _reg1			integer;
define _reg2			integer;
define _reg3			integer;
define _reg1_min		integer;
define _reg2_min		integer;
define _reg3_min		integer;
define _reg1_max		integer;
define _reg2_max		integer;
define _reg3_max		integer;
define _v1_data			integer;
define _v2_data			integer;
define _par_periodo_act char(7);


set isolation to dirty read;

--SET DEBUG FILE TO "sp_ttc08.trc";
--trace on;

let _reg = 0;
let _mensaje = 'actualizacion exitosa';

let _ano	= a_periodo[1,4];
let _mes	= a_periodo[6,7];

--Contadores de PARCONT
IF a_modulo = 1 OR a_modulo = 2 THEN  	--1 = produccion  2 = cobros
	select valor_parametro
	  into _id_mov_tecnico
	  from parcont
	 where cod_parametro = 'ttcorp_id1_pri';

	select valor_parametro
	  into _id_mov_reas
	  from parcont
	 where cod_parametro = 'ttcorp_id2_pri';

	 select valor_parametro
	  into _id_reas_caract
	  from parcont
     where cod_parametro = 'ttcorp_id3_pri';
	 
	select par_periodo_act
      into _par_periodo_act
      from parparam;

    update emirepar
       set periodo_verifica = _par_periodo_act;
	   
ELIF a_modulo = 3 OR a_modulo = 4 THEN  	-- 3 = SIN PAGADOS 4 = SIN PENDIENTES

	select valor_parametro
	  into _id_mov_tecnico
	  from parcont
	 where cod_parametro = 'ttcorp_id1_sin';

	select valor_parametro
	  into _id_mov_reas
	  from parcont
	 where cod_parametro = 'ttcorp_id2_sin';

	 select valor_parametro
	  into _id_reas_caract
	  from parcont
     where cod_parametro = 'ttcorp_id3_sin';
END IF

--PROCESO DE VERIFICACION
	IF  a_modulo = 1 THEN 	--PRODUCCION PRIMAS
	
		--PRIMER NIVEL
		SELECT COUNT(*),
			   MIN(id_mov_tecnico_anc),
               MAX(id_mov_tecnico_anc)
		 INTO  _reg1,
			   _reg1_min,
			   _reg1_max 
		  FROM deivid_ttcorp:movim_tec_pri_ttco
		 WHERE NUM_ANO = _ano
		   AND NUM_MES = _mes 
		   AND COD_SITUACION = 5;

		-- SEGUNDO NIVEL
		 SELECT COUNT(*),
		   		MIN(b.id_mov_reas_ancon),
                MAX(b.id_mov_reas_ancon)
		   INTO _reg2,
				_reg2_min,
				_reg2_max
		   FROM deivid_ttcorp:movim_tec_pri_ttco a, deivid_ttcorp:movim_reaseguro_pr b
		  WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			AND a.NUM_ANO = _ano
			AND a.NUM_MES = _mes
			AND a.COD_SITUACION = 5;
          
		--TERCER NIVEL
		 SELECT COUNT(*),
		        MIN(c.id_reas_caract_ancon),
		        MAX(c.id_reas_caract_ancon)
		   INTO _reg3,
				_reg3_min,
				_reg3_max
		   FROM deivid_ttcorp:movim_tec_pri_ttco a, deivid_ttcorp:movim_reaseguro_pr b, deivid_ttcorp:reas_caract_pri c
		  WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			AND c.id_mov_reas_ancon = b.id_mov_reas_ancon
			AND a.NUM_ANO = _ano
			AND a.NUM_MES = _mes
			AND a.COD_SITUACION = 5;
			
			CALL sp_ttc10(1) returning _v1_data , _v2_data; 
			
			IF _v1_data <> 0 OR _v2_data <> 0 THEN 
				RETURN 1, "Existen registro con flag en prima cobrada, favor corregir la data ";
			END IF 
			
			
			--BORRAR REGISTOS
			IF _reg1 <> 0 OR _reg2 <> 0 OR _reg3 <> 0  THEN
				--NIVEL 3
				DELETE FROM deivid_ttcorp:reas_caract_pri
					  WHERE id_reas_caract_ancon >=_reg3_min;
				--NIVEL 2      
				DELETE FROM deivid_ttcorp:movim_reaseguro_pr
					  WHERE id_mov_reas_ancon >= _reg2_min;
				--NIVEL 1
				DELETE FROM deivid_ttcorp:movim_tec_pri_ttco
					  WHERE id_mov_tecnico_anc >= _reg1_min;
					  
				-- ACTUALIZACION TEMPORAL DE LA PARCONT				
				let _reg1_min = _reg1_min - 1;
				let _reg2_min = _reg2_min - 1;
				let _reg3_min = _reg3_min - 1;
				
				--ACTURALIZACION DE CONTADORES PARA EL CORRER EL PROCEDIMIENTO
				UPDATE parcont 
				   SET valor_parametro = _reg1_min
				 WHERE cod_parametro   = 'ttcorp_id1_pri';
				
				UPDATE parcont 
				   SET valor_parametro = _reg2_min
				 WHERE cod_parametro   = 'ttcorp_id2_pri';
				 
				 UPDATE parcont 
				   SET valor_parametro = _reg3_min
				 WHERE cod_parametro   = 'ttcorp_id3_pri';		  
					  
				-- EJECUCION DEL PROCEDIMIENTO CORREGIDO
				CALL sp_actuario19(a_periodo,a_periodo) returning _reg , _mensaje;
				
				--ACTURALIZACION DE CONTADORES DESPUES DE CORRER EL PROCEDIMIENTO
				UPDATE parcont 
				   SET valor_parametro = _id_mov_tecnico
				 WHERE cod_parametro   = 'ttcorp_id1_pri';
				
				UPDATE parcont 
				   SET valor_parametro = _id_mov_reas
				 WHERE cod_parametro   = 'ttcorp_id2_pri';
				 
				 UPDATE parcont 
				   SET valor_parametro = _id_reas_caract
				 WHERE cod_parametro   = 'ttcorp_id3_pri';		
			ELSE
				--EJECUCION DEL PROCEDIMIENTO SIMPLE
				CALL sp_actuario19(a_periodo,a_periodo) returning _reg , _mensaje;
				
			END IF
			
			-- CONTROL DE RETORNO A POWERBUILDER	
			 RETURN _reg, _mensaje;

	ELIF a_modulo = 2 THEN 	  --COBROS PRIMAS
		--PRIMER NIVEL
	   SELECT COUNT(*),
			  MIN(id_mov_tecnico_anc),
              MAX(id_mov_tecnico_anc)
		 INTO _reg1,
			  _reg1_min,
			  _reg1_max
		  FROM movim_tec_pri_tt
		 WHERE NUM_ANO = _ano
		   AND NUM_MES = _mes 
		   AND COD_SITUACION = 13;

		-- SEGUNDO NIVEL
		 SELECT COUNT(*),
		   		 MIN(b.id_mov_reas_ancon),
                 MAX(b.id_mov_reas_ancon)
		   INTO _reg2,
				_reg2_min,
				_reg2_max
		   FROM movim_tec_pri_tt a, movim_reaseguro_tt b
		  WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			AND a.NUM_ANO = _ano
			AND a.NUM_MES = _mes
			AND a.COD_SITUACION = 13;
          
		--TERCER NIVEL
		 SELECT COUNT(*),
				 MIN(c.id_reas_caract_ancon),
                 MAX(c.id_reas_caract_ancon)
		   INTO _reg3,
				_reg3_min,
				_reg3_max
		  FROM movim_tec_pri_tt a, movim_reaseguro_tt b, reas_caract_pri_tt c
		 WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
		   AND c.id_mov_reas_ancon = b.id_mov_reas_ancon
		   AND a.NUM_ANO = _ano
		   AND a.NUM_MES = _mes
		   AND a.COD_SITUACION = 13;
		   
		   	CALL sp_ttc10(2) returning _v1_data , _v2_data; 
			
			IF _v1_data <> 0 OR _v2_data <> 0 THEN 
				RETURN 1, "Existen registro con flag en Prima Suscrita, favor corregir la data";
			END IF
		   
			
			--BORRAR REGISTOS
			IF _reg1 <> 0 OR _reg2 <> 0 OR _reg3 <> 0  THEN
				--NIVER 3
				DELETE FROM reas_caract_pri_tt
					  WHERE id_reas_caract_ancon >= _reg3_min;
				--NIVER 2      
				DELETE FROM movim_reaseguro_tt
					  WHERE id_mov_reas_ancon   >= _reg2_min;
				--NIVER 1
				DELETE FROM movim_tec_pri_tt
					  WHERE id_mov_tecnico_anc  >= _reg1_min; 
					  
				-- ACTUALIZACION TEMPORAL DE LA PARCONT
				let _reg1_min = _reg1_min - 1;
				let _reg2_min = _reg2_min - 1;
				let _reg3_min = _reg3_min - 1;
				
				--ACTURALIZACION DE CONTADORES PARA EL CORRER EL PROCEDIMIENTO
				UPDATE parcont 
				   SET valor_parametro = _reg1_min
				 WHERE cod_parametro   = 'ttcorp_id1_pri';
				
				UPDATE parcont 
				   SET valor_parametro = _reg2_min
				 WHERE cod_parametro   = 'ttcorp_id2_pri';
				 
				 UPDATE parcont 
				   SET valor_parametro = _reg3_min
				 WHERE cod_parametro   = 'ttcorp_id3_pri';		  
					  
				-- EJECUCION DEL PROCEDIMIENTO CORREGIDO
				CALL sp_actuario_cob(a_periodo,a_periodo) returning _reg , _mensaje;
				
				--ACTURALIZACION DE CONTADORES DESPUES DE CORRER EL PROCEDIMIENTO
				UPDATE parcont 
				   SET valor_parametro = _id_mov_tecnico
				 WHERE cod_parametro   = 'ttcorp_id1_pri';
				
				UPDATE parcont 
				   SET valor_parametro = _id_mov_reas
				 WHERE cod_parametro   = 'ttcorp_id2_pri';
				 
				 UPDATE parcont 
				   SET valor_parametro = _id_reas_caract
				 WHERE cod_parametro   = 'ttcorp_id3_pri';		  
				
				
			ELSE
				--EJECUCION DEL PROCEDIMIENTO SIMPLE
				CALL sp_actuario_cob(a_periodo,a_periodo) returning _reg , _mensaje;
			END IF
			
			-- CONTROL DE RETORNO A POWERBUILDER	
			 RETURN _reg, _mensaje;
	  
			
			
	ELIF a_modulo = 3 THEN	  --SINIESTROS PAGADOS
		--PRIMER NIVEL
	   SELECT COUNT(*),
			  MIN(id_mov_tecnico_anc),
              MAX(id_mov_tecnico_anc)
		 INTO _reg1,
			  _reg1_min,
			  _reg1_max
		 FROM deivid_ttcorp:tmp_det_movim_tecn
		 WHERE NUM_ANO = _ano
		   AND NUM_MES = _mes 
		   AND tip_siniestro <> 'PEN';
		--SEGUNDO NIVEL
		 SELECT COUNT(*),
		   		 MIN(b.id_mov_reas_ancon),
                 MAX(b.id_mov_reas_ancon)
		   INTO _reg2,
				_reg2_min,
				_reg2_max
		   FROM deivid_ttcorp:tmp_det_movim_tecn a, deivid_ttcorp:movim_reaseguro b
		  WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			AND a.NUM_ANO = _ano
			AND a.NUM_MES = _mes
			AND a.tip_siniestro <> 'PEN';
		 --TERCER NIVEL
		 SELECT COUNT(*),
				 MIN(c.id_reas_caract_anc),
                 MAX(c.id_reas_caract_anc)
		   INTO _reg3,
				_reg3_min,
				_reg3_max
		   FROM deivid_ttcorp:tmp_det_movim_tecn a, deivid_ttcorp:movim_reaseguro b, deivid_ttcorp:reas_caract_sin c
		  WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			AND c.id_mov_reas_ancon = b.id_mov_reas_ancon
			AND a.NUM_ANO = _ano
			AND a.NUM_MES = _mes
			AND a.tip_siniestro <> 'PEN';
			
			CALL sp_ttc10(3) returning _v1_data , _v2_data; 
			
			IF _v1_data <> 0 OR _v2_data <> 0 THEN 
				RETURN 1, "Existen registro con flag en Siniestros Pendientes, favor corregir la data";
			END IF
			
			
			--BORRAR REGISTOS
			IF _reg1 <> 0 OR _reg2 <> 0 OR _reg3 <> 0  THEN
				--NIVER 1
				DELETE FROM deivid_ttcorp:reas_caract_sin
					  WHERE id_reas_caract_anc >= _reg3_min
						AND id_reas_caract_anc <= _reg3_max;
				--NIVER 2      
				DELETE FROM deivid_ttcorp:movim_reaseguro
					   WHERE id_mov_reas_ancon >= _reg2_min
					     AND id_mov_reas_ancon <= _reg2_max;
				--NIVER 3
				DELETE FROM deivid_ttcorp:tmp_det_movim_tecn
					  WHERE id_mov_tecnico_anc >= _reg1_min
                        AND	id_mov_tecnico_anc <= _reg1_max;
				let _reg = 1;
				
				let _reg1_min = _reg1_min - 1;
				let _reg2_min = _reg2_min - 1;
				let _reg3_min = _reg3_min - 1;
				
			--ACTURALIZACION DE CONTADORES PARA EL CORRER EL PROCEDIMIENTO
				UPDATE parcont 
				   SET valor_parametro = _reg1_min 
				 WHERE cod_parametro = 'ttcorp_id1_sin';
				
				UPDATE parcont 
				   SET valor_parametro = _reg2_min 
				 WHERE cod_parametro = 'ttcorp_id2_sin';
				 
				 UPDATE parcont 
				   SET valor_parametro = _reg3_min 
				 WHERE cod_parametro = 'ttcorp_id3_sin';
				 
				-- EJECUCION DEL PROCEDIMIENTO CORREGIDO
				CALL sp_aud44(a_periodo,a_periodo) returning _reg , _mensaje;
				
			    --ACTURALIZACION DE CONTADORES DESPUES DE CORRER EL PROCEDIMIENTO
				UPDATE parcont 
				   SET valor_parametro = _id_mov_tecnico 
				 WHERE cod_parametro = 'ttcorp_id1_sin';
				
				UPDATE parcont 
				   SET valor_parametro = _id_mov_reas 
				 WHERE cod_parametro = 'ttcorp_id2_sin';
				 
				 UPDATE parcont 
				   SET valor_parametro = _id_reas_caract 
				 WHERE cod_parametro = 'ttcorp_id3_sin';
			ELSE
			--EJECUCION DEL PROCEDIMIENTO SIMPLE
				CALL sp_aud44(a_periodo,a_periodo) returning _reg , _mensaje;
			END IF
			
			-- CONTROL DE RETORNO A POWERBUILDER	
			 RETURN _reg, _mensaje;
	  
	
	ELIF a_modulo = 4 THEN 		--SINIESTROS PENDIENTES
		--PRIMER NIVEL
	   SELECT  COUNT(*),
			   MIN(id_mov_tecnico_anc),
               MAX(id_mov_tecnico_anc)
		  INTO _reg1,
			   _reg1_min,
			   _reg1_max
		  FROM deivid_ttcorp:tmp_det_movim_tecn
		 WHERE NUM_ANO = _ano
		   AND NUM_MES = _mes 
		   AND tip_siniestro = 'PEN';
		--SEGUNDO NIVEL
		 SELECT  COUNT(*),
				 MIN(b.id_mov_reas_ancon),
                 MAX(b.id_mov_reas_ancon)
		   INTO _reg2,
				_reg2_min,
				_reg2_max
		   FROM deivid_ttcorp:tmp_det_movim_tecn a, deivid_ttcorp:movim_reaseguro b
		  WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			AND a.NUM_ANO = _ano
			AND a.NUM_MES = _mes
			AND a.tip_siniestro = 'PEN';
		--TERCER NIVEL
		 SELECT COUNT(*),
				 MIN(c.id_reas_caract_anc),
                 MAX(c.id_reas_caract_anc)
		   INTO _reg3,
				_reg3_min,
				_reg3_max
		   FROM deivid_ttcorp:tmp_det_movim_tecn a, deivid_ttcorp:movim_reaseguro b, deivid_ttcorp:reas_caract_sin c
		  WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			AND c.id_mov_reas_ancon = b.id_mov_reas_ancon
			AND a.NUM_ANO = _ano
			AND a.NUM_MES = _mes
			AND a.tip_siniestro = 'PEN';
			
			CALL sp_ttc10(4) returning _v1_data , _v2_data; 
			
			IF _v1_data <> 0 OR _v2_data <> 0 THEN 
				RETURN 1, "Existen registro con flag en Sininiestros Pagados, favor corregir la data";
			END IF
			
			
			--BORRAR REGISTOS
			IF _reg1 <> 0 OR _reg2 <> 0 OR _reg3 <> 0  THEN
				--NIVER 1
				DELETE FROM deivid_ttcorp:reas_caract_sin
					  WHERE id_reas_caract_anc >= _reg3_min
						AND id_reas_caract_anc <= _reg3_max;
				--NIVER 2      
				DELETE FROM deivid_ttcorp:movim_reaseguro
					  WHERE id_mov_reas_ancon >= _reg2_min
					    AND id_mov_reas_ancon <= _reg2_max;
				--NIVER 3
				DELETE FROM deivid_ttcorp:tmp_det_movim_tecn
					  WHERE id_mov_tecnico_anc >= _reg1_min
                        AND	id_mov_tecnico_anc <= _reg1_max; 
				let _reg = 1;
				
				let _reg1_min = _reg1_min - 1;
				let _reg2_min = _reg2_min - 1;
				let _reg3_min = _reg3_min - 1;
				
				--ACTURALIZACION DE CONTADORES PARA EL CORRER EL PROCEDIMIENTO
				UPDATE parcont 
				   SET valor_parametro = _reg1_min 
				 WHERE cod_parametro = 'ttcorp_id1_sin';
				
				UPDATE parcont 
				   SET valor_parametro = _reg2_min 
				 WHERE cod_parametro = 'ttcorp_id2_sin';
				 
				 UPDATE parcont 
				   SET valor_parametro = _reg3_min 
				 WHERE cod_parametro = 'ttcorp_id3_sin';
				 
				-- EJECUCION DEL PROCEDIMIENTO CORREGIDO
				CALL sp_aud50(a_periodo) returning _reg , _mensaje;
				
			    --ACTURALIZACION DE CONTADORES DESPUES DE CORRER EL PROCEDIMIENTO
				UPDATE parcont 
				   SET valor_parametro = _id_mov_tecnico 
				 WHERE cod_parametro = 'ttcorp_id1_sin';
				
				UPDATE parcont 
				   SET valor_parametro = _id_mov_reas 
				 WHERE cod_parametro = 'ttcorp_id2_sin';
				 
				 UPDATE parcont 
				   SET valor_parametro = _id_reas_caract 
				 WHERE cod_parametro = 'ttcorp_id3_sin';
				
			ELSE
			--EJECUCION DEL PROCEDIMIENTO SIMPLE
				CALL sp_aud50(a_periodo) returning _reg , _mensaje;
			END IF
			
			-- CONTROL DE RETORNO A POWERBUILDER	
			 RETURN _reg, _mensaje;
	END IF
 END PROCEDURE