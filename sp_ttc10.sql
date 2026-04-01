-- Motor de verificacion de data de deivid_ttcorp
--
-- Creado    : 25/07/2014 - Autor: Angel Tello
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_ttc10;

create procedure "informix".sp_ttc10( a_modulo  smallint )
						returning   integer,
						            integer;

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
define _mensaje  		char(100);
define _tarjeta_cre	    char(20);
define _id_mov_tecnico  integer;
define _id_mov_reas  	integer;
define _id_reas_caract  integer;
define _reg				integer;
define _reg1			integer;
define _reg2			integer;
define _reg3			integer;
define _cont1			integer;
define _cont2			integer;
define _cont3			integer;
define _reg1_min		integer;
define _reg2_min		integer;
define _reg3_min		integer;
define _reg1_max		integer;
define _reg2_max		integer;
define _reg3_max		integer;

set isolation to dirty read;

let _reg = 0;
let _mensaje = 'actualizacion exitosa';


--PROCESO DE VERIFICACION
	IF  a_modulo = 2 THEN 	--PRODUCCION PRIMAS
	
		
		--PRIMER NIVEL
		SELECT COUNT(*),
			   MIN(id_mov_tecnico_anc),
               MAX(id_mov_tecnico_anc)
		 INTO  _reg1,
			   _reg1_min,
			   _reg1_max 
		  FROM deivid_ttcorp:movim_tec_pri_ttco
		 WHERE COD_SITUACION = 5
		   AND FLAG IN(1,2,4);

		-- SEGUNDO NIVEL
		 SELECT COUNT(*),
		   		MIN(b.id_mov_reas_ancon),
                MAX(b.id_mov_reas_ancon)
		   INTO _reg2,
				_reg2_min,
				_reg2_max
		   FROM deivid_ttcorp:movim_tec_pri_ttco a, deivid_ttcorp:movim_reaseguro_pr b
		  WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			AND a.COD_SITUACION = 5
			AND	b.flag = 3;
          
		--TERCER NIVEL
		 -- SELECT COUNT(*),
		        -- MIN(c.id_reas_caract_ancon),
		        -- MAX(c.id_reas_caract_ancon)
		   -- INTO _reg3,
				-- _reg3_min,
				-- _reg3_max
		   -- FROM deivid_ttcorp:movim_tec_pri_ttco a, deivid_ttcorp:movim_reaseguro_pr b, deivid_ttcorp:reas_caract_pri c
		  -- WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			-- AND c.id_mov_reas_ancon = b.id_mov_reas_ancon
			-- AND a.NUM_ANO = _ano
			-- AND a.NUM_MES = _mes
			-- AND a.COD_SITUACION = 5;
	
	ELIF a_modulo = 1 THEN 	  --COBROS PRIMAS
		--PRIMER NIVEL
	   SELECT COUNT(*),
			  MIN(id_mov_tecnico_anc),
              MAX(id_mov_tecnico_anc)
		 INTO _reg1,
			  _reg1_min,
			  _reg1_max
		  FROM movim_tec_pri_tt
		 WHERE COD_SITUACION = 13
		   AND FLAG IN(1,2,4);

		-- SEGUNDO NIVEL
		 SELECT COUNT(*),
		   		 MIN(b.id_mov_reas_ancon),
                 MAX(b.id_mov_reas_ancon)
		   INTO _reg2,
				_reg2_min,
				_reg2_max
		   FROM movim_tec_pri_tt a, movim_reaseguro_tt b
		  WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			AND a.COD_SITUACION = 13
			AND	b.flag = 3;
          
		--TERCER NIVEL
		 -- SELECT COUNT(*),
				 -- MIN(c.id_reas_caract_ancon),
                 -- MAX(c.id_reas_caract_ancon)
		   -- INTO _reg3,
				-- _reg3_min,
				-- _reg3_max
		  -- FROM movim_tec_pri_tt a, movim_reaseguro_tt b, reas_caract_pri_tt c
		 -- WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
		   -- AND c.id_mov_reas_ancon = b.id_mov_reas_ancon
		   -- AND a.NUM_ANO = _ano
		   -- AND a.NUM_MES = _mes
		   -- AND a.COD_SITUACION = 13;
		   
	ELIF a_modulo = 4 THEN	  --SINIESTROS PAGADOS
		--PRIMER NIVEL
	   SELECT COUNT(*),
			  MIN(id_mov_tecnico_anc),
              MAX(id_mov_tecnico_anc)
		 INTO _reg1,
			  _reg1_min,
			  _reg1_max
		 FROM deivid_ttcorp:tmp_det_movim_tecn
		 WHERE tip_siniestro <> 'PEN'
		   AND FLAG IN(1,2,4);
		   
		--SEGUNDO NIVEL
		 SELECT COUNT(*),
		   		 MIN(b.id_mov_reas_ancon),
                 MAX(b.id_mov_reas_ancon)
		   INTO _reg2,
				_reg2_min,
				_reg2_max
		   FROM deivid_ttcorp:tmp_det_movim_tecn a, deivid_ttcorp:movim_reaseguro b
		  WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			AND a.tip_siniestro <> 'PEN'
			AND b.flag = 3;
		 --TERCER NIVEL
		 -- SELECT COUNT(*),
				 -- MIN(c.id_reas_caract_anc),
                 -- MAX(c.id_reas_caract_anc)
		   -- INTO _reg3,
				-- _reg3_min,
				-- _reg3_max
		   -- FROM deivid_ttcorp:tmp_det_movim_tecn a, deivid_ttcorp:movim_reaseguro b, deivid_ttcorp:reas_caract_sin c
		  -- WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			-- AND c.id_mov_reas_ancon = b.id_mov_reas_ancon
			-- AND a.NUM_ANO = _ano
			-- AND a.NUM_MES = _mes
			-- AND a.tip_siniestro <> 'PEN';
	
	ELIF a_modulo = 3 THEN 		--SINIESTROS PENDIENTES
		--PRIMER NIVEL
	   SELECT  COUNT(*),
			   MIN(id_mov_tecnico_anc),
               MAX(id_mov_tecnico_anc)
		  INTO _reg1,
			   _reg1_min,
			   _reg1_max
		  FROM deivid_ttcorp:tmp_det_movim_tecn
		 WHERE tip_siniestro = 'PEN'
		   AND FLAG IN(1,2,4);
		--SEGUNDO NIVEL
		 SELECT  COUNT(*),
				 MIN(b.id_mov_reas_ancon),
                 MAX(b.id_mov_reas_ancon)
		   INTO _reg2,
				_reg2_min,
				_reg2_max
		   FROM deivid_ttcorp:tmp_det_movim_tecn a, deivid_ttcorp:movim_reaseguro b
		  WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			AND a.tip_siniestro = 'PEN'
			AND b.flag = 3;
			
		--TERCER NIVEL
		 -- SELECT COUNT(*),
				 -- MIN(c.id_reas_caract_anc),
                 -- MAX(c.id_reas_caract_anc)
		   -- INTO _reg3,
				-- _reg3_min,
				-- _reg3_max
		   -- FROM deivid_ttcorp:tmp_det_movim_tecn a, deivid_ttcorp:movim_reaseguro b, deivid_ttcorp:reas_caract_sin c
		  -- WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			-- AND c.id_mov_reas_ancon = b.id_mov_reas_ancon
			-- AND a.NUM_ANO = _ano
			-- AND a.NUM_MES = _mes
			-- AND a.tip_siniestro = 'PEN';
	END IF
	
	
RETURN _reg1,
	   _reg2;
	  
END PROCEDURE
