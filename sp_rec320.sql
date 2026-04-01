-- Busqueda de cobertura de Reclamos para Deivid
-- 
-- Creado    : 18/01/2023 - Autor: Amado Perez Mendoza
-- Como el sp_rwf66 que se usa en Workflow
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_rec320;
CREATE PROCEDURE "informix".sp_rec320(a_poliza CHAR(10), a_unidad CHAR(5), a_fecha_sinies DATE)
returning char(5) as cod_cobertura,
		  varchar(50) as descripcion,
		  dec(16,2) as limite_1,
		  dec(16,2) as limite_2,
		  dec(16,2) as prima,
		  varchar(50) as deducible;

define v_no_orden	   	char(5);
define v_desc_orden	   	varchar(50);
define v_deducible	   	varchar(50);
define _cant            SMALLINT;
define _no_endoso	   	char(5);
define _opcion          smallint;
define v_prima          dec(16,2);
define v_limite_1       dec(16,2);
define v_limite_2       dec(16,2);

set isolation to dirty read;
--SET DEBUG FILE TO "sp_cwf3.trc"; 
--trACE ON;

create temp table tmp_coberturas(
                 cod_cobertura  CHAR(5),
				 descripcion    varchar(50),
				 deducible      varchar(50),
                 prima			dec(16,2),	 
				 limite_1       dec(16,2), 
				 limite_2       dec(16,2), primary key (cod_cobertura)) WITH NO LOG;
	
	FOREACH
		SELECT no_endoso 
		  INTO _no_endoso
		  FROM endedmae 
		 WHERE no_poliza = a_poliza
		   AND vigencia_inic <= a_fecha_sinies
		 --  AND fecha_emision <= a_fecha_sinies
		ORDER BY no_endoso
		   
		   FOREACH
			SELECT cod_cobertura, 
			       deducible, 
				   opcion, 
				   prima,
				   limite_1,
				   limite_2
			  INTO v_no_orden, 
			       v_deducible, 
				   _opcion,
				   v_prima,
				   v_limite_1,
				   v_limite_2
			  FROM endedcob
			 WHERE no_poliza = a_poliza
			   AND no_endoso = _no_endoso
			   AND no_unidad = a_unidad
			ORDER BY orden
			   
			SELECT nombre
			  INTO v_desc_orden
			  FROM prdcober
			 WHERE cod_cobertura = v_no_orden; 
			 
			 if _opcion in (0,1) then
				 begin
				 on exception in (-239, -268)
				 end exception			 
				 insert into tmp_coberturas
				  values (v_no_orden, v_desc_orden, v_deducible, v_prima, v_limite_1, v_limite_2);
				 end
             elif _opcion = 2 then
			     update tmp_coberturas
				    set deducible = v_deducible,
					    prima = v_prima,
						limite_1 = v_limite_1,
						limite_2 = v_limite_2
				  where cod_cobertura = v_no_orden;
             elif _opcion = 3 then
			     delete from tmp_coberturas where cod_cobertura = v_no_orden;
             end if			 
		   END FOREACH
		   
	END FOREACH
	
   FOREACH	
		SELECT cod_cobertura,
		       descripcion,
			   limite_1,
			   limite_2,
			   prima,
			   deducible
		  INTO v_no_orden,
		       v_desc_orden,
			   v_limite_1,
			   v_limite_2,
			   v_prima,
			   v_deducible
		  FROM tmp_coberturas
		 
			RETURN v_no_orden,
                   v_desc_orden,
				   v_limite_1,
			       v_limite_2,
			       v_prima,
				   v_deducible WITH RESUME;
  END FOREACH
  
  DROP TABLE tmp_coberturas;
end procedure