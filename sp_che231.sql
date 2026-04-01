
-- Creado    : 21/06/2016 - Autor: Henry Giron
-- Modificado: 21/06/2016 - Autor: Henry 
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_che231;
CREATE PROCEDURE "informix".sp_che231(a_compania CHAR(3), a_fecha_desde DATE, a_fecha_hasta DATE, a_cod_agente char(255)) 
RETURNING 	CHAR(5),  	-- 1 - codigo agente
			CHAR(10),	-- 2 - no_licencia
			CHAR(50),	-- 3 - nombre 
			DATE,		-- 4 - date_added
			CHAR(8),	-- 6 - user_added
			CHAR(1),	-- 7 - estatus
			char(255),  -- 11 - filtros
			smallint;   -- 12 - Cantidad

DEFINE _cod_agente 		CHAR(5);
DEFINE _no_licencia 	CHAR(10);
DEFINE _nombre 			CHAR(50);
DEFINE _date_added 		DATE;
DEFINE _user_added 		CHAR(8);
DEFINE _estatus 		CHAR(1);
DEFINE _tipo            char(1);
DEFINE _fecha_desde     DATE;
DEFINE _fecha_hasta     DATE; 
DEFINE v_filtros        char(255);
DEFINE _cantidad        SMALLINT;
let v_filtros = '';
let _cantidad = 0;

	
CREATE TEMP TABLE tmp_agtmorhis(
	cod_agente 		CHAR(5),
	no_licencia 	CHAR(10),
	nombre 			CHAR(50),
	date_added 		DATE,
	user_added 		CHAR(8),
	estatus 		CHAR(1),
	seleccionado    smallint 
) WITH NO LOG;

FOREACH		 
  SELECT cod_agente,   
         no_licencia,   
         nombre,   
         date_added,   
         user_added,   
         estatus
	INTO _cod_agente,   
         _no_licencia,   
         _nombre,   
         _date_added,   
         _user_added,   
         _estatus  
    FROM agt_mor_his  
     WHERE date_added >= a_fecha_desde
	   AND date_added <= a_fecha_hasta      
		 
		insert into tmp_agtmorhis(
			cod_agente,   
            no_licencia,   
            nombre,   
            date_added,   
            user_added,   
            estatus,
			seleccionado
			)
			values(
			_cod_agente,   
            _no_licencia,   
            _nombre,   
            _date_added,   
            _user_added,   
            _estatus, 
			1
			);	

END FOREACH;		 

IF a_cod_agente <> "*" THEN
	let v_filtros = trim(v_filtros) || " Agente: " ||  TRIM(a_cod_agente);
	LET _tipo = sp_sis04(a_cod_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE tmp_agtmorhis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- Excluir estos Registros
		UPDATE tmp_agtmorhis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
	END IF

	DROP TABLE tmp_codigos;
END IF

select count(distinct nombre)
  into _cantidad
  from tmp_agtmorhis
 where seleccionado = 1;

foreach
	select cod_agente,   
            no_licencia,   
            nombre,   
            date_added,   
            user_added,   
            estatus
	  into _cod_agente,   
            _no_licencia,   
            _nombre,   
            _date_added,   
            _user_added,   
            _estatus
	  from tmp_agtmorhis
	 where seleccionado = 1

	return _cod_agente,   
            _no_licencia,   
            _nombre,   
            _date_added,   
            _user_added,   
            _estatus,			
			v_filtros,
			_cantidad
			with resume;
	   
end foreach;

drop table tmp_agtmorhis;
END PROCEDURE;