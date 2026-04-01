-- Procedimiento para reporte de siniestralidad por poliza
-- 
-- Creado: 28/08/2015 - Autor: Jaime Chevalier.

DROP PROCEDURE sp_atc28c;
CREATE PROCEDURE "informix".sp_atc28c(a_no_poliza CHAR(10), a_no_unidad CHAR(5))
    RETURNING  CHAR(50),
	           CHAR(50),
			   CHAR(50);

DEFINE _nombre            CHAR(50);
DEFINE _por_descuen       DECIMAL(5,2);
DEFINE _cod_descuent      CHAR(3);
DEFINE _desc04            CHAR(50);
DEFINE _desc05            CHAR(50);
DEFINE _desc06            CHAR(50);

LET _desc04 = '';
LET _desc05 = '';
LET _desc06 = '';

FOREACH 
	SELECT e.cod_descuen,
           c.nombre,
           e.porc_descuento
      INTO _cod_descuent,
           _nombre,
           _por_descuen		   
	FROM emicobde e, emidescu c
	WHERE c. cod_descuen = e.cod_descuen
	AND e.no_poliza = a_no_poliza
	AND e.no_unidad = a_no_unidad
	AND e.cod_descuen in ('004','005','006')
	GROUP BY e.cod_descuen, c.nombre ,e.porc_descuento
	
	If _cod_descuent = '004' Then
		LET _desc04 = _por_descuen || ' %';
	Else 
		if _cod_descuent = '005' Then
			LET _desc05 = _por_descuen || ' %';
		Else
			LET _desc06 = _por_descuen || ' %';
		End If
	End If
	
		RETURN  _desc04,
     	        _desc05,
			    _desc06 with resume;
			
END FOREACH	
		   
END PROCEDURE

