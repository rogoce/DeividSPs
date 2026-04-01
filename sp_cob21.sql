-- Reporte de las Remesas Pendientes de Postear
-- 
-- Creado    : 22/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 22/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob21_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob21;

CREATE PROCEDURE "informix".sp_cob21(a_compania CHAR(3)) 
RETURNING CHAR(10),   -- Remesa
		  DATE,		  -- Fecha
		  CHAR(1),	  -- Tipo Remesa
		  CHAR(7),	  -- Periodo
		  CHAR(8),	  -- Usuario
		  DEC(16,2),  -- Monto Chequeo
		  CHAR(50);   -- Nombre Compania    

DEFINE v_remesa 		 CHAR(10);
DEFINE v_fecha           DATE;
DEFINE v_tipo_remesa     CHAR(1);
DEFINE v_periodo		 CHAR(7);
DEFINE v_user_added	 	 CHAR(8);
DEFINE v_monto_chequeo   DEC(16,2);
DEFINE v_compania_nombre CHAR(50); 

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Remesas Pendientes

FOREACH 
 SELECT no_remesa,
 		fecha,
	    tipo_remesa,
	    periodo,
		user_added,
		monto_chequeo
   INTO v_remesa,
 		v_fecha,
	    v_tipo_remesa,
	    v_periodo,
		v_user_added,
		v_monto_chequeo
   FROM cobremae
  WHERE cod_compania = a_compania
    AND actualizado  = 0
  ORDER BY fecha, no_remesa

	RETURN v_remesa,
	 	   v_fecha,
		   v_tipo_remesa,
		   v_periodo,
		   v_user_added,
		   v_monto_chequeo,
		   v_compania_nombre
		   WITH RESUME;	 		

END FOREACH

END PROCEDURE;

