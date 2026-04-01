-- Insertando los valores de las cartas de Salud en emicartasal

-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

--DROP PROCEDURE sp_pro497b;

CREATE PROCEDURE sp_pro497b(
    a_no_documento CHAR(20),
    a_nom_cliente  VARCHAR(100),
    a_fecha_aniv   DATE,
    a_dir          CHAR(100),
    a_tel_pag1     CHAR(10),
    a_tel_pag2     CHAR(10),
    a_nom_agente   VARCHAR(50), 
    a_usuario      CHAR(8) DEFAULT NULL,
    a_periodo      CHAR(7),
    a_dir1         VARCHAR(50),
    a_dir2         VARCHAR(50),
    a_email        VARCHAR(50))

RETURNING smallint,
		  char(25);

DEFINE _error smallint; 
DEFINE _cod_subramo, _cod_perpago, _cod_formapag CHAR(3);
DEFINE _no_poliza, _cod_asegurado  CHAR(10);
DEFINE _cod_producto, _cod_grupo, _cod_producto_new CHAR(5);
DEFINE _prima_asegurado DEC(16,2);
DEFINE _fecha_periodo DATE;

--set debug file to "sp_pro172.trc";

SET ISOLATION TO DIRTY READ;

LET _fecha_periodo = MDY(a_periodo[6,7], 1, a_periodo[1,4]);

--SELECT emi_fecha_salud
--  INTO _fecha_periodo
--  FROM parparam;

--LET _fecha_periodo = _fecha_periodo + 1 UNITS DAY;

IF a_fecha_aniv < _fecha_periodo THEN
	LET a_fecha_aniv = a_fecha_aniv + 1 UNITS YEAR;
END IF 

BEGIN
ON EXCEPTION SET _error    		
	IF _error = -268 OR _error = -239 THEN 
	   LET _cod_producto_new =  sp_pro30g(_no_poliza, _cod_producto, a_periodo); --> VERIFICANDO SI EN ALGUN MOMENTO NO SE CAMBIARON LOS PRODUCTOS A ALGUNAS POLIZAS

       IF _cod_producto_new <> _cod_producto THEN
 		UPDATE tmp_emicartasal
 		   SET periodo      = a_periodo,
 		       fecha_aniv   = a_fecha_aniv 	     
 		 WHERE no_documento = a_no_documento;
       END IF
	ELSE
 		RETURN _error, "Error al Actualizar";         
	END IF
END EXCEPTION 
 
 CALL sp_sis21(a_no_documento) RETURNING _no_poliza;
  
	SELECT cod_subramo, cod_perpago, cod_formapag, cod_grupo
	  INTO _cod_subramo, _cod_perpago, _cod_formapag, _cod_grupo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

  FOREACH
	  SELECT cod_producto, prima_asegurado, cod_asegurado 
	    INTO _cod_producto, _prima_asegurado, _cod_asegurado
		FROM emipouni
	   WHERE no_poliza = _no_poliza

     EXIT FOREACH;
  END FOREACH

  SET LOCK MODE TO WAIT;

  INSERT INTO tmp_emicartasal(
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
  prima,
  cod_perpago,
  cod_formapag,
  periodo,
  cod_grupo
  )
  VALUES(
  a_no_documento,
  a_nom_cliente,
  a_fecha_aniv,  
  a_dir,           
  a_tel_pag1,    
  a_tel_pag2,    
  null,     
  a_nom_agente,
  a_usuario,
  current,
  0,
  _cod_subramo,
  _cod_producto,
  _prima_asegurado,
  _cod_perpago, 
  _cod_formapag,
  a_periodo,
  _cod_grupo
  );

  {UPDATE cliclien
     SET direccion_1 = trim(a_dir1),
	     direccion_2 = trim(a_dir2),
		 e_mail = trim(a_email)
   WHERE cod_cliente = _cod_asegurado; }

END

RETURN 0, "Actualizacion Exitosa";

END PROCEDURE;