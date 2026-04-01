-- Procedimiento para mostrar los reportes de costo promedio de piezas (APADEA)
-- Creado    : 06/03/2015 - Autor: Jaime Chevalier
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro704;

CREATE PROCEDURE "informix".sp_pro704(a_compania CHAR(3), a_ano CHAR(4))
	RETURNING   CHAR(50),
				CHAR(50),
				DEC(16,2),
				CHAR(5),
				CHAR(50);    

DEFINE _no_reclamo     	   CHAR(18);
DEFINE _no_motor           CHAR(30);
DEFINE _cod_marca          CHAR(5);
DEFINE _no_orden           CHAR(10);
DEFINE _nombre_marca       CHAR(50);
DEFINE _nombre_parte       CHAR(50);
DEFINE _valor              DEC(16,2);
DEFINE _no_parte           CHAR(5);
DEFINE _compania_nombre    CHAR(50);

CREATE TEMP TABLE tmp_promedio_piezas(
	    nombre_marca     CHAR(50),
		nombre_parte     CHAR(50),
		valor            DEC(16,2),
		no_parte         CHAR(5)
		) WITH NO LOG;

LET _nombre_parte = "";

LET _compania_nombre = sp_sis01(a_compania);

FOREACH

	SELECT no_reclamo,
	       no_orden
	  INTO _no_reclamo,
           _no_orden	  
	  FROM recordma
	 WHERE year(fecha_orden) = a_ano
	   AND actualizado       = 1
	 
	FOREACH
	
		SELECT no_motor			   
		  INTO _no_motor
		  FROM recrcmae 
		 WHERE no_reclamo = _no_reclamo
		 
		SELECT cod_marca	
		  INTO _cod_marca
		  FROM emivehic
        WHERE no_motor = _no_motor;
		
		IF _cod_marca IN ('00122','00098','00710','00096','00010','00070','00031','00086','00080','00091') THEN
			
			SELECT nombre 
			  INTO _nombre_marca
			  FROM emimarca
			 WHERE cod_marca = _cod_marca;
			 
			FOREACH 
	
				SELECT no_parte,
				       valor
				  INTO _no_parte,
				       _valor
				  FROM recordde
				 WHERE no_orden = _no_orden
				   AND no_parte in ('050','840','624','051','976','849','1042','1043','071','072','073','074','106','107','108','109','110','111','075','076','472','892','893','1003','557','558') 
				   
				IF _no_parte in ('050','840','624') THEN --Defensas delanteras y traseras
					LET _no_parte = '001';
					LET _nombre_parte = 'DEFENSAS DELANTERAS';
				ELSE	
					IF _no_parte in('051','976','849') THEN
						LET _no_parte = '002';
					    LET _nombre_parte = 'DEFENSAS TRASERAS';
					ELSE
						IF _no_parte in('071','072','073','074') THEN --Guardafangos 
							LET _no_parte = '003';
							LET _nombre_parte = 'GUARDAFANGOS';
						ELSE
							IF _no_parte in('075','076','071','472','892','893','1003','891','557','558') THEN -- Lamparas
								LET _no_parte = '004';
								LET _nombre_parte = 'LAMPARAS';
							ELSE
								LET _no_parte = '005';
								LET _nombre_parte = 'PUERTAS';
							END IF
						END IF
					END IF
				END IF
				
				INSERT INTO tmp_promedio_piezas(
				nombre_marca,
				nombre_parte,
				valor,
				no_parte)
				values(
				_nombre_marca,
				_nombre_parte,
				_valor,
				_no_parte);
			
			END FOREACH
			
        END IF		   
			
	END FOREACH	
	
END FOREACH

FOREACH

	SELECT nombre_marca,
		   nombre_parte,
		   AVG(valor),
		   no_parte
      INTO _nombre_marca,
		   _nombre_parte,
		   _valor,
		   _no_parte
	  FROM tmp_promedio_piezas
	  GROUP BY 1,2,4
	  ORDER BY 1,2
		  
	RETURN  _nombre_marca,
			_nombre_parte,
			_valor,
			_no_parte,
			_compania_nombre
			WITH RESUME;
		   
END FOREACH

DROP TABLE tmp_promedio_piezas;
END PROCEDURE;