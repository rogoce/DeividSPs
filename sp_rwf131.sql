-- Procedimiento que Realiza la Busqueda de Clientes

-- Creado    : 11/02/2004 - Autor: Amado Perez  

--drop procedure sp_rwf01;

create procedure "informix".sp_rwf01(a_nombre VARCHAR(100) DEFAULT '%', a_cedula VARCHAR(30) DEFAULT '%') 
RETURNING VARCHAR(10), 
          VARCHAR(100),
          VARCHAR(30), 
          VARCHAR(50),
          CHAR(10),
          CHAR(1),
          CHAR(1);
          
--}
DEFINE v_cod_cliente VARCHAR(10);
DEFINE v_nombre      VARCHAR(100);
DEFINE v_cedula      VARCHAR(30);
DEFINE v_direccion   VARCHAR(50);
DEFINE v_telefono    CHAR(10);
DEFINE v_fecha_aniversario    CHAR(10);
DEFINE v_tipo_persona         CHAR(1);
DEFINE v_tiene_fecha       	  CHAR(1);


SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "sp_rwf01.trc"; 
--trace on;

IF TRIM(a_cedula) = "%" THEN
	FOREACH WITH HOLD
	  SELECT cod_cliente,   
	         nombre,   
	         cedula,   
	         direccion_1,   
	         telefono1,
	         fecha_aniversario,
	         tipo_persona  
		INTO v_cod_cliente,
			 v_nombre,
			 v_cedula,
			 v_direccion,
			 v_telefono,
			 v_fecha_aniversario,
			 v_tipo_persona     
		FROM cliclien  
	   WHERE nombre LIKE a_nombre
	ORDER BY nombre ASC  

      LET v_tiene_fecha = "1";

      IF (v_fecha_aniversario IS NULL OR v_fecha_aniversario = "") AND v_tipo_persona = "N"  THEN
		 LET v_tiene_fecha = "0";
	  END IF

	 RETURN v_cod_cliente,
		    v_nombre,     
		    v_cedula,     
		    v_direccion,  
		    v_telefono,   
		    v_tiene_fecha,
		    v_tipo_persona        
		    WITH RESUME;
	END FOREACH
ELSE 	 
	FOREACH WITH HOLD
	  SELECT cod_cliente,   
			 nombre,   
			 cedula,   
			 direccion_1,   
			 telefono1,
			 fecha_aniversario,
			 tipo_persona   
		INTO v_cod_cliente,	 
			 v_nombre,
			 v_cedula,
			 v_direccion,
			 v_telefono,
			 v_fecha_aniversario,
			 v_tipo_persona      
		 FROM cliclien  
		WHERE nombre like a_nombre 
		  AND cedula like a_cedula
	 ORDER BY nombre ASC 

      LET v_tiene_fecha = "1";

      IF (v_fecha_aniversario IS NULL OR v_fecha_aniversario = "") AND v_tipo_persona = "N"  THEN
		 LET v_tiene_fecha = "0";
	  END IF

	 RETURN v_cod_cliente,
		    v_nombre,     
		    v_cedula,     
		    v_direccion,  
		    v_telefono,
		    v_tiene_fecha,
		    v_tipo_persona        
		    WITH RESUME;
	END FOREACH
END IF	  

end procedure;
