-- Procedimiento que se utuliza cuando se dispara el trigger. 
-- 
-- creado: 20/11/2024 - Autor: Federico Coronado

DROP PROCEDURE sp_webp02;
CREATE PROCEDURE "informix".sp_webp02()
REFERENCING NEW AS nuevo FOR ponderacion; 								  

DEFINE _descripcion         VARCHAR(255);
DEFINE _nombre_viejo        VARCHAR(10);
DEFINE _nombre_nuevo        VARCHAR(10);

let _descripcion = "";

Insert into ponbitacora (cod_cliente, cod_riesgo, valor_ponderacion, usuario, descripcion)
				 values (nuevo.cod_cliente,nuevo.cod_riesgo, nuevo.valor_ponderacion, nuevo.user_add, _descripcion);
END PROCEDURE	