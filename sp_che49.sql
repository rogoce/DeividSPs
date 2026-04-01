-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_che49;
CREATE PROCEDURE "informix".sp_che49(a_origen char(1))
returning CHAR(15), 
          CHAR(22),
		  CHAR(11),
		  CHAR(9),
		  CHAR(17),
		  CHAR(1),
		  CHAR(1),
		  CHAR(80),
		  CHAR(10);

define _error			integer;

define	v_cedula   		CHAR(15);
define	v_nombre   		CHAR(22);
define	v_monto   		CHAR(11);
define	v_ruta_numero	CHAR(9);
define	v_cod_cuenta 	CHAR(17);
define	v_tipo_cuenta	CHAR(1);
define	v_no_requis		CHAR(10);
define  v_desc_cheque	CHAR(80);

--set debug file to "sp_cwf1.trc";
--trace on;

FOREACH	WITH HOLD
  SELECT agtagent.cedula,   
         agtagent.nombre,   
         chqchmae.monto,   
         chqbanco.ruta_numero,   
         agtagent.cod_cuenta,   
         agtagent.tipo_cuenta,   
         chqchmae.no_requis
    INTO v_cedula,   
    	 v_nombre,   
    	 v_monto,   
    	 v_ruta_numero,
    	 v_cod_cuenta, 
    	 v_tipo_cuenta,
       	 v_no_requis
    FROM chqchmae, agtagent, chqbanco  
   WHERE agtagent.cod_agente = chqchmae.cod_agente and  
         chqbanco.cod_banco = agtagent.cod_banco and  
         chqchmae.origen_cheque = a_origen AND  
         chqchmae.tipo_requis = 'A' AND  
         chqchmae.pagado = 0 AND  
         chqchmae.autorizado = 1    

    FOREACH
		SELECT desc_cheque
		  INTO v_desc_cheque
		  FROM chqchdes
		 WHERE no_requis = v_no_requis
		 EXIT FOREACH;
	END FOREACH

return trim(v_cedula),   
	   trim(v_nombre),   
	   trim(v_monto),   
	   trim(v_ruta_numero),
	   trim(v_cod_cuenta), 
	   trim(v_tipo_cuenta),
	   'C',
	   trim(v_desc_cheque),
	   trim(v_no_requis)
	   WITH RESUME;
END FOREACH



end procedure