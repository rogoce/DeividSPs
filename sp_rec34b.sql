
drop procedure sp_rec34b;
CREATE PROCEDURE sp_rec34b(a_documento CHAR(20), fecha DATE)
RETURNING CHAR(10),  -- no_poliza
          CHAR(5),   -- no_endoso
		  CHAR(5),	 -- no_unidad
		  CHAR(50),  -- producto      
		  CHAR(10),  -- cod_contratante
		  CHAR(100), -- nombre_asegurado
		  DEC(16,2), -- suma_asegurada
		  DEC(16,2), -- prima_neta
		  CHAR(10),  -- cod_asegurado
		  INT,		 -- eliminada
		  CHAR(5),
		  DATE,
		  DATE;

DEFINE v_poliza        CHAR(10); 
DEFINE v_contratante   CHAR(10); 
DEFINE v_unidad        CHAR(5);  
DEFINE v_endoso        CHAR(5);  
DEFINE v_suma_aseg     DEC(16,2);
DEFINE v_prima_neta    DEC(16,2);
DEFINE v_eliminada,_dia,_mes,_ano     INT;      
DEFINE v_asegurado     CHAR(100);
DEFINE v_producto      CHAR(50); 

DEFINE _no_unidad      CHAR(5);  
DEFINE _cod_producto   CHAR(5);  
DEFINE _cod_asegurado  CHAR(10); 
DEFINE _vigencia_final DATE;
DEFINE _vigencia_inic,_no_activo_desde  DATE;
DEFINE _fecha_reclamo  DATE;
DEFINE _vigencia_final2 DATE;
define _cod_grupo       char(5);
DEFINE _estatus_poliza,_activo SMALLINT;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec34b.trc";
--TRACE ON;

drop table if exists tmp_tabla;

CREATE TEMP TABLE tmp_tabla(
    no_poliza       CHAR(10),
	no_endoso       CHAR(5),
	no_unidad       CHAR(5),
	cod_producto    CHAR(5),
	contratante     CHAR(10),
	cod_asegurado   CHAR(10),
	suma_aseg       DEC(16,2),
	prima_neta      DEC(16,2),
	eliminada		INT,
	asegurado       char(100),
	vigencia_inic   DATE,
	vigencia_final  DATE,
	PRIMARY KEY (no_poliza, no_unidad)
	) WITH NO LOG;

CREATE INDEX i_tmp_tabla ON tmp_tabla(asegurado);

LET v_poliza = sp_sis21(a_documento);

select cod_grupo,
       vigencia_final,
	   estatus_poliza
  into _cod_grupo,
       _vigencia_final,
	   _estatus_poliza
  from emipomae
 where no_poliza = v_poliza;
	 
let _dia = day(fecha);
let _mes = month(fecha);
let _ano = year(fecha);

if _dia = 29 and _mes = 2 then
	let fecha = MDY(2, 28, _ano);
end if

if _cod_grupo in ("00000","1000") then -- Estado colocar a 2010
	let _fecha_reclamo = fecha - 13 units year;  --SD#6625 Yiniva De Ramos
elif _cod_grupo = '1024' then --Se incluye grupo de la embajada de EEUU ID de la solicitud	# 8394 -- Amado Perez M 14-11-2023
	let _fecha_reclamo = fecha - 13 units year;
else
	let _fecha_reclamo = fecha - 5 units year;
end if	

if a_documento = '1614-00545-09' and _estatus_poliza = 2 then -- Caso de controversia SD# 11645 Yiniva de Ramos 27-09-2024
	let _fecha_reclamo = _vigencia_final;
end if

if a_documento = '1807-00787-01' and _estatus_poliza = 3 then -- Caso Fany 12239
	let _fecha_reclamo = _vigencia_final;
end if
if a_documento = '1808-00681-01' and _estatus_poliza = 2 then -- Caso Fany 14417
	let _fecha_reclamo = _vigencia_final;
end if

if a_documento = '1612-00009-01' and _estatus_poliza = 2 then -- Caso Meivis
	let _fecha_reclamo = fecha - 7 units year;
end if

if a_documento = '1611-00058-01' then -- Caso Meivis
	let _fecha_reclamo = _vigencia_final;
end if


--foreach
/* select	no_poliza,
		vigencia_inic
   into	v_poliza,
		_vigencia_inic
   from	emipomae
  where no_documento       = a_documento
	and actualizado        = 1
  order by vigencia_final desc

	if _vigencia_inic <= fecha then
		exit foreach;
	end if
end foreach

FOREACH*/
	{SELECT x.no_poliza,
		   x.cod_contratante
	  INTO v_poliza,
	       v_contratante
	  FROM emipomae x
	 WHERE no_documento = a_documento
	   AND vigencia_final >= _fecha_reclamo
	   AND x.actualizado   = 1}

{ 	AND x.vigencia_inic  <= fecha
 	AND x.vigencia_final >= fecha}

	-- Asegurados

	FOREACH
		SELECT '00000',
				x.no_poliza,
				x.cod_contratante,
				y.no_unidad,
				y.cod_asegurado,
				y.suma_asegurada,
				y.prima_neta,
				y.cod_producto,
				y.vigencia_inic,
				y.vigencia_final
		  INTO	v_endoso,
				v_poliza,
				v_contratante,
				v_unidad,
				_cod_asegurado,
				v_suma_aseg,
				v_prima_neta,
				_cod_producto,
				_vigencia_inic,
				_vigencia_final
		  FROM	emipomae x
		 inner join emipouni y on y.no_poliza = x.no_poliza
		 WHERE no_documento = a_documento
		   AND x.vigencia_final >= _fecha_reclamo
		   and y.vigencia_inic <= fecha
		   AND x.actualizado = 1
		   AND (y.activo = 1 OR (y.activo = 0 and y.no_activo_desde > _fecha_reclamo))

		SELECT nombre 
		  INTO v_asegurado
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

 		BEGIN
		  ON EXCEPTION IN(-268, -239)						
		  END EXCEPTION

		  INSERT INTO tmp_tabla(
		  no_poliza,
		  no_endoso,    
		  cod_producto, 
		  contratante,  
		  cod_asegurado,
		  no_unidad,    
		  suma_aseg,    
		  prima_neta,
		  eliminada,
		  asegurado,
		  vigencia_inic,
		  vigencia_final
		  )
		  VALUES(
		  v_poliza,
		  v_endoso,
		  _cod_producto,
		  v_contratante,
		  _cod_asegurado,
		  v_unidad,     
		  v_suma_aseg,
		  v_prima_neta,
		  0,
		  v_asegurado,
		  _vigencia_inic,
		  _vigencia_final
		  );
		END
	END FOREACH
	
    -- UNIDADES ELIMINADAS DE EMIPOUNI
	FOREACH
		SELECT y.no_endoso,
			   y.no_poliza,
			   z.cod_contratante,
			   y.no_unidad,
			   y.cod_cliente,
			   y.suma_asegurada,
			   y.prima_neta,
			   y.cod_producto,
			   y.vigencia_inic,
			   y.vigencia_final
		  INTO v_endoso,
			   v_poliza,
			   v_contratante,
			   v_unidad,
			   _cod_asegurado,
			   v_suma_aseg,
			   v_prima_neta,
			   _cod_producto,
			   _vigencia_inic,
			   _vigencia_final
		  FROM endedmae x, endeduni y, emipomae z
		 WHERE x.no_documento = a_documento
		   AND z.no_poliza = x.no_poliza
		   AND y.no_poliza = x.no_poliza
		   AND y.no_endoso = x.no_endoso
		   AND (x.cod_endomov = '011' or x.cod_endomov = '004')
		   AND x.vigencia_inic >= _fecha_reclamo
		   AND x.vigencia_inic <= fecha
		 ORDER BY x.no_endoso desc
	  
		LET _vigencia_final2 = NULL; 
	  
		FOREACH
			SELECT a.vigencia_inic
			  INTO _vigencia_final2
			  FROM endedmae a, endeduni b
			 WHERE a.no_poliza = b.no_poliza
			   AND a.no_endoso = b.no_endoso
			   AND a.no_poliza = v_poliza
			   AND b.no_unidad = v_unidad
			   AND a.cod_endomov = '005'
			 ORDER BY a.no_endoso desc  
			 
			EXIT FOREACH;
			  
		END FOREACH
	 
		IF _vigencia_final2 IS NOT NULL THEN
			LET _vigencia_final = _vigencia_final2; 
		END IF	

		SELECT nombre 
		  INTO v_asegurado
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

		BEGIN
			  ON EXCEPTION IN(-268, -239)						
			  END EXCEPTION

			  INSERT INTO tmp_tabla(
			  no_poliza,
			  no_endoso,    
			  cod_producto, 
			  contratante,  
			  cod_asegurado,
			  no_unidad,    
			  suma_aseg,    
			  prima_neta,
			  eliminada,
			  asegurado,
			  vigencia_inic,
			  vigencia_final
			  )
			  VALUES(
			  v_poliza,
			  v_endoso,
			  _cod_producto,
			  v_contratante,
			  _cod_asegurado,
			  v_unidad,     
			  v_suma_aseg,
			  v_prima_neta,
			  1,
			  v_asegurado,
			  _vigencia_inic,
			  _vigencia_final
			  );
		END
	END FOREACH
--END FOREACH
FOREACH
	SELECT no_poliza,    
	       no_endoso,
	       cod_producto, 
	       contratante,  
		   cod_asegurado,
		   no_unidad,    
		   suma_aseg,    
		   prima_neta,
		   eliminada,
		   asegurado,
		   vigencia_inic,
		   vigencia_final
	  INTO v_poliza,
	       v_endoso,
	       _cod_producto,
	       v_contratante,
		   _cod_asegurado,
		   v_unidad,     
		   v_suma_aseg,
		   v_prima_neta,
		   v_eliminada,
		   v_asegurado,
		  _vigencia_inic,
		  _vigencia_final
	  FROM tmp_tabla
  ORDER BY asegurado
  
	select activo,
	       no_activo_desde
	  into _activo,
	       _no_activo_desde
	  from emipouni
	 where no_poliza = v_poliza
       and no_unidad = v_unidad;

	if _activo = 0 then
		let _vigencia_final = _no_activo_desde;
	end if
	
	SELECT nombre
	  INTO v_producto
	  FROM prdprod
	 WHERE cod_producto = _cod_producto;
	
	RETURN v_poliza,
	       v_endoso,
		   v_unidad,     
		   v_producto,
		   v_contratante,
		   v_asegurado,
	 	   v_suma_aseg,
		   v_prima_neta,
		   _cod_asegurado,
		   v_eliminada,
		   _cod_producto,
		   _vigencia_inic,
		   _vigencia_final
    	   WITH RESUME;
	
END FOREACH
DROP TABLE tmp_tabla;
END PROCEDURE                                                                                                                                                                        
