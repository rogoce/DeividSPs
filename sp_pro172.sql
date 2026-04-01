-- Insertando los valores de las cartas de Salud en emicartasal

-- Creado    : 22/08/2006 - Autor: Amado Perez M.
-- Modificado: 22/08/2006 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_pro172;

CREATE PROCEDURE sp_pro172(
    a_no_documento CHAR(20),
    a_nom_cliente  VARCHAR(100),
    a_fecha_aniv   DATE,
    a_dir          CHAR(100),
    a_tel_pag1     CHAR(10),
    a_tel_pag2     CHAR(10),
    a_cel_pag      CHAR(10), 
    a_nom_agente   VARCHAR(50), 
    a_usuario      CHAR(8) DEFAULT NULL, 
    a_por_edad     smallint,
    a_producto     CHAR(5) DEFAULT NULL,
    a_prima        DEC(16,2) DEFAULT 0)

RETURNING smallint,
		  char(25);

DEFINE _error smallint; 
DEFINE _cod_subramo CHAR(3);

--set debug file to "sp_pro172.trc";

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error    		
	IF _error = -268 OR _error = -239 THEN 
		UPDATE emicartasal
		   SET cod_producto = a_producto,
		       a_prima      = a_prima
	     WHERE no_documento = a_no_documento;
	ELSE
 		RETURN _error, "Error al Actualizar";         
	END IF
END EXCEPTION 
  
  FOREACH
	SELECT cod_subramo
	  INTO _cod_subramo
	  FROM emipomae
	 WHERE no_documento = a_no_documento
	 EXIT FOREACH;
  END FOREACH

  INSERT INTO emicartasal(
  no_documento,
  nombre_cliente,
  fecha_aniv,
  direccion,
  telefono1,
  telefono2,
  celular,
  nombre_agente,
  user_added,
  date_added,
  por_edad,
  cod_subramo,
  cod_producto,
  prima
  )
  VALUES(
  a_no_documento,
  a_nom_cliente,
  a_fecha_aniv,  
  a_dir,           
  a_tel_pag1,    
  a_tel_pag2,    
  a_cel_pag,     
  a_nom_agente,
  a_usuario,
  current,
  a_por_edad,
  _cod_subramo,
  a_producto,
  a_prima
  );

END

RETURN 0, "Actualizacion Exitosa";

END PROCEDURE;