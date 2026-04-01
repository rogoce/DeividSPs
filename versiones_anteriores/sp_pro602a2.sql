drop procedure spj_pro602a2;
create procedure "informix".spj_pro602a2(
a_ramo		varchar(255)	default "*",
a_subramo	varchar(255)	default "*")
returning	char(3) as cod_ramo,
			char(50) as ramo,
			char(3) as cod_subramo,
			char(50) as subramo,
			char(5) as cod_producto,
			char(50) as producto,
			int as cnt_polizas,	
			
			char(20) as poliza,
			date as vigencia_inicial,
			date as vigencia_final,
			char(100) as contratante,
			char(5) as no_unidad,
			char(100) as asegurado,	
			
			varchar(255) as filtros;	

define v_filtros         varchar(255);
define v_ramo_nombre     char(50);
define v_subramo_nombre  char(50);
define v_compania_nombre char(50);

define _cod_ramo        char(3);
define _cod_producto    char(5);
define _nombre          char(50);
define _cod_subramo     char(3);
define _cnt             integer;

define _no_documento	    char(20);
define _vigencia_inic	    date;
define _vigencia_final	    date;
define _nombre_contratante  char(100);
define _no_unidad           char(5);
define _nombre_aseg		    char(100);
-- Cargar el Incurrido
drop table if exists temp_perfil;
CALL spj_pro602( 
a_ramo, 
a_subramo 
) RETURNING v_filtros; 


SET ISOLATION TO DIRTY READ;
FOREACH 
	SELECT distinct a.cod_producto,
		   a.nombre,
		   a.cod_ramo,
		   a.cod_subramo   
	  INTO _cod_producto,
		   _nombre,
		   _cod_ramo,
		   _cod_subramo
	  FROM temp_producto a, temp_perfil b
	 WHERE a.cod_producto = a.cod_producto 
	   and a.seleccionado = 1
	   and b.seleccionado = 1
	   and a.cod_ramo = b.cod_ramo
	   and a.cod_subramo = b.cod_subramo 
  ORDER BY a.cod_ramo, a.cod_subramo, a.cod_producto
  
  LET _cnt = 0;
  
	SELECT sum(cnt)
	  INTO _cnt
	  FROM temp_perfil
	 WHERE cod_producto = _cod_producto
	   AND seleccionado = 1;

	IF _cnt IS NULL THEN
		LET _cnt = 0;
	END IF

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO v_subramo_nombre
	  FROM prdsubra
	 WHERE cod_ramo = _cod_ramo
	   AND cod_subramo = _cod_subramo;
	
	foreach   
	SELECT  no_documento,
			vigencia_inic,
			vigencia_final,
			nombre_contratante,
			no_unidad,
			nombre_aseg
	  INTO  _no_documento,
			_vigencia_inic,
			_vigencia_final,
			_nombre_contratante,
			_no_unidad,
			_nombre_aseg
	  FROM temp_perfil
	 WHERE cod_producto = _cod_producto
	   AND seleccionado = 1	   

		RETURN _cod_ramo,
			   v_ramo_nombre, 	
			   _cod_subramo,		
			   v_subramo_nombre, 
			   _cod_producto,
			   _nombre,		
			   _cnt,
			   _no_documento,
			   _vigencia_inic,
			   _vigencia_final,
			   _nombre_contratante,
			   _no_unidad,
			   _nombre_aseg,			   
			   v_filtros  WITH RESUME;
			   
		end foreach

END FOREACH

DROP TABLE temp_producto;
--DROP TABLE temp_perfil;

END PROCEDURE                                                        