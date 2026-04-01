-- Reporte de Reclamos Pendientes por Ramo
-- 
-- Creado    : 07/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 07/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 27/06/2002 - Autor: Amado Perez M. (Se incluye filtro de agente)
--
-- SIS v.2.0 - d_sp_rec02a_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_mor02;

CREATE PROCEDURE "informix".sp_mor02()
RETURNING CHAR(18),DATE,date,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2);


DEFINE v_filtros         CHAR(255);

DEFINE v_doc_reclamo     CHAR(18);
DEFINE v_cliente_nombre  CHAR(100);				 
DEFINE v_doc_poliza      CHAR(20);
DEFINE v_fecha_reclamo   DATE;
DEFINE v_ultima_fecha    DATE;
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50);
DEFINE v_compania_nombre CHAR(50);

DEFINE _nombre_ajust    CHAR(50);
DEFINE _ajust_interno   CHAR(50);
DEFINE _no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _periodo         CHAR(7);
DEFINE _cnt             smallint;

DEFINE _ld_reserva1 	DECIMAL(16,2);
DEFINE _ld_reserva2 	DECIMAL(16,2);
DEFINE _ld_reserva3 	DECIMAL(16,2);
DEFINE _ld_reserva4 	DECIMAL(16,2);
DEFINE _ld_reserva5 	DECIMAL(16,2);
DEFINE _ld_reserva6 	DECIMAL(16,2);
DEFINE _ld_reserva7 	DECIMAL(16,2);
DEFINE _ld_reserva8 	DECIMAL(16,2);
DEFINE _ld_reserva9 	DECIMAL(16,2);

DEFINE _fecha_pagado    date;


-- Nombre de la Compania

--LET  v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido

CALL sp_rec02(
'001', 
'001', 
'2010-11',
'*',     --suc
'*',     --ajustador
'*',     --grupo
'002;',  --ramo
'*'
) RETURNING v_filtros; 

SET ISOLATION TO DIRTY READ;

FOREACH 
 SELECT no_reclamo,		
 		no_poliza,			
 		pagado_bruto, 		
 		pagado_neto, 
	    reserva_bruto, 	
	    reserva_neto,		
	    incurrido_bruto,	
	    incurrido_neto,
		cod_ramo,		
		periodo,
		numrecla,
		ultima_fecha
   INTO	_no_reclamo, 		
   		_no_poliza,	   	
   		v_pagado_bruto, 		
   		v_pagado_neto, 
	    v_reserva_bruto,		
	    v_reserva_neto, 	
	    v_incurrido_bruto,	
	    v_incurrido_neto,
		_cod_ramo,			
		_periodo,
		v_doc_reclamo,
		v_ultima_fecha
   FROM tmp_sinis 
  WHERE seleccionado = 1
  ORDER BY cod_ramo,numrecla

	select count(*)
	  into _cnt
	  from emipouni
	 where no_poliza = _no_poliza
	   and cod_producto in("00312","00327");  --auto completa

	if _cnt = 0 then
		continue foreach;
	end if

	SELECT fecha_reclamo
	  INTO v_fecha_reclamo
	  FROM recrcmae
	 WHERE no_reclamo  = _no_reclamo
	   AND actualizado = 1;

	let _fecha_pagado = '01/01/1900';

	select max(fecha) 
	  into _fecha_pagado
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and actualizado = 1
	   and cod_tipotran = '004';

   let _ld_reserva1 = 0;
   let _ld_reserva2 = 0;
   let _ld_reserva3 = 0;
   let _ld_reserva4 = 0;
   let _ld_reserva5 = 0;
   let _ld_reserva6 = 0;
   let _ld_reserva7 = 0;
   let _ld_reserva8 = 0;
   let _ld_reserva9 = 0;


   foreach

      SELECT reserva_actual
	 	INTO _ld_reserva1
	 	FROM recrccob
       WHERE no_reclamo    = _no_reclamo
         AND cod_cobertura = "00117" --Asistencia
	
      exit foreach;

   end foreach

   foreach

      SELECT reserva_actual
	 	INTO _ld_reserva2
	 	FROM recrccob
       WHERE no_reclamo    = _no_reclamo
         AND cod_cobertura = "00119" --Colision
	
      exit foreach;

   end foreach

   foreach

      SELECT reserva_actual
	 	INTO _ld_reserva3
	 	FROM recrccob
       WHERE no_reclamo    = _no_reclamo
         AND cod_cobertura = "00118" --Comprensivo
	
      exit foreach;

   end foreach

   foreach

      SELECT reserva_actual
	 	INTO _ld_reserva4
	 	FROM recrccob
       WHERE no_reclamo    = _no_reclamo
         AND cod_cobertura = "00113" --Danos
	
      exit foreach;

   end foreach

   foreach

      SELECT reserva_actual
	 	INTO _ld_reserva5
	 	FROM recrccob
       WHERE no_reclamo    = _no_reclamo
         AND cod_cobertura = "00120" --Incendio
	
      exit foreach;

   end foreach

   foreach

      SELECT reserva_actual
	 	INTO _ld_reserva6
	 	FROM recrccob
       WHERE no_reclamo    = _no_reclamo
         AND cod_cobertura = "00102" --Lesiones
	
      exit foreach;

   end foreach


   foreach

      SELECT reserva_actual
	 	INTO _ld_reserva7
	 	FROM recrccob
       WHERE no_reclamo    = _no_reclamo
         AND cod_cobertura = "00104" --Reembolso
	
      exit foreach;

   end foreach

   foreach

      SELECT reserva_actual
	 	INTO _ld_reserva8
	 	FROM recrccob
       WHERE no_reclamo    = _no_reclamo
         AND cod_cobertura = "00103" --Robo
	
      exit foreach;

   end foreach


   foreach

      SELECT reserva_actual
	 	INTO _ld_reserva9
	 	FROM recrccob
       WHERE no_reclamo    = _no_reclamo
         AND cod_cobertura = "00904" --Rotura de Vidrios
	
      exit foreach;

   end foreach


	RETURN v_doc_reclamo,
	 	   v_fecha_reclamo,
		   _fecha_pagado,
		   v_pagado_bruto,		
		   _ld_reserva1,
		   _ld_reserva2,
		   _ld_reserva3,
		   _ld_reserva4,
		   _ld_reserva5,
		   _ld_reserva6,
		   _ld_reserva7,
		   _ld_reserva8,
		   _ld_reserva9
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE;
