-- Procedimiento para buscar los reclamos con la ultima transaccion sea cerrar reclamos para completar los incidentes en workflow
-- 
-- creado: 11/05/2005 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf110;

CREATE PROCEDURE "informix".sp_rwf110(a_cod_perfil char(3)) 
			RETURNING DEC(16,2), SMALLINT, DEC(5,2), DEC(5,2), DEC(5,2), DEC(5,2), DEC(5,2), SMALLINT, DEC(5,2), DEC(16,2);  

DEFINE v_sumaasegurada 		DEC(16,2); 
DEFINE v_numpagos      		SMALLINT; 
DEFINE v_desc_be       		DEC(5,2); 
DEFINE v_desc_especial 		DEC(5,2); 
DEFINE v_desc_comprensivo 	DEC(5,2);
DEFINE v_desc_colision 		DEC(5,2); 
DEFINE v_desc_flota			DEC(5,2);
DEFINE v_aut_marca     		SMALLINT;
DEFINE v_desc_be_comer 		DEC(5,2); 
DEFINE v_suma_nuevos        DEC(16,2);

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf43.trc";
--trace on;


SELECT sumaasegurada, 
       numpagos, 
       desc_be, 
       desc_especial, 
       desc_comprensivo, 
       desc_colision, 
       desc_flota,
	   aut_marca,
       desc_be_comer,
	   suma_nuevos
  INTO v_sumaasegurada, 
  	   v_numpagos, 
  	   v_desc_be, 
  	   v_desc_especial, 
  	   v_desc_comprensivo,
  	   v_desc_colision, 
  	   v_desc_flota,
	   v_aut_marca,
	   v_desc_be_comer,
	   v_suma_nuevos
  FROM wf_perfil 
 where cod_perfil = a_cod_perfil;

RETURN v_sumaasegurada,
	   v_numpagos, 
	   v_desc_be, 
	   v_desc_especial, 
	   v_desc_comprensivo,
	   v_desc_colision, 
	   v_desc_flota,
	   v_aut_marca,
	   v_desc_be_comer,
	   v_suma_nuevos;

END PROCEDURE