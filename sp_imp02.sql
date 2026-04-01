-- Procedimiento para los calcular los descuentos de la poliza
--
-- Creado    : 15/12/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 15/12/2000 - Autor: Amado Perez Mendoza
--
-- copia del sp_pro54 para la impresion Autor: Federico Coronado
-- Adaptado para que el sistema lea desde las tablas de emision
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_imp02;

CREATE PROCEDURE "informix".sp_imp02(a_poliza CHAR(10), a_unidad CHAR(5),a_general INT)
			RETURNING   CHAR(50),			 --	v_nombre
						DEC(16,2);			 --	v_descuento
	
DEFINE v_nombre  	   CHAR(50);
DEFINE v_descuento	   DEC(16,2);
DEFINE v_descuen_sal   DEC(16,2);
DEFINE v_tmp           DEC(16,2);
DEFINE v_porcentaje    DEC(16,4);
DEFINE v_prima         DEC(16,2);
DEFINE v_prima_uni     DEC(16,2);
DEFINE v_prima_neta	   DEC(16,2);
DEFINE v_orden         int;

DEFINE _contador       INT;
DEFINE _cod_producto   CHAR(5);
DEFINE _descuento_cob  DEC(16,2);
DEFINE _descuent_temp  DEC(16,2);
DEFINE _prima          DEC(16,2); 
DEFINE _cod_descuen    CHAR(3);
DEFINE _no_unidad      CHAR(5);
DEFINE _no_poliza      CHAR(10);
DEFINE _no_endoso      CHAR(5);
DEFINE _cod_cobertura  CHAR(5);
DEFINE _cod_ramo  CHAR(3);
DEFINE _forma_char      CHAR(10); 
DEFINE _siguiente           INTEGER;
SET ISOLATION TO DIRTY READ;

LET v_nombre = '';
LET _cod_ramo = '';
LET _contador = 1;
LET v_descuento = 0;
LET _descuento_cob = 0;
let v_tmp          = 0;
let v_descuen_sal = null;

	select cod_ramo
	  into  _cod_ramo
	  from emipomae
	 where no_poliza = a_poliza;	 	 

drop table if exists temp_unicob;	
CREATE TEMP TABLE temp_unicob(
        no_poliza  CHAR(10),
        no_unidad  CHAR(5),
		cod_cobertura CHAR(5),
        prima       DEC(16,2)
        ) WITH NO LOG;	  
		
drop table if exists temp_new;		
CREATE TEMP TABLE temp_new(
        cod_descuen  CHAR(3),
        no_poliza  CHAR(10),
        no_unidad  CHAR(5),
		descuento   DEC(16,2),
        prima       DEC(16,2)
        ) WITH NO LOG;	 		

  --SET DEBUG FILE TO "sp_imp02.trc";      
  --TRACE ON;    

if a_poliza  = '1620800' then
LET a_poliza = a_poliza;
LET a_unidad = a_unidad;
LET a_general = a_general; 
end if

if _cod_ramo <> '002' and _cod_ramo <> '020'  and _cod_ramo <> '023' then

	IF a_general = 1 THEN
		SELECT SUM(prima) 
		  INTO v_prima
		  FROM emipouni
		 WHERE no_poliza = a_poliza;

		FOREACH
		  SELECT y.prima, y.no_poliza,y.no_unidad, y.cod_cobertura 
			INTO _prima, _no_poliza, _no_unidad, _cod_cobertura
			FROM emipouni x, emipocob y, prdcobpd z
			WHERE y.no_poliza = a_poliza
			AND x.no_poliza = y.no_poliza
			AND x.no_unidad = y.no_unidad
			AND z.cod_producto = x.cod_producto
			AND z.cod_cobertura = y.cod_cobertura
			AND z.acepta_desc = 1

		  INSERT INTO  temp_unicob(
		  no_poliza,
		  no_unidad,
		  cod_cobertura,
		  prima
		  )
		  VALUES(
		  _no_poliza,
		  _no_unidad,
		  _cod_cobertura,
		  _prima
		  );

		END FOREACH

		FOREACH

			SELECT x.cod_descuen, y.nombre, y.orden
			INTO _cod_descuen, v_nombre, v_orden
			FROM emiunide x, emidescu y
			WHERE x.no_poliza = a_poliza
			AND y.cod_descuen = x.cod_descuen
			GROUP BY x.cod_descuen, y.nombre, y.orden
			ORDER BY y.orden

			LET v_descuento = 0;	

			FOREACH	

				   SELECT x.porc_descuento, z.prima, z.cod_producto, z.no_unidad
				   INTO v_porcentaje, v_prima_uni, _cod_producto, _no_unidad
				   FROM emiunide x, emipouni z
				   WHERE z.no_poliza = x.no_poliza
				   AND z.no_unidad = x.no_unidad
				   AND x.no_poliza = a_poliza
				   AND x.cod_descuen = _cod_descuen

					FOREACH	
					  SELECT prima, cod_cobertura
						INTO _prima, _cod_cobertura
						FROM temp_unicob
					   WHERE no_poliza = a_poliza
						 AND no_unidad = _no_unidad

						  LET _descuento_cob = _prima * v_porcentaje / 100;
						  LET _prima = _prima -_descuento_cob;
						  LET v_descuento = v_descuento + _descuento_cob;

						UPDATE temp_unicob
						   SET prima = _prima
						 WHERE no_poliza = a_poliza
						   AND no_unidad = _no_unidad
						   AND cod_cobertura = _cod_cobertura;

					END FOREACH;

	--			LET v_descuento = (v_prima_uni * v_porcentaje / 100) + v_descuento;

			END FOREACH;
			LET v_prima = v_prima - v_descuento;
			LET v_descuen_sal = v_descuento * -1; 
			
		
			RETURN
				v_nombre,
				v_descuen_sal	WITH RESUME;


		END FOREACH

	ELSE
		SELECT SUM(prima),sum(descuento) 
		  INTO v_prima,v_tmp
		  FROM emipouni
		 WHERE no_poliza = a_poliza
		   and no_unidad = a_unidad;

		FOREACH
		  SELECT y.prima, y.no_poliza,y.no_unidad, y.cod_cobertura 
			INTO _prima, _no_poliza, _no_unidad, _cod_cobertura
			FROM emipouni x, emipocob y, prdcobpd z
		   WHERE y.no_poliza = a_poliza
			 AND y.no_unidad = a_unidad
			 AND x.no_poliza = y.no_poliza
			 AND x.no_unidad = y.no_unidad
			 AND z.cod_producto = x.cod_producto
			 AND z.cod_cobertura = y.cod_cobertura
			 AND z.acepta_desc = 1

		  INSERT INTO  temp_unicob(
		  no_poliza,
		  no_unidad,
		  cod_cobertura,
		  prima
		  )
		  VALUES(
		  _no_poliza,
		  _no_unidad,
		  _cod_cobertura,
		  _prima
		  );

		END FOREACH

		FOREACH
			 SELECT y.orden, y.nombre, x.porc_descuento, y.cod_descuen
			 INTO v_orden, v_nombre, v_porcentaje, _cod_descuen
			 FROM emiunide x, emidescu y
			 WHERE y.cod_descuen = x.cod_descuen
			 AND x.no_poliza = a_poliza
			 AND x.no_unidad = a_unidad
			 ORDER BY y.orden

			LET v_descuento = 0;					

			FOREACH

			  SELECT prima, cod_cobertura
				INTO _prima, _cod_cobertura
				FROM temp_unicob
			   WHERE no_poliza = a_poliza
				 AND no_unidad = a_unidad

			  LET _descuento_cob = ROUND((_prima * v_porcentaje / 100),2);
			  LET _prima = _prima -_descuento_cob;
			  LET v_descuento = v_descuento + _descuento_cob;

			  UPDATE temp_unicob
				 SET prima = _prima
			   WHERE no_poliza = a_poliza
				 AND no_unidad = a_unidad
				 AND cod_cobertura = _cod_cobertura;

		END FOREACH;

	--		LET v_descuento = v_prima * v_porcentaje / 100;
			LET v_prima = v_prima - v_descuento;
			LET v_descuen_sal = v_descuento * -1; 
			let v_tmp = v_tmp * -1;

		
			RETURN
				v_nombre,
				v_descuen_sal	WITH RESUME;


		END FOREACH;
	END IF
else
	let v_prima = 0;
	let v_descuen_sal = 0;

	IF a_general = 1 THEN 	
		  
		FOREACH
			SELECT sum(prima), sum(prima_neta)
			  INTO v_prima, v_prima_neta
			  FROM emipouni
			 WHERE no_poliza = a_poliza
		 
			if v_prima is null then
				let v_prima = 0;
			end if	

			if v_prima_neta is null then
				let v_prima_neta = 0;
			end if	
			
			let v_descuen_sal = v_prima - v_prima_neta;
			
			if v_descuen_sal is null then
				let v_descuen_sal = 0;
			end if	
			
			RETURN
			'DESCUENTOS',
			v_descuen_sal	WITH RESUME;		

			RETURN
			'SUBTOTAL DE PRIMAS CON DESCUENTOS:',
			v_prima_neta	WITH RESUME;		
				 
		END FOREACH
	ELSE
		FOREACH
			SELECT sum(prima), sum(prima_neta)
			  INTO v_prima, v_prima_neta
			  FROM emipouni
			 WHERE no_poliza = a_poliza
               AND no_unidad = a_unidad			 
		 
			if v_prima is null then
				let v_prima = 0;
			end if	

			if v_prima_neta is null then
				let v_prima_neta = 0;
			end if	
			
			let v_descuen_sal = v_prima - v_prima_neta;
			
			if v_descuen_sal is null then
				let v_descuen_sal = 0;
			end if	

			RETURN
			'DESCUENTOS',
			v_descuen_sal	WITH RESUME;		

			RETURN
			'SUBTOTAL DE PRIMAS CON DESCUENTOS:',
			v_prima_neta	WITH RESUME;		
				 
		END FOREACH
	END IF
end if

DROP TABLE temp_unicob;
drop table if exists temp_new;
END PROCEDURE