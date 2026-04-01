-- Polizas para Cartas de Aumento de Primas
--
-- Creado    : 11/07/2002 - Autor: Armando Moreno

-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_pro139;

CREATE PROCEDURE "informix".sp_pro139(a_cia CHAR(3), a_agencia CHAR(3), a_fecha date)
RETURNING char(20),
          char(100),
		  char(100),
		  integer,
		  integer,
		  char(50),
		  date,
		  date,
		  char(50),
		  char(50),
		  char(50),
		  char(20),
		  char(10),
		  char(10),
		  char(10),
		  char(50);


DEFINE _no_documento    	CHAR(20);
DEFINE _nombre_contratante	CHAR(100); 
DEFINE _nombre_asegurado  	CHAR(100); 
DEFINE _edad				INTEGER;
DEFINE _dependientes    	INTEGER;
DEFINE _nombre_plan			char(50);
DEFINE _vigencia_inic   	DATE;
DEFINE _vigencia_final  	DATE;
DEFINE _direccion_1     	CHAR(50);
DEFINE _direccion_2     	CHAR(50);
DEFINE _email				char(50);
DEFINE _apartado			char(20);
DEFINE _telefono1       	CHAR(10);
DEFINE _telefono2       	CHAR(10);
DEFINE _celular         	CHAR(10);
DEFINE _nombre_corredor		char(50);

DEFINE _no_poliza       	CHAR(10); 
DEFINE _no_unidad       	CHAR(5); 
DEFINE _cod_asegurado   	CHAR(10); 
DEFINE _cod_contratante   	CHAR(10); 
DEFINE _cod_agente   		CHAR(10); 
DEFINE _cod_producto		CHAR(10); 
DEFINE _fecha				DATE;

DEFINE v_descr_cia      	CHAR(50);
DEFINE v_filtros        	CHAR(255);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\demrep41.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

LET v_descr_cia = sp_sis01(a_cia);

--polizas vigentes a la fecha

CALL sp_pro03(a_cia, a_agencia, a_fecha, '018;') RETURNING v_filtros;    

FOREACH
 SELECT no_poliza,
		no_documento,
		cod_contratante
   INTO _no_poliza,
		_no_documento,
		_cod_contratante
   FROM temp_perfil
  WHERE seleccionado = 1

	SELECT nombre
	  INTO _nombre_contratante
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt 
	   where no_poliza = _no_poliza
		exit foreach;
	end foreach

	select nombre
	  into _nombre_corredor
	  from agtagent
	 where cod_agente = _cod_agente;

   FOREACH	
	SELECT cod_asegurado,
	       vigencia_inic,
		   vigencia_final,
		   cod_producto,
		   no_unidad
	  INTO _cod_asegurado,
	       _vigencia_inic,
		   _vigencia_final,
		   _cod_producto,
		   _no_unidad
	  FROM emipouni
	 WHERE no_poliza = _no_poliza

		select count(*)
		  into _dependientes
		  from emidepen
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		select nombre
		  into _nombre_plan
		  from prdprod
		 where cod_producto = _cod_producto;

		SELECT nombre,
			   fecha_aniversario,
			   direccion_1,
			   direccion_2,
			   telefono1,
			   telefono2,
			   celular,
			   apartado,
			   e_mail
		  INTO _nombre_asegurado,
			   _fecha,
			   _direccion_1,
			   _direccion_2,
			   _telefono1,
			   _telefono2,
			   _celular,
			   _apartado,
			   _email
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

		IF _direccion_1 IS NULL THEN
			LET _direccion_1 = "";
		END IF
		IF _direccion_2 IS NULL THEN
			LET _direccion_2 = "";
		END IF
		IF _telefono2 IS NULL THEN
			LET _direccion_2 = "";
		END IF
		IF _telefono1 IS NULL THEN
			LET _telefono1 = "";
		END IF

		LET _edad = YEAR(TODAY) - YEAR(_fecha);

		IF MONTH(TODAY) < MONTH(_fecha) THEN
			LET _edad = _edad - 1;
		ELIF MONTH(_fecha) = MONTH(TODAY) THEN
			IF DAY(TODAY) < DAY(_fecha) THEN
				LET _edad = _edad - 1;
			END IF
		END IF
		
		RETURN _no_documento,    	
			   _nombre_contratante,
			   _nombre_asegurado,  
			   _edad,				
			   _dependientes,
			   _nombre_plan,			
			   _vigencia_inic,   	
			   _vigencia_final,  	
			   _direccion_1,     	
			   _direccion_2,     	
			   _email,				
			   _apartado,			
			   _telefono1,       	
			   _telefono2,       	
			   _celular,         	
			   _nombre_corredor		
			   WITH RESUME;

	END FOREACH

END FOREACH

DROP TABLE temp_perfil;

END PROCEDURE;
