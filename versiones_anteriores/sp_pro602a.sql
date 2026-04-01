drop procedure spj_pro602a;
create procedure "informix".spj_pro602a(
a_ramo		varchar(255)	default "*",
a_subramo	varchar(255)	default "*")
returning	char(3) as cod_ramo,
			char(50) as ramo,
			char(3) as cod_subramo,
			char(50) as subramo,
			char(5) as cod_producto,
			char(50) as producto,
			int as cnt_polizas,
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
	
	IF _cnt = 0 then
		continue foreach;
	end if	

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO v_subramo_nombre
	  FROM prdsubra
	 WHERE cod_ramo = _cod_ramo
	   AND cod_subramo = _cod_subramo;

	RETURN _cod_ramo,
	 	   v_ramo_nombre, 	
	 	   _cod_subramo,		
	 	   v_subramo_nombre, 
		   _cod_producto,
		   _nombre,		
		   _cnt,
           v_filtros  WITH RESUME;

END FOREACH

DROP TABLE temp_producto;
--DROP TABLE temp_perfil;

END PROCEDURE                                                        