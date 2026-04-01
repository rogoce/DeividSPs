-- Procedimieto que verifica y borra los registros de un mes en las tablas de deivid_ttcorp
--
-- Creado    : 09/07/2014 - Autor: Angel Tello
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_ttc09;

create procedure "informix".sp_ttc09(a_periodo char(7) ,a_modulo	smallint)
			returning   integer,
						integer,
						integer,
						integer;

define _id_mov_tecnico  integer;
define _id_mov_reas  	integer;
define _id_reas_caract  integer;
define _reg				integer;
define _reg1			integer;
define _reg2			integer;
define _reg3			integer;

define _reg1_min_pri1	integer;
define _reg2_min_pri1	integer;
define _reg3_min_pri1	integer;
define _reg1_max_pri1	integer;
define _reg2_max_pri1	integer;
define _reg3_max_pri1	integer;

define _reg1_min_pri2	integer;
define _reg2_min_pri2	integer;
define _reg3_min_pri2	integer;
define _reg1_max_pri2	integer;
define _reg2_max_pri2	integer;
define _reg3_max_pri2	integer;

define _reg1_min_sin1	integer;
define _reg2_min_sin1	integer;
define _reg3_min_sin1	integer;
define _reg1_max_sin1	integer;
define _reg2_max_sin1	integer;
define _reg3_max_sin1	integer;

define _reg1_min_sin2	integer;
define _reg2_min_sin2	integer;
define _reg3_min_sin2	integer;
define _reg1_max_sin2	integer;
define _reg2_max_sin2	integer;
define _reg3_max_sin2	integer;




set isolation to dirty read;

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
	IF  a_modulo = 1 OR a_modulo = 2 THEN 	--PRODUCCION PRIMAS
	
		--PRIMER NIVEL
		SELECT COUNT(*),
			   MIN(id_mov_tecnico_anc),
               MAX(id_mov_tecnico_anc)
		 INTO  _reg1,
			   _reg1_min_pri1,
			   _reg1_max_pri1 
		  FROM deivid_ttcorp:movim_tec_pri_ttco
		 WHERE NUM_ANO = _ano
		   AND NUM_MES = _mes 
		   AND COD_SITUACION = 5;

		-- SEGUNDO NIVEL
		 SELECT COUNT(*),
		   		MIN(b.id_mov_reas_ancon),
                MAX(b.id_mov_reas_ancon)
		   INTO _reg2,
				_reg2_min_pri2,
				_reg2_max_pri2
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
				_reg3_min_pri1,
				_reg3_max_pri1
		   FROM deivid_ttcorp:movim_tec_pri_ttco a, deivid_ttcorp:movim_reaseguro_pr b, deivid_ttcorp:reas_caract_pri c
		  WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
			AND c.id_mov_reas_ancon = b.id_mov_reas_ancon
			AND a.NUM_ANO = _ano
			AND a.NUM_MES = _mes
			AND a.COD_SITUACION = 5;
			
-----------------------------------------------------------------------------COBROS PRIMAS -------------------------------------------------------------------------------------------
		--PRIMER NIVEL
	   SELECT COUNT(*),
			  MIN(id_mov_tecnico_anc),
              MAX(id_mov_tecnico_anc)
		 INTO _reg1,
			  _reg1_min_pri2,
			  _reg1_max_pri2
		  FROM movim_tec_pri_tt
		 WHERE NUM_ANO = _ano
		   AND NUM_MES = _mes 
		   AND COD_SITUACION = 13;

		-- SEGUNDO NIVEL
		 SELECT COUNT(*),
		   		 MIN(b.id_mov_reas_ancon),
                 MAX(b.id_mov_reas_ancon)
		   INTO _reg2,
				_reg2_min_pri2,
				_reg2_max_pri2
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
				_reg3_min_pri2,
				_reg3_max_sin2
		  FROM movim_tec_pri_tt a, movim_reaseguro_tt b, reas_caract_pri_tt c
		 WHERE b.id_mov_tecnico_ancon = a.id_mov_tecnico_anc 
		   AND c.id_mov_reas_ancon = b.id_mov_reas_ancon
		   AND a.NUM_ANO = _ano
		   AND a.NUM_MES = _mes
		   AND a.COD_SITUACION = 13;
			
---------------------------------------------------------------------------PROCESO MAESTROS PARA PRIMAS-----------------------------------------------------------------------------
			IF a_modulo = 1  THEN
				
				IF _reg1_max_pri1 > _reg1_min_pri2 OR _reg2_max_pri1 > _reg2_min_pri2 OR _reg3_max_pri1 > _reg3_min_pri2 THEN 
				
				select *
				  from deivid_ttcorp:movim_tec_pri_ttco
				 where id_mov_tecnico_anc >= _reg1_min_pri1
				   and id_mov_tecnico_anc <= _reg1_max_pri1
				  into temp tmp_movim_tec_pri_ttco;
				create index idx_tmp_movim_tec_pri_ttco_1 on tmp_movim_tec_pri_ttco(id_mov_tecnico_anc);
				 
				select *
				  from deivid_ttcorp:movim_reaseguro_pr
				 where 1=2
				  into temp tmp_movim_reaseguro_pr;
				create index idx_tmp_movim_reaseguro_pr_1 on tmp_movim_reaseguro_pr(id_mov_reas_ancon);
				create index idx_tmp_movim_reaseguro_pr_2 on tmp_movim_reaseguro_pr(id_mov_tecnico_ancon);

				select *
				  from deivid_ttcorp:reas_caract_pri
				 where 1=2
				  into temp tmp_reas_caract_pri;

				create index idx_tmp_reas_caract_pri_1 on tmp_reas_caract_pri(id_reas_caract_ancon);
				create index idx_tmp_reas_caract_pri_2 on tmp_reas_caract_pri(id_mov_reas_ancon);
				
				
				
			ELIF a_modulo = 2  THEN
			
			
			END IF
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------			
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
				
				UPDATE parcont 
				   SET valor_parametro = _reg1_min
				 WHERE cod_parametro   = 'ttcorp_id1_sin';
				
				UPDATE parcont 
				   SET valor_parametro = _reg2_min
				 WHERE cod_parametro   = 'ttcorp_id2_sin';
				 
				 UPDATE parcont 
				   SET valor_parametro = _reg3_min
				 WHERE cod_parametro   = 'ttcorp_id3_sin';
				
			END IF
			
	
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
				
				UPDATE parcont 
				   SET valor_parametro = _reg1_min 
				 WHERE cod_parametro = 'ttcorp_id1_sin';
				
				UPDATE parcont 
				   SET valor_parametro = _reg2_min 
				 WHERE cod_parametro = 'ttcorp_id2_sin';
				 
				 UPDATE parcont 
				   SET valor_parametro = _reg3_min 
				 WHERE cod_parametro = 'ttcorp_id3_sin';
				
			END IF
	END IF

RETURN _reg, 
	   _id_mov_tecnico, 
	   _id_mov_reas, 
	   _id_reas_caract;

 END PROCEDURE